"""add notification processing fields

Revision ID: c631f9fae833
Revises: acc9ed12fedd
Create Date: 2026-01-05 22:38:06.537337

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'c631f9fae833'
down_revision: Union[str, Sequence[str], None] = 'acc9ed12fedd'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade():
    op.add_column(
        "reminder_notifications",
        sa.Column("processing_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.add_column(
        "reminder_notifications",
        sa.Column(
            "delivery_status",
            sa.String(),
            nullable=False,
            server_default="pending",
        ),
    )
    op.add_column(
        "reminder_notifications",
        sa.Column(
            "attempt_count",
            sa.Integer(),
            nullable=False,
            server_default="0",
        ),
    )
    op.add_column(
        "reminder_notifications",
        sa.Column("error_message", sa.String(), nullable=True),
    )

    op.create_index(
        "ix_reminder_notifications_processing_at",
        "reminder_notifications",
        ["processing_at"],
    )
    op.create_index(
        "ix_reminder_notifications_delivery_status",
        "reminder_notifications",
        ["delivery_status"],
    )


def downgrade():
    op.drop_index("ix_reminder_notifications_delivery_status")
    op.drop_index("ix_reminder_notifications_processing_at")

    op.drop_column("reminder_notifications", "error_message")
    op.drop_column("reminder_notifications", "attempt_count")
    op.drop_column("reminder_notifications", "delivery_status")
    op.drop_column("reminder_notifications", "processing_at")
