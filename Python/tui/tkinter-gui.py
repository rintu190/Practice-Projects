import customtkinter as ctk
from tkinter import messagebox, Menu

# ---------- App Setup ----------
ctk.set_appearance_mode("dark")          # Modes: "light", "dark"
ctk.set_default_color_theme("blue")      # Themes: "blue", "green", "dark-blue"

class DashboardApp(ctk.CTk):
    def __init__(self):
        super().__init__()

        self.title("My Modern Python Dashboard")
        self.geometry("950x600")
        self.minsize(800, 500)

        # Top Menu Bar (like in Windows apps)
        self.create_menubar()

        # Sidebar (Left)
        self.sidebar = ctk.CTkFrame(self, width=200, corner_radius=0)
        self.sidebar.pack(side="left", fill="y")

        ctk.CTkLabel(self.sidebar, text="📊 Dashboard Menu", font=("Segoe UI", 18, "bold")).pack(pady=25)
        ctk.CTkButton(self.sidebar, text="🏠 Home", command=self.show_home).pack(pady=10, fill="x", padx=20)
        ctk.CTkButton(self.sidebar, text="⚙️ Settings", command=self.show_settings).pack(pady=10, fill="x", padx=20)
        ctk.CTkButton(self.sidebar, text="📈 Analytics", command=self.show_analytics).pack(pady=10, fill="x", padx=20)
        ctk.CTkButton(self.sidebar, text="ℹ️ About", command=self.show_about).pack(pady=10, fill="x", padx=20)

        ctk.CTkButton(
            self.sidebar, text="❌ Exit", fg_color="red", hover_color="#b31b1b",
            command=self.quit
        ).pack(side="bottom", pady=25, fill="x", padx=20)

        # Main Content Frame
        self.main_frame = ctk.CTkFrame(self, corner_radius=10)
        self.main_frame.pack(side="right", expand=True, fill="both", padx=20, pady=20)

        # Default Page
        self.show_home()

    # ---------- Menu Bar ----------
    def create_menubar(self):
        menubar = Menu(self)

        # File Menu
        file_menu = Menu(menubar, tearoff=0)
        file_menu.add_command(label="New", command=lambda: messagebox.showinfo("New", "Create a new file (demo)."))
        file_menu.add_separator()
        file_menu.add_command(label="Exit", command=self.quit)
        menubar.add_cascade(label="File", menu=file_menu)

        # View Menu
        view_menu = Menu(menubar, tearoff=0)
        view_menu.add_command(label="🌞 Light Mode", command=lambda: ctk.set_appearance_mode("light"))
        view_menu.add_command(label="🌙 Dark Mode", command=lambda: ctk.set_appearance_mode("dark"))
        menubar.add_cascade(label="View", menu=view_menu)

        # Help Menu
        help_menu = Menu(menubar, tearoff=0)
        help_menu.add_command(label="About", command=self.show_about)
        menubar.add_cascade(label="Help", menu=help_menu)

        self.config(menu=menubar)

    # ---------- Pages ----------
    def show_home(self):
        self.clear_frame()
        ctk.CTkLabel(self.main_frame, text="🏠 Home Dashboard", font=("Segoe UI", 26, "bold")).pack(pady=20)
        ctk.CTkLabel(self.main_frame, text="Welcome to your upgraded Python GUI!").pack(pady=10)
        ctk.CTkButton(
            self.main_frame,
            text="Click Me!",
            command=lambda: messagebox.showinfo("Hello!", "You clicked the Home button.")
        ).pack(pady=20)

    def show_settings(self):
        self.clear_frame()
        ctk.CTkLabel(self.main_frame, text="⚙️ Settings", font=("Segoe UI", 26, "bold")).pack(pady=20)
        ctk.CTkLabel(self.main_frame, text="Switch between themes or adjust preferences.").pack(pady=10)

        ctk.CTkButton(self.main_frame, text="🌞 Light Mode", command=lambda: ctk.set_appearance_mode("light")).pack(pady=10)
        ctk.CTkButton(self.main_frame, text="🌙 Dark Mode", command=lambda: ctk.set_appearance_mode("dark")).pack(pady=10)

    def show_analytics(self):
        self.clear_frame()
        ctk.CTkLabel(self.main_frame, text="📈 Analytics Page", font=("Segoe UI", 26, "bold")).pack(pady=20)
        ctk.CTkLabel(self.main_frame, text="You can embed charts or tables here.").pack(pady=10)
        ctk.CTkProgressBar(self.main_frame, width=400).pack(pady=30)
        ctk.CTkButton(self.main_frame, text="Simulate Data Load", command=self.simulate_loading).pack(pady=10)

    def show_about(self):
        self.clear_frame()
        ctk.CTkLabel(self.main_frame, text="ℹ️ About This App", font=("Segoe UI", 26, "bold")).pack(pady=20)
        ctk.CTkLabel(
            self.main_frame,
            text="A clean, professional GUI built using Python and CustomTkinter.\n"
                 "Now with a top menu bar and responsive layout!",
            justify="center"
        ).pack(pady=10)

    # ---------- Utility ----------
    def simulate_loading(self):
        messagebox.showinfo("Simulate", "Pretending to load analytics data...")

    def clear_frame(self):
        for widget in self.main_frame.winfo_children():
            widget.destroy()


if __name__ == "__main__":
    app = DashboardApp()
    app.mainloop()
