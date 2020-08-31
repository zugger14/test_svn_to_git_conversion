
IF OBJECT_ID(N'[dbo].[spa_contract_trees]', N'P') IS NOT NULL
  DROP PROCEDURE [dbo].[spa_contract_trees]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===============================================================================================================
-- Author: vsshrestha@pioneersolutionsglobal.com
-- Create date: 2015-04-09
-- Description: Returning different contract types for populating in the tree.

-- Params:
-- @flag CHAR(1)        - Operational flag 
--    				- 's' - standard contract 
--						- 'n' - non-standard contract
--						- 't' - transportation contract

-- Usage - EXEC spa_contract_trees @flag='s'
-- =============================================================================================================== 
CREATE PROCEDURE [dbo].[spa_contract_trees] 
	@flag char(1)

AS
SET NOCOUNT ON

/* **DEBUG**
DECLARE @flag char(1)
SET @flag = 't'
--*/

DECLARE @sql VARCHAR(MAX)
DECLARE @user_name VARCHAR(300)
SET @user_name = dbo.FNADBUser()


IF OBJECT_ID('tempdb..#final_privilege_list') IS NOT NULL
	DROP TABLE #final_privilege_list
IF @flag IN ('s', 'n', 't')
BEGIN

	CREATE TABLE #final_privilege_list(value_id INT, is_enable VARCHAR(20) COLLATE DATABASE_DEFAULT )
	EXEC spa_static_data_privilege @flag = 'p', @source_object = 'contract'
END

IF @flag = 's'
BEGIN
	SET @sql = '
		SELECT DISTINCT cg.contract_id AS contract_id_show,
				contract_name,
				--contract_id,
				--CASE
				--  WHEN ISNULL(contract_type_def_id, ''1'') = ''1'' THEN ''10211200''
				--  WHEN contract_type_def_id = ''38401'' THEN ''10211024''
				--  WHEN contract_type_def_id = ''38400'' THEN ''10211000''
				--  ELSE ''10211025''
				--END AS function_id,
				cg.contract_desc,
				sc.currency_name,
				su.uom_name as volume_uom,
				sdv1.code as contract_status,
				ph.entity_name,
				CASE WHEN cg.is_active = ''y'' THEN ''Yes'' ELSE ''No'' END AS is_active,
				sdv2.code as settlement_date,
				cg.settlement_days,
				sdv3.code as invoice_due_date,
				cg.payment_days,
				sdv4.code as volume_granularity,
				crt1.template_name as invoice_report_template,
				crt2.template_name as contract_report_template,
				crt3.template_name as netting_template,
				dbo.FNADATEFORMAT(cg.create_ts) create_ts,
				cg.create_user,
				dbo.FNADATEFORMAT(cg.update_ts) update_ts,
				cg.update_user,
				cg.source_contract_id,
				4016 type_id,
				ISNULL(sdad.is_active, 0) is_privilege_active
		FROM #final_privilege_list fpl
		' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
		contract_group cg ON cg.contract_id = fpl.value_id
		LEFT JOIN static_data_value sdv ON sdv.value_id = cg.contract_type_def_id
			AND sdv.type_id = 38400
		LEFT JOIN source_currency sc ON sc.source_currency_id=cg.currency
		LEFT JOIN source_uom su ON su.source_uom_id=cg.volume_uom
		LEFT JOIN static_data_value sdv1 ON cg.contract_status=sdv1.value_id 
			AND sdv1.type_id = 1900 AND sdv1.entity_id IS NULL
		LEFT JOIN portfolio_hierarchy ph ON ph.entity_id=cg.sub_id 
		LEFT JOIN static_data_value sdv2 ON cg.settlement_date=sdv2.value_id 
			AND sdv2.type_id = 20000 AND sdv2.entity_id IS NULL
		LEFT JOIN static_data_value sdv3 ON cg.invoice_due_date=sdv3.value_id 
			AND sdv3.type_id = 20000 AND sdv3.entity_id IS NULL
		LEFT JOIN static_data_value sdv4 ON cg.volume_granularity=sdv4.value_id 
			AND sdv4.type_id = 978 AND sdv4.entity_id IS NULL
		LEFT JOIN contract_report_template crt1 ON crt1.template_id=cg.invoice_report_template
		LEFT JOIN contract_report_template crt2 ON crt2.template_id=cg.contract_report_template
		LEFT JOIN contract_report_template crt3 ON crt3.template_id=cg.netting_template
		LEFT JOIN static_data_active_deactive sdad ON sdad.type_id = 4016 --location type id :4000		
		WHERE ISNULL(contract_type_def_id, ''1'') = ''1''
			OR contract_type_def_id = 38400
		ORDER BY contract_name
	'
	EXEC(@sql)
