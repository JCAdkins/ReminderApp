from datetime import datetime, timedelta
import pytz
from sqlalchemy.orm import Session
from app.db import SessionLocal
from app.models.reminder import Reminder

def send_notification(reminder: Reminder, seconds_before: int):
    """
    Send the actual notification to the user.
    """
    print(f"[{datetime.utcnow()}] Notify {reminder.user_id}: '{reminder.title}' "
          f"(offset {seconds_before}s before event)")

def get_due_reminders(db: Session):
    """
    Return all active reminders that are due for notification based on offsets.
    """
    now_utc = datetime.now(pytz.UTC)
    reminders = db.query(Reminder).filter(Reminder.status == "active").all()
    
    due = []
    for r in reminders:
        tz = pytz.timezone(r.timezone)
        start_local = r.start_at.astimezone(tz)
        
        for offset in r.notify_offsets or [0]:
            notify_time = start_local - timedelta(seconds=offset)
            if notify_time.astimezone(pytz.UTC) <= now_utc:
                due.append((r, offset))
    
    return due

def process_reminders():
    db = SessionLocal()
    try:
        due_reminders = get_due_reminders(db)
        for reminder, offset in due_reminders:
            send_notification(reminder, offset)

            # Optional: mark completed only if the event has passed completely
            if datetime.now(pytz.UTC) >= reminder.start_at.astimezone(pytz.UTC):
                reminder.status = "completed"
                db.add(reminder)
        db.commit()
    finally:
        db.close()

if __name__ == "__main__":
    process_reminders()
