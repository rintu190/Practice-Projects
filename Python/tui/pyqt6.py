from PyQt6.QtWidgets import QApplication, QWidget, QLabel, QLineEdit, QPushButton, QMessageBox, QVBoxLayout
import sys

class MyApp(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("PyQt App")
        self.resize(300, 200)

        self.layout = QVBoxLayout()
        self.label = QLabel("Enter your name:")
        self.entry = QLineEdit()
        self.button = QPushButton("Say Hello")

        self.button.clicked.connect(self.say_hello)

        self.layout.addWidget(self.label)
        self.layout.addWidget(self.entry)
        self.layout.addWidget(self.button)
        self.setLayout(self.layout)

    def say_hello(self):
        name = self.entry.text()
        QMessageBox.information(self, "Greeting", f"Hello, {name}!")

app = QApplication(sys.argv)
window = MyApp()
window.show()
app.exec()
