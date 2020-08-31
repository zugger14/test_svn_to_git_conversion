IF OBJECT_ID(N'[dbo].[spa_source_deal_cng]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_source_deal_cng]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: msingh@pioneersolutionsglobal.com
-- Create date: 2015-04-09
-- Description: CRUD operations for table source_deal_cng
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- 's' - list all data.
-- 'a' - List specific data. 
-- 'd' - Delete specific data.
-- 'c' - For cash apply logic.
-- 'l' - For unlock deals
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_source_deal_cng]
	  @flag					 CHAR(1)
	, @source_deal_cng_id	 VARCHAR(500) = NULL
	, @card_type			 INT = NULL
	, @counterparty_id		 INT = NULL
	, @credit_card_no		 VARCHAR(100) = NULL	
	, @transaction_date		 DATETIME = NULL
	, @start_time			 DATETIME = NULL		
	, @end_time				 DATETIME = NULL
	, @pulser_start_time	 DATETIME = NULL
	, @pulser_end_time		 DATETIME = NULL
	, @location_id			 INT = NULL
	, @quantity				 NUMERIC(38,20) = NULL
	, @price				 NUMERIC(38,20) = NULL
	, @pump_number			 VARCHAR(100) = NULL	
	, @driver				 VARCHAR(100) = NULL	
	, @vehicle_id			 VARCHAR(100) = NULL	
	, @odo_meter			 VARCHAR(100) = NULL	
	, @payment_status		 CHAR(1)	= 0
	, @cash_apply			 NUMERIC(38,20) = NULL
	, @source_deal_cng_id_to VARCHAR(500)  = NULL
	, @batch_process_id		 VARCHAR(250) = NULL
	, @batch_report_param	 VARCHAR(500) = NULL 
	, @enable_paging		 INT = 0
	, @page_size			 INT = NULL
	, @page_no				 INT = NULL
	
AS 
SET NOCOUNT ON

IF @source_deal_cng_id = '' SET @source_deal_cng_id = NULL
IF @card_type = '' SET @card_type = NULL
IF @counterparty_id = '' SET @counterparty_id = NULL
IF @credit_card_no = '' SET @credit_card_no = NULL
IF @transaction_date = '' SET @transaction_date = NULL
IF @start_time = '' SET @start_time = NULL
IF @end_time = '' SET @end_time = NULL
IF @pulser_start_time = '' SET @pulser_start_time = NULL
IF @pulser_end_time = '' SET @pulser_end_time = NULL
IF @location_id = '' SET @location_id = NULL
IF @pump_number = '' SET @pump_number = NULL
IF @driver = '' SET @driver = NULL
IF @vehicle_id = '' SET @vehicle_id = NULL
IF @odo_meter = '' SET @odo_meter = NULL
IF @payment_status = '' SET @payment_status = NULL
IF @source_deal_cng_id_to = '' SET @source_deal_cng_id_to = NULL

DECLARE @sql VARCHAR(4000),  @err_no INT

/*******************************************1st Paging Batch START**********************************************/
 
DECLARE @str_batch_table VARCHAR(8000)
DECLARE @user_login_id VARCHAR(50)
DECLARE @sql_paging VARCHAR(8000)
DECLARE @is_batch BIT
 
SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser() 
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 
 
IF @is_batch = 1
   SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
 
IF @enable_paging = 1 --paging processing
BEGIN
   IF @batch_process_id IS NULL
      SET @batch_process_id = dbo.FNAGetNewID()
 
   SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)
 
   --retrieve data from paging table instead of main table
   IF @page_no IS NOT NULL 
   BEGIN
      SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no) 
      EXEC (@sql_paging) 
      RETURN 
   END
END
 
/*******************************************1st Paging Batch END**********************************************/
DECLARE @client_card_type INT
SELECT @client_card_type = value_id FROM static_data_value sdv WHERE code = 'MLGW' AND type_id = 32300  

