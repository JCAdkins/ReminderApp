import uuid
from pydantic import ConfigDict
from sqlalchemy import (
    Column,
    DateTime,
    Integer,
    ForeignKey,
    Index,
    String,
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

    processing_at = Column(
        DateTime(timezone=True),
        nullable=True,
        index=True,
    )

    delivery_status = Column(
        String,
        nullable=False,
        default="pending",  # pending | sent | failed
        index=True,
    )

    attempt_count = Column(
        Integer,
        nullable=False,
        default=0,
    )

    error_message = Column(
        String,
        nullable=True,
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
            postgresql_where=sent_at.is_(None),
        )
    )

    def validate_fire_at(self):
        if self.fire_at.tzinfo is None:
            raise ValueError("fire_at must be timezone-aware (UTC)")

    model_config = ConfigDict(from_attributes=True)

    def __repr__(self):
        return (
            f"<ReminderNotification "
            f"id={self.id} "
            f"reminder_id={self.reminder_id} "
            f"fire_at={self.fire_at} "
            f"offset={self.offset_seconds} "
            f"sent_at={self.sent_at}>"
            f"delivery_status={self.delivery_status}>"
            f"error_message={self.error_message}>"
            f"processing_at={self.processing_at}>"
        )
