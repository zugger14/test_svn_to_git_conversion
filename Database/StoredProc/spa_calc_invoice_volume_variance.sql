IF OBJECT_ID(N'[dbo].[spa_calc_invoice_volume_variance]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_calc_invoice_volume_variance]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: rgiriv@pioneersolutionsglobal.com
-- Create date: 2012-09-17
-- Description: update operations for table calc_invoice_volume_variance
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- SELECT  * FROM   calc_invoice_volume_variance 
-- spa_calc_invoice_volume_variance 'u',4013,60,'2012-12-01','2012-11-01', 1,'a','b',null,null,null,20700,'test','y'
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_calc_invoice_volume_variance]
	@flag CHAR(1),
	@calc_id INT = NULL,
	@counterparty_id INT = NULL,
	@as_of_date  VARCHAR(50) = NULL,
	@prod_month VARCHAR(50) = NULL,
	@invoice_number VARCHAR(50)= NULL,
	@comment1 VARCHAR(100)= NULL,
	@comment2 VARCHAR(100)= NULL,
	@comment3 VARCHAR(100)= NULL,
	@comment4 VARCHAR(100)= NULL,
	@comment5 VARCHAR(100)= NULL,
	@status INT = 20700,
	@invoice_note VARCHAR(500) = NULL,
	@invoice_lock CHAR(1) = 'y',
	@invoice_type CHAR(1) = NULL
	
AS 

DECLARE @sql as VARCHAR(MAX)
IF @flag='s'
BEGIN
	SET  @sql =
		'SELECT 
			calc_id AS [Invoice ID],  
			dbo.FNADateFormat(as_of_date) AS [As of Date],  
			dbo.FNADateFormat(prod_date)as [Production Month],
			invoice_number AS [Invoice Number], 
			CASE WHEN ci.invoice_type =''i'' THEN ''Invoice'' WHEN ci.invoice_type =''r'' THEN ''Remittance'' END [Invoice Type],
			sdv.code  [Invoice Status],
			CASE WHEN [status] = ''v'' THEN ''Voided'' WHEN ISNULL(civ_status.finalized,''n'')=''y'' THEN ''Final'' ELSE ''Initial'' END [Calc Status], 
			invoice_note [Invoice Note], comment1 [comment1], comment2 [Comment2], (case when invoice_lock = ''y'' then ''Yes'' else ''No'' end)[Invoice Locked],
			ci.create_user [Created By], ci.create_ts [Created TS], ci.update_user [Updated By], ci.update_ts[ Update TS]
		FROM  calc_invoice_volume_variance ci
			LEFT JOIN dbo.static_data_value sdv ON sdv.value_id = ci.invoice_status
			CROSS APPLY(SELECT MAX(status) status,MAX(finalized) finalized FROM calc_invoice_volume WHERE calc_id = ci.calc_id)civ_status
		WHERE counterparty_id =' + cast(@counterparty_id AS VARCHAR)

	IF @prod_month IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND YEAR(prod_date)='''+ CAST(YEAR(@prod_month) AS VARCHAR) +''' AND MONTH(prod_date)='''+ CAST(MONTH(@prod_month) AS VARCHAR) +''''
	END
		SET  @sql = @sql  + 'Order by calc_id desc'
	EXEC spa_print @sql
	EXEC (@sql)
END
IF @flag = 'u'
	BEGIN
		UPDATE calc_invoice_volume_variance
		SET    as_of_date = @as_of_date,
		       prod_date = @prod_month,
		       invoice_status = @status,
		       comment1 = @comment1,
		       comment2 = @comment2,
		       comment3 = @comment3,
		       comment4 = @comment4,
		       comment5 = @comment5,
		       invoice_note = @invoice_note,
		       invoice_lock = @invoice_lock
		WHERE  calc_id = @calc_id
	    
	    -- alert call
		DECLARE @alert_process_table VARCHAR(300)
		DECLARE @process_id VARCHAR(300)
		
		SET @process_id = ISNULL(@process_id, dbo.FNAGetNewID())
		SET @alert_process_table = 'adiha_process.dbo.alert_invoice_' + @process_id + '_ai'
		IF(SELECT invoice_status  FROM calc_invoice_volume_variance WHERE calc_id = @calc_id) IS NOT NULL
		BEGIN
			
			EXEC spa_print 'CREATE TABLE ', @alert_process_table, '(calc_id INT NOT NULL, invoice_number INT NOT NULL, invoice_status INT NOT NULL)'
			EXEC('CREATE TABLE ' + @alert_process_table + ' (
		      		calc_id         INT NOT NULL,
		      		invoice_number  INT NOT NULL,
		      		invoice_status  INT NOT NULL,
		      		hyperlink1      VARCHAR(5000),
		      		hyperlink2      VARCHAR(5000),
		      		hyperlink3      VARCHAR(5000),
		      		hyperlink4      VARCHAR(5000),
		      		hyperlink5      VARCHAR(5000)
				  )')
			SET @sql = 'INSERT INTO ' + @alert_process_table + '(calc_id, invoice_number, invoice_status)
						SELECT calc_id,
							   invoice_number,
							   invoice_status
						FROM  calc_invoice_volume_variance civv 
						WHERE  calc_id = ' + CAST(@calc_id AS VARCHAR(10)) + ''
			EXEC spa_print @sql
			EXEC(@sql)		
			EXEC spa_register_event 20605, 20512, @alert_process_table, 0, @process_id
			
		END
	    
		IF @@ERROR <> 0
			EXEC spa_ErrorHandler @@ERROR,
				 "update Invoice",
				 "spa_calc_invoice_volume_variance",
				 "DB Error",
				 "Error on updating Invoice.",
				 ''
		ELSE
			EXEC spa_ErrorHandler 0,
				 'Save Invoice',
				 'spa_save_invoice',
				 'Success',
				 'Invoice Successfully Updated.',
				 ''
	END
IF @flag='a'
	BEGIN
		SELECT calc_id,
		       counterparty_id,
		       dbo.FNADateFormat(as_of_date) [As Of Date],
		       dbo.FNADateFormat(prod_date) [Production Month],
		       invoice_number [Invoice Number],
		       invoice_status,
		       comment1,
		       comment2,
		       comment3,
		       comment4,
		       comment5,
		       invoice_note,
		       invoice_lock
		FROM   calc_invoice_volume_variance
		WHERE  calc_id = @calc_id
	END