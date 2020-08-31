-- START source_deal_header

IF EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'source_deal_header'
                   AND ccu.COLUMN_NAME = 'source_system_id'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu1
                   ON  tc.TABLE_NAME = ccu1.TABLE_NAME
                   AND tc.Constraint_name = ccu1.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'source_deal_header'
                   AND ccu1.COLUMN_NAME = 'deal_id'
				   AND tc.CONSTRAINT_NAME = 'IX_source_deal_header_unique'
   ) 
BEGIN
    ALTER TABLE [dbo].source_deal_header DROP CONSTRAINT IX_source_deal_header_unique
END
GO    

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_source_deal_header_unique' AND object_id = OBJECT_ID('dbo.[source_deal_header]'))
BEGIN
	DROP INDEX IX_source_deal_header_unique ON dbo.[source_deal_header]
END
GO
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PT_source_deal_header_deal_id' AND object_id = OBJECT_ID('[source_deal_header]'))
BEGIN
	DROP INDEX IX_PT_source_deal_header_deal_id ON dbo.[source_deal_header]
END
GO
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_source_deal_header_1' AND object_id = OBJECT_ID('[source_deal_header]'))
BEGIN
	DROP INDEX IX_source_deal_header_1 ON dbo.[source_deal_header]
END
GO
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_source_deal_header_template_id' AND object_id = OBJECT_ID('[source_deal_header]'))
BEGIN
	DROP INDEX IX_source_deal_header_template_id ON dbo.[source_deal_header]
END
GO

IF EXISTS (
    SELECT 1
    FROM sys.all_columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
    WHERE t.name = 'source_deal_header' AND c.name = 'create_user' AND s.name = 'dbo' AND d.name = 'source_deal_header_create_user_def')
BEGIN
	ALTER TABLE source_deal_header
	DROP CONSTRAINT source_deal_header_create_user_def
END
GO
-- Change column datatype

IF COL_LENGTH('source_deal_header', 'deal_id') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN deal_id NVARCHAR(200)
END
GO
IF COL_LENGTH('source_deal_header', 'ext_deal_id') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN ext_deal_id NVARCHAR(200)
END
GO
IF COL_LENGTH('source_deal_header', 'physical_financial_flag') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN physical_financial_flag NCHAR(10)
END
GO
IF COL_LENGTH('source_deal_header', 'structured_deal_id') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN structured_deal_id NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_header', 'option_flag') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN option_flag NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header', 'option_type') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN option_type NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header', 'option_excercise_type') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN option_excercise_type NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header', 'description1') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN description1 NVARCHAR(2000)
END
GO
IF COL_LENGTH('source_deal_header', 'description2') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN description2 NVARCHAR(100)
END
GO
IF COL_LENGTH('source_deal_header', 'description3') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN description3 NVARCHAR(100)
END
GO
IF COL_LENGTH('source_deal_header', 'header_buy_sell_flag') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN header_buy_sell_flag NVARCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header', 'assigned_by') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN assigned_by NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_header', 'generation_source') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN generation_source NVARCHAR(250)
END
GO
IF COL_LENGTH('source_deal_header', 'aggregate_environment') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN aggregate_environment NVARCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header', 'aggregate_envrionment_comment') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN aggregate_envrionment_comment NVARCHAR(250)
END
GO
IF COL_LENGTH('source_deal_header', 'rolling_avg') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN rolling_avg NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header', 'create_user') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN create_user NVARCHAR(50) 
	ALTER TABLE source_deal_header ADD CONSTRAINT source_deal_header_create_user_def DEFAULT [dbo].[FNADBUser]() FOR create_user
END
GO
IF COL_LENGTH('source_deal_header', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN update_user NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_header', 'reference') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN reference NVARCHAR(250)
END
GO
IF COL_LENGTH('source_deal_header', 'deal_locked') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN deal_locked NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header', 'unit_fixed_flag') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN unit_fixed_flag NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header', 'term_frequency') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN term_frequency NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header', 'verified_by') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN verified_by NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_header', 'risk_sign_off_by') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN risk_sign_off_by NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_header', 'back_office_sign_off_by') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN back_office_sign_off_by NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_header', 'description4') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN description4 NVARCHAR(100)
END
GO
IF COL_LENGTH('source_deal_header', 'settlement_vol_type') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN settlement_vol_type NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header', 'sample_control') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN sample_control NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header', 'sdr') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN sdr NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header', 'certificate') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN certificate NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header', 'match_type') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN match_type NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header', 'is_environmental') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header ALTER COLUMN is_environmental NCHAR(1)
END
GO
--Enable Index
--clustered, unique, primary key, stats no recompute located on PRIMARY

IF NOT EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'source_deal_header'
                   AND ccu.COLUMN_NAME = 'source_system_id'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu1
                   ON  tc.TABLE_NAME = ccu1.TABLE_NAME
                   AND tc.Constraint_name = ccu1.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'source_deal_header'
                   AND ccu1.COLUMN_NAME = 'deal_id'
   )
BEGIN
    ALTER TABLE [dbo].source_deal_header WITH NOCHECK ADD CONSTRAINT IX_source_deal_header_unique UNIQUE(source_system_id, deal_id)
END
GO


IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_source_deal_header_unique' AND object_id = OBJECT_ID('[source_deal_header]'))
BEGIN
	CREATE UNIQUE INDEX IX_source_deal_header_unique ON source_deal_header(source_system_id, deal_id)
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PT_source_deal_header_deal_id' AND object_id = OBJECT_ID('[source_deal_header]'))
BEGIN
	CREATE INDEX IX_PT_source_deal_header_deal_id ON source_deal_header(deal_id, header_buy_sell_flag, physical_financial_flag, source_deal_header_id, term_frequency)
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_source_deal_header_1' AND object_id = OBJECT_ID('[source_deal_header]'))
BEGIN
	CREATE INDEX IX_source_deal_header_1 ON source_deal_header(deal_date, structured_deal_id, ext_deal_id, header_buy_sell_flag)
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_source_deal_header_template_id' AND object_id = OBJECT_ID('[source_deal_header]'))
BEGIN
	CREATE INDEX IX_source_deal_header_template_id ON source_deal_header(template_id)
END
GO
-- END source_deal_header


-- start source_deal_detail

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PT_source_deal_detail_curve_id' AND object_id = OBJECT_ID('dbo.[source_deal_detail]'))
BEGIN
	DROP INDEX IX_PT_source_deal_detail_curve_id ON dbo.[source_deal_detail]
END
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'indx_source_deal_detail_volume_frequency' AND object_id = OBJECT_ID('dbo.[source_deal_detail]'))
BEGIN
	DROP INDEX indx_source_deal_detail_volume_frequency ON dbo.[source_deal_detail]
END
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PT_source_deal_detail_physical_financial_flag' AND object_id = OBJECT_ID('dbo.[source_deal_detail]'))
BEGIN
	DROP INDEX IX_PT_source_deal_detail_physical_financial_flag ON dbo.[source_deal_detail]
END
GO

IF EXISTS (
    SELECT 1 
    FROM sys.all_columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
    WHERE t.name = 'source_deal_detail' AND c.name = 'pay_opposite' AND s.name = 'dbo' AND d.name = 'DF_pay_opposite')
BEGIN
	ALTER TABLE source_deal_detail
	DROP CONSTRAINT DF_pay_opposite
END
GO

IF COL_LENGTH('source_deal_detail', 'fixed_float_leg') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN fixed_float_leg NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail', 'buy_sell_flag') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN buy_sell_flag NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail', 'deal_volume_frequency') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN deal_volume_frequency NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail', 'block_description') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN block_description NVARCHAR(100)
END
GO
IF COL_LENGTH('source_deal_detail', 'deal_detail_description') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN deal_detail_description NVARCHAR(100)
END
GO
IF COL_LENGTH('source_deal_detail', 'create_user') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN create_user NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_detail', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN update_user NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_detail', 'physical_financial_flag') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN physical_financial_flag NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail', 'Booked') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN Booked NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail', 'pay_opposite') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN pay_opposite NVARCHAR(1)
	ALTER TABLE source_deal_detail ADD CONSTRAINT DF_pay_opposite DEFAULT 'y' FOR pay_opposite
