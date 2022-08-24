IF OBJECT_ID(N'[dbo].[spa_generate_document]', N'P') IS NOT NULL    
	DROP PROCEDURE [dbo].[spa_generate_document]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 /**
	Wrapper procedure for document generation logic

	Parameters :
	@event_message_id : Event Message Id (event_message_id from workflow_event_message)
	@process_table : Process table that contains the data to be processed from workflow
	@workflow_process_id : Unique Identifier for Process
	@document_category : Document Category (static_data_value - type_id = 25)
	@document_sub_category : Document Sub Category (static_data_value - type_id = 42000)
	@filter_object_id : Value of the primary column of the workflow module
	@temp_generate : 0 - Save in modules folder and in tables, 1 - save in temp note for temporary
	@get_generated : 0 - always generated new document, 1 - Get Already Generated document if available else generate new
	@show_output : 0 - Dont show ooutput, 1- Show Output
    @user_login_id: User login id used to determine number format.
 */


/*
 * DOCUMENT GENERATION FROM WORKFLOW
	- @event_message_id, @process_table, @workflow_process_id parameters are used
 * DOCUMENT GENERATION FROM OTHER SCREEN
	- @document_category, @document_sub_category, @filter_object_id

 * LOGIC DESCRIPTION
	- Collect all the documents to be generated in #tmp_document_details.
		- For workflow, the list is generated as defined in the workflow
		- For others, the list is the parameters - @document_category, @document_sub_category, @filter_object_id
	- Logic for each document category/sub category is triggered. 
		- Criteria is build for RDL or WORD document or EXCEL document.
		- FOR WORKFLOW - Emaling list is collected
	- Template ID is generated from FNAGetDocumentTemplate
	- Logic for WORD or RDL or EXCEL will be called based on document type of the generated Template ID
		- FOR RDL -> spa_export_RDL
		- FOR WORD -> spa_generate_document_word
		- FOR EXCEL -> spa_generate_document_excel
	- After document is generated, the document will be inserted in the application_notes
	- FOR WORKFLOW - If contracts are defined then document will be emailed.
	- FOR Workflow - The generated document will be updated in the process table and further be used in workflow logic.
*/

CREATE PROCEDURE [dbo].[spa_generate_document]
	@event_message_id		VARCHAR(100) = NULL,
	@process_table			VARCHAR(100) = NULL,
	@workflow_process_id	VARCHAR(300) = NULL,
	@document_category		INT = NULL,
	@document_sub_category	INT = NULL,
	@filter_object_id		VARCHAR(MAX) = NULL,
	@temp_generate			INT = 0,
	@get_generated			INT = 0,
	@show_output			INT = 0,
	@user_login_id          NVARCHAR(500) = NULL
AS
SET NOCOUNT ON; 

/*
DECLARE @event_message_id		INT = 1236
DECLARE @process_table			VARCHAR(100) = NULL
DECLARE @workflow_process_id	VARCHAR(300) = '131231231231231213'
DECLARE @document_category		INT = 33
DECLARE @document_sub_category	INT = 42018
DECLARE @filter_object_id		INT = 215678
DECLARE @temp_generate			INT = 0
DECLARE @get_generated			INT = 1
DECLARE @show_output			INT = 1
--*/

IF @user_login_id IS NULL
	SET @user_login_id = dbo.FNADBUser(); 

DECLARE @user					NVARCHAR(200) = dbo.FNADBUser() 
DECLARE @sql					NVARCHAR(2000),
		@document_path			VARCHAR(300),
		@attachment_files		NVARCHAR(MAX),
		@object_id				VARCHAR(MAX) = '',
		@object_detail_id		INT = '',
		@criteria_for_rdl		VARCHAR(1000),
		@criteria_for_word_doc	VARCHAR(1000) = NULL,
		@criteria_for_excel_doc	VARCHAR(MAX) = NULL,
		@xml_count				INT = 0,
		@is_create_xml			CHAR(1) = 'n',
		@send_email				VARCHAR(300) = NULL,
		@send_email_cc			VARCHAR(300) = NULL,
		@send_email_bcc			VARCHAR(300) = NULL,
		@att_file_string		NVARCHAR(MAX) = NULL,
		@counterparty_name		NVARCHAR(1000) = '', 
		@generated_document		NVARCHAR(1000) = NULL
DECLARE @objects	VARCHAR(MAX) = NULL
		,@module_id INT
	   ,@email_address_query VARCHAR(MAX)
	   ,@group_type CHAR(1)
	   ,@email_data_id INT
	   ,@previous_id INT
	   ,@current_id INT
	   ,@email_subject_input VARCHAR(1500)
	   ,@email_message_input VARCHAR(MAX)
	   ,@email_subject_output VARCHAR(1500)
	   ,@email_message_output VARCHAR(MAX)
	   ,@error_message VARCHAR(1000)
	   ,@get_generated_workflow INT = 0


SELECT	@document_path = document_path + '\attach_docs\'
FROM connection_string

IF OBJECT_ID('tempdb..#tmp_document_details') IS NOT NULL
	DROP TABLE #tmp_document_details

CREATE TABLE #tmp_document_details (
	[message_document_id]			INT,
	[document_category_id]			INT,
	[document_category_name]		VARCHAR(1000) COLLATE DATABASE_DEFAULT,
	[document_sub_category]			INT,
	[document_sub_category_name] 	VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[default_document_template]		INT
)
    
IF OBJECT_ID('tempdb..#tmp_ids') IS NOT NULL
	DROP TABLE #tmp_ids
IF OBJECT_ID('tempdb..#notes') IS NOT NULL
	DROP TABLE #notes
IF OBJECT_ID('tempdb..#contract_report_template_tbl') IS NOT NULL
	DROP TABLE #contract_report_template_tbl
IF OBJECT_ID('tempdb..#invoices') IS NOT NULL
	DROP TABLE #invoices
IF OBJECT_ID('tempdb..#invoice_netting') IS NOT NULL
	DROP TABLE #invoice_netting
IF OBJECT_ID('tempdb..#invoice_netting_template') IS NOT NULL
	DROP TABLE #invoice_netting_template
IF OBJECT_ID('tempdb..#contract_report_template') IS NOT NULL
	DROP TABLE #contract_report_template

CREATE TABLE #tmp_ids (obj_id INT)

IF OBJECT_ID('tempdb..#tmp_ctpy_email') IS NOT NULL
		DROP TABLE #tmp_ctpy_email
CREATE TABLE #tmp_ctpy_email (message_detail_id INT, counterparty_id INT, counterparty_email VARCHAR(100) COLLATE DATABASE_DEFAULT , email_cc VARCHAR(100) COLLATE DATABASE_DEFAULT , email_bcc VARCHAR(100) COLLATE DATABASE_DEFAULT )
	
IF OBJECT_ID('tempdb..#tmp_status') IS NOT NULL
		DROP TABLE #tmp_status
CREATE TABLE #tmp_status (message_document_id INT, [status] VARCHAR(10) COLLATE DATABASE_DEFAULT , [message] VARCHAR(5000) COLLATE DATABASE_DEFAULT )

CREATE TABLE #notes(notes_id INT, [object_id] INT, output_file_name VARCHAR(1000), generated_document NVARCHAR(2000))

IF @get_generated = 1
BEGIN
	IF @process_table IS NOT NULL
	BEGIN
		SET @get_generated_workflow = 1
	END
	
	DECLARE @notes_id INT
	INSERT INTO #notes(notes_id, [object_id], output_file_name, generated_document)
	SELECT MAX(notes_id), a.item, MAX(attachment_file_name) attachment_file_name, @document_path + MAX(sdv.code) + '\' + MAX(attachment_file_name) generated_document
	FROM application_notes an
	INNER JOIN dbo.SplitCommaSeperatedValues(@filter_object_id) a ON a.item = ISNULL(parent_object_id, notes_object_id)
	LEFT JOIN static_data_value sdv ON sdv.value_id = an.internal_type_value_id
	WHERE internal_type_value_id = @document_category AND category_value_id = @document_sub_category AND ISNUMERIC(a.item) = 1
	GROUP BY a.item

	/* Check if the document has been generated and saved or not */
	--IF EXISTS (SELECT 1 FROM application_notes WHERE notes_id = @notes_id)
	--BEGIN
	--	SELECT @generated_document = @document_path + sdv.code + '\' + attachment_file_name FROM application_notes an
	--	INNER JOIN static_data_value sdv ON sdv.value_id = an.internal_type_value_id
	--	WHERE notes_id = @notes_id
	--END
END
--ELSE
--BEGIN
--	SET @generated_document = NULL
--END

