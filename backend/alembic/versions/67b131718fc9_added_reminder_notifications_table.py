"""added reminder_notifications table

Revision ID: 67b131718fc9
Revises: 169ae0a704ca
Create Date: 2025-12-25 15:16:09.437689

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision: str = '67b131718fc9'
down_revision: Union[str, Sequence[str], None] = '169ae0a704ca'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade():
    """Upgrade schema."""
    op.create_table(
        "reminder_notifications",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            nullable=False,
        ),
        sa.Column(
            "reminder_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("reminders.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column(
            "fire_at",
            sa.DateTime(timezone=True),
            nullable=False,
        ),
        sa.Column(
            "offset_seconds",
            sa.Integer(),
            nullable=False,
            server_default="0",
        ),
        sa.Column(
            "sent_at",
            sa.DateTime(timezone=True),
            nullable=True,
        ),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            nullable=False,
        ),
    )

    # Indexes
    op.create_index(
        "ix_reminder_notifications_reminder_id",
        "reminder_notifications",
        ["reminder_id"],
    )

    op.create_index(
        "ix_reminder_notifications_fire_at",
        "reminder_notifications",
        ["fire_at"],
    )

    op.create_index(
        "ix_reminder_notifications_sent_at",
        "reminder_notifications",
        ["sent_at"],
    )

    # Composite index for scheduler queries
    op.create_index(
        "ix_reminder_notifications_due",
        "reminder_notifications",
        ["fire_at", "sent_at"],
    )


def downgrade():
    """Downgrade schema."""
    op.drop_index("ix_reminder_notifications_due", table_name="reminder_notifications")
    op.drop_index("ix_reminder_notifications_sent_at", table_name="reminder_notifications")
    op.drop_index("ix_reminder_notifications_fire_at", table_name="reminder_notifications")
    op.drop_index("ix_reminder_notifications_reminder_id", table_name="reminder_notifications")

    op.drop_table("reminder_notifications")
