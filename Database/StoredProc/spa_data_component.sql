IF OBJECT_ID(N'[dbo].[spa_data_component]', N'P') IS NOT NULL
  DROP PROCEDURE [dbo].[spa_data_component]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ============================================================================================================================
-- Create date: 2018-07-24 
-- Author : sbasnet@pioneersolutionsglobal.com
-- Description: SP for formula calculation using excel engine
-- ============================================================================================================================

CREATE PROCEDURE [dbo].spa_data_component
	  @flag 			CHAR(1),
	  @contract_group_detail_id INT = NULL,
	  @data_component_detail_id VARCHAR(1000) = NULL,
	  @xml	VARCHAR(MAX) = NULL,
	  @invoice_line_item_id INT = NULL,
	  @calc_id INT = NULL,
	  @contract_id INT = NULL
AS

SET NOCOUNT ON

DECLARE @user_name VARCHAR(100) = dbo.fnadbuser(),
	    @process_id	VARCHAR(200),
		@process_table VARCHAR(300),
		@sql VARCHAR(MAX),
		@formula_exists BIT = 0,
		@formula_ids VARCHAR(MAX) = NULL

IF @flag = 'c'
BEGIN
	SELECT CAST(data_component_id AS VARCHAR(10)) + '_' + CAST([type] AS VARCHAR(10))  [value], description [code]	
	FROM data_component
END

ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		DELETE dcd
		FROM data_component_detail dcd
		INNER JOIN dbo.FNASplit(@data_component_detail_id, ',') di ON di.item = dcd.data_component_detail_id

		EXEC spa_ErrorHandler 0,
            'Data Component',
            'spa_data_component',
            'Success',
            'Changes has been successfully saved.',
            @data_component_detail_id
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1,
			 'Data Component',
             'spa_data_component',
			 'Error',
			 'Error while saving changes. Try again.',
			 ''
	END CATCH
	
END

ELSE If @flag = 's'
BEGIN
	IF @xml IS NOT NULL
	BEGIN
	DECLARE @idoc INT
		BEGIN TRY
		IF OBJECT_ID('tempdb..#temp_data_component_detail') IS NOT NULL 
			DROP TABLE #temp_data_component_detail
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

		SELECT 
			NULLIF(data_component_detail_id,'') data_component_detail_id,
			NULLIF(contract_group_detail_id,'') contract_group_detail_id,		
			NULLIF(data_component_id,'') data_component_id,
			NULLIF(granularity,'') granularity,
			NULLIF([value],'') [value],
			NULLIF([formula_id],'') formula_id
		INTO #temp_data_component_detail 
		FROM OPENXML(@idoc,'/GridXML/GridRow',2) 
		WITH (
			data_component_detail_id			VARCHAR(300)		'@data_component_detail_id',
			contract_group_detail_id			VARCHAR(300)		'@contract_group_detail_id',
			data_component_id					VARCHAR(300)		'@data_component_id',
			granularity							VARCHAR(300)		'@granularity',
			[value]								VARCHAR(300)		'@value',
			[formula_id]						VARCHAR(300)		'@formula_id'
		)
		

		INSERT INTO data_component_detail(contract_group_detail_id,data_component_id,[value],granularity)
		SELECT tdcd.contract_group_detail_id
			  ,tdcd.data_component_id
			  ,IIF(dc.type = 107303,tdcd.formula_id,tdcd.[value])
			  ,tdcd.granularity 
		FROM #temp_data_component_detail tdcd
		LEFT JOIN data_component_detail dcd
			ON tdcd.data_component_detail_id = dcd.data_component_detail_id
		INNER JOIN data_component dc
			ON dc.data_component_id = tdcd.data_component_id
		WHERE dcd.data_component_detail_id IS NULL

		UPDATE dcd
		SET dcd.contract_group_detail_id = tdcd.contract_group_detail_id 
		   ,dcd.data_component_id = tdcd.data_component_id
		   ,dcd.[value] = IIF(dc.type = 107303,tdcd.formula_id,tdcd.[value])
		   ,dcd.granularity = tdcd.granularity 
		FROM #temp_data_component_detail tdcd
		LEFT JOIN data_component_detail dcd
			ON tdcd.data_component_detail_id = dcd.data_component_detail_id
		INNER JOIN data_component dc
			ON dc.data_component_id = tdcd.data_component_id
		WHERE dcd.data_component_detail_id IS NOT NULL

		EXEC spa_ErrorHandler 0,
            'Data Component',
            'spa_data_component',
            'Success',
            'Changes has been successfully saved.',
            ''

		END TRY
		BEGIN CATCH
			EXEC spa_ErrorHandler -1,
			 'Data Component',
             'spa_data_component',
			 'Error',
			 'Error while saving changes. Try again.',
			 ''
		END CATCH
	END