--set @generated_document = null
 IF EXISTS(SELECT 1 FROM #notes WHERE generated_document IS NULL) OR NOT EXISTS(SELECT 1 FROM #notes)
BEGIN
 
	/* 
	 * COLLECT THE LIST TO GENERATE DOCUMENT FROM WORKFLOW
	 */
	IF @event_message_id IS NOT NULL
	BEGIN
		INSERT INTO #tmp_document_details
		SELECT	wemd.message_document_id [message_document_id],
				sdv.value_id [document_category_id],
				sdv.code [document_category_name],
				wemd.document_category [document_sub_category],
				sdv1.code [document_sub_category_name],
				wemd.document_template [default_document_template]
		FROM workflow_event_message_documents wemd
		INNER JOIN static_data_value sdv ON wemd.document_template_id = sdv.value_id
		LEFT JOIN static_data_value sdv1 ON wemd.document_category = sdv1.value_id
		INNER JOIN dbo.SplitCommaSeperatedValues(@event_message_id) a ON a.item = wemd.event_message_id
		WHERE ISNUMERIC(a.item) = 1
	END
	ELSE 
	/* 
	 * COLLECT THE LIST TO GENERATE DOCUMENT FOR SPECIFIC OBJECT
	 */
	BEGIN
		DECLARE @tmp_doc_category_name VARCHAR(100), @tmp_doc_category_sub_name VARCHAR(100)
		SELECT @tmp_doc_category_name = code FROM static_data_value WHERE value_id = ABS(@document_category)
		SELECT @tmp_doc_category_sub_name = code FROM static_data_value WHERE value_id = @document_sub_category

		INSERT INTO #tmp_document_details
		SELECT  -1							[message_document_id],
				@document_category			[document_category_id],
				@tmp_doc_category_name		[document_category_name],
				@document_sub_category		[document_sub_category],
				@tmp_doc_category_sub_name	[document_sub_category_name],
				NULL						[default_document_template]
	END
END

		CREATE TABLE #invoices(invoice_id INT)
		CREATE TABLE #invoice_netting(id INT IDENTITY(1,1), invoice_id INT, netting_id INT) 
		CREATE TABLE #invoice_netting_template(id INT IDENTITY(1,1), invoice_id INT, template_id INT, main_invoice_id INT) 
		CREATE TABLE #contract_report_template(id INT IDENTITY(1,1), invoice_id INT, main_invoice_id INT, document_type VARCHAR(10), template_id INT, template_name VARCHAR(50), [filename] VARCHAR(1000), xml_map_filename VARCHAR(200), excel_sheet_id INT, output_file_name VARCHAR(1000), output_file_path VARCHAR(2000), criteria_for_excel_doc VARCHAR(2000))
 
DECLARE	@template_id INT, @templates VARCHAR(MAX),
		@document_type CHAR(1), 
		@template_name VARCHAR(100), 
		@report_filename VARCHAR(100), 
		@xml_map_filename VARCHAR(100),
		@excel_sheet_id INT,
		@primary_column NVARCHAR(500)

DECLARE @cur_message_document_id INT,
		@cur_document_category_id INT, 
		@cur_document_category_name VARCHAR(100), 
		@cur_document_sub_category INT, 
		@cur_document_sub_category_name VARCHAR(100),
		@cur_default_document_template INT 

DECLARE @rdl_sql VARCHAR(2000), @process_id VARCHAR(50), @process_id_main VARCHAR(50) = dbo.FNAGetNewID()

DECLARE @contract_report_template_tbl VARCHAR(200) = 'adiha_process.dbo.contract_report_template_exceldoc_' + @process_id_main
--select dbo.FNAProcessTableName('contract_report_template_exceldoc', '', dbo.FNAGetNewID())
SET @sql = ' CREATE TABLE ' + @contract_report_template_tbl + '(id INT IDENTITY(1,1), invoice_id INT, main_invoice_id INT, process_id VARCHAR(50), excel_sheet_id INT, criteria VARCHAR(1000), export_format VARCHAR(20), 
template_type VARCHAR(20), [user_name] VARCHAR(50), output_file_name VARCHAR(300), output_file_path VARCHAR(300), cur_message_document_id INT, template_id INT, document_type CHAR(1), [status] BIT, notes_subject VARCHAR(1000), notes_attachment VARCHAR(1000) )
'
EXEC(@sql)

CREATE TABLE #contract_report_template_tbl (id INT IDENTITY(1,1), invoice_id INT, main_invoice_id INT, process_id VARCHAR(50), excel_sheet_id INT, criteria VARCHAR(1000), export_format VARCHAR(20), 
template_type VARCHAR(20), [user_name] VARCHAR(50), output_file_path VARCHAR(300), cur_message_document_id INT, template_id INT, document_type CHAR(1), cur_document_category_name VARCHAR(100)
, cur_document_sub_category_name VARCHAR(100), counterparty_name VARCHAR(200), output_file_name VARCHAR(300), cur_document_sub_category INT, [status] BIT
)


IF OBJECT_ID('tempdb..#error_status') IS NOT NULL
	DROP TABLE #error_status
CREATE TABLE #error_status (error_code VARCHAR(20) COLLATE DATABASE_DEFAULT , module VARCHAR(20) COLLATE DATABASE_DEFAULT , area VARCHAR(20) COLLATE DATABASE_DEFAULT , [status] VARCHAR(20) COLLATE DATABASE_DEFAULT , [message] VARCHAR(100) COLLATE DATABASE_DEFAULT , recommendation VARCHAR(100) COLLATE DATABASE_DEFAULT )

IF CURSOR_STATUS('global','document_cursor')>=-1
BEGIN
	DEALLOCATE document_cursor
END

DECLARE document_cursor CURSOR FOR
SELECT	message_document_id, 
		document_category_id, 
		document_category_name, 
		document_sub_category, 
		document_sub_category_name, 
		default_document_template 
FROM #tmp_document_details
ORDER BY document_category_id, CASE document_sub_category WHEN 42031 THEN 2 WHEN 42047 THEN 1 END ASC

OPEN document_cursor
FETCH NEXT FROM document_cursor
INTO @cur_message_document_id, @cur_document_category_id, @cur_document_category_name, @cur_document_sub_category, @cur_document_sub_category_name, @cur_default_document_template

