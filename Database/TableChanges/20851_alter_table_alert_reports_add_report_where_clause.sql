IF COL_LENGTH('alert_reports','report_where_clause') IS NULL
	ALTER TABLE alert_reports ADD report_where_clause VARCHAR(MAX)