from datetime import datetime, timedelta
from dateutil.rrule import rrulestr
import pytz
from app.models.reminder import Reminder
from app.models.reminder_notification import ReminderNotification


EXPANSION_DAYS = 45  # rolling window


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
