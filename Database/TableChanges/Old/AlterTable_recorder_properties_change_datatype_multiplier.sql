IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'recorder_properties'
        AND  COLUMN_NAME = 'mult_factor')
        BEGIN
        	
        	ALTER TABLE recorder_properties
			ALTER COLUMN mult_factor FLOAT
		
        END
        