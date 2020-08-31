
IF NOT EXISTS(SELECT 'X' FROM alert_table_definition WHERE physical_table_name='Calc_invoice_Volume_variance_audit_view')
	INSERT INTO alert_table_definition(logical_table_name,physical_table_name)
	SELECT 'Settlement Invoice Audit','Calc_invoice_Volume_variance_audit_view'


DECLARE @alert_table_id INT
SELECT @alert_table_id =  alert_table_definition_id FROM alert_table_definition WHERE physical_table_name='Calc_invoice_Volume_variance_audit_view'

IF NOT EXISTS(SELECT 'X' FROM alert_columns_definition WHERE alert_table_id=@alert_table_id)
	INSERT INTO alert_columns_definition(alert_table_id,column_name,is_primary)
	SELECT @alert_table_id,column_name,is_primary 
	FROM alert_columns_definition  acd
		 INNER JOIN alert_table_definition atd ON acd.alert_table_id = atd.alert_table_definition_id
	where physical_table_name = 'Calc_invoice_Volume_variance'

--select * from alert_table_definition



