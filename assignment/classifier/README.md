# JSALT Tutorial: Sentence Representation

---

### Overview

This assignment consists of three notebooks:
* [Prelude](Prelude.ipynb), introducing basic text processing for ML. No work,
  but you'll need this information for the rest of the assignment so read it carefully!
* [Exploration](Exploration.ipynb), in which we'll introduce the Stanford 
  Sentiment Treebank (SST) and train a baseline Naive Bayes model.
* [Neural Bag of Words Model](NeuralBOW.ipynb), in which you'll implement and train a Neural 
  Bag-of-Words model on the SST.
* [Co-occurence Matrix Exploration](Embeddings_SVD_Viz.ipynb), in which you'll create a co-occurence matrix from a reasonably large dataset and visualise word co-occurences and created representations.
* [Vector Representation Exploration](Embeddings_explore.ipynb), in which you'll analyse pretrained embeddings and visualise their algebraic (and therefore, semantic?) relationship to one another in the same vector space. 
 


This assignment builds directly on the [TensorFlow Introduction](../a1/tensorflow/tensorflow.ipynb) and [pandas](https://pandas.pydata.org/pandas-docs/stable/index.html), which we'll be using to manage the datasets.

---

### Environment and Imports

You can either use the environment.yml file to set up a virtual environment or install the required packages. All experiments and tests can be run inside the required notebooks.

Use the environment.yml file by running:

conda env create -f environment.yml

---

