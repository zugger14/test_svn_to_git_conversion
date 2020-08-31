IF OBJECT_ID(N'[dbo].[spa_ixp_import_where_clause]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ixp_import_where_clause]
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
CREATE PROCEDURE [dbo].[spa_ixp_import_where_clause]   
    @flag CHAR(1),
    @ixp_import_where_clause_id INT = NULL,
    @rules_id INT = NULL,
    @table_id INT = NULL,
    @process_id VARCHAR(300) = NULL    
AS
 
DECLARE @sql VARCHAR(MAX)
DECLARE @ixp_import_where_clause VARCHAR(300)
DECLARE @user_login_id VARCHAR(100) 

SET @user_login_id = dbo.FNADBUser()

SET @ixp_import_where_clause = dbo.FNAProcessTableName('ixp_import_where_clause', @user_login_id, @process_id) 
IF @flag = 's'
BEGIN
    SET @sql = 'SELECT ixp_import_where_clause_id [clause_id],
                       ixp_import_where_clause [where_clause]
                FROM   ' + @ixp_import_where_clause + '
                WHERE  rules_id = ' + CAST(@rules_id AS VARCHAR(20)) + '
				AND table_id = ' + CAST(@table_id AS VARCHAR(20))
	EXEC(@sql)
END