IF @flag = 's'
BEGIN
	SET @sql = 'SELECT sdc.source_deal_cng_id 
					, sdv.code
					, sc.counterparty_name
					, sdc.credit_card_no
					, sdc.transaction_date
					, sdc.start_time
					, sdc.end_time
					, sdc.pulser_start_time
					, sdc.pulser_end_time
					, sml.Location_Name
					, ROUND(dbo.FNARemoveTrailingZeroes(sdc.quantity), 2) quantity
					, ROUND(dbo.FNARemoveTrailingZeroes(sdc.price), 2) price
					, ROUND(dbo.FNARemoveTrailingZeroes(sdc.Amount), 2) amount
					, ROUND(dbo.FNARemoveTrailingZeroes(sdc.Settlement), 2) settlement
					, ROUND(dbo.FNARemoveTrailingZeroes(sdc.Credit), 2) credit
					, ROUND(dbo.FNARemoveTrailingZeroes(sdc.cash_apply), 2) cash_apply
					, sdc.pump_number
					, sdc.driver
					, sdc.vehicle_id
					, sdc.odo_meter
					, CASE WHEN sdc.payment_status = 1 THEN ''Paid'' ELSE ''Unpaid'' END payment_status
					,CASE WHEN ISNULL(sdc.lock,0) = 1 THEN ''Yes'' ELSE ''No'' END lock
				' + @str_batch_table + ' 
				FROM source_deal_cng sdc
				LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdc.counterparty_id
				LEFT JOIN static_data_value sdv ON sdv.value_id = sdc.card_type AND sdv.type_id = 32300
				LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = sdc.location_id
				WHERE 1 = 1	' +
				CASE WHEN @source_deal_cng_id IS NOT NULL THEN ' AND sdc.source_deal_cng_id ' + CASE WHEN @source_deal_cng_id_to IS NOT NULL THEN '>=' ELSE '=' END + CAST(@source_deal_cng_id AS VARCHAR(50)) ELSE '' END +
				CASE WHEN @source_deal_cng_id_to IS NOT NULL THEN ' AND sdc.source_deal_cng_id <= ' + CAST(@source_deal_cng_id_to AS VARCHAR(50)) ELSE '' END +
				CASE WHEN @card_type IS NOT NULL THEN ' AND sdc.card_type = ' + CAST(@card_type AS VARCHAR(50)) ELSE '' END +
				CASE WHEN @start_time IS NOT NULL THEN ' AND sdc.start_time >= ''' + CAST(@start_time AS VARCHAR(50)) +''''  ELSE '' END +
				CASE WHEN @end_time IS NOT NULL THEN ' AND sdc.end_time <= ''' + CAST(@end_time AS VARCHAR(50)) +'''' ELSE '' END +
				CASE WHEN @payment_status IS NOT NULL THEN ' AND sdc.payment_status = ' + CAST(@payment_status AS VARCHAR(50)) ELSE '' END +
				CASE WHEN @counterparty_id IS NOT NULL THEN ' AND sdc.counterparty_id = ' + CAST(@counterparty_id AS VARCHAR(50)) ELSE '' END +
				CASE WHEN @credit_card_no IS NOT NULL THEN ' AND sdc.credit_card_no like ''' + @credit_card_no + '%''' ELSE '' END +
				'ORDER BY sdc.source_deal_cng_id DESC'
	EXEC(@sql)	
END
ELSE IF @flag = 'a'
BEGIN
    SELECT TOP 1 
		sdc.source_deal_cng_id,
		sdc.counterparty_id,
		a.excess_amount,
		sdc.cash_apply,
		sdc.receive_date
    FROM source_deal_cng sdc
		LEFT JOIN source_minor_location sml
			ON  sml.source_minor_location_id = sdc.location_id
		LEFT JOIN source_counterparty sc
			ON  sc.source_counterparty_id = sdc.counterparty_id
        OUTER APPLY (
			SELECT TOP 1 
				cash_apply_id,
				received_date,
				cash_apply_amount,
				outstanding_amount,
				counterparty_id,
				excess_amount
			FROM cash_apply_cng     cac
			WHERE cac.counterparty_id = sdc.counterparty_id
			ORDER BY received_date DESC, create_ts DESC
    ) a
    WHERE sdc.counterparty_id = CAST(@counterparty_id AS INT)
