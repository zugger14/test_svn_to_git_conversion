IF OBJECT_ID(N'[dbo].[spa_counterparty_contract_type]', N'P') IS NOT NULL    
	DROP PROCEDURE [dbo].[spa_counterparty_contract_type]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Procedure that is used for CRUD operations in Counterparty Contracts Type.

	Parameters:
		@flag								:	Operation flag that decides the logic to be executed.
		@counterparty_contract_type_id		:	Numeric Identifier of Counterparty Contract.
		@xml_data							:	Data related to counterparty contracts in XML format for insert/update.
		@category							:	TBD.
		@notes_object						:	TBD.
		@download_url						:	Not in use.
		@counterparty_id					:	Numeric Identifier of Counterparty.
		@counterparty_contract_address_id	:	Numeric Identifier of counterparty contract address.
		@counterparty_contract_type			:	Numeric Identifier of type of counterparty contract.
		@xml								:	Multiple counterparty contract types identifier in XML format for deletion.
*/

CREATE PROCEDURE [dbo].[spa_counterparty_contract_type] 
	@flag									CHAR(1),
	@counterparty_contract_type_id			NVARCHAR(200) = NULL,
	@xml_data								NVARCHAR(MAX) = NULL,
	@category								INT = NULL,
	@notes_object							INT = NULL,
	@download_url							NVARCHAR(200) = NULL,
	@counterparty_id						INT = NULL,
	@counterparty_contract_address_id		INT = NULL,
	@counterparty_contract_type				NVARCHAR(30) = NULL,
	@xml									TEXT = NULL
AS

/** Debug Mode
DECLARE @flag									CHAR(1),
	@counterparty_contract_type_id			NVARCHAR(200) = NULL,
	@xml_data								NVARCHAR(MAX) = NULL,
	@category								INT = NULL,
	@notes_object							INT = NULL,
	@download_url							NVARCHAR(200) = NULL,
	@counterparty_id						INT = NULL,
	@counterparty_contract_address_id		INT = NULL,
	@counterparty_contract_type				NVARCHAR(30) = NULL,
	@xml									XML = NULL

	--select  @flag='i',@xml_data='<Root><CounterpartyContractTypeLog  counterparty_contract_type_id="" counterparty_contract_address_id="3604" counterparty_id="11105" contract_id="14340" counterparty_contract_type="105804" description="testaabc" ammendment_date="2020-06-10" number="4" contract_status="1900" /><ApplicationNotes  category_id ="56" sub_category_id ="" notes_object_id ="3604" parent_object_id ="" notes_subject ="105804" file_attachment ="" /></Root>'
	SELECT @flag = 'k', @counterparty_id = 11105, @counterparty_contract_address_id = 3604, @counterparty_contract_type = NULL
--*/

SET NOCOUNT ON;

DECLARE @idoc INT

DECLARE @notes_flag CHAR(1),
		@category_id INT,
		@object_id INT,
		@parent_object_id INT,
		@notes_subject NVARCHAR(500),
		@application_notes_id INT,
		@new_counterparty_contract_type_id INT,
		@category_name NVARCHAR(100),
		@file_attachment NVARCHAR(100),
		@notes_attachment NVARCHAR(200),
		@sql NVARCHAR(max)


DECLARE @alert_process_id VARCHAR(200)
DECLARE @alert_process_table VARCHAR(500)
SET @alert_process_id = dbo.FNAGetNewID()  
SET @alert_process_table = 'adiha_process.dbo.alert_counterparty_contract_type_' + @alert_process_id + '_cct'

