IF COL_LENGTH('state_rec_requirement_data', 'from_month') IS NOT NULL
BEGIN   
    ALTER TABLE state_rec_requirement_data 
		DROP COLUMN from_month  
    PRINT 'Column from_month dropped'
END
GO

IF COL_LENGTH('state_rec_requirement_data', 'to_month') IS NOT NULL
BEGIN  
    ALTER TABLE state_rec_requirement_data 
		DROP COLUMN to_month  
    PRINT 'Column to_month dropped'
END
GO

IF COL_LENGTH('rec_gen_eligibility', 'from_month') IS NOT NULL
BEGIN  
    ALTER TABLE rec_gen_eligibility
	DROP COLUMN from_month  
  PRINT 'Column from_month dropped'
END
GO

IF COL_LENGTH('rec_gen_eligibility', 'to_month') IS NOT NULL
BEGIN  
    ALTER TABLE rec_gen_eligibility
	DROP COLUMN to_month  
  PRINT 'Column to_month dropped'
END
GO
 
 