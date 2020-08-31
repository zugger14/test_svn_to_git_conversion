 IF OBJECT_ID(N'[dbo].[spa_stmt_apply_cash]', N'P') IS NOT NULL
     DROP PROCEDURE [dbo].[spa_stmt_apply_cash]
 GO
   
 SET ANSI_NULLS ON
 GO
   
 SET QUOTED_IDENTIFIER ON
 GO
   
 -- ===============================================================================================================
 -- Author: bmaharjan@pioneersolutionsglobal.com
 -- Create date: 2019-01-29
 -- Description: Functionalities for the Apply cash
   
 -- Params:
 -- @flag = 'full_apply' -> Apply the cash completely
 -- @flag = 'partial_apply'	-> Apply the cash paritally with allocation logic

 --===============================================================================================================
CREATE PROCEDURE [dbo].[spa_stmt_apply_cash]
	@flag VARCHAR(1000),
	@stmt_invoice_id INT = NULL,
	@applied_amount FLOAT = NULL,
	@applied_date DATETIME = NULL,
	@stmt_invoice_detail_id INT = NULL,
	@stmt_checkout_id INT= NULL

AS

SET NOCOUNT ON

DECLARE @transaction_process_id VARCHAR(200) = dbo.FNAGetNewID()

IF @flag = 'full_apply'
BEGIN
	BEGIN TRY
		INSERT INTO stmt_apply_cash (stmt_invoice_detail_id, received_date, cash_received, settle_status, variance_amount, transaction_process_id)
		SELECT stid.stmt_invoice_detail_id, ISNULL(@applied_date,GETDATE()), stid.value, 's', 0, @transaction_process_id  
		FROM stmt_invoice sti 
		INNER JOIN stmt_invoice_detail stid ON sti.stmt_invoice_id =  stid.stmt_invoice_id
		LEFT JOIN stmt_apply_cash sta ON sta.stmt_invoice_detail_id = stid.stmt_invoice_detail_id
		WHERE sti.stmt_invoice_id = @stmt_invoice_id AND sta.stmt_apply_cash_id IS NULL

		UPDATE sta
		SET sta.cash_received = stid.value,
			sta.settle_status = 's',
			sta.variance_amount = 0,
			received_date = ISNULL(@applied_date,GETDATE())
		FROM stmt_invoice sti 
		INNER JOIN stmt_invoice_detail stid ON sti.stmt_invoice_id =  stid.stmt_invoice_id
		INNER JOIN stmt_apply_cash sta ON sta.stmt_invoice_detail_id = stid.stmt_invoice_detail_id AND sta.settle_status = 'o'
		WHERE sti.stmt_invoice_id = @stmt_invoice_id AND sta.stmt_apply_cash_id IS NULL

		EXEC spa_ErrorHandler 0,
				 'Apply Cash',
				 'spa_stmt_apply_cash',
				 'Success',
				 'Successfully Saved',
				 ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Apply Cash',
             'spa_stmt_apply_cash',
             'Error',
             'Failed to Save',
             ''
	END CATCH
END

