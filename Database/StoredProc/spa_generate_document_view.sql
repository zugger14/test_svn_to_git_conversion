
IF OBJECT_ID(N'[dbo].[spa_generate_document_view]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_generate_document_view]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: bmaharjan@pioneersolutionsglobal.com
-- Create date: 2016-11-19
-- Description: Generate document to view or view the saved document.
 
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_generate_document_view]
    @flag CHAR(1),
    @object_id INT = NULL,
    @document_category INT = NULL,
    @document_sub_category INT = NULL,
    @document_filename VARCHAR(1024) = NULL
AS

/*
DECLARE @flag CHAR(1) = 'g',
    @object_id INT = 6782,
    @document_category INT = 38,
    @document_sub_category INT = ''
--*/
SET NOCOUNT ON

DECLARE @sql VARCHAR(MAX)

IF @flag = 'g'
BEGIN
	DECLARE @document_path VARCHAR(100),@notes_id INT
	
	SELECT @document_path = document_path FROM connection_string
	SELECT @notes_id = MAX(notes_id) FROM application_notes an
	WHERE ISNULL(parent_object_id,notes_object_id) = @object_id AND internal_type_value_id = @document_category AND category_value_id = @document_sub_category

	/* Check if the document has been generated and saved or not */
	IF EXISTS (SELECT 1 FROM application_notes WHERE notes_id = @notes_id)
	BEGIN
		SELECT 'Success' [status], @document_path + '\attach_docs\' + sdv.code + '\' + attachment_file_name [file] FROM application_notes an
		INNER JOIN static_data_value sdv ON sdv.value_id = an.internal_type_value_id
		WHERE notes_id = @notes_id
	END
	/* If not generated yet, Generate and download in temp note. This is only for temporary view. */
	ELSE 
	BEGIN
		BEGIN TRY
			IF OBJECT_ID('tempdb..#tmp_status') IS NOT NULL
				DROP TABLE #tmp_status
			CREATE TABLE #tmp_status ([status] VARCHAR(10) COLLATE DATABASE_DEFAULT , [message] VARCHAR(5000) COLLATE DATABASE_DEFAULT )

			DECLARE @template_id INT,
					@template_name VARCHAR(100),
					@document_type CHAR(1),
					@document_category_name VARCHAR(100),
					@report_filename VARCHAR(100),
					@xml_map_filename VARCHAR(100),
					@filter VARCHAR(200),
					@criteria VARCHAR(200),
					@use_default_template INT = 1,
					@document_sheet_id INT = NULL,
					@user VARCHAR(500)= dbo.FNADBUser(),
					@process_id VARCHAR(100) = dbo.FNAGetNewID()
		
		IF @document_category = 38
		BEGIN
			SET @filter = 'invoice_ids:' + CAST(@object_id AS VARCHAR)
				SELECT 	@document_sub_category = CASE WHEN ISNULL(crt.template_category,0) = 0 THEN 42024 ELSE  crt.template_category END, @document_type = crt.document_type FROM calc_invoice_volume_variance civv
												INNER JOIN contract_group cg ON cg.contract_id = civv.contract_id
												INNER JOIN Contract_report_template crt ON crt.template_id =  
																												CASE WHEN civv.invoice_type = 'i' THEN cg.invoice_report_template
																												WHEN civv.invoice_type IN('r','e') THEN cg.contract_report_template
																												WHEN civv.netting_group_id IS NOT NULL THEN cg.netting_template
																												ELSE '' END 
												LEFT JOIN static_data_value sdv ON sdv.value_id = crt.template_type
												WHERE crt.template_id IS NOT NULL AND civv.calc_id = @object_id
		END
	
			/* Logic for Deal */
			IF @document_category = 33 AND @document_sub_category IN (42018, 42021)
			BEGIN
				SET @filter = 'export_type:PDF,source_deal_header_id:' + CAST(@object_id AS VARCHAR)
				SET @criteria = 'source_deal_header_id = '+ CAST(@object_id AS VARCHAR)

				IF EXISTS (SELECT 1 FROM Contract_report_template crt
							INNER JOIN deal_confirmation_rule dcr ON crt.template_id = dcr.confirm_template_id
							INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = @object_id 
								AND CASE	WHEN @document_sub_category = 42021
										THEN ISNULL(dcr.counterparty_id, sdh.counterparty_id2)
									ELSE ISNULL(dcr.counterparty_id, sdh.counterparty_id)
									END = CASE 
									WHEN @document_sub_category = 42021
										THEN sdh.counterparty_id2
									ELSE sdh.counterparty_id
									END
								AND ISNULL(dcr.deal_type_id, sdh.source_deal_type_id) = sdh.source_deal_type_id
								AND COALESCE(dcr.deal_sub_type, sdh.deal_sub_type_type_id,'') = COALESCE(sdh.deal_sub_type_type_id,'')
								AND dcr.buy_sell_flag = CASE 
									WHEN dcr.buy_sell_flag = 'a'
										THEN 'a'
									ELSE sdh.header_buy_sell_flag
									END
								AND ISNULL(dcr.deal_template_id, sdh.template_id) = sdh.template_id
							INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
								AND COALESCE(dcr.origin, sdd.origin,'') = COALESCE(sdd.origin,'')
								AND COALESCE(dcr.commodity_id, sdd.detail_commodity_id,'') = COALESCE(sdd.detail_commodity_id,sdh.commodity_id,'')
							WHERE template_type = @document_category AND ISNULL(dcr.deal_confirm, 42018) = @document_sub_category)
				BEGIN
					SET @use_default_template = 0
					
					SELECT TOP(1) 
							 @document_type = ISNULL(crt.document_type, 'r'),
							@template_id = crt.template_id,
							@template_name = crt.template_name,
							@report_filename = crt.[filename],
							@document_category_name = ISNULL(sdv.code,''),
							@xml_map_filename = crt.xml_map_filename,
							@document_type = crt.document_type
					FROM Contract_report_template crt
					INNER JOIN deal_confirmation_rule dcr ON crt.template_id = dcr.confirm_template_id
					INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = @object_id 
					AND CASE 
							WHEN @document_sub_category = 42021
								THEN ISNULL(dcr.counterparty_id, sdh.counterparty_id2)
							ELSE ISNULL(dcr.counterparty_id, sdh.counterparty_id)
							END = CASE 
							WHEN @document_sub_category = 42021
								THEN sdh.counterparty_id2
							ELSE sdh.counterparty_id
							END
						AND COALESCE(dcr.deal_type_id, sdh.source_deal_type_id,'') =COALESCE(sdh.source_deal_type_id,'')
						AND COALESCE(dcr.deal_sub_type, sdh.deal_sub_type_type_id,'') = COALESCE(sdh.deal_sub_type_type_id,'')
						AND dcr.buy_sell_flag = CASE 
							WHEN dcr.buy_sell_flag = 'a'
								THEN 'a'
							ELSE sdh.header_buy_sell_flag
							END
						AND COALESCE(dcr.deal_template_id, sdh.template_id,'') = COALESCE(sdh.template_id,'')
					INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
						AND COALESCE(dcr.origin, sdd.origin,'') = COALESCE(sdd.origin,'')
						AND COALESCE(dcr.commodity_id, sdd.detail_commodity_id,'') = COALESCE(sdd.detail_commodity_id,sdh.commodity_id,'')
					LEFT JOIN static_data_value sdv ON sdv.value_id = crt.template_type
					WHERE template_type = @document_category
						AND ISNULL(dcr.deal_confirm, 42018) = @document_sub_category
				END

				/*	@use_default_template = 2 is used if we dont need to generate document. 
					When counterparty_id2 is not defined, we dont generate document for document sub category is 42021 */
				IF EXISTS(SELECT 1 FROM source_deal_header WHERE source_deal_header_id = @object_id AND counterparty_id2 IS NULL AND @document_sub_category = 42021)
					SET @use_default_template = 2
			END
			ELSE IF @document_category = 38 AND @document_sub_category = 42031
			BEGIN
					SET @filter = 'calc_id:' + CAST(@object_id AS VARCHAR)
				SET @criteria = 'calc_id = '+ CAST(@object_id AS VARCHAR)
				IF EXISTS(SELECT 1 FROM calc_invoice_volume_variance civv 
								INNER JOIN contract_group cg ON cg.contract_id = civv.contract_id 
								INNER JOIN Contract_report_template crt ON crt.template_id = cg.invoice_report_template
								WHERE civv.calc_id = @object_id) 
				BEGIN
					SELECT TOP (1)   @document_type = ISNULL(crt.document_type, 'r')
									,@template_id = crt.template_id
									,@template_name = crt.template_name
									,@report_filename = CASE WHEN crt.template_category = 42031 THEN ISNULL(NULLIF(crt.[filename], ''), CASE [xml_map_filename]
																	WHEN NULL
																		THEN NULL
																	ELSE (
																			CASE LEN([xml_map_filename])
																				WHEN 0
																					THEN [xml_map_filename]
																				ELSE LEFT([xml_map_filename], LEN([xml_map_filename]) - 4)
																				END
																			)
																	END)
																	ELSE 
																	 'Invoice Report Collection'
																	END
									,@document_category_name = ISNULL(sdv.code, '')
									,@xml_map_filename = crt.xml_map_filename
								FROM calc_invoice_volume_variance civv
								INNER JOIN contract_group cg ON cg.contract_id = civv.contract_id
								INNER JOIN Contract_report_template crt ON crt.template_id =  
																								CASE WHEN civv.invoice_type = 'i' THEN cg.invoice_report_template
																								WHEN civv.invoice_type = 'r' THEN cg.contract_report_template
																								WHEN civv.netting_group_id IS NOT NULL THEN cg.netting_template
																								ELSE '' END 
								LEFT JOIN static_data_value sdv ON sdv.value_id = crt.template_type
								WHERE crt.template_id IS NOT NULL AND civv.calc_id = @object_id
								--	AND crt.template_category = 42031
			
					SET @use_default_template = 0
				END
			END
			
		
			/* Use default template if templates are not mapped for specific object*/
			IF @use_default_template = 1
			BEGIN
				SELECT	@template_id = crt.template_id,
						@template_name = crt.template_name,
						@document_type = ISNULL(crt.document_type,'r'),
						@document_category_name = sdv.code,
						@report_filename = crt.[filename],
						@xml_map_filename = crt.xml_map_filename
				FROM contract_report_template crt
				INNER JOIN static_data_value sdv ON sdv.value_id = crt.template_type
				WHERE template_type = @document_category AND template_category = @document_sub_category AND [default] = 1
			END

			DECLARE @date_part VARCHAR(20)= CAST(DATEPART(yy, GETDATE()) AS VARCHAR) + '_' + CAST(DATEPART(mm, GETDATE()) AS VARCHAR) + '_' + CAST(DATEPART(dd, GETDATE()) AS VARCHAR) + '_' + CAST(DATEPART(hh, GETDATE()) AS VARCHAR) + CAST(DATEPART(mi, GETDATE()) AS VARCHAR) + CAST(DATEPART(ss, GETDATE()) AS VARCHAR)
			DECLARE @output_file_name VARCHAR(100) = ISNULL(@document_filename, @document_category_name+ '_' + CAST(@object_id AS VARCHAR) + '_' + @date_part + CASE WHEN @document_type IN('r','e') THEN '.pdf' ELSE '.docx' END)
			DECLARE @output_file_path VARCHAR(300) = @document_path + '\temp_Note\' + @output_file_name
	
			/* Generate the RDL Document */
			IF @document_type = 'r' AND @use_default_template < 2
			BEGIN
				SET @report_filename = 'custom_reports/' + @report_filename
				
				INSERT INTO #tmp_status ([status], [message])
				EXEC spa_export_RDL @report_filename, @filter, 'PDF', @output_file_path
			END	
			/* Generate document using excel document template */
			ELSE IF @document_type = 'e' AND @use_default_template < 2
			BEGIN
				-- This sp doesnt support nested inserted, to check if snapshot is created or not process id used.
				-- @show_result = 0 will supress result row
				EXEC spa_generate_document_from_excel @object_id= @object_id, @template_type = @document_category, @template_category = @document_sub_category , @export_format = 'PDF', @process_id = @process_id, @show_result = 0
				
				-- Excel document is always generated in temp_note, Rename the file
				DECLARE @source_filename VARCHAR(1000)
				SELECT @source_filename = @document_path + '\temp_note\' + ess.snapshot_filename,
				       @output_file_path = @document_path + '\temp_note\' + @output_file_name
				FROM   excel_sheet_snapshot AS ess
				WHERE  ess.process_id = @process_id
				
				IF @source_filename IS NOT NULL AND dbo.FNAFileExists(@source_filename) = 1
					INSERT INTO #tmp_status ([status],[message]) VALUES('Success', @output_file_path)
				ELSE
					INSERT INTO #tmp_status ([status],[message]) VALUES('Error', '')
				
				EXEC spa_copy_file @source_file = @source_filename ,@destination_file = @output_file_path, @result = NULL	
			END	
			/* Generate the word Document */
			ELSE IF @document_type = 'w' AND @use_default_template < 2
			BEGIN
				DECLARE @new_process_id VARCHAR(200) = dbo.FNAGETnewID();
				DECLARE @table_name VARCHAR(200) = 'adiha_process.dbo.'+ REPLACE(@document_category_name,' ','_') +'_'+@new_process_id

				-- pass event_document_id, filename, process table and parameters to the word file generating spa
				SET @sql = 'SELECT ' + CAST(@template_id AS VARCHAR) + ' [template_id]
							, ''' + @template_name + ''' [template_name]
							, ''' + @output_file_name + ''' [filename]
							, ''' + @xml_map_filename + ''' [xml_map_filename]
							, ' + CAST(@object_id AS VARCHAR) + ' [filter_id]
							, ''' + @document_path + '\attach_docs\' + @document_category_name + ''' [file_location]
							, ''' + @xml_map_filename+'.xsd' + ''' [xsd_file]
							INTO ' + @table_name 
				EXEC(@sql)

				DECLARE @temp_path VARCHAR(200) = @document_path + '\temp_Note\'
				
				INSERT INTO #tmp_status ([status],[message])
				EXEC  [dbo].[spa_generate_document_word] 'g',@table_name,'y',@document_category,@criteria,@new_process_id, @temp_path
			END

			IF EXISTS (SELECT 1 FROM #tmp_status WHERE [status] = 'Success' OR [status] = 'Sucess')
				SELECT 'Success' [status], @document_path + '\temp_Note\' + @output_file_name [file]
			ELSE 
				SELECT 'Error' [status], '' [file]
		END TRY
		BEGIN CATCH
			SELECT 'Error' [status], '' [file]
		END CATCH
	END	
END
