
IF NOT EXISTS (SELECT 1 FROM sys.columns c INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]	WHERE t.name = 'trm_sap_status_log_detail'
		AND c.name = 'ContractPurchaseOrder')
	ALTER TABLE trm_sap_status_log_detail ADD ContractPurchaseOrder VARCHAR(100)

IF NOT EXISTS (SELECT 1 FROM sys.columns c INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]	WHERE t.name = 'trm_sap_status_log_detail'
		AND c.name = 'ContractItemNumber')
	ALTER TABLE trm_sap_status_log_detail ADD ContractItemNumber VARCHAR(100)

IF NOT EXISTS (SELECT 1 FROM sys.columns c INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]	WHERE t.name = 'trm_sap_status_log_detail'
		AND c.name = 'DeliveryPricingDate')
	ALTER TABLE trm_sap_status_log_detail ADD DeliveryPricingDate VARCHAR(100)

IF NOT EXISTS (SELECT 1 FROM sys.columns c INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]	WHERE t.name = 'trm_sap_status_log_detail'
		AND c.name = 'ServiceRenderedDate')
	ALTER TABLE trm_sap_status_log_detail ADD ServiceRenderedDate VARCHAR(100)

IF NOT EXISTS (SELECT 1 FROM sys.columns c INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]	WHERE t.name = 'trm_sap_status_log_detail'
		AND c.name = 'AccountingRemarks')
	ALTER TABLE trm_sap_status_log_detail ADD AccountingRemarks VARCHAR(100)

IF NOT EXISTS (SELECT 1 FROM sys.columns c INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]	WHERE t.name = 'trm_sap_status_log_detail'
		AND c.name = 'ItemCategory')
	ALTER TABLE trm_sap_status_log_detail ADD ItemCategory VARCHAR(100)


IF NOT EXISTS (SELECT 1 FROM sys.columns c INNER JOIN sys.tables t ON t.[object_id] = c.[object_id]	WHERE t.name = 'trm_sap_status_log_detail'
		AND c.name = 'BillingDate')
	ALTER TABLE trm_sap_status_log_detail ADD BillingDate VARCHAR(100)

