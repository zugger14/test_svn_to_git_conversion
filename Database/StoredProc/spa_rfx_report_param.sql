IF OBJECT_ID(N'[dbo].[spa_rfx_report_param]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_report_param]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_rfx_report_param]
@flag				CHAR(1),
@process_id			VARCHAR(100),
@report_paramset_id	INT = NULL

AS
SET NOCOUNT ON
IF @process_id IS NULL
    SET @process_id = dbo.FNAGetNewID()

DECLARE @user_name  VARCHAR(50)   
DECLARE @sql        VARCHAR(MAX)
DECLARE @rfx_report_param VARCHAR(200)

SET @user_name = dbo.FNADBUser()

--Resolve Process Table Name
SET @rfx_report_param = dbo.FNAProcessTableName('report_param', @user_name, @process_id)
DECLARE @rfx_report_dataset_paramset VARCHAR(300) = dbo.FNAProcessTableName('report_dataset_paramset', @user_name, @process_id)
IF @flag = 'a'
BEGIN
	SET @sql ='SELECT rp.report_param_id
					, rp.dataset_paramset_id
					, rp.dataset_id
					, rp.column_id
					, rp.operator
					, rp.initial_value
					, rp.initial_value2
					, rp.optional
					, rp.hidden
					, rdp.where_part
				FROM ' + @rfx_report_param + ' rp
				INNER JOIN ' + @rfx_report_dataset_paramset + ' rdp ON rdp.report_dataset_paramset_id = rp.dataset_paramset_id AND rdp.root_dataset_id = rp.dataset_id
				WHERE rdp.paramset_id = ' + CAST(@report_paramset_id AS VARCHAR(50))
	--PRINT @sql
	EXEC(@sql)	
END
