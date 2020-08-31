IF COL_LENGTH('location_loss_factor','from_zone') IS NULL
BEGIN
	ALTER TABLE location_loss_factor ADD from_zone INT	
END
ELSE 
	PRINT 'Column already exists.'



IF COL_LENGTH('location_loss_factor','to_zone') IS NULL
BEGIN
	ALTER TABLE location_loss_factor ADD to_zone INT	
END
ELSE 
	PRINT 'Column already exists.'


IF COL_LENGTH('location_loss_factor','rate_schedule_type') IS NULL
BEGIN
	ALTER TABLE location_loss_factor ADD rate_schedule_type INT	
END
ELSE 
	PRINT 'Column already exists.'


IF EXISTS(SELECT 1 FROM sysconstraints WHERE id = OBJECT_ID('location_loss_factor') AND COL_NAME(id, colid) = 'from_location_id')
BEGIN
	ALTER TABLE location_loss_factor ALTER COLUMN from_location_id INT NULL	
END
ELSE 
	PRINT 'Column not exists.'


IF EXISTS(SELECT 1 FROM sysconstraints WHERE id = OBJECT_ID('location_loss_factor') AND COL_NAME(id, colid) = 'to_location_id')
BEGIN
	ALTER TABLE location_loss_factor ALTER COLUMN to_location_id INT NULL	
END
ELSE 
	PRINT 'Column not exists.'