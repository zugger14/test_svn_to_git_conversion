IF OBJECT_ID(N'[dbo].[spa_ixp_export_relation_detail]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ixp_export_relation_detail]
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
CREATE PROCEDURE [dbo].[spa_ixp_export_relation_detail]
    @flag CHAR(1),
    @ixp_export_relation_detail_id INT = NULL,
    @export_relation_id INT = NULL,
    @ixp_rules_id INT = NULL,
    @process_id VARCHAR(400) = NULL,
    @xml TEXT = NULL
    
AS
DECLARE @ixp_export_relation VARCHAR(500)
DECLARE @ixp_export_relation_detail VARCHAR(500)
DECLARE @user_name VARCHAR(100)

SET @user_name = dbo.FNADBUser() 
SET @ixp_export_relation = dbo.FNAProcessTableName('ixp_export_relation', @user_name, @process_id) 
SET @ixp_export_relation_detail = dbo.FNAProcessTableName('ixp_export_relation_detail', @user_name, @process_id)  
DECLARE @sql VARCHAR(MAX)
 
IF @flag = 's'
BEGIN
    SET @sql = ''
END