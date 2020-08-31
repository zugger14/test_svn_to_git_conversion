IF OBJECT_ID(N'[dbo].[spa_alert_report_params]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_alert_report_params]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: kcshrestha@pioneersolutionsglobal.com
-- Create date: 2014-01-29
-- Description: CRUD operations for table alert_report_params
 
-- Params:
--
-- @flag CHAR(1) - Operation flag
-- @alert_report_params_id INT - Alert Report Parameter ID
-- @event_message_id INT - Alert ID
-- @alert_report_id INT - Alert Report ID
-- @alert_report_id INT - Alert Report ID
-- @main_table_id INT - Main Table ID
-- @parameter_name NVARCHAR(100) - Paramater Name
-- @parameter_value NVARCHAR(1000) - Paramater Value
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_alert_report_params]
    @flag							CHAR(1),
    @event_message_id				INT = NULL,
	@alert_report_id				INT = NULL,
	@main_table_id					INT = NULL,
	@parameter_name					NVARCHAR(100) = NULL,
	@parameter_value				NVARCHAR(1000) = NULL
AS
SET NOCOUNT ON
 
IF @flag = 's'
BEGIN
    SELECT
    	event_message_id, 
    	alert_report_id,
		main_table_id,	
		parameter_name,
		parameter_value
    FROM
    	alert_report_params
END
ELSE IF @flag = 'a'
BEGIN
    SELECT
    	main_table_id,	
		parameter_name,
		parameter_value
    FROM
    	alert_report_params
    WHERE 
		alert_report_id = @alert_report_id
		AND event_message_id = @event_message_id
END