import uuid
from pydantic import ConfigDict
from sqlalchemy import (
    Column,
    DateTime,
    Integer,
    ForeignKey,
    Index,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db import Base


class ReminderNotification(Base):
    __tablename__ = "reminder_notifications"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
    )

    reminder_id = Column(
        UUID(as_uuid=True),
        ForeignKey("reminders.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    fire_at = Column(
        DateTime(timezone=True),
        nullable=False,
        index=True,
    )

    offset_seconds = Column(
        Integer,
        nullable=False,
        default=0,
    )

    sent_at = Column(
        DateTime(timezone=True),
        nullable=True,
        index=True,
    )

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )

    # Relationships
    reminder = relationship(
        "Reminder",
        backref="notifications",
        lazy="joined",
    )

    __table_args__ = (
        Index(
            "ix_reminder_notifications_due",
            "fire_at",
            "sent_at",
        ),
    )

    model_config = ConfigDict(from_attributes=True)