END
GO
IF COL_LENGTH('source_deal_detail', 'lock_deal_detail') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN lock_deal_detail NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail', 'pricing_type') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN pricing_type NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail', 'pricing_period') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN pricing_period NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail', 'event_defination') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN event_defination NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail', 'apply_to_all_legs') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN apply_to_all_legs NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail', 'organic') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN organic NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail', 'lot') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN lot NVARCHAR(500)
END
GO
IF COL_LENGTH('source_deal_detail', 'batch_id') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN batch_id NVARCHAR(500)
END
GO
IF COL_LENGTH('source_deal_detail', 'detail_sample_control') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN detail_sample_control NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail', 'product_description') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN product_description NVARCHAR(2000)
END
GO
IF COL_LENGTH('source_deal_detail', 'upstream_contract') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN upstream_contract NVARCHAR(500)
END
GO
IF COL_LENGTH('source_deal_detail', 'vintage') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN vintage NVARCHAR(10)
END
GO
IF COL_LENGTH('source_deal_detail', 'tiered') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN tiered NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail', 'pricing_description') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail ALTER COLUMN pricing_description NVARCHAR(500)
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PT_source_deal_detail_curve_id' AND object_id = OBJECT_ID('[source_deal_detail]'))
BEGIN
	CREATE INDEX IX_PT_source_deal_detail_curve_id ON source_deal_detail(curve_id)
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'indx_source_deal_detail_volume_frequency' AND object_id = OBJECT_ID('[source_deal_detail]'))
BEGIN
	CREATE INDEX indx_source_deal_detail_volume_frequency ON source_deal_detail(curve_id)
	UPDATE STATISTICS dbo.source_deal_detail indx_source_deal_detail_volume_frequency WITH NORECOMPUTE
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PT_source_deal_detail_physical_financial_flag' AND object_id = OBJECT_ID('[source_deal_detail]'))
BEGIN
	CREATE INDEX IX_PT_source_deal_detail_physical_financial_flag ON source_deal_detail(physical_financial_flag)
END
GO
-- END source_deal_detail


-- Start source_deal_header_audit
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PT_source_deal_header_audit_user_action_update_ts' AND object_id = OBJECT_ID('[source_deal_header_audit]'))
BEGIN
	DROP INDEX IX_PT_source_deal_header_audit_user_action_update_ts ON dbo.[source_deal_header_audit]
END
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PT_SDHA11' AND object_id = OBJECT_ID('[source_deal_header_audit]'))
BEGIN
	DROP INDEX IX_PT_SDHA11 ON dbo.[source_deal_header_audit]
END
GO

IF COL_LENGTH('source_deal_header_audit', 'deal_id') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN deal_id NVARCHAR(200)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'ext_deal_id') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN ext_deal_id NVARCHAR(200)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'physical_financial_flag') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN physical_financial_flag NCHAR(10)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'structured_deal_id') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN structured_deal_id NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'option_flag') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN option_flag NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'option_type') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN option_type NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'option_excercise_type') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN option_excercise_type NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'description1') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN description1 NVARCHAR(2000)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'description2') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN description2 NVARCHAR(1000)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'description3') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN description3 NVARCHAR(1000)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'header_buy_sell_flag') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN header_buy_sell_flag NVARCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'assigned_by') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN assigned_by NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'generation_source') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN generation_source NVARCHAR(250)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'aggregate_environment') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN aggregate_environment NVARCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'aggregate_envrionment_comment') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN aggregate_envrionment_comment NVARCHAR(250)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'rolling_avg') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN rolling_avg NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'create_user') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN create_user NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN update_user NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'user_action') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN user_action NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'reference') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN reference NVARCHAR(250)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'deal_locked') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN deal_locked NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'verified_by') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN verified_by NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'unit_fixed_flag') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN unit_fixed_flag NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'term_frequency') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN term_frequency NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'formula_change') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN formula_change NVARCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'mtm_effect_field') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN mtm_effect_field NVARCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'settlement_vol_type') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN settlement_vol_type NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'sample_control') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN sample_control NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'underlying_options') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN underlying_options NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'sdr') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN sdr NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'certificate') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN certificate NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'match_type') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN match_type NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_audit', 'is_environmental') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_audit ALTER COLUMN is_environmental NCHAR(1)
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PT_source_deal_header_audit_user_action_update_ts' AND object_id = OBJECT_ID('[source_deal_header_audit]'))
BEGIN
	CREATE INDEX IX_PT_source_deal_header_audit_user_action_update_ts ON source_deal_header_audit(user_action, update_ts)
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PT_SDHA11' AND object_id = OBJECT_ID('[source_deal_header_audit]'))
BEGIN
	CREATE INDEX IX_PT_SDHA11 ON source_deal_header_audit(source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4)
END
GO
-- END source_deal_header_audit

-- Start source_deal_detail_audit
IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_deal_detail_audit]') AND name = N'IX_PT_source_deal_detail_audit_header_audit_id')
BEGIN
	DROP INDEX [IX_PT_source_deal_detail_audit_header_audit_id] ON [dbo].[source_deal_detail_audit] WITH ( ONLINE = OFF )
END
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_deal_detail_audit]') AND name = N'IX_PT_source_deal_detail_audit_source_deal_detail_id_header_audit_id')
BEGIN
	DROP INDEX [IX_PT_source_deal_detail_audit_source_deal_detail_id_header_audit_id] ON [dbo].[source_deal_detail_audit] WITH ( ONLINE = OFF )
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'fixed_float_leg') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN fixed_float_leg NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail_audit', 'buy_sell_flag') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN buy_sell_flag NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail_audit', 'deal_volume_frequency') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN deal_volume_frequency NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail_audit', 'block_description') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN block_description NVARCHAR(100)
END
GO
IF COL_LENGTH('source_deal_detail_audit', 'deal_detail_description') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN deal_detail_description NVARCHAR(100)
END
GO
IF COL_LENGTH('source_deal_detail_audit', 'create_user') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN create_user NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_detail_audit', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN update_user NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_detail_audit', 'user_action') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN user_action NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_detail_audit', 'physical_financial_flag') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN physical_financial_flag NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail_audit', 'Booked') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN Booked NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail_audit', 'pay_opposite') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN pay_opposite NVARCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail_audit', 'formula_text') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN formula_text NVARCHAR(MAX)
END
GO
IF COL_LENGTH('source_deal_detail_audit', 'lock_deal_detail') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN lock_deal_detail NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail_audit', 'organic') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN organic NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail_audit', 'lot') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN lot NVARCHAR(500)
END
GO
IF COL_LENGTH('source_deal_detail_audit', 'batch_id') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN batch_id NVARCHAR(500)
END
GO
IF COL_LENGTH('source_deal_detail_audit', 'detail_sample_control') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN detail_sample_control NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail_audit', 'product_description') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN product_description NVARCHAR(2000)
END
GO
IF COL_LENGTH('source_deal_detail_audit', 'upstream_contract') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN upstream_contract NVARCHAR(500)
END
GO
IF COL_LENGTH('source_deal_detail_audit', 'vintage') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN vintage NVARCHAR(10)
END
GO
IF COL_LENGTH('source_deal_detail_audit', 'tiered') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN tiered NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail_audit', 'pricing_description') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ALTER COLUMN pricing_description NVARCHAR(500)
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PT_source_deal_detail_audit_header_audit_id' AND object_id = OBJECT_ID(N'[dbo].[source_deal_detail_audit]'))
BEGIN
	CREATE INDEX [IX_PT_source_deal_detail_audit_header_audit_id] ON 
	[source_deal_detail_audit] ([header_audit_id]) 
	INCLUDE(
			   [source_deal_detail_id],
			   [term_start],
			   [term_end],
			   [contract_expiration_date],
			   [fixed_float_leg],
			   [buy_sell_flag],
			   [curve_id],
			   [fixed_price],
			   [fixed_price_currency_id],
			   [option_strike_price],
			   [deal_volume],
			   [deal_volume_frequency],
			   [deal_volume_uom_id],
			   [block_description],
			   [deal_detail_description],
			   [settlement_volume],
			   [settlement_uom],
			   [price_adder],
			   [price_multiplier],
			   [settlement_date],
			   [day_count_id],
			   [location_id],
			   [physical_financial_flag],
			   [Booked],
			   [fixed_cost],
			   [multiplier],
			   [adder_currency_id],
			   [fixed_cost_currency_id],
			   [formula_currency_id],
			   [price_adder2],
			   [price_adder_currency2],
			   [volume_multiplier2],
			   [pay_opposite],
			   [formula_text],
			   [capacity],
			   [meter_id],
			   [settlement_currency],
			   [standard_yearly_volume],
			   [price_uom_id],
			   [category],
			   [profile_code],
			   [pv_party],
			   [status],
			   [lock_deal_detail]
	)
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PT_source_deal_detail_audit_source_deal_detail_id_header_audit_id' AND object_id = OBJECT_ID(N'[dbo].[source_deal_detail_audit]'))
BEGIN
	CREATE INDEX 
	[IX_PT_source_deal_detail_audit_source_deal_detail_id_header_audit_id] ON 
	[source_deal_detail_audit] ([source_deal_detail_id], [header_audit_id]) 
	INCLUDE(
			   [source_deal_header_id],
			   [term_start],
			   [term_end],
			   [Leg],
			   [contract_expiration_date],
			   [fixed_float_leg],
			   [buy_sell_flag],
			   [curve_id],
			   [fixed_price],
			   [fixed_price_currency_id],
			   [option_strike_price],
			   [deal_volume],
			   [deal_volume_frequency],
			   [deal_volume_uom_id],
			   [block_description],
			   [deal_detail_description],
			   [settlement_volume],
			   [settlement_uom],
			   [update_user],
			   [update_ts],
			   [price_adder],
			   [price_multiplier],
			   [settlement_date],
			   [day_count_id],
			   [location_id],
			   [physical_financial_flag],
			   [Booked],
			   [fixed_cost],
			   [multiplier],
			   [adder_currency_id],
			   [fixed_cost_currency_id],
			   [formula_currency_id],
			   [price_adder2],
			   [price_adder_currency2],
			   [volume_multiplier2],
			   [pay_opposite],
			   [formula_text],
			   [capacity],
			   [meter_id],
			   [settlement_currency],
			   [standard_yearly_volume],
			   [price_uom_id],
			   [category],
			   [profile_code],
			   [pv_party],
			   [status],
			   [lock_deal_detail]
	)
