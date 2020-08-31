IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_UpdateBlockTypeXml]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_UpdateBlockTypeXml]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_UpdateBlockTypeXml]
	@flag CHAR(1),
	@xmlValue TEXT,
	@xmlValue2 TEXT
AS

SET NOCOUNT ON

DECLARE @sqlStmt VARCHAR(MAX)
DECLARE @sqlStmt2 VARCHAR(MAX)
DECLARE @tempdetailtable VARCHAR(128)
DECLARE @temphourtable VARCHAR(128)
DECLARE @user_login_id VARCHAR(100) 
DECLARE @process_id VARCHAR(50)

SET @user_login_id = dbo.FNADBUser()
--select @process_id

SET @process_id = REPLACE(NEWID(), '-', '_')

DECLARE @block_value_id INT

DECLARE @report_position_process_id VARCHAR(100)
DECLARE @job_name VARCHAR(100)
DECLARE @report_position_deals VARCHAR(300)
DECLARE @sql VARCHAR(8000)

SET @report_position_process_id = REPLACE(NEWID(), '-', '_')

SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id,@report_position_process_id)
EXEC ('CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, action CHAR(1))')

SET @tempdetailtable=dbo.FNAProcessTableName('hourly_process', @user_login_id,@process_id)
SET @temphourtable = dbo.FNAProcessTableName('holiday', @user_login_id,@process_id)

BEGIN TRY
	DECLARE @idoc INT
	DECLARE @doc VARCHAR(1000)

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlValue2
	SELECT * INTO #ztbl_xmlvalue
	FROM OPENXML (@idoc, '/GridGroup/Grid/GridRow', 2)
		 WITH (	 
		 		 id   INT  '@id',
		 		 block_type_group_id   INT  '@block_type_group_id',
		 		 block_name   VARCHAR(200)  '@block_name',
				 block_type_id INT '@block_type_id',
				 hourly_block_id  INT '@hourly_block_id'
				)
--SELECT * FROM #ztbl_xmlvalue
	
	DECLARE @idoc2 INT
	DECLARE @doc2 VARCHAR(1000)
		
	EXEC sp_xml_preparedocument @idoc2 OUTPUT, @xmlValue	
	

	-----------------------------------------------------------------
	SELECT * INTO #ztbl_xmlvalue2	
	FROM OPENXML (@idoc2, '/Root/PSRecordset', 2)
		WITH (	[type_id]   VARCHAR(50) '@type_id',
				[value_id] VARCHAR(50) '@value_id',
				[code]  VARCHAR(50) '@code',
				[description] VARCHAR(100) '@description'
			 )	


	DECLARE @idoc3 INT
	DECLARE @doc3 VARCHAR(1000)
		
	EXEC sp_xml_preparedocument @idoc3 OUTPUT, @xmlValue2	
	

	-----------------------------------------------------------------
	SELECT * INTO #delete_xmlvalue	
	FROM OPENXML (@idoc3, '/GridGroup/Grid/GridDelete', 2)
		WITH (	id   VARCHAR(50) '@id',
				block_type_group_id VARCHAR(50) '@block_type_group_id'
			 )	

	

	IF @flag IN ('i', 'u')
	BEGIN
		BEGIN TRAN		
		MERGE dbo.static_data_value AS sdv		
		USING (
			SELECT [type_id], [code], [description], [value_id]
			FROM #ztbl_xmlvalue2) zxv2 ON sdv.[value_id] = zxv2.[value_id]		
			WHEN NOT MATCHED BY TARGET THEN
				INSERT ([type_id], code, [description])
				VALUES (zxv2.[type_id], zxv2.[code], zxv2.[description])				
				
			WHEN MATCHED THEN
				UPDATE SET code = zxv2.code
							, [description] = zxv2.[description];							
		--select * from #ztbl_xmlvalue2
	
		declare @static_data_value_id int
		SET @static_data_value_id = (SELECT tsdv.[value_id] from #ztbl_xmlvalue2 tsdv)
		IF ( @static_data_value_id = '' )
			SET 			
			@static_data_value_id = SCOPE_IDENTITY()
        --SELECT * FROM #ztbl_xmlvalue
		MERGE block_type_group AS btg
		USING (
				SELECT 
					[id],
					[block_type_group_id],
					[block_name],
					[block_type_id], 
					[hourly_block_id]
				FROM #ztbl_xmlvalue
			) zxv ON btg.[id] = zxv.[id] AND btg.[block_type_group_id] = zxv.[block_type_group_id]

			WHEN NOT MATCHED BY TARGET THEN
				INSERT (
						[block_type_group_id],
						[block_name],
						[block_type_id],
						[hourly_block_id]
						)
				VALUES (
						@static_data_value_id,
						zxv.[block_name],
						CASE zxv.[block_type_id] 
							WHEN '' THEN NULL 
							ELSE zxv.[block_type_id] 
						END,
						--NULLIF('', zxv.[block_type_id]),
						zxv.[hourly_block_id]
						)
			WHEN MATCHED THEN
				UPDATE SET    
							  [block_name] = zxv.[block_name]
							, [block_type_id] = CASE zxv.[block_type_id] 
													WHEN  '' THEN NULL 
													ELSE zxv.[block_type_id] 
							                    END
							, [hourly_block_id] = zxv.[hourly_block_id];			
			
			DELETE from block_type_group where id in (SELECT id FROM #delete_xmlvalue )
			--SELECT [hol_group_ID] FROM #delete_xmlvalue
		
		EXEC spa_ErrorHandler 0
			, 'Source Deal Detail'
			, 'spa_UpdateBlockTypeXml'
			, 'Success'
			, 'Changes have been saved successfully.'
			, @static_data_value_id				

		COMMIT
	END
END TRY

BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK		
	DECLARE @msg VARCHAR(5000)
	SELECT @msg = 'Failed Inserting record (' + ERROR_MESSAGE() + ').'
	DECLARE @err_num INT = ERROR_NUMBER()
	IF @err_num = 2601
		 SELECT @msg = 'Duplicate data in Date From.'
	ELSE IF @err_num = 2627
		SELECT @msg = 'Duplicate data in (Data Type and <b>Name</b>).'
	ELSE IF @err_num = 241
		SELECT @msg = 'Invalid date format in grid'
	
	EXEC spa_ErrorHandler -1
		, 'Source Deal Detail'
		, 'spa_UpdateBlockTypeXml'
		, 'DB Error'
		, @msg
		, 'Failed Inserting Record'
END CATCH


