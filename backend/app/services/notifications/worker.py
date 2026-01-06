import asyncio
from app.db import SessionLocal
from app.services.notifications.dispatcher import claim_due_notifications
from app.services.notifications.sender import dispatch_notification

CHECK_INTERVAL_SECONDS = 30  # seconds

async def notification_worker():
    while True:
        db = SessionLocal()
        try:
            notifications = claim_due_notifications(db)

            for notification in notifications:
                dispatch_notification(db, notification)

            db.commit()

        except Exception as e:
            print("[WORKER ERROR]", e)
            db.rollback()
        finally:
            db.close()

        await asyncio.sleep(CHECK_INTERVAL_SECONDS)  # tick interval
