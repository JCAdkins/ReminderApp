from datetime import datetime
from dateutil.rrule import rrulestr
import pytz
from app.models.reminder import Reminder


def expand_reminder_occurrences(
    reminder: Reminder,
    *,
    window_start: datetime,
    window_end: datetime,
):
    """
    Expand recurring reminder into concrete UTC occurrences.
    """

    tz = pytz.timezone(reminder.timezone)

    # Convert start to local time
    start_local = reminder.start_at.astimezone(tz)

    # Strip timezone info (REQUIRED by dateutil)
    naive_start = start_local.replace(tzinfo=None)

    # Build rule with naive dtstart
    rule = rrulestr(
        reminder.recurrence_rule,
        dtstart=naive_start,
    )

    # Convert window bounds to naive local time
    window_start_local = window_start.astimezone(tz).replace(tzinfo=None)
    window_end_local = window_end.astimezone(tz).replace(tzinfo=None)

    occurrences: list[datetime] = []

    for occ in rule.between(
        window_start_local,
        window_end_local,
        inc=True,
    ):
        # Re-attach timezone, then convert to UTC
        localized = tz.localize(occ)
        occurrences.append(localized.astimezone(pytz.UTC))

    return occurrences