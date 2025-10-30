from textual.app import App, ComposeResult
from textual.widgets import Header, Footer, Static

class HelloApp(App):
    def compose(self) -> ComposeResult:
        yield Header()
        yield Static("👋 Hello from Textual!", id="main")
        yield Footer()

if __name__ == "__main__":
    HelloApp().run()
