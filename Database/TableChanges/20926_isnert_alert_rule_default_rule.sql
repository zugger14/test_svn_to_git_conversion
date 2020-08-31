SET IDENTITY_INSERT alert_sql ON
IF NOT EXISTS (SELECT 1 FROM alert_sql WHERE alert_sql_id = -1)
BEGIN
	INSERT INTO alert_sql (alert_sql_id, workflow_only, notification_type, alert_sql_name, is_active, alert_type, rule_category, system_rule,alert_category)
	SELECT -1, 'n', 751, 'Default Rule For Message', 'y', 'r', 26000, 'y', 's'
END
ELSE 
BEGIN
	UPDATE alert_sql
	SET alert_sql_name = 'Default Rule For Message'
	WHERE alert_sql_id = -1
END
SET IDENTITY_INSERT alert_sql OFF