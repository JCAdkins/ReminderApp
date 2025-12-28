from fastapi import APIRouter
from app.schemas.reminder import ReminderCreate
from app.services.reminders.preview import preview_reminder_notifications

router = APIRouter()


@router.post("/reminders/preview")
def preview_reminder(data: ReminderCreate):
    return preview_reminder_notifications(data)
