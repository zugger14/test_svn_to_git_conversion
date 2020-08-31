IF OBJECT_ID(N'regression_rule', N'U') IS NOT NULL 
	AND COL_LENGTH('regression_rule', 'system_defined') IS NULL
BEGIN
	ALTER TABLE
	/**
		Columns
		system_defined: Specify whether the rule is system defined (i.e. Must be protected or not).
	*/
	regression_rule ADD system_defined CHAR(1) DEFAULT 'n'

	PRINT('system_defined Added.')
END
ELSE
	PRINT('system_defined Exists.')

GO