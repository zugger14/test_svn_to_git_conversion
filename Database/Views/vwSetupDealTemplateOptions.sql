IF OBJECT_ID(N'[dbo].[vwSetupDealTemplateOptions]', N'V') IS NOT NULL
	DROP VIEW [dbo].[vwSetupDealTemplateOptions]
GO 

CREATE VIEW [dbo].[vwSetupDealTemplateOptions]
AS
	SELECT
		sdht.enable_provisional_tab,
		sdht.enable_pricing_tabs,
		sdht.enable_document_tab,
		sdht.enable_efp,
		sdht.enable_escalation_tab,
		sdht.enable_trigger,
		sdht.enable_exercise,
		sdht.ignore_bom,
		sdht.internal_flag,
		sdht.bid_n_ask_price,
		sdht.discounting_applies,
		sdht.certificate,
		sdht.term_rule,
		sdht.deal_date_rule,
		sdht.term_frequency_type,
		CASE WHEN sdht.attribute_type = 'a' THEN 45902 WHEN sdht.attribute_type = 'f' THEN 45901 ELSE '' END [attribute_type],
		sdht.options_calc_method,
		sdht.trade_ticket_template_id,
		sdht.hourly_position_breakdown,
		sdht.save_mtm_at_calculation_granularity,
		sdht.template_id,
		sdht.blotter_supported,
		sdht.[year],
		sdht.[month],
		mft.show_cost_tab,
		mft.show_detail_cost_tab,
		mft.show_udf_tab,
		sdht.split_positive_and_negative_commodity
	FROM source_deal_header_template sdht
	INNER JOIN maintain_field_template mft ON mft.field_template_id = sdht.field_template_id

GO