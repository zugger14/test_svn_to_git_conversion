Update 
user_defined_fields_template 
SET
sql_string = 'SELECT ''i'' as ID ,''Invoice'' as NAME
			UNION SELECT ''r'' as ID,''Remittance'' as NAME 
			UNION SELECT ''b'' as ID,''Both'' as NAME'
where field_label = 'document type'
