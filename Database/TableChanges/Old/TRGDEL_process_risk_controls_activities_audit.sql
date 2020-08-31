SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[TRGDEL_process_risk_controls_activities_audit]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGDEL_process_risk_controls_activities_audit]
GO
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2014-01-02
-- Modified date: 2014-01-07
-- Description: Trigger during Delete of data in process_risk_controls_activities_audit
-- Params:
--  
-- ===============================================================================================================

CREATE TRIGGER [dbo].[TRGDEL_process_risk_controls_activities_audit]
ON [dbo].[process_risk_controls_activities_audit]
FOR  DELETE
AS
	DELETE waas
	FROM DELETED prcau
	INNER JOIN workflow_activities_audit_summary waas ON waas.risk_control_activity_audit_id = prcau.risk_control_activity_audit_id
GO
