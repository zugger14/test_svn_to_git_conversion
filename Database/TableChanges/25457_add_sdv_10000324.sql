SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000324)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (20500, 10000324, 'GL Posted (Accrual)', 'GL Posted (Accrual)', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000324 - GL Posted (Accrual).'
END
ELSE
BEGIN
    PRINT 'Static data value 10000324 - GL Posted (Accrual) already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF