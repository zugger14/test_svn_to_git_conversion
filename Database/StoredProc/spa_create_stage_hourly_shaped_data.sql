IF OBJECT_ID(N'[dbo].[spa_create_stage_hourly_shaped_data]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_create_stage_hourly_shaped_data]
    
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================================================
-- Author: ssingh@pioneersolutionsglobal.com
-- Create date: 2012-02-20
-- Description: Creates a staging table while importing Nomination files. spa_import_temp_table also creates staging
--				table for source_deal_detail_hour, but doesn't have columns [filename, has_error]

--	Params:
-- @flag CHAR(1) - Operation flag
-- @process_id VARCHAR(50)- Process ID,
-- @user_login_id varchar - UserID
-- ===========================================================================================================
CREATE  PROCEDURE [dbo].spa_create_stage_hourly_shaped_data
	@flag CHAR(1),
	@process_id VARCHAR(50),
	@user_login_id varchar(50)
AS 
DECLARE @sql VARCHAR(500)
DECLARE @stage_hourly_shape VARCHAR(128)

SELECT @stage_hourly_shape = dbo.FNAProcessTableName('stage_hourly_shape', @user_login_id, @process_id)

IF @flag = 'c'
BEGIN
	SET @sql = 'IF OBJECT_ID(''' + @stage_hourly_shape + ''') IS NOT NULL
		DROP TABLE ' + @stage_hourly_shape 
	EXEC(@sql)
	
	SET @sql = 
		'CREATE TABLE ' + @stage_hourly_shape + 
		'(
		source_deal_header_id INT,
		deal_id VARCHAR(100),
		date DATE,
		hour VARCHAR(2),
		volume VARCHAR(50),
		price NUMERIC(38, 20),
		leg VARCHAR(3),
		filename VARCHAR(200),
		has_error BIT
		)'
	EXEC(@sql)
	exec spa_print @sql	
END 


	










