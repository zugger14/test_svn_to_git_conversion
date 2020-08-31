PRINT 'tables insert starts'

IF NOT EXISTS (SELECT 1 FROM alert_table_definition atd WHERE atd.physical_table_name = 'contract_group') BEGIN INSERT INTO alert_table_definition (physical_table_name, logical_table_name)    SELECT 'contract_group'  , 'Contract' END
IF NOT EXISTS (SELECT 1 FROM alert_table_definition atd WHERE atd.physical_table_name = 'contract_group_audit_view') BEGIN INSERT INTO alert_table_definition (physical_table_name, logical_table_name)    SELECT 'contract_group_audit_view'  , 'Contract Audit' END
IF NOT EXISTS (SELECT 1 FROM alert_table_definition atd WHERE atd.physical_table_name = 'source_deal_header') BEGIN INSERT INTO alert_table_definition (physical_table_name, logical_table_name)    SELECT 'source_deal_header'  , 'Deal Header' END
IF NOT EXISTS (SELECT 1 FROM alert_table_definition atd WHERE atd.physical_table_name = 'source_deal_detail') BEGIN INSERT INTO alert_table_definition (physical_table_name, logical_table_name)    SELECT 'source_deal_detail'  , 'Deal Detail' END
IF NOT EXISTS (SELECT 1 FROM alert_table_definition atd WHERE atd.physical_table_name = 'user_defined_deal_fields') BEGIN INSERT INTO alert_table_definition (physical_table_name, logical_table_name)    SELECT 'user_defined_deal_fields'  , 'UDF Header' END
IF NOT EXISTS (SELECT 1 FROM alert_table_definition atd WHERE atd.physical_table_name = 'user_defined_deal_fields_template') BEGIN INSERT INTO alert_table_definition (physical_table_name, logical_table_name)    SELECT 'user_defined_deal_fields_template'  , 'UDF Fields' END
IF NOT EXISTS (SELECT 1 FROM alert_table_definition atd WHERE atd.physical_table_name = 'Calc_invoice_Volume_variance') BEGIN INSERT INTO alert_table_definition (physical_table_name, logical_table_name)    SELECT 'Calc_invoice_Volume_variance'  , 'Invoice Details' END
IF NOT EXISTS (SELECT 1 FROM alert_table_definition atd WHERE atd.physical_table_name = 'confirm_status') BEGIN INSERT INTO alert_table_definition (physical_table_name, logical_table_name)    SELECT 'confirm_status'  , 'Confirm Status' END
IF NOT EXISTS (SELECT 1 FROM alert_table_definition atd WHERE atd.physical_table_name = 'confirm_status_recent') BEGIN INSERT INTO alert_table_definition (physical_table_name, logical_table_name)    SELECT 'confirm_status_recent'  , 'Confirm Status Recent' END
IF NOT EXISTS (SELECT 1 FROM alert_table_definition atd WHERE atd.physical_table_name = 'deal_confirmation_rule') BEGIN INSERT INTO alert_table_definition (physical_table_name, logical_table_name)    SELECT 'deal_confirmation_rule'  , 'Deal Confirm Rule' END

IF NOT EXISTS (SELECT 1 FROM alert_table_definition atd WHERE atd.physical_table_name = 'source_deal_pnl') BEGIN INSERT INTO alert_table_definition (physical_table_name, logical_table_name)    SELECT 'source_deal_pnl'  , 'Source Deal PNL' END
IF NOT EXISTS (SELECT 1 FROM alert_table_definition atd WHERE atd.physical_table_name = 'vwDealContractValue') BEGIN INSERT INTO alert_table_definition (physical_table_name, logical_table_name)    SELECT 'vwDealContractValue'  , 'Deal Contract Value' END
IF NOT EXISTS (SELECT 1 FROM alert_table_definition atd WHERE atd.physical_table_name = 'vwCreditExposureDetail') BEGIN INSERT INTO alert_table_definition (physical_table_name, logical_table_name)    SELECT 'vwCreditExposureDetail'  , 'Credit Exposure Detail' END
IF NOT EXISTS (SELECT 1 FROM alert_table_definition atd WHERE atd.physical_table_name = 'vwCounterPartyCreditInfoAudit') BEGIN INSERT INTO alert_table_definition (physical_table_name, logical_table_name)    SELECT 'vwCounterPartyCreditInfoAudit'  , 'Counterparty Credit Info Audit' END
IF NOT EXISTS (SELECT 1 FROM alert_table_definition atd WHERE atd.physical_table_name = 'generic_mapping_header') BEGIN INSERT INTO alert_table_definition (physical_table_name, logical_table_name)    SELECT 'generic_mapping_header'  , 'Generic Mapping Header' END
IF NOT EXISTS (SELECT 1 FROM alert_table_definition atd WHERE atd.physical_table_name = 'generic_mapping_definition') BEGIN INSERT INTO alert_table_definition (physical_table_name, logical_table_name)    SELECT 'generic_mapping_definition'  , 'Generic Mapping Definition' END
IF NOT EXISTS (SELECT 1 FROM alert_table_definition atd WHERE atd.physical_table_name = 'generic_mapping_values') BEGIN INSERT INTO alert_table_definition (physical_table_name, logical_table_name)    SELECT 'generic_mapping_values'  , 'Generic Mapping Values' END
IF NOT EXISTS (SELECT * FROM alert_table_definition atd WHERE atd.physical_table_name = 'source_deal_header_template') BEGIN INSERT INTO alert_table_definition (physical_table_name, logical_table_name)    SELECT 'source_deal_header_template'  , 'Deal Template' END
IF NOT EXISTS (SELECT 1 FROM alert_table_definition atd WHERE atd.physical_table_name = 'vwCounterPartyCreditLimitsAudit') BEGIN INSERT INTO alert_table_definition (physical_table_name, logical_table_name)    SELECT 'vwCounterPartyCreditLimitsAudit'  , 'Counterparty Credit Limits Audit' END

