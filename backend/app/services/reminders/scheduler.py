from datetime import datetime
import pytz
from sqlalchemy.orm import Session

from app.db import SessionLocal
from app.models.reminder import Reminder
from app.models.reminder_notification import ReminderNotification


def send_notification(reminder: Reminder, offset_seconds: int):
    """
    Dispatch notification.
    Replace this later with push / email / SMS logic.
    """
    print(
        f"[{datetime.utcnow().isoformat()}] "
        f"Notify user={reminder.user_id} | "
        f"title='{reminder.title}' | "
        f"offset={offset_seconds}s"
    )


def process_notifications():
    """
    Find all due, unsent reminder notifications and send them.
    """
    db: Session = SessionLocal()
    try:
        now = datetime.now(pytz.UTC)

        notifications = (
            db.query(ReminderNotification)
            .join(Reminder)
            .filter(
                Reminder.status == "active",
                ReminderNotification.sent_at.is_(None),
                ReminderNotification.fire_at <= now,
            )
            .order_by(ReminderNotification.fire_at.asc())
            .all()
        )

        for notification in notifications:
            send_notification(
                notification.reminder,
                notification.offset_seconds,
            )

            # Mark notification as sent (idempotency)
            notification.sent_at = now

        db.commit()

    except Exception:
        db.rollback()
        raise
    finally:
        db.close()
