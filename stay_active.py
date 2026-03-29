import time
import subprocess
import os

def play_sound():
    """Attempt to play a sound or notification on Linux."""
    try:
        # Try using paplay (PulseAudio/PipeWire) with a standard freedesktop sound
        sound_path = '/usr/share/sounds/freedesktop/stereo/message.oga'
        if os.path.exists(sound_path):
            subprocess.run(['paplay', sound_path], check=True, stderr=subprocess.DEVNULL)
        else:
            raise FileNotFoundError
    except Exception:
        try:
            # Fallback 1: Text-to-speech
            subprocess.run(['spd-say', 'Stay active!'], check=True, stderr=subprocess.DEVNULL)
        except Exception:
            # Fallback 2: Terminal bell
            print('\a', end='', flush=True)

def main():
    minutes = 3.5
    interval = minutes * 60
    
    print(f"Starting Teams active reminder.")
    print(f"You will hear a sound every {minutes} minutes.")
    print("Press Ctrl+C to stop.")
    
    while True:
        try:
            time.sleep(interval)
            current_time = time.strftime('%H:%M:%S')
            print(f"[{current_time}] Reminder: Move your mouse or interact with Teams!")
            play_sound()
        except KeyboardInterrupt:
            print("\nReminder stopped.")
            break

if __name__ == "__main__":
    main()
