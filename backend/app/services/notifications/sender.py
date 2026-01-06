from datetime import datetime
from sqlalchemy.orm import Session

from app.models.reminder_notification import ReminderNotification

def dispatch_notification(db: Session, notification: ReminderNotification):
    try:
        print(f"[PROCESSING] reminder={notification.reminder_id} fire_at={notification.fire_at}")

        # TODO: Replace this with actual send logic (push/email/WebSocket)
        # Example: send_push(notification)


        # Mark as sent
        notification.sent_at = datetime.utcnow()
        notification.delivery_status = "sent"
        notification.processing_at = None

    except Exception as e:
        notification.attempt_count += 1
        notification.delivery_status = "failed"
        notification.processing_at = None
        notification.error_message = str(e)
        print(f"[FAILED] reminder={notification.reminder_id} fire_at={notification.fire_at} error={e}")

    finally:
        db.add(notification)
        db.commit()
        print(f"[SENT] reminder={notification.reminder_id} fire_at={notification.fire_at}")
