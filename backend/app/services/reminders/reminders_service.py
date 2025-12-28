from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.orm import Session
from datetime import datetime
from app.schemas.reminder import ReminderCreate, ReminderUpdate
from app.models.reminder_notification import ReminderNotification
from app.models.reminder import Reminder
from app.services.reminders.notification_builder import build_notifications_for_reminder



def create_reminder_service(db: Session, *, user_id, data: ReminderCreate) -> Reminder:
    reminder = Reminder(user_id=user_id, **data.model_dump())
    db.add(reminder)
    db.flush()

    notifications = build_notifications_for_reminder(reminder)
    insert_notifications_safe(db, notifications)

    db.flush()
    db.commit()
    db.refresh(reminder)

    reminder.notifications = (
    db.query(ReminderNotification)
    .filter(ReminderNotification.reminder_id == reminder.id)
    .all()
)

    return reminder


def get_user_reminders_service(db: Session, *, user_id):
    return (
        db.query(Reminder)
        .filter(Reminder.user_id == user_id)
        .order_by(Reminder.start_at.asc())
        .all()
    )


def get_reminder_service(db: Session, *, user_id, reminder_id):
    return (
        db.query(Reminder)
        .filter(
            Reminder.id == reminder_id,
            Reminder.user_id == user_id,
        )
        .first()
    )


def update_reminder_service(
    db: Session, *, reminder: Reminder, data: ReminderUpdate
) -> Reminder:
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(reminder, key, value)

    db.query(ReminderNotification).filter(
        ReminderNotification.reminder_id == reminder.id,
        ReminderNotification.sent_at.is_(None),
    ).delete(synchronize_session=False)

    notifications = build_notifications_for_reminder(reminder)
    insert_notifications_safe(db, notifications)

    db.commit()
    db.refresh(reminder)
    return reminder


def complete_reminder_service(db: Session, *, reminder: Reminder) -> Reminder:
    reminder.status = "completed"
    reminder.completed_at = datetime.utcnow()

    db.query(ReminderNotification).filter(
        ReminderNotification.reminder_id == reminder.id,
        ReminderNotification.sent_at.is_(None),
    ).delete(synchronize_session=False)

    db.commit()
    db.refresh(reminder)
    return reminder


def cancel_reminder_service(db: Session, *, reminder: Reminder) -> Reminder:
    reminder.status = "cancelled"

    db.query(ReminderNotification).filter(
        ReminderNotification.reminder_id == reminder.id,
        ReminderNotification.sent_at.is_(None),
    ).delete(synchronize_session=False)

    db.commit()
    db.refresh(reminder)
    return reminder

def insert_notifications_safe(db: Session, notifications: list[ReminderNotification]):
    if not notifications:
        return

    stmt = insert(ReminderNotification).values(
        [
            {
                "reminder_id": n.reminder_id,
                "fire_at": n.fire_at,
                "offset_seconds": n.offset_seconds,
            }
            for n in notifications
        ]
    ).on_conflict_do_nothing(
        index_elements=["reminder_id", "fire_at", "offset_seconds"]
    )

    db.execute(stmt)