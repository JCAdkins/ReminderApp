import time
from app.services.reminders.scheduler import process_reminders

POLL_INTERVAL = 30  # seconds

if __name__ == "__main__":
    while True:
        process_reminders()
        time.sleep(POLL_INTERVAL)
