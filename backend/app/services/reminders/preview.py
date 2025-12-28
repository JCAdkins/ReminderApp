from app.models.reminder import Reminder
from app.services.reminders.notification_builder import (
    build_notifications_for_reminder,
)

MAX_PREVIEW_OCCURRENCES = 50


def preview_reminder_notifications(data) -> dict:
    """
    Dry-run recurrence expansion & notification generation.
    No DB writes. No IDs persisted.
    """

    # Create an in-memory Reminder (not added to session)
    reminder = Reminder(**data.model_dump())

    # Safety limit (important!)
    reminder._preview_limit = MAX_PREVIEW_OCCURRENCES

    notifications = build_notifications_for_reminder(reminder)

    grouped = {}
    for n in notifications:
        grouped.setdefault(n.fire_at, []).append(n)

    occurrences = []
    for fire_at, items in grouped.items():
        occurrences.append(
            {
                "occurrence_at": fire_at,
                "notifications": [
                    {
                        "fire_at": n.fire_at,
                        "offset_seconds": n.offset_seconds,
                    }
                    for n in items
                ],
            }
        )

    return {
        "occurrences": sorted(
            occurrences, key=lambda x: x["occurrence_at"]
        ),
        "truncated": len(occurrences) >= MAX_PREVIEW_OCCURRENCES,
    }