ELSE IF @flag = 'partial_apply'
BEGIN
	BEGIN TRY
		DECLARE @addition_value FLOAT
		DECLARE @is_positive INT = 0

		IF OBJECT_ID('tempdb..#tmp_apply_cash') IS NOT NULL
			DROP TABLE #tmp_apply_cash
		
		CREATE TABLE #tmp_apply_cash (
			stmt_invoice_detail_id	INT,
			stmt_amount				FLOAT,
			row_num					INT,
			apply_amount			FLOAT,
			settle_status			CHAR(1)
		)

		IF (SELECT SUM(value) FROM stmt_invoice_detail WHERE stmt_invoice_id = @stmt_invoice_id) > 0
		BEGIN
			SET @is_positive = 1

			SELECT @addition_value = ISNULL(ABS(SUM(stid.value)),0) 
			FROM stmt_invoice_detail stid
			LEFT JOIN stmt_apply_cash sta ON sta.stmt_invoice_detail_id = stid.stmt_invoice_detail_id
			WHERE stid.stmt_invoice_id = @stmt_invoice_id AND stid.value < 0 AND sta.stmt_apply_cash_id IS NULL
			
			SET @applied_amount = @applied_amount + @addition_value

			INSERT INTO stmt_apply_cash (stmt_invoice_detail_id, received_date, cash_received, settle_status, variance_amount,transaction_process_id)
			SELECT stid.stmt_invoice_detail_id, ISNULL(@applied_date,GETDATE()), stid.value, 's', 0,@transaction_process_id  
			FROM stmt_invoice_detail stid
			LEFT JOIN stmt_apply_cash sta ON sta.stmt_invoice_detail_id = stid.stmt_invoice_detail_id
			WHERE stid.stmt_invoice_id = @stmt_invoice_id AND stid.value < 0 AND sta.stmt_apply_cash_id IS NULL

			INSERT INTO #tmp_apply_cash (stmt_invoice_detail_id, stmt_amount, row_num)
			SELECT stid.stmt_invoice_detail_id, CASE WHEN sta.settle_status = 'o' THEN sta.variance_amount ELSE stid.value END [amount], ROW_NUMBER() OVER (ORDER BY stid.value) [row_num]
			FROM stmt_invoice_detail stid
			LEFT JOIN stmt_apply_cash sta ON sta.stmt_invoice_detail_id = stid.stmt_invoice_detail_id
			WHERE stid.stmt_invoice_id = @stmt_invoice_id AND stid.value > 0 AND (sta.stmt_apply_cash_id IS NULL OR sta.settle_status = 'o')

		END
		ELSE
		BEGIN
			SET @applied_amount = @applied_amount * -1
			SET @is_positive = 0

			SELECT @addition_value = ISNULL(ABS(SUM(stid.value)),0) 
			FROM stmt_invoice_detail stid
			LEFT JOIN stmt_apply_cash sta ON sta.stmt_invoice_detail_id = stid.stmt_invoice_detail_id
			WHERE stid.stmt_invoice_id = @stmt_invoice_id AND stid.value > 0 AND sta.stmt_apply_cash_id IS NULL
			
			SET @applied_amount = @applied_amount - @addition_value

			INSERT INTO stmt_apply_cash (stmt_invoice_detail_id, received_date, cash_received, settle_status, variance_amount, transaction_process_id)
			SELECT stid.stmt_invoice_detail_id, ISNULL(@applied_date,GETDATE()), stid.value, 's', 0, @transaction_process_id  
			FROM stmt_invoice_detail stid
			LEFT JOIN stmt_apply_cash sta ON sta.stmt_invoice_detail_id = stid.stmt_invoice_detail_id
			WHERE stid.stmt_invoice_id = @stmt_invoice_id AND stid.value > 0 AND sta.stmt_apply_cash_id IS NULL

			INSERT INTO #tmp_apply_cash (stmt_invoice_detail_id, stmt_amount, row_num)
			SELECT stid.stmt_invoice_detail_id, CASE WHEN sta.settle_status = 'o' THEN sta.variance_amount ELSE stid.value END [amount], ROW_NUMBER() OVER (ORDER BY stid.value DESC) [row_num]
			FROM stmt_invoice_detail stid
			LEFT JOIN stmt_apply_cash sta ON sta.stmt_invoice_detail_id = stid.stmt_invoice_detail_id
			WHERE stid.stmt_invoice_id = @stmt_invoice_id AND stid.value < 0 AND (sta.stmt_apply_cash_id IS NULL OR sta.settle_status = 'o')
		END

		

		DECLARE @cur_stmt_invoice_detail_id INT, @cur_amount FLOAT

		DECLARE apply_cash_cursor CURSOR LOCAL FOR
		SELECT stmt_invoice_detail_id, stmt_amount
		FROM #tmp_apply_cash a			
		ORDER BY row_num
		
		OPEN apply_cash_cursor
		FETCH NEXT FROM apply_cash_cursor
		INTO @cur_stmt_invoice_detail_id, @cur_amount
		WHILE @@FETCH_STATUS = 0
		BEGIN			
				
			IF @applied_amount = 0
			BEGIN
				UPDATE #tmp_apply_cash
				SET apply_amount = 0,
					settle_status = NULL
				WHERE stmt_invoice_detail_id = @cur_stmt_invoice_detail_id
			END

			ELSE IF @applied_amount > @cur_amount AND @is_positive = 1
			BEGIN
				UPDATE #tmp_apply_cash
				SET apply_amount = @cur_amount,
					settle_status = 's'
				WHERE stmt_invoice_detail_id = @cur_stmt_invoice_detail_id

				SET @applied_amount = @applied_amount - @cur_amount
			END

			ELSE IF @applied_amount < @cur_amount  AND @is_positive = 1
			BEGIN
				UPDATE #tmp_apply_cash
				SET apply_amount = @applied_amount,
					settle_status = 'o'
				WHERE stmt_invoice_detail_id = @cur_stmt_invoice_detail_id

				SET @applied_amount = 0
			END

			ELSE IF @applied_amount < @cur_amount AND @is_positive = 0
			BEGIN
				UPDATE #tmp_apply_cash
				SET apply_amount = @cur_amount,
					settle_status = 's'
				WHERE stmt_invoice_detail_id = @cur_stmt_invoice_detail_id

				SET @applied_amount = @applied_amount - @cur_amount
			END

			ELSE IF @applied_amount > @cur_amount  AND @is_positive = 0
			BEGIN
				UPDATE #tmp_apply_cash
				SET apply_amount = @applied_amount,
					settle_status = 'o'
				WHERE stmt_invoice_detail_id = @cur_stmt_invoice_detail_id

				SET @applied_amount = 0
			END
			
		FETCH NEXT FROM apply_cash_cursor INTO @cur_stmt_invoice_detail_id, @cur_amount
		END
		CLOSE apply_cash_cursor
		DEALLOCATE apply_cash_cursor		

		DELETE stad
		FROM #tmp_apply_cash tmp
		INNER JOIN stmt_apply_cash stac ON tmp.stmt_invoice_detail_id = stac.stmt_invoice_detail_id 
		INNER JOIN stmt_apply_cash_detail stad ON stad.stmt_invoice_detail_id = tmp.stmt_invoice_detail_id
		WHERE stac.settle_status = 'o'

		UPDATE stac
			SET stac.settle_status = 's',
				stac.variance_amount = 0
		FROM #tmp_apply_cash tmp
		INNER JOIN stmt_apply_cash stac ON tmp.stmt_invoice_detail_id = stac.stmt_invoice_detail_id 
		WHERE stac.settle_status = 'o'

		INSERT INTO stmt_apply_cash (stmt_invoice_detail_id, received_date, cash_received, settle_status, variance_amount,transaction_process_id)
		SELECT tmp.stmt_invoice_detail_id, ISNULL(@applied_date,GETDATE()), tmp.apply_amount, tmp.settle_status, tmp.stmt_amount - tmp.apply_amount,@transaction_process_id
		FROM #tmp_apply_cash tmp WHERE tmp.apply_amount <> 0

		DECLARE @variance_invoice_detail_id INT
		SELECT @variance_invoice_detail_id = stmt_invoice_detail_id FROM #tmp_apply_cash WHERE settle_status = 'o'

		EXEC spa_stmt_apply_cash @flag = 'detail_level_apply', @stmt_invoice_detail_id = @variance_invoice_detail_id

		EXEC spa_ErrorHandler 0,
				 'Apply Cash',
				 'spa_stmt_apply_cash',
				 'Success',
				 'Successfully Saved',
				 ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Apply Cash',
             'spa_stmt_apply_cash',
             'Error',
             'Failed to Save',
             ''
	END CATCH
