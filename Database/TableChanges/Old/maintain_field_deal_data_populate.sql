	
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

SET IDENTITY_INSERT [dbo].[maintain_field_deal] ON;

IF EXISTS(SELECT 1 FROM maintain_field_deal mfd)
BEGIN
	DELETE FROM maintain_field_deal
END

BEGIN TRANSACTION
INSERT INTO [dbo].[maintain_field_deal]([field_deal_id], [field_id], [farrms_field_id], [default_label], [field_type], [data_type], [default_validation], [header_detail], [system_required], [sql_string], [field_size], [is_disable], [window_function_id], [is_hidden], [default_value], [insert_required], [data_flag], [update_required])
SELECT 1, 4, N'source_deal_header_id', N'ID', N't', N'int', NULL, N'h', N'y', NULL, 23, N'y', NULL, N'n', NULL, N'y', N'i', N'y' UNION ALL
SELECT 2, 5, N'source_system_id', N'Source System', N'd', N'int', NULL, N'h', N'y', N'SELECT source_system_id, source_system_name FROM source_system_description', 20, N'y', NULL, N'y', N'2', N'n', N'i', N'n' UNION ALL
SELECT 3, 6, N'deal_id', N'Reference ID', N't', N'varchar', NULL, N'h', N'y', NULL, 23, NULL, NULL, N'n', NULL, N'y', N'i', N'y' UNION ALL
SELECT 4, 7, N'deal_date', N'Deal Date', N'a', N'datetime', NULL, N'h', N'y', NULL, NULL, N'y', NULL, N'n', NULL, N'y', N'd', N'y' UNION ALL
SELECT 5, 8, N'ext_deal_id', N'Ext Deal ID', N't', N'varchar', NULL, N'h', NULL, NULL, 23, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 6, 9, N'physical_financial_flag', N'Physical/Financial', N'd', N'char', NULL, N'h', N'y', N'SELECT ''p'' code,''Physical'' Data UNION  SELECT ''f'' code,''Financial'' Data', 20, N'y', NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 7, 10, N'structured_deal_id', N'Structure ID', N't', N'varchar', NULL, N'h', N'y', NULL, 23, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 8, 11, N'counterparty_id', N'CounterParty', N'd', N'int', NULL, N'h', N'y', N'SELECT source_counterparty_id,counterparty_name FROM dbo.source_counterparty order by counterparty_name', 20, NULL, N'10101115', N'n', NULL, N'y', N'i', N'y' UNION ALL
SELECT 9, 12, N'entire_term_start', N'Deal Term Start', N'a', N'datetime', NULL, N'h', N'y', NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'd', N'n' UNION ALL
SELECT 10, 13, N'entire_term_end', N'Deal Term End', N'a', N'datetime', NULL, N'h', N'y', NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'd', N'n' UNION ALL
SELECT 11, 14, N'source_deal_type_id', N'Deal Type', N'd', N'int', NULL, N'h', N'y', N'exec spa_getsourcedealtype ''s''', NULL, NULL, NULL, N'y', N'31', N'n', N'i', N'n' UNION ALL
SELECT 12, 15, N'deal_sub_type_type_id', N'Sub Deal Type', N'd', N'int', NULL, N'h', N'y', N'exec spa_getsourcedealtype @flag=''s'',@sub_type=''y''', NULL, N'y', NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 13, 16, N'option_flag', N'Options', N'c', N'char', NULL, N'h', N'y', N'SELECT ''y'' code, ''Yes'' value UNION select ''n'',''No''', NULL, NULL, NULL, N'y', N'n', N'n', N'i', N'n' UNION ALL
SELECT 14, 17, N'option_type', N'Option Type', N'd', N'char', NULL, N'h', NULL, N'SELECT ''c'' code, ''Call'' value UNION select ''p'',''Put''', NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 15, 18, N'option_excercise_type', N'Excersice Type', N'd', N'char', NULL, N'h', NULL, N'exec spa_getExcerciseType', NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 16, 19, N'source_system_book_id1', N'Book1', N'd', N'int', NULL, N'h', N'y', N'SELECT source_book_id, source_book_name FROM dbo.source_book', 20, N'y', NULL, N'n', NULL, N'n', N'i', N'y' UNION ALL
SELECT 17, 20, N'source_system_book_id2', N'Book2', N'd', N'int', NULL, N'h', N'y', N'SELECT source_book_id, source_book_name FROM dbo.source_book', 20, N'y', NULL, N'n', NULL, N'n', N'i', N'y' UNION ALL
SELECT 18, 21, N'source_system_book_id3', N'Book3', N'd', N'int', NULL, N'h', N'y', N'SELECT source_book_id, source_book_name FROM dbo.source_book', 20, N'y', NULL, N'n', NULL, N'n', N'i', N'y' UNION ALL
SELECT 19, 22, N'source_system_book_id4', N'Book4', N'd', N'int', NULL, N'h', N'y', N'SELECT source_book_id, source_book_name FROM dbo.source_book', 20, N'y', NULL, N'n', NULL, N'n', N'i', N'y' UNION ALL
SELECT 20, 23, N'description1', N'Description1', N't', N'varchar', NULL, N'h', NULL, NULL, 23, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 21, 24, N'description2', N'Description2', N't', N'varchar', NULL, N'h', NULL, NULL, 23, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 22, 25, N'description3', N'Description 3', N't', N'varchar', NULL, N'h', NULL, NULL, 23, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 23, 26, N'deal_category_value_id', N'Category', N'd', N'int', NULL, N'h', N'y', N'SELECT value_id,code FROM dbo.static_data_value WHERE [type_id]=475', NULL, NULL, NULL, N'y', N'475', N'n', N'i', N'n' UNION ALL
SELECT 24, 27, N'trader_id', N'Trader', N'd', N'int', NULL, N'h', N'y', N'SELECT source_trader_id, trader_name FROM dbo.source_traders ORDER BY trader_name', NULL, N'y', N'10101144', N'n', NULL, N'y', N'i', N'y' UNION ALL
SELECT 25, 28, N'internal_deal_type_value_id', N'Internal Deal Type', N'd', N'int', NULL, N'h', NULL, N'exec spa_getinternaldealtype ''s''', NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 26, 29, N'internal_deal_subtype_value_id', N'Internal Deal Sub Type', N'd', N'int', NULL, N'h', NULL, N'exec spa_getinternaldealtype ''s''', NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 27, 30, N'template_id', N'Template', N'd', N'int', NULL, N'h', N'y', N'EXEC spa_getDealTemplate ''s'', NULL, NULL, NULL, NULL, NULL, NULL', NULL, N'y', N'10101400', N'n', NULL, N'n', N'i', N'y' UNION ALL
SELECT 28, 31, N'header_buy_sell_flag', N'Buy/Sell', N'd', N'varchar', NULL, N'h', N'y', N'SELECT ''s'' code, ''Sell'' value UNION select ''b'',''Buy''', NULL, NULL, NULL, N'n', NULL, N'y', N'i', N'y' UNION ALL
SELECT 29, 32, N'broker_id', N'Broker', N'd', N'int', NULL, N'h', NULL, N'SELECT source_broker_id, broker_name FROM dbo.source_brokers', NULL, N'y', N'10101111', N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 30, 33, N'generator_id', N'Generator ID', NULL, N'int', NULL, N'h', NULL, NULL, NULL, NULL, N'10161510', N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 31, 34, N'status_value_id', N'Status', NULL, N'int', NULL, N'h', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 32, 35, N'status_date', N'Status Date', N'a', N'datetime', NULL, N'h', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 33, 36, N'assignment_type_value_id', N'Assignment Type', NULL, N'int', NULL, N'h', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 34, 37, N'compliance_year', N'Compliance Year', N'd', N'int', NULL, N'h', NULL, N'EXEC spa_compliance_year', NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 35, 38, N'state_value_id', N'State Value', N'd', N'int', NULL, N'h', NULL, N'SELECT value_id,code FROM dbo.static_data_value WHERE type_id=10002', NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 36, 39, N'assigned_date', N'Assign Date', N'a', N'datetime', NULL, N'h', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 37, 40, N'assigned_by', N'Assigned by', N't', N'varchar', NULL, N'h', NULL, NULL, 23, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 38, 41, N'generation_source', N'Generation Source', N't', N'varchar', NULL, N'h', NULL, NULL, 23, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 39, 42, N'aggregate_environment', N'Aggregate Environment', NULL, N'varchar', NULL, N'h', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 40, 43, N'aggregate_envrionment_comment', N'Aggregate Comments', N't', N'varchar', NULL, N'h', NULL, NULL, 23, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 41, 44, N'rec_price', N'Rec Price', N't', N'float', NULL, N'h', NULL, NULL, 23, NULL, NULL, N'y', NULL, N'n', N'n', N'n' UNION ALL
SELECT 42, 45, N'rec_formula_id', N'Rec Formula', NULL, N'int', NULL, N'h', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 43, 46, N'rolling_avg', N'Rolling Avg', N'd', N'char', NULL, N'h', NULL, N'SELECT NULL Code,'''' Value UNION ALL SELECT ''q'',''Quaterly''  UNION ALL SELECT ''s'',''Semi-Annually'' UNION ALL select ''a'',''Annually''', NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 44, 47, N'contract_id', N'Contract', N'd', N'int', NULL, N'h', NULL, N'EXEC spa_source_contract_detail ''s''', NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 45, 48, N'create_user', N'Create By', N'l', N'varchar', NULL, N'h', NULL, NULL, NULL, NULL, NULL, N'n', NULL, N'n', N'i', N'y' UNION ALL
SELECT 46, 49, N'create_ts', N'Create TS', N'l', N'datetime', NULL, N'h', NULL, NULL, NULL, NULL, NULL, N'n', NULL, N'n', N'i', N'y' UNION ALL
SELECT 47, 50, N'update_user', N'Update By', N'l', N'varchar', NULL, N'h', NULL, NULL, NULL, NULL, NULL, N'n', NULL, N'n', N'i', N'y' UNION ALL
SELECT 48, 51, N'update_ts', N'Update TS', N'l', N'datetime', NULL, N'h', NULL, NULL, NULL, NULL, NULL, N'n', NULL, N'n', N'i', N'y' UNION ALL
SELECT 49, 52, N'legal_entity', N'Legal Entity', N'd', N'int', NULL, N'h', NULL, N'EXEC spa_source_legal_entity_maintain ''s''', NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 50, 53, N'internal_desk_id', N'Profile', N'd', N'int', NULL, N'h', NULL, N'SELECT value_id,code FROM dbo.static_data_value WHERE [type_id]=17300', NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n'
COMMIT;
RAISERROR (N'[dbo].[maintain_field_deal]: Insert Batch: 1.....Done!', 10, 1) WITH NOWAIT;
GO

