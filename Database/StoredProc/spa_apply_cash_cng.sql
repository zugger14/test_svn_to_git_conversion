IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_apply_cash_cng]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_apply_cash_cng]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_apply_cash_cng]
	@flag CHAR(1),
	@counterparty_id INT = NULL,
	@cash_applied FLOAT = 0,
	@receive_date DATETIME =  NULL
AS
BEGIN
SET NOCOUNT ON

IF @counterparty_id = '' SET @counterparty_id = NULL
IF @receive_date =  '' SET @receive_date =  NULL

DECLARE @sql VARCHAR(MAX)

IF @flag = 's'
BEGIN
	SET @sql = ''
	SET @sql = 'SELECT sc.counterparty_name,
					   received_date, 
					   ROUND(cash_apply_amount,2) cash_apply_amount, 
					   ROUND(excess_amount,2) excess_amount,
					   ROUND(outstanding_amount,2) outstanding_amount
	            FROM cash_apply_cng cac 
					INNER JOIN source_counterparty sc 
						ON sc.source_counterparty_id = cac.counterparty_id 
	            WHERE 1 = 1  '+
		CASE 
		     WHEN @counterparty_id IS NOT NULL THEN 
		          ' AND cac.counterparty_id = ' + CAST(@counterparty_id AS VARCHAR(50))
		     ELSE ''
		END +
		CASE 
		     WHEN @receive_date IS NOT NULL THEN ' AND dbo.FNADateFormat(cac.received_date) = ''' + 
		          dbo.FNADateFormat(@receive_date) + ''''
		     ELSE ''
		END  + 
		
		' ORDER BY cash_apply_id desc'
	
	EXEC(@sql)
END
BEGIN TRY

	SET @receive_date   = ISNULL(@receive_date,GETDATE());

	DECLARE @amount FLOAT, 
			@counterparty INT,
			@transaction_date DATETIME,
			@payment_status bit,
			@paid_amount FLOAT,
			@outstanding_amount FLOAT,
			@source_deal_cng_id INT,
			@remaining_balance FLOAT,
			@previous_cash FLOAT,
			@cash_applied_amount FLOAT,
			@count_rows INT
	DECLARE @err_no INT,@is_higher BIT

	SET @cash_applied_amount = @cash_applied
	IF OBJECT_ID('tempdb..#list_of_deals') IS NOT NULL
		DROP TABLE #list_of_deals
    IF OBJECT_ID('tempdb..#temp_cash_applied') IS NOT NULL
		DROP TABLE #temp_cash_applied

 
IF @flag = 'a'
	BEGIN 
		CREATE TABLE #temp_cash_applied
			(	
				source_deal_cng_id INT, 
				cash_applied float,
				counterparty INT,
				AMOUNT FLOAT,
				transaction_date Datetime,
				payment_status BIT,
				paid_amount FLOAT,
				outstanding_amount FLOAT,
				previous_cash_applied FLOAT,
				lock BIT
			)

		SELECT source_deal_cng_id,
		       sdc.counterparty_id,
		       amount,
		       transaction_date,
		       payment_status,
		       ISNULL(outstanding_amount, 0) outstanding_amount,
		       ISNULL(cash_apply, 0) cash_apply
		       INTO #list_of_deals
		FROM source_deal_cng sdc
			INNER JOIN source_counterparty sc
				ON  sc.source_counterparty_id = sdc.counterparty_id
		WHERE sdc.counterparty_id = @counterparty_id
			AND payment_status = 0
			AND amount <> 0
		ORDER BY transaction_date  ASC

		DECLARE db_cursor CURSOR FOR  
		SELECT source_deal_cng_id,counterparty_id,amount,transaction_date,payment_status,outstanding_amount,cash_apply
		FROM #list_of_deals		

		OPEN  db_cursor
		FETCH NEXT FROM db_cursor INTO @source_deal_cng_id,@counterparty,@amount,@transaction_date,@payment_status,@outstanding_amount,@previous_cash
		WHILE @@Fetch_status = 0 
		BEGIN 
			IF @outstanding_amount <>0	
				SET @amount = @outstanding_amount
			IF @cash_applied > @amount
			 BEGIN
				EXEC spa_print 'Cash applied is high'
				SET @paid_amount = @amount
				SET @remaining_balance = @cash_applied-@paid_amount
				SET @payment_status = 1
				SET @outstanding_amount = 0
				SET @cash_applied = @remaining_balance
				EXEC spa_print @paid_amount
				EXEC spa_print @remaining_balance
				SET @is_higher = 1
			 END	
			ELSE
			 BEGIN
				EXEC spa_print 'less cash'
				SET @paid_amount = @cash_applied
				SET @payment_status = 0 
				IF @outstanding_amount = 0 
				BEGIN
				EXEC spa_print 'here'
					SET @outstanding_amount = @amount- @cash_applied
				END
				ELSE
				BEGIN 
				
					SET @outstanding_amount = @outstanding_amount- @cash_applied
				END
			 END	
			 
			INSERT INTO #temp_cash_applied
			  (
			    source_deal_cng_id,
			    cash_applied,
			    counterparty,
			    AMOUNT,
			    transaction_date,
			    payment_status,
			    paid_amount,
			    outstanding_amount,
			    previous_cash_applied,
			    lock
			  )
			SELECT @source_deal_cng_id,
			       @paid_amount,
			       @counterparty,
			       @amount,
			       @transaction_date,
			       @payment_status,
			       @paid_amount,
			       @outstanding_amount,
			       @previous_cash,
			       CASE 
			            WHEN @outstanding_amount = 0 THEN 1
			            ELSE 0
			       END
			
			IF @outstanding_amount > 0 
				BREAK

			FETCH NEXT FROM db_cursor INTO @source_deal_cng_id,@counterparty,@amount,@transaction_date,@payment_status,@outstanding_amount,@previous_cash
		END 
		CLOSE db_cursor   
		DEALLOCATE db_cursor

SELECT @count_rows = COUNT(1) FROM 	#list_of_deals
		
IF @count_rows  > 0
	BEGIN
		UPDATE sdc SET 
			sdc.cash_apply = tca.cash_applied + lod.cash_apply,
			sdc.outstanding_amount = tca.outstanding_amount,
			sdc.payment_status  = tca.payment_status,
			sdc.credit = tca.outstanding_amount,
			sdc.receive_date = @receive_date,
			sdc.lock = tca.lock	
		FROM source_deal_cng sdc
			 INNER JOIN #temp_cash_applied tca 
				ON sdc.source_deal_cng_id = tca.source_deal_cng_id
					AND sdc.transaction_date = tca.transaction_date
			 INNER JOIN #list_of_deals lod 
				ON lod.source_deal_cng_id = sdc.source_deal_cng_id
	END

	INSERT INTO cash_apply_cng(received_date, cash_apply_amount, excess_amount, outstanding_amount, counterparty_id)
	SELECT @receive_date,
	       @cash_applied_amount,
	       CASE 
	            WHEN @count_rows > 0 THEN CASE 
	                                           WHEN @cash_applied_amount > 
	                                                ISNULL(@amount, 0) THEN 
	                                                ISNULL(@remaining_balance, 0)
	                                           ELSE 0
	                                      END
	            ELSE @cash_applied_amount
	       END,
	       CASE 
	            WHEN @cash_applied_amount < ISNULL(@amount, 0) THEN ISNULL(@outstanding_amount, 0)
	            ELSE 0
	       END,
	       @counterparty_id

		EXEC spa_ErrorHandler 0
			, 'source_deal_cng'
			, 'spa_apply_cash_apply_cng'
			, 'Success' 
			, 'Changes have been successfully saved.'
			, @source_deal_cng_id 
	
	END
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
GO