IF COL_LENGTH('pivot_report_dashboard', 'category') IS NULL
BEGIN
    ALTER TABLE pivot_report_dashboard ADD category INT
END
GO

IF COL_LENGTH('pivot_report_dashboard', 'is_public') IS NULL
BEGIN
    ALTER TABLE pivot_report_dashboard ADD is_public BIT DEFAULT 0
END
GO