BEGIN TRANSACTION
INSERT INTO [dbo].[maintain_field_deal]([field_deal_id], [field_id], [farrms_field_id], [default_label], [field_type], [data_type], [default_validation], [header_detail], [system_required], [sql_string], [field_size], [is_disable], [window_function_id], [is_hidden], [default_value], [insert_required], [data_flag], [update_required])
SELECT 51, 54, N'product_id', N'Fixation', N'd', N'int', NULL, N'h', NULL, N'SELECT value_id,code FROM dbo.static_data_value WHERE type_id=4100', NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 52, 55, N'internal_portfolio_id', N'Internal Portfolio', N'd', N'int', NULL, N'h', NULL, N'EXEC spa_source_internal_portfolio ''s''', NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 53, 56, N'commodity_id', N'Commodity', N'd', N'int', NULL, N'h', NULL, N'EXEC spa_source_commodity_maintain ''s''', NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 54, 57, N'reference', N'Reference', NULL, N'varchar', NULL, N'h', NULL, NULL, 20, N'y', NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 55, 58, N'deal_locked', N'Deal Lock', N'c', N'char', NULL, N'h', NULL, N'SELECT ''y'' code, ''Yes'' value UNION select ''n'',''No''', NULL, NULL, NULL, N'n', NULL, N'n', N'i', N'y' UNION ALL
SELECT 56, 59, N'close_reference_id', N'Reference Deal', N't', N'int', NULL, N'h', NULL, NULL, 23, NULL, N'10131010', N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 57, 60, N'block_type', N'Block Type', NULL, N'int', NULL, N'h', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 58, 61, N'block_define_id', N'Block Definition', N'd', N'int', NULL, N'h', NULL, N'SELECT value_id,code FROM dbo.static_data_value WHERE [type_id]=10018', NULL, NULL, N'10101024', N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 59, 62, N'granularity_id', N'Granularity', N'd', N'int', NULL, N'h', NULL, N'SELECT value_id,DESCRIPTION FROM static_data_value WHERE TYPE_ID = 978', NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 60, 63, N'pricing', N'Pricing', N'd', N'int', NULL, N'h', NULL, N'SELECT value_id,code FROM dbo.static_data_value WHERE type_id=1600', NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 61, 64, N'deal_reference_type_id', N'Deal Ref Type', N't', N'int', NULL, N'h', NULL, NULL, 23, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 62, 65, N'unit_fixed_flag', N'Unit Fixed Flag', N't', N'char', NULL, N'h', NULL, NULL, 23, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 63, 66, N'broker_unit_fees', N'Broker Unit Fee', N't', N'float', NULL, N'h', NULL, NULL, 23, NULL, NULL, N'y', NULL, N'n', N'n', N'n' UNION ALL
SELECT 64, 67, N'broker_fixed_cost', N'Broker Cost', N't', N'float', NULL, N'h', NULL, NULL, 23, NULL, NULL, N'y', NULL, N'n', N'n', N'n' UNION ALL
SELECT 65, 68, N'broker_currency_id', N'Broker Currency', N'd', N'int', NULL, N'h', NULL, N'SELECT source_currency_id, currency_name FROM dbo.source_currency', NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 66, 69, N'deal_status', N'Deal Status', N'd', N'int', NULL, N'h', NULL, N'SELECT value_id,code FROM dbo.static_data_value WHERE [type_id]=5600', NULL, NULL, NULL, N'n', NULL, N'n', N'i', N'y' UNION ALL
SELECT 67, 70, N'term_frequency', N'Term Frequency', N'd', N'char', NULL, N'h', NULL, N'SELECT  ''m'' id,''Monthly'' val UNION SELECT ''q'', ''Quarterly'' UNION SELECT ''h'',''Hourly'' UNION SELECT ''s'',''Semi-Annually'' UNION SELECT ''a'', ''Annually'' UNION SELECT ''d'', ''Daily''', NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 68, 71, N'option_settlement_date', N'Option Sett.Date', N'a', N'datetime', NULL, N'h', NULL, NULL, NULL, NULL, NULL, N'n', NULL, N'n', N'i', N'y' UNION ALL
SELECT 69, 72, N'verified_by', N'Verified by', N't', N'varchar', NULL, N'h', NULL, NULL, 23, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 70, 73, N'verified_date', N'Verified Date', N'a', N'datetime', NULL, N'h', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 71, 74, N'risk_sign_off_by', N'Risk Sign-off', N't', N'varchar', NULL, N'h', NULL, NULL, 23, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 72, 75, N'risk_sign_off_date', N'Risk Sign-off Date', N'a', N'datetime', NULL, N'h', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 73, 76, N'back_office_sign_off_by', N'Backoff Sign-off', N't', N'varchar', NULL, N'h', NULL, NULL, 23, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 74, 77, N'back_office_sign_off_date', N'Backoff Sign-off Date', N'a', N'datetime', NULL, N'h', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 75, 78, N'book_transfer_id', N'Book Transfer', N't', N'int', NULL, N'h', NULL, NULL, 23, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 76, 79, N'confirm_status_type', N'Confirm Status', N'd', N'int', NULL, N'h', NULL, N'SELECT value_id,code FROM dbo.static_data_value WHERE TYPE_ID=17200', NULL, N'y', N'10171010', N'n', NULL, N'n', N'i', N'y' UNION ALL
SELECT 77, 80, N'source_deal_detail_id', N'ID', N't', N'int', NULL, N'd', N'y', NULL, NULL, N'y', NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 78, 81, N'source_deal_header_id', N'Deal ID', N't', N'int', NULL, N'd', NULL, NULL, NULL, N'y', NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 79, 82, N'term_start', N'Term Start', N'a', N'datetime', NULL, N'd', N'y', N'Select value_id, code FROM static_data_value where type_id = 19300', NULL, N'y', NULL, N'n', NULL, N'y', N'd', N'y' UNION ALL
SELECT 80, 83, N'term_end', N'Term End', N'a', N'datetime', NULL, N'd', N'y', N'Select value_id, code FROM static_data_value where type_id = 19300', NULL, N'y', NULL, N'n', NULL, N'y', N'd', N'y' UNION ALL
SELECT 81, 84, N'Leg', N'Leg', N't', N'int', NULL, N'd', N'y', NULL, NULL, N'y', NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 82, 85, N'contract_expiration_date', N'Expire Date', N'a', N'datetime', NULL, N'd', N'y', NULL, NULL, NULL, NULL, N'n', NULL, N'y', N'i', N'y' UNION ALL
SELECT 83, 86, N'fixed_float_leg', N'Fixed/Float', N'd', N'char', NULL, N'd', N'y', N'SELECT ''f'' code,''Fixed'' value UNION ALL select ''t'',''Float''', NULL, NULL, NULL, N'y', N't', N'n', N'i', N'n' UNION ALL
SELECT 84, 87, N'buy_sell_flag', N'Buy/Sell', N'd', N'char', NULL, N'd', N'y', N'SELECT ''s'' code, ''Sell'' value UNION select ''b'',''Buy''', NULL, N'y', NULL, N'n', NULL, N'y', N'i', N'y' UNION ALL
SELECT 85, 88, N'curve_id', N'Curve ID', N'f', N'int', NULL, N'd', N'y', N'SELECT source_curve_def_id,curve_name FROM source_price_curve_def', NULL, NULL, N'10102610', N'n', NULL, N'y', N'i', N'y' UNION ALL
SELECT 86, 89, N'fixed_price', N'Fixed Price', N't', N'numeric', NULL, N'd', N'y', NULL, NULL, NULL, NULL, N'n', NULL, N'y', N'n', N'y' UNION ALL
SELECT 87, 90, N'fixed_price_currency_id', N'Fixed Price Currency', N'd', N'int', NULL, N'd', NULL, N'SELECT source_currency_id, currency_name FROM dbo.source_currency', NULL, NULL, NULL, N'n', NULL, N'y', N'i', N'y' UNION ALL
SELECT 88, 91, N'option_strike_price', N'Option Strike Price', N't', N'numeric', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'n', N'n' UNION ALL
SELECT 89, 92, N'deal_volume', N'Deal Volume', N't', N'numeric', NULL, N'd', N'y', NULL, NULL, NULL, NULL, N'n', NULL, N'y', N'n', N'y' UNION ALL
SELECT 90, 93, N'deal_volume_frequency', N'Volume Frequency', N'd', N'char', NULL, N'd', N'y', N'EXEC  spa_getVolumeFrequency NULL,NULL', NULL, NULL, NULL, N'n', NULL, N'y', N'i', N'y' UNION ALL
SELECT 91, 94, N'deal_volume_uom_id', N'Volume UOM', N'd', N'int', NULL, N'd', N'y', N'exec spa_getsourceuom @flag=''s''', NULL, NULL, NULL, N'n', NULL, N'y', N'i', N'y' UNION ALL
SELECT 92, 95, N'block_description', N'Block Description', NULL, N'varchar', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 93, 96, N'deal_detail_description', N'Detail Description', N't', N'varchar', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 94, 97, N'formula_id', N'Formula ID', N'w', NULL, NULL, N'd', NULL, N'SELECT fe.formula_id,dbo.FNAFormulaFormat(fe.formula,''r'') AS [Formula] FROM formula_nested fn INNER JOIN formula_editor fe ON fn.formula_id = fe.formula_id WHERE fe.istemplate =''y''', NULL, NULL, NULL, N'n', NULL, N'y', N'i', N'y' UNION ALL
SELECT 95, 98, N'volume_left', N'Volume Left', NULL, N'float', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'n', N'n' UNION ALL
SELECT 96, 99, N'settlement_volume', N'Settlement Volume', N't', N'float', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'n', N'n' UNION ALL
SELECT 97, 100, N'settlement_uom', N'Settlement UOM', N'd', N'int', NULL, N'd', NULL, N'exec spa_getsourceuom @flag=''s''', NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 98, 101, N'create_user', N'Create User', N'l', N'varchar', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'n', NULL, N'n', N'i', N'y' UNION ALL
SELECT 99, 102, N'create_ts', N'Create TS', N'l', N'datetime', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'n', NULL, N'n', N'i', N'y' UNION ALL
SELECT 100, 103, N'update_user', N'Update User', N'l', N'varchar', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'n', NULL, N'n', N'i', N'y'
COMMIT
RAISERROR (N'[dbo].[maintain_field_deal]: Insert Batch: 2.....Done!', 10, 1) WITH NOWAIT
GO

