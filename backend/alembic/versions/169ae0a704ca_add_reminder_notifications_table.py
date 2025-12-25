"""add reminder_notifications table

Revision ID: 169ae0a704ca
Revises: df2fb4a42c83
Create Date: 2025-12-25 15:14:43.346580

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '169ae0a704ca'
down_revision: Union[str, Sequence[str], None] = 'df2fb4a42c83'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    pass


def downgrade() -> None:
    """Downgrade schema."""
    pass
