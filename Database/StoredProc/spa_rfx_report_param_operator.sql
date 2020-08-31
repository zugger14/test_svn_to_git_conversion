IF OBJECT_ID(N'[dbo].[spa_rfx_report_param_operator]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_report_param_operator]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: sligal@pioneersolutionsglobal.com
-- Create date: 2012-09-10
-- Description: Add/Update Operations for Report Paramsets
 
-- Params:
--	@flag					CHAR	- Operation flag
--	@report_param_operator_id INT 
--	@description VARCHAR(100) 
--	@sql_code VARCHAR(500) 
-- Sample Use:
-- 1. EXEC [spa_rfx_report_param_operator] 's'

-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_rfx_report_param_operator]
	@flag CHAR(1),
	@report_param_operator_id INT = NULL,
	@description VARCHAR(100) = NULL,
	@sql_code VARCHAR(500) = NULL
AS
SET NOCOUNT ON
	DECLARE @sql VARCHAR(MAX)

IF @flag = 's'
BEGIN
    SET @sql = 'SELECT rpo.report_param_operator_id
						, rpo.[description]
						, rpo.sql_code
				FROM report_param_operator rpo'
	--PRINT @sql
	EXEC (@sql)
END
	
	
	    