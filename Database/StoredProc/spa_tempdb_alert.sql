IF OBJECT_ID(N'[dbo].[spa_tempdb_alert]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_tempdb_alert]
GO

/****** Object:  StoredProcedure [dbo].[spa_tempdb_alert]    Script Date: 01/23/2012 16:59:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================================================================
-- Create date: 2012-01-23
-- Author: Santosh Gupta 
-- Description:	Wrapper sp to Send Alert on TempDB size limit exceed
-- Params:
--	@lim_size -Free Size of TEMPDB to generate Alert 	

-- ===============================================================================================================

CREATE PROCEDURE [dbo].[spa_tempdb_alert]
	@lim_size FLOAT
	
AS
BEGIN
	SET NOCOUNT ON;
	
	--DECLARE @free_size FLOAT
	DECLARE @tot_size FLOAT
	DECLARE @template_params VARCHAR(5000)
	SET @template_params = ''
	SELECT @tot_size = SUM(size) * 1.0 / 128 / 1024
	FROM tempdb.sys.database_files
	--SELECT   @free_size = (SUM(unallocated_extent_page_count * (8.0 / 1024.0)) /1024)
	--FROM sys.dm_db_file_space_usage
		--replace template fields
	SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_TEMPDB_TOT_SIZE>',  @tot_size)
	--SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_TEMPDB_FREE_SIZE>', @free_size)
	SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_TEMPDB_INSTANCE>', CONVERT(VARCHAR(200), SERVERPROPERTY('ServerName')))
	SET @template_params = dbo.FNABuildNameValueXML(@template_params, '<TRM_TEMPDB_SIZE_LIMIT>', @lim_size)
			
	IF @tot_size > @lim_size
	BEGIN
	    EXEC spa_email_notes
	    @flag = 'i',
	    @role_type_value_id = 5,
	    @email_module_type_value_id = 17803,
	    @send_status = 'n',
	    @active_flag = 'y',
	    @template_params = @template_params
	END
	

END
