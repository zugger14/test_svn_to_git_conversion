IF EXISTS(SELECT * FROM sys.columns 
            WHERE Name = N'meter_description' AND Object_ID = Object_ID(N'source_minor_location_meter'))
            BEGIN
            	--PRINT 'This colummn is already exist in this table.'
            	ALTER TABLE source_minor_location_meter DROP COLUMN meter_description
            	PRINT 'Deleted meter_description column successfully'
            END
ELSE 
BEGIN
	PRINT 'This colummn does not exist in this table.'
	  -- ALTER TABLE source_minor_location_meter ADD meter_description VARCHAR(1000)
	END-------------------------------------------------------------------------------