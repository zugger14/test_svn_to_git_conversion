IF OBJECT_ID(N'[dbo].[spa_stmt_account_code_mapping]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_stmt_account_code_mapping]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: srranjitkar@pioneersolutionsglobal.com
-- Create date: 2018-11-20
-- Description: Select operations for Account Code Mapping UI
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- @code_mapping_id INT - Send account code mapping ID.
-- @acc_code_chargetype_id INT - Send chargetype ID.
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_stmt_account_code_mapping]
    @flag VARCHAR(40),
	@code_mapping_id INT = NULL,
	@acc_code_chargetype_id INT = NULL
AS
 
DECLARE @SQL VARCHAR(MAX)
 
IF @flag = 'main_grid'
BEGIN
    --SELECT ALL ROWS FROM THE TABLE
	SELECT acm.stmt_account_code_mapping_id,
		acm.account_code_group_name,
		CASE WHEN acm.buy_sell_flag = 'b' THEN 'Buy' WHEN acm.buy_sell_flag = 's' THEN 'Sell' ELSE '' END [buy_sell_flag],
		sdt.deal_type_id [source_deal_type_id],
		sdt_sub.deal_type_id [source_deal_sub_type_id],
		sc.commodity_id,
		sml.location_id,
		smagl.location_name location_group,
		sdht.template_name [template],
		scr.currency_id,
		cgrp.contract_name,
		CASE 
			WHEN acm.counterparty_type = 'i' THEN 'Internal'
			WHEN acm.counterparty_type = 'e' THEN 'External'
			WHEN acm.counterparty_type = 'b' THEN 'Broker'
			WHEN acm.counterparty_type = 'c' THEN 'Clearing'
			ELSE ''
		END [counterparty_type],
		sdv_cet.code [counterparty_entity_type],
		sdv_rgn.code [region],
		acm.[priority] [priority]
		FROM stmt_account_code_mapping acm
	LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = acm.source_deal_type_id
	LEFT JOIN source_deal_type sdt_sub ON sdt_sub.source_deal_type_id = acm.source_deal_sub_type_id
	LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = acm.location_id
	LEFT JOIN source_commodity sc ON sc.source_commodity_id = acm.commodity_id
	LEFT JOIN source_major_location smagl ON smagl.source_major_location_id = acm.location_group_id
	LEFT JOIN source_deal_header_template sdht ON sdht.template_id = acm.template_id
	LEFT JOIN source_currency scr ON scr.source_currency_id = acm.currency_id
	LEFT JOIN contract_group cgrp ON cgrp.contract_id = acm.contract_id
	LEFT JOIN static_data_value sdv_cet ON sdv_cet.value_id = acm.counterparty_group AND sdv_cet.type_id = 10020
	LEFT JOIN static_data_value sdv_rgn ON sdv_rgn.value_id = acm.region AND sdv_rgn.type_id = 11150

END

ELSE IF @flag = 'chargetype_grid'
BEGIN
	SELECT stmt_account_code_chargetype_id, 
		stmt_account_code_mapping_id, 
		deal_charge_type_id, 
		contract_charge_type_id,
		invoicing_charge_type_id, 
		charge_type_alias, 
		pnl_line_item_id,
		is_hide
	FROM stmt_account_code_chargetype
	WHERE stmt_account_code_mapping_id = @code_mapping_id
END

ELSE IF @flag = 'gl_grid'
BEGIN
	SELECT stmt_account_code_gl_id
			,stmt_account_code_chargetype_id
			,effective_date
			,estimate_gl
			,final_gl
			,payment_gl_group			
			,prior_period_gl
			,applies_to
	FROM stmt_account_code_gl WHERE stmt_account_code_chargetype_id = @acc_code_chargetype_id
END

ELSE IF @flag = 'sdt_combo'
BEGIN
	SELECT source_deal_type_id AS [id], deal_type_id AS [value] FROM source_deal_type
END

ELSE IF @flag = 'commodity_combo'
BEGIN
	SELECT source_commodity_id AS [id], commodity_id AS [value] FROM source_commodity
END

ELSE IF @flag = 'location_combo'
BEGIN
	SELECT source_minor_location_id AS [id], location_name AS [value] FROM source_minor_location
END

ELSE IF @flag = 'location_group_combo'
BEGIN
	SELECT source_major_location_id AS [id], location_name AS [value] FROM source_major_location
END

ELSE IF @flag = 'template_combo'
BEGIN
	SELECT template_id AS [id], template_name AS [value] FROM source_deal_header_template
END

ELSE IF @flag = 'currency_combo'
BEGIN
	SELECT source_currency_id AS [id], currency_id AS [value] FROM source_currency
END

ELSE IF @flag = 'contract_combo'
BEGIN
	SELECT contract_id AS [id], contract_name AS [value] FROM contract_group
END
-- For GL Code Combo (Estimated)
ELSE IF @flag = 'glcode_combo_e'
BEGIN
	SELECT default_gl_id AS [id], sdv.code + ' -> ' + case when adgl.estimated_actual = 'e' then 'Estimated' else 'Actual' end [value] from adjustment_default_gl_codes adgl
	INNER JOIN static_data_value sdv on sdv.value_id = adgl.adjustment_type_id
	WHERE adgl.estimated_actual = 'e'
END

-- For GL Code Combo (Actual/Final)
ELSE IF @flag = 'glcode_combo_a'
BEGIN
	SELECT default_gl_id AS [id], sdv.code + ' -> ' + case when adgl.estimated_actual = 'e' then 'Estimated' else 'Actual' end [value] from adjustment_default_gl_codes adgl
	INNER JOIN static_data_value sdv on sdv.value_id = adgl.adjustment_type_id
	WHERE adgl.estimated_actual = 'a'
END

-- For GL Code Combo (Payment GL Group)
ELSE IF @flag = 'glcode_combo_c'
BEGIN
	SELECT default_gl_id AS [id], sdv.code + ' -> ' + case when adgl.estimated_actual = 'e' then 'Estimated' when adgl.estimated_actual = 'c' then 'Cash Applied' else 'Actual' end [value] from adjustment_default_gl_codes adgl
	INNER JOIN static_data_value sdv on sdv.value_id = adgl.adjustment_type_id
	WHERE adgl.estimated_actual = 'c'
END

-- For Prior Period GL Code Combo
ELSE IF @flag = 'glcode_combo'
BEGIN
	SELECT default_gl_id AS [id], sdv.code + ' -> ' + case when adgl.estimated_actual = 'e' then 'Estimated' else 'Actual' end [value] from adjustment_default_gl_codes adgl
	INNER JOIN static_data_value sdv on sdv.value_id = adgl.adjustment_type_id
END

GO