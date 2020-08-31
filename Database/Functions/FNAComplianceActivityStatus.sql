/*
Author		:	Sishir Maharjan
Date		:	07/07/2009
Description	:	Return Next Action of the instance according to control_status
*/

IF OBJECT_ID('dbo.FNAComplianceActivityStatus','fn') IS NOT NULL 
DROP FUNCTION dbo.FNAComplianceActivityStatus
GO 

CREATE FUNCTION dbo.FNAComplianceActivityStatus (
	@activity_id          INT,
	@return_as_hyperlink  CHAR(1) = NULL,
	@as_of_date           VARCHAR(50) = NULL,
	@as_of_date_to        VARCHAR(50) = NULL,
	@hierarchy_level      INT = NULL,
	@process_table        VARCHAR(400) = NULL,
	@source_column        VARCHAR(300) = NULL,
	@source_id            INT
)

RETURNS VARCHAR(500)
AS 
BEGIN 
/*
DECLARE @activity_id INT,
		@return_as_hyperlink CHAR(1),
		@as_of_date VARCHAR(50),
		@as_of_date_to VARCHAR(50)

SELECT @activity_id = 1
SELECT @as_of_date = '2012-12-18' 
SELECT @as_of_date_to = 'Dec 18 2012  4:38AM' 
SET @return_as_hyperlink = 'y'
SET @hierarchy_level = null
*/
SELECT @return_as_hyperlink = ISNULL(NULLIF(@return_as_hyperlink,''),'y')

DECLARE @action VARCHAR(500)

SELECT 
@action = 
CASE 
	WHEN @return_as_hyperlink = 'y' THEN 
		CASE 
			WHEN prcas.nextAction = 11000 THEN	-- Approve/Unapprove
				(dbo.FNACompliancePerformHyperlink(ISNULL(prc.action_label_on_approve,'Approve'),CAST(prca.risk_control_activity_id AS VARCHAR),CAST('' + dbo.FNADateFormat(prca.as_of_date)  + '' AS VARCHAR),CAST(isnull(CAST(@hierarchy_level AS VARCHAR), 'null') AS varchar),1, @process_table, 1, @source_column, @source_id)) --+ '  ' + 
				--(dbo.FNACompliancePerformHyperlink(ISNULL(prc.action_label_secondary,'Unapprove'),CAST(prca.risk_control_activity_id AS VARCHAR),CAST('' + dbo.FNADateFormat(prca.as_of_date)  + '' AS VARCHAR),CAST(isnull(CAST(@hierarchy_level AS VARCHAR), 'null') AS varchar),0))	
				
			WHEN ISNULL(prcas.nextAction,11001) = 11001 THEN	-- Complete
				dbo.FNACompliancePerformHyperlink(ISNULL(prc.action_label_on_complete,sdv.code),CAST(prca.risk_control_activity_id AS VARCHAR),CAST('' + dbo.FNADateFormat(prca.as_of_date)  + '' AS VARCHAR),CAST(isnull(CAST(@hierarchy_level AS VARCHAR), 'null') AS varchar),-1, @process_table, 1, @source_column, @source_id) + ' ' +
				(dbo.FNACompliancePerformHyperlink(ISNULL(prc.action_label_secondary,''),CAST(prca.risk_control_activity_id AS VARCHAR),CAST('' + dbo.FNADateFormat(prca.as_of_date)  + '' AS VARCHAR),CAST(isnull(CAST(@hierarchy_level AS VARCHAR), 'null') AS varchar),0, @process_table, 2, @source_column, @source_id))
				
			WHEN prcas.nextAction = 11002 THEN	-- Mitigate
				dbo.FNAComplianceHyperlink('e',453,sdv.code,CAST(prca.risk_control_id AS VARCHAR),CAST( dbo.FNADateFormat(prca.as_of_date)   AS VARCHAR),CAST(isnull(CAST(@hierarchy_level AS VARCHAR), 'null') AS varchar), CAST(prca.risk_control_activity_id AS VARCHAR),default,default,default)
					
			WHEN prcas.nextAction = 11003 THEN	-- Proceed
				dbo.FNAComplianceHyperlink('e',455,sdv.code,CAST(prca.risk_control_activity_id AS VARCHAR),CAST( dbo.FNADateFormat(@as_of_date) AS VARCHAR),CAST( dbo.FNADateFormat(@as_of_date_to) AS VARCHAR),CAST( dbo.FNADateFormat(prca.as_of_date) AS VARCHAR),CAST(isnull(CAST(@hierarchy_level AS VARCHAR), 'null') AS varchar),default,default)
				
			WHEN prcas.nextAction = 11004 THEN	-- Re-process
				dbo.FNACompliancePerformHyperlink(sdv.code,CAST(prca.risk_control_activity_id AS VARCHAR),CAST('' + dbo.FNADateFormat(prca.as_of_date)  + '' AS VARCHAR),CAST(isnull(CAST(@hierarchy_level AS VARCHAR), 'null') AS varchar),-1, @process_table, 1, @source_column, @source_id)
				
			WHEN prcas.nextAction = 11005 THEN	-- Submit Proof
				dbo.FNAComplianceHyperlink('e',10102910,sdv.code,CAST(prca.risk_control_id AS VARCHAR),CAST( dbo.FNADateFormat(prca.as_of_date)   AS VARCHAR),CAST(isnull(CAST(@hierarchy_level AS VARCHAR), 'null') AS varchar),CAST(prca.risk_control_activity_id AS VARCHAR),default,default,default)
		END 
	ELSE 
		CASE WHEN prc.notificationOnly = 'y' THEN 'Complete' ELSE sdv.code END
	END 
	
FROM process_risk_controls_activities prca
JOIN process_risk_controls prc ON prc.risk_control_id = prca.risk_control_id 
LEFT JOIN dbo.process_risk_controls_activities_status prcas ON prcas.activityStatus = prca.control_status 
AND UPPER(prc.requires_approval) = UPPER(prcas.requiresApproval) AND UPPER(prc.requires_approval_for_late) = UPPER(prcas.requiresApprovalLate) 
AND UPPER(prc.requires_proof) = UPPER(prcas.requiresProof) AND UPPER(prc.mitigation_plan_required) = UPPER(prcas.mitigationRequired)
LEFT JOIN dbo.static_data_value sdv ON sdv.value_id = ISNULL(prcas.nextAction,11001)
WHERE prca.risk_control_activity_id = @activity_id 

RETURN @action 
END 