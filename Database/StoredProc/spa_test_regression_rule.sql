IF OBJECT_ID('[testing].[spa_test_regression_rule]') IS NOT NULL
	DROP PROC [testing].spa_test_regression_rule
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


---- ===========================================================================================================
---- Author: anuj@pioneersolutionsglobal.com
---- Create date: 2019-02-22
---- Params:
---- @flag CHAR(1) - Operation flag
---- ===========================================================================================================
CREATE PROC [testing].spa_test_regression_rule @flag VARCHAR(1)
	,@object_name VARCHAR(MAX) = NULL
	,@rule_id INT = NULL
	,@regression_module_header_id INT = NULL
	,@type CHAR(1) = NULL
	,@call_from VARCHAR(10) = NULL
AS
SET NOCOUNT ON

/*
----Debugg Query
DECLARE 
	@regression_module_header_id INT = NULL
	,@type CHAR(1) = NULL
	,@call_from VARCHAR(10) = NULL
	,@flag VARCHAR(1) = 's',
	@object_name VARCHAR(MAX) = 'FNABatchProcess,FNACalcOptionsPrem,FNACurve,FNADateFormat,FNADBUser,FNAFNACurveNames,FNAGetBusinessDay,FNAGetContractMonth,FNAGetProcessTableName,FNAGetSQLStandardDate,FNAGetTermEndDate,FNAGetTermStartDate,FNAHyperLink,FNAHyperLinkText,FNAInvoiceDueDate,FNALagcurve,FNAMax,FNAMin,FNAPartialAvgCurve,FNAPmt,FNAProcessTableName,FNARCLagcurve,FNATrmHyperlink,FNAUserDateTimeFormat,spa_Calc_Discount_Factor,spa_calc_mtm_job,spa_calc_options_prem_detail,spa_calculate_formula,spa_create_fx_exposure_report,spa_create_xml_document,spa_deal_position_breakdown,spa_derive_curve_value,spa_ErrorHandler,spa_get_mtm_test_run_log,spa_maintain_transaction_job,FNACurve,FNADBUser,FNAGetContractMonth,FNAGetSQLStandardDate,FNAGetTermEndDate,FNAGetTermStartDate,FNAHyperLinkText,FNALagcurve,FNAProcessTableName,spa_calculate_formula,spa_deal_position_breakdown,spa_ErrorHandler,spa_maintain_transaction_job',
	@rule_id INT = NULL
--*/
DECLARE @process_id VARCHAR(50), @filtered_objects VARCHAR(MAX), @new_line CHAR(2) = CHAR(13) + CHAR(10), @tab CHAR(1) = CHAR(9), @space CHAR(1) = CHAR(32)
SET @process_id = dbo.FNAGetNewID()

