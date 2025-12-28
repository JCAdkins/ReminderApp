"""Add reminder notification idempotency constraint

Revision ID: c1afda3aef10
Revises: 67b131718fc9
Create Date: 2025-12-27

"""
from alembic import op

# revision identifiers, used by Alembic.
revision = "c1afda3aef10"
down_revision = "67b131718fc9"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_unique_constraint(
        "uq_reminder_notification_idempotency",
        "reminder_notifications",
        ["reminder_id", "fire_at", "offset_seconds"],
    )


def downgrade() -> None:
    op.drop_constraint(
        "uq_reminder_notification_idempotency",
        "reminder_notifications",
        type_="unique",
    )
