IF OBJECT_ID(N'[dbo].[spa_ixp_ssis_configurations]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ixp_ssis_configurations]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2013-11-08
-- Description: Description of the functionality in brief.
 
-- Params:
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - Description of param3
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_ixp_ssis_configurations]
    @flag CHAR(1)
AS
SET NOCOUNT ON
DECLARE @SQL VARCHAR(MAX)
 
IF @flag = 's'
BEGIN
   SELECT NULLIF('', '') , ' ' UNION ALL SELECT isc.ixp_ssis_configurations_id,
           isc.package_description
    FROM   ixp_ssis_configurations isc
END