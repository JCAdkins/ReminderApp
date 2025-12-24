from sqlalchemy.orm import Session
from datetime import datetime
from app.models.reminder import Reminder
from app.schemas.reminder import ReminderCreate, ReminderUpdate


def create_reminder_service(db: Session, *, user_id, data: ReminderCreate) -> Reminder:
    reminder = Reminder(user_id=user_id, **data.model_dump())
    db.add(reminder)
    db.commit()
    db.refresh(reminder)
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

    db.commit()
    db.refresh(reminder)
    return reminder


def complete_reminder_service(db: Session, *, reminder: Reminder) -> Reminder:
    reminder.status = "completed"
    reminder.completed_at = datetime.utcnow()
    db.commit()
    db.refresh(reminder)
    return reminder


def cancel_reminder_service(db: Session, *, reminder: Reminder) -> Reminder:
    reminder.status = "cancelled"
    db.commit()
    db.refresh(reminder)
    return reminder
