from datetime import timedelta, datetime
import pytz

from app.models.reminder import Reminder
from app.models.reminder_notification import ReminderNotification
from app.services.reminders.recurrence import expand_reminder_occurrences


def build_notifications_for_reminder(
    reminder: Reminder,
    *,
    window_days: int = 45,
):
    now = datetime.now(pytz.UTC)
    window_end = now + timedelta(days=window_days)

    fire_times: list[datetime] = []

    if reminder.recurrence_rule:
        fire_times = expand_reminder_occurrences(
            reminder,
            window_start=now,
            window_end=window_end,
        )
    else:
        fire_times = [reminder.start_at.astimezone(pytz.UTC)]

    notifications: list[ReminderNotification] = []

    offsets = reminder.notify_offsets or [0]

    for fire_time in fire_times:
        for offset in offsets:
            notifications.append(
                ReminderNotification(
                    reminder_id=reminder.id,
                    fire_at=fire_time - timedelta(seconds=offset),
                    offset_seconds=offset,
                )
            )

    return notifications
