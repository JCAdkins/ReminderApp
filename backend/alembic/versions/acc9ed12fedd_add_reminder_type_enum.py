"""add reminder type enum

Revision ID: acc9ed12fedd
Revises: c1afda3aef10
Create Date: 2025-12-28 01:13:10.128927
"""

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'acc9ed12fedd'
down_revision = 'c1afda3aef10'
branch_labels = None
depends_on = None

# define the enum type
reminder_type_enum = sa.Enum(
    'birthday',
    'anniversary',
    'task',
    'bill',
    'health',
    'trip',
    'custom',
    name='reminder_type',
)


def upgrade() -> None:
    # 1. Create enum type in Postgres
    reminder_type_enum.create(op.get_bind(), checkfirst=True)

    # 2. Alter the 'type' column to use the enum
    op.execute("""
        ALTER TABLE reminders
        ALTER COLUMN type TYPE reminder_type
        USING type::reminder_type
    """)


def downgrade() -> None:
    # 1. Revert the column back to VARCHAR
    op.execute("""
        ALTER TABLE reminders
        ALTER COLUMN type TYPE VARCHAR(50)
        USING type::text
    """)

    # 2. Drop the enum type
    reminder_type_enum.drop(op.get_bind(), checkfirst=True)
