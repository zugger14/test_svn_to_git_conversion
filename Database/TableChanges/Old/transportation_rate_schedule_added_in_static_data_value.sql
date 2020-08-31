-- Author: Tara Nath Subedi
-- Dated: 2010 April 16
-- Issue ID: 2227
-- Purpose: Addition of "Transportation Rate Schedule" in "Maintain Definition"

IF NOT EXISTS(SELECT 'X' FROM static_data_value WHERE value_id=4033)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value(value_id,type_id,code,description) VALUES(4033,4000,'transportation_rate_schedule','Transportation Rate Schedule')
	SET IDENTITY_INSERT static_data_value OFF
	print '4033: transportation_rate_schedule added in static_data_value table.'
END