IF @flag = 's'
BEGIN
	IF OBJECT_ID('tempdb..#temp_error_message') IS NOT NULL
		DROP TABLE #temp_error_message

	CREATE TABLE #temp_error_message (
		rule_id INT
		,rule_name VARCHAR(50) COLLATE DATABASE_DEFAULT
		,obj_name VARCHAR(MAX) COLLATE DATABASE_DEFAULT
		,process_id VARCHAR(50) COLLATE DATABASE_DEFAULT
		,err_msg VARCHAR(MAX) COLLATE DATABASE_DEFAULT
		)

	IF @call_from IS NULL --call form hudson jenkin
	BEGIN
		--logic to grab the table changes 
		SELECT @filtered_objects = STUFF((
					SELECT ',' + s.name
					FROM sys.tables s
					OUTER APPLY (
						SELECT item AS item
						FROM dbo.SplitCommaSeperatedValues(@object_name)
						) c
					WHERE s.type = 'U'
						AND CHARINDEX(s.name, c.item) > 0
						AND ISNUMERIC(SUBSTRING(c.item, 0, CHARINDEX('_', c.item))) = 1
					GROUP BY s.name
					FOR XML PATH
						,type
					).value('.[1]', 'VARCHAR(MAX)'), 1, 1, '')

		--logic to eliminate the table changes 
		SELECT @filtered_objects = IIF(@filtered_objects IS NULL, '', ',') + STUFF((
					SELECT ',' + item AS item
					FROM dbo.SplitCommaSeperatedValues(@object_name)
					WHERE ISNUMERIC(SUBSTRING(item, 0, CHARINDEX('_', item))) = 0
					FOR XML PATH
						,type
					).value('.[1]', 'VARCHAR(MAX)'), 1, 1, '')

		SET @object_name = @filtered_objects -- reset the value of object_name filtering the table name form the file name
	END



	DECLARE @regg_rule_id INT
		,@rule_name VARCHAR(100)
		,@obj_name VARCHAR(MAX)

	DECLARE regression_rule_cursor CURSOR
	FOR
	SELECT rr.regression_rule_id
		,rr.rule_name
		,MAX(obj.aff_obj)
	FROM regression_module_dependencies rmd
	INNER JOIN regression_rule rr ON rmd.regression_module_header_id = rr.regression_module_header_id
	INNER JOIN dbo.SplitCommaSeperatedValues(@object_name) obj_name ON rmd.[object_name] = obj_name.item
	OUTER APPLY(
		SELECT STUFF(
               (
                   SELECT ',' + affected_items.item
                   FROM   regression_rule  rr1 
				   INNER JOIN regression_module_dependencies rmd1
					ON rr1.regression_module_header_id = rmd1.regression_module_header_id
				   INNER JOIN dbo.SplitCommaSeperatedValues(@object_name) affected_items
				   ON affected_items.item = rmd1.[object_name]
                  WHERE rr1.regression_rule_id = rr.regression_rule_id   FOR XML PATH,type
               ).value('.[1]', 'VARCHAR(MAX)'),
               1,
               1,
               ''
           ) AS aff_obj
	) obj
	GROUP BY regression_rule_id, rule_name

	OPEN regression_rule_cursor

	FETCH NEXT
	FROM regression_rule_cursor
	INTO @regg_rule_id
		,@rule_name
		,@obj_name

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		BEGIN TRY
			--print 'EXEC spa_pre_post_analysis @flag = ''p''
			--	,@regression_rule_id = ' + Cast(@regg_rule_id AS VARCHAR) + '
			--	,@output_process_id = @process_id OUTPUT'
			--set @regg_rule_id = 5

			EXEC spa_pre_post_analysis @flag = 'p'
				,@regression_rule_id = @regg_rule_id
				,@output_process_id = @process_id
			--SET  @process_id = '5FFAA9B2_BFCC_4A5E_A5F3_76861AB01BDF'

			INSERT INTO #temp_error_message
			SELECT @regg_rule_id
				,@rule_name
				,@obj_name
				,@process_id
				,NULL
		END TRY
		BEGIN CATCH
			INSERT INTO #temp_error_message
			SELECT @regg_rule_id
				,@rule_name
				,@obj_name
				,@process_id
				,ERROR_MESSAGE()
				--SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage; 
		END CATCH

		FETCH NEXT
		FROM regression_rule_cursor
		INTO @regg_rule_id
			,@rule_name
			,@obj_name
	END

	CLOSE regression_rule_cursor

	DEALLOCATE regression_rule_cursor

	--FOR Testing purpose
	--INSERT INTO #temp_error_message
	--SELECT '1', 'MTM Calc', 'spa_mtm_calc_job','901BFE02_8EC9_4B31_9F05_C4D9868B83FF',NULL UNION
	--SELECT '1', 'MTM Calc', 'spa_mtm_calc_job','23563BF9_BAB2_490D_B46C_A811CCD373F5',NULL UNION
	--SELECT '1', 'MTM Calc', 'spa_mtm_calc_job',NULL,'Test Message' UNION
	--SELECT '2', 'Settlement Calc', 'spa_settlement_calc_job',NULL,'Test Message' UNION 
	--SELECT '2', 'Settlement Calc', 'spa_settlement_calc_job1',NULL,'Test Message11' UNION 
	--SELECT '2', 'Settlement Calc', 'spa_settlement_calc_job2',NULL,'Test Message23' 


	--SELECT * FROM #temp_error_message
	IF EXISTS (
			SELECT 1
			FROM #temp_error_message
			)
	BEGIN
		DECLARE @message VARCHAR(MAX)


		--select * from #temp_error_message
			
		SELECT @message = 'Following Regression Testing rule(s) failed for database ' + DB_NAME() + ' by your recent commit.' + @new_line + STUFF((
					SELECT final_value.validation_message
					FROM (
						SELECT
							rule_name,
							MAX(tem1.process_id) AS process_id
							, @new_line + @new_line + CAST(ROW_NUMBER() OVER (
									ORDER BY rule_name
									) AS VARCHAR) + '. Rule Name: ' + tem1.rule_name + ' [Affected Object(s): ' + tem1.obj_name + ']' + @new_line 
									+ final_message.final_message AS validation_message
						FROM #temp_error_message tem1
						OUTER APPLY (
							SELECT (
									STUFF((
											SELECT DISTINCT @new_line + @tab + COALESCE(QUOTENAME(source), QUOTENAME(tem.obj_name), 'Error') 
												+ ': ' + ISNULL(dbo.FNAStripHTML(ssdis_inner.description), tem.err_msg)
											FROM #temp_error_message tem
											LEFT JOIN source_system_data_import_status ssdis_inner ON ISNULL(tem.process_id, - 1) = ssdis_inner.Process_id
												AND LTRIM(RTRIM(ssdis_inner.rules_name)) = LTRIM(RTRIM(tem.rule_name))
											WHERE tem.rule_id = tem1.rule_id
												AND (ssdis_inner.[type] = 'Mismatch'
														OR dbo.FNAStripHTML(ssdis_inner.[type]) = 'Data Error'
														OR tem.process_id IS NULL)
											FOR XML PATH('')
												,TYPE
											).value('.', 'NVARCHAR(MAX)'), 1, 2, '')
									) AS final_message
							) final_message
						LEFT JOIN source_system_data_import_status ssdis ON ISNULL(tem1.process_id, - 1) = ssdis.Process_id
							AND LTRIM(RTRIM(ssdis.rules_name)) = LTRIM(RTRIM(tem1.rule_name))
						WHERE (ssdis.[type] = 'Mismatch' OR dbo.FNAStripHTML(ssdis.[type]) = 'Data Error' OR tem1.process_id IS NULL)
						GROUP BY rule_name,
						tem1.obj_name
							--,obj_name.obj_name
							,final_message.final_message,
							tem1.err_msg
						) final_value
					FOR XML PATH('')
						,TYPE
					).value('.', 'NVARCHAR(MAX)'), 1, 2, '')--final_out_string


					--SELECT @message

			SET @message += @new_line + @new_line + 'Please fix the issue and reply this email after re-committing the changes.' + @new_line

	--SELECT @message
	--RETURN
		IF @call_from = 'job' AND @message IS NOT NULL
		BEGIN
			DECLARE @send_from VARCHAR(500) = 'noreply@pioneersolutionsglobal.com', @send_to VARCHAR(500) = 'regg.testing@pioneersolutionsglobal.com;'
			INSERT INTO email_notes
				(
					notes_subject,
					notes_text,
					send_from,
					send_to,
					send_status,
					active_flag
				)		
			SELECT 'Regression Testing Failed',
				REPLACE(REPLACE(REPLACE(@message, @new_line, '<br/>'), @tab, '&#09;'), @space, '&nbsp;'),
				@send_from,
				@send_to,
				'n',
				'y'

		END
		ELSE
		BEGIN
			SELECT @message regg_out_msg
		END
	END
