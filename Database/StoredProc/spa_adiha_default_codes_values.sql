IF OBJECT_ID(N'[dbo].[spa_adiha_default_codes_values]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_adiha_default_codes_values]
GO
 
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
 
/**
	CRUD operations for menu Configuration Manager.

	Parameters:
		@flag				:	Operation flag. Does not accept NULL.
		@default_code_id	:	Identifier of Default Code, used as a filter to return specific data.
		@description		:	Unused Parameter.
		@xml				:	Default Code data in XML Format.
*/

CREATE PROCEDURE [dbo].[spa_adiha_default_codes_values]
	@flag VARCHAR(100),
	@default_code_id INT = NULL,
	@description VARCHAR(MAX) = NULL,
	@xml VARCHAR(MAX) = NULL 
AS
SET NOCOUNT ON

/** Debug Code **
DECLARE @flag VARCHAR(100)= NULL,
	@default_code_id INT = NULL,
	@description VARCHAR(MAX) = NULL,
	@xml VARCHAR(MAX) = NULL 

SELECT @flag='modify',@xml='<Root function_id = "20006200" object_id = "1"><GridGroup><Grid grid_id=""><GridRow  adiha_default_codes_values_id = "" default_code_id = "1" seq_no = "5" description = "5" var_value = "5" ></GridRow> <GridRow  adiha_default_codes_values_id = "" default_code_id = "1" seq_no = "6" description = "6" var_value = "6" ></GridRow> <GridRow  adiha_default_codes_values_id = "" default_code_id = "1" seq_no = "7" description = "7" var_value = "7" ></GridRow> </Grid></GridGroup></Root>'
--*/

DECLARE @sql VARCHAR(MAX),
	@adiha_default_codes_values_id INT = NULL,
	@instance_no VARCHAR(100) = NULL,
	@seq_no INT = NULL, 
	@var_value VARCHAR(100) = NULL,
	@idoc INT = NULL

IF @flag = 'combo_grid'
BEGIN
	SELECT adiha_default_codes_values_id,
		default_code_id,
		seq_no,
		var_value [description],
		var_value,
		[description] [sequence_desc]
	FROM adiha_default_codes_values
	WHERE default_code_id = @default_code_id
	ORDER BY seq_no ASC
END

ELSE IF @flag = 'text_grid'
BEGIN
    SELECT adiha_default_codes_values_id,
		default_code_id,
		seq_no,
		[description],
		var_value,
		instance_no [sequence_desc]
	FROM adiha_default_codes_values
	WHERE default_code_id = @default_code_id
	ORDER BY seq_no ASC
END

ELSE IF @flag = 'get_count'
BEGIN
    SELECT COUNT(1) FROM adiha_default_codes_values
	WHERE default_code_id = @default_code_id
END

ELSE IF @flag = 'modify'
BEGIN
	BEGIN TRY
		BEGIN TRAN

		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

		/*For Deletion Case*/
		SELECT NULLIF(adiha_default_codes_values_id, '') adiha_default_codes_values_id,
			NULLIF(default_code_id, '') default_code_id
		INTO #data_collection_to_delete
		FROM OPENXML (@idoc, '/Root/GridGroup/GridDelete/GridRow', 2)
		WITH (   
			adiha_default_codes_values_id INT '@adiha_default_codes_values_id',
			default_code_id INT '@default_code_id'
		)

		DELETE adcv
		FROM #data_collection_to_delete dctd
		INNER JOIN adiha_default_codes_values adcv
		ON adcv.adiha_default_codes_values_id = dctd.adiha_default_codes_values_id
			AND adcv.default_code_id = dctd.default_code_id
		/*Deletion case ends*/

		SELECT NULLIF (adiha_default_codes_values_id, '') adiha_default_codes_values_id,
			NULLIF (default_code_id, '') default_code_id,
			NULLIF (seq_no, '') seq_no,
			NULLIF (var_value, '') var_value,
			NULLIF ([description], '') [description],
			NULLIF (sequence_desc, '') [sequence_desc]
		INTO #data_collection_to_insert_or_update
		FROM OPENXML (@idoc, '/Root/GridGroup/Grid/GridRow', 2)
		WITH (
			adiha_default_codes_values_id INT '@adiha_default_codes_values_id',  
			default_code_id INT '@default_code_id', 
			seq_no INT '@seq_no',
			var_value VARCHAR(100) '@var_value',
			[description] VARCHAR(MAX) '@description',
			sequence_desc VARCHAR(MAX) '@sequence_desc'
		)

		-- CASE I: Text Mode
		IF (SELECT TOP 1 adcvp.[description] FROM #data_collection_to_insert_or_update tmp
			LEFT JOIN adiha_default_codes_values_possible adcvp
			ON adcvp.default_code_id = tmp.default_code_id
				AND adcvp.var_value = tmp.var_value
			) IS NULL
		BEGIN
			MERGE adiha_default_codes_values AS target
			USING #data_collection_to_insert_or_update AS source
			ON (target.default_code_id = source.default_code_id AND target.adiha_default_codes_values_id = source.adiha_default_codes_values_id)
			WHEN MATCHED THEN
				UPDATE SET [description] = source.[description]
					, var_value = source.var_value
					, seq_no = source.seq_no
			WHEN NOT MATCHED THEN
				INSERT (instance_no, default_code_id, seq_no, [description], var_value)
				VALUES (1, source.default_code_id, source.seq_no, source.[description], source.var_value);
		END
		-- CASE II: Combo Mode
		ELSE
		BEGIN
			MERGE adiha_default_codes_values AS target
			USING #data_collection_to_insert_or_update AS source
			ON (target.default_code_id = source.default_code_id AND target.adiha_default_codes_values_id = source.adiha_default_codes_values_id)
			WHEN MATCHED THEN
				UPDATE SET [description] = source.sequence_desc
					, var_value = source.var_value
					, seq_no = source.seq_no
			WHEN NOT MATCHED THEN
				INSERT (instance_no, default_code_id, seq_no, [description], var_value)
				VALUES (1, source.default_code_id, source.seq_no, source.sequence_desc, source.var_value);
		END

		COMMIT TRAN

		EXEC spa_ErrorHandler 0
			, 'Adiha Default Codes Values'
			, 'spa_adiha_default_codes_values_new'
			, 'Success'
			, 'Changes have been saved successfully.'
			, default_code_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRAN

		DECLARE @err VARCHAR(MAX) = 'Duplicate Data In <b>Detail Grid (Sequence)</b>.' + ERROR_MESSAGE()

		EXEC spa_ErrorHandler -1
		   , 'Adiha Default Codes Values'
		   , 'spa_adiha_default_codes_values_new'
		   , 'Error'
		   , @err
		   , seq_no  
	END CATCH
END

ELSE IF @flag = 'update'
BEGIN
	IF OBJECT_ID('tempdb..#data_collection_to_update') IS NOT NULL
		DROP TABLE #data_collection_to_update

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
	
	SELECT NULLIF (adiha_default_codes_values_id, '') adiha_default_codes_values_id,
		NULLIF (default_code_id, '') default_code_id,
		NULLIF (seq_no, '') seq_no,
		NULLIF (var_value, '') var_value,
		NULLIF (instance_no, '') instance_no,
		NULLIF ([description], '') [description]
	INTO #data_collection_to_update
	FROM OPENXML (@idoc, '/Root/GridGroup/Grid/GridRow', 2)
	WITH (
		adiha_default_codes_values_id INT '@adiha_default_codes_values_id',  
		default_code_id INT '@default_code_id',
		seq_no INT '@seq_no',
		var_value VARCHAR(100) '@var_value',
		instance_no VARCHAR(100) '@instance_no',
		[description] VARCHAR(MAX) '@description'			
	)

	IF (SELECT TOP 1 adcvp.[description] FROM #data_collection_to_update tmp
		LEFT JOIN adiha_default_codes_values_possible adcvp
		ON adcvp.default_code_id = tmp.default_code_id
			AND adcvp.var_value = tmp.var_value
		) IS NOT NULL
	BEGIN
		UPDATE tmp
		SET tmp.[description] = adcvp.[description]
		FROM #data_collection_to_update tmp
		INNER JOIN adiha_default_codes_values_possible adcvp
		ON adcvp.default_code_id = tmp.default_code_id
			AND adcvp.var_value = tmp.var_value
	END

	BEGIN TRY
		--SELECT adcv.description, dctu.description
		UPDATE adcv
		SET [description] = dctu.[description]
			, var_value = dctu.var_value
			, seq_no = dctu.seq_no
		FROM adiha_default_codes_values adcv
		INNER JOIN #data_collection_to_update dctu ON dctu.default_code_id = adcv.default_code_id
			AND dctu.adiha_default_codes_values_id = adcv.adiha_default_codes_values_id

		EXEC spa_ErrorHandler 0
			, 'Adiha Default Codes Values'
			, 'spa_adiha_default_codes_values_new'
			, 'Success'
			, 'Changes have been saved successfully.'
			, default_code_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRAN
		
		EXEC spa_ErrorHandler -1
		   , 'Adiha Default Codes Values'
		   , 'spa_adiha_default_codes_values_new'
		   , 'Error'
		   , 'Duplicate Data In <b>Detail Grid (Sequence)</b>.'
		   , seq_no 
	END CATCH
END

IF @flag = 'load_combo'
BEGIN
	SELECT adcv.var_value [id],
		adcv.[description] [value]
	FROM adiha_default_codes_values_possible adcv
	WHERE adcv.default_code_id = @default_code_id
END

ELSE IF @flag = 'left_grid'
BEGIN
	SELECT DISTINCT
		adc.default_code_id,
		adc.code_def,
		CASE WHEN adcvp.var_value IS NOT NULL
			THEN 'combo'
			ELSE 'text'
		END [combo_or_text],
		instances [sequence]
	FROM adiha_default_codes adc
	LEFT JOIN adiha_default_codes_values_possible adcvp
		ON adcvp.default_code_id = adc.default_code_id
END

GO