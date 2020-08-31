IF OBJECT_ID(N'[dbo].[spa_alert_columns_definition]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_alert_columns_definition]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: kcshrestha@pioneersolutionsglobal.com
-- Create date: 2014-01-30
-- Description: CRUD operations for table alert_columns_definition
 
-- Params:
--
-- @flag CHAR(1) - Operation flag
-- @alert_table_id INT - Alert Table ID
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_alert_columns_definition]
    @flag							CHAR(1),
    @alert_table_id					INT = NULL
AS
 
IF @flag = 's'
BEGIN
    SELECT
		alert_columns_definition_id,
    	alert_table_id, 
    	column_name
    FROM
    	alert_columns_definition
END
ELSE IF @flag = 'a'
BEGIN
    SELECT
    	alert_columns_definition_id, 
    	column_name
    FROM
    	alert_columns_definition
    WHERE 
		alert_table_id = @alert_table_id
END