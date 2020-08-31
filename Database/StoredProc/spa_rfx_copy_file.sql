IF OBJECT_ID(N'[dbo].[spa_rfx_copy_file]', N'P') IS NOT NULL    
	DROP PROCEDURE [dbo].[spa_rfx_copy_file]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ============================================================================================================================
-- Author: Pawan Adhikari
-- Create date: 2012-03-15 08:45PM
-- Description: Deploy RDL.
--              
-- Params:
-- @source_file_path 
-- @dest_file_path 

-- Sample Use
-- EXEC spa_rfx_copy_file 'C:\\ICE_logger.sql', 'C:\\Copied\ICE_logger.sql'
-- EXEC TRMTracker.dbo.spa_rfx_copy_file 'D:\RSS_Export\Using Sp in SQL source _SP in SQL source .xls', '\\manaslu\bcp\Using Sp in SQL source _SP in SQL source .xls'
-- ============================================================================================================================
CREATE PROCEDURE [dbo].[spa_rfx_copy_file](
	@source_file_path	VARCHAR(1000),
	@dest_file_path		VARCHAR(1000)
)
AS
BEGIN
	SET NOCOUNT ON -- NOCOUNT is set ON since returning row count has side effects on exporting table feature
	DECLARE @win_cmd VARCHAR(300)
	
	SET @source_file_path = REPLACE(@source_file_path,'/','\')
	SET @dest_file_path = REPLACE(@dest_file_path,'/','\')
	
	SET NOCOUNT ON 
	--SET @win_cmd = 'Copy "' + @source_file_path + '"  "' + @dest_file_path + '"'
	
	--PRINT @win_cmd
	--EXEC MASTER..xp_cmdShell @win_cmd, no_output
	
	DECLARE @result NVARCHAR(1024)
	EXEC spa_move_file @source_file_path, @dest_file_path , @result OUTPUT
	SET NOCOUNT OFF
END
GO