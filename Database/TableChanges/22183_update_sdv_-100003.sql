UPDATE static_data_value
    SET code = 'ERP NG Invoice',
		description = 'ERP NG Invoice'
    WHERE [value_id] = -100003
PRINT 'Updated Static value -100003 - ERP Invoice Type.' 
