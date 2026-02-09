# tf_dl_gpu_check.py
import tensorflow as tf

print("TF version:", tf.__version__)
print("GPUs:", tf.config.list_physical_devices('GPU'))

model = tf.keras.Sequential([
    tf.keras.layers.Dense(4096, activation='relu'),
    tf.keras.layers.Dense(10)
])

model.compile(
    optimizer='adam',
    loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True)
)

x = tf.random.normal((4096, 1024))
y = tf.random.uniform((4096,), maxval=10, dtype=tf.int32)

model.fit(x, y, epochs=3, batch_size=256)
