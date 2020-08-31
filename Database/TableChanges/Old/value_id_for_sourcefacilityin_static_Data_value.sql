--add Source/Facility as Data format dropdown in data import.
--the value id is fixed here in 5462, to have uniformity in all database.. and being used as hardcode in php.
IF  EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'static_data_value' AND COLUMN_NAME = 'type_id')
	BEGIN
		
		IF NOT EXISTS (SELECT 'X' from static_data_value where type_id=5450 and code='Source/Facility')
			BEGIN	
				SET IDENTITY_INSERT static_data_value ON		
				insert into static_data_value(value_id,type_id,code,description) values(5462,5450,'Source/Facility','Source/Facility')
				SET IDENTITY_INSERT static_data_value OFF
				print 'Source/Facility added in static_data_value table with value_id 5462.'
			END
		ELSE
			begin
			delete from static_data_value where type_id=5450 and code='Source/Facility';
			SET IDENTITY_INSERT static_data_value ON
			insert into static_data_value(value_id,type_id,code,description) values(5462,5450,'Source/Facility','Source/Facility')
			SET IDENTITY_INSERT static_data_value OFF

			print 'Source/Facility update to value id: 5462.'
			end
			

	END