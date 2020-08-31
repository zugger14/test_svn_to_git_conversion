IF COL_LENGTH('pivot_report_view', 'pin_it') IS NULL
BEGIN
    ALTER TABLE pivot_report_view ADD pin_it BIT DEFAULT 0
END
GO