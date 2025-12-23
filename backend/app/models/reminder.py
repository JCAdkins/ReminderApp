import uuid
from pydantic import ConfigDict
from sqlalchemy import (
    Column,
    String,
    Text,
    Boolean,
    Integer,
    DateTime,
    ForeignKey,
    JSON,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from app.db import Base


class Reminder(Base):
    __tablename__ = "reminders"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    title = Column(String(255), nullable=False)
    description = Column(Text)

    type = Column(String(50), nullable=False)
    # birthday | anniversary | task | bill | health | trip | custom

    start_at = Column(DateTime(timezone=True), nullable=False)
    end_at = Column(DateTime(timezone=True))

    is_all_day = Column(Boolean, default=False)
    timezone = Column(String(50), nullable=False)

    recurrence_rule = Column(Text)
    # RFC5545 RRULE

    notify_offsets = Column(JSON, default=list)
    # seconds before event

    priority = Column(Integer, default=0)
    status = Column(String(20), default="active")
    # active | completed | cancelled

    completed_at = Column(DateTime(timezone=True))

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
    )

    model_config = ConfigDict(from_attributes=True)
