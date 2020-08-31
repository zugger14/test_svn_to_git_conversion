--Author: Tara Nath Subedi
--Purpose: to add 'ispublic' column.
--User ownership should be there in user_login_id, and the user decide whether it should be public or not in 'ispublic' column.
IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='dashboard_report_template_header' AND COLUMN_NAME='ispublic')
BEGIN
	ALTER TABLE dashboard_report_template_header ADD ispublic CHAR(1) DEFAULT 'n'
	PRINT '''ispublic'' column added in ''dashboard_report_template_header'' table.'
END