END

ELSE IF @flag = 'detail_level_apply'
BEGIN
	DELETE FROM stmt_apply_cash_detail WHERE stmt_invoice_detail_id = @stmt_invoice_detail_id

	DECLARE @is_invoice_positive INT = 0
	DECLARE @total_applied FLOAT = 0
	DECLARE @detail_additional_value FLOAT = 0

	IF OBJECT_ID('tempdb..#tmp_apply_cash_detail') IS NOT NULL
		DROP TABLE #tmp_apply_cash_detail
		
	CREATE TABLE #tmp_apply_cash_detail (
		stmt_invoice_detail_id	INT,
		stmt_checkout_id		INT,
		stmt_amount				FLOAT,
		row_num					INT,
		apply_amount			FLOAT,
		settle_status			CHAR(1)
	)
	
	SELECT @total_applied = ISNULL(SUM(ABS(cash_received)),0) 
	FROM stmt_apply_cash
	WHERE stmt_invoice_detail_id = @stmt_invoice_detail_id

	
	IF (SELECT SUM(value) FROM stmt_invoice_detail stid INNER JOIN stmt_invoice sti ON stid.stmt_invoice_id = sti.stmt_invoice_id WHERE stmt_invoice_detail_id = @stmt_invoice_detail_id) > 0
	BEGIN
		SET @is_invoice_positive = 1

		SELECT @detail_additional_value = ISNULl(ABS(SUM(sc.settlement_amount)),0)
		FROM stmt_invoice_detail stid
		INNER JOIN stmt_checkout sc ON stid.stmt_invoice_detail_id = sc.stmt_invoice_detail_id
		WHERE stid.stmt_invoice_detail_id = @stmt_invoice_detail_id AND sc.settlement_amount < 0
		
		SET @total_applied = @total_applied + @detail_additional_value

		INSERT INTO #tmp_apply_cash_detail (stmt_invoice_detail_id, stmt_checkout_id, stmt_amount, row_num)
		SELECT stid.stmt_invoice_detail_id, sc.stmt_checkout_id, sc.settlement_amount, ROW_NUMBER() OVER (ORDER BY sc.settlement_amount) [row_num]
		FROM stmt_invoice_detail stid
		INNER JOIN stmt_checkout sc ON stid.stmt_invoice_detail_id = sc.stmt_invoice_detail_id
		WHERE stid.stmt_invoice_detail_id = @stmt_invoice_detail_id AND sc.settlement_amount > 0

		INSERT INTO stmt_apply_cash_detail (stmt_invoice_detail_id, stmt_checkout_id, cash_received, settle_status, variance_amount)
		SELECT stid.stmt_invoice_detail_id, sc.stmt_checkout_id, sc.settlement_amount, 's', 0
		FROM stmt_invoice_detail stid
		INNER JOIN stmt_checkout sc ON stid.stmt_invoice_detail_id = sc.stmt_invoice_detail_id
		WHERE stid.stmt_invoice_detail_id = @stmt_invoice_detail_id AND sc.settlement_amount < 0
	
	END
	ELSE
	BEGIN	
		SET @total_applied = @total_applied * -1
		SET @is_invoice_positive = 0	

		SELECT @detail_additional_value = ISNULl(ABS(SUM(sc.settlement_amount)),0)
		FROM stmt_invoice_detail stid
		INNER JOIN stmt_checkout sc ON stid.stmt_invoice_detail_id = sc.stmt_invoice_detail_id
		WHERE stid.stmt_invoice_detail_id = @stmt_invoice_detail_id AND sc.settlement_amount > 0
		
		SET @total_applied = @total_applied - @detail_additional_value

		INSERT INTO #tmp_apply_cash_detail (stmt_invoice_detail_id, stmt_checkout_id, stmt_amount, row_num)
		SELECT stid.stmt_invoice_detail_id, sc.stmt_checkout_id, sc.settlement_amount, ROW_NUMBER() OVER (ORDER BY sc.settlement_amount) [row_num]
		FROM stmt_invoice_detail stid
		INNER JOIN stmt_checkout sc ON stid.stmt_invoice_detail_id = sc.stmt_invoice_detail_id
		WHERE stid.stmt_invoice_detail_id = @stmt_invoice_detail_id AND sc.settlement_amount < 0

		INSERT INTO stmt_apply_cash_detail (stmt_invoice_detail_id, stmt_checkout_id, cash_received, settle_status, variance_amount)
		SELECT stid.stmt_invoice_detail_id, sc.stmt_checkout_id, sc.settlement_amount, 's', 0
		FROM stmt_invoice_detail stid
		INNER JOIN stmt_checkout sc ON stid.stmt_invoice_detail_id = sc.stmt_invoice_detail_id
		WHERE stid.stmt_invoice_detail_id = @stmt_invoice_detail_id AND sc.settlement_amount > 0
	END

	DECLARE @cur1_stmt_invoice_detail_id INT, @cur1_stmt_checkout_id INT, @cur1_stmt_amount FLOAT

	DECLARE apply_cash_cursor_detail CURSOR LOCAL FOR
	SELECT stmt_invoice_detail_id, stmt_checkout_id, stmt_amount
	FROM #tmp_apply_cash_detail a			
	ORDER BY row_num
		
	OPEN apply_cash_cursor_detail
	FETCH NEXT FROM apply_cash_cursor_detail
	INTO @cur1_stmt_invoice_detail_id, @cur1_stmt_checkout_id, @cur1_stmt_amount
	WHILE @@FETCH_STATUS = 0
	BEGIN	
			
		IF @total_applied = 0
		BEGIN
			UPDATE #tmp_apply_cash_detail
			SET apply_amount = 0,
				settle_status = NULL
			WHERE stmt_checkout_id = @cur1_stmt_checkout_id
		END
		ELSE IF @total_applied > @cur1_stmt_amount AND @is_invoice_positive = 1
		BEGIN
			UPDATE #tmp_apply_cash_detail
			SET apply_amount = @cur1_stmt_amount,
				settle_status = 's'
			WHERE stmt_checkout_id = @cur1_stmt_checkout_id

			SET @total_applied = @total_applied - @cur1_stmt_amount
		END

		ELSE IF @total_applied < @cur1_stmt_amount  AND @is_invoice_positive = 1
		BEGIN
			UPDATE #tmp_apply_cash_detail
			SET apply_amount = @total_applied,
				settle_status = 'o'
			WHERE stmt_checkout_id = @cur1_stmt_checkout_id

			SET @total_applied = 0
		END

		ELSE IF @total_applied < @cur1_stmt_amount AND @is_invoice_positive = 0
		BEGIN
			UPDATE #tmp_apply_cash_detail
			SET apply_amount = @cur1_stmt_amount,
				settle_status = 's'
			WHERE stmt_checkout_id = @cur1_stmt_checkout_id

			SET @total_applied = @total_applied - @cur1_stmt_amount
		END

		ELSE IF @total_applied > @cur1_stmt_amount  AND @is_invoice_positive = 0
		BEGIN
			UPDATE #tmp_apply_cash_detail
			SET apply_amount = @total_applied,
				settle_status = 'o'
			WHERE stmt_checkout_id = @cur1_stmt_checkout_id

			SET @total_applied = 0
		END
		
			
	FETCH NEXT FROM apply_cash_cursor_detail INTO  @cur1_stmt_invoice_detail_id, @cur1_stmt_checkout_id, @cur1_stmt_amount
	END
	CLOSE apply_cash_cursor_detail
	DEALLOCATE apply_cash_cursor_detail	

	INSERT INTO stmt_apply_cash_detail (stmt_invoice_detail_id, stmt_checkout_id, cash_received, settle_status, variance_amount)
	SELECT tmp.stmt_invoice_detail_id, tmp.stmt_checkout_id, tmp.apply_amount, tmp.settle_status, tmp.stmt_amount - tmp.apply_amount
	FROM #tmp_apply_cash_detail tmp WHERE tmp.apply_amount <> 0