WHILE @@FETCH_STATUS = 0
BEGIN
	TRUNCATE TABLE #invoices
	TRUNCATE TABLE #invoice_netting
	TRUNCATE TABLE #invoice_netting_template
	TRUNCATE TABLE #contract_report_template
	TRUNCATE TABLE #contract_report_template_tbl
	EXEC('TRUNCATE TABLE ' + @contract_report_template_tbl)
	/*
	-- @object_id is used for filter such as source_deal_header_id, counterparty_id
	-- @object_detail_id is id used in saved in application_notes table. If same @object_id has multiple document then, @object_detail_id is different than @object_id
		else @object_id and @object_detail_id are same.
	-- Eg - In case of deal confirmation, source_deal_header_id has multiple confirmation so, @object_id = source_deal_header_id and @object_detail_id = confirm_status_id
	-- Eg - In case of invoice, calc_id has only one invoice so, @object_id and @object_detail_id are same
	*/

	/* 
	 * LOGIC FOR DEAL CONFIRMATION
	 */
	IF @cur_document_category_id = 33 AND (@cur_document_sub_category = 42018 OR @cur_document_sub_category = 42021)
	BEGIN
		IF @process_table IS NOT NULL
		BEGIN
			EXEC('INSERT INTO #tmp_ids SELECT source_deal_header_id [obj_id] FROM ' + @process_table)
			SELECT @object_id = obj_id FROM #tmp_ids
		END
		ELSE
		BEGIN
			SELECT @object_id = @filter_object_id
		END

		SELECT @object_detail_id = MAX(confirm_status_id) FROM confirm_status WHERE source_deal_header_id = @object_id
		SET @criteria_for_rdl = 'export_type:PDF,source_deal_header_id:' + CAST(@object_id AS VARCHAR)+',user_login_id:' + CAST(@user_login_id AS VARCHAR)
		SET @criteria_for_word_doc = 'source_deal_header_id = '+ CAST(@object_id AS VARCHAR)
		SET @criteria_for_excel_doc = '<Parameters><Parameter><Name>source_deal_header_id</Name><Value>' + CAST(@object_id AS VARCHAR) + '</Value></Parameter></Parameters>'


		-- GETTING COUNTERPARTY NAME TO ADD IN GENERATED FILE NAME
		SELECT @counterparty_name = sc.counterparty_name
		FROM source_deal_header sdh
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = CASE WHEN @document_sub_category = 42018 THEN sdh.counterparty_id ELSE sdh.counterparty_id2 END
		INNER JOIN dbo.SplitCommaSeperatedValues(@filter_object_id) a ON a.item = sdh.source_deal_header_id
		WHERE  ISNUMERIC(a.item) = 1

		/*
		 * DATA COLLECTION FOR WORKFLOW CONTACTS EMAIL LOGIC
		 * Logic to email contact type and internal contact type for counterparty and counterparty2.
		 * ONLY USEFUL WHERE GENERATED FROM WORKFLOW
		 */	
		IF @cur_message_document_id > 0 -- CHECKING IF CALLED FROM WORKFLOW OR NOT
		BEGIN
			INSERT INTO #tmp_ctpy_email (message_detail_id, counterparty_id, counterparty_email, email_cc, email_bcc)
			SELECT wemds.message_detail_id, sdh.counterparty_id, ISNULL(cc1.email,cc.email), ISNULL(cc1.email_cc,cc.email_cc), ISNULL(cc1.email_bcc,cc.email_bcc)
			FROM source_deal_header sdh
			INNER JOIN counterparty_contacts cc ON CASE WHEN @cur_document_sub_category = 42021 THEN sdh.counterparty_id2 ELSE sdh.counterparty_id END = cc.counterparty_id
			INNER JOIN workflow_event_message_details wemds ON cc.contact_type = wemds.counterparty_contact_type AND wemds.event_message_document_id = @cur_message_document_id
			LEFT JOIN counterparty_contacts cc1 ON CASE WHEN @cur_document_sub_category = 42021 THEN sdh.counterparty2_trader ELSE sdh.counterparty_trader END = cc.counterparty_contact_id 
						AND CASE WHEN @cur_document_sub_category = 42021 THEN sdh.counterparty_id ELSE counterparty_id2 END = cc.counterparty_id
						AND wemds.counterparty_contact_type = -32200
			WHERE sdh.source_deal_header_id IN (@object_id) AND
			CASE WHEN wemds.counterparty_contact_type = -32200 THEN 
				CASE WHEN @cur_document_sub_category = 42021 THEN sdh.counterparty2_trader ELSE sdh.counterparty_trader END
			ELSE '' END = CASE WHEN wemds.counterparty_contact_type = -32200 THEN cc.counterparty_contact_id ELSE '' END
			UNION ALL
			SELECT wemds.message_detail_id, sdh.counterparty_id, ISNULL(cc1.email,cc.email), ISNULL(cc1.email_cc,cc.email_cc), ISNULL(cc1.email_bcc,cc.email_bcc)
			FROM source_deal_header sdh
			INNER JOIN counterparty_contacts cc ON CASE WHEN @cur_document_sub_category = 42021 THEN sdh.counterparty_id2 ELSE sdh.counterparty_id END = cc.counterparty_id
			INNER JOIN workflow_event_message_details wemds ON cc.contact_type = wemds.internal_contact_type AND wemds.event_message_document_id = @cur_message_document_id
			LEFT JOIN counterparty_contacts cc1 ON CASE WHEN @cur_document_sub_category = 42021 THEN sdh.counterparty2_trader ELSE sdh.counterparty_trader END = cc.counterparty_contact_id
						AND CASE WHEN @cur_document_sub_category = 42021 THEN sdh.counterparty_id ELSE counterparty_id2 END = cc.counterparty_id
						AND wemds.counterparty_contact_type = -32200
			WHERE sdh.source_deal_header_id IN (@object_id) AND
			CASE WHEN wemds.counterparty_contact_type = -32200 THEN 
				CASE WHEN @cur_document_sub_category = 42021 THEN sdh.counterparty2_trader ELSE sdh.counterparty_trader END
			ELSE '' END = CASE WHEN wemds.counterparty_contact_type = -32200 THEN cc.counterparty_contact_id ELSE '' END		
		END
	END
	
	/* 
	 * LOGIC FOR SCHEDULE MATCH
	 */
	ELSE IF @cur_document_category_id = 45
	BEGIN
		IF @process_table IS NOT NULL	
		BEGIN
			EXEC('INSERT INTO #tmp_ids SELECT mgs_match_group_shipment_id [obj_id] FROM ' + @process_table)
			SELECT @object_id = obj_id, @object_detail_id = obj_id FROM #tmp_ids
		END
		ELSE
		BEGIN
			SELECT @object_id = @filter_object_id
		END
		SET @criteria_for_rdl = 'source_deal_header_id:' + CAST(@object_id AS VARCHAR)
		SET @criteria_for_word_doc = 'source_deal_header_id = '+ CAST(@object_id AS VARCHAR)
		SET @criteria_for_excel_doc = '<Parameters><Parameter><Name>source_deal_header_id</Name><Value>' + CAST(@object_id AS VARCHAR) + '</Value></Parameter></Parameters>'
	END

	/* 
	 * LOGIC FOR INVOICE
	 * 38 -> View Invoice
	 * 10000283 -> Settlement Invoice
	 */
	ELSE IF @cur_document_category_id IN (38,10000283) 
	BEGIN
		IF @process_table IS NOT NULL	
		BEGIN
			IF @cur_document_category_id = 38
			BEGIN
				EXEC('INSERT INTO #tmp_ids SELECT calc_id [obj_id] FROM ' + @process_table)
			END
			ELSE 
			BEGIN
				EXEC('INSERT INTO #tmp_ids SELECT stmt_invoice_id [obj_id] FROM ' + @process_table)
			END
			SELECT @object_id = obj_id FROM #tmp_ids
			SET @filter_object_id = @object_id
		END
		ELSE
		BEGIN
			SELECT @object_id = @filter_object_id
		END

		INSERT INTO #invoices(invoice_id)
		SELECT a.item invoice_id FROM dbo.SplitCommaSeperatedValues(@object_id) a WHERE  ISNUMERIC(a.item) = 1

		INSERT INTO #invoices(invoice_id)
		SELECT  si.stmt_invoice_id FROM #invoices i
		INNER JOIN stmt_invoice si ON si.backing_sheet_original_invoice = i.invoice_id AND si.invoice_type = 'i'

		--SELECT @cur_document_category_id, @cur_document_sub_category, @filter_object_id, @object_id
			DECLARE @netting_id INT 
		IF (@document_sub_category = 42047  OR @cur_document_sub_category = 42047) AND @cur_document_category_id = 10000283 AND EXISTS(SELECT 1 FROM #invoices WHERE invoice_id > 0 ) -- For STMT netting invoice.
		BEGIN 
			INSERT INTO #invoice_netting(invoice_id, netting_id)
			SELECT i.invoice_id,
				CASE 
					WHEN si.stmt_invoice_id > si1.stmt_invoice_id 
						THEN si.stmt_invoice_id 
					ELSE si1.stmt_invoice_id
				END * -1 netting_id
			FROM stmt_invoice si
			INNER JOIN #invoices i ON i.invoice_id = si.stmt_invoice_id
			INNER JOIN contract_group cg
				ON cg.contract_id = si.contract_id
			INNER JOIN counterparty_contract_address cca 
				ON cca.counterparty_id = si.counterparty_id 
				AND cca.contract_id = cg.contract_id
			OUTER APPLY (
				SELECT stmt_invoice_id FROM stmt_invoice si1
				WHERE si1.counterparty_id = si.counterparty_id
				AND si1.contract_id = si.contract_id
				AND si1.prod_date_from = si.prod_date_from
				AND si1.prod_date_to = si.prod_date_to
				AND si1.invoice_type <> si.invoice_type
			) si1
			WHERE COALESCE(cca.netting_statement,cg.netting_statement,'n') = 'y'
			AND ISNULL(si.is_voided,'n') <> 'v'
			--AND si.stmt_invoice_id = @object_id
			AND si1.stmt_invoice_id IS NOT NULL

			IF NOT EXISTS(SELECT 1 FROM #invoice_netting WHERE netting_id IS NOT NULL)
				SET @cur_document_category_id = 0

			--SELECT @object_id = ISNULL(@netting_id, @object_id)

		END
		ELSE
		BEGIN
					INSERT INTO #invoice_netting(invoice_id)
					SELECT invoice_id FROM #invoices
		END

		--SELECT @cur_document_category_id, @cur_document_sub_category, @filter_object_id, @object_id

		IF @cur_document_category_id =  38
		BEGIN
			SET @criteria_for_rdl = 'invoice_ids:' + CAST(@object_id AS VARCHAR)
			SET @criteria_for_word_doc = 'invoice_ids:' + CAST(@object_id AS VARCHAR)
		END
		ELSE IF @cur_document_category_id =  10000283
		BEGIN
			SET @criteria_for_rdl = 'flag:b,invoice_ids:' + CAST(@object_id AS VARCHAR) +',user_login_id:' + CAST(@user_login_id AS VARCHAR)
			SET @criteria_for_word_doc = 'flag:b,invoice_ids:' + CAST(@object_id AS VARCHAR) +',user_login_id:' + CAST(@user_login_id AS VARCHAR)
			--SET @criteria_for_rdl = 'flag:b,invoice_ids:' + CAST(@object_id AS VARCHAR) 
		END

		IF @cur_document_category_id = 38
		BEGIN
			IF OBJECT_ID('tempdb..#invoice_report_collection_params') IS NOT NULL
				DROP TABLE #invoice_report_collection_params

			CREATE TABLE #invoice_report_collection_params
			(
				as_of_date             VARCHAR(20) COLLATE DATABASE_DEFAULT,
				counterparty_id        INT,
				prod_date              VARCHAR(20) COLLATE DATABASE_DEFAULT,
				contract_id            INT,
				invoice_type           VARCHAR(1) COLLATE DATABASE_DEFAULT,
				netting_group_id       INT,
				report_type            VARCHAR(50) COLLATE DATABASE_DEFAULT,
				statement_type         VARCHAR(10) COLLATE DATABASE_DEFAULT,
				settlement_date        VARCHAR(20) COLLATE DATABASE_DEFAULT,
				template_filename      VARCHAR(200) COLLATE DATABASE_DEFAULT,
				template_name          VARCHAR(200) COLLATE DATABASE_DEFAULT,
				calc_id                INT,
				client_date_format     VARCHAR(20) COLLATE DATABASE_DEFAULT
			)

			INSERT INTO #invoice_report_collection_params
			EXEC spa_rfx_invoice_report_collection @invoice_ids  = @object_id, @runtime_user  = @user

			SELECT @criteria_for_excel_doc  = 
					'<Parameters><Parameter><Name>as_of_date</Name><Value>' + ISNULL(as_of_date, '') + '</Value></Parameter>' 
				   + '<Parameter><Name>counterparty_id</Name><Value>' + CAST(counterparty_id AS VARCHAR) + '</Value></Parameter>'
				   + '<Parameter><Name>prod_date</Name><Value>' + prod_date + '</Value></Parameter>'
				   + '<Parameter><Name>contract_id</Name><Value>' + CAST(contract_id AS VARCHAR) + '</Value></Parameter>'
				   + '<Parameter><Name>invoice_type</Name><Value>' + ISNULL(invoice_type, 'i') + '</Value></Parameter>'
				   + '<Parameter><Name>netting_group_id</Name><Value>' + CAST(netting_group_id AS VARCHAR) + '</Value></Parameter>'
				   + '<Parameter><Name>statement_type</Name><Value>' + ISNULL(statement_type, '') + '</Value></Parameter>'
				   + '<Parameter><Name>settlement_date</Name><Value>' + ISNULL(settlement_date, '') + '</Value></Parameter>'
				   + '<Parameter><Name>calc_id</Name><Value>' + CAST(calc_id AS VARCHAR) + '</Value></Parameter></Parameters>'
			FROM   #invoice_report_collection_params ircp
		END
		ELSE
		BEGIN 
			IF OBJECT_ID('tempdb..#invoice_report_collection_params1') IS NOT NULL
				DROP TABLE #invoice_report_collection_params1

			CREATE TABLE #invoice_report_collection_params1
			(
				report_type             VARCHAR(200) COLLATE DATABASE_DEFAULT ,
				template_filename       VARCHAR(200) COLLATE DATABASE_DEFAULT ,
				save_invoice_id         INT,
				as_of_date             VARCHAR(20) COLLATE DATABASE_DEFAULT,
				counterparty_id        INT,
				prod_date              VARCHAR(20) COLLATE DATABASE_DEFAULT,
				contract_id            INT,
				invoice_type           VARCHAR(1) COLLATE DATABASE_DEFAULT,
				netting_group_id       INT,
				statement_type         VARCHAR(10) COLLATE DATABASE_DEFAULT,
				settlement_date        VARCHAR(20) COLLATE DATABASE_DEFAULT,
				template_name          VARCHAR(200) COLLATE DATABASE_DEFAULT,
				calc_id                INT,
				client_date_format     VARCHAR(20) COLLATE DATABASE_DEFAULT,
				source_deal_header_id  INT,
				global_number_format_region VARCHAR(20) COLLATE DATABASE_DEFAULT
			)

			IF @cur_document_category_id = 10000283
			BEGIN
				SELECT @objects = COALESCE(@objects+',', '') + CAST(ISNULL(netting_id, invoice_id) AS VARCHAR)
				FROM #invoice_netting

				INSERT INTO #invoice_report_collection_params1
				EXEC spa_rfx_invoice_report_collection @invoice_ids  = @objects, @runtime_user  = @user, @flag = 'b', @user_login_id = @user_login_id 
			END
			ELSE
			BEGIN
			INSERT INTO #invoice_report_collection_params1
			EXEC spa_rfx_invoice_report_collection @invoice_ids  = @object_id, @runtime_user  = @user, @flag = 'b', @user_login_id = @user_login_id 

			SELECT @criteria_for_excel_doc         = '<Parameters>' 
				   + '<Parameter><Name>stmt_invoice_id</Name><Value>' + CAST(save_invoice_id AS VARCHAR) + '</Value></Parameter></Parameters>'
			FROM   #invoice_report_collection_params1 ircp
		END
		END
		
		/*
		 * DATA COLLECTION FOR WORKFLOW CONTACTS EMAIL LOGIC
		 * Logic to email contact type and internal contact type for counterparty 
		 * ONLY USEFUL WHERE GENERATED FROM WORKFLOW
		 */
		IF @cur_message_document_id > 0 -- CHECKING IF CALLED FROM WORKFLOW OR NOT
		BEGIN
			INSERT INTO #tmp_ctpy_email (message_detail_id, counterparty_id, counterparty_email, email_cc, email_bcc)
			SELECT wemds.message_detail_id, civv.counterparty_id, cc.email, cc.email_cc, cc.email_bcc
			FROM 
				calc_invoice_volume_variance civv
				INNER JOIN counterparty_contract_address cca ON cca.contract_id = civv.contract_id AND cca.counterparty_id =  civv.counterparty_id
				INNER JOIN counterparty_contacts cc ON cc.counterparty_id = civv.counterparty_id AND civv.contract_id = cca.contract_id
				INNER JOIN workflow_event_message_details wemds ON cc.contact_type = wemds.counterparty_contact_type AND wemds.event_message_document_id = @cur_message_document_id
			WHERE civv.calc_id IN (@object_id) 
		END
	END

	/* 
	 * LOGIC FOR CREDIT EXPOSURE SUMMARY
	 */
	ELSE IF @cur_document_category_id = -27
	BEGIN
		IF @process_table IS NOT NULL
		BEGIN
			EXEC ('INSERT INTO #tmp_ids
				SELECT Top 1 id FROM credit_exposure_summary ces
				INNER JOIN '+ @process_table + ' temp
				INNER JOIN counterparty_contract_address cca ON cca.counterparty_id = temp.counterparty_id AND cca.contract_id = temp.contract_id
				ON  ces.as_of_date = temp.as_of_date
					AND ces.source_counterparty_id = temp.counterparty_id
					AND ISNULL(ces.contract_id,-1) = ISNULL(temp.contract_id,-1)
					AND ISNULL(ces.internal_counterparty_id,-1) = ISNULL(temp.internal_counterparty_id,-1)
					AND cca.margin_provision IS NOT NULL'
				)

			SELECT @object_id = obj_id 
			FROM #tmp_ids

		create table #tmp_ids_custom
		(counterparty_id int, contract_id int, as_of_date varchar(50) COLLATE DATABASE_DEFAULT, internal_counterparty_id int)

		EXEC ('INSERT INTO #tmp_ids_custom
				SELECT Top 1 temp.counterparty_id, temp.contract_id,temp.as_of_date, temp.internal_counterparty_id
				FROM credit_exposure_summary ces
				INNER JOIN '+ @process_table + ' temp
				INNER JOIN counterparty_contract_address cca ON cca.counterparty_id = temp.counterparty_id AND cca.contract_id = temp.contract_id
				ON  ces.as_of_date = temp.as_of_date
					AND ces.source_counterparty_id = temp.counterparty_id
					AND ISNULL(ces.contract_id,-1) = ISNULL(temp.contract_id,-1)
					AND ISNULL(ces.internal_counterparty_id,-1) = ISNULL(temp.internal_counterparty_id,-1)
					AND cca.margin_provision IS NOT NULL'
				)

				
		Declare 
		@counterparty_id int,
		@contract_id int,
		@internal_counterparty_id int,
		@as_of_date varchar(200)

		SELECT @counterparty_id = counterparty_id,
			   @contract_id = contract_id,
			   @as_of_date = as_of_date,
			   @internal_counterparty_id = internal_counterparty_id		 
		FROM #tmp_ids_custom
		END
		ELSE
		BEGIN
			SELECT @object_id = @filter_object_id
		END
		SET @criteria_for_excel_doc = '<Parameters><Parameter><Name>margin_call_id</Name><Value>' + CAST(@object_id AS VARCHAR) + '</Value></Parameter></Parameters>'
		SET @criteria_for_rdl = 'export_type:PDF,margin_call_id:' + CAST(@object_id AS VARCHAR) + ',counterparty_id:' + CAST(@counterparty_id AS VARCHAR) + ',as_of_date:' + CAST(@as_of_date AS VARCHAR) + ',internal_counterparty_id:' + CAST(@internal_counterparty_id AS VARCHAR) + ',contract_id:' + CAST(@contract_id AS VARCHAR)
		SET @criteria_for_word_doc = 'margin_call_id = '+ CAST(@object_id AS VARCHAR)+ ',counterparty_id:' + CAST(@counterparty_id AS VARCHAR) + ',as_of_date:' + CAST(@as_of_date AS VARCHAR) + ',internal_counterparty_id:' + CAST(@internal_counterparty_id AS VARCHAR) +
		',contract_id:' + CAST(@contract_id AS VARCHAR)
	END 

	ELSE IF @cur_document_category_id = 48
	BEGIN
		IF @process_table IS NOT NULL	
		BEGIN
			EXEC('INSERT INTO #tmp_ids SELECT link_id [obj_id] FROM ' + @process_table)
			SELECT @object_id = obj_id FROM #tmp_ids
		END
		ELSE
		BEGIN
			SELECT @object_id = @filter_object_id
		END

		SET @criteria_for_excel_doc = '<Parameters><Parameter><Name>link_id</Name><Value>' + CAST(@object_id AS VARCHAR) + '</Value></Parameter></Parameters>'
		SET @criteria_for_rdl = 'link_id:' + CAST(@object_id AS VARCHAR)
		SET @criteria_for_word_doc = 'link_id = '+ CAST(@object_id AS VARCHAR)
	END

	/* 
	 * LOGIC FOR COUNTERPARTY CONTRACTS
	 */
	ELSE IF @cur_document_category_id = 10000330
	BEGIN
		IF @process_table IS NOT NULL	
		BEGIN
			EXEC('INSERT INTO #tmp_ids SELECT counterparty_contract_address_id [obj_id] FROM ' + @process_table)
			SELECT @object_detail_id = obj_id FROM #tmp_ids
			SELECT @object_id = counterparty_id FROM counterparty_contract_address WHERE counterparty_contract_address_id = @object_detail_id
		END
		ELSE
		BEGIN
			SELECT @object_id = @filter_object_id
		END
		SET @criteria_for_excel_doc = '<Parameters><Parameter><Name>counterparty_contract_address_id</Name><Value>' + CAST(@object_id AS VARCHAR) + '</Value></Parameter></Parameters>'
		SET @criteria_for_word_doc = 'counterparty_contract_address_id = '+ CAST(@object_id AS VARCHAR)
		SET @criteria_for_rdl = 'counterparty_contract_address_id:' + CAST(@object_detail_id AS VARCHAR)
	END

	ELSE
	BEGIN
		SET @primary_column = NULL
		SELECT @primary_column = atm.primary_column 
		FROM workflow_event_message wem
		INNER JOIN event_trigger et ON wem.event_trigger_id = et.event_trigger_id
		INNER JOIN module_events me ON et.modules_event_id = me.module_events_id
		INNER JOIN workflow_module_rule_table_mapping mp ON mp.module_id = me.modules_id
		INNER JOIN alert_table_definition atm ON mp.rule_table_id = atm.alert_table_definition_id AND is_action_view = 'y'
		WHERE wem.event_message_id =  @event_message_id

		IF @primary_column IS NOT NULL AND @process_table IS NOT NULL	
		BEGIN	
			EXEC('INSERT INTO #tmp_ids SELECT ' + @primary_column + ' [obj_id] FROM ' + @process_table)
			SELECT @object_id = obj_id FROM #tmp_ids
		END	
		ELSE
		BEGIN
			SELECT @object_id = @filter_object_id
		END
		
		IF @object_id IS NOT NULL
		BEGIN
			SET @criteria_for_excel_doc = '<Parameters><Parameter><Name>' + @primary_column + '</Name><Value>' + CAST(@object_id AS VARCHAR) + '</Value></Parameter></Parameters>'
			SET @criteria_for_rdl = @primary_column + ':' + CAST(@object_id AS VARCHAR)
			SET @criteria_for_word_doc = @primary_column + ' = '+ CAST(@object_id AS VARCHAR)	
		END
	END

	/*
	 * GET THE TEMPLATE FOR THE DOCUMENT GENERATION
	 */
	DELETE FROM #tmp_status
	DECLARE @date_part VARCHAR(20)
	SET @date_part = FORMAT(GETDATE(), 'yyyy_M_d_HHmmss')
	DECLARE @output_file_name NVARCHAR(100) 
	DECLARE @output_file_path NVARCHAR(300) 
	
	IF @cur_document_category_id = 10000283
	BEGIN 
		INSERT INTO #invoice_netting_template(invoice_id, main_invoice_id, template_id)
		SELECT DISTINCT ISNULL(inet.netting_id, i.invoice_id) invoice_id, i.invoice_id, dbo.FNAGetDocumentTemplate(@cur_document_category_id, @cur_document_sub_category, ISNULL(inet.netting_id, i.invoice_id) , @cur_default_document_template) template_id
		FROM #invoices i
		LEFT JOIN #invoice_netting inet ON inet.invoice_id = i.invoice_id

		-- DONT GENERATE DOCUMENT FOR THIS CONDITION
		IF NOT EXISTS(SELECT 1 FROM #invoice_netting_template WHERE template_id IS NOT NULL)
		BEGIN
			INSERT INTO #tmp_status ([status],[message]) VALUES('Error', 'No Template')
		END

		--INSERT INTO #contract_report_template(document_type, template_id, template_name, [filename], xml_map_filename, excel_sheet_id)
		--SELECT ISNULL(crt.document_type, 'r') document_type, crt.template_id, crt.template_name, crt.[filename], crt.xml_map_filename, crt.excel_sheet_id
		--FROM Contract_report_template crt
		--INNER JOIN #invoice_netting_template i ON i.template_id = crt.template_id
		 
		 --SET @document_type = 'e'
	 END
	 ELSE
	 BEGIN
	SET @template_id = dbo.FNAGetDocumentTemplate(@cur_document_category_id, @cur_document_sub_category, @object_id, @cur_default_document_template)
	-- DONT GENERATE DOCUMENT FOR THIS CONDITION
	IF @template_id < 0 OR @template_id IS NULL
	BEGIN
		INSERT INTO #tmp_status ([status],[message]) VALUES('Error', 'No Template')
	END

	SET @document_type = NULL
		SET @excel_sheet_id = NULL
	SELECT @document_type = ISNULL(crt.document_type, 'r'),
			@template_id = crt.template_id,
			@template_name = crt.template_name,
			@report_filename = crt.[filename],
			@xml_map_filename = crt.xml_map_filename,
			@excel_sheet_id = crt.excel_sheet_id
	FROM Contract_report_template crt
	WHERE template_id = @template_id
	
	END

	  --SET @output_file_name  = @cur_document_category_name+ '_' + ISNULL(@cur_document_sub_category_name + '_','') + CAST(@object_id AS VARCHAR) + '_' + REPLACE(REPLACE(REPLACE(ISNULL(@counterparty_name,''),'/','_'),'.','_'),',','_') + @date_part + CASE WHEN @document_type IN ('r','e') THEN '.pdf' ELSE '.docx' END

	IF @cur_document_category_id = 10000283
	BEGIN
		INSERT INTO #contract_report_template(invoice_id, main_invoice_id, document_type, template_id, template_name, [filename], xml_map_filename, excel_sheet_id, output_file_name, output_file_path, criteria_for_excel_doc)
		SELECT i.invoice_id invoice_id, i.main_invoice_id, ISNULL(crt.document_type, 'r') document_type, crt.template_id, crt.template_name, crt.[filename], crt.xml_map_filename, crt.excel_sheet_id,
		f.output_file_name, CASE WHEN @temp_generate = 0 THEN @document_path + @cur_document_category_name + '\' + f.output_file_name ELSE REPLACE(@document_path,'attach_docs','temp_Note') + f.output_file_name END output_file_path,
		'<Parameters><Parameter><Name>stmt_invoice_id</Name><Value>' + CAST(ir.save_invoice_id AS VARCHAR) + '</Value></Parameter></Parameters>' criteria_for_excel_doc
		FROM Contract_report_template crt
		INNER JOIN #invoice_netting_template i ON i.template_id = crt.template_id
		INNER JOIN #invoice_report_collection_params1 ir ON ir.save_invoice_id = ABS(i.invoice_id)
		CROSS APPLY(SELECT @cur_document_category_name+ '_' + ISNULL(@cur_document_sub_category_name + '_','') + CAST(i.invoice_id AS VARCHAR) + '_' + REPLACE(REPLACE(REPLACE(ISNULL(@counterparty_name,''),'/','_'),'.','_'),',','_') + @date_part + CASE WHEN document_type IN ('r','e') THEN '.pdf' ELSE '.docx' END output_file_name ) f  -- + '_' + CAST(ROW_NUMBER() OVER (ORDER BY newid()) AS VARCHAR(10))

		IF @temp_generate = 1
        BEGIN
            SELECT @output_file_path =  output_file_path FROM #contract_report_template
        END

 	END
	ELSE
	BEGIN
		SET @output_file_name = @cur_document_category_name+ '_' + ISNULL(@cur_document_sub_category_name + '_','') + CAST(@object_id AS VARCHAR) + '_' + REPLACE(REPLACE(REPLACE(ISNULL(@counterparty_name,''),'/','_'),'.','_'),',','_') + @date_part + CASE WHEN @document_type IN ('r','e') THEN '.pdf' ELSE '.docx' END
	IF @temp_generate = 0
			BEGIN
		SET @output_file_path = @document_path + @cur_document_category_name + '\' + @output_file_name
			END
	ELSE
		SET @output_file_path = REPLACE(@document_path,'attach_docs','temp_Note') + @output_file_name

	END

	--SET @generated_document = NULL
	IF @get_generated_workflow = 1
	BEGIN
		TRUNCATE TABLE #notes

		INSERT INTO #notes(notes_id, [object_id], output_file_name, generated_document)
		SELECT MAX(notes_id), a.item, MAX(attachment_file_name) attachment_file_name, @document_path + MAX(sdv.code) + '\' + MAX(attachment_file_name) generated_document
		FROM application_notes an
		INNER JOIN dbo.SplitCommaSeperatedValues(@object_id) a ON a.item = ISNULL(parent_object_id, notes_object_id)
		LEFT JOIN static_data_value sdv ON sdv.value_id = an.internal_type_value_id
		WHERE internal_type_value_id = @cur_document_category_id AND category_value_id = @cur_document_sub_category AND ISNUMERIC(a.item) = 1
		GROUP BY a.item

		--SELECT @notes_id = MAX(notes_id) FROM application_notes an
		--WHERE ISNULL(parent_object_id,notes_object_id) = @object_id AND internal_type_value_id = @cur_document_category_id AND category_value_id = @cur_document_sub_category

		/* Check if the document has been generated and saved or not */
		IF EXISTS(SELECT 1 FROM #notes WHERE  notes_id IS NOT NULL AND generated_document IS NOT NULL)
			BEGIN
				SET @document_type = 'g'

				SELECT @output_file_name = MAX(output_file_name), @output_file_path = MAX(generated_document) FROM #notes

				INSERT INTO #tmp_status ([status], [message])
				SELECT 'success',''
		END
	END


	/*
	 * CREATE DOCUMENT CATEGORY FOLDER IF IT DOESNOT EXISTS
	 */
	IF @cur_document_category_name IS NOT NULL
	BEGIN
		DECLARE @document_folder_path VARCHAR(200) = @document_path + @cur_document_category_name
		EXEC spa_create_folder @folder_path = @document_folder_path, @result = NULL
	END

	/*
	 *  GENERATE DOCUMENT FROM RDL
	 */ 
		IF @cur_document_category_id IN (38,10000283)
			SET @report_filename = 'Invoice Report Collection'

		SET @report_filename = 'custom_reports/' + @report_filename
		
		--INSERT INTO #tmp_status ([status], [message])
		--EXEC spa_export_RDL @report_filename, @criteria_for_rdl, 'PDF', @output_file_path
		
	 --SET @criteria_for_rdl = 'flag:b,invoice_ids:' + CAST(@object_id AS VARCHAR) +',user_login_id:' + CAST(@user_login_id AS VARCHAR)
	 --SET @rdl_sql = 'EXEC spa_export_RDL ''' + @report_filename + ''', ''' + 'flag:b,invoice_ids:' + CAST(@object_id AS VARCHAR) +',user_login_id:' + CAST(@user_login_id AS VARCHAR) + ''', ''PDF'', ''' + @output_file_path + ''''

	INSERT INTO #contract_report_template_tbl (invoice_id, main_invoice_id, process_id, excel_sheet_id, criteria, export_format, template_type, [user_name], output_file_path, cur_message_document_id, template_id, document_type,
		cur_document_category_name, cur_document_sub_category_name, counterparty_name, output_file_name, cur_document_sub_category)
	SELECT invoice_id, main_invoice_id, dbo.FNAGetNewID(), NULL, 'EXEC spa_export_RDL ''' + @report_filename + ''', ''' + 'flag:b,invoice_ids:' + CAST(invoice_id AS VARCHAR) +',user_login_id:' + CAST(@user_login_id AS VARCHAR) + ''', ''PDF'', ''' + output_file_path + ''''
	, 'PDF', 'rdl', @user_login_id, output_file_path, @cur_message_document_id, @template_id, 'r', 
	@cur_document_category_name, @cur_document_sub_category_name, @counterparty_name, output_file_name, @cur_document_sub_category
	FROM #contract_report_template WHERE document_type = 'r'

	/*
	 * GENERATE DOCUMENT FROM EXCEL
	 */

	INSERT INTO #contract_report_template_tbl (invoice_id, main_invoice_id, process_id, excel_sheet_id, criteria, export_format, template_type, [user_name], output_file_path, cur_message_document_id, template_id, document_type,
			cur_document_category_name, cur_document_sub_category_name, counterparty_name, output_file_name, cur_document_sub_category)
	SELECT invoice_id, main_invoice_id, dbo.FNAGetNewID(), excel_sheet_id, criteria_for_excel_doc, 'PDF', 'excel', @user_login_id, output_file_path, @cur_message_document_id, template_id, 'e' document_type,
	@cur_document_category_name, @cur_document_sub_category_name, @counterparty_name, output_file_name, @cur_document_sub_category
	FROM #contract_report_template WHERE document_type = 'e' AND excel_sheet_id IS NOT NULL

	/*
	 * GENERATE DOCUMENT FROM WORD
	 */	
	IF @document_type = 'w'
	BEGIN
		DECLARE @new_process_id VARCHAR(200) = dbo.FNAGETnewID();
		DECLARE @table_name VARCHAR(200) = 'adiha_process.dbo.'+ REPLACE(@cur_document_category_name,' ','_') +'_'+@new_process_id
	
		IF @xml_count = 0  
			SET @is_create_xml = 'y'
		SET @xml_count = 1 

		-- pass event_document_id, filename, process table and parameters to the word file generating spa
			SET @sql = 'SELECT ' + CAST(@template_id AS VARCHAR) + ' [template_id]
						, ''' + @template_name + ''' [template_name]
						, ''' + @output_file_name + ''' [filename]
						, ''' + @xml_map_filename + ''' [xml_map_filename]
						, ' + CAST(@object_id AS VARCHAR) + ' [filter_id]
						, ''' + @document_path + @cur_document_category_name + ''' [file_location]
						, ''' + @xml_map_filename+'.xsd' + ''' [xsd_file]
						INTO ' + @table_name 

			EXEC(@sql)

			IF @temp_generate = 0
			BEGIN
				INSERT INTO #tmp_status ([status],[message])
				EXEC  [dbo].[spa_generate_document_word] 'g',@table_name,@is_create_xml,@cur_document_category_id,@criteria_for_word_doc,@new_process_id
			END
			ELSE
			BEGIN
				DECLARE @t_path VARCHAR(2000) = REPLACE(@document_path , '\attach_docs\','\temp_Note\')
				INSERT INTO #tmp_status ([status],[message])
				EXEC  [dbo].[spa_generate_document_word] 'g',@table_name,@is_create_xml,@cur_document_category_id,@criteria_for_word_doc,@new_process_id,@t_path
			END
		END

	UPDATE #tmp_status
	SET message_document_id = @cur_message_document_id
	WHERE message_document_id IS NULL
	

	SET @sql = 'INSERT INTO ' + @contract_report_template_tbl + '(invoice_id, main_invoice_id, process_id, excel_sheet_id, criteria, export_format, template_type, user_name, output_file_name, output_file_path, cur_message_document_id, template_id, document_type, notes_subject, notes_attachment)
	SELECT invoice_id, main_invoice_id, process_id, excel_sheet_id, criteria, export_format, template_type, [user_name], output_file_name, output_file_path, cur_message_document_id, template_id, document_type, 
	''' + @cur_document_category_name + ' ' + ISNULL(@cur_document_sub_category_name + '_', '') + ''' + CAST(invoice_id AS VARCHAR) + ''' + CASE WHEN ISNULL(@counterparty_name,'') = '' THEN '' ELSE ' ' END + '' + ISNULL(@counterparty_name,'') + ' ' + @date_part + ''', 
	''../../../adiha.php.scripts/dev/shared_docs/attach_docs/' + @cur_document_category_name + '/'' + output_file_name
	FROM #contract_report_template_tbl	'

	EXEC(@sql)

	IF EXISTS(SELECT 1 FROM #contract_report_template_tbl)
	EXEC spa_bulk_document_generation @batchProcessId = @process_id_main
	
	SET @sql = '
	INSERT INTO #tmp_status ([status], [message], message_document_id)
	SELECT DISTINCT CASE WHEN c.[status] = 1 THEN ''success'' ELSE ''Error'' END [status], ''Invoice ID '' + CAST(c.invoice_id AS VARCHAR(10)) + '' generated '', ' + CAST(@cur_message_document_id AS VARCHAR(10)) + ' FROM ' + @contract_report_template_tbl + ' c 
	'
	EXEC(@sql)

	SET @sql = 'UPDATE c SET c.[status] = ct.[status] FROM #contract_report_template_tbl c
	INNER JOIN ' + @contract_report_template_tbl + ' ct ON ct.invoice_id = c.invoice_id
	'
	EXEC(@sql)

	IF EXISTS (SELECT [status] FROM #tmp_status WHERE message_document_id = @cur_message_document_id AND [status] = 'Success')
	BEGIN
		/*
		 * LOGIC TO ADD THE GENERATED DOCUMENT IN APPLICATION NOTES
		 */

		DECLARE @notes_subject NVARCHAR(100) = @cur_document_category_name + ' ' + ISNULL(@cur_document_sub_category_name + '_','') + CAST(@object_id AS VARCHAR) + CASE WHEN ISNULL(@counterparty_name,'') = '' THEN '' ELSE ' ' END + ISNULL(@counterparty_name,'') + ' ' + @date_part
		DECLARE @notes_attachment NVARCHAR(100) = '../../../adiha.php.scripts/dev/shared_docs/attach_docs/' + @cur_document_category_name + '/' + @output_file_name
		
		IF @temp_generate = 0 --AND @generated_document IS NULL --todo @generated_document ?
		BEGIN	
			TRUNCATE TABLE #error_status
			SET @cur_document_sub_category = NULLIF(@cur_document_sub_category,0)

			IF @netting_id IS NOT NULL
				SET @object_id = @filter_object_id;
			
			SET @process_id = CASE WHEN @cur_document_category_id = 10000283 THEN  @process_id_main ELSE NULL END

			INSERT INTO #error_status (error_code, module, area, [status], [message], recommendation)
			EXEC spa_post_template	@flag='i',
									@process_id = @process_id,
									@internal_type_value_id = @cur_document_category_id,
									@notes_object_id = @object_detail_id,
									@notes_subject = @notes_subject,
									@doc_file_unique_name = @output_file_name,
									@doc_file_name = @notes_attachment,
									@workflow_process_id = @workflow_process_id,
									@workflow_message_id = @event_message_id,
									@parent_object_id = @object_id,
									@category_value_id = @cur_document_sub_category,
									@notes_share_email_enable = 0
		END
						
		/*
		 * WORKFLOW DOCUMENT CONTACTS EMAIL LOGIC
		 */
		IF @process_table IS NOT NULL
		BEGIN

			--SELECT @att_file_string = STUFF((SELECT DISTINCT ',' +  a.item
			--										FROM dbo.SplitCommaSeperatedValues(@attachment_files) a
			--										FOR XML PATH('')), 1, 1, '')

			--SELECT @cur_document_category_name + '/' + output_file_name FROM #contract_report_template_tbl

			SELECT @att_file_string = STUFF((SELECT DISTINCT ',' +  @cur_document_category_name + '/' + a.output_file_name
													FROM #contract_report_template_tbl a
													FOR XML PATH('')), 1, 1, '')

		IF @attachment_files IS NULL
			BEGIN 
				SET @attachment_files = @att_file_string
		END
		ELSE
		BEGIN
				SET @attachment_files = @attachment_files + ',' + @att_file_string
		END

			IF @att_file_string IS NOT NULL
			BEGIN
				/*Logic to get email from query*/
				SELECT @module_id = me.modules_id
				FROM workflow_event_message_details wemd
				INNER JOIN workflow_event_message_documents wemds
					ON wemds.message_document_id = wemd.event_message_document_id
				INNER JOIN workflow_event_message wem ON wemds.event_message_id = wem.event_message_id
				INNER JOIN event_trigger et ON et.event_trigger_id = wem.event_trigger_id
				INNER JOIN module_events me ON me.module_events_id = et.modules_event_id
				WHERE wemd.event_message_document_id = @cur_message_document_id

				IF OBJECT_ID('tempdb..#temp_email_query') IS NOT NULL
					DROP TABLE #temp_email_query

				CREATE TABLE #temp_email_query(
					group_type CHAR(1) COLLATE DATABASE_DEFAULT,
					email_address_query VARCHAR(MAX) COLLATE DATABASE_DEFAULT
				)

				IF OBJECT_ID('tempdb..#temp_email_data') IS NOT NULL
					DROP TABLE #temp_email_data

				CREATE TABLE #temp_email_data(
					email_data_id INT IDENTITY(1,1),
					group_type CHAR(1) COLLATE DATABASE_DEFAULT,
					email VARCHAR(1000) COLLATE DATABASE_DEFAULT
				)

				INSERT INTO #temp_email_query
				SELECT wc.group_type,REPLACE(wc.email_address_query,'@_source_id',@object_id) --Get query for email_group
				FROM workflow_contacts wc
				INNER JOIN workflow_event_message_email weme
					ON weme.workflow_contacts_id = wc.workflow_contacts_id
					AND wc.group_type = weme.group_type
				INNER JOIN workflow_event_message_details wemd
					ON wemd.message_detail_id = weme.message_detail_id
				WHERE wc.module_id = @module_id
				AND NULLIF(wc.email_group,'') IS NOT NULL
				AND wemd.event_message_document_id = @cur_message_document_id
				AND wemd.delivery_method = 21301
				UNION
				SELECT wc.group_type,REPLACE(REPLACE(wc.email_address_query,'@_source_id',@object_id),'@_filter_obj',tbl.filter_value)  --Get query for filter_values
				FROM workflow_contacts wc
				OUTER APPLY(
				SELECT STUFF(
				(SELECT ',' + weme.query_value
				FROM workflow_event_message_email weme
				INNER JOIN workflow_event_message_details wemd
					ON wemd.message_detail_id = weme.message_detail_id
				WHERE wemd.event_message_document_id = @cur_message_document_id
				AND wemd.delivery_method = 21301 
				AND (@send_email IS NOT NULL OR wemd.email IS NOT NULL)
				AND weme.group_type = wc.group_type
				FOR XML PATH('')),1,1,'') AS filter_value
				) tbl
				WHERE wc.module_id = @module_id
				AND NULLIF(wc.email_group,'') IS NULL
				AND tbl.filter_value IS NOT NULL

				DECLARE cursor_formula_editor CURSOR FOR
				SELECT group_type,email_address_query
				FROM #temp_email_query
				OPEN cursor_formula_editor
					FETCH NEXT FROM cursor_formula_editor INTO @group_type, @email_address_query
					WHILE @@FETCH_STATUS = 0
					BEGIN
						SELECT @previous_id = IIF(@@identity IS NULL,0,Ident_Current('#temp_email_data'))
						INSERT INTO #temp_email_data(email)
						EXEC (@email_address_query)
						SELECT @current_id = Ident_Current('#temp_email_data')
		
						UPDATE #temp_email_data
						SET group_type = @group_type
						WHERE email_data_id > @previous_id AND email_data_id <= @current_id
					FETCH NEXT FROM cursor_formula_editor INTO @group_type, @email_address_query
					END
				CLOSE cursor_formula_editor
				DEALLOCATE cursor_formula_editor
				/*End of logic*/
				SELECT @send_email = STUFF((SELECT DISTINCT ';' +  email 
											FROM #temp_email_data
											WHERE group_type = 'e'
															FOR XML PATH('')), 1, 1, '')

				SELECT @send_email_cc = STUFF((SELECT DISTINCT ';' +  email 
											FROM #temp_email_data
											WHERE group_type = 'c'
															FOR XML PATH('')), 1, 1, '')

				SELECT @send_email_bcc = STUFF((SELECT DISTINCT ';' +  email 
											FROM #temp_email_data
											WHERE group_type = 'b'
															FOR XML PATH('')), 1, 1, '')

				SELECT DISTINCT	@email_message_input = ISNULL(dbo.FNAURLDecode(aec.email_body), REPLACE(REPLACE(wemds.[message], CHAR(13), ''), CHAR(10), ' <br>')),
						        @email_subject_input = COALESCE(NULLIF(aec.email_subject,''),NULLIF(wemds.[subject],''))
				FROM workflow_event_message_details wemds
				LEFT JOIN admin_email_configuration aec ON wemds.message_template_id = aec.admin_email_configuration_id
				WHERE wemds.event_message_document_id = @cur_message_document_id AND wemds.delivery_method = 21301
				 AND (@send_email IS NOT NULL OR wemds.email IS NOT NULL)
		

				DECLARE @invoice_tag TABLE(id INT IDENTITY(1,1), invoice_id INT, output_msg VARCHAR(MAX), msg_type VARCHAR(1))
				DECLARE @invoice_id INT
				DECLARE cursor_resolve_tag CURSOR FOR
				SELECT DISTINCT invoice_id FROM #contract_report_template_tbl
				OPEN cursor_resolve_tag
					FETCH NEXT FROM cursor_resolve_tag INTO @invoice_id
					WHILE @@FETCH_STATUS = 0
					BEGIN
						EXEC spa_resolve_workflow_message_tag @message_input = @email_subject_input, @source_id = @invoice_id, @module_id = @module_id, @message_output = @email_subject_output OUTPUT
						INSERT INTO @invoice_tag(invoice_id, output_msg, msg_type)
						SELECT @invoice_id, @email_subject_output, 's'

						EXEC spa_resolve_workflow_message_tag @message_input = @email_message_input, @source_id = @invoice_id, @module_id = @module_id, @message_output = @email_message_output OUTPUT
						INSERT INTO @invoice_tag(invoice_id, output_msg, msg_type)
						SELECT @invoice_id, @email_message_output, 'm'

					FETCH NEXT FROM cursor_resolve_tag INTO @invoice_id
					END
				CLOSE cursor_resolve_tag
				DEALLOCATE cursor_resolve_tag

				DECLARE @final_attachment_file VARCHAR(MAX)
								DECLARE @tmp_attachment_file VARCHAR(1000)


				SET @final_attachment_file =  @document_path + '\' + @cur_document_category_name + '\' + @output_file_name -- + CASE WHEN @tmp_attachment_file IS NOT NULL THEN ', ' + @tmp_attachment_file ELSE '' END

				--select @output_file_name, @object_id, @final_attachment_file
				--print @final_attachment_file

				/*
				 * Logic to attach backing sheet invoice document along with invoice document
				 */
		
		
		IF (@document_category = 10000283 OR @cur_document_category_id = 10000283) AND EXISTS (SELECT 1 FROM stmt_invoice WHERE stmt_invoice_id = @object_id AND ISNULL(is_backing_sheet,'n') = 'n')
				BEGIN
					INSERT INTO email_notes (notes_subject, notes_text, send_from, send_to, send_cc, send_bcc, attachment_file_name, send_status, active_flag, email_type, internal_type_value_id, category_value_id, notes_object_id)
					SELECT DISTINCT	ISNULL(it_s.output_msg, 'TRMTracker Notification'), --@email_subject_output
							it_m.output_msg, -- @email_message_output,
							'noreply@hitachienergy.com',
							c_r.email,
							null,
							null,
							c2.output_file_path, --@document_path + '\' + @cur_document_category_name + '\' + an.attachment_file_name,
							'n',
							'y',
							'o',
							@cur_document_category_id,
							@cur_document_sub_category,
							c2.invoice_id --@object_id
 
 					--select  c.invoice_id, c2.*
					FROM 
					#contract_report_template_tbl c 
					INNER JOIN stmt_invoice si ON si.backing_sheet_original_invoice = c.invoice_id AND si.invoice_type = 'i' AND ISNULL(si.is_backing_sheet,'n') = 'y'
					INNER JOIN #contract_report_template_tbl c2 ON c2.invoice_id = si.stmt_invoice_id
					INNER JOIN stmt_invoice si_m ON si_m.stmt_invoice_id = c.invoice_id AND si.invoice_type = 'i' AND  ISNULL(si_m.is_backing_sheet,'n') = 'n'
					INNER JOIN stmt_netting_group sng ON sng.counterparty_id = si_m.counterparty_id AND sng.netting_contract_id = si_m.contract_id
					INNER JOIN stmt_netting_group_detail sngd ON sngd.netting_group_id = sng.netting_group_id AND sngd.contract_detail_id = si.contract_id
					INNER JOIN counterparty_contract_address cca ON cca.counterparty_id = si.counterparty_id AND cca.contract_id = si.contract_id
					INNER JOIN counterparty_contacts c_r ON c_r.counterparty_contact_id = cca.receivables
					LEFT JOIN @invoice_tag it_s ON it_s.invoice_id = c2.invoice_id AND it_s.msg_type = 's'
					LEFT JOIN @invoice_tag it_m ON it_m.invoice_id = c2.invoice_id AND it_m.msg_type = 'm'
					--CROSS APPLY (
					--	SELECT MAX(attachment_file_name) attachment_file_name FROM application_notes an WHERE an.parent_object_id = si.stmt_invoice_id AND an.internal_type_value_id = 10000283 AND an.category_value_id = 42031 GROUP BY an.parent_object_id
					--) an
 

				END
				
				--SELECT @final_attachment_file
				--IF ISNULL(@cur_document_sub_category, 0) <> 42047 -- Not for netting.
				--BEGIN

	 				INSERT INTO email_notes (notes_subject, notes_text, send_from, send_to, send_cc, send_bcc, attachment_file_name, send_status, active_flag, email_type, internal_type_value_id, category_value_id, notes_object_id)
					SELECT DISTINCT	ISNULL(it_s.output_msg, 'TRMTracker Notification'), --@email_subject_output
							it_m.output_msg, --@email_message_output,
							'noreply@hitachienergy.com',
							ISNULL(@send_email, '') + ISNULL(CASE WHEN @send_email IS NOT NULL THEN ';' ELSE '' END + wemds.email, ''),
							ISNULL(@send_email_cc, '') + ISNULL(CASE WHEN @send_email_cc IS NOT NULL THEN ';' ELSE '' END + wemds.email_cc, ''),
							ISNULL(@send_email_bcc, '') + ISNULL(CASE WHEN @send_email_bcc IS NOT NULL THEN ';' ELSE '' END + wemds.email_bcc, ''),
							c.output_file_path, --@final_attachment_file,
							'n',
							'y',
							'o',
							@cur_document_category_id,
							@cur_document_sub_category,
							c.invoice_id --@object_id
				FROM workflow_event_message_details wemds
					LEFT JOIN admin_email_configuration aec ON wemds.message_template_id = aec.admin_email_configuration_id
					LEFT JOIN #contract_report_template_tbl c ON c.cur_document_sub_category = @cur_document_sub_category
					LEFT JOIN stmt_invoice si ON si.stmt_invoice_id = c.invoice_id
					LEFT JOIN @invoice_tag it_s ON it_s.invoice_id = c.invoice_id AND it_s.msg_type = 's'
					LEFT JOIN @invoice_tag it_m ON it_m.invoice_id = c.invoice_id AND it_m.msg_type = 'm'
					WHERE ISNULL(si.is_backing_sheet,'n') = 'n' and si.invoice_type = 'i' AND wemds.event_message_document_id = @cur_message_document_id AND wemds.delivery_method = 21301
					AND (@send_email IS NOT NULL OR NULLIF(wemds.email,'') IS NOT NULL)


	 				INSERT INTO email_notes (notes_subject, notes_text, send_from, send_to, send_cc, send_bcc, attachment_file_name, send_status, active_flag, email_type, internal_type_value_id, category_value_id, notes_object_id)
					SELECT DISTINCT	ISNULL(it_s.output_msg, 'TRMTracker Notification'), --@email_subject_output
							it_m.output_msg, --@email_message_output,
							'noreply@hitachienergy.com',
							ISNULL(@send_email, '') + ISNULL(CASE WHEN @send_email IS NOT NULL THEN ';' ELSE '' END + wemds.email, ''),
							ISNULL(@send_email_cc, '') + ISNULL(CASE WHEN @send_email_cc IS NOT NULL THEN ';' ELSE '' END + wemds.email_cc, ''),
							ISNULL(@send_email_bcc, '') + ISNULL(CASE WHEN @send_email_bcc IS NOT NULL THEN ';' ELSE '' END + wemds.email_bcc, ''),
							c.output_file_path, --@final_attachment_file,
							'n',
							'y',
							'o',
							@cur_document_category_id,
							@cur_document_sub_category,
							c.invoice_id --@object_id
					FROM workflow_event_message_details wemds
					LEFT JOIN admin_email_configuration aec ON wemds.message_template_id = aec.admin_email_configuration_id
					LEFT JOIN #contract_report_template_tbl c ON c.cur_document_sub_category = @cur_document_sub_category
					LEFT JOIN @invoice_tag it_s ON it_s.invoice_id = c.invoice_id AND it_s.msg_type = 's'
					LEFT JOIN @invoice_tag it_m ON it_m.invoice_id = c.invoice_id AND it_m.msg_type = 'm'
					WHERE wemds.event_message_document_id = @cur_message_document_id AND wemds.delivery_method = 21301
					AND (@send_email IS NOT NULL OR NULLIF(wemds.email,'') IS NOT NULL) AND c.invoice_id < 0

					 

				--END
		
					DELETE FROM @invoice_tag
					 

			END
		END
	END
	
	FETCH NEXT FROM document_cursor
	INTO @cur_message_document_id, @cur_document_category_id, @cur_document_category_name, @cur_document_sub_category, @cur_document_sub_category_name, @cur_default_document_template
END
CLOSE document_cursor
DEALLOCATE document_cursor


--EXEC spa_synchronize_excel_reports
--	 @excel_sheet_id = @excel_sheet_id,
--	 @batch_xml_report_param = NULL,
--	 @view_report_filter_xml = @criteria_for_excel_doc,
--	 @process_id = @process_id,
--	 @export_format = 'PDF',
--	 @suppress_result = 'y' 

/*
 * UPDATING THE DOCUMENT GENERATED FOR WORKFLOW
 */
IF @process_table IS NOT NULL
BEGIN
	--Add attachment_files column in process table and update its value. This will be used in spa_process_outstanding_alerts.
	SET @sql = 'IF COL_LENGTH(''' + @process_table + ''', ''attachment_files'') IS NULL
				BEGIN
					ALTER TABLE ' + @process_table + ' ADD attachment_files VARCHAR(300) NULL
				END'
	EXEC(@sql)

	SET @sql = 'UPDATE ' + @process_table + '
				SET attachment_files = NULL'
	EXEC(@sql)

	SET @sql = 'UPDATE ' + @process_table + '
				SET attachment_files = ''' + @attachment_files + ''''

	IF @attachment_files IS NOT NULL
		EXEC(@sql)
END
ELSE
BEGIN
	IF @output_file_path IS NOT NULL
		SET @generated_document = @output_file_path
	
	IF @show_output = 1
	BEGIN
		IF EXISTS (SELECT 1 FROM #tmp_status WHERE [status] = 'Error')
		BEGIN
			IF @document_category = 33
				SET @error_message = 'Could not generate Confirmation Document. Please check Setup Confirmation Rule.'
			ELSE
				SET @error_message = 'Error in generating document.'
			SELECT TOP 1 'Error' [Status], @generated_document [file],  [message] FROM #tmp_status WHERE [status] = 'Error'
				
		END
		ELSE
		BEGIN
			SELECT 'Success' [Status], @generated_document [file]
		END
	END
END
--rollback
