IF EXISTS (SELECT 1 FROM static_data_value sdv WHERE sdv.value_id=-5506)
BEGIN
	DELETE FROM static_data_value WHERE value_id IN (-5506)
	PRINT 'Delete static_data_value -5506, Standard_Yearly_Volume.'	
END
ELSE
	PRINT 'Data does not exist.'
	
	
IF EXISTS (SELECT 1 FROM static_data_value sdv WHERE sdv.value_id = -5507)
BEGIN
	DELETE FROM static_data_value WHERE value_id IN (-5507)
	PRINT 'Delete static_data_value -5507, Standardy_Yearly_Volume_Onpeak.'		
END
ELSE
	PRINT 'Data does not exist.'
	
	
IF EXISTS (SELECT 1 FROM static_data_value sdv WHERE sdv.value_id = -5508)
BEGIN
	DELETE FROM static_data_value WHERE value_id IN (-5508)	
	PRINT 'Delete static_data_value -5508, Standardy_Yearly_Volume_Offpeak.'	
END
ELSE
	PRINT 'Data does not exist.'