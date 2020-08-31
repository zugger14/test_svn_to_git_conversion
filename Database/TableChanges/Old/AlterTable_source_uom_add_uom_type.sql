IF NOT EXISTS(SELECT * FROM sys.columns 
            WHERE Name = N'uom_type' and Object_ID = Object_ID(N'source_uom'))
	BEGIN
		ALTER TABLE source_uom
		ADD  uom_type varchar(1)
	END
ELSE
PRINT 'Column already exists'


