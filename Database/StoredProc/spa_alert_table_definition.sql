IF OBJECT_ID(N'[dbo].[spa_alert_table_definition]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_alert_table_definition]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2008-09-09
-- Description: Description of the functionality in brief.
 
-- Params:
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - Description of param3
-- =============================================================================================================== 
CREATE PROCEDURE [dbo].[spa_alert_table_definition]
    @flag CHAR(1),
    @table_name VARCHAR(300) = NULL
AS
 
DECLARE @SQL VARCHAR(MAX)
 
IF @flag = 'z' -- used for compliance activities staus report
BEGIN
    SELECT atd.physical_table_name,
           atd.logical_table_name
    FROM   alert_table_definition atd
END

IF @flag = 'w' -- used for compliance activities staus report
BEGIN
    SELECT acd.column_name,
           acd.column_name
    FROM alert_columns_definition acd
    INNER JOIN alert_table_definition atd ON atd.alert_table_definition_id = acd.alert_table_id
    WHERE atd.physical_table_name = @table_name
END