END

ELSE IF @flag = 'delete'
BEGIN
	BEGIN TRY
		DELETE sacd
		FROM stmt_apply_cash_detail sacd
		INNER JOIN stmt_invoice_detail stid ON sacd.stmt_invoice_detail_id = stid.stmt_invoice_detail_id
		WHERE stid.stmt_invoice_id = @stmt_invoice_id

		DELETE sacd
		FROM stmt_apply_cash sacd
		INNER JOIN stmt_invoice_detail stid ON sacd.stmt_invoice_detail_id = stid.stmt_invoice_detail_id
		WHERE stid.stmt_invoice_id = @stmt_invoice_id

		EXEC spa_ErrorHandler 0,
				 'Apply Cash',
				 'spa_stmt_apply_cash',
				 'Success',
				 'Successfully Saved',
				 ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Apply Cash',
             'spa_stmt_apply_cash',
             'Error',
             'Failed to Save',
             ''
	END CATCH
END


ELSE IF @flag = 'writeoff'
BEGIN
	BEGIN TRY
		UPDATE sac
		SET sac.settle_status = 's'
		FROM stmt_checkout sc
		INNER JOIN stmt_invoice_detail stid ON sc.stmt_invoice_detail_id = stid.stmt_invoice_detail_id
		INNER JOIN stmt_apply_cash sac ON sac.stmt_invoice_detail_id = stid.stmt_invoice_detail_id
		WHERE sc.stmt_checkout_id = @stmt_checkout_id AND sac.settle_status = 'o'

		EXEC spa_ErrorHandler 0,
				 'Apply Cash',
				 'spa_stmt_apply_cash',
				 'Success',
				 'Successfully Saved',
				 ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Apply Cash',
             'spa_stmt_apply_cash',
             'Error',
             'Failed to Save',
             ''
	END CATCH
END