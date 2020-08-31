IF COL_LENGTH('pivot_report_dashboard', 'mins') IS NULL
BEGIN
    ALTER TABLE pivot_report_dashboard ADD mins INT
END
GO

IF COL_LENGTH('pivot_report_dashboard', 'secs') IS NULL
BEGIN
    ALTER TABLE pivot_report_dashboard ADD secs INT
END
GO