BEGIN TRANSACTION;
INSERT INTO [dbo].[maintain_field_deal]([field_deal_id], [field_id], [farrms_field_id], [default_label], [field_type], [data_type], [default_validation], [header_detail], [system_required], [sql_string], [field_size], [is_disable], [window_function_id], [is_hidden], [default_value], [insert_required], [data_flag], [update_required])
SELECT 101, 104, N'update_ts', N'Update TS', N'l', N'datetime', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'n', NULL, N'n', N'i', N'y' UNION ALL
SELECT 102, 105, N'price_adder', N'Price Adder', N't', N'numeric', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'n', N'n' UNION ALL
SELECT 103, 106, N'price_multiplier', N'Price Multiplier', N't', N'numeric', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'n', N'n' UNION ALL
SELECT 104, 107, N'settlement_date', N'Settlement Date', N'a', N'datetime', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 105, 108, N'day_count_id', N'Day Count', N't', N'int', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'n', N'n' UNION ALL
--SELECT 106, 109, N'location_id', N'Location', N'f', N'int', NULL, N'd', N'y', N'SELECT%20source_minor_location_id%2Clocation_name%20%3D%20CASE%20WHEN%20SMLL.source_major_location_ID%20is%20null%20THEN%20%27%27%20ELSE%20SMLL.location_name%20%2B%20%27-%3E%27%20END%20%2B%20sml.%5Blocation_name%5D%20FROM%20source_minor_location%20sml%20LEFT%20OUTER%20JOIN%20source_major_location%20SMLL%20ON%20SMLL.source_major_location_ID%20%3D%20sml.source_major_location_ID%20where%20sml.is_active%20%3D%20%27y%27', NULL, NULL, N'10102510', N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 106, 109, N'location_id', N'Location', N'f', N'int', NULL, N'd', N'y', N'SELECT sml.[source_minor_location_ID] AS value_id,CASE WHEN sml2.location_name IS NULL THEN sml.[Location_Name] ELSE sml2.location_name + '' >> '' + sml.[Location_Name] END FROM   [dbo].source_minor_location sml LEFT JOIN source_major_location sml2 ON sml2.source_major_location_ID = sml.source_major_location_ID where sml.is_active = ''y''', NULL, NULL, N'10102510', N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 107, 110, N'meter_id', N'Meter', N'f', N'int', NULL, N'd', NULL, N'SELECT  meter_id,recorderid FROM    meter_id', NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 108, 111, N'physical_financial_flag', N'Physical/Financial', N'd', N'char', NULL, N'd', N'y', N'SELECT ''p'' code,''Physical'' Data UNION  SELECT ''f'' code,''Financial'' Data', NULL, NULL, NULL, N'n', NULL, N'y', N'i', N'y' UNION ALL
SELECT 109, 112, N'Booked', N'Booked', N't', N'char', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 110, 113, N'process_deal_status', N'Process Deal Status', N't', N'int', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 111, 114, N'fixed_cost', N'Fixed Cost', N't', N'numeric', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'n', NULL, N'y', N'n', N'y' UNION ALL
SELECT 112, 115, N'multiplier', N'multiplier', N't', N'numeric', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'n', N'n' UNION ALL
SELECT 113, 116, N'adder_currency_id', N'Adder Currency', N'd', N'int', NULL, N'd', NULL, N'SELECT source_currency_id, currency_name FROM dbo.source_currency', NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 114, 117, N'fixed_cost_currency_id', N'Fixed Cost Currency', N'd', N'int', NULL, N'd', NULL, N'SELECT source_currency_id, currency_name FROM dbo.source_currency', NULL, NULL, NULL, N'n', NULL, N'y', N'i', N'y' UNION ALL
SELECT 115, 118, N'formula_currency_id', N'Formula Currency', N'd', N'int', NULL, N'd', NULL, N'SELECT source_currency_id, currency_name FROM dbo.source_currency', NULL, NULL, NULL, N'n', NULL, N'y', N'i', N'y' UNION ALL
SELECT 116, 119, N'price_adder2', N'Price Adder2', N't', N'numeric', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'n', N'n' UNION ALL
SELECT 117, 120, N'price_adder_currency2', N'Price Adder Currency2', N'd', N'int', NULL, N'd', NULL, N'SELECT source_currency_id, currency_name FROM dbo.source_currency', NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 118, 121, N'volume_multiplier2', N'Volume Multiplier2', N't', N'numeric', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'n', N'n' UNION ALL
SELECT 119, 122, N'total_volume', N'Total Volume', N't', N'numeric', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'n', NULL, N'n', N'n', N'y' UNION ALL
SELECT 120, 123, N'pay_opposite', N'Pay Opposite', NULL, N'varchar', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'y', N'y', N'n', N'i', N'n' UNION ALL
SELECT 121, 124, N'capacity', N'Capacity', N't', N'numeric', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'n', N'n' UNION ALL
SELECT 122, 125, N'settlement_currency', N'Settlement Currency', N'd', N'int', NULL, N'd', NULL, N'SELECT source_currency_id, currency_name FROM dbo.source_currency', NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 123, 126, N'standard_yearly_volume', N'Standard Yearly Volume', NULL, N'float', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'n', N'n' UNION ALL
--SELECT 124, 127, N'formula_curve_id', N'Formula Curve', NULL, N'int', NULL, N'd', NULL, NULL, NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 125, 128, N'price_uom_id', N'Price UOM', N'd', N'int', NULL, N'd', NULL, N'exec spa_getsourceuom @flag=''s''', NULL, NULL, NULL, N'n', NULL, N'y', N'i', N'y' UNION ALL
SELECT 126, 129, N'category', N'Category', N'd', N'int', NULL, N'd', NULL, N'exec spa_staticDataValues ''b'',10101', NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 127, 130, N'profile_code', N'Profile Code', N'd', N'int', NULL, N'd', NULL, N'exec spa_staticDataValues @flag=''b'',@type_id=18200', NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL
SELECT 128, 131, N'pv_party', N'PV Party', N'd', N'int', NULL, N'd', NULL, N'exec spa_staticDataValues @flag=''b'',@type_id=18300', NULL, NULL, NULL, N'y', NULL, N'n', N'i', N'n' UNION ALL 
SELECT 129, 3, N'sub_book', N'Sub Book', N'd', N'int', NULL, N'h', N'y', N'exec spa_get_source_book_map @flag=''s'',@function_id=10131000', 20, NULL, NULL, N'n', NULL, N'y', N'i', N'y'
COMMIT;
RAISERROR (N'[dbo].[maintain_field_deal]: Insert Batch: 3.....Done!', 10, 1) WITH NOWAIT;

GO

SET IDENTITY_INSERT [dbo].[maintain_field_deal] OFF;

