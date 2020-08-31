IF OBJECT_ID(N'[dbo].[spa_print_invoices_paging]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_print_invoices_paging]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: bbishural@pioneersolutionsglobal.com
-- Create date: GETDATE()
-- Description: Paging operations for send invoices/remittance UI
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_print_invoices_paging]
    @flag CHAR(1),
    @invoice_ids VARCHAR(MAX) = NULL,
    @counterparty_id INT = NULL,
    @contract_id INT = NULL,
    @as_of_date_from DATETIME = NULL,
    @as_of_date_to DATETIME = NULL,
    @settlement_date_from DATETIME = NULL,
    @settlement_date_to DATETIME = NULL,
    @remittance_invoice_status INT = NULL,
    @invoice_status CHAR(1) = NULL,
    @invoice_number VARCHAR(MAX) = NULL,
    @reporting_param VARCHAR(MAX) = NULL,
    @report_file_path VARCHAR(5000) = NULL,
    @report_name VARCHAR(MAX) = NULL,
	@notify_users VARCHAR(MAX) = NULL,
	@notify_roles VARCHAR(MAX) = NULL,
	@export_csv_path VARCHAR(5000) = NULL,
	@non_system_users VARCHAR(MAX) = NULL,
	@send_option CHAR(1) = NULL,
	@delivery_method INT = NULL,
	@holiday_calendar_id INT = NULL,
	@freq_type INT = NULL,
	@active_start_date DATETIME = NULL,
	@active_start_time VARCHAR(100) = NULL,
	@freq_interval INT = NULL,
	@active_end_date DATETIME = NULL,
	@freq_subday_type INT = NULL,
	@freq_recurrence_factor INT = NULL,	
	@printer_name VARCHAR(200) = NULL,
	@report_folder VARCHAR(500) = NULL,
	@calc_type CHAR(1) = NULL,
	@statement_type INT = NULL, -- statement type(invoice,remittance,netting statmenet Filters)
	@process_id_paging VARCHAR(200) = NULL, 
	@page_size INT = NULL,
	@page_no INT = NULL
    
AS
DECLARE @user_login_id  VARCHAR(50),
        @temp_table     VARCHAR(MAX)
 
DECLARE @flag_paging    CHAR(1)

SET @user_login_id = dbo.FNADBUser()

IF @process_id_paging IS NULL
BEGIN
    SET @flag_paging = 'i'
    SET @process_id_paging = REPLACE(NEWID(), '-', '_')
END

SET @temp_table = dbo.FNAProcessTableName (
        'print_invoices_paging',
        @user_login_id,
        @process_id_paging
    )

EXEC spa_print @temp_table

DECLARE @sql VARCHAR(MAX)

IF @flag_paging = 'i'
BEGIN
    IF @flag = 's'
    BEGIN
        SET @sql = 'CREATE TABLE ' + @temp_table + ' (
						sno INT IDENTITY(1, 1),
						calc_id INT,
						invoice_number INT,
						counterparty_name VARCHAR(500),
						contract_name VARCHAR(500),
						as_of_date VARCHAR(40),
						production_month VARCHAR(40),
						status VARCHAR(100),
						invoice_type VARCHAR(30),
						calc_status VARCHAR(10),
						invoice_locked VARCHAR(10)
					)'
        
        EXEC spa_print @sql 
        EXEC (@sql)
        
        SET @sql = 'INSERT ' + @temp_table + '(
						calc_id,
						invoice_number,
						counterparty_name,
						contract_name,
						as_of_date,
						production_month,
						status,
						invoice_type,
						calc_status,
						invoice_locked
					)' +
					
				' EXEC spa_print_invoices ' +
						dbo.FNASingleQuote(@flag) + ',' +
						dbo.FNASingleQuote(@invoice_ids) + ',' +
						dbo.FNASingleQuote(@counterparty_id) + ',' +
						dbo.FNASingleQuote(@contract_id) + ',' +
						dbo.FNASingleQuote(@as_of_date_from) + ',' +
						dbo.FNASingleQuote(@as_of_date_to) + ',' +
						dbo.FNASingleQuote(@settlement_date_from) + ',' +
						dbo.FNASingleQuote(@settlement_date_to) + ',' +
						dbo.FNASingleQuote(@remittance_invoice_status) + ',' +
						dbo.FNASingleQuote(@invoice_status) + ',' +
						dbo.FNASingleQuote(@invoice_number) + ',' +
						dbo.FNASingleQuote(@reporting_param) + ',' +
						dbo.FNASingleQuote(@report_file_path) + ',' +  
						dbo.FNASingleQuote(@report_name) + ',' +
						dbo.FNASingleQuote(@notify_users) + ',' +
						dbo.FNASingleQuote(@notify_roles) + ',' +
						dbo.FNASingleQuote(@export_csv_path) + ',' + 
						dbo.FNASingleQuote(@non_system_users) + ',' +
						dbo.FNASingleQuote(@send_option) + ',' +
						dbo.FNASingleQuote(@delivery_method) + ',' +
						dbo.FNASingleQuote(@holiday_calendar_id) + ',' + 
						dbo.FNASingleQuote(@freq_type) + ',' +
						dbo.FNASingleQuote(@active_start_date) + ',' +
						dbo.FNASingleQuote(@active_start_time) + ',' +
						dbo.FNASingleQuote(@freq_interval) + ',' + 
						dbo.FNASingleQuote(@active_end_date) + ',' +
						dbo.FNASingleQuote(@freq_subday_type) + ',' +
						dbo.FNASingleQuote(@freq_recurrence_factor) + ',' + 
						dbo.FNASingleQuote(@printer_name) + ',' +
						dbo.FNASingleQuote(@report_folder) + ',' +
						dbo.FNASingleQuote(@calc_type) + ',' +
						dbo.FNASingleQuote(@statement_type)
						
						  
	    
        EXEC spa_print @sql 
        EXEC (@sql)
        SET @sql = 'SELECT COUNT(*) TotalRow, ''' + @process_id_paging + ''' process_id FROM   ' + @temp_table
        EXEC spa_print @sql
        EXEC (@sql)
    END
   
END

ELSE
BEGIN
	DECLARE @row_from INT, @row_to INT 
	SET @row_to = @page_no * @page_size 
	IF @page_no > 1 
	SET @row_from = ((@page_no-1) * @page_size) + 1
	ELSE 
	SET @row_from = @page_no

    IF @flag = 's'
    BEGIN
        SET @sql = 'SELECT calc_id [Invoice ID],
							invoice_number [Invoice Number],
							counterparty_name [Counterparty],
							contract_name [Contract],
							as_of_date [As Of Date],
							production_month [Production Month],
							STATUS [Status],
							invoice_type [Invoice Type],
							calc_status [Calculation Status],
							invoice_locked [Invoice Locked]
					 FROM   ' + @temp_table + '
					 WHERE  sno BETWEEN ' + CAST(@row_from AS VARCHAR) + ' AND ' + CAST(@row_to AS VARCHAR) + '
					 ORDER BY sno ASC'
            
		EXEC spa_print @sql 
		EXEC (@sql)               
    END
END