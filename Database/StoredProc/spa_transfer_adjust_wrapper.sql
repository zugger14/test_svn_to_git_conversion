IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_transfer_adjust_wrapper]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_transfer_adjust_wrapper]
GO 

/**
	Procedure that is used to wrap multiple deals for spa_transfer_adjust.

	Parameters:
		@process_id:	Process ID.
*/

CREATE PROC [dbo].[spa_transfer_adjust_wrapper]
	@process_id NVARCHAR(100)
AS

--declare @process_id NVARCHAR(100) = 'CF6E37D5_BA5E_4773_BEA8_E4134D048668ss'

BEGIN
	DECLARE @user_login_id				 NVARCHAR(50) = dbo.FNADBUser()
	DECLARE @spa_transfer_adjust_process NVARCHAR(100)
	SET @spa_transfer_adjust_process = dbo.FNAProcessTableName('spa_transfer_adjust', @user_login_id, @process_id)

	IF OBJECT_ID('tempdb..#temp_transfer_adjust_process') is not null
		DROP TABLE #temp_transfer_adjust_process
	CREATE TABLE #temp_transfer_adjust_process (source_deal_header_id INT)

	EXEC(' INSERT INTO #temp_transfer_adjust_process(source_deal_header_id)
		   --select 8774
		   SELECT source_deal_header_id
		   FROM ' + @spa_transfer_adjust_process)
	
	IF (SELECT 1 FROM #temp_transfer_adjust_process) IS NULL
		RETURN

	DECLARE @sql NVARCHAR(MAX)	
	DECLARE @source_deal_header_id INT

	DECLARE deal_cursor CURSOR FOR
	SELECT source_deal_header_id FROM #temp_transfer_adjust_process

	OPEN deal_cursor
	FETCH NEXT FROM deal_cursor
	INTO @source_deal_header_id
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		IF EXISTS( SELECT  uddf.udf_value
				   FROM source_deal_header sdh
				   INNER JOIN user_defined_deal_fields_template_main uddft
					   ON uddft.template_id = sdh.template_id
				   INNER JOIN user_defined_deal_fields uddf
					   ON uddf.source_deal_header_id = sdh.source_deal_header_id 
					   AND uddf.udf_template_id = uddft.udf_template_id
				   INNER JOIN user_defined_fields_template udft
					   ON udft.field_id = uddft.field_id
				   WHERE sdh.source_deal_header_id = @source_deal_header_id --7385 --
					   AND udft.Field_label = 'Delivery Path'
					   AND NULLIF(uddf.udf_value, '') IS NOT NULL
		)
		BEGIN
			
			--declare @sql varchar(max)
			--declare @process_id varchar(100) ='test1111111'
			
			DECLARE @col INT
			DECLARE @job_name1 NVARCHAR(100)

			SET @sql = ' [dbo].[spa_transfer_adjust] ' + 
							CAST(@source_deal_header_id AS VARCHAR(10)) 

			SET @job_name1 = 'transfer_adjust_' + @process_id
			
			EXEC spa_run_sp_as_job @job_name1, @sql, 'spa_transfer_adjust', 'farmms_admin'    
		END
		FETCH NEXT FROM deal_cursor INTO @source_deal_header_id
	END
	CLOSE deal_cursor 
	DEALLOCATE deal_cursor
END
