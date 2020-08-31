IF EXISTS(SELECT * FROM sys.columns WHERE [name] = N'type' AND OBJECT_ID = OBJECT_ID(N'source_minor_location_nomination_group'))
BEGIN
    PRINT 'Column Already Exists'
END
ELSE 
BEGIN
	ALTER TABLE source_minor_location_nomination_group ADD [type] INT  
END