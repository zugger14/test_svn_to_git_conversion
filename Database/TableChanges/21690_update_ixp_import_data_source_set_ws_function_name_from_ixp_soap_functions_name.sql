UPDATE ids
    SET ids.ws_function_name = isf.ixp_soap_functions_name
   
FROM
    ixp_import_data_source ids
    INNER JOIN ixp_soap_functions isf 
		ON ids.soap_function_id = isf.ixp_soap_functions_id