IF OBJECT_ID ('[WF_Incidentlog]', 'V') IS NOT NULL
	DROP VIEW [WF_Incidentlog];
GO

-- ===============================================================================================================
-- Author: ryadav@pioneersolutionsglobal.com
-- Create date: 2019-04-16
-- Modified Date: 2019-04-16
-- Description: created view for incident log
-- ===============================================================================================================

CREATE VIEW [dbo].[WF_Incidentlog]

AS
SELECT
      [incident_log_id] -- Primary column 
    , [application_notes_id]
	, [contract]
	, [counterparty]
	, [incident_status]
	, [incident_type]
	, [internal_counterparty]
FROM incident_log


