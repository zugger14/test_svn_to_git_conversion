drop TRIGGER [dbo].[TRGINS_FAS_Source_deal_header]
GO
SET QUOTED_IDENTIFIER ON
GO



create TRIGGER [dbo].[TRGINS_FAS_Source_deal_header]
ON [dbo].[source_deal_header]
FOR INSERT
AS

INSERT INTO [source_deal_header_audit](
	[source_deal_header_id]
	,[source_system_id]
	,[deal_id]
	,[deal_date]
	,[ext_deal_id]
	,[physical_financial_flag]
	,[structured_deal_id]
	,[counterparty_id]
	,[entire_term_start]
	,[entire_term_end]
	,[source_deal_type_id]
	,[deal_sub_type_type_id]
	,[option_flag]
	,[option_type]
	,[option_excercise_type]
	,[source_system_book_id1]
	,[source_system_book_id2]
	,[source_system_book_id3]
	,[source_system_book_id4]
	,[description1]
	,[description2]
	,[description3]
	,[deal_category_value_id]
	,[trader_id]
	,[internal_deal_type_value_id]
	,[internal_deal_subtype_value_id]
	,[template_id]
	,[header_buy_sell_flag]
	,[broker_id]
	,[generator_id]
	,[status_value_id]
	,[status_date]
	,[assignment_type_value_id]
	,[compliance_year]
	,[state_value_id]
	,[assigned_date]
	,[assigned_by]
	,[generation_source]
	,[aggregate_environment]
	,[aggregate_envrionment_comment]
	,[rec_price]
	,[rec_formula_id]
	,[rolling_avg]
	,[contract_id]
	,[update_user]
	,[update_ts]
	,[legal_entity],
	[internal_desk_id],
	[product_id],
	[internal_portfolio_id],
	[commodity_id],
	[reference],
	[deal_locked],
	[close_reference_id],
	[block_type],
	[block_define_id],
	[granularity_id],
	[pricing],
	[verified_by],
	[verified_date],
	[user_action]
)
SELECT 
	[source_deal_header_id]
	,[source_system_id]
	,[deal_id]
	,[deal_date]
	,[ext_deal_id]
	,[physical_financial_flag]
	,[structured_deal_id]
	,[counterparty_id]
	,[entire_term_start]
	,[entire_term_end]
	,[source_deal_type_id]
	,[deal_sub_type_type_id]
	,[option_flag]
	,[option_type]
	,[option_excercise_type]
	,[source_system_book_id1]
	,[source_system_book_id2]
	,[source_system_book_id3]
	,[source_system_book_id4]
	,[description1]
	,[description2]
	,[description3]
	,[deal_category_value_id]
	,[trader_id]
	,[internal_deal_type_value_id]
	,[internal_deal_subtype_value_id]
	,[template_id]
	,[header_buy_sell_flag]
	,[broker_id]
	,[generator_id]
	,[status_value_id]
	,[status_date]
	,[assignment_type_value_id]
	,[compliance_year]
	,[state_value_id]
	,[assigned_date]
	,[assigned_by]
	,[generation_source]
	,[aggregate_environment]
	,[aggregate_envrionment_comment]
	,[rec_price]
	,[rec_formula_id]
	,[rolling_avg]
	,[contract_id]
	,dbo.FNADBUser()
	,getdate()
	,[legal_entity],
	[internal_desk_id],
	[product_id],
	[internal_portfolio_id],
	[commodity_id],
	[reference],
	[deal_locked],
	[close_reference_id],
	[block_type],
	[block_define_id],
	[granularity_id],
	[pricing],
	[verified_by],
	[verified_date],
	'Insert' 
FROM inserted