END
ELSE IF @flag = 'i'
BEGIN
	IF @client_card_type = @card_type
	BEGIN
		SELECT @counterparty_id = counterparty_id FROM counterparty_bank_info 
		WHERE account_no = ISNULL(NULLIF(@credit_card_no, ''), -1)

		IF @counterparty_id IS NULL
		BEGIN
			EXEC spa_ErrorHandler 1
				, 'source_deal_cng'
				, 'spa_source_deal_cng'
				, 'ERROR' 
				, 'Credit Card Number not found in the system.'
				, @credit_card_no 
			RETURN
		END			
	END

	BEGIN TRY
		INSERT INTO source_deal_cng(
			  card_type
			, counterparty_id
			, credit_card_no
			, transaction_date
			, start_time
			, end_time
			, pulser_start_time
			, pulser_end_time
			, location_id
			, quantity
			, price
			, pump_number
			, driver
			, vehicle_id
			, odo_meter
			, payment_status	
			, cash_apply			
		)
		VALUES (
			@card_type
			, @counterparty_id
			, @credit_card_no
			, @transaction_date
			, @start_time
			, @end_time
			, @pulser_start_time
			, @pulser_end_time
			, @location_id
			, @quantity
			, @price
			, @pump_number
			, @driver
			, @vehicle_id
			, @odo_meter
			, @payment_status
			, @cash_apply				
		)
		
		DECLARE @inserted_id INT 
		SET  @inserted_id = SCOPE_IDENTITY()
		
		UPDATE source_deal_cng SET Amount = quantity * price,
		                        credit = CASE WHEN payment_status = 0 OR card_type = 303171 THEN quantity * price ELSE 0 END ,
		                        settlement = quantity * price,
								outstanding_amount = CASE WHEN payment_status = 0 THEN quantity * price ELSE 0 END
		WHERE source_deal_cng_id = @inserted_id
		 
		EXEC spa_ErrorHandler 0
			, 'source_deal_cng'
			, 'spa_source_deal_cng'
			, 'Success' 
			, 'Changes have been successfully saved.'
			, @source_deal_cng_id 
	END TRY
	BEGIN CATCH
		SELECT @err_no = ERROR_NUMBER()
  
		EXEC spa_ErrorHandler @err_no
			, 'source_deal_cng'
			, 'spa_source_deal_cng'
			, 'Error'
			, 'Failed to save data'
			, @source_deal_cng_id
	END CATCH   

END
 
ELSE IF @flag = 'u'
BEGIN
IF @client_card_type = @card_type
		BEGIN
			SELECT @counterparty_id = counterparty_id FROM counterparty_bank_info 
			WHERE account_no = ISNULL(NULLIF(@credit_card_no, ''), -1)

			IF @counterparty_id IS NULL
			BEGIN
				EXEC spa_ErrorHandler 1
					, 'source_deal_cng'
					, 'spa_source_deal_cng'
					, 'ERROR' 
					, 'Credit Card Number not found in the system.'
					, @credit_card_no 
				RETURN
			END			
		END
	BEGIN TRY
		
		UPDATE source_deal_cng
		SET card_type = @card_type				
			, counterparty_id = @counterparty_id
			, credit_card_no = @credit_card_no
			, transaction_date = @transaction_date
			, start_time = @start_time
			, end_time = @end_time
			, pulser_start_time = @pulser_start_time
			, pulser_end_time = @pulser_end_time
			, location_id = @location_id
			, quantity = @quantity
			, price = @price
			, pump_number = @pump_number
			, driver = @driver
			, vehicle_id = @vehicle_id
			, odo_meter = @odo_meter
			, payment_status = @payment_status
			, cash_apply = @cash_apply
			, Amount = @quantity * @price
			, settlement = @quantity * @price
			, credit = CASE WHEN @payment_status = 0 THEN @quantity * @price ELSE 0 END
			, outstanding_amount = CASE WHEN @payment_status = 0 THEN @quantity * @price ELSE 0 END
		WHERE source_deal_cng_id = CAST(@source_deal_cng_id	 AS INT)
 
		EXEC spa_ErrorHandler 0
			, 'source_deal_cng'
			, 'spa_source_deal_cng'
			, 'Success' 
			, 'Changes have been successfully saved.'
			, @source_deal_cng_id 
	END TRY
	BEGIN CATCH
		SELECT @err_no = ERROR_NUMBER() 
  
		EXEC spa_ErrorHandler @err_no
			, 'source_deal_cng'
			, 'spa_source_deal_cng'
			, 'Error'
			, 'Failed to save data'
			, @source_deal_cng_id
	END CATCH
