IF OBJECT_ID ('spa_counterparty_certificate','p') IS NOT NULL 
	DROP PROC spa_counterparty_certificate 
GO 

CREATE PROC dbo.spa_counterparty_certificate 
	@flag CHAR(1),
	@counterparty_id INT = NULL,
	@xml text = NULL
AS 
SET NOCOUNT ON
BEGIN
	DECLARE @sql_stmt VARCHAR(8000),  @idoc int
	DECLARE @desc VARCHAR(500)
	DECLARE @err_no INT

	IF @flag = 's'
	BEGIN
		SELECT	
				counterparty_certificate_id,
				counterparty_id,
				available_reqd,
				certificate_id,
				dbo.FNAGetSQLStandardDate(effective_date) effective_date, 
				dbo.FNAGetSQLStandardDate(expiration_date) expiration_date, 
				comments,
				--'<span style="cursor:pointer" onClick="setup_counterparty.open_document('''+CAST(counterparty_certificate_id AS VARCHAR(100))+''',''42001'','''+CAST(counterparty_id AS VARCHAR(100))+''')"><font color=#0000ff><u><l>Certificates<l></u></font></span> ('+ CAST(COUNT(an.attachment_file_name) AS VARCHAR(100)) +')' [Attachment]
				CASE WHEN COUNT(an.attachment_file_name) = 0 THEN '<span style="cursor:pointer" onClick="setup_counterparty.attach_document('''+CAST(cc.counterparty_id AS VARCHAR(100))+''',''42001'',''NULL'','''+CAST(cc.counterparty_certificate_id AS VARCHAR(100))+''')"><font color=#ff000000><u><l>Upload<l></u></font></span>'
				ELSE  '<span style="cursor:pointer" onClick="setup_counterparty.attach_document('''+CAST(cc.counterparty_id AS VARCHAR(100))+''',''42001'','''+CAST(an.notes_id AS VARCHAR(100))+''','''+CAST(cc.counterparty_certificate_id AS VARCHAR(100))+''')"><font color=#ff000000><u><l>Upload<l></u></font></span> <span style="cursor:pointer" onClick="setup_counterparty.remove_document('''+CAST(an.notes_id AS VARCHAR(100))+''')"><font color=#ff000000><u><l>Remove<l></u></font></span> (' + ISNULL('<a href=../../adiha.php.scripts/force_download.php?path=' + REPLACE(notes_attachment, attachment_file_name, '') + item + ' download>' + item + '</a>', '<a href=' + url + ' target=_blank>' + url + '<a>') + ')'
				END [attachment]
		FROM counterparty_certificate cc
		LEFT JOIN application_notes an ON cc.counterparty_certificate_id = an.notes_object_id AND ISNULL(an.internal_type_value_id, 37) = 37 AND ISNULL(an.category_value_id, 42001) = 42001
		OUTER APPLY dbo.fnasplit(attachment_file_name, ', ')
		WHERE counterparty_id = @counterparty_id
		GROUP BY counterparty_certificate_id,counterparty_id,effective_date,expiration_date,certificate_id,comments,available_reqd
		,item,notes_attachment, attachment_file_name,notes_id,an.url
		ORDER BY effective_date DESC
	END
	ELSE IF @flag = 'v'
	BEGIN
		BEGIN TRY
			EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
			IF OBJECT_ID('tempdb..#temp_update_detail') IS NOT NULL
				DROP TABLE #temp_update_detail

			IF OBJECT_ID('tempdb..#temp_delete_detail') IS NOT NULL
				DROP TABLE #temp_delete_detail
			IF OBJECT_ID('tempdb..#temp_insert_detail') IS NOT NULL
				DROP TABLE #temp_insert_detail

			SELECT
				  counterparty_certificate_id,
				  available_reqd,
				  counterparty_id,
				  NULLIF(effective_date, '') effective_date,
				  NULLIF(expiration_date, '') expiration_date,
				  certificate_id,
				  comments 
			INTO #temp_update_detail
			FROM OPENXML(@idoc, '/Root/GridUpdate', 1)
			WITH (
				counterparty_certificate_id INT,
				available_reqd CHAR,
				counterparty_id INT,
				effective_date DATE,
				expiration_date DATE,
				certificate_id VARCHAR(250),
				comments VARCHAR(1000)
			)

			SELECT
				grid_id
			INTO #temp_delete_detail
			FROM OPENXML(@idoc, '/Root/GridDelete', 1)
			WITH (
				grid_id INT
			)

			SELECT
				counterparty_certificate_id,
				available_reqd,
				counterparty_id,
				NULLIF(effective_date, '') effective_date,
				NULLIF(expiration_date, '') expiration_date,
				certificate_id,
				comments 
			INTO #temp_insert_detail
			FROM OPENXML(@idoc, '/Root/GridInsert', 1)
			WITH (
				counterparty_certificate_id INT,
				available_reqd CHAR,
				counterparty_id INT,
				effective_date DATE,
				expiration_date DATE,
				certificate_id VARCHAR(250),
				comments VARCHAR(1000)
			)
		
			UPDATE cf
			SET cf.counterparty_id = tud.counterparty_id,
				cf.available_reqd = tud.available_reqd,
				cf.effective_date = tud.effective_date,
				cf.expiration_date = tud.expiration_date,
				cf.certificate_id = tud.certificate_id,
				cf.comments = tud.comments
			FROM counterparty_certificate cf
			INNER JOIN #temp_update_detail tud ON cf.counterparty_certificate_id = tud.counterparty_certificate_id
		
			INSERT INTO counterparty_certificate (
				available_reqd,
				counterparty_id,
				effective_date,
				expiration_date,
				certificate_id,
				comments)
			SELECT
			tid.available_reqd,
			tid.counterparty_id,
			tid.effective_date,
			tid.expiration_date,
			tid.certificate_id,
			tid.comments
			FROM #temp_insert_detail tid

			DELETE an
			FROM counterparty_certificate cf
			INNER JOIN application_notes an on an.notes_object_id = cf.counterparty_certificate_id
			INNER JOIN #temp_delete_detail tdd ON cf.counterparty_certificate_id = tdd.grid_id

			DELETE cf 
			FROM counterparty_certificate cf
			INNER JOIN #temp_delete_detail tdd ON cf.counterparty_certificate_id = tdd.grid_id

			EXEC spa_ErrorHandler @@ERROR,
								'Counterparty Certificate',
								'spa_counterparty_certificate',
								'Success',
								'Changes have been saved successfully.',
								''
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
			   ROLLBACK
			
			SET @desc = dbo.FNAHandleDBError(10105800)
			
			EXEC spa_ErrorHandler -1
			   , 'Counterparty Certificate'
			   , 'spa_counterparty_certificate'
			   , 'Error'
			   , @desc
			   , ''
		END CATCH
	END
END