IF OBJECT_ID(N'[dbo].[spa_bcp_table_to_text_file]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_bcp_table_to_text_file]
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
CREATE PROCEDURE [dbo].[spa_bcp_table_to_text_file]
	@table VARCHAR(5000),
	@file_name VARCHAR(8000) 
AS

DECLARE @str VARCHAR(1000)
IF OBJECT_ID(@table) IS NOT NULL
BEGIN
	--SET @str = 'Exec Master..xp_Cmdshell ''bcp "Select * from ' + @table + '" queryout "' + @file_name + '" -S ' + CONVERT(VARCHAR(200),SERVERPROPERTY('ServerName'))  + ' -T -c'',no_output'
    
 --   PRINT(@str)
 --   EXEC (@str)
    DECLARE @sql VARCHAR(1024) = 'Select * from ' + @table 
    DECLARE @result NVARCHAR(1024)
    EXEC spa_export_to_csv @sql, @file_name, 'y', ',', 'n', 'n', 'y', 'n', @result OUTPUT
    
    
END
ELSE
    SELECT 'The table ' + @table + ' does not exist in the database'