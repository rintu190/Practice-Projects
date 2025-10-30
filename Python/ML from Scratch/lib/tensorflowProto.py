import warnings
import tensorflow as tf

# print(tf.config.list_physical_devices('GPU'))
# warnings.filterwarnings('ignore')
x1 = tf.constant([1,2,3,4])
x2 = tf.constant([5,6,4,3])

result = tf.multiply(x1,x2)

print(result.numpy())   