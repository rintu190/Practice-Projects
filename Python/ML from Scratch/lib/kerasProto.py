from keras.models import Sequential
from keras.layers import Dense,Flatten
from keras.datasets import mnist
from keras.utils import to_categorical

# load
(X_train,y_train),(X_test,y_test) = mnist.load_data()

# PreProcess
X_train = X_train/255.0
X_test = X_test/255.0

y_train = to_categorical(y_train,10)
y_test = to_categorical(y_test,10)

# Build the Model
model = Sequential()
model.add(Flatten(input_shape = (28,28)))
model.add(Dense(128,activation = 'relu'))
model.add(Dense(10,activation = 'softmax'))

# Compile the Model
model.compile(optimizer = 'adam',
              loss = 'categorical_crossentropy',
              metrics = ['accuracy'])

# Train the Model
model.fit(X_train,y_train,epochs = 5, batch_size = 32,
          validation_split = 0.2)

# Evaluate the Model
test_loss, test_accuracy = model.evaluate(X_test,y_test)
print(f"Test Accuracy: {test_accuracy: .4f}")

# Make Prediction
# predictions = model.predict(X_test)
# print(predictions)