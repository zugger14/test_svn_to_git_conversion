IF COL_LENGTH('ixp_ssis_parameters','grid_name') is null
BEGIN
 ALTER TABLE ixp_ssis_parameters ADD grid_name VARCHAR(100) 
END
ELSE 
 PRINT 'Column already exists.'