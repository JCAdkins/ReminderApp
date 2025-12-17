from sqlalchemy import Column, Date, Integer, String, DateTime
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=True)  # nullable if using OAuth only
    first_name = Column(String, nullable=False)
    last_name = Column(String, nullable=False)
    dob = Column(Date, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    google_id = Column(String, unique=True, nullable=True)

    oauth_tokens = relationship(
        "OAuthTokenDb",
        back_populates="user",
        cascade="all, delete",
        lazy="selectin"
    )

    model_config = {
        "from_attributes": True  # <-- allows conversion from ORM objects
    }
