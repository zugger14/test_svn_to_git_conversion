SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGDEL_CONTRACT_GROUP_DETAIL]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGDEL_CONTRACT_GROUP_DETAIL]
GO

CREATE TRIGGER [dbo].[TRGDEL_CONTRACT_GROUP_DETAIL]
ON [dbo].[contract_group_detail]
FOR  DELETE
AS

	INSERT INTO contract_group_detail_audit
	(
		ID,
		contract_id,
		invoice_line_item_id,
		default_gl_id,
		price,
		formula_id,
		[manual],
		currency,
		Prod_type,
		sequence_order,
		create_user,
		create_ts,
		update_user,
		update_ts,
		inventory_item,
		class_name,
		increment_peaking_name,
		product_type_name,
		rate_description,
		units_for_rate,
		begin_date,
		end_date,
		default_gl_id_estimates,
		eqr_product_name,
		group_by,
		alias,
		hideInInvoice,
		int_begin_month,
		int_end_month,
		volume_granularity,
		deal_type,
		time_bucket_formula_id,
		calc_aggregation,
		payment_date,
		payment_calendar,
		pnl_date,
		pnl_calendar,
		timeofuse,
		include_charges,
		user_action
	)
	SELECT
		ID,
		contract_id,
		invoice_line_item_id,
		default_gl_id,
		price,
		formula_id,
		[manual],
		currency,
		Prod_type,
		sequence_order,
		create_user,
		create_ts,
		dbo.FNADBUser(),
		GETDATE(),
		inventory_item,
		class_name,
		increment_peaking_name,
		product_type_name,
		rate_description,
		units_for_rate,
		begin_date,
		end_date,
		default_gl_id_estimates,
		eqr_product_name,
		group_by,
		alias,
		hideInInvoice,
		int_begin_month,
		int_end_month,
		volume_granularity,
		deal_type,
		time_bucket_formula_id,
		calc_aggregation,
		payment_date,
		payment_calendar,
		pnl_date,
		pnl_calendar,
		timeofuse,
		include_charges, 
		'delete' 
	FROM DELETED


