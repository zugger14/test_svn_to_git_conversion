IF OBJECT_ID(N'dbo.spa_import_deal_detail_hour_from_staging', N'P') IS NOT NULL
	DROP PROCEDURE dbo.spa_import_deal_detail_hour_from_staging
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================================================================
-- Create date: 2011-02-09 10:05AM
-- Description: Start importing from staging to main if this is the last job & partition
-- Params:
-- ===============================================================================================================
CREATE PROCEDURE dbo.spa_import_deal_detail_hour_from_staging
	@import_type SMALLINT,
	@table_name VARCHAR(150) = 'deal_detail_hour',
	@process_id VARCHAR(50) = NULL,
	@user_login_id VARCHAR(50) = NULL,
	@send_email CHAR(1) = 'n'
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @tbl_final_import_run_status VARCHAR(150)
	DECLARE @sql VARCHAR(8000)
	
	IF @process_id IS NULL
		SET @process_id = dbo.FNAGetNewID()
	SET @user_login_id = ISNULL(@user_login_id, dbo.FNADBUser())
	IF NOT EXISTS(SELECT 1 FROM log_partition WITH(TABLOCK) WHERE end_time IS NULL)
	BEGIN
		BEGIN TRY
			SET @tbl_final_import_run_status = dbo.FNAProcessTableName('ddh_import_ssis_final_status', @user_login_id, @process_id)
			
			SET @sql = 'INSERT INTO ' + @tbl_final_import_run_status + ' WITH(TABLOCK)
						SELECT 1, ''' + @process_id + ''', ''' + CAST(GETDATE() AS VARCHAR(20)) + '''' --error will occur if the other sp has already called
			EXEC(@sql)						

			EXEC dbo.spa_generate_position_breakdown_data @import_type, @table_name, @user_login_id, @process_id, @send_email
		END TRY
		BEGIN CATCH
			IF ERROR_NUMBER() = 2601
			BEGIN
				EXEC spa_print 'Run Successfully.Just INFO(The SP:EXEC [dbo].[spa_generate_position_breakdown_data] @import_type, @table_name  has been called by other job ........).'
			END				
			ELSE
			BEGIN
				DECLARE @error_msg VARCHAR(1000)
				SET @error_msg = 'Error raised in TRY block. Error: ' + ERROR_MESSAGE()
				RAISERROR (@error_msg, -- Message text.
						   16, -- Severity.
						   1 -- State.
						   );
			END 
			   
		END CATCH
	END
	ELSE
	BEGIN
		EXEC spa_print 'Run Successfully. There are other job still running......'	
	END
END
GO
