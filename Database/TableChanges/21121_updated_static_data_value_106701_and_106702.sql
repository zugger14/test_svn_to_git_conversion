-- Here the value of description is crucial as it is used to get value_id in spa_view_report

UPDATE static_data_value
    SET code = 'Document Generation',
	[description] = 'document_generation',
    [category_id] = ''
    WHERE [value_id] = 106701
PRINT 'Updated Static value 106701 - Document Generation.'

UPDATE static_data_value
    SET code = 'Calculation',
	[description] = 'calculation_engine',
    [category_id] = ''
    WHERE [value_id] = 106702
PRINT 'Updated Static value 106702 - Calculation.'