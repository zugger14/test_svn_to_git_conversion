/**
* sangam ligal
* 7/9/2012
* renaming the code and description of static_data_values(value_id: 1562, 1563) of type id;1560
**/

UPDATE static_data_value
SET [code] = 'Arithmetic Rate of Return',
	[description] = 'Arithmetic Rate of Return'
WHERE value_id = 1562

PRINT 'Updated Static data type 1562 - Arithmetic Rate of Return.'

UPDATE static_data_value
SET [code] = 'Geometric Rate of Return',
	[description] = 'Geometric Rate of Return'
WHERE value_id = 1563
PRINT 'Updated Static data type 1563 - Geometric Rate of Return.'
