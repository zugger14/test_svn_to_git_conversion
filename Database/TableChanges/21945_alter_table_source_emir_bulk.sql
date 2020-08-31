BEGIN TRY
	BEGIN TRANSACTION
	IF COL_LENGTH (N'source_emir', N'nature_of_reporting_cpty') IS NULL
		ALTER TABLE dbo.source_emir ADD nature_of_reporting_cpty VARCHAR(100) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'nature_of_reporting_cpty2') IS NULL
		ALTER TABLE dbo.source_emir ADD nature_of_reporting_cpty2 VARCHAR (100) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'corporate_sector2') IS NULL
		ALTER TABLE dbo.source_emir ADD corporate_sector2 VARCHAR (10) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'is_financial_cpty') IS NOT NULL
		ALTER TABLE dbo.source_emir DROP COLUMN is_financial_cpty

	IF COL_LENGTH (N'source_emir', N'corporate_sector') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN corporate_sector VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'trading_capacity') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN trading_capacity VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'counterparty_side') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN counterparty_side VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'commercial_or_treasury') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN commercial_or_treasury VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'clearing_threshold') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN clearing_threshold VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'contarct_mtm_currency') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN contarct_mtm_currency VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'valuation_type') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN valuation_type VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'collateralization') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN collateralization VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'collateral_portfolio') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN collateral_portfolio VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'collateral_portfolio_code') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN collateral_portfolio_code VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'initial_margin_posted_currency') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN initial_margin_posted_currency VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'variation_margin_posted_currency') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN variation_margin_posted_currency VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'initial_margin_received_currency') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN initial_margin_received_currency VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'variation_margins_received_currency') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN variation_margins_received_currency VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'excess_collateral_posted_currency') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN excess_collateral_posted_currency VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'excess_collateral_received_currency') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN excess_collateral_received_currency VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'product_classification_type') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN product_classification_type VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'product_classification') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN product_classification VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'product_identification_type') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN product_identification_type VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'product_identification') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN product_identification VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'notional_currency_1') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN notional_currency_1 VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'notional_currency_2') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN notional_currency_2 VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'derivable_currency') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN derivable_currency VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'exec_venue') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN exec_venue VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'compression') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN compression VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'price_notation') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN price_notation VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'price_currency') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN price_currency VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'delivery_type') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN delivery_type VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'aggreement_version') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN aggreement_version VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'clearing_obligation') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN clearing_obligation VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'cleared') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN cleared VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'intra_group') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN intra_group VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'fixed_rate_payment_feq_time_leg_1') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN fixed_rate_payment_feq_time_leg_1 VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'fixed_rate_payment_feq_mult_leg_1') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN fixed_rate_payment_feq_mult_leg_1 VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'fixed_rate_payment_feq_time_leg_2') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN fixed_rate_payment_feq_time_leg_2 VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'fixed_rate_payment_feq_mult_leg_2') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN fixed_rate_payment_feq_mult_leg_2 VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'float_rate_payment_feq_time_leg_1') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN float_rate_payment_feq_time_leg_1 VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'float_rate_payment_feq_mult_leg_1') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN float_rate_payment_feq_mult_leg_1 VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'float_rate_payment_feq_time_leg_2') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN float_rate_payment_feq_time_leg_2 VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'float_rate_payment_feq_mult_leg_2') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN float_rate_payment_feq_mult_leg_2 VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'float_rate_reset_freq_leg_1_time') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN float_rate_reset_freq_leg_1_time VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'float_rate_reset_freq_leg_1_mult') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN float_rate_reset_freq_leg_1_mult VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'float_rate_reset_freq_leg_2_time') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN float_rate_reset_freq_leg_2_time VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'float_rate_reset_freq_leg_2_mult') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN float_rate_reset_freq_leg_2_mult VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'float_rate_ref_period_leg_1_time') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN float_rate_ref_period_leg_1_time VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'float_rate_ref_period_leg_2_time') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN float_rate_ref_period_leg_2_time VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'delivery_currency_2') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN delivery_currency_2 VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'commodity_base') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN commodity_base VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'load_type') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN load_type VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'duration') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN duration VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'option_type') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN option_type VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'option_style') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN option_style VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'strike_price_notation') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN strike_price_notation VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'seniority') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN seniority VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'frequency_of_payment') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN frequency_of_payment VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'tranche') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN tranche VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'action_type') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN action_type VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	IF COL_LENGTH (N'source_emir', N'level') IS NOT NULL
		ALTER TABLE dbo.source_emir ALTER COLUMN level VARCHAR (20) COLLATE DATABASE_DEFAULT NULL

	COMMIT
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 1
		ROLLBACK
	DECLARE @err VARCHAR(5000)
	PRINT @err
END CATCH