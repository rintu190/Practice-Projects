import customtkinter as ctk
from tkinter import Menu, messagebox
from matplotlib.figure import Figure
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import random

# ---------- App Configuration ----------
ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("blue")

class InvestmentDashboard(ctk.CTk):
    def __init__(self):
        super().__init__()

        self.title("💹 Investment Dashboard")
        self.geometry("1000x650")
        self.minsize(900, 550)

        # Sample user data
        self.total_investment = 50000
        self.current_value = 57000

        # Build layout
        self.create_menu_bar()
        self.create_sidebar()

        # Main content frame
        self.main_frame = ctk.CTkFrame(self, corner_radius=10)
        self.main_frame.pack(side="right", expand=True, fill="both", padx=20, pady=20)

        # Default page
        self.show_overview()

    # ---------- MENU BAR ----------
    def create_menu_bar(self):
        menubar = Menu(self)

        file_menu = Menu(menubar, tearoff=0)
        file_menu.add_command(label="Exit", command=self.quit)
        menubar.add_cascade(label="File", menu=file_menu)

        view_menu = Menu(menubar, tearoff=0)
        view_menu.add_command(label="Light Mode", command=lambda: ctk.set_appearance_mode("light"))
        view_menu.add_command(label="Dark Mode", command=lambda: ctk.set_appearance_mode("dark"))
        menubar.add_cascade(label="View", menu=view_menu)

        help_menu = Menu(menubar, tearoff=0)
        help_menu.add_command(label="About", command=self.show_about)
        menubar.add_cascade(label="Help", menu=help_menu)

        self.config(menu=menubar)

    # ---------- SIDEBAR ----------
    def create_sidebar(self):
        self.sidebar = ctk.CTkFrame(self, width=200, corner_radius=0)
        self.sidebar.pack(side="left", fill="y")

        ctk.CTkLabel(self.sidebar, text="📊 Dashboard", font=("Segoe UI", 18, "bold")).pack(pady=20)
        ctk.CTkButton(self.sidebar, text="Overview", command=self.show_overview).pack(pady=10, fill="x", padx=20)
        ctk.CTkButton(self.sidebar, text="Add Funds", command=self.show_add_funds).pack(pady=10, fill="x", padx=20)
        ctk.CTkButton(self.sidebar, text="Withdraw Funds", command=self.show_withdraw_funds).pack(pady=10, fill="x", padx=20)
        ctk.CTkButton(self.sidebar, text="Analytics", command=self.show_analytics).pack(pady=10, fill="x", padx=20)
        ctk.CTkButton(self.sidebar, text="About", command=self.show_about).pack(pady=10, fill="x", padx=20)

        ctk.CTkButton(self.sidebar, text="Exit", fg_color="red", hover_color="#b31b1b", command=self.quit).pack(side="bottom", pady=25, fill="x", padx=20)

    # ---------- PAGE 1: Overview ----------
    def show_overview(self):
        self.clear_frame()

        profit = self.current_value - self.total_investment
        profit_percent = (profit / self.total_investment) * 100

        ctk.CTkLabel(self.main_frame, text="💼 Portfolio Overview", font=("Segoe UI", 26, "bold")).pack(pady=20)

        ctk.CTkLabel(self.main_frame, text=f"Total Investment: ₹{self.total_investment:,}", font=("Segoe UI", 18)).pack(pady=10)
        ctk.CTkLabel(self.main_frame, text=f"Current Value: ₹{self.current_value:,}", font=("Segoe UI", 18)).pack(pady=10)

        color = "green" if profit >= 0 else "red"
        ctk.CTkLabel(self.main_frame, text=f"Net {'Profit' if profit >= 0 else 'Loss'}: ₹{abs(profit):,} ({profit_percent:.2f}%)",
                     font=("Segoe UI", 18, "bold"), text_color=color).pack(pady=15)

    # ---------- PAGE 2: Add Funds ----------
    def show_add_funds(self):
        self.clear_frame()

        ctk.CTkLabel(self.main_frame, text="➕ Add Funds", font=("Segoe UI", 26, "bold")).pack(pady=20)
        ctk.CTkLabel(self.main_frame, text="Enter amount to add:").pack(pady=10)

        self.add_entry = ctk.CTkEntry(self.main_frame, placeholder_text="e.g. 10000")
        self.add_entry.pack(pady=10)

        ctk.CTkButton(self.main_frame, text="Add", command=self.add_funds).pack(pady=15)

    def add_funds(self):
        try:
            amount = float(self.add_entry.get())
            self.total_investment += amount
            self.current_value += amount  # assume same increase initially
            messagebox.showinfo("Success", f"₹{amount:,.0f} added to your investment.")
            self.show_overview()
        except ValueError:
            messagebox.showerror("Error", "Please enter a valid amount.")

    # ---------- PAGE 3: Withdraw Funds ----------
    def show_withdraw_funds(self):
        self.clear_frame()

        ctk.CTkLabel(self.main_frame, text="➖ Withdraw Funds", font=("Segoe UI", 26, "bold")).pack(pady=20)
        ctk.CTkLabel(self.main_frame, text="Enter amount to withdraw:").pack(pady=10)

        self.withdraw_entry = ctk.CTkEntry(self.main_frame, placeholder_text="e.g. 5000")
        self.withdraw_entry.pack(pady=10)

        ctk.CTkButton(self.main_frame, text="Withdraw", command=self.withdraw_funds).pack(pady=15)

    def withdraw_funds(self):
        try:
            amount = float(self.withdraw_entry.get())
            if amount > self.current_value:
                messagebox.showerror("Error", "Insufficient funds.")
            else:
                self.current_value -= amount
                messagebox.showinfo("Success", f"₹{amount:,.0f} withdrawn successfully.")
                self.show_overview()
        except ValueError:
            messagebox.showerror("Error", "Please enter a valid amount.")

    # ---------- PAGE 4: Analytics ----------
    def show_analytics(self):
        self.clear_frame()

        ctk.CTkLabel(self.main_frame, text="📈 Investment Growth Chart", font=("Segoe UI", 26, "bold")).pack(pady=20)

        # Generate dummy data
        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
        values = [self.total_investment + random.randint(-3000, 8000) for _ in months]

        # Create chart
        fig = Figure(figsize=(6, 3), dpi=100)
        ax = fig.add_subplot(111)
        ax.plot(months, values, marker="o", color="cyan", linewidth=2)
        ax.set_title("Portfolio Value Over Time", fontsize=12)
        ax.set_ylabel("Value (₹)")
        ax.grid(True, linestyle="--", alpha=0.5)

        # Embed in Tkinter
        canvas = FigureCanvasTkAgg(fig, master=self.main_frame)
        canvas.draw()
        canvas.get_tk_widget().pack(pady=10)

    # ---------- PAGE 5: About ----------
    def show_about(self):
        self.clear_frame()
        ctk.CTkLabel(self.main_frame, text="ℹ️ About This Dashboard", font=("Segoe UI", 26, "bold")).pack(pady=20)
        ctk.CTkLabel(
            self.main_frame,
            text="An interactive Investment Dashboard built in Python.\n"
                 "Features: Live analytics, add/withdraw funds, profit tracking.\n"
                 "Built with CustomTkinter + Matplotlib.",
            justify="center"
        ).pack(pady=15)

    # ---------- Utility ----------
    def clear_frame(self):
        for widget in self.main_frame.winfo_children():
            widget.destroy()


if __name__ == "__main__":
    app = InvestmentDashboard()
    app.mainloop()
