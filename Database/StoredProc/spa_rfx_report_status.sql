IF OBJECT_ID(N'[dbo].[spa_rfx_report_status]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_report_status]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: padhikari@pioneersolutionsglobal.com
-- Create date: 2013-01-07
-- Description: Select Report Status List
 
-- Params:
--	@flag					CHAR	- Operation flag
--	@report_status_id INT 
--	@description VARCHAR(100) 

-- Sample Use:
-- 1. EXEC [spa_rfx_report_status] 's'

-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_rfx_report_status]
	@flag CHAR(1),
	@report_status_id INT = NULL,
	@description VARCHAR(100) = NULL
AS
SET NOCOUNT ON
IF @flag = 's'
BEGIN
    SELECT rpo.report_status_id,
           rpo.[name],
           rpo.[description]
    FROM   report_status rpo
END
	
	
	    