END
GO
-- End source_deal_detail_audit

-- Start delete_source_deal_header

IF COL_LENGTH('delete_source_deal_header', 'deal_id') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN deal_id NVARCHAR(200)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'ext_deal_id') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN ext_deal_id NVARCHAR(200)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'physical_financial_flag') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN physical_financial_flag NCHAR(10)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'structured_deal_id') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN structured_deal_id NVARCHAR(50)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'option_flag') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN option_flag NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'option_type') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN option_type NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'option_excercise_type') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN option_excercise_type NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'description1') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN description1 NVARCHAR(1000)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'description2') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN description2 NVARCHAR(1000)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'description3') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN description3 NVARCHAR(1000)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'header_buy_sell_flag') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN header_buy_sell_flag NVARCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'assigned_by') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN assigned_by NVARCHAR(50)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'generation_source') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN generation_source NVARCHAR(250)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'aggregate_environment') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN aggregate_environment NVARCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'aggregate_envrionment_comment') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN aggregate_envrionment_comment NVARCHAR(250)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'rolling_avg') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN rolling_avg NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'create_user') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN create_user NVARCHAR(50)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN update_user NVARCHAR(50)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'reference') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN reference NVARCHAR(250)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'deal_locked') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN deal_locked NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'unit_fixed_flag') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN unit_fixed_flag NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'term_frequency') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN term_frequency NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'verified_by') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN verified_by NVARCHAR(50)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'risk_sign_off_by') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN risk_sign_off_by NVARCHAR(50)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'back_office_sign_off_by') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN back_office_sign_off_by NVARCHAR(50)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'delete_user') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN delete_user NVARCHAR(30)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'settlement_vol_type') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN settlement_vol_type NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'sample_control') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN sample_control NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'underlying_options') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN underlying_options NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'sdr') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN sdr NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'certificate') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN certificate NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'match_type') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN match_type NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_header', 'is_environmental') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_header ALTER COLUMN is_environmental NCHAR(1)
END
GO
-- END delete_source_deal_header

-- Start delete_source_deal_detail

IF COL_LENGTH('delete_source_deal_detail', 'fixed_float_leg') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN fixed_float_leg NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_detail', 'buy_sell_flag') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN buy_sell_flag NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_detail', 'deal_volume_frequency') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN deal_volume_frequency NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_detail', 'block_description') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN block_description NVARCHAR(100)
END
GO
IF COL_LENGTH('delete_source_deal_detail', 'deal_detail_description') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN deal_detail_description NVARCHAR(100)
END
GO
IF COL_LENGTH('delete_source_deal_detail', 'create_user') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN create_user NVARCHAR(50)
END
GO
IF COL_LENGTH('delete_source_deal_detail', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN update_user NVARCHAR(50)
END
GO
IF COL_LENGTH('delete_source_deal_detail', 'physical_financial_flag') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN physical_financial_flag NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_detail', 'Booked') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN Booked NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_detail', 'pay_opposite') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN pay_opposite NVARCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_detail', 'delete_user') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN delete_user NVARCHAR(30)
END
GO
IF COL_LENGTH('delete_source_deal_detail', 'lock_deal_detail') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN lock_deal_detail NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_detail', 'pricing_type') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN pricing_type NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_detail', 'pricing_period') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN pricing_period NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_detail', 'event_defination') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN event_defination NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_detail', 'apply_to_all_legs') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN apply_to_all_legs NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_detail', 'organic') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN organic NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_detail', 'lot') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN lot NVARCHAR(500)
END
GO
IF COL_LENGTH('delete_source_deal_detail', 'batch_id') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN batch_id NVARCHAR(500)
END
GO
IF COL_LENGTH('delete_source_deal_detail', 'detail_sample_control') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN detail_sample_control NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_detail', 'product_description') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN product_description NVARCHAR(2000)
END
GO
IF COL_LENGTH('delete_source_deal_detail', 'upstream_contract') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN upstream_contract NVARCHAR(500)
END
GO
IF COL_LENGTH('delete_source_deal_detail', 'vintage') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN vintage NVARCHAR(10)
END
GO
IF COL_LENGTH('delete_source_deal_detail', 'tiered') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN tiered NCHAR(1)
END
GO
IF COL_LENGTH('delete_source_deal_detail', 'pricing_description') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ALTER COLUMN pricing_description NVARCHAR(500)
END
GO
--End delete_source_deal_detail

-- Start maintain_field_deal

IF EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'maintain_field_deal'
                   AND ccu.COLUMN_NAME = 'farrms_field_id'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu1
                   ON  tc.TABLE_NAME = ccu1.TABLE_NAME
                   AND tc.Constraint_name = ccu1.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'maintain_field_deal'
                   AND ccu1.COLUMN_NAME = 'header_detail'
				   AND tc.CONSTRAINT_NAME = 'UC_maintain_field_deal_farrms_field_id'
   )
BEGIN
	ALTER TABLE maintain_field_deal DROP CONSTRAINT UC_maintain_field_deal_farrms_field_id
END
GO

IF EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'maintain_field_deal'
                   AND ccu.COLUMN_NAME = 'default_label'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu1
                   ON  tc.TABLE_NAME = ccu1.TABLE_NAME
                   AND tc.Constraint_name = ccu1.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'maintain_field_deal'
                   AND ccu1.COLUMN_NAME = 'header_detail'
				   AND tc.CONSTRAINT_NAME = 'UC_maintain_field_deal_default_label'
   )
BEGIN
	ALTER TABLE maintain_field_deal DROP CONSTRAINT UC_maintain_field_deal_default_label
END
GO

IF COL_LENGTH('maintain_field_deal', 'farrms_field_id') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_deal ALTER COLUMN farrms_field_id NVARCHAR(50)
END
GO
IF COL_LENGTH('maintain_field_deal', 'default_label') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_deal ALTER COLUMN default_label NVARCHAR(150)
END
GO
IF COL_LENGTH('maintain_field_deal', 'field_type') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_deal ALTER COLUMN field_type NCHAR(1)
END
GO
IF COL_LENGTH('maintain_field_deal', 'data_type') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_deal ALTER COLUMN data_type NVARCHAR(50)
END
GO
IF COL_LENGTH('maintain_field_deal', 'header_detail') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_deal ALTER COLUMN header_detail NCHAR(1)
END
GO
IF COL_LENGTH('maintain_field_deal', 'system_required') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_deal ALTER COLUMN system_required NCHAR(1)
END
GO
IF COL_LENGTH('maintain_field_deal', 'sql_string') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_deal ALTER COLUMN sql_string NVARCHAR(MAX)
END
GO
IF COL_LENGTH('maintain_field_deal', 'is_disable') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_deal ALTER COLUMN is_disable NCHAR(1)
END
GO
IF COL_LENGTH('maintain_field_deal', 'window_function_id') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_deal ALTER COLUMN window_function_id NVARCHAR(50)
END
GO

IF COL_LENGTH('maintain_field_deal', 'is_hidden') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_deal ALTER COLUMN is_hidden NCHAR(1)
END
GO
IF COL_LENGTH('maintain_field_deal', 'default_value') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_deal ALTER COLUMN default_value NVARCHAR(200)
END
GO
IF COL_LENGTH('maintain_field_deal', 'insert_required') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_deal ALTER COLUMN insert_required NCHAR(1)
END
GO
IF COL_LENGTH('maintain_field_deal', 'data_flag') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_deal ALTER COLUMN data_flag NCHAR(1)
END
GO
IF COL_LENGTH('maintain_field_deal', 'update_required') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_deal ALTER COLUMN update_required NCHAR(1)
END
GO
IF NOT EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'maintain_field_deal'
                   AND ccu.COLUMN_NAME = 'farrms_field_id'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu1
                   ON  tc.TABLE_NAME = ccu1.TABLE_NAME
                   AND tc.Constraint_name = ccu1.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'maintain_field_deal'
                   AND ccu1.COLUMN_NAME = 'header_detail'
   )
