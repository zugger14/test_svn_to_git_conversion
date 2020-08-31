IF COL_LENGTH('user_defined_fields_template', 'include_in_credit_exposure') IS NULL
BEGIN
    ALTER TABLE user_defined_fields_template ADD include_in_credit_exposure VARCHAR(1)
	PRINT 'include_in_credit_exposure - Column added'
END
ELSE PRINT 'include_in_credit_exposure - Column already exists'
GO