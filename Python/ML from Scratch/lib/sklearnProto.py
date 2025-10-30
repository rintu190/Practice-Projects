from sklearn import datasets
from sklearn.tree import DecisionTreeClassifier
from sklearn.model_selection import train_test_split

iris = datasets.load_iris()
x = iris.data
y = iris.target

clf = DecisionTreeClassifier()
clf.fit(x,y)
predictions = clf.predict(x)
print("predicted: ",predictions[40:60])
print("actual: ",y[40:60])

x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.2, random_state=42)
clf_split = DecisionTreeClassifier()
clf_split.fit(x_train, y_train)
predictions_split = clf_split.predict(x_test)
print("Predicted Split: ", predictions_split)
print("Actual split: ", y_test)


