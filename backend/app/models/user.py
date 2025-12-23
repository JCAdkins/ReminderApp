import uuid
from pydantic import ConfigDict
from sqlalchemy import Column, Date, String, DateTime
from sqlalchemy.sql import func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.db import Base

class User(Base):
    __tablename__ = "users"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True,
    )
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=True)  # nullable if using OAuth only
    first_name = Column(String, nullable=False)
    last_name = Column(String, nullable=False)
    dob = Column(Date, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    oauth_tokens = relationship(
        "OAuthTokenDb",
        back_populates="user",
        cascade="all, delete",
        lazy="selectin"
    )

    oauth_providers = relationship(
        "UserOAuthProvider",
        back_populates="user",
        cascade="all, delete",
        lazy="selectin"
    )

    model_config = ConfigDict(from_attributes=True)
