from textual.app import App, ComposeResult
from textual.screen import Screen
from textual.widgets import Header, Footer, Button, Static
from textual.containers import Vertical

# ----------- Screen for main menu -----------
class MenuDashboard(App):
    CSS_PATH = "dashboard.css"

    def compose(self) -> ComposeResult:
        yield Header(show_clock=True)
        yield Static("📊 Welcome to My TUI Dashboard!", id="title")

        with Vertical(id="menu"):
            yield Button("Option 1: Show Message", id="opt1")
            yield Button("Option 2: Exit", id="opt2")

        yield Footer()

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "opt1":
            self.push_screen(MessageScreen())   # ✅ Now correct
        elif event.button.id == "opt2":
            self.exit()


# ----------- Secondary screen -----------
class MessageScreen(Screen):

    def compose(self) -> ComposeResult:
        yield Header()
        yield Static("🎉 Hello! You pressed Option 1.", id="msg")
        yield Button("Back", id="back")
        yield Footer()

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "back":
            self.app.pop_screen()   # ✅ Correct way to go back


# ----------- Run app -----------
if __name__ == "__main__":
    MenuDashboard().run()
