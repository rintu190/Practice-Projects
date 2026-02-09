# tf_cpu_only.py
import os
os.environ["CUDA_VISIBLE_DEVICES"] = "-1"

import tensorflow as tf
import time

print("TF version:", tf.__version__)
print("GPUs:", tf.config.list_physical_devices('GPU'))

a = tf.random.normal((8000, 8000))
b = tf.random.normal((8000, 8000))

start = time.time()
c = tf.matmul(a, b)
print("Time (CPU):", time.time() - start)
