

IF OBJECT_ID(N'[dbo].[spa_send_accurals_invoices_job]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_send_accurals_invoices_job]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spa_send_accurals_invoices_job]
AS

--TODO CHANGES
DECLARE @shared_folder VARCHAR(200) = '\\PSSJCDEV01\shared_docs_SettlementTracker_Master_Eneco\'
DECLARE @report_folder VARCHAR(200) = '/SettlementTracker_Master_Eneco/custom_reports/'
DECLARE @report_server_url VARCHAR(100) = 'http://pssjcdev01.farrms.us//ReportServer_INSTANCE2008R2'
DECLARE @report_server_rss_path VARCHAR(100) = 'D:\FARRMS_SPTFiles\RSS\SettlementTracker_Master_Eneco\custom_export.rss'
--TODO CHANGES END

IF object_id('tempdb..#sap_data') IS NOT NULL
    DROP TABLE #sap_data
CREATE TABLE #sap_data (col1 VARCHAR(200) COLLATE DATABASE_DEFAULT ,col2 VARCHAR(200) COLLATE DATABASE_DEFAULT ,col3 VARCHAR(200) COLLATE DATABASE_DEFAULT ,col4 VARCHAR(200) COLLATE DATABASE_DEFAULT ,col5 VARCHAR(200) COLLATE DATABASE_DEFAULT ,col6 VARCHAR(200) COLLATE DATABASE_DEFAULT ,col7 VARCHAR(200) COLLATE DATABASE_DEFAULT ,col8 VARCHAR(200) COLLATE DATABASE_DEFAULT ,col9 VARCHAR(200) COLLATE DATABASE_DEFAULT ,col10 VARCHAR(200) COLLATE DATABASE_DEFAULT ,col11 VARCHAR(200) COLLATE DATABASE_DEFAULT ,col12 VARCHAR(200) COLLATE DATABASE_DEFAULT ,col13 VARCHAR(200) COLLATE DATABASE_DEFAULT ,col14 VARCHAR(200) COLLATE DATABASE_DEFAULT ,col15 VARCHAR(200) COLLATE DATABASE_DEFAULT ,col16 VARCHAR(200) COLLATE DATABASE_DEFAULT ,col17 VARCHAR(200) COLLATE DATABASE_DEFAULT ,col18 VARCHAR(200) COLLATE DATABASE_DEFAULT ,col19 VARCHAR(200) COLLATE DATABASE_DEFAULT ,col20 VARCHAR(200) COLLATE DATABASE_DEFAULT ,col21 VARCHAR(200) COLLATE DATABASE_DEFAULT ,col22 VARCHAR(200) COLLATE DATABASE_DEFAULT ,col23 VARCHAR(200) COLLATE DATABASE_DEFAULT ,col24 VARCHAR(200) COLLATE DATABASE_DEFAULT ,col25 VARCHAR(200) COLLATE DATABASE_DEFAULT,col26 VARCHAR(200) COLLATE DATABASE_DEFAULT )

IF object_id('tempdb..#final_status') IS NOT NULL
    DROP TABLE #final_status
CREATE TABLE #final_status ([status] VARCHAR(10) COLLATE DATABASE_DEFAULT , calc_id INT, [desc] VARCHAR(100) COLLATE DATABASE_DEFAULT , [est_final] VARCHAR(100) COLLATE DATABASE_DEFAULT )

IF object_id('tempdb..#output') IS NOT NULL
    DROP TABLE #output
CREATE TABLE #output (id INT IDENTITY(1,1), [output] VARCHAR(255) COLLATE DATABASE_DEFAULT )


DECLARE @sql VARCHAR(8000)
DECLARE @process_id VARCHAR(100)
DECLARE @process_table VARCHAR(200)
DECLARE @user VARCHAR(100)  = dbo.FNADBUser()
DECLARE @file_folder_path VARCHAR(200) = @shared_folder + 'sap_export_file\'
DECLARE @pdf_folder_path VARCHAR(200) = @shared_folder + 'sap_export_pdf\'
Declare @source_folder varchar(500) = @shared_folder + 'invoice_docs\'
DECLARE @calc_id INT, @as_of_date DATETIME, @invoice_date DATETIME, @invoice_file_name VARCHAR(100), @invoice_number VARCHAR(100), @contract_id INT
DECLARE @bcp_error_status VARCHAR(100), @bcp_error_status1 VARCHAR(100)
DECLARE @time_stamp VARCHAR(50)


/*------------- FOR ESTIMATE BC APPROVED --------------*/

IF object_id('tempdb..#temp_bc_approved') IS NOT NULL
    DROP TABLE #temp_bc_approved

SELECT civv.calc_id, civv.as_of_date, civv.settlement_date, cmb.as_of_date [close_as_of_date] 
INTO #temp_bc_approved 
FROM Calc_invoice_Volume_variance civv 
LEFT JOIN close_measurement_books cmb ON dbo.FNAGetContractMonth(civv.as_of_date) = cmb.as_of_date
WHERE civv.invoice_status = 20711 AND (civv.finalized IS NULL OR civv.finalized = 'n') AND civv.netting_calc_id IS NULL

DECLARE bc_approved_cursor CURSOR FOR 
SELECT calc_id, as_of_date, settlement_date
FROM #temp_bc_approved
WHERE close_as_of_date IS NULL

OPEN bc_approved_cursor
FETCH NEXT FROM bc_approved_cursor 
INTO @calc_id, @as_of_date, @invoice_date

WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @process_id = dbo.FNAGETnewID()
	SET @process_table = dbo.FNAProcesstablename('SAP_estimate',@user,@process_id)
	
	SET @sql = 'EXEC spa_SettlementExport_estimate @flag=''s'',@counterparty_id='''',@contract_id='''',@as_of_date=''' + CAST(@as_of_date AS VARCHAR) + ''',@invoice_date=''' + CAST(@invoice_date AS VARCHAR) + ''',@calc_id=''' + CAST(@calc_id AS VARCHAR) + ''',@process_id=''' + @process_id + ''''
	INSERT INTO #sap_data(col1,col2,col3,col4,col5,col6,col7,col8,col9,col10,col11,col12,col13,col14,col15,col16,col17,col18,col19,col20,col21,col22,col23,col24,col25,col26)
	EXEC(@sql)

	IF NOT EXISTS(SELECT 1 FROM #sap_data)
	BEGIN
		INSERT INTO #final_status ([status], calc_id, [desc], [est_final])
		VALUES('Error', @calc_id, 'Data not found for SAP export', 'e')
	END
	ELSE
	BEGIN
		SET @time_stamp = CAST(DATEPART(YYYY,GETDATE()) AS VARCHAR) + '_' + CAST(DATEPART(MM,GETDATE()) AS VARCHAR) + '_' + CAST(DATEPART(DD,GETDATE()) AS VARCHAR) + CAST(DATEPART(HH,GETDATE()) AS VARCHAR) + CAST(DATEPART(MI,GETDATE()) AS VARCHAR) + CAST(DATEPART(SS,GETDATE()) AS VARCHAR)
		--SELECT @sql = 'bcp "SELECT	NULLIF([DOCUMENT_HEADER/KeyField],''''),NULLIF([COMP_CODE /AccountID],''''),NULLIF([DOC_TYPE/CustomerID],''''),NULLIF([DOC_DATE/VendorID],''''),NULLIF([FISC_YEAR/BaseLineDate],''''),NULLIF([PSTNG_DATE/CostCenter],''''),NULLIF([CURRENCY/Amount],''''),NULLIF([HEADER_TXT/TaxCode],''''),NULLIF([REF_DOC_NO/Allocation],''''),NULLIF([REASON_REV/BankID],''''),NULLIF([EXTENSION1-FIELD1/PartnerBankType],''''),NULLIF([Text],''''),[Quantity],NULLIF([Base Unit of Measure],''''),NULLIF([SettlementPeriod],''''),NULLIF([PartnerID],''''),NULLIF([ProfitCenter],'''') FROM ' + @process_table + '" queryout ' + @file_folder_path + 'SAP_Export_Estimate_' + CAST(@calc_id AS VARCHAR) + '_' + @time_stamp + '.csv -c -t";" -T -S' + @@servername
		--print @sql
		--DELETE FROM #output
		--INSERT #output (output)
		--EXEC xp_cmdshell @sql--, NO_OUTPUT
		----SELECT * FROM #output
		--SELECT @bcp_error_status = [output] FROM #output WHERE id = 1
 		--SELECT @bcp_error_status1 = [output] FROM #output WHERE id = 2
		
		DECLARE @result NVARCHAR(1024)
		DECLARE @csv_file VARCHAR(1024) = @file_folder_path + 'SAP_Export_Estimate_' + CAST(@calc_id AS VARCHAR) + '_' + @time_stamp + '.csv'
		SET @sql = 'SELECT	NULLIF([DOCUMENT_HEADER/KeyField],''''),NULLIF([COMP_CODE /AccountID],''''),NULLIF([DOC_TYPE/CustomerID],''''),NULLIF([DOC_DATE/VendorID],''''),NULLIF([FISC_YEAR/BaseLineDate],''''),NULLIF([PSTNG_DATE/CostCenter],''''),NULLIF([CURRENCY/Amount],''''),NULLIF([HEADER_TXT/TaxCode],''''),NULLIF([REF_DOC_NO/Allocation],''''),NULLIF([REASON_REV/BankID],''''),NULLIF([EXTENSION1-FIELD1/PartnerBankType],''''),NULLIF([Text],''''),[Quantity],NULLIF([Base Unit of Measure],''''),NULLIF([SettlementPeriod],''''),NULLIF([PartnerID],''''),NULLIF([ProfitCenter],'''') FROM ' + @process_table
		EXEC spa_export_to_csv @sql, @csv_file, 'n', ';', 'n', 'n', 'y', 'n', 'n', @result OUTPUT  
		
		--IF (@bcp_error_status IS NULL AND @bcp_error_status1 = 'Starting copy...')
		IF (@result = '1')
		BEGIN
			INSERT INTO #final_status ([status], calc_id, [desc],[est_final])
			VALUES('Success', @calc_id, 'Success', 'e')
		END
		ELSE
		BEGIN
			INSERT INTO #final_status ([status], calc_id, [desc],[est_final])
			VALUES('Error', @calc_id, 'Failed copying sap file', 'e')
		END
	END

	FETCH NEXT FROM bc_approved_cursor 
	INTO @calc_id, @as_of_date, @invoice_date
END

CLOSE bc_approved_cursor
DEALLOCATE bc_approved_cursor

/*------------------------ END ESTIMATE -------------------------*/


/*-------------- FOR FINAL/VOIDED SC APPROVED -------------------*/
IF object_id('tempdb..#temp_sc_approved') IS NOT NULL
    DROP TABLE #temp_sc_approved

SELECT DISTINCT civv.calc_id, civv.as_of_date, civv.settlement_date, cmb.as_of_date [close_as_of_date], civv.invoice_file_name [invoice_file_name], civv.invoice_number [invoice_number], civv.contract_id [contract_id]
INTO #temp_sc_approved 
FROM Calc_invoice_Volume_variance civv 
INNER JOIN calc_invoice_volume civ ON civv.calc_id = civ.calc_id
LEFT JOIN close_measurement_books cmb ON dbo.FNAGetContractMonth(civv.as_of_date) = cmb.as_of_date
WHERE ((civv.invoice_status = 20710 AND civv.finalized = 'y') OR (civ.status = 'v' AND civv.invoice_status = 20701)) AND civv.netting_calc_id IS NULL

DECLARE sc_approved_cursor CURSOR FOR 
SELECT calc_id, as_of_date, settlement_date, invoice_file_name, invoice_number, contract_id
FROM #temp_sc_approved
WHERE close_as_of_date IS NULL

OPEN sc_approved_cursor
FETCH NEXT FROM sc_approved_cursor 
INTO @calc_id, @as_of_date, @invoice_date, @invoice_file_name, @invoice_number, @contract_id

WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @process_id = dbo.FNAGETnewID()
	SET @process_table = dbo.FNAProcesstablename('SAP_final',@user,@process_id)
	SET @sql = 'EXEC spa_SettlementExport_final @flag=''s'',@counterparty_id='''',@contract_id=''' + CAST(@contract_id AS VARCHAR) + ''',@as_of_date=''' + CAST(@as_of_date AS VARCHAR) + ''',@invoice_date=''' + CAST(@invoice_date AS VARCHAR) + ''',@calc_id=''' + CAST(@calc_id AS VARCHAR) + ''', @process_id=''' + @process_id + ''''
	
	INSERT INTO #sap_data(col1,col2,col3,col4,col5,col6,col7,col8,col9,col10,col11,col12,col13,col14,col15,col16,col17,col18,col19,col20,col21)
	EXEC(@sql)
	
	IF NOT EXISTS(SELECT 1 FROM #sap_data)
	BEGIN
		INSERT INTO #final_status ([status], calc_id, [desc],[est_final])
		VALUES('Error', @calc_id, 'Data not found for SAP export', 'f')
	END
	ELSE 
	BEGIN
		SET @time_stamp = CAST(DATEPART(YYYY,GETDATE()) AS VARCHAR) + '_' + CAST(DATEPART(MM,GETDATE()) AS VARCHAR) + '_' + CAST(DATEPART(DD,GETDATE()) AS VARCHAR) + CAST(DATEPART(HH,GETDATE()) AS VARCHAR) + CAST(DATEPART(MI,GETDATE()) AS VARCHAR) + CAST(DATEPART(SS,GETDATE()) AS VARCHAR)
		--SELECT @sql = 'bcp "SELECT	NULLIF([DOCUMENT_HEADER/KeyField],''''),NULLIF([COMP_CODE /AccountID],''''),NULLIF([DOC_TYPE/CustomerID],''''),NULLIF([DOC_DATE/VendorID],''''),NULLIF([FISC_YEAR/BaseLineDate],''''),NULLIF([PSTNG_DATE/CostCenter],''''),NULLIF([CURRENCY/Amount],''''),NULLIF([HEADER_TXT/TaxCode],''''),NULLIF([REF_DOC_NO/Allocation],''''),NULLIF([REASON_REV/BankID],''''),NULLIF([EXTENSION1-FIELD1/PartnerBankType],''''),NULLIF([Text],''''),[Quantity],NULLIF([Base Unit of Measure],''''),NULLIF([SettlementPeriod],''''),NULLIF([PartnerID],''''),NULLIF([ProfitCenter],'''') FROM ' + @process_table + '" queryout ' + @file_folder_path + 'SAP_Export_Final_' + CAST(@calc_id AS VARCHAR) + '_' + @time_stamp + '.csv -c -t";" -T -S' + @@servername
		
		--DELETE FROM #output
		--INSERT #output (output)
		--EXEC xp_cmdshell @sql--, NO_OUTPUT
		
		--SET @bcp_error_status = (SELECT TOP(1) [output] FROM #output)
		--;WITH output_cte AS
		--(
		--SELECT TOP 2
		--	*, ROW_NUMBER() OVER(ORDER BY id) AS RowNumber
		--	FROM #output
		--)
		--SELECT @bcp_error_status1 = [output] FROM output_cte WHERE RowNumber = 2
		
		DECLARE @csv_filename VARCHAR(1024) = @file_folder_path + 'SAP_Export_Final_' + CAST(@calc_id AS VARCHAR) + '_' + @time_stamp + '.csv'
		SET @sql = 'SELECT	NULLIF([DOCUMENT_HEADER/KeyField],''''),NULLIF([COMP_CODE /AccountID],''''),NULLIF([DOC_TYPE/CustomerID],''''),NULLIF([DOC_DATE/VendorID],''''),NULLIF([FISC_YEAR/BaseLineDate],''''),NULLIF([PSTNG_DATE/CostCenter],''''),NULLIF([CURRENCY/Amount],''''),NULLIF([HEADER_TXT/TaxCode],''''),NULLIF([REF_DOC_NO/Allocation],''''),NULLIF([REASON_REV/BankID],''''),NULLIF([EXTENSION1-FIELD1/PartnerBankType],''''),NULLIF([Text],''''),[Quantity],NULLIF([Base Unit of Measure],''''),NULLIF([SettlementPeriod],''''),NULLIF([PartnerID],''''),NULLIF([ProfitCenter],'''') FROM ' + @process_table
		
		EXEC spa_export_to_csv @sql, @csv_filename, 'n', ';', 'n', 'n', 'y', 'n', @result OUTPUT   


		--IF (@bcp_error_status IS NULL AND @bcp_error_status1 = 'Starting copy...')
		IF (@result = '1')
		BEGIN
			if @invoice_file_name IS NULL
			BEGIN
				--INSERT INTO #final_status ([status], calc_id, [desc],[est_final])
				--VALUES('Error', @calc_id, 'No Invoice pdf found.', 'f')
				--SET @sql = 'xp_cmdshell ''del "' + @file_folder_path + '\' + 'SAP_Export_Final_' + CAST(@calc_id AS VARCHAR) + '_' + @time_stamp + '.csv' + '"'',no_output'
				--EXEC(@sql)
				SET @csv_filename = @file_folder_path + '\' + 'SAP_Export_Final_' + CAST(@calc_id AS VARCHAR) + '_' + @time_stamp + '.csv'				
				EXEC spa_delete_file @csv_filename, @result OUTPUT
			END
			ELSE
			BEGIN
				Declare @SqlCopy varchar(2000)
				DECLARE @FileName varchar(500)
				Declare @source varchar(500)
				Set @source = @source_folder + @invoice_file_name
				
				--SET @sql =  ' COPY "' + @source + '" ' + @pdf_folder_path + @invoice_number + '.pdf'
				
				--DELETE FROM #output
				--INSERT #output (output)
				--EXEC xp_cmdshell @sql--, NO_OUTPUT
				
				SET @FileName = @pdf_folder_path + @invoice_number + '.pdf'
				EXEC spa_copy_file @source, @FileName, @result OUTPUT 
				
				--SET @bcp_error_status = (SELECT TOP(1) [output] FROM #output)

				--IF (LTRIM(@bcp_error_status) = '1 file(s) copied.')
				IF (@result = '1')
				BEGIN
					DECLARE @email_address VARCHAR(100) = NULL
					
					SELECT @email_address = CASE WHEN civv.invoice_type = 'i' THEN ISNULL(sc.mailing_address, cca.email) ELSE ISNULL(sc.email_remittance_to, cca.remittance_to) END
					FROM Calc_invoice_Volume_variance civv
					INNER JOIN source_counterparty sc ON civv.counterparty_id = sc.source_counterparty_id
					LEFT JOIN counterparty_contract_address cca ON sc.source_counterparty_id = cca.counterparty_id AND cca.contract_id = civv.contract_id
					WHERE civv.calc_id = @calc_id

					IF (@email_address IS NULL OR @email_address = '') 
					BEGIN
						INSERT INTO #final_status ([status], calc_id, [desc],[est_final])
						VALUES('Error', @calc_id, 'No Email Address defined', 'f')
						--SET @sql = 'xp_cmdshell ''del "' + @file_folder_path + '\' + 'SAP_Export_Final_' + CAST(@calc_id AS VARCHAR) + '_' + @time_stamp + '.csv' + '"'',no_output'
						--EXEC(@sql)
						SET @FileName = @file_folder_path + '\' + 'SAP_Export_Final_' + CAST(@calc_id AS VARCHAR) + '_' + @time_stamp + '.csv'
						EXEC spa_delete_file @FileName, @result OUTPUT
						     
						--SET @sql = 'xp_cmdshell ''del "' + @pdf_folder_path + '\' + @invoice_number + '.pdf' + '"'',no_output'
						--EXEC(@sql)
						SET @FileName = @pdf_folder_path + '\' + @invoice_number + '.pdf'
						EXEC spa_delete_file @FileName , @result OUTPUT
						
					END
					ELSE
					BEGIN
						INSERT INTO #final_status ([status], calc_id, [desc],[est_final])
						VALUES('Success', @calc_id, 'Success', 'f')
					END
				END
				ELSE
				BEGIN
					INSERT INTO #final_status ([status], calc_id, [desc],[est_final])
					VALUES('Error', @calc_id, 'Failed copying invoice pdf file', 'f')
					--SET @sql = 'xp_cmdshell ''del "' + @file_folder_path + '\' + 'SAP_Export_Final_' + CAST(@calc_id AS VARCHAR) + '_' + @time_stamp + '.csv' + '"'',no_output'
					--EXEC(@sql)
					SET @FileName = @file_folder_path + '\' + 'SAP_Export_Final_' + CAST(@calc_id AS VARCHAR) + '_' + @time_stamp + '.csv'
					EXEC spa_delete_file @FileName, @result OUTPUT
				END
			END
		END
		ELSE
		BEGIN
			INSERT INTO #final_status ([status], calc_id, [desc],[est_final])
			VALUES('Error', @calc_id, 'Failed copying sap file', 'f')
		END
	END

	FETCH NEXT FROM sc_approved_cursor 
	INTO @calc_id, @as_of_date, @invoice_date, @invoice_file_name, @invoice_number, @contract_id
END

CLOSE sc_approved_cursor
DEALLOCATE sc_approved_cursor

/*------------------------ END FINALIZE/VOID -------------------------*/


/*---- UPDATING THE STATUS TO SAP EXPORT IF SUCCESS AND EXCEPTION IF FAIL ----*/
UPDATE civv
SET civv.invoice_status = 20700
FROM #final_status fs
INNER JOIN Calc_invoice_Volume_variance civv ON fs.calc_id = civv.calc_id
WHERE status = 'Success'

UPDATE civv
SET civv.invoice_status = 20713
FROM #final_status fs
INNER JOIN Calc_invoice_Volume_variance civv ON fs.calc_id = civv.calc_id
WHERE status = 'Error'


/*----------------------- SEND EMAIL -------------------------------*/
DECLARE @email_calc_ids VARCHAR(2000)
SET @email_calc_ids = (SELECT  STUFF(( SELECT ',' + CAST(fs.calc_id AS VARCHAR)
                        FROM #final_status fs
						WHERE fs.est_final = 'f' AND fs.status = 'Success'
                         FOR XML PATH('') 
                        ), 1, 1, '' )
			 AS [calc_ids])

SET @sql = 'EXEC spa_print_invoices @flag=''e'',
						@report_name='''',
						@invoice_ids=''' + @email_calc_ids + ''',
						@reporting_param=''rs -e Exec2005 -l 2700 -s ' + @report_server_url + ' -i "' + @report_server_rss_path + '" -v vFullPathOfOutputFile="' + @shared_folder + 'temp_Note\Invoice Report Template.pdf" -v vReportPath="' + @report_folder + 'Invoice Report Template" -v vFormat="PDF" -v vReportFilter='',
						@report_file_path=''' + @shared_folder + 'temp_Note/Invoice Report Template.pdf'',
						@report_folder=''' + @report_folder + ''',
						@send_option=''y'', @save_invoice=''y'''
EXEC(@sql)


/*-------------------- INSERT INTO LOG TABLE --------------------------*/
INSERT INTO sap_invoice_export_log (calc_id, calc_status, send_status, send_desc)
SELECT calc_id, [est_final], [status], [desc] FROM #final_status

