from datetime import datetime
from sqlalchemy.orm import Session

from app.models.reminder_notification import ReminderNotification
from app.services.reminders.status import complete_reminder


def dispatch_notification(db: Session, notification: ReminderNotification):
    try:
        print(f"[PROCESSING] reminder={notification.reminder_id} fire_at={notification.fire_at}")

        # TODO: actual send logic here

        # Mark as sent
        notification.sent_at = datetime.utcnow()
        notification.delivery_status = "sent"
        notification.processing_at = None

        db.add(notification)
        db.commit()

        print(f"[SENT] reminder={notification.reminder_id} fire_at={notification.fire_at}")

        # NEW: maybe complete the reminder
        completed = complete_reminder(db, notification.reminder_id)
        if completed:
            db.commit()
            print(f"[REMINDER COMPLETED] {notification.reminder_id}")

    except Exception as e:
        notification.attempt_count += 1
        notification.delivery_status = "failed"
        notification.processing_at = None
        notification.error_message = str(e)

        db.add(notification)
        db.commit()

        print(
            f"[FAILED] reminder={notification.reminder_id} "
            f"fire_at={notification.fire_at} error={e}"
        )
