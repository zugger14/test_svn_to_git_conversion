DELETE a FROM adiha_default_codes_values a
CROSS APPLY(SELECT var_value, default_code_id, seq_no
			FROM adiha_default_codes_values 
			GROUP BY default_code_id, seq_no, var_value
			HAVING COUNT(default_code_id) > 1) b
WHERE a.var_value = b.var_value 
	AND a.default_code_id = b.default_code_id 
	AND a.seq_no = b.seq_no

GO