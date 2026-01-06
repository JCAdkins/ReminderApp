from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import or_, select

from app.models.reminder_notification import ReminderNotification

MAX_ATTEMPTS = 5
PROCESSING_TIMEOUT = timedelta(minutes=5)


def claim_due_notifications(db: Session, limit: int = 50):
    now = datetime.utcnow()
    stale_before = now - PROCESSING_TIMEOUT

    # Step 1: candidate IDs
    subquery = (
        db.query(ReminderNotification.id)
        .filter(
            ReminderNotification.sent_at.is_(None),
            ReminderNotification.fire_at <= now,
            ReminderNotification.attempt_count < MAX_ATTEMPTS,
            or_(
                ReminderNotification.processing_at.is_(None),
                ReminderNotification.processing_at < stale_before,
            ),
        )
        .order_by(ReminderNotification.fire_at.asc())
        .limit(limit)
        .subquery()
    )

    # Step 2: atomic claim
    rows_affected = (
        db.query(ReminderNotification)
        .filter(ReminderNotification.id.in_(select(subquery.c.id)))
        .update(
            {
                ReminderNotification.processing_at: now,
                ReminderNotification.delivery_status: "processing",
            },
            synchronize_session="fetch",  # ensures SQLAlchemy tracks updated objects
        )
    )

    db.commit()

    # Step 3: Only fetch objects if something was claimed
    if rows_affected > 0:
        return (
            db.query(ReminderNotification)
            .filter(
                ReminderNotification.processing_at == now,
                ReminderNotification.delivery_status == "processing"
            )
            .all()
        )

    # Nothing claimed
    return []