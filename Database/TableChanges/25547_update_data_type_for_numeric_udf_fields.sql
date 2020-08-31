UPDATE udft
	SET udft.data_type = 'numeric(38,20)'
FROM (
SELECT 'Value' [Field_label],'h' [udf_type]
UNION SELECT 'Actual Price Multiplier','d'
UNION SELECT 'Actual Fixed Price','d'
UNION SELECT 'Prorated Volume','d'
UNION SELECT 'Injection Amount','d'
UNION SELECT 'Withdrawal Amount','d'
UNION SELECT 'Injection Volume','d'
UNION SELECT 'Withdrawal Volume','d'
UNION SELECT 'Variable Value','h'
UNION SELECT 'Conditional Value','h'
UNION SELECT 'Strike Price','h'
UNION SELECT 'Nominated Volume','d'
UNION SELECT 'Cashout Volume','d'
UNION SELECT 'Payback Volume','d'
UNION SELECT 'Closeout Volume','d'
UNION SELECT 'Daily Imbalance Volume','d'
UNION SELECT 'Actual Volume','d'
UNION SELECT 'Price Adder','h'
UNION SELECT 'Brent Base Value','h'
UNION SELECT 'Base Price EUR/MWh','d'
) tbl
INNER JOIN user_defined_fields_template udft
	ON udft.[Field_label] = tbl.[Field_label]
	AND udft.udf_type = tbl.udf_type