UPDATE alert_sql
SET notification_type = CASE WHEN notification_type = '752' THEN '750,751' ELSE notification_type END

UPDATE workflow_event_message
SET notification_type = CASE WHEN notification_type = '752' THEN '750,751' ELSE notification_type END