IF EXISTS(Select 1 FROM static_Data_value sdv INNER JOIN static_data_type sdt ON sdt.type_id = sdv.type_id  where code = 'SAP Payable ID' and sdt.type_name = 'Counterparty External ID')
BEGIN
	UPDATE static_Data_value 
	SET code = 'SAP Payable ID (Creditor)',
	description = 'SAP Payable ID (Creditor)'
	where code = 'SAP Payable ID'
END 
ELSE 
	PRINT 'SAP Payable Id not found'

IF EXISTS(Select 1 FROM static_Data_value sdv INNER JOIN static_data_type sdt ON sdt.type_id = sdv.type_id  where code = 'SAP Receivable ID' and sdt.type_name = 'Counterparty External ID')
BEGIN
	UPDATE static_Data_value 
	SET code = 'SAP Receivable ID (Debtor)',
	description = 'SAP Receivable ID (Debtor)'
	where code = 'SAP Receivable ID' 
END 
ELSE 
PRINT 'SAP Receivable ID is not found'