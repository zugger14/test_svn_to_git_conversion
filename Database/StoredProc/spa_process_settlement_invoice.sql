/****** Object:  StoredProcedure [dbo].[spa_process_settlement_invoice]    Script Date: 10/08/2009 13:46:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_process_settlement_invoice]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_process_settlement_invoice]
/****** Object:  StoredProcedure [dbo].[spa_process_settlement_invoice]    Script Date: 10/08/2009 13:46:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[spa_process_settlement_invoice]
	 @sub_id INT = NULL,
	 @prod_date DATETIME,
	 @as_of_date DATETIME,
	 @counterparty_id VARCHAR(MAX) = NULL,
	 @settlement_adjustment CHAR(1) = 'n',
	 @contract_id VARCHAR(MAX) = NULL,
	 @process_id VARCHAR(100) = NULL,
	 @estimate_calculation CHAR(1) = 'n',
	 @module_type VARCHAR(10) = NULL,
	 @charge_type_id VARCHAR(MAX) = NULL,
	 @deal_id VARCHAR(100) = NULL,
	 @deal_ref_id VARCHAR(100) = NULL,
	 @prod_date_to DATETIME = NULL,
	 @deal_set_calc CHAR(1) = 'n',
	 @cpt_type CHAR(1) = 'e',
	 @deal_list_table VARCHAR(300) = NULL, -- contains list of deals to be processed
	 @date_type CHAR(1) = NULL,
	 @calc_id VARCHAR(100) = NULL,
	 @scheduled_job CHAR(1) = 'n',
	 @batch_process_id	VARCHAR(120) = NULL, -- 's' - Settlement, 't' Term
	 @batch_report_param	VARCHAR(5000) = NULL
AS

SET NOCOUNT ON

IF @sub_id IS NULL
    SET @sub_id = -1

IF @settlement_adjustment IS NULL
    SET @settlement_adjustment = ''

IF @scheduled_job = 'y'
BEGIN
    SET @prod_date = @as_of_date
    SET @prod_date_to = @as_of_date
END
	
	
DECLARE @job_name             VARCHAR(50)
--DECLARE @process_id VARCHAR(50)
DECLARE @spa              VARCHAR(MAX)
DECLARE @user_id          VARCHAR(100)
DECLARE @calc_start_time  DATETIME 
DECLARE @prod_date_end    DATETIME

SET @user_id = dbo.FNADBUser()

SET @process_id = REPLACE(NEWID(), '-', '_')
IF @batch_process_id IS NULL
	SET @batch_process_id = REPLACE(NEWID(), '-', '_')
SET @job_name = 'batch_' + @batch_process_id
SET @calc_start_time = GETDATE()

-- Custom deal filter when deal settlement is run
IF @deal_set_calc = 'y'
BEGIN
	DECLARE @sql VARCHAR(MAX)
	SET @deal_list_table = dbo.FNAProcessTableName('deal_settlement', @user_id, @process_id)
	SET @sql = 'SELECT sdh.source_deal_header_id INTO ' + @deal_list_table + ' 
	FROM   source_deal_header sdh
	       INNER JOIN dbo.FNASplit(''' + @counterparty_id+ ''','','') cpty
	            ON  sdh.counterparty_id = cpty.item '
	IF @contract_id IS NOT NULL
	BEGIN
		SET @sql += ' INNER JOIN dbo.FNASplit(''' + @contract_id + ''','','') ctrct
					ON  sdh.contract_id = ctrct.item'		
	END

	EXEC (@sql)
END 

WHILE @prod_date <= @prod_date_to				
BEGIN
	
	IF @prod_date_to >= DATEADD(m, 1, dbo.FNAGetContractMonth(@prod_date)) -1
	    SET @prod_date_end = DATEADD(m, 1, dbo.FNAGetContractMonth(@prod_date)) -1
	ELSE
	    SET @prod_date_end = @prod_date_to
			
	SET @spa = ' spa_calc_invoice '''+cast(@prod_date as VARCHAR)+''','''+@counterparty_id+''','''+cast(@as_of_date as VARCHAR)+''',''' + @batch_process_id + ''',''n'','''+ISNULL(@settlement_adjustment,'n')+''','+CAST(@sub_id AS VARCHAR)+','''+ISNULL(@contract_id,'NULL')+''','''+CAST(@estimate_calculation AS VARCHAR)+''','''+CAST(@module_type AS VARCHAR)+''','+ISNULL('''' + @charge_type_id + '''','NULL') + ',' + ISNULL('''' + @deal_id + '''', 'NULL') + ',' + ISNULL('''' + @deal_ref_id + '''', 'NULL')+ ',' + ISNULL('''' + @deal_set_calc + '''', 'n')  + ',''' +@cpt_type+'''' + ',' + ISNULL('''' + @deal_list_table + '''', 'NULL')+ ',''' +@date_type+''',' + ISNULL('''' + @calc_id + '''', 'NULL')+','''+cast(@prod_date_end as VARCHAR)+''''
	exec spa_print @spa
	EXEC(@spa)
	SET @prod_date = DATEADD(m,1,@prod_date)					
END

DECLARE @model_name VARCHAR(100),@desc VARCHAR(500),@url VARCHAR(5000),@error_warning VARCHAR(100),@error_success CHAR(1),@total_time VARCHAR(100)

IF @cpt_type = 'm'
    SET @model_name = 'Financial Model Calculation'
ELSE
    SET @model_name = 'Settlement Reconciliation'
	

SET @total_time=CAST(DATEPART(mi,getdate()-@calc_start_time) AS VARCHAR)+ ' min '+ CAST(DATEPART(s,getdate()-@calc_start_time) AS VARCHAR)+' sec'

SET @error_warning = ''
SET @error_success = 's'
IF EXISTS(
       SELECT 'X'
       FROM   process_settlement_invoice_log
       WHERE  process_id = @batch_process_id AND code IN ('Error', 'Warning')
   )
BEGIN
    SET @error_warning = ' <font color="red">(Warnings Found)</font>'
    SET @error_success = 'e'
END
	
SET @url = './dev/spa_html.php?__user_name__=''' + @user_id + '''&spa=exec spa_get_settlement_invoice_log ''' + @batch_process_id + ''''

SET @desc = '<a target="_blank" href="' + @url + '">' + + @model_name + ' Processed:  As of Date  ' + dbo.FNAContractmonthFormat(@as_of_date)+ @error_warning+'.</a> (Elapsed Time: '+@total_time+')'	 

EXEC spa_message_board 'u',
	 @user_id,
	 NULL,
	 'Settlement Reconciliation ',
	 @desc,
	 '',
	 '',
	 @error_success,
	 @batch_process_id,
	 @email_enable = 'y' 

--SET @total_time=CAST(DATEPART(mi,getdate()-@calc_start_time) AS VARCHAR)+ ' min '+ CAST(DATEPART(s,getdate()-@calc_start_time) AS VARCHAR)+' sec'
--SET @url = './dev/spa_html.php?__user_name__=''' + @user_login_id +       
--		'''&spa=exec spa_get_settlement_invoice_log ''' + @test_process_id + ''''   
--	SET @desc = '<a target="_blank" href="' + @url + '">' +       
--		  @model_name+' Processed:  As of Date  ' + dbo.FNAContractmonthFormat(@as_of_date)+      
--		  ' (Errors Found).</a> (Elapsed Time: '+@total_time+')'	 
	  
-- EXEC  spa_message_board 'i', @user_login_id,      
--	   NULL, @model_name,      
--	   @desc, '', '', 'e', @job_name 

