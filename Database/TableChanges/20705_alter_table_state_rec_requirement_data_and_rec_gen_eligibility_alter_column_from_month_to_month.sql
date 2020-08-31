IF COL_LENGTH('state_rec_requirement_data', 'from_month') IS NOT NULL
BEGIN 
    ALTER TABLE state_rec_requirement_data 
		ALTER COLUMN from_month DATETIME NULL
    PRINT 'Column from_month updated'
END
GO

IF COL_LENGTH('state_rec_requirement_data', 'to_month') IS NOT NULL
BEGIN 
    ALTER TABLE state_rec_requirement_data 
		ALTER COLUMN to_month DATETIME NULL
    PRINT 'Column to_month updated'
END
GO

IF COL_LENGTH('rec_gen_eligibility', 'from_month') IS NOT NULL
BEGIN 
    ALTER TABLE rec_gen_eligibility 
		ALTER COLUMN from_month DATETIME NULL
    PRINT 'Column from_month updated'
END
GO

IF COL_LENGTH('rec_gen_eligibility', 'to_month') IS NOT NULL
BEGIN 
    ALTER TABLE rec_gen_eligibility 
		ALTER COLUMN to_month DATETIME NULL
    PRINT 'Column to_month updated'
END
GO