PRINT 'tables insert ends'

PRINT '-----------------------'

PRINT 'columns insert starts'

Update acd 
SET acd.column_name = 'counterparty_id'
FROM alert_columns_definition acd
Inner Join alert_table_definition atd on acd.alert_table_id = atd.alert_table_definition_id  
where acd.column_name = 'ID' and atd.physical_table_name = 'vwCreditExposureDetail'

INSERT INTO alert_columns_definition (alert_table_id, column_name, is_primary)
SELECT atd.alert_table_definition_id, 
	   c.name,
       MAX(CASE WHEN ISNULL(i.is_primary_key, 0) = 1 THEN 'y' ELSE 'n' END) is_primary
FROM  alert_table_definition atd
INNER JOIN sys.columns c ON  c.object_id = OBJECT_ID(atd.physical_table_name)
INNER JOIN sys.types t ON  c.system_type_id = t.system_type_id
LEFT OUTER JOIN sys.index_columns ic
    ON  ic.object_id = c.object_id
    AND ic.column_id = c.column_id
LEFT OUTER JOIN sys.indexes i
    ON  ic.object_id = i.object_id
    AND ic.index_id = i.index_id
LEFT JOIN alert_columns_definition acd ON c.[name] = acd.column_name AND acd.alert_table_id = atd.alert_table_definition_id
WHERE acd.alert_columns_definition_id IS NULL
GROUP BY atd.alert_table_definition_id, c.name

PRINT 'columns insert ends'    

PRINT '---------------------'


PRINT '############columns static_data_type_id update starts################'
PRINT 'contract_status'
UPDATE alert_columns_definition SET static_data_type_id = 1900 WHERE column_name = 'contract_status'

PRINT 'invoice_status'
UPDATE alert_columns_definition SET static_data_type_id = 20700 WHERE column_name = 'invoice_status'

PRINT 'confirm_status'
UPDATE acd
SET  static_data_type_id = 17200
FROM alert_columns_definition acd
INNER JOIN alert_table_definition atd ON atd.alert_table_definition_id = acd.alert_table_id
WHERE  acd.column_name = 'type' AND atd.physical_table_name = 'confirm_status'

UPDATE acd
SET  static_data_type_id = 17200
FROM alert_columns_definition acd
INNER JOIN alert_table_definition atd ON atd.alert_table_definition_id = acd.alert_table_id
WHERE  acd.column_name = 'type' AND atd.physical_table_name = 'confirm_status_recent'

UPDATE acd
SET  static_data_type_id = 17200
FROM alert_columns_definition acd
INNER JOIN alert_table_definition atd ON atd.alert_table_definition_id = acd.alert_table_id
WHERE acd.column_name = 'confirm_status_type' AND atd.physical_table_name = 'source_deal_header'

PRINT 'deal_status'
UPDATE acd
SET  static_data_type_id = 5600
FROM alert_columns_definition acd
INNER JOIN alert_table_definition atd ON atd.alert_table_definition_id = acd.alert_table_id
WHERE acd.column_name = 'deal_status' AND atd.physical_table_name = 'source_deal_header'

PRINT '############columns static_data_type_id update ends################'

UPDATE alert_table_definition
SET    physical_table_name = 'contract_group_audit_view'
WHERE  physical_table_name = 'contract_group_audit'

UPDATE alert_columns_definition
SET    is_primary = 'y'
FROM   alert_table_definition atd
INNER JOIN alert_columns_definition acd ON  acd.alert_table_id = atd.alert_table_definition_id
WHERE  acd.column_name = 'counterparty_id'
       AND atd.physical_table_name = 'vwCreditExposureDetail' 

UPDATE alert_columns_definition
SET    is_primary = 'y'
FROM   alert_table_definition atd
INNER JOIN alert_columns_definition acd ON  acd.alert_table_id = atd.alert_table_definition_id
WHERE  acd.column_name = 'source_deal_header_id'
       AND atd.physical_table_name = 'vwDealContractValue'


UPDATE alert_columns_definition
SET    is_primary = 'y'
FROM   alert_table_definition atd
INNER JOIN alert_columns_definition acd ON  acd.alert_table_id = atd.alert_table_definition_id
WHERE  acd.column_name = 'counterparty_id'
       AND atd.physical_table_name = 'vwCounterPartyCreditInfoAudit'


UPDATE alert_columns_definition
SET is_primary = 'y'
FROM   alert_table_definition atd
INNER JOIN alert_columns_definition acd ON  acd.alert_table_id = atd.alert_table_definition_id
WHERE  acd.column_name = 'generic_mapping_definition_id'
       AND atd.physical_table_name = 'generic_mapping_definition'
       
UPDATE alert_columns_definition
SET is_primary = 'y'
FROM   alert_table_definition atd
INNER JOIN alert_columns_definition acd ON  acd.alert_table_id = atd.alert_table_definition_id
WHERE  acd.column_name = 'generic_mapping_values_id'
       AND atd.physical_table_name = 'generic_mapping_values'

UPDATE alert_columns_definition
SET    is_primary = 'y'
FROM   alert_table_definition atd
INNER JOIN alert_columns_definition acd ON  acd.alert_table_id = atd.alert_table_definition_id
WHERE  acd.column_name = 'counterparty_credit_limit_id'
	AND atd.physical_table_name = 'vwCounterPartyCreditLimitsAudit' 