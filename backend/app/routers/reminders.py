from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from uuid import UUID

from app.db import get_db
from app.dependencies import get_current_user
from app.schemas.reminder import (
    ReminderCreate,
    ReminderUpdate,
    ReminderResponse,
)
from app.services.reminders.reminders_service import cancel_reminder_service, complete_reminder_service, create_reminder_service, get_user_reminders_service, get_reminder_service, update_reminder_service

router = APIRouter(prefix="/reminders", tags=["Reminders"])

@router.post("", response_model=ReminderResponse)
def create_reminder(
    data: ReminderCreate,
    db: Session = Depends(get_db),
    auth = Depends(get_current_user),
):
    reminder = create_reminder_service(
        db,
        user_id=auth.user.id,
        data=data,
    )
    print("notifs: ", reminder.notifications)
    return ReminderResponse.model_validate(reminder)

@router.get("", response_model=list[ReminderResponse])
def list_reminders(
    db: Session = Depends(get_db),
    auth = Depends(get_current_user),
):
    return get_user_reminders_service(
        db,
        user_id=auth.user.id,
    )

@router.put("/{reminder_id}", response_model=ReminderResponse)
def update_reminder(
    reminder_id: UUID,
    data: ReminderUpdate,
    db: Session = Depends(get_db),
    auth = Depends(get_current_user),
):
    reminder = get_reminder_service(
        db,
        user_id=auth.user.id,
        reminder_id=reminder_id,
    )
    if not reminder:
        raise HTTPException(404, "Reminder not found")

    return update_reminder_service(
        db,
        reminder=reminder,
        data=data,
    )

@router.post("/{reminder_id}/complete", response_model=ReminderResponse)
def complete_reminder(
    reminder_id: UUID,
    db: Session = Depends(get_db),
    auth = Depends(get_current_user),
):
    reminder = get_reminder_service(
        db,
        user_id=auth.user.id,
        reminder_id=reminder_id,
    )
    if not reminder:
        raise HTTPException(404, "Reminder not found")

    return complete_reminder_service(db, reminder=reminder)

@router.delete("/{reminder_id}", response_model=ReminderResponse)
def cancel_reminder(
    reminder_id: UUID,
    db: Session = Depends(get_db),
    auth = Depends(get_current_user),
):
    reminder = get_reminder_service(
        db,
        user_id=auth.user.id,
        reminder_id=reminder_id,
    )
    if not reminder:
        raise HTTPException(404, "Reminder not found")

    return cancel_reminder_service(db, reminder=reminder)
