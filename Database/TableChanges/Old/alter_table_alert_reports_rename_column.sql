IF COL_LENGTH('alert_reports', 'alert_sql_id') IS NOT NULL
BEGIN
    EXEC sp_RENAME 'alert_reports.alert_sql_id', 'event_message_id', 'COLUMN'
END
GO


DECLARE @fk_name VARCHAR(500) = null,@sql VARCHAR(max)
SELECT @fk_name = name
       FROM   sys.foreign_keys
       WHERE  parent_object_id = OBJECT_ID(N'dbo.alert_report_params')
              AND referenced_object_id = OBJECT_ID(N'alert_sql')
IF @fk_name is not null
BEGIN
	SET @sql = '
	ALTER TABLE alert_report_params
	DROP CONSTRAINT ' + @fk_name
	EXEC(@sql)
END
GO


IF COL_LENGTH('alert_report_params', 'alert_sql_id') IS NOT NULL
BEGIN
    EXEC sp_RENAME 'alert_report_params.alert_sql_id', 'event_message_id', 'COLUMN'
END
GO