from pydantic import ConfigDict
from sqlalchemy import Column, String, ForeignKey, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.db import Base
import uuid

class UserOAuthProvider(Base):
    __tablename__ = "user_oauth_providers"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True
    )

    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False
    )

    provider = Column(String, nullable=False)
    provider_user_id = Column(String, nullable=False)

    user = relationship("User", back_populates="oauth_providers")

    __table_args__ = (
        UniqueConstraint('provider', 'provider_user_id', name='uq_provider_user'),
    )

    model_config = ConfigDict(from_attributes=True)
