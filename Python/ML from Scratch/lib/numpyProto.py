import numpy as np
X = np.array([[1,2],[3,4],[5,6]])
Y = np.array([1,2,3])
mean = np.mean(X,axis = 0)
print(mean)