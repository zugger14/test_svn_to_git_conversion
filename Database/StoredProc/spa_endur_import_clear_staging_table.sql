IF OBJECT_ID(N'dbo.spa_endur_import_clear_staging_table', N'P') IS NOT NULL
	DROP PROCEDURE dbo.spa_endur_import_clear_staging_table
GO

CREATE PROCEDURE dbo.spa_endur_import_clear_staging_table
	  @parse_type				INT --  deal : 5, mtm : 6, price : 4
AS


IF @parse_type = 5 -- deal
BEGIN
		-- create staging table for Endur Deal Import Interface. Since the table stores data for one session, it can be safely deleted before creating.
	IF OBJECT_ID(N'adiha_process.dbo.stage_deals_rwe_de', N'U') IS NOT NULL
		DROP TABLE adiha_process.dbo.stage_deals_rwe_de

	CREATE TABLE adiha_process.dbo.stage_deals_rwe_de (
			[type]							VARCHAR(10)
			, reference_code                VARCHAR(50)
			, tran_number                   VARCHAR(50)
			, offset_tran_num               VARCHAR(50)
			, trade_date                    VARCHAR(10)
			, [start_date]                  VARCHAR(10)
			, end_date                      VARCHAR(10)
			, trader_name                   VARCHAR(50)
			, trader_id                     VARCHAR(100)
			, int_portfolio				    VARCHAR(255)
			, portfolio_id                  VARCHAR(100)
			, ext_bunit                     VARCHAR(128)
			, counterparty_id	            VARCHAR(50)
			, counterparty_group			VARCHAR(50)
			, position						NUMERIC(38, 20)
			, buy_sell_flag                 VARCHAR(1)
			, maturity_date                 VARCHAR(10)
			, price                         NUMERIC(38, 20)
			, [status]	                    VARCHAR(1)
			, payment_date                  VARCHAR(10)
			, proj_index_name               VARCHAR(255)
			, proj_index_curve_id           VARCHAR(50)
			, proj_index_currency           VARCHAR(3)
			, proj_index_uom                VARCHAR(50)
			, proj_index_group_commodity    VARCHAR(255)
			, reporting_group_name          VARCHAR(4)
			, [contract]                    VARCHAR(100)
			, ccy                           VARCHAR(3)
			, param_seq_num                 INT
			, profile_seq_num               BIGINT
			, ins_type						VARCHAR(255)
			, ins_sub_type					VARCHAR(255)
			, fix_float						VARCHAR(1)
			, pay_rec                       VARCHAR(1)
			, deal_vol_type                 VARCHAR(1)
			, unit                          VARCHAR(50)
			, price_currency_id             VARCHAR(3)
			, broker_name                   VARCHAR(50)
			, int_legal                     VARCHAR(128)
			, int_bunit                     VARCHAR(255)
			, ext_legal                     VARCHAR(255)
			, ext_portfolio                 VARCHAR(255)
			, put_call						VARCHAR(10)
			, option_strike_price           NUMERIC(38, 20)
			, option_premium                NUMERIC(38, 20)
			, premium_settlement_date       VARCHAR(10)
			, reference                     VARCHAR(255)
			, ins_reference                 VARCHAR(50)
			, price_uom						VARCHAR(50)
			, [file_name]					VARCHAR(150)
			, folder_endur_or_user			CHAR(1)
			, file_type						VARCHAR(20)
			, file_as_of_date				VARCHAR(10)
			, file_timestamp				VARCHAR(20)
		)
		
END

ELSE IF @parse_type = 6 -- mtm
BEGIN
	IF OBJECT_ID(N'adiha_process.dbo.stage_mtm_rwe_de', N'U') IS NOT NULL
		DROP TABLE adiha_process.dbo.stage_mtm_rwe_de

	CREATE TABLE adiha_process.dbo.stage_mtm_rwe_de (
		deal_num						VARCHAR(50)
		, endur_run_date_for_files		VARCHAR(10)
		, profile_end_date				VARCHAR(10)
		, euro_side_currency			VARCHAR(3)
		, df_by_leg_result				FLOAT 
		, pv_df_by_leg_result			FLOAT
		, pv_from_mtm_detail_result		FLOAT 
		, [file_name]					VARCHAR(150)
		, folder_endur_or_user			CHAR(1)
		, file_type						VARCHAR(20)
		, file_as_of_date				VARCHAR(10)
		, file_timestamp				VARCHAR(20)
		, violation_file_level			CHAR(1)
		)
END

ELSE IF @parse_type = 4 -- price
BEGIN
	IF OBJECT_ID(N'adiha_process.dbo.stage_spc_rwe_de', N'U') IS NOT NULL
		DROP TABLE adiha_process.dbo.stage_spc_rwe_de

	CREATE TABLE adiha_process.dbo.stage_spc_rwe_de
		(
			proj_index_id					VARCHAR(50)
			, proj_index_name				VARCHAR(255)
			, endur_run_date_for_files		VARCHAR(10)
			, index_curve_date				VARCHAR(10)
			, curve_price					FLOAT
			, [file_name]					VARCHAR(150)
			, folder_endur_or_user			CHAR(1)
			, file_type						VARCHAR(20)
			, file_as_of_date				VARCHAR(10)
			, file_timestamp				VARCHAR(20)
			, violation_file_level			CHAR(1)	
		)
	
END