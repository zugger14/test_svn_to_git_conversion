IF NOT EXISTS (SELECT 1 FROM alert_table_definition atd WHERE atd.physical_table_name = 'vwCounterPartyCreditLimitsAudit') 
BEGIN 
	INSERT INTO alert_table_definition (physical_table_name, logical_table_name)    
	SELECT 'vwCounterPartyCreditLimitsAudit'  , 'Counterparty Credit Limits Audit' 
END

 