IF COL_LENGTH('meter_id', 'allocation_type') IS NULL
BEGIN
	ALTER TABLE meter_id ADD allocation_type INT
	PRINT 'Column meter_id.allocation_type added.'
END
ELSE
BEGIN
	PRINT 'Column meter_id.allocation_type already exists.'
END
GO