BEGIN
    ALTER TABLE [dbo].maintain_field_deal WITH NOCHECK ADD CONSTRAINT [UC_maintain_field_deal_farrms_field_id] UNIQUE(farrms_field_id, header_detail)
END
GO

IF NOT EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'maintain_field_deal'
                   AND ccu.COLUMN_NAME = 'default_label'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu1
                   ON  tc.TABLE_NAME = ccu1.TABLE_NAME
                   AND tc.Constraint_name = ccu1.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'maintain_field_deal'
                   AND ccu1.COLUMN_NAME = 'header_detail'	 	
   )
BEGIN
    ALTER TABLE [dbo].maintain_field_deal WITH NOCHECK ADD CONSTRAINT [UC_maintain_field_deal_default_label] UNIQUE(default_label, header_detail)
END
GO
-- End maintain_field_deal

-- Start maintain_field_template

IF EXISTS(
       SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND tc.Table_Name = 'maintain_field_template'      
                    AND ccu.COLUMN_NAME = 'template_name'   
   )
BEGIN
	ALTER TABLE maintain_field_template DROP CONSTRAINT UC_maintain_field_template_template_name
END
GO

IF COL_LENGTH('maintain_field_template', 'template_name') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_template ALTER COLUMN template_name NVARCHAR(50)
END
GO
IF COL_LENGTH('maintain_field_template', 'template_description') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_template ALTER COLUMN template_description NVARCHAR(150)
END
GO
IF COL_LENGTH('maintain_field_template', 'active_inactive') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_template ALTER COLUMN active_inactive NCHAR(1)
END
GO

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND tc.Table_Name = 'maintain_field_template'      
                    AND ccu.COLUMN_NAME = 'template_name'      
)
BEGIN
	ALTER TABLE [dbo].maintain_field_template WITH NOCHECK ADD CONSTRAINT [UC_maintain_field_template_template_name] UNIQUE(template_name)
END
GO

-- End maintain_field_template

-- Start maintain_field_template_detail

IF EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'maintain_field_template_detail'
                   AND ccu.COLUMN_NAME = 'field_template_id'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu1
                   ON  tc.TABLE_NAME = ccu1.TABLE_NAME
                   AND tc.Constraint_name = ccu1.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'maintain_field_template_detail'
                   AND ccu1.COLUMN_NAME = 'field_id'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu2
                   ON  tc.TABLE_NAME = ccu2.TABLE_NAME
                   AND tc.Constraint_name = ccu2.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'maintain_field_template_detail'
                   AND ccu2.COLUMN_NAME = 'udf_or_system'
				   AND tc.CONSTRAINT_NAME = 'UC_maintain_field_template_detail_field_template_id'
   )
BEGIN
    ALTER TABLE [dbo].maintain_field_template_detail DROP CONSTRAINT UC_maintain_field_template_detail_field_template_id
END
GO

IF EXISTS (SELECT 1 
     FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
     WHERE CONSTRAINT_NAME = 'UQ_field_label' AND TABLE_NAME = 'maintain_field_template_detail'    
)
BEGIN 
	ALTER TABLE dbo.maintain_field_template_detail DROP CONSTRAINT UQ_field_label
END
GO

IF COL_LENGTH('maintain_field_template_detail', 'is_disable') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_template_detail ALTER COLUMN is_disable NCHAR(1)
END
GO
IF COL_LENGTH('maintain_field_template_detail', 'insert_required') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_template_detail ALTER COLUMN insert_required NCHAR(1)
END
GO
IF COL_LENGTH('maintain_field_template_detail', 'field_caption') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_template_detail ALTER COLUMN field_caption NVARCHAR(50)
END
GO
IF COL_LENGTH('maintain_field_template_detail', 'default_value') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_template_detail ALTER COLUMN default_value NVARCHAR(150)
END
GO
IF COL_LENGTH('maintain_field_template_detail', 'udf_or_system') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_template_detail ALTER COLUMN udf_or_system NCHAR(1)
END
GO
IF COL_LENGTH('maintain_field_template_detail', 'data_flag') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_template_detail ALTER COLUMN data_flag NCHAR(1)
END
GO
IF COL_LENGTH('maintain_field_template_detail', 'buy_label') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_template_detail ALTER COLUMN buy_label NVARCHAR(500)
END
GO
IF COL_LENGTH('maintain_field_template_detail', 'sell_label') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_template_detail ALTER COLUMN sell_label NVARCHAR(500)
END
GO
IF COL_LENGTH('maintain_field_template_detail', 'update_required') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_template_detail ALTER COLUMN update_required NCHAR(1)
END
GO
IF COL_LENGTH('maintain_field_template_detail', 'hide_control') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_template_detail ALTER COLUMN hide_control NCHAR(1)
END
GO
IF COL_LENGTH('maintain_field_template_detail', 'value_required') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_template_detail ALTER COLUMN value_required NCHAR(1)
END
GO
IF COL_LENGTH('maintain_field_template_detail', 'show_in_form') IS NOT NULL
BEGIN
    ALTER TABLE maintain_field_template_detail ALTER COLUMN show_in_form NCHAR(1)
END
GO

IF NOT EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'maintain_field_template_detail'
                   AND ccu.COLUMN_NAME = 'field_template_id'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu1
                   ON  tc.TABLE_NAME = ccu1.TABLE_NAME
                   AND tc.Constraint_name = ccu1.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'maintain_field_template_detail'
                   AND ccu1.COLUMN_NAME = 'field_id'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu2
                   ON  tc.TABLE_NAME = ccu2.TABLE_NAME
                   AND tc.Constraint_name = ccu2.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'maintain_field_template_detail'
                   AND ccu2.COLUMN_NAME = 'udf_or_system'
   )
BEGIN
    ALTER TABLE [dbo].maintain_field_template_detail WITH NOCHECK ADD CONSTRAINT [UC_maintain_field_template_detail_field_template_id] UNIQUE(field_template_id, field_id, udf_or_system)
END
GO

IF NOT EXISTS (SELECT 1 
     FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
     WHERE CONSTRAINT_NAME = 'UQ_field_label' AND TABLE_NAME = 'maintain_field_template_detail'    
)
BEGIN 
	ALTER TABLE dbo.maintain_field_template_detail
	ADD CONSTRAINT UQ_field_label UNIQUE (field_template_id, field_group_id, field_caption)
END

-- End maintain_field_template_detail

-- Start source_deal_header_template

IF EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'source_deal_header_template'
                   AND ccu.COLUMN_NAME = 'template_name'
				   AND tc.CONSTRAINT_NAME = 'UC_source_deal_header_template_template_name'
   )
BEGIN
    ALTER TABLE [dbo].source_deal_header_template DROP  CONSTRAINT UC_source_deal_header_template_template_name 
END
GO

IF EXISTS (
    SELECT 1
    FROM sys.all_columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
    WHERE t.name = 'source_deal_header_template' AND c.name = 'enable_provisional_tab' AND s.name = 'dbo')