END
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY

	CREATE TABLE #deletedData ( 
		ID INT, 
		counterparty_id INT, 
		received_date datetime, 
		payment_status char,
		cash_apply float
	 )
	
		DELETE sdc 
			OUTPUT deleted.source_deal_cng_id,deleted.counterparty_id,deleted.receive_date,deleted.payment_status,deleted.cash_apply INTO #deletedData
			FROM source_deal_cng sdc 
			INNER JOIN 
			dbo.SplitCommaSeperatedValues(@source_deal_cng_id) a on a.item = sdc.source_deal_cng_id
		WHERE ISNULL(sdc.lock,0)=0

		UPDATE cac SET excess_amount = excess_amount + dd.cash_apply FROM 
			cash_apply_cng  cac INNER JOIN #deletedData dd ON dd.counterparty_id = cac.counterparty_id
			AND create_ts =  (Select max(create_ts) FROM cash_apply_cng  WHERE counterparty_id = dd.counterparty_id)
		
		-- WHERE source_deal_cng_id = @source_deal_cng_id
 
		EXEC spa_ErrorHandler 0
			, 'source_deal_cng'
			, 'spa_source_deal_cng'
			, 'Success' 
			, 'Changes have been successfully saved.'
			, @source_deal_cng_id 
	END TRY
	
	BEGIN CATCH
		SELECT @err_no = ERROR_NUMBER()
  
		EXEC spa_ErrorHandler @err_no
			, 'source_deal_cng'
			, 'spa_source_deal_cng'
			, 'Error'
			, 'Failed to save data'
			, @source_deal_cng_id
	END CATCH      
END
ELSE IF @flag = 'c'
BEGIN
	BEGIN TRY		
		UPDATE source_deal_cng
		SET counterparty_id = @counterparty_id			
			, cash_apply = @cash_apply
		WHERE source_deal_cng_id = @source_deal_cng_id	
 
		EXEC spa_ErrorHandler 0
			, 'source_deal_cng'
			, 'spa_source_deal_cng'
			, 'Success' 
			, 'Changes have been successfully saved.'
			, @source_deal_cng_id 
	END TRY
	BEGIN CATCH
		SELECT @err_no = ERROR_NUMBER() 
  
		EXEC spa_ErrorHandler @err_no
			, 'source_deal_cng'
			, 'spa_source_deal_cng'
			, 'Error'
			, 'Failed to save data'
			, @source_deal_cng_id
	END CATCH
END
ELSE IF @flag = 'l'
BEGIN
	UPDATE sdc
	SET sdc.lock = 0 
	FROM source_deal_cng sdc
	INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_cng_id) i ON i.item = sdc.source_deal_cng_id
	
END
ELSE IF @flag = 'x'
BEGIN
	SELECT sdc.source_deal_cng_id,
	       sdc.card_type,
	       sdc.counterparty_id,
	       sdc.credit_card_no,
	       sdc.transaction_date,
	       sdc.start_time,
	       sdc.end_time,
	       sdc.pulser_start_time,
	       sdc.pulser_end_time,
	       sdc.location_id,
	       dbo.FNARemoveTrailingZeroes(sdc.quantity) quantity,
	       dbo.FNARemoveTrailingZeroes(sdc.price) price,
	       sdc.pump_number,
	       sdc.driver,
	       sdc.vehicle_id,
	       sdc.odo_meter,
	       sdc.payment_status
	FROM   source_deal_cng sdc
	INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_cng_id) a ON a.item = sdc.source_deal_cng_id
END

/*******************************************2nd Paging Batch START**********************************************/
 
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@sql_paging)
 
   --TODO: modify sp and report name
   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_source_deal_cng', 'spa_source_deal_cng')
   EXEC(@sql_paging)  
 
   RETURN
END
 
--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
   EXEC(@sql_paging)
END
 
/*******************************************2nd Paging Batch END**********************************************/
 
GO