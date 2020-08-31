IF COL_LENGTH('location_loss_factor', 'meter_from') IS NULL
BEGIN
    ALTER TABLE location_loss_factor ADD meter_from INT NULL 
END
GO

IF COL_LENGTH('location_loss_factor', 'meter_to') IS NULL
BEGIN
    ALTER TABLE location_loss_factor ADD meter_to INT NULL 
END
GO

IF COL_LENGTH('location_loss_factor', 'rate_loss_flag') IS NULL
BEGIN
    ALTER TABLE location_loss_factor ADD rate_loss_flag CHAR(1) NULL 
END
GO

IF COL_LENGTH('location_loss_factor', 'rate_schedule') IS NULL
BEGIN
    ALTER TABLE location_loss_factor ADD rate_schedule INT NULL 
END
GO

IF EXISTS (
       SELECT 'x'
       FROM   sys.[columns] c INNER JOIN sys.tables t ON  t.[object_id] = c.[object_id]
       WHERE  t.[name] = 'location_loss_factor' AND c.[name] = 'loss_factor'
)
ALTER TABLE location_loss_factor ALTER COLUMN loss_factor FLOAT NULL 

