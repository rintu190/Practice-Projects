# tf_gpu_used.py
import tensorflow as tf
import time

print("TF version:", tf.__version__)
print("GPUs:", tf.config.list_physical_devices('GPU'))

# Force GPU
with tf.device('/GPU:0'):
    a = tf.random.normal((12000, 12000))
    b = tf.random.normal((12000, 12000))

    start = time.time()
    c = tf.matmul(a, b)
    print("Time (GPU):", time.time() - start)
