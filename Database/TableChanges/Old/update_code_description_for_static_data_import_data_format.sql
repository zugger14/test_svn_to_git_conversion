/*
* Update code for Import Data Format, so that they are undescore(_) separated.
* Update description for Import Data Format, so that they don't contain underscore.
*/

UPDATE static_data_value SET code = 'Source_System_File', [description] = 'Source System File' WHERE value_id = 5468
PRINT 'Updated static data value 5468 - Source_System_File.'

UPDATE static_data_value SET code = 'Source_Facility', [description] = 'Source/Facility' WHERE value_id = 5462
PRINT 'Updated static data value 5462 - Source_Facility.'

UPDATE static_data_value SET code = 'Hourly_Data', [description] = 'Hourly Data' WHERE value_id = 5465
PRINT 'Updated static data value 5465 - Hourly_Data.'

UPDATE static_data_value SET code = 'MV90_Data', [description] = 'MV90 Data' WHERE value_id = 5466
PRINT 'Updated static data value 5466 - MV90_Data.'
