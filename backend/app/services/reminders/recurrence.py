from datetime import datetime, timedelta
from dateutil.rrule import rrulestr
import pytz
from requests import Session
from app.models.reminder import Reminder
from app.models.reminder_notification import ReminderNotification
from app.services.reminders.notification_builder import build_notifications_for_reminder


EXPANSION_DAYS = 45 
REFILL_THRESHOLD_DAYS = 10


def expand_reminder_occurrences(
    reminder: Reminder,
    *,
    window_start: datetime,
    window_end: datetime,
):
    """
    Expand recurring reminder into concrete occurrences.
    Returns list of (occurrence_datetime_utc).
    """
    tz = pytz.timezone(reminder.timezone)

    start_local = reminder.start_at.astimezone(tz)

    rule = rrulestr(
        reminder.recurrence_rule,
        dtstart=start_local,
    )

    occurrences = []

    for occ in rule.between(
        window_start.astimezone(tz),
        window_end.astimezone(tz),
        inc=True,
    ):
        occurrences.append(occ.astimezone(pytz.UTC))

    return occurrences


def refill_recurring_notifications(db: Session):
    now = datetime.now(pytz.UTC)
    threshold = now + timedelta(days=REFILL_THRESHOLD_DAYS)

    reminders = (
        db.query(Reminder)
        .filter(
            Reminder.recurrence_rule.isnot(None),
            Reminder.status == "active",
        )
        .all()
    )

    for reminder in reminders:
        last_notification = (
            db.query(ReminderNotification)
            .filter(ReminderNotification.reminder_id == reminder.id)
            .order_by(ReminderNotification.fire_at.desc())
            .first()
        )

        if not last_notification or last_notification.fire_at < threshold:
            db.query(ReminderNotification).filter(
                ReminderNotification.reminder_id == reminder.id,
                ReminderNotification.sent_at.is_(None),
            ).delete(synchronize_session=False)

            notifications = build_notifications_for_reminder(
                reminder,
                window_days=EXPANSION_DAYS
            )
            db.add_all(notifications)

    db.commit()