END
 
IF @flag = 'n'
BEGIN
	SET @sql = '
		SELECT DISTINCT cg.contract_id AS contract_id_show,
				contract_name,
				--contract_id,
				--CASE
				--  WHEN ISNULL(contract_type_def_id, ''1'') = ''1'' THEN ''10211200''
				--  WHEN contract_type_def_id = ''38401'' THEN ''10211024''
				--  WHEN contract_type_def_id = ''38400'' THEN ''10211000''
				--  ELSE ''10211025''
				--END AS function_id,
				cg.contract_desc,
				sc.currency_name,
				su.uom_name as volume_uom,
				sdv1.code as contract_status,
				ph.entity_name,
				CASE
				WHEN cg.is_active = ''y'' THEN ''Yes''
				ELSE ''No''
				END AS is_active,
				sdv2.code as settlement_date,
				cg.settlement_days,
				sdv3.code as invoice_due_date,
				cg.payment_days,
				sdv4.code as volume_granularity,
				crt1.template_name as invoice_report_template,
				crt2.template_name as contract_report_template,
				crt3.template_name as netting_template,
				dbo.FNADATEFORMAT(cg.create_ts) create_ts,
				cg.create_user,
				dbo.FNADATEFORMAT(cg.update_ts) update_ts,
				cg.update_user,
				cg.source_contract_id,
				4073 type_id,
				ISNULL(sdad.is_active, 0) is_privilege_active
		FROM #final_privilege_list fpl
		' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
		contract_group cg ON cg.contract_id = fpl.value_id
		LEFT JOIN static_data_value sdv ON sdv.value_id = cg.contract_type_def_id
			AND sdv.type_id = 38400
		LEFT JOIN source_currency sc ON sc.source_currency_id=cg.currency
		LEFT JOIN source_uom su ON su.source_uom_id=cg.volume_uom
		LEFT JOIN static_data_value sdv1 ON cg.contract_status=sdv1.value_id 
			AND sdv1.type_id = 1900 AND sdv1.entity_id IS NULL
		LEFT JOIN portfolio_hierarchy ph ON ph.entity_id=cg.sub_id 
		LEFT JOIN static_data_value sdv2 ON cg.settlement_date=sdv2.value_id 
			AND sdv2.type_id = 20000 AND sdv2.entity_id IS NULL
		LEFT JOIN static_data_value sdv3 ON cg.invoice_due_date=sdv3.value_id 
			AND sdv3.type_id = 20000 AND sdv3.entity_id IS NULL
		LEFT JOIN static_data_value sdv4 ON cg.volume_granularity=sdv4.value_id 
			AND sdv4.type_id = 978 AND sdv4.entity_id IS NULL
		LEFT JOIN contract_report_template crt1 ON crt1.template_id=cg.invoice_report_template
		LEFT JOIN contract_report_template crt2 ON crt2.template_id=cg.contract_report_template
		LEFT JOIN contract_report_template crt3 ON crt3.template_id=cg.netting_template
		LEFT JOIN static_data_active_deactive sdad ON sdad.type_id = 4073 --location type id :4000		
		WHERE contract_type_def_id = ''38401''
		ORDER BY contract_name
	'
	EXEC (@sql)
END
 
