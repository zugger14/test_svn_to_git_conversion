IF EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 11102)
BEGIN
UPDATE static_data_type
SET [type_name] = 'Debt Rating5',
    [description] = 'Debt Rating5',
    [internal] = 0, 
    [is_active] = 1
WHERE [type_id] = 11102
PRINT 'Updated static data type 11102 - Debt Rating5.'
END
ELSE
BEGIN
    PRINT 'Static data type 11102 - Debt Rating5 does not EXISTS.'
END          