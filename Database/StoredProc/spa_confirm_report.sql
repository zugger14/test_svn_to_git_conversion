IF OBJECT_ID('[dbo].[spa_confirm_report]','p') IS NOT NULL
DROP PROC [dbo].[spa_confirm_report]
GO

--exec spa_confirm_report 's',72
CREATE PROC [dbo].[spa_confirm_report]
	@flag char(1),
	@confirm_id int
AS
SET NOCOUNT ON

if @flag = 's'
begin
	select 
		--date,
		as_of_date,
		trader,
		trade_date,
		trade_type,
		type,
		commodity,
		start_date,
		end_date,
		quantity,
		total_quantity,
		price_index,
		pricing_date,
		fixed_price,
		service_type,
		payment_frequency,
		settle_rules,
		holiday_calendar,
		external_trade_id,
		book,
		comments,
		counterparty_name,
		counterparty_address,
		counterparty_phone_no,
		counterparty_mailing_address,
		counterparty_fax_email,
		trade_confirmation_status,
		trade_confirmation_comment,
		nearby_month,
		roll_convention,
		trader_phone,
		trader_fax,
		trader_email,
		payment_dates,
		system_trade_id,
		input_by,
		premium_settlement_date,
		strike_price,
		premium,
		total_premium,
		input_date,
		verified_by_name,
		verified_date,
		user_login_id,
		location_name,
		broker_name,
		is_confirm,
		isnull(init_template,'confirm_template.php'),
		isnull(sub_template,'confirm_template_replacement.php'),
		cast(curve_definition AS VARCHAR(8000)) curve_definition,
		deal_volume_frequency
	from save_confirm_status
	where confirm_id = @confirm_id
end