SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGDEL_SOURCE_PRICE_CURVE_DEF]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGDEL_SOURCE_PRICE_CURVE_DEF]
GO

CREATE TRIGGER [dbo].[TRGDEL_SOURCE_PRICE_CURVE_DEF]
ON [dbo].source_price_curve_def
FOR  DELETE
AS
	INSERT INTO source_price_curve_def_audit
	  (
	    source_curve_def_id,
	    source_system_id,
	    curve_id,
	    curve_name,
	    curve_des,
	    commodity_id,
	    market_value_id,
	    market_value_desc,
	    source_currency_id,
	    source_currency_to_id,
	    source_curve_type_value_id,
	    uom_id,
	    proxy_source_curve_def_id,
	    formula_id,
	    obligation,
	    sort_order,
	    fv_level,
	    create_user,
	    create_ts,
	    update_user,
	    update_ts,
	    Granularity,
	    exp_calendar_id,
	    risk_bucket_id,
	    reference_curve_id,
	    monthly_index,
	    program_scope_value_id,
	    curve_definition,
	    block_type,
	    block_define_id,
	    index_group,
	    display_uom_id,
	    proxy_curve_id,
	    hourly_volume_allocation,
	    settlement_curve_id,
	    time_zone,
	    udf_block_group_id,
	    is_active,
	    ratio_option,
	    curve_tou,
	    proxy_curve_id3,
	    asofdate_current_month,
	    monte_carlo_model_parameter_id,
	    user_action
	  )
	SELECT source_curve_def_id,
	       source_system_id,
	       curve_id,
	       curve_name,
	       curve_des,
	       commodity_id,
	       market_value_id,
	       market_value_desc,
	       source_currency_id,
	       source_currency_to_id,
	       source_curve_type_value_id,
	       uom_id,
	       proxy_source_curve_def_id,
	       formula_id,
	       obligation,
	       sort_order,
	       fv_level,
	       create_user,
	       create_ts,
	       dbo.FNADBUser(),
	       GETDATE(),
	       Granularity,
	       exp_calendar_id,
	       risk_bucket_id,
	       reference_curve_id,
	       monthly_index,
	       program_scope_value_id,
	       curve_definition,
	       block_type,
	       block_define_id,
	       index_group,
	       display_uom_id,
	       proxy_curve_id,
	       hourly_volume_allocation,
	       settlement_curve_id,
	       time_zone,
	       udf_block_group_id,
	       is_active,
	       ratio_option,
	       curve_tou,
	       proxy_curve_id3,
	       asofdate_current_month,
	       monte_carlo_model_parameter_id,
	       'delete'
	FROM   DELETED