IF @flag = 't'
BEGIN
	SET @sql = '
		SELECT DISTINCT
			cg.contract_id AS contract_id_show,
			contract_name,
			--contract_id,
			--CASE
			--  WHEN ISNULL(contract_type_def_id, ''1'') = ''1'' THEN ''10211200''
			--  WHEN contract_type_def_id = ''38401'' THEN ''10211024''
			--  WHEN contract_type_def_id = ''38400'' THEN ''10211000''
			--  ELSE ''10211025''
			--END AS function_id,
			CASE WHEN pipeline IS NOT NULL THEN sc.counterparty_name ELSE '''' END AS pipeline,
			dbo.FNARemoveTrailingZero(aa.mdq) mdq,
			--dbo.FNADateFormat(aa.effective_date) effective_date,       
			CASE
				WHEN capacity_release = ''y'' THEN ''Yes''
			ELSE ''No''
			END AS capacity_release,      
			dbo.FNADateFormat(cg.flow_start_date) AS flow_start_date,
			dbo.FNADateFormat(cg.flow_end_date) AS flow_end_date,   
			CASE
				WHEN contract_type = ''f'' THEN ''Firm Transport''
				WHEN contract_type = ''f'' THEN ''Interruptible Transport''
				WHEN contract_type = ''s'' THEN ''Storage''
				ELSE ''''
			END AS contract_type,
			CASE WHEN sdv1.code IS NOT NULL THEN sdv1.code END AS maintain_rate_schedule,
			CASE WHEN segmentation = ''y'' THEN ''Yes'' ELSE ''No'' END AS segmentation,
			CASE WHEN cg.is_active = ''y'' THEN ''Yes'' ELSE ''No'' END AS is_active,
			4074 type_id,
			ISNULL(sdad.is_active, 0) is_privilege_active     
		FROM #final_privilege_list fpl
		' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
		contract_group cg ON cg.contract_id = fpl.value_id
		LEFT JOIN static_data_value sdv ON sdv.value_id = cg.contract_type_def_id
			AND sdv.type_id = 38400
		LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cg.maintain_rate_schedule
			AND sdv1.type_id = 1800
		LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = cg.pipeline
		OUTER APPLY (
			SELECT effective_date, mdq FROM transportation_contract_mdq tcm 
			WHERE effective_date 
			IN (	
				SELECT MAX(effective_date)  FROM transportation_contract_mdq 
				WHERE contract_id = cg.contract_id
			)
			AND tcm.contract_id = cg.contract_id
		) aa
		LEFT JOIN static_data_active_deactive sdad ON sdad.type_id = 4074 --location type id :4000		
		WHERE contract_type_def_id = ''38402''
			OR contract_type = ''f''
		ORDER BY contract_name
	'
	EXEC(@sql)
END

IF @flag = 'v'
BEGIN
    SET @sql = ' SELECT
		CASE WHEN cg.pipeline IS NOT NULL THEN sc.counterparty_name ELSE ''Pipeline'' END AS pipeline,
		--ISNULL(cg1.contract_name,cg.contract_name) grouping_contract,
		cg1.contract_name [grouping_contract],
		cg.contract_name,
		cg.contract_id AS contract_id_show,
		IIF(cg.contract_name = cg1.contract_name, '''', cg1.contract_name) [primary_contract],
		dbo.FNADateFormat(cg.flow_start_date) AS flow_start_date,
		dbo.FNADateFormat(cg.flow_end_date) AS flow_end_date,   
		CASE
			WHEN cg.capacity_release = ''y'' THEN ''Yes''
		ELSE ''No''
		END AS capacity_release,      
		
		
		CASE WHEN sdv1.code IS NOT NULL THEN sdv1.code END AS maintain_rate_schedule,
		CASE WHEN cg.segmentation = ''y'' THEN ''Yes'' ELSE ''No'' END AS segmentation,
		CASE WHEN cg.is_active = ''y'' THEN ''Yes'' ELSE ''No'' END AS is_active,
		4074 type_id,
		ISNULL(sdad.is_active, 0) is_privilege_active     
	FROM contract_group cg
	LEFT JOIN contract_group cg1 ON cg.grouping_contract = cg1.contract_id
	LEFT JOIN static_data_value sdv ON sdv.value_id = cg.contract_type_def_id
		AND sdv.type_id = 38400
	LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cg.maintain_rate_schedule
		AND sdv1.type_id = 1800
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = cg.pipeline
	LEFT JOIN static_data_active_deactive sdad ON sdad.type_id = 4074 --location type id :4000		
	WHERE cg.contract_type_def_id = 38404'
	EXEC(@sql)
END


GO 