END
ELSE IF @flag = 'r'
BEGIN
	SELECT rmd.regression_module_detail_id [Detail ID]
		,rmd.regression_module_header_id [Regression Module Header ID]
		,rmd.regg_type [Regression Type]
		, CASE 
			WHEN rmd.regg_type = 109701 THEN NULL
			ELSE  
		rmd.table_name + '^' + rmd.table_name
		END  [Table Name]
		,rmd.regg_rpt_paramset_hash + '^' + report_name.name [Report Name]
		,rmd.unique_columns [Unique Columns]
		,rmd.compare_columns [Compare Columns]
		,rmd.display_columns [Display Columns]
		,rmd.data_order [Data Order]
		,rmd.process_exec_order [Process Execution]
	--,rmd.regg_rpt_paramset_hash [Report Hash]
	FROM regression_module_detail rmd
	OUTER APPLY (
		SELECT rp.name
		FROM regression_module_detail rmd1
		INNER JOIN report_paramset rp ON rmd1.regg_rpt_paramset_hash = rp.paramset_hash
		WHERE rmd.regression_module_detail_id = rmd1.regression_module_detail_id
		) report_name
	WHERE regression_module_header_id = @regression_module_header_id
END
ELSE IF @flag = 'l'
BEGIN
	IF @type = 't'
		SELECT QUOTENAME(column_name) AS id
			,QUOTENAME(column_name) AS value
		FROM INFORMATION_SCHEMA.COLUMNS 
		WHERE table_name = @object_name
		ORDER BY column_name
	ELSE IF @type = 'r'
	BEGIN
		SELECT QUOTENAME(ISNULL(rtc.alias, dsc.[name])) AS id
			,QUOTENAME(ISNULL(rtc.alias, dsc.[name])) AS value
		FROM report_paramset rp
		INNER JOIN report_page_tablix rpt ON rp.page_id = rpt.page_id
		INNER JOIN report_tablix_column rtc ON rtc.tablix_id = rpt.report_page_tablix_id
		INNER JOIN data_source_column dsc ON dsc.data_source_column_id = rtc.column_id
		WHERE rp.paramset_hash = @object_name
		ORDER BY ISNULL(rtc.alias, dsc.[name])
	END
END
GO
