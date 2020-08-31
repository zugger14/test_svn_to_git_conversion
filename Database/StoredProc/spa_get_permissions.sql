IF OBJECT_ID(N'[dbo].[spa_get_permissions]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_get_permissions]
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
-- EXEC spa_get_permissions @function_ids='10201610,10201611,10201613,10201612,10201638,10201635'
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_get_permissions]
    @function_ids VARCHAR(MAX)
AS
SET NOCOUNT ON 
DECLARE @permission_state varchar(MAX)

SELECT @permission_state = COALESCE(@permission_state + ',', '') + dbo.FNACheckPermission(scsv.item)
FROM dbo.SplitCommaSeperatedValues(@function_ids) scsv

SELECT @permission_state [permission_string]