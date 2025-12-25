from datetime import timedelta
import pytz
from sqlalchemy.orm import Session

from app.models.reminder import Reminder
from app.models.reminder_notification import ReminderNotification


def generate_notifications_for_reminder(
    db: Session,
    reminder: Reminder,
    replace_existing: bool = True,
):
    """
    Create ReminderNotification rows for a reminder.

    - Deletes existing notifications (on update)
    - Expands notify_offsets
    - Computes fire_at in UTC
    """

    if replace_existing:
        db.query(ReminderNotification).filter(
            ReminderNotification.reminder_id == reminder.id
        ).delete()

    tz = pytz.timezone(reminder.timezone)

    # Convert start time to local timezone
    start_local = reminder.start_at.astimezone(tz)

    offsets = reminder.notify_offsets or [0]

    notifications = []

    for offset_seconds in offsets:
        fire_local = start_local - timedelta(seconds=offset_seconds)
        fire_utc = fire_local.astimezone(pytz.UTC)

        notifications.append(
            ReminderNotification(
                reminder_id=reminder.id,
                fire_at=fire_utc,
                offset_seconds=offset_seconds,
            )
        )

    db.bulk_save_objects(notifications)
