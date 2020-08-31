IF COL_LENGTH('variable_charge','payment_calendar') IS NULL
BEGIN
	ALTER TABLE variable_charge 
	ADD payment_calendar INT
	PRINT 'Added column ''payment_calendar'''
END
ELSE
PRINT 'column ''payment_calendar'' already exists'

IF COL_LENGTH('variable_charge','payment_date') IS NULL
BEGIN
	ALTER TABLE variable_charge 
	ADD payment_date DATE
	PRINT 'Added column ''payment_date'''
END
ELSE
PRINT 'column ''payment_date'' already exists'

IF COL_LENGTH('variable_charge','settlement_calendar') IS NULL
BEGIN
	ALTER TABLE variable_charge 
	ADD settlement_calendar INT
	PRINT 'Added column ''settlement_calendar'''
END
ELSE
PRINT 'column ''settlement_calendar'' already exists'

IF COL_LENGTH('variable_charge','settlement_date') IS NULL
BEGIN
	ALTER TABLE variable_charge 
	ADD settlement_date DATE
	PRINT 'Added column ''settlement_date'''
END
ELSE
PRINT 'column ''settlement_date'' already exists'