IF @flag = 'i'
BEGIN
	BEGIN TRY
	BEGIN TRAN 	
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_data

		IF OBJECT_ID('tempdb..#tmp_counterparty_contract') IS NOT NULL
			DROP TABLE #tmp_counterparty_contract
		
		SELECT	counterparty_contract_type_id			[counterparty_contract_type_id],
				counterparty_contract_address_id		[counterparty_contract_address_id],
				counterparty_id							[counterparty_id],
				contract_id								[contract_id],
				counterparty_contract_type				[counterparty_contract_type],
				[description]							[description],
				NULLIF(ammendment_date,'') 				[ammendment_date],
				NULLIF(number,'')						[number],
				NULLIF(contract_status,'')				[contract_status]
		INTO #tmp_counterparty_contract
		FROM OPENXML(@idoc, '/Root/CounterpartyContractTypeLog', 1)
		WITH (
			counterparty_contract_type_id		NVARCHAR(10),
			counterparty_contract_address_id	NVARCHAR(10),
			counterparty_id						NVARCHAR(10),
			contract_id							NVARCHAR(10),
			counterparty_contract_type			NVARCHAR(10),
			[description]						NVARCHAR(MAX),
			ammendment_date						DATETIME,
			number								NVARCHAR(10),
			contract_status						NVARCHAR(10)
		)


		IF OBJECT_ID('tempdb..#tmp_app_notes') IS NOT NULL
			DROP TABLE #tmp_app_notes
		
		SELECT	category_id			[category_id],
				sub_category_id		[sub_category_id],
				notes_object_id		[notes_object_id],
				parent_object_id	[parent_object_id],
				notes_subject		[notes_subject],
				file_attachment		[file_attachment]
		INTO #tmp_app_notes
		FROM OPENXML(@idoc, '/Root/ApplicationNotes', 1)
		WITH (
			category_id				NVARCHAR(10),
			sub_category_id			NVARCHAR(10),
			notes_object_id			NVARCHAR(10),
			parent_object_id		NVARCHAR(10),
			notes_subject			NVARCHAR(500),
			file_attachment			NVARCHAR(200)
		)
		--SELECT * FROM #tmp_counterparty_contract
		--SELECT * FROM #tmp_app_notes COMMIT  RETURN 
		/*
		 * INSERT/UPDATE in application notes.
		 */
		
		SELECT	@category_id = t.category_id,
				@object_id = t.notes_object_id,
				@parent_object_id = ISNULL(NULLIF(t.parent_object_id,''),t.notes_object_id),
				@notes_subject = sdv.code,
				@file_attachment = t.file_attachment
		FROM #tmp_app_notes t
		LEFT JOIN static_data_value sdv ON sdv.value_id = t.notes_subject AND sdv.[type_id] = 105800 
	
		SELECT @category_name = code FROM static_data_value WHERE value_id = @category_id
		SET @notes_attachment = '../../../adiha.php.scripts/dev/shared_docs/attach_docs/' + @category_name + '/' + @file_attachment
		
		IF EXISTS (SELECT 1 FROM #tmp_counterparty_contract WHERE counterparty_contract_type_id = '')
		BEGIN	
			SET @notes_flag = 'i'
			SET @application_notes_id = ''
		END	
		ELSE
		BEGIN
			SET @notes_flag = 'u'
			SELECT @application_notes_id = cct.application_notes_id FROM #tmp_counterparty_contract tmp
			INNER JOIN counterparty_contract_type cct ON tmp.counterparty_contract_type_id = cct.counterparty_contract_type_id
		END

		IF OBJECT_ID('tempdb..#error_status') IS NOT NULL
			DROP TABLE #error_status
		CREATE TABLE #error_status (error_code NVARCHAR(20) COLLATE DATABASE_DEFAULT, module NVARCHAR(20) COLLATE DATABASE_DEFAULT, area NVARCHAR(20) COLLATE DATABASE_DEFAULT, [status] NVARCHAR(20) COLLATE DATABASE_DEFAULT, [message] NVARCHAR(100) COLLATE DATABASE_DEFAULT, recommendation NVARCHAR(100) COLLATE DATABASE_DEFAULT)

		INSERT INTO #error_status (error_code, module, area, [status], [message], recommendation)
		EXEC spa_post_template	@flag = @notes_flag,
								@notes_subject = @notes_subject,
								@internal_type_value_id = @category_id,
								--@category_value_id = 42027,
								@notes_object_id = @object_id,
								@parent_object_id = @parent_object_id,
								@notes_share_email_enable = 0,
								@notes_id = @application_notes_id,
								@doc_file_name = @notes_attachment,
								@doc_file_unique_name = @file_attachment 
 					
		IF @notes_flag = 'i'
		BEGIN
			SET @application_notes_id = IDENT_CURRENT('application_notes')						
		END
		
		/*
		 * INSERT/UPDATE in counterparty_contract log
		 */
	
		IF @notes_flag = 'i'
		BEGIN
			INSERT INTO counterparty_contract_type ( 		 
				counterparty_contract_address_id,		 
				counterparty_id,							 
				contract_id,									
				counterparty_contract_type,	
				application_notes_id,
				[description],
				ammendment_date,
				number,
				contract_status
			)
			SELECT 
				NULLIF(counterparty_contract_address_id,''),
				NULLIF(counterparty_id,''),
				NULLIF(contract_id,''),
				NULLIF(counterparty_contract_type,''), 
				@application_notes_id,
				NULLIF([description],''),
				ammendment_date,
				NULLIF([number],''),
				NULLIF([contract_status],'')
			FROM #tmp_counterparty_contract 
			WHERE counterparty_contract_type_id = ''

			SET @new_counterparty_contract_type_id = SCOPE_IDENTITY()	
		END
		ELSE 
		BEGIN
			UPDATE cct
				SET cct.counterparty_contract_type = ti.counterparty_contract_type, 
					cct.application_notes_id = @application_notes_id,
					cct.[description] = ti.[description],
					cct.ammendment_date = ti.ammendment_date,
					cct.number = ti.number,
					cct.contract_status = ti.contract_status
			FROM counterparty_contract_type cct
			INNER JOIN #tmp_counterparty_contract ti ON cct.counterparty_contract_type_id = ti.counterparty_contract_type_id

			SELECT @new_counterparty_contract_type_id = counterparty_contract_type_id FROM #tmp_counterparty_contract
		END
		
		COMMIT 

		SET @sql = 'CREATE TABLE ' + @alert_process_table + '
					(
						counterparty_contract_type_id INT
					)
					INSERT INTO ' + @alert_process_table + '(
						counterparty_contract_type_id
					)
					SELECT ' + CAST(@new_counterparty_contract_type_id AS VARCHAR)
		EXEC(@sql)

		-- Start Alert/Workflow Process
		EXEC spa_register_event 20636, 10000326, @alert_process_table, 1, @alert_process_id
		EXEC spa_register_event 20636, 10000327, @alert_process_table, 1, @alert_process_id

		EXEC spa_ErrorHandler 0
			, 'spa_counterparty_contract_type' 
			, 'counterparty_contract_type'
			, 'counterparty_contract_type'
			, 'Change have been saved successfully.'
			, @new_counterparty_contract_type_id
	END TRY 
	BEGIN CATCH
	--print error_message()
		EXEC spa_ErrorHandler -1
			,'spa_counterparty_contract_type' 
			, 'counterparty_contract_type'
			, 'counterparty_contract_type'
			, 'Failed adding counterparty_contract'
			, ''
		ROLLBACK  
	END CATCH
END

ELSE IF @flag = 'f'
BEGIN
	SELECT notes_attachment,
		attachment_file_name
	FROM application_notes an
	LEFT JOIN counterparty_contract_type cct ON an.notes_id = cct.application_notes_id
	WHERE counterparty_contract_type_id = @counterparty_contract_type_id
END

ELSE IF (@flag = 'k')  --load grid data in Counterparty Contract Type grid
BEGIN
	SET @sql = '
		SELECT cct.counterparty_contract_type_id [ID],
			cct.counterparty_contract_address_id [Counterparty Contract Address ID],
			sc.counterparty_id [Counterparty],
			sdv.code [Counterparty Contract Type],
			cct.counterparty_contract_type [Counterparty Contract Type ID],
			an.attachment_file_name [Attached Document],
			cct.description [Description],
			dbo.FNAUserDateFormat(cct.ammendment_date, dbo.FNADBuser()) [Ammendment Date],
			cct.number [Number],
			sdv1.code [Contract Status],
			cct.contract_status [Contract Status ID]
		FROM counterparty_contract_type cct
		LEFT JOIN application_notes an ON an.notes_id = cct.application_notes_id
		LEFT JOIN source_counterparty AS sc ON sc.source_counterparty_id = cct.counterparty_id
		LEFT JOIN static_data_value AS sdv ON sdv.value_id = cct.counterparty_contract_type
		LEFT JOIN static_data_value AS sdv1 ON sdv1.value_id = cct.contract_status
		WHERE 1=1 AND cct.counterparty_contract_address_id = ' +  CAST(NULLIF(@counterparty_contract_address_id, -1) AS NVARCHAR) + '
	' +
	CASE
		WHEN @counterparty_contract_type =  'NULL' THEN ' '
		ELSE ' AND cct.counterparty_contract_type = ' +  @counterparty_contract_type + ''
	END

	EXEC spa_print @sql
	EXEC(@sql)	
END

ELSE IF (@flag = 'd')  --deleting grid data in Counterparty Contract Type grid
BEGIN 
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
	
	IF OBJECT_ID('tempdb..#tmp_counterparty_contract_delete_detail') IS NOT NULL
		DROP TABLE #tmp_counterparty_contract_delete_detail 

	SELECT grid_id
	INTO #tmp_counterparty_contract_delete_detail 
	FROM OPENXML(@idoc, '/Root/GridDelete', 1)
	WITH (
		grid_id INT
	)
	
	DELETE cct
	FROM counterparty_contract_type cct 
	INNER JOIN  #tmp_counterparty_contract_delete_detail  tcdd ON cct.counterparty_contract_type_id = tcdd.grid_id 
	
	EXEC spa_ErrorHandler 0
		, 'CreditBlock'
		, 'spa_counterparty_contract_address'
		, 'Success' 
		, 'Changes have been saved successfully.'
		, ''
END

GO
