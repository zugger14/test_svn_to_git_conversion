DECLARE @value_id INT

SELECT @value_id=value_id from static_data_value where code='Weight' and type_id=15600

UPDATE static_data_value SET code = 'Formula Details', [description] = 'Formula Details' WHERE [value_id] = @value_id
PRINT 'Updated Static value '+CAST(@value_id AS VARCHAR)+' - Weight.'

GO

IF(SELECT 1 FROM static_data_value sdv WHERE sdv.description = 'Add Ons') IS NOT NULL
BEGIN
	PRINT 'Deleted static data - Add Ons'
	DELETE FROM static_data_value WHERE description = 'Add Ons'
END

GO


