#!/bin/bash

##
# Release script for weekX to prepare student version
#
# This will create a new RELEASE_DIR directory (../aX) with the contents of
# this directory. It will remove specified files, and process all .py files and
# .ipynb files to:
#   a) remove any lines ending with #--SOLUTION--
#   b) remove all output cells from .ipynb notebooks
#
# Run as ./make_release.sh <week#>
##

set -e

ASSIGNMENT_NAME=${1:-""}
if [ -z $ASSIGNMENT_NAME ]; then
  echo "Please specify an assignment number!"
  exit 1
fi

# Make sure we have jq installed.
if [ -z `which jq` ]; then
  echo "jq is missing"
  echo "run 'sudo apt-get install jq' to install"
  exit 1
fi

# Colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"

DEV_DIR="$(dirname $0)/${ASSIGNMENT_NAME}-dev"
pushd "${DEV_DIR}"
RELEASE_DIR="../${ASSIGNMENT_NAME}"
rm -rf "${RELEASE_DIR}"    # clear old directory
mkdir -p "${RELEASE_DIR}"  # make a new one

# Copy everything tracked from this directory
# readarray -t files <<<"$(git ls-tree -r master --name-only | sed -r 's/(.*)/"\1"/')"
readarray -t files <<<"$(git ls-tree -r HEAD --name-only)"
echo -e $COL_GREEN"Copying files..."$COL_RESET
for fname in "${files[@]}"; do
  # echo $fname
  cp -v --parents -d -t "${RELEASE_DIR}" "$fname"
done

# Delete anything that shouldn't be published
# Saved models, this script, etc.
patterns=( "\\.pyc$" "\\.npy$" ".*-solution.*" )
for pattern in "${patterns[@]}"
do
  echo -en $COL_YELLOW
  echo "-- Removing file pattern '${pattern}' --"
  readarray -t files <<<"$(find "${RELEASE_DIR}" | grep -P "${pattern}" )"
  for fname in "${files[@]}"; do
    if [[ ! -z "${fname}" ]]; then
      rm -v "${fname}"
    fi
  done
  echo -en $COL_RESET
done

# Delete starter code from all .py and .ipynb files
# removes any line ending in #--SOLUTION--
readarray -t files <<<"$(find "${RELEASE_DIR}" | grep -P ".*py(nb)?$")"
for fname in "${files[@]}"; do
  echo -en $COL_CYAN"Cleaning \"$fname\""$COL_RESET
  cat "${fname}" | sed '/.*#--SOLUTION--[",\s]*/d' > "${fname}.clean"
  echo -e $COL_CYAN" : removed lines: "$COL_RESET
  cat "${fname}" | sed -n '/.*#--SOLUTION--[",\s]*/p'
  mv "${fname}.clean" "${fname}"
done

# Clear all output from .ipynb files
# jq is frickin awesome
readarray -t files <<<"$(find "${RELEASE_DIR}" | grep -P ".*ipynb$")"
for fname in "${files[@]}"; do
  echo -e $COL_MAGENTA"Scrubbing output cells from ($fname)"$COL_RESET
  cat "${fname}" | jq 'del(.cells[].outputs[]?)' > "${fname}.clean"
  mv "${fname}.clean" "${fname}"
done

# Execute (and then remove) custom script for that assignment
CUSTOM_SCRIPT="custom_release.sh"
pushd ${RELEASE_DIR}
if [ -e "${CUSTOM_SCRIPT}" ]; then
  bash "${CUSTOM_SCRIPT}"
  rm -v "${CUSTOM_SCRIPT}"
fi
popd

# Show your work
echo ""
echo -e $COL_GREEN"Output directory "${RELEASE_DIR}":"$COL_RESET
echo ""
ls "${RELEASE_DIR}"/*
echo ""

# Add files to git
git add -v ${RELEASE_DIR}
# git commit -e -m "Update release for Assignment ${ASSIGNMENT_NAME}"

popd

# Print git diff report
SRC="$(dirname $0)/${ASSIGNMENT_NAME}-dev/"
DST="$(dirname $0)/${ASSIGNMENT_NAME}/"
echo -en $COL_CYAN"Diff report: "$COL_RESET
echo -e "${SRC} -> ${DST}"
git diff --cached --stat "${SRC}" "${DST}"
