IF EXISTS(SELECT 1 FROM formula_editor_parameter WHERE function_name = 'lagCurve')
BEGIN
UPDATE fep 
SET fep.is_required =  0
FROM formula_editor_parameter fep
WHERE fep.function_name = 'lagCurve'
	AND fep.field_label IN
		(
		'Price Adder'
		,'Volume Multiplier'
		,'Expiration Type'
		,'Expiration Value'
		)
END
ELSE
BEGIN
    PRINT 'Formula Name - lagCurve doesnot EXISTS.'
END