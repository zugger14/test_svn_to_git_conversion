IF COL_LENGTH('deal_actual_quality', 'company') IS NULL
BEGIN
    ALTER TABLE deal_actual_quality ADD company INT
END
GO


IF COL_LENGTH('deal_actual_quality', 'is_average') IS NULL
BEGIN
    ALTER TABLE deal_actual_quality ADD is_average CHAR(1)
END
GO

IF COL_LENGTH('deal_actual_quality', 'value') IS NOT NULL
BEGIN
	ALTER TABLE deal_actual_quality
	ALTER COLUMN value VARCHAR(50)
End