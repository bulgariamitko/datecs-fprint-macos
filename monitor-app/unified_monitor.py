#!/usr/bin/env python3
import rumps
import subprocess
import socket
import time
import json
import os
import shutil

class UnifiedMonitor(rumps.App):
    def __init__(self):
        super(UnifiedMonitor, self).__init__("Monitor", "🟢")
        self.config_path = os.path.expanduser("~/.config/fprint_monitor/config.json")
        self.load_config()

        self.menu = [
            rumps.MenuItem("FPrint Status: Checking...", callback=None),
            rumps.MenuItem("Printer Status: Checking...", callback=None),
            rumps.separator,
            rumps.MenuItem("Start FPrint", callback=self.start_fprint),
            rumps.MenuItem("Restart FPrint", callback=self.restart_fprint),
            rumps.separator,
            rumps.MenuItem("Settings", callback=self.show_settings),
            rumps.MenuItem("Quit All", callback=self.quit_all)
        ]

        # Start monitoring
        self.timer = rumps.Timer(self.check_status, 5)
        self.timer.start()

        # Initial check
        self.check_status(None)

    def load_config(self):
        """Load configuration from file"""
        default_config = {
            "printer_ip": "192.168.1.100",
            "printer_port": 9100
        }

        try:
            os.makedirs(os.path.dirname(self.config_path), exist_ok=True)
            if os.path.exists(self.config_path):
                with open(self.config_path, 'r') as f:
                    self.config = json.load(f)
            else:
                self.config = default_config
                self.save_config()
        except:
            self.config = default_config

    def save_config(self):
        """Save configuration to file"""
        try:
            os.makedirs(os.path.dirname(self.config_path), exist_ok=True)
            with open(self.config_path, 'w') as f:
                json.dump(self.config, f, indent=2)
        except:
            pass

    def check_fprint_running(self):
        """Check if FPrint.exe is running"""
        result = subprocess.run(
            ["pgrep", "-f", "FPrint.exe"],
            capture_output=True,
            text=True
        )
        return result.returncode == 0

    def check_printer_connection(self):
        """Check if printer is accessible"""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(2)
            result = sock.connect_ex((self.config["printer_ip"], self.config["printer_port"]))
            sock.close()
            return result == 0
        except:
            return False

    def check_status(self, _):
        """Check status of both systems"""
        fprint_running = self.check_fprint_running()
        printer_connected = self.check_printer_connection()

        # Update menu items
        fprint_status = "✅ Running" if fprint_running else "❌ Not Running"
        printer_status = "✅ Connected" if printer_connected else "❌ Disconnected"

        self.menu["FPrint Status: Checking..."].title = f"FPrint: {fprint_status}"
        self.menu["Printer Status: Checking..."].title = f"Printer: {printer_status}"

        # Update icon color (use title since we can't use emoji in icon)
        if fprint_running and printer_connected:
            # Both running - GREEN
            self.title = "🟢"
        elif fprint_running or printer_connected:
            # One running - YELLOW
            self.title = "🟡"
        else:
            # Both down - RED
            self.title = "🔴"

    def show_settings(self, _):
        """Show settings dialog"""
        window = rumps.Window(
            title="Monitor Settings",
            message=f"Enter printer IP address and port:\n\nCurrent: {self.config['printer_ip']}:{self.config['printer_port']}",
            default_text=f"{self.config['printer_ip']}:{self.config['printer_port']}",
            ok="Save",
            cancel="Cancel",
            dimensions=(300, 24)
        )

        response = window.run()
        if response.clicked:
            try:
                parts = response.text.split(":")
                if len(parts) == 2:
                    self.config["printer_ip"] = parts[0].strip()
                    self.config["printer_port"] = int(parts[1].strip())
                    self.save_config()
                    rumps.notification(
                        title="Settings Saved",
                        subtitle="Configuration updated",
                        message=f"Printer: {self.config['printer_ip']}:{self.config['printer_port']}"
                    )
                    # Re-check status immediately
                    self.check_status(None)
                else:
                    rumps.alert("Invalid format. Use: IP:PORT (e.g., 192.168.1.100:9100)")
            except ValueError:
                rumps.alert("Invalid port number. Port must be a number (e.g., 9100)")

    def start_fprint(self, _):
        """Start FPrint.exe if not running"""
        if not self.check_fprint_running():
            try:
                # Find wine executable
                wine_path = shutil.which("wine") or "/opt/homebrew/bin/wine"

                # Check if wine exists
                if not os.path.exists(wine_path):
                    rumps.alert(f"Wine not found at {wine_path}. Please install wine via Homebrew: brew install wine-stable")
                    return

                # Use Downloads folder path
                fprint_path = os.path.expanduser("~/Downloads/datecs-fprint-macos/FPrintWIN")

                if not os.path.exists(fprint_path):
                    rumps.alert(f"FPrintWIN not found at {fprint_path}.\n\nPlease ensure the repository is cloned to ~/Downloads/datecs-fprint-macos/")
                    return

                subprocess.Popen(
                    [wine_path, "FPrint.exe", "/resident"],
                    cwd=fprint_path,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    env=dict(os.environ, PATH=f"/opt/homebrew/bin:{os.environ.get('PATH', '')}")
                )
                time.sleep(2)
                self.check_status(None)
                rumps.notification(
                    title="FPrint Started",
                    subtitle="",
                    message="FPrint.exe has been started in resident mode"
                )
            except Exception as e:
                rumps.alert(f"Failed to start FPrint: {str(e)}")
        else:
            rumps.alert("FPrint is already running")

    def restart_fprint(self, _):
        """Restart FPrint.exe"""
        # Kill if running
        subprocess.run(["pkill", "-f", "FPrint.exe"], stderr=subprocess.DEVNULL)
        time.sleep(1)
        # Start again
        self.start_fprint(None)

    def quit_all(self, _):
        """Quit monitoring and FPrint"""
        # Kill FPrint.exe
        subprocess.run(["pkill", "-f", "FPrint.exe"], stderr=subprocess.DEVNULL)
        # Quit this app
        rumps.quit_application()

if __name__ == "__main__":
    app = UnifiedMonitor()
    app.run()
