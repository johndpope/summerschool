from __future__ import print_function
from __future__ import division

import tensorflow as tf
import tensorflow_hub as hub

def process_elmo(tokens_lists, bow=False):
    with tf.Graph().as_default():
        tokens_input = tf.placeholder(shape=[1, None], dtype=tf.string)
        length_input = tf.placeholder(shape=[1], dtype=tf.int32)

        elmo = hub.Module("https://tfhub.dev/google/elmo/2",
                          trainable=False)

        elmo_outputs = elmo(
            inputs={
                "tokens": tokens_input,
                "sequence_len": length_input,
            },
            signature="tokens",
            as_dict=True)

        elmo_0 = tf.tile(elmo_outputs["word_emb"], [1, 1, 2])
        elmo_1 = elmo_outputs["lstm_outputs1"]
        elmo_2 = elmo_outputs["lstm_outputs2"]

        # [batch_size, max_time, 1024, 3]
        stacked_emb = tf.stack([elmo_0, elmo_1, elmo_2], 3)

        # sum along time dimension
        bow_emb = tf.reduce_sum(stacked_emb, 1)

        with tf.Session() as sess:
            sess.run(tf.global_variables_initializer())
            sess.run(tf.tables_initializer())
            fetch = bow_emb if bow else stacked_emb
            for tokens in tokens_lists:
                feeds = {tokens_input: [tokens], length_input: [len(tokens)]}
                emb_np = sess.run(fetch, feed_dict=feeds)
                yield emb_np

