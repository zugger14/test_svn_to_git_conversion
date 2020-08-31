
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_UpdateBookMappingXml]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_UpdateBookMappingXml]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_UpdateBookMappingXml]
	@flag CHAR(1),
	@xml TEXT 

AS
--DECLARE @fas_book_id INT 

BEGIN TRY
	DECLARE @id INT 
	DECLARE @idoc INT
	DECLARE @doc VARCHAR(1000)

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
	
	SELECT * INTO #ztbl_xmlvalue
	
	--SELECT * FROM source_system_book_map
	FROM OPENXML (@idoc, '/Root/FormXML', 2)
		 WITH (	 
		 		 ID INT '@ID',
		 		 logical_name VARCHAR(100) '@logical_name',
		 		  [entity_name] VARCHAR(100) '@entity_name',
		 		 
		 		 fas_book_id  INT  '@fas_book_id',
				
				 source_system_book_id1 INT '@source_system_book_id1',
				 source_system_book_id2 INT '@source_system_book_id2',
				 source_system_book_id3  INT '@source_system_book_id3',
				 source_system_book_id4 INT '@source_system_book_id4',
				 fas_deal_type_value_id INT '@fas_deal_type_value_id',
				 fas_deal_sub_type_value_id INT '@fas_deal_sub_type_value_id',
				 effective_start_date DATETIME '@effective_start_date',
				 end_date DATETIME '@end_date',
				 percentage_included FLOAT '@percentage_included',
				 sub_book_group1 INT '@sub_book_group1',
				 sub_book_group2 INT '@sub_book_group2',
				 sub_book_group3 INT '@sub_book_group3',
				 sub_book_group4 INT '@sub_book_group4' )

				 --SELECT * FROM #ztbl_xmlvalue

	 
	

	--DECLARE @idoc2 INT
	--DECLARE @doc2 VARCHAR(1000)

	--EXEC sp_xml_preparedocument @idoc2 OUTPUT, @xmlValue2

	-------------------------------------------------------------------
	--SELECT * INTO #ztbl_xmlvalue2
	--FROM OPENXML (@idoc2, '/Root/PSRecordset', 2)
	--	WITH (entity_name  VARCHAR(100) '@fas_strategy_name')
	--	SELECT * FROM #ztbl_xmlvalue2		
	
	
	IF @flag IN ('i', 'u')
	BEGIN
		EXEC spa_print 'Merge'
		BEGIN TRAN
		
				MERGE portfolio_hierarchy ph
		USING (SELECT [entity_name],logical_name,ID,fas_book_id
				FROM #ztbl_xmlvalue) zxv ON ph.[entity_id] = zxv.fas_book_id
	
		WHEN NOT MATCHED BY TARGET THEN
				INSERT ([entity_name],hierarchy_level,entity_type_value_id,parent_entity_id)
				VALUES ( zxv.[entity_name],0,527,zxv.ID )
		WHEN MATCHED THEN
			UPDATE SET	 ph.[entity_name] = zxv.logical_name;
			
			set @id = SCOPE_IDENTITY()
			
			
		
		MERGE source_system_book_map AS fs
		USING (
			SELECT fas_book_id,
				 source_system_book_id1,
				 source_system_book_id2,
				 source_system_book_id3,
				 source_system_book_id4 ,
				 fas_deal_type_value_id ,
				 fas_deal_sub_type_value_id ,
				 effective_start_date ,
				 end_date ,
				 percentage_included ,
				 sub_book_group1 ,
				 sub_book_group2 ,
				 sub_book_group3 ,
				 sub_book_group4 
				 
			FROM #ztbl_xmlvalue) zxv ON fs.fas_book_id = zxv.fas_book_id
			
			WHEN NOT MATCHED BY TARGET THEN
				INSERT (
					fas_book_id,
				 source_system_book_id1 ,
				 source_system_book_id2,
				 source_system_book_id3  ,
				 source_system_book_id4 ,
				 fas_deal_type_value_id ,
				 fas_deal_sub_type_value_id ,
				 effective_start_date ,
				 end_date ,
				 percentage_included ,
				 sub_book_group1 ,
				 sub_book_group2 ,
				 sub_book_group3 ,
				 sub_book_group4 )
				VALUES (
				@id,
				 zxv.source_system_book_id1,
				 zxv.source_system_book_id2,
				 zxv.source_system_book_id3,
				 zxv.source_system_book_id4 ,
				 zxv.fas_deal_type_value_id ,
				 zxv.fas_deal_sub_type_value_id ,
				 zxv.effective_start_date ,
				 zxv.end_date ,
				 zxv.percentage_included ,
				 zxv.sub_book_group1 ,
				 zxv.sub_book_group2 ,
				 zxv.sub_book_group3 ,
				 zxv.sub_book_group4  )
			WHEN MATCHED THEN
				UPDATE SET
				
				 source_system_book_id1 = zxv.source_system_book_id1 ,
				 source_system_book_id2 = zxv.source_system_book_id2,
				 source_system_book_id3 = zxv.source_system_book_id3,
				 source_system_book_id4 = zxv.source_system_book_id4,
				 fas_deal_type_value_id = zxv.fas_deal_type_value_id ,
				 fas_deal_sub_type_value_id = zxv.fas_deal_sub_type_value_id,
				 effective_start_date = zxv.effective_start_date,
				 end_date = zxv.end_date,
				 percentage_included = zxv.percentage_included,
				 sub_book_group1 = zxv.sub_book_group1,
				 sub_book_group2 = zxv.sub_book_group2,
				 sub_book_group3 = zxv.sub_book_group3,
				 sub_book_group4 = zxv.sub_book_group4;
				
		
	  --SELECT @fas_book_id = fas_book_id FROM #ztbl_xmlvalue
		--SELECT * FROM portfolio_hierarchy AS ph
		--SELECT * FROM fas_strategy AS fs

		
	--	EXEC dbo.spa_generate_hour_block_term 300501@block_value_id, NULL, NULL
		
		--Release Bookstructure cache key.
		IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
		BEGIN
			EXEC [spa_manage_memcache] @flag = 'd', @other_key_source='BookStructure', @source_object = 'spa_UpdateBookMappingXml @flag=iu'
		END

		EXEC spa_ErrorHandler 0
			, 'Source Deal Detail'
			, 'spa_getXml'
			, 'Success'
			, 'Changes have been saved successfully.'
			, ''				

		COMMIT
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK
		
	DECLARE @msg VARCHAR(5000)
	SELECT @msg = 'Failed Inserting record (' + ERROR_MESSAGE() + ').'
	
	EXEC spa_ErrorHandler @@ERROR
		, 'Source Deal Detail'
		, 'spa_UpdateBookStrategyXml'
		, 'DB Error'
		, @msg
		, 'Failed Inserting Record'
END CATCH



