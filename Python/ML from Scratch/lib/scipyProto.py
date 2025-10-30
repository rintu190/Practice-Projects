# from scipy.misc import imread,imsave,imresize
import imageio.v2 as imageio
from imageio.v2 import imread, imsave

img = imread('elephant.PNG')
print(img.dtype,img.shape)

img_tint = img * [1,0.45,0.3]
imsave('elephant_tinted.jpg',img_tint)

img_resize = imresize(img_tint,(300,300))
imsave('elephant_resized.jpg',img_resize)

