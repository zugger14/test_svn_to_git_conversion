IF COL_LENGTH('pivot_report_view', 'standard_report_id') IS NULL
BEGIN
    ALTER TABLE pivot_report_view ADD standard_report_id INT
END
GO

IF COL_LENGTH('pivot_report_view', 'xaxis_label') IS NULL
BEGIN
    ALTER TABLE pivot_report_view ADD xaxis_label VARCHAR(1000)
END
GO

IF COL_LENGTH('pivot_report_view', 'yaxis_label') IS NULL
BEGIN
    ALTER TABLE pivot_report_view ADD yaxis_label VARCHAR(1000)
END
GO

IF COL_LENGTH('pivot_report_view', 'user_report_name') IS NULL
BEGIN
    ALTER TABLE pivot_report_view ADD user_report_name VARCHAR(1000)
END
GO

IF COL_LENGTH('pivot_report_view', 'report_group_id') IS NULL
BEGIN
    ALTER TABLE pivot_report_view ADD report_group_id INT
END
GO

UPDATE pivot_report_view SET report_group_id = -1
WHERE report_group_id IS NULL