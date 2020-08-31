UPDATE static_data_value
    SET code = 'Approved',
    [category_id] = ''
    WHERE [value_id] = 20710
PRINT 'Updated Static value 20710 - Approved.'

UPDATE static_data_value
    SET code = 'Unapproved',
    [category_id] = ''
    WHERE [value_id] = 20711
PRINT 'Updated Static value 20711 - Unapproved.'

UPDATE static_data_value
    SET code = 'Submitted for Approval',
    [category_id] = ''
    WHERE [value_id] = 20700
PRINT 'Updated Static value 20700 - Submitted for Approval.'

UPDATE static_data_value
    SET code = 'Submitted for Recall',
    [category_id] = ''
    WHERE [value_id] = 20706
PRINT 'Updated Static value 20706 - Submitted for Recall.'

UPDATE static_data_value
    SET code = 'Draft',
    [category_id] = ''
    WHERE [value_id] = 20701
PRINT 'Updated Static value 20701 - Draft.'

-- Delete Dispute And Initial
IF EXISTS(SELECT 'x' FROM static_data_value WHERE value_id = 20705)
BEGIN
	DELETE FROM static_data_value WHERE [value_id] = 20705
	PRINT 'Deleted Static value 20705 - Dispute.'
END

IF EXISTS(SELECT 'x' FROM static_data_value WHERE value_id = 20709)
BEGIN
	DELETE FROM static_data_value WHERE [value_id] = 20709
	PRINT 'Deleted Static value 20709 - Initial.'
END