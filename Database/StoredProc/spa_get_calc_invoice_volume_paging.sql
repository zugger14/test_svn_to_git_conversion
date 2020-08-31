IF OBJECT_ID(N'[dbo].[spa_get_calc_invoice_volume_paging]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_get_calc_invoice_volume_paging]
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: bbishural@pioneersolutionsglobal.com
-- Create date: GETDATE()
-- Description: Paging operations for table get_calc_invoice_volume
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_get_calc_invoice_volume_paging]
	@flag VARCHAR(1) = NULL, 
	@counterparty_id INT = NULL,
	@contract_id INT = NULL,
	@prod_date DATETIME = NULL,
	@as_of_date DATETIME = NULL,
	@sub_id INT = NULL,
	@calc_id VARCHAR(MAX) = NULL,
	@delete_option CHAR(1) = NULL, 	
	@estimate_calculation CHAR(1) = 'n',
	@cpt_type CHAR(1) = NULL,
	@invoice_type CHAR(1) = NULL,
	@remittance_invoice_status INT = NULL,
	@invoice_number INT = NULL,
	@as_of_date_to DATETIME = NULL,
	@invoice_remmit_type CHAR(1) = NULL,
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
        'get_calc_invoice_volume_paging',
        @user_login_id,
        @process_id_paging
    )

EXEC spa_print @temp_table

DECLARE @sql VARCHAR(MAX)

IF @flag_paging = 'i'
BEGIN
    IF @flag = 'e'
    BEGIN
        SET @sql = 'CREATE TABLE ' + @temp_table + ' (
						sno INT IDENTITY(1, 1),
						calc_id VARCHAR(100),
						source_counterparty_id INT,
						invoice_number INT,
						counterparty_name VARCHAR(700),
						contract_name VARCHAR(500),
						prod_date VARCHAR(50),
						prod_date_to VARCHAR(50),
						settlement_date VARCHAR(50),
						as_of_date VARCHAR(50),
						invoice_type VARCHAR(10),
						STATUS VARCHAR(500),
						calc_status VARCHAR(10),
						invoice_lock VARCHAR(100),
						contract_id INT
					)'
        
        EXEC spa_print @sql 
        EXEC (@sql)
        
        SET @sql = 'INSERT ' + @temp_table + '(
						calc_id,
						source_counterparty_id,
						invoice_number,
						counterparty_name,
						contract_name,
						prod_date,
						prod_date_to,
						settlement_date,
						as_of_date,
						invoice_type,
						status,
						calc_status,
						invoice_lock,
						contract_id
					)' +
			
            ' EXEC spa_get_calc_invoice_volume ' +
				dbo.FNASingleQuote(@flag) + ',' +
				dbo.FNASingleQuote(@counterparty_id) + ',' +
				dbo.FNASingleQuote(@contract_id) + ',' +
				dbo.FNASingleQuote(@prod_date) + ',' +
				dbo.FNASingleQuote(@as_of_date) + ',' +
				dbo.FNASingleQuote(@sub_id) + ',' +
				dbo.FNASingleQuote(@calc_id) + ',' +
				dbo.FNASingleQuote(@delete_option) + ',' +
				dbo.FNASingleQuote(@estimate_calculation) + ',' +
				dbo.FNASingleQuote(@cpt_type) + ',' +
				dbo.FNASingleQuote(@invoice_type) + ',' +
				dbo.FNASingleQuote(@remittance_invoice_status) + ',' +
				dbo.FNASingleQuote(@invoice_number) + ',' +  
				dbo.FNASingleQuote(@as_of_date_to) + ',' + 
				dbo.FNASingleQuote(@invoice_remmit_type)
				
        EXEC spa_print @sql 
        EXEC (@sql)
        
        SET @sql = 'select count(*) TotalRow,''' + @process_id_paging + ''' process_id  from ' + @temp_table
        
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

    IF @flag = 'e'
    BEGIN
        SET @sql = 'SELECT calc_id [ID], 
						   source_counterparty_id [Counterparty ID], 
						   invoice_number [Invoice No], 
						   counterparty_name [Counterparty], 
						   contract_name [Contract], 
						   prod_date [Production Month From], 
						   prod_date_to [Production Month To], 
						   settlement_date [Settlement Date], 
						   as_of_date [As Of Date], 
						   invoice_type [Invoice Type], 
						   status [Invoice Status], 
						   calc_status [Calc Status], 
						   invoice_lock [Invoice Lock Status], 
						   contract_id [Contract ID]
					FROM ' + @temp_table + '
					WHERE sno BETWEEN ' + CAST(@row_from AS VARCHAR) + ' AND ' + CAST(@row_to AS VARCHAR) + 
					' ORDER BY sno ASC'
            
		EXEC spa_print @sql 
		EXEC (@sql)               
    END
END