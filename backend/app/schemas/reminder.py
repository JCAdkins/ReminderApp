from datetime import datetime
from typing import List
from uuid import UUID
from pydantic import BaseModel, Field
from enum import Enum

class ReminderType(str, Enum):
    birthday = "birthday"
    anniversary = "anniversary"
    task = "task"
    bill = "bill"
    health = "health"
    trip = "trip"
    custom = "custom"

class ReminderBase(BaseModel):
    title: str
    description: str | None = None
    type: ReminderType | None = None
    start_at: datetime
    end_at: datetime | None = None
    timezone: str
    is_all_day: bool = False
    recurrence_rule: str | None = None
    notify_offsets: list[int] = Field(default_factory=list)
    priority: int = 0

    class Config:
        from_attributes = True


class ReminderCreate(ReminderBase):
    pass


class ReminderUpdate(BaseModel):
    title: str | None = None
    description: str | None = None
    start_at: datetime | None = None
    end_at: datetime | None = None
    timezone: str | None = None
    is_all_day: bool | None = None
    recurrence_rule: str | None = None
    notify_offsets: list[int] | None = None
    priority: int | None = None
    status: str | None = None

    class Config:
        from_attributes = True


class ReminderNotificationResponse(BaseModel):
    id: UUID
    fire_at: datetime
    offset_seconds: int

    class Config:
        from_attributes = True


class ReminderResponse(ReminderBase):
    id: UUID
    status: str
    completed_at: datetime | None
    notifications: List[ReminderNotificationResponse] = Field(default_factory=list)

    class Config:
        from_attributes = True

