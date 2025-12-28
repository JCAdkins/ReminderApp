import uuid
from pydantic import ConfigDict
from sqlalchemy import (
    Column,
    DateTime,
    Integer,
    ForeignKey,
    Index,
    UniqueConstraint,
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

    reminder = relationship(
        "Reminder",
        back_populates="notifications",
    )

    __table_args__ = (
        # Idempotency guarantee
        UniqueConstraint(
            "reminder_id",
            "fire_at",
            "offset_seconds",
            name="uq_reminder_notification_idempotency",
        ),
        # ⚡ Scheduler lookup index
        Index(
            "ix_reminder_notifications_due",
            "fire_at",
            "sent_at",
        ),
    )

    model_config = ConfigDict(from_attributes=True)

    def __repr__(self):
        return (
            f"<ReminderNotification "
            f"id={self.id} "
            f"reminder_id={self.reminder_id} "
            f"fire_at={self.fire_at} "
            f"offset={self.offset_seconds} "
            f"sent_at={self.sent_at}>"
        )