END

ELSE IF @flag = 'g'
BEGIN
	IF EXISTS(SELECT 1 FROM data_component dc
				INNER JOIN data_component_detail dcd
					ON dcd.data_component_id = dc.data_component_id
				WHERE contract_group_detail_id = @contract_group_detail_id
				AND dc.[type] = 107303
			 )
	BEGIN
		SELECT @formula_ids =  STUFF(
		(SELECT ',' + dcd.[value]
		FROM data_component dc
		INNER JOIN data_component_detail dcd
			ON dcd.data_component_id = dc.data_component_id
		WHERE contract_group_detail_id = @contract_group_detail_id
		AND dc.[type] = 107303
		FOR XML PATH('')),1,1,'')

		SET @process_id	= dbo.FNAGetNewId()
		SET @process_table = dbo.FNAProcessTableName('formula_editor', @user_name, @process_id)
		--EXEC spa_resolve_function_parameter @flag = 's',@process_id = @process_id, @formula_id = @formula_ids
		SET @formula_exists = 1
	END
	
	SET @sql = 'SELECT dcd.data_component_detail_id
					  ,CAST(dc.data_component_id AS VARCHAR(10)) + ''_'' + CAST(dc.[type] AS VARCHAR(10))  [data_component_id]
					  ,dcd.granularity
					  ,IIF(dc.type = 107303,NULL,dcd.[value]) [value] '
	IF @formula_exists = 1
		SET @sql += ',REPLACE(dbo.FNAFormulaFormatMaxString(fe.formula, ''r''),''<'',''&lt;'') [user_defined_function]'
	ELSE 
		SET @sql += ','''' [user_defined_function]'

	SET @sql +=	',IIF(dc.type = 107303,dcd.[value],NULL) [formula_id]
				FROM data_component_detail dcd 
				INNER JOIN data_component dc
					ON dc.data_component_id = dcd.data_component_id 
				LEFT JOIN formula_editor fe
					ON fe.formula_id = dcd.value
					'
	--IF @formula_exists = 1
	--	SET @sql += 'LEFT JOIN '+ @process_table + ' temp
	--					ON CAST(temp.formula_id AS VARCHAR(10)) = dcd.value '		
	SET @sql	+=	'WHERE 1 = 1
					'
	IF @contract_group_detail_id IS NOT NULL
		SET @sql = @sql + ' AND dcd.contract_group_detail_id = ''' + CAST(@contract_group_detail_id AS VARCHAR(20)) + ''''
	EXEC (@sql)
END

ELSE IF @flag = 'k'
BEGIN
	IF EXISTS(SELECT 1 FROM contract_group_detail WHERE contract_id = @contract_id AND invoice_line_item_id = @invoice_line_item_id AND radio_automatic_manual = 'e')
	BEGIN
		SELECT 1 [is_excel], ISNULL(NULLIF(calculated_excel_file,''),'error') [file_name]
		FROM calc_invoice_volume_variance
		WHERE calc_id = @calc_id
	END
	ELSE
	BEGIN
		SELECT 0 [is_excel], '' [file_name]
	END
END	
