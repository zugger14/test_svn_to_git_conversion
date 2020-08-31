IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'meter_id' AND COLUMN_NAME = 'multiple_location')
BEGIN
	ALTER TABLE meter_id ADD multiple_location CHAR(1)
END

Go

UPDATE mi
SET 
	mi.multiple_location ='y'
from
	meter_id mi
	INNER JOIN group_meter_mapping gmm ON mi.meter_id = gmm.meter_id

GO

