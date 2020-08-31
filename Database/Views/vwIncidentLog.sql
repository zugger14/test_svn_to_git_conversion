IF OBJECT_ID(N'dbo.[vwIncidentLog]', N'V') IS NOT NULL
	DROP VIEW dbo.[vwIncidentLog]
GO 
-- ===============================================================================================================
-- Author: sbasnet@pioneersolutionsglobal.com
-- Create date: 2018-03-09
-- Description: Creatrs view for Incident Log
-- Params:
-- ===============================================================================================================

CREATE VIEW dbo.[vwIncidentLog]
As
	       
	SELECT il.incident_log_id
	   ,il.application_notes_id
	   ,il.[contract]
	   ,il.incident_status
	   ,ild.incident_status [incident_status_detail]
	   ,il.incident_type
	   ,il.internal_counterparty
	   ,ild.application_notes_id [application_notes_id_detail]
	   ,an.notes_object_id [object_id]
	   ,an.category_value_id [category_id]
	   ,il.counterparty [counterparty_id]
	FROM incident_log il
	LEFT JOIN incident_log_detail ild
		ON il.incident_log_id = ild.incident_log_id
	INNER JOIN application_notes an
		ON an.notes_id = il.application_notes_id 
GO


