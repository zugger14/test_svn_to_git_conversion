UPDATE static_data_value
    SET code = 'Submitted for Approval',
    [category_id] = ''
    WHERE [value_id] = 1904
PRINT 'Updated Static value 1904 - Submitted for Approval.'

UPDATE static_data_value
    SET code = 'Draft',
    [category_id] = ''
    WHERE [value_id] = 1903
PRINT 'Updated Static value 1903 - Draft.'

DELETE FROM static_data_value WHERE [type_id] = 1900 AND value_id IN (1905,1902)

UPDATE sdv set sdv.description = sdv.code from static_data_value AS sdv WHERE sdv.[type_id] = 1900

UPDATE sdv set sdv.description = sdv.code from static_data_value AS sdv WHERE sdv.[type_id] = 20700

