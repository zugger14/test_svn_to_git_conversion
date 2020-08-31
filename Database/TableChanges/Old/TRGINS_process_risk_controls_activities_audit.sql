IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGINS_process_risk_controls_activities_audit]'))
    DROP TRIGGER [dbo].[TRGINS_process_risk_controls_activities_audit]
GO
 
SET ANSI_NULLS ON
GO
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2014-01-02
-- Modified date: 2014-01-07
-- Description: Trigger during insertion of data in process_risk_controls_activities_audit
-- Params:
--  
-- ===============================================================================================================
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[TRGINS_process_risk_controls_activities_audit]
ON [dbo].[process_risk_controls_activities_audit]
FOR INSERT
AS
BEGIN
	INSERT INTO workflow_activities_audit_summary (
		risk_control_activity_audit_id,
		source_name,
		source_id,
		activity_name,
		activity_detail,
		run_as_of_date,
		prior_status,
		current_status,
		activity_description,
		run_by,
		activity_create_date
	)
	SELECT
		prcau.risk_control_activity_audit_id,
		atd.logical_table_name,
		prca.source_id,  
		(CAST(prc.risk_control_id AS VARCHAR(10)) + ' - ' + DBO.FNAGetActivityName(prc.risk_control_id)),
		prca.comments, 
		CONVERT(VARCHAR(100), prca.as_of_date, 120),
		ps.code, 
		cs.code, 
		prcau.activity_desc, 
		CASE WHEN pUser.user_f_name IS NOT NULL THEN ' ' + ISNULL(pUser.user_l_name, '') + ' ' + ISNULL(pUser.user_f_name, '') + ' ' + ISNULL(pUser.user_m_name, '') ELSE '' END  AS [By Who], 
		CONVERT(VARCHAR(100), prcau.create_ts, 120) AS [Time Stamp]
	FROM INSERTED prcau
	INNER JOIN process_risk_controls_activities prca 
		ON prca.risk_control_id = prcau.risk_control_id 
		AND ISNULL(prca.source, '') = ISNULL(prcau.source, '')
		AND ISNULL(prcau.source_id, '') = ISNULL(prca.source_id, '')
		AND ISNULL(prcau.source_column, '') = ISNULL(prca.source_column, '')
	INNER JOIN process_risk_controls prc ON  prc.risk_control_id = prcau.risk_control_id
	LEFT JOIN portfolio_hierarchy book ON  book.entity_id = prc.fas_book_id
	LEFT JOIN portfolio_hierarchy stra ON  stra.entity_id = book.parent_entity_id
	LEFT JOIN portfolio_hierarchy sub ON  sub.entity_id = stra.parent_entity_id
	INNER JOIN process_risk_description prd ON  prc.risk_description_id = prd.risk_description_id
	INNER JOIN process_control_header pch ON  prd.process_id = pch.process_id
	INNER JOIN static_data_value ps ON  ps.value_id = prcau.control_prior_status
	INNER JOIN static_data_value cs ON  cs.value_id = prcau.control_new_status
	LEFT JOIN application_users pUser ON  pUser.user_login_id = prcau.create_user
	LEFT JOIN static_data_value area ON  area.value_id = prc.activity_area_id
	LEFT JOIN static_data_value sarea ON  sarea.value_id = prc.activity_sub_area_id
	LEFT JOIN static_data_value [action] ON  [action].value_id = prc.activity_action_id 
	LEFT JOIN alert_table_definition atd ON atd.physical_table_name = prcau.source
	
END
GO

