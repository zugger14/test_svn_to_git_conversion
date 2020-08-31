--add Source/Facility as Data format dropdown in data import.
IF  EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'static_data_value' AND COLUMN_NAME = 'type_id')
	BEGIN
		
		IF NOT EXISTS (SELECT 'X' from static_data_value where type_id=5450 and code='Source/Facility')
			BEGIN			
				insert into static_data_value(type_id,code,description) values(5450,'Source/Facility','Source/Facility')
				print 'Source/Facility added in static_data_value table.'
			END
		ELSE
			print 'You already have Source/Facility, No need to insert.'

	END