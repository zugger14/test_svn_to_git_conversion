IF COL_LENGTH('state_rec_requirement_detail', 'tier_type') IS NOT NULL
BEGIN 
    ALTER TABLE state_rec_requirement_detail 
		ALTER COLUMN tier_type INT NULL
    PRINT 'Column tier_type updated'
END
GO

