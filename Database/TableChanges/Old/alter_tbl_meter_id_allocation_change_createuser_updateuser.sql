IF COL_LENGTH('meter_id_allocation', 'create_user') IS NOT NULL
BEGIN
    ALTER TABLE meter_id_allocation ALTER COLUMN create_user VARCHAR(50)
END
GO

IF COL_LENGTH('meter_id_allocation', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE meter_id_allocation ALTER COLUMN update_user VARCHAR(50)
END
GO