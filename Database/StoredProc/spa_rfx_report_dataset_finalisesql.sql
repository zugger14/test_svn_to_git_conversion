IF OBJECT_ID(N'[dbo].[spa_rfx_report_dataset_finalisesql]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_report_dataset_finalisesql]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rgiri@pioneersolutionsglobal.com
-- Create date: 2012-08-17
-- Description: Add/Update Operations for Report Resultsetss
 
-- Params:
-- @flag					CHAR	- Operation flag
-- @process_id


-- Sample Use:
-- 1. EXEC [spa_rfx_report_dataset_finalisesql] 'w'
-- 2. EXEC [spa_rfx_report_dataset_finalisesql] 'd'

-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_rfx_report_dataset_finalisesql]
	@flag CHAR(1),
	@process_id VARCHAR(50) = NULL
	
AS

SET NOCOUNT ON
	IF @flag = 'd'
	BEGIN
	    SELECT rd.report_datatype_id, rd.[name] FROM report_datatype rd  
	END
	IF @flag = 'w'
	BEGIN
	    SELECT rw.report_widget_id, rw.[name] FROM report_widget rw 
	END