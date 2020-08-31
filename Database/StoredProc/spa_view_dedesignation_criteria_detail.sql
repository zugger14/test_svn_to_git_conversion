--EXEC spa_view_dedesignation_criteria_detail  's', 2
IF OBJECT_ID('spa_view_dedesignation_criteria_detail') IS NOT NULL
DROP PROC dbo.spa_view_dedesignation_criteria_detail
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2011-06-06
-- Description: display dedesignation criteria detail

-- Params:
-- @flag CHAR(1) - Operation flag
-- @dedesignation_criteria_id - dedesignation criteria id
-- ===========================================================================================================

CREATE PROC [dbo].spa_view_dedesignation_criteria_detail	
 		@flag CHAR(1) = NULL,
		@dedesignation_criteria_id INT = NULL,
		@dedesignation_criteria_detail_id INT = NULL,
		@dedesignate_type INT = NULL 
		
AS
DECLARE @sql VARCHAR(MAX)
IF @flag = 's'
BEGIN
	SELECT	row_id AS [Row ID]
			,dedesignation_criteria_id AS [Dedesignation Criteria ID]
			,link_id AS [Link ID]
			,recommended_per AS [Recommended %]
			,available_per AS [Available %]
			,dbo.FNADateFormat(effective_date) AS [Effective Date]
			,relationship_desc AS [Relation Description]
			,perfect_hedge AS [Perfect Hedge]
			,dbo.FNADateFormat(term_start) AS [Term Start]
			,link_volume AS [Link Volume]
			,runing_total AS [Running Total]
			,process_status AS [Process Status]
			,dcr.create_user AS [Create User]
			,dbo.FNADateFormat(dcr.create_ts) AS [Create Ts]
			,dcr.dedesignate_type AS [De-Designate Type ID]
			,sdv.[description] AS [De-Designate TYPE]
			
			
	 FROM dedesignation_criteria_result dcr 
	 LEFT JOIN static_data_value sdv ON dcr.dedesignate_type = sdv.value_id AND sdv.[type_id] = 450
	WHERE dedesignation_criteria_id = @dedesignation_criteria_id
		AND (process_status IS NULL OR process_status = 'n')
	
END
ELSE IF @flag = 'u'
BEGIN
	UPDATE dedesignation_criteria_result
	SET dedesignate_type = @dedesignate_type 
	WHERE row_id = @dedesignation_criteria_detail_id
END
ELSE IF @flag = 'd'
BEGIN
	DELETE FROM dedesignation_criteria_result WHERE row_id = @dedesignation_criteria_detail_id
END
	 