BEGIN
	DECLARE @def_source_deal_header_template_provision NVARCHAR(100)
	SELECT @def_source_deal_header_template_provision = d.name
    FROM sys.all_columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
    WHERE t.name = 'source_deal_header_template' AND c.name = 'enable_provisional_tab' AND s.name = 'dbo' 

	EXEC('ALTER TABLE source_deal_header_template
	DROP CONSTRAINT ' + @def_source_deal_header_template_provision)
END
GO

IF EXISTS (
    SELECT 1
    FROM sys.all_columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
    WHERE t.name = 'source_deal_header_template' AND c.name = 'enable_escalation_tab' AND s.name = 'dbo')
BEGIN
	DECLARE @def_source_deal_header_template NVARCHAR(100)
	SELECT @def_source_deal_header_template = d.name
    FROM sys.all_columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
    WHERE t.name = 'source_deal_header_template' AND c.name = 'enable_escalation_tab' AND s.name = 'dbo' 

	EXEC('ALTER TABLE source_deal_header_template
	DROP CONSTRAINT ' + @def_source_deal_header_template)
END
GO

IF COL_LENGTH('source_deal_header_template', 'template_name') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN template_name NVARCHAR(250)
END
GO
IF COL_LENGTH('source_deal_header_template', 'physical_financial_flag') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN physical_financial_flag NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'term_frequency_value') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN term_frequency_value NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'term_frequency_type') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN term_frequency_type NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'option_flag') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN option_flag NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'option_type') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN option_type NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'option_exercise_type') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN option_exercise_type NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'description1') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN description1 NVARCHAR(1000)
END
GO
IF COL_LENGTH('source_deal_header_template', 'description2') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN description2 NVARCHAR(1000)
END
GO
IF COL_LENGTH('source_deal_header_template', 'description3') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN description3 NVARCHAR(1000)
END
GO
IF COL_LENGTH('source_deal_header_template', 'header_buy_sell_flag') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN header_buy_sell_flag NCHAR(10)
END
GO
IF COL_LENGTH('source_deal_header_template', 'is_active') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN is_active NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'internal_flag') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN internal_flag NVARCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'create_user') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN create_user NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_header_template', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN update_user NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_header_template', 'allow_edit_term') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN allow_edit_term NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'blotter_supported') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN blotter_supported NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'rollover_to_spot') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN rollover_to_spot NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'discounting_applies') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN discounting_applies NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'term_end_flag') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN term_end_flag NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'is_public') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN is_public NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'make_comment_mandatory_on_save') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN make_comment_mandatory_on_save NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'comments') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN comments NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'trade_ticket_template') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN trade_ticket_template NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'deal_id') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN deal_id NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_header_template', 'ext_deal_id') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN ext_deal_id NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_header_template', 'structured_deal_id') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN structured_deal_id NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_header_template', 'option_excercise_type') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN option_excercise_type NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'assigned_by') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN assigned_by NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_header_template', 'generation_source') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN generation_source NVARCHAR(250)
END
GO
IF COL_LENGTH('source_deal_header_template', 'aggregate_environment') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN aggregate_environment NVARCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'aggregate_envrionment_comment') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN aggregate_envrionment_comment NVARCHAR(250)
END
GO
IF COL_LENGTH('source_deal_header_template', 'rolling_avg') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN rolling_avg NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'reference') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN reference NVARCHAR(250)
END
GO
IF COL_LENGTH('source_deal_header_template', 'deal_locked') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN deal_locked NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'unit_fixed_flag') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN unit_fixed_flag NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'term_frequency') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN term_frequency NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'verified_by') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN verified_by NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_header_template', 'risk_sign_off_by') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN risk_sign_off_by NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_header_template', 'back_office_sign_off_by') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN back_office_sign_off_by NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_header_template', 'calculate_position_based_on_actual') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN calculate_position_based_on_actual NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'enable_pricing_tabs') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN enable_pricing_tabs NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'enable_efp') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN enable_efp NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'enable_trigger') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN enable_trigger NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'settlement_vol_type') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN settlement_vol_type NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'certificate') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN certificate NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'ignore_bom') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN ignore_bom NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'enable_document_tab') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN enable_document_tab NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'description4') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN description4 NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_header_template', 'enable_remarks') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN enable_remarks NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'sample_control') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN sample_control NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'enable_exercise') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN enable_exercise NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'actualization_flag') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN actualization_flag NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'Attribute_type') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN Attribute_type NVARCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'underlying_options') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN underlying_options NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'sdr') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN sdr NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'bid_n_ask_price') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN bid_n_ask_price NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'enable_provisional_tab') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN enable_provisional_tab NCHAR(1)
	ALTER TABLE source_deal_header_template ADD CONSTRAINT DF__source_de__enabl__24894959 DEFAULT 'n' FOR enable_provisional_tab
END
GO
IF COL_LENGTH('source_deal_header_template', 'enable_escalation_tab') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN enable_escalation_tab NCHAR(1)
	ALTER TABLE source_deal_header_template ADD CONSTRAINT DF__source_de__enabl__257D6D92 DEFAULT 'n' FOR enable_escalation_tab
END
GO
IF COL_LENGTH('source_deal_header_template', 'is_gas_daily') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN is_gas_daily NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'match_type') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN match_type NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'is_environmental') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN is_environmental NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_header_template', 'calc_mtm_at_tou_level') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_header_template ALTER COLUMN calc_mtm_at_tou_level NVARCHAR(1)
END
GO

IF NOT EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'source_deal_header_template'
                   AND ccu.COLUMN_NAME = 'template_name'
   )
BEGIN
    ALTER TABLE [dbo].source_deal_header_template WITH NOCHECK ADD CONSTRAINT [UC_source_deal_header_template_template_name] UNIQUE(template_name)
END
GO
-- End source_deal_header_template

-- Start source_deal_detail_template
IF EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'source_deal_detail_template'
                   AND ccu.COLUMN_NAME = 'template_id'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu1
                   ON  tc.TABLE_NAME = ccu1.TABLE_NAME
                   AND tc.Constraint_name = ccu1.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'source_deal_detail_template'
                   AND ccu1.COLUMN_NAME = 'leg'
				   AND tc.CONSTRAINT_NAME = 'UC_source_deal_detail_template_template_id'
   )
BEGIN
    ALTER TABLE [dbo].source_deal_detail_template DROP CONSTRAINT UC_source_deal_detail_template_template_id
END
GO    

IF COL_LENGTH('source_deal_detail_template', 'fixed_float_leg') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_template ALTER COLUMN fixed_float_leg NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail_template', 'buy_sell_flag') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_template ALTER COLUMN buy_sell_flag NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail_template', 'deal_volume_frequency') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_template ALTER COLUMN deal_volume_frequency NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail_template', 'block_description') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_template ALTER COLUMN block_description NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_detail_template', 'create_user') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_template ALTER COLUMN create_user NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_detail_template', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_template ALTER COLUMN update_user NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_detail_template', 'physical_financial_flag') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_template ALTER COLUMN physical_financial_flag NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail_template', 'pay_opposite') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_template ALTER COLUMN pay_opposite NVARCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail_template', 'formula') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_template ALTER COLUMN formula NVARCHAR(100)
END
GO
IF COL_LENGTH('source_deal_detail_template', 'booked') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_template ALTER COLUMN booked NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail_template', 'deal_detail_description') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_template ALTER COLUMN deal_detail_description NVARCHAR(100)
END
GO
IF COL_LENGTH('source_deal_detail_template', 'lock_deal_detail') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_template ALTER COLUMN lock_deal_detail NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail_template', 'organic') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_template ALTER COLUMN organic NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail_template', 'lot') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_template ALTER COLUMN lot NVARCHAR(500)
END
GO
IF COL_LENGTH('source_deal_detail_template', 'batch_id') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_template ALTER COLUMN batch_id NVARCHAR(500)
END
GO
IF COL_LENGTH('source_deal_detail_template', 'detail_sample_control') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_template ALTER COLUMN detail_sample_control NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail_template', 'product_description') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_template ALTER COLUMN product_description NVARCHAR(2000)
END
GO
IF COL_LENGTH('source_deal_detail_template', 'upstream_contract') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_template ALTER COLUMN upstream_contract NVARCHAR(500)
END
GO
IF COL_LENGTH('source_deal_detail_template', 'vintage') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_template ALTER COLUMN vintage NVARCHAR(10)
END
GO
IF COL_LENGTH('source_deal_detail_template', 'tiered') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_template ALTER COLUMN tiered NCHAR(1)
END
GO
IF COL_LENGTH('source_deal_detail_template', 'pricing_description') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_template ALTER COLUMN pricing_description NVARCHAR(500)
END
GO

IF NOT EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'source_deal_detail_template'
                   AND ccu.COLUMN_NAME = 'template_id'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu1
                   ON  tc.TABLE_NAME = ccu1.TABLE_NAME
                   AND tc.Constraint_name = ccu1.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'source_deal_detail_template'
                   AND ccu1.COLUMN_NAME = 'leg'
   )
BEGIN
    ALTER TABLE [dbo].source_deal_detail_template WITH NOCHECK ADD CONSTRAINT 
    [UC_source_deal_detail_template_template_id] UNIQUE(template_id, leg)
END
GO    
-- End source_deal_detail_template

-- Start deal_default_value

IF EXISTS (
    SELECT 1
    FROM sys.all_columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
    WHERE t.name = 'deal_default_value' AND c.name = 'create_user' AND s.name = 'dbo')
BEGIN
	DECLARE @def_deal_default_value NVARCHAR(100)
	SELECT @def_deal_default_value = d.name
    FROM sys.all_columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
    WHERE t.name = 'deal_default_value' AND c.name = 'create_user' AND s.name = 'dbo'

	EXEC('ALTER TABLE deal_default_value
	DROP CONSTRAINT ' + @def_deal_default_value)	
END
GO

IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_deal_default_value')
BEGIN
	ALTER TABLE deal_default_value DROP CONSTRAINT UC_deal_default_value
END

IF COL_LENGTH('deal_default_value', 'term_frequency') IS NOT NULL
BEGIN
    ALTER TABLE deal_default_value ALTER COLUMN term_frequency NCHAR(1)
END
GO
IF COL_LENGTH('deal_default_value', 'pay_opposite') IS NOT NULL
BEGIN
    ALTER TABLE deal_default_value ALTER COLUMN pay_opposite NCHAR(1)
END
GO
IF COL_LENGTH('deal_default_value', 'create_user') IS NOT NULL
BEGIN
    ALTER TABLE deal_default_value ALTER COLUMN create_user NVARCHAR(50)
	ALTER TABLE deal_default_value ADD CONSTRAINT DF_ddv_create_user DEFAULT [dbo].[FNADBUser]() FOR create_user
END
GO
IF COL_LENGTH('deal_default_value', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE deal_default_value ALTER COLUMN update_user NVARCHAR(50)
END
GO
IF COL_LENGTH('deal_default_value', 'physical_financial_flag') IS NOT NULL
BEGIN
    ALTER TABLE deal_default_value ALTER COLUMN physical_financial_flag NCHAR(1)
END
GO
IF COL_LENGTH('deal_default_value', 'buy_sell_flag') IS NOT NULL
BEGIN
    ALTER TABLE deal_default_value ALTER COLUMN buy_sell_flag NCHAR(1)
END
GO
IF COL_LENGTH('deal_default_value', 'upstream_contract') IS NOT NULL
BEGIN
    ALTER TABLE deal_default_value ALTER COLUMN upstream_contract NVARCHAR(500)
END
GO
IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_deal_default_value')
BEGIN
	ALTER TABLE deal_default_value
	ADD CONSTRAINT UC_deal_default_value UNIQUE (deal_type_id, pricing_type, commodity, buy_sell_flag)
END
-- End deal_default_value

-- Start delete_user_defined_deal_detail_fields

IF COL_LENGTH('delete_user_defined_deal_detail_fields', 'udf_value') IS NOT NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_detail_fields ALTER COLUMN udf_value NVARCHAR(MAX)
END
GO
IF COL_LENGTH('delete_user_defined_deal_detail_fields', 'create_user') IS NOT NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_detail_fields ALTER COLUMN create_user NVARCHAR(50)
END
GO
IF COL_LENGTH('delete_user_defined_deal_detail_fields', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_detail_fields ALTER COLUMN update_user NVARCHAR(50)
END
GO
IF COL_LENGTH('delete_user_defined_deal_detail_fields', 'receive_pay') IS NOT NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_detail_fields ALTER COLUMN receive_pay NCHAR(1)
END
GO
IF COL_LENGTH('delete_user_defined_deal_detail_fields', 'fixed_fx_rate') IS NOT NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_detail_fields ALTER COLUMN fixed_fx_rate NVARCHAR(50)
END
GO
-- End delete_user_defined_deal_detail_fields

-- Start delete_user_defined_deal_fields
IF COL_LENGTH('delete_user_defined_deal_fields', 'udf_value') IS NOT NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_fields ALTER COLUMN udf_value NVARCHAR(MAX)
END
GO
IF COL_LENGTH('delete_user_defined_deal_fields', 'create_user') IS NOT NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_fields ALTER COLUMN create_user NVARCHAR(50)
END
GO
IF COL_LENGTH('delete_user_defined_deal_fields', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_fields ALTER COLUMN update_user NVARCHAR(50)
END
GO
IF COL_LENGTH('delete_user_defined_deal_fields', 'receive_pay') IS NOT NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_fields ALTER COLUMN receive_pay NCHAR(1)
END
GO
IF COL_LENGTH('delete_user_defined_deal_fields', 'fixed_fx_rate') IS NOT NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_fields ALTER COLUMN fixed_fx_rate NVARCHAR(50)
END
GO
-- End delete_user_defined_deal_fields

-- Start user_defined_deal_detail_fields

IF COL_LENGTH('user_defined_deal_detail_fields', 'udf_value') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields ALTER COLUMN udf_value NVARCHAR(MAX)
END
GO
IF COL_LENGTH('user_defined_deal_detail_fields', 'create_user') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields ALTER COLUMN create_user NVARCHAR(50)
END
GO
IF COL_LENGTH('user_defined_deal_detail_fields', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields ALTER COLUMN update_user NVARCHAR(50)
END
GO
IF COL_LENGTH('user_defined_deal_detail_fields', 'receive_pay') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields ALTER COLUMN receive_pay NCHAR(1)
END
GO
IF COL_LENGTH('user_defined_deal_detail_fields', 'fixed_fx_rate') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields ALTER COLUMN fixed_fx_rate NVARCHAR(50)
END
GO
-- End user_defined_deal_detail_fields

-- Start user_defined_deal_detail_fields_audit
IF COL_LENGTH('user_defined_deal_detail_fields_audit', 'udf_value') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields_audit ALTER COLUMN udf_value NVARCHAR(MAX)
END
GO
IF COL_LENGTH('user_defined_deal_detail_fields_audit', 'create_user') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields_audit ALTER COLUMN create_user NVARCHAR(50)
END
GO
IF COL_LENGTH('user_defined_deal_detail_fields_audit', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields_audit ALTER COLUMN update_user NVARCHAR(50)
END
GO
IF COL_LENGTH('user_defined_deal_detail_fields_audit', 'user_action') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields_audit ALTER COLUMN user_action NVARCHAR(50)
END
GO
IF COL_LENGTH('user_defined_deal_detail_fields_audit', 'receive_pay') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields_audit ALTER COLUMN receive_pay NCHAR(1)
END
GO
IF COL_LENGTH('user_defined_deal_detail_fields_audit', 'fixed_fx_rate') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields_audit ALTER COLUMN fixed_fx_rate NVARCHAR(50)
END
GO
-- End user_defined_deal_detail_fields_audit


-- Start user_defined_deal_fields
IF COL_LENGTH('user_defined_deal_fields', 'udf_value') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_fields ALTER COLUMN udf_value NVARCHAR(MAX)
END
GO
IF COL_LENGTH('user_defined_deal_fields', 'create_user') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_fields ALTER COLUMN create_user NVARCHAR(50)
END
GO
IF COL_LENGTH('user_defined_deal_fields', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_fields ALTER COLUMN update_user NVARCHAR(50)
END
GO
IF COL_LENGTH('user_defined_deal_fields', 'receive_pay') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_fields ALTER COLUMN receive_pay NCHAR(1)
END
GO
IF COL_LENGTH('user_defined_deal_fields', 'fixed_fx_rate') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_fields ALTER COLUMN fixed_fx_rate NVARCHAR(50)
END
GO
-- End user_defined_deal_fields


-- Start user_defined_deal_fields_template_main
IF EXISTS (
    SELECT 1
    FROM sys.all_columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
    WHERE t.name = 'user_defined_deal_fields_template_main' AND c.name = 'udf_type' AND s.name = 'dbo')
BEGIN
	DECLARE @def_user_defined_deal_fields_template_main NVARCHAR(100)
	SELECT @def_user_defined_deal_fields_template_main = d.name
    FROM sys.all_columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
    WHERE t.name = 'user_defined_deal_fields_template_main' AND c.name = 'udf_type' AND s.name = 'dbo'

	EXEC('ALTER TABLE user_defined_deal_fields_template_main
	DROP CONSTRAINT ' + @def_user_defined_deal_fields_template_main)
	
END
GO

IF COL_LENGTH('user_defined_deal_fields_template_main', 'Field_label') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_fields_template_main ALTER COLUMN Field_label NVARCHAR(50)
END
GO
IF COL_LENGTH('user_defined_deal_fields_template_main', 'Field_type') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_fields_template_main ALTER COLUMN Field_type NVARCHAR(100)
END
GO
IF COL_LENGTH('user_defined_deal_fields_template_main', 'data_type') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_fields_template_main ALTER COLUMN data_type NVARCHAR(50)
END
GO
IF COL_LENGTH('user_defined_deal_fields_template_main', 'is_required') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_fields_template_main ALTER COLUMN is_required NCHAR(1)
END
GO
IF COL_LENGTH('user_defined_deal_fields_template_main', 'sql_string') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_fields_template_main ALTER COLUMN sql_string NVARCHAR(500)
END
GO
IF COL_LENGTH('user_defined_deal_fields_template_main', 'create_user') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_fields_template_main ALTER COLUMN create_user NVARCHAR(50)
END
GO
IF COL_LENGTH('user_defined_deal_fields_template_main', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_fields_template_main ALTER COLUMN update_user NVARCHAR(50)
END
GO
IF COL_LENGTH('user_defined_deal_fields_template_main', 'udf_type') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_fields_template_main ALTER COLUMN udf_type NCHAR(1)
	ALTER TABLE user_defined_deal_fields_template_main ADD CONSTRAINT DF__user_defi__udf_t__78EAF436 DEFAULT 'u' FOR udf_type
END
GO
IF COL_LENGTH('user_defined_deal_fields_template_main', 'default_value') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_fields_template_main ALTER COLUMN default_value NVARCHAR(500)
END
GO
IF COL_LENGTH('user_defined_deal_fields_template_main', 'udf_user_field_id') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_fields_template_main ALTER COLUMN udf_user_field_id NVARCHAR(50)
END
GO
IF COL_LENGTH('user_defined_deal_fields_template_main', 'deal_udf_type') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_deal_fields_template_main ALTER COLUMN deal_udf_type NCHAR(1)
END
GO

-- End user_defined_deal_fields_template_main

-- Start user_defined_fields_template
IF EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'user_defined_fields_template'     
                    AND ccu.COLUMN_NAME = 'Field_label'  
					AND tc.CONSTRAINT_NAME = 'UC_user_defined_fields_template_field_lable'
)
BEGIN
	ALTER TABLE dbo.user_defined_fields_template DROP CONSTRAINT [UC_user_defined_fields_template_field_lable]
END
GO

IF EXISTS (
    SELECT 1
    FROM sys.all_columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
    WHERE t.name = 'user_defined_fields_template' AND c.name = 'udf_type' AND s.name = 'dbo' AND d.name = 'DF_user_defined_fields_template_udf_type')
BEGIN
	ALTER TABLE user_defined_fields_template
	DROP CONSTRAINT DF_user_defined_fields_template_udf_type
END
GO

IF COL_LENGTH('user_defined_fields_template', 'Field_label') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_fields_template ALTER COLUMN Field_label NVARCHAR(50)
END
GO
IF COL_LENGTH('user_defined_fields_template', 'Field_type') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_fields_template ALTER COLUMN Field_type NVARCHAR(100)
END
GO
IF COL_LENGTH('user_defined_fields_template', 'data_type') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_fields_template ALTER COLUMN data_type NVARCHAR(50)
END
GO
IF COL_LENGTH('user_defined_fields_template', 'is_required') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_fields_template ALTER COLUMN is_required NCHAR(1)
END
GO
IF COL_LENGTH('user_defined_fields_template', 'sql_string') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_fields_template ALTER COLUMN sql_string NVARCHAR(1000)
END
GO
IF COL_LENGTH('user_defined_fields_template', 'create_user') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_fields_template ALTER COLUMN create_user NVARCHAR(50)
END
GO
IF COL_LENGTH('user_defined_fields_template', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_fields_template ALTER COLUMN update_user NVARCHAR(50)
END
GO
IF COL_LENGTH('user_defined_fields_template', 'udf_type') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_fields_template ALTER COLUMN udf_type NCHAR(1)
	ALTER TABLE user_defined_fields_template ADD CONSTRAINT DF_user_defined_fields_template_udf_type DEFAULT 'u' FOR udf_type	
END
GO
IF COL_LENGTH('user_defined_fields_template', 'default_value') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_fields_template ALTER COLUMN default_value NVARCHAR(500)
END
GO
IF COL_LENGTH('user_defined_fields_template', 'deal_udf_type') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_fields_template ALTER COLUMN deal_udf_type NCHAR(1)
END
GO
IF COL_LENGTH('user_defined_fields_template', 'include_in_credit_exposure') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_fields_template ALTER COLUMN include_in_credit_exposure NVARCHAR(1)
END
GO

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'user_defined_fields_template'     
                    AND ccu.COLUMN_NAME = 'Field_label'       
)
BEGIN
	ALTER TABLE [dbo].[user_defined_fields_template] WITH NOCHECK ADD CONSTRAINT [UC_user_defined_fields_template_field_lable] UNIQUE(Field_label,udf_type)
END
-- End user_defined_fields_template

-- Start user_defined_group_detail
IF COL_LENGTH('user_defined_group_detail', 'create_user') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_group_detail ALTER COLUMN create_user NVARCHAR(50)
END
GO
IF COL_LENGTH('user_defined_group_detail', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_group_detail ALTER COLUMN update_user NVARCHAR(50)
END
GO
-- End user_defined_group_detail

-- Start user_defined_group_header
IF COL_LENGTH('user_defined_group_header', 'user_defined_group_name') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_group_header ALTER COLUMN user_defined_group_name NVARCHAR(500)
END
GO
IF COL_LENGTH('user_defined_group_header', 'create_user') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_group_header ALTER COLUMN create_user NVARCHAR(50)
END
GO
IF COL_LENGTH('user_defined_group_header', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_group_header ALTER COLUMN update_user NVARCHAR(50)
END
GO
-- End user_defined_group_header

-- Start user_defined_tables
IF EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'user_defined_tables'
                   AND ccu.COLUMN_NAME = 'udt_name'            
   )
BEGIN
    ALTER TABLE [dbo].user_defined_tables DROP CONSTRAINT [UQ_udt_name] 
END
GO

IF EXISTS (
    SELECT 1
    FROM sys.all_columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
    WHERE t.name = 'user_defined_tables' AND c.name = 'create_user' AND s.name = 'dbo')
BEGIN
	DECLARE @def_user_defined_tables NVARCHAR(500)
	SELECT @def_user_defined_tables = d.name
    FROM sys.all_columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
    WHERE t.name = 'user_defined_tables' AND c.name = 'create_user' AND s.name = 'dbo'

	EXEC('ALTER TABLE user_defined_tables
	DROP CONSTRAINT ' + @def_user_defined_tables)
END
GO

IF COL_LENGTH('user_defined_tables', 'udt_name') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_tables ALTER COLUMN udt_name NVARCHAR(200)
END
GO
IF COL_LENGTH('user_defined_tables', 'udt_descriptions') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_tables ALTER COLUMN udt_descriptions NVARCHAR(200)
END
GO
IF COL_LENGTH('user_defined_tables', 'create_user') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_tables ALTER COLUMN create_user NVARCHAR(50)
	ALTER TABLE user_defined_tables ADD CONSTRAINT DF__user_defi__creat__453F9821 DEFAULT [dbo].[FNADBUser]() FOR create_user
END
GO
IF COL_LENGTH('user_defined_tables', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_tables ALTER COLUMN update_user NVARCHAR(50)
END
GO
IF COL_LENGTH('user_defined_tables', 'udt_hash') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_tables ALTER COLUMN udt_hash NVARCHAR(150)
END
GO

IF NOT EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'user_defined_tables'
                   AND ccu.COLUMN_NAME = 'udt_name'            
   )
BEGIN
    ALTER TABLE [dbo].user_defined_tables WITH NOCHECK ADD CONSTRAINT [UQ_udt_name] UNIQUE(udt_name)
END
GO

-- End user_defined_tables


-- Start user_defined_tables_metadata

IF EXISTS (
    SELECT 1
    FROM sys.all_columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
    WHERE t.name = 'user_defined_tables_metadata' AND c.name = 'create_user' AND s.name = 'dbo')
BEGIN
	DECLARE @def_user_defined_tables_metadata NVARCHAR(500)
	SELECT @def_user_defined_tables_metadata = d.name
    FROM sys.all_columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
    WHERE t.name = 'user_defined_tables_metadata' AND c.name = 'create_user' AND s.name = 'dbo'

	EXEC('ALTER TABLE user_defined_tables_metadata
	DROP CONSTRAINT ' + @def_user_defined_tables_metadata)
END
GO

IF COL_LENGTH('user_defined_tables_metadata', 'column_name') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_tables_metadata ALTER COLUMN column_name NVARCHAR(200)
END
GO
IF COL_LENGTH('user_defined_tables_metadata', 'column_descriptions') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_tables_metadata ALTER COLUMN column_descriptions NVARCHAR(500)
END
GO
IF COL_LENGTH('user_defined_tables_metadata', 'column_type') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_tables_metadata ALTER COLUMN column_type NVARCHAR(50)
END
GO
IF COL_LENGTH('user_defined_tables_metadata', 'column_nullable') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_tables_metadata ALTER COLUMN column_nullable NCHAR(3)
END
GO
IF COL_LENGTH('user_defined_tables_metadata', 'create_user') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_tables_metadata ALTER COLUMN create_user NVARCHAR(50)
	ALTER TABLE user_defined_tables_metadata ADD CONSTRAINT DF__user_defi__creat__49102905 DEFAULT [dbo].[FNADBUser]() FOR create_user
END
GO
IF COL_LENGTH('user_defined_tables_metadata', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_tables_metadata ALTER COLUMN update_user NVARCHAR(50)
END
GO
IF COL_LENGTH('user_defined_tables_metadata', 'udt_column_hash') IS NOT NULL
BEGIN
    ALTER TABLE user_defined_tables_metadata ALTER COLUMN udt_column_hash NVARCHAR(150)
END
GO

--END user_defined_tables_metadata

-- Start source_deal_groups

IF EXISTS (
    SELECT 1
    FROM sys.all_columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
    WHERE t.name = 'source_deal_groups' AND c.name = 'create_user' AND s.name = 'dbo')
BEGIN
	DECLARE @def_source_deal_groups NVARCHAR(500)
	SELECT @def_source_deal_groups = d.name
    FROM sys.all_columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
    WHERE t.name = 'source_deal_groups' AND c.name = 'create_user' AND s.name = 'dbo'

	EXEC('ALTER TABLE source_deal_groups
	DROP CONSTRAINT ' + @def_source_deal_groups)
END
GO

IF COL_LENGTH('source_deal_groups', 'source_deal_groups_name') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_groups ALTER COLUMN source_deal_groups_name NVARCHAR(100)
END
GO
IF COL_LENGTH('source_deal_groups', 'create_user') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_groups ALTER COLUMN create_user NVARCHAR(50)
	ALTER TABLE source_deal_groups ADD CONSTRAINT DF__source_de__creat__4F9E5E1D DEFAULT [dbo].[FNADBUser]() FOR create_user
END
GO
IF COL_LENGTH('source_deal_groups', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_groups ALTER COLUMN update_user NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_groups', 'static_group_name') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_groups ALTER COLUMN static_group_name NVARCHAR(200)
END
GO

-- End source_deal_groups

-- Start delete_source_deal_groups

IF EXISTS (
    SELECT 1
    FROM sys.all_columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
    WHERE t.name = 'delete_source_deal_groups' AND c.name = 'delete_user' AND s.name = 'dbo')
BEGIN
	DECLARE @def_del_source_deal_groups_del NVARCHAR(500)
	SELECT @def_del_source_deal_groups_del = d.name
    FROM sys.all_columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
    WHERE t.name = 'delete_source_deal_groups' AND c.name = 'delete_user' AND s.name = 'dbo'

	EXEC('ALTER TABLE delete_source_deal_groups
	DROP CONSTRAINT ' + @def_del_source_deal_groups_del)
END
GO

IF EXISTS (
    SELECT 1
    FROM sys.all_columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
    WHERE t.name = 'delete_source_deal_groups' AND c.name = 'create_user' AND s.name = 'dbo')
BEGIN
	DECLARE @def_del_source_deal_groups NVARCHAR(500)
	SELECT @def_del_source_deal_groups = d.name
    FROM sys.all_columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
    WHERE t.name = 'delete_source_deal_groups' AND c.name = 'create_user' AND s.name = 'dbo'

	EXEC('ALTER TABLE delete_source_deal_groups
	DROP CONSTRAINT ' + @def_del_source_deal_groups)
END
GO

IF COL_LENGTH('delete_source_deal_groups', 'static_group_name') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_groups ALTER COLUMN static_group_name NVARCHAR(200)
END
GO
IF COL_LENGTH('delete_source_deal_groups', 'delete_user') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_groups ALTER COLUMN delete_user NVARCHAR(50)
	ALTER TABLE delete_source_deal_groups ADD CONSTRAINT DF__delete_so__delet__357F64BE DEFAULT [dbo].[FNADBUser]() FOR delete_user	
END
GO
IF COL_LENGTH('delete_source_deal_groups', 'create_user') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_groups ALTER COLUMN create_user NVARCHAR(50)
	ALTER TABLE delete_source_deal_groups ADD CONSTRAINT DF__delete_so__creat__33971C4C DEFAULT [dbo].[FNADBUser]() FOR create_user	
END
GO
IF COL_LENGTH('delete_source_deal_groups', 'source_deal_groups_name') IS NOT NULL
BEGIN
    ALTER TABLE delete_source_deal_groups ALTER COLUMN source_deal_groups_name NVARCHAR(100)
END
GO
-- End delete_source_deal_groups

--Start deal_type_pricing_maping

IF EXISTS (
    SELECT 1
    FROM sys.all_columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
    WHERE t.name = 'deal_type_pricing_maping' AND c.name = 'create_user' AND s.name = 'dbo')
BEGIN
	DECLARE @def_deal_type_pricing_maping NVARCHAR(500)
	SELECT @def_deal_type_pricing_maping = d.name
    FROM sys.all_columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
    WHERE t.name = 'deal_type_pricing_maping' AND c.name = 'create_user' AND s.name = 'dbo'

	EXEC('ALTER TABLE deal_type_pricing_maping
	DROP CONSTRAINT ' + @def_deal_type_pricing_maping)
END
GO

IF COL_LENGTH('deal_type_pricing_maping', 'create_user') IS NOT NULL
BEGIN
    ALTER TABLE deal_type_pricing_maping ALTER COLUMN create_user NVARCHAR(50)
	ALTER TABLE deal_type_pricing_maping ADD CONSTRAINT DF__deal_type__creat__123BB7E2 DEFAULT [dbo].[FNADBUser]() FOR create_user	
END
GO
IF COL_LENGTH('deal_type_pricing_maping', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE deal_type_pricing_maping ALTER COLUMN update_user NVARCHAR(50)
END
GO

-- End deal_type_pricing_maping

-- Start source_deal_type
IF EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'source_deal_type'
                   AND ccu.COLUMN_NAME = 'source_system_id'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu1
                   ON  tc.TABLE_NAME = ccu1.TABLE_NAME
                   AND tc.Constraint_name = ccu1.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'source_deal_type'
                   AND ccu1.COLUMN_NAME = 'deal_type_id'
				   AND tc.CONSTRAINT_NAME = 'IX_source_deal_type'
   ) 
BEGIN
    ALTER TABLE [dbo].source_deal_type DROP CONSTRAINT IX_source_deal_type
END
GO    

IF EXISTS (
    SELECT 1
    FROM sys.all_columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
    WHERE t.name = 'source_deal_type' AND c.name = 'create_user' AND s.name = 'dbo')
BEGIN
	DECLARE @def_source_deal_type NVARCHAR(100)
	SELECT @def_source_deal_type = d.name
    FROM sys.all_columns c
    INNER JOIN sys.tables t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.default_constraints d ON c.default_object_id = d.object_id
    WHERE t.name = 'source_deal_type' AND c.name = 'create_user' AND s.name = 'dbo'

	EXEC('ALTER TABLE source_deal_type
	DROP CONSTRAINT ' + @def_source_deal_type)	
END
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_source_deal_type' AND object_id = OBJECT_ID('[source_deal_type]'))
BEGIN
	DROP INDEX IX_source_deal_type ON dbo.[source_deal_type]
END
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_source_deal_type_1' AND object_id = OBJECT_ID('[source_deal_type]'))
BEGIN
	DROP INDEX IX_source_deal_type_1 ON dbo.[source_deal_type]
END
GO

IF COL_LENGTH('source_deal_type', 'deal_type_id') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_type ALTER COLUMN deal_type_id NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_type', 'source_deal_type_name') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_type ALTER COLUMN source_deal_type_name NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_type', 'source_deal_desc') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_type ALTER COLUMN source_deal_desc NVARCHAR(50)
END
GO
IF COL_LENGTH('source_deal_type', 'sub_type') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_type ALTER COLUMN sub_type NVARCHAR(1)
END
GO
IF COL_LENGTH('source_deal_type', 'expiration_applies') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_type ALTER COLUMN expiration_applies NVARCHAR(1)
END
GO
IF COL_LENGTH('source_deal_type', 'disable_gui_groups') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_type ALTER COLUMN disable_gui_groups NVARCHAR(1)
END
GO
IF COL_LENGTH('source_deal_type', 'break_individual_deal') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_type ALTER COLUMN break_individual_deal NVARCHAR(1)
END
GO
IF COL_LENGTH('source_deal_type', 'seperate_rec_value_used') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_type ALTER COLUMN seperate_rec_value_used NVARCHAR(1)
END
GO
IF COL_LENGTH('source_deal_type', 'create_user') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_type ALTER COLUMN create_user NVARCHAR(50)
	ALTER TABLE source_deal_type ADD CONSTRAINT DF_sdt_create_user DEFAULT [dbo].[FNADBUser]() FOR create_user
END
GO
IF COL_LENGTH('source_deal_type', 'update_user') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_type ALTER COLUMN update_user NVARCHAR(50)
END
GO
IF NOT EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
                   ON  tc.TABLE_NAME = ccu.TABLE_NAME
                   AND tc.Constraint_name = ccu.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'source_deal_type'
                   AND ccu.COLUMN_NAME = 'source_system_id'
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu1
                   ON  tc.TABLE_NAME = ccu1.TABLE_NAME
                   AND tc.Constraint_name = ccu1.Constraint_name
                   AND tc.CONSTRAINT_TYPE = 'UNIQUE'
                   AND tc.Table_Name = 'source_deal_type'
                   AND ccu1.COLUMN_NAME = 'deal_type_id'
   )
BEGIN
    ALTER TABLE [dbo].source_deal_type WITH NOCHECK ADD CONSTRAINT IX_source_deal_type UNIQUE(source_system_id, deal_type_id)
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_source_deal_type' AND object_id = OBJECT_ID('[source_deal_type]'))
BEGIN
	CREATE UNIQUE INDEX IX_source_deal_type ON source_deal_type(source_system_id, deal_type_id)
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_source_deal_type_1' AND object_id = OBJECT_ID('[source_deal_type]'))
BEGIN
	CREATE UNIQUE INDEX IX_source_deal_type_1 ON source_deal_type(deal_type_id)
END
GO

-- End source_deal_type