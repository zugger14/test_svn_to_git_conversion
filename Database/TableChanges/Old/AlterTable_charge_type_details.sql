IF COL_LENGTH('contract_charge_type_detail','template_id') IS  NULL
BEGIN
	ALTER TABLE contract_charge_type_detail ADD  template_id INT NULL
END
GO
IF COL_LENGTH('contract_charge_type_detail', 'pnl_date') IS NOT NULL
BEGIN
    ALTER TABLE [dbo].[contract_charge_type_detail]
	ALTER COLUMN pnl_date datetime NULL
END
GO
IF COL_LENGTH('contract_charge_type_detail', 'payment_calendar') IS NOT NULL
BEGIN
	ALTER TABLE [dbo].[contract_charge_type_detail]
	ALTER COLUMN payment_calendar datetime NULL
END
GO