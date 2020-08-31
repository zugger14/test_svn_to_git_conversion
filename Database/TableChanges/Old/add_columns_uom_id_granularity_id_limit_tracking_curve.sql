IF COL_LENGTH('limit_tracking_curve', 'uom_id') IS NULL
BEGIN
    ALTER TABLE limit_tracking_curve ADD uom_id INT
END
GO

IF COL_LENGTH('limit_tracking_curve', 'granularity_id') IS NULL
BEGIN
    ALTER TABLE limit_tracking_curve ADD granularity_id INT
END
GO