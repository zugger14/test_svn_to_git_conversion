--Update application_functions
UPDATE application_functions
	SET function_desc = 'Match RECs'
		WHERE [function_id] = 20007900
PRINT 'Updated Application Function.'

--Update setup_menu
UPDATE setup_menu
	SET display_name = 'Match RECs'
		WHERE [function_id] = 20007900
		AND [product_category]= 14000000
PRINT 'Updated Setup Menu.'
                    