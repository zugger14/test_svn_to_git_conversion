IF COL_LENGTH(N'pivot_report_view', N'standard_exec_sql') IS NULL
BEGIN
    ALTER TABLE pivot_report_view ADD standard_exec_sql VARCHAR(MAX)
END
ELSE
BEGIN
    PRINT 'standard_exec_sql Already Exists.'
END