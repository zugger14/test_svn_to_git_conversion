-- Insert Rule Table Start 'counterparty_credit_info'
IF NOT EXISTS (SELECT 1 FROM alert_table_definition atd WHERE atd.physical_table_name = 'counterparty_credit_info') 
BEGIN 
	INSERT INTO alert_table_definition (physical_table_name, logical_table_name)    
	SELECT 'counterparty_credit_info'  , 'Counterparty Credit Info' 
END
-- Insert Rule Table End

-- Insert Rule Table Columns Start
DECLARE @alert_table_definition_id INT

SELECT @alert_table_definition_id = alert_table_definition_id
FROM alert_table_definition
WHERE physical_table_name = 'counterparty_credit_info'

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @alert_table_definition_id AND column_name = 'Counterparty_id')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @alert_table_definition_id, 'Counterparty_id', 'y', 'Counterparty ID'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @alert_table_definition_id AND column_name = 'account_status')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @alert_table_definition_id, 'account_status', 'n', 'Account Status'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @alert_table_definition_id AND column_name = 'counterparty_credit_info_id')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @alert_table_definition_id, 'counterparty_credit_info_id', 'n', 'Counterparty Credit Info ID'
END
-- Insert Rule Table Columns End