from datetime import datetime
from sqlalchemy.orm import Session
from app.models.reminder import Reminder
from app.models.reminder_notification import ReminderNotification

def complete_reminder(db: Session, reminder_id):
    pending = (
        db.query(ReminderNotification)
        .filter(
            ReminderNotification.reminder_id == reminder_id,
            ReminderNotification.sent_at.is_(None),
        )
        .count()
    )

    if pending == 0:
        reminder = db.get(Reminder, reminder_id)
        if reminder and reminder.status != "completed":
            reminder.status = "completed"
            reminder.completed_at = datetime.utcnow()
            db.add(reminder)
            return True

    return False
