IF OBJECT_ID(N'[dbo].[spa_load_pda_priority_data]',N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_load_pda_priority_data]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: anuj@pioneersolutionsglobal.com
-- Create date: 2018-02-14
-- Description: Operations for PDA 
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_load_pda_priority_data]
	@flag CHAR(1) = 's',
	@pda_group_id INT = NULL,
	@active_tab_id VARCHAR(50) = NULL--,
	--@contract_id INT = NULL
AS

/* Debugg Querey
DECLARE	@flag CHAR(1) = 's',
	@pda_group_id INT = NULL,
	@active_tab_id VARCHAR(50) = NULL--,
	--@contract_id INT = NULL

*/
IF @flag = 's'
BEGIN
	SELECT CAST(ppg.pda_group_id AS VARCHAR(50)) + '_parent' AS parent_id, 
		ppg.pda_group_name AS parent_name,
		CAST(ppd.pda_detail_id AS VARCHAR(50))+'_child' AS child_id,
		sdv.code AS child_name
		FROM pda_priority_group ppg 
		LEFT JOIN pda_priority_detail ppd
			ON ppg.pda_group_id = ppd.pda_group_id
		LEFT JOIN static_data_value sdv on ppd.pda_method = sdv.value_id
			ORDER BY ppd.pda_rank 
END
ELSE IF @flag = 'r'
BEGIN
	SELECT COUNT(pda_group_id)+1 AS [rank], @active_tab_id AS active_tab_id 
	FROM pda_priority_detail
		WHERE pda_group_id = @pda_group_id
END
ELSE IF @flag = 'c'
BEGIN
	SELECT sc.source_counterparty_id,sc.counterparty_name 
	FROM source_counterparty sc 
	INNER JOIN static_data_value sdv 
		ON sdv.value_id = sc.type_of_entity 
	WHERE sdv.code = 'Shipper' AND type_id = 10020
END
--ELSE IF @flag = 'p'
--BEGIN
	--SELECT transportation_contract_pda_id,
		--contract_id,
		--CONVERT(VARCHAR(10), CAST(effective_date AS DATE)) effective_date,
		--pda_method,
		--dbo.FNARRound([value],0) [value]
	--FROM transportation_contract_pda WHERE contract_id = @contract_id 
	--ORDER BY effective_date DESC
--END
ELSE IF @flag = 'm'
BEGIN
	SELECT value_id,code FROM static_data_value WHERE type_id = 104800
END
ELSE IF @flag = 'g'
BEGIN
	SELECT pda_group_id,pda_group_name FROM pda_priority_group
END
ELSE IF @flag = 'a'
BEGIN
	SELECT value_id,code FROM static_data_value WHERE type_id = 104800
END