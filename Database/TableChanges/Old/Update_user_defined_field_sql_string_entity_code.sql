UPDATE user_defined_fields_template SET sql_string = '
SELECT sc.source_counterparty_id
				,sc.counterparty_name

			FROM counterparty_epa_account cea
			INNER JOIN static_data_value sdv_cea ON sdv_cea.value_id = cea.external_type_id
			INNER JOIN static_data_type sdt_cea ON sdt_cea.type_id = sdv_cea.type_id
				AND sdt_cea.type_name = ''Counterparty External ID''
			INNER JOIN source_counterparty sc ON 
			 cea.counterparty_id =  sc.source_counterparty_id
			 WHERE 
				 cea.external_type_id = sdv_cea.value_id
				AND sdv_cea.code = ''Entity Code'''
				WHERE field_label = 'Entity'