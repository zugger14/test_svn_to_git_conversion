IF OBJECT_ID(N'[dbo].[spa_payment_instruction]', N'P') IS NOT NULL
drop PROCEDURE [dbo].[spa_payment_instruction]
go

create PROCEDURE [dbo].[spa_payment_instruction]
	@flag CHAR(1)=NULL,
	@payment_ins_header VARCHAR(100) = NULL,
	@payment_ins_detail_id INT = NULL,
	@calc_id INT = NULL,
	@xml_data XML = NULL

AS
SET NOCOUNT ON

DECLARE @idoc INT

-- Show the data in the grid.
IF @flag = 'g'
BEGIN
	SELECT	pih.payment_ins_name				[payment_ins_name],
			sdv.code							[charge_type],
			dbo.FNADateFormat(pih.prod_date)	[date],
			dbo.FNADateFormat(civ.prod_date)	[prod_month],
			civ.Value							[value],
			pih.payment_ins_header_id			[payment_ins_header_id],
			pid.payment_ins_detail_Id			[payment_ins_detail_id],
			civ.invoice_line_item_id			[invoice_line_item_id],
			civ.calc_detail_id					[calc_detail_id]
	FROM payment_instruction_header pih
	INNER JOIN Calc_invoice_Volume_variance civv ON civv.counterparty_id = pih.counterparty_id
	LEFT JOIN payment_instruction_detail pid ON pih.payment_ins_header_id = pid.payment_ins_header_Id
	LEFT JOIN calc_invoice_volume civ ON civ.calc_detail_id = pid.calc_detail_id
	LEFT JOIN static_data_value sdv ON sdv.value_id = civ.invoice_line_item_id
	WHERE civv.calc_id = @calc_id
END

-- Insert/Update header
ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_data

		IF OBJECT_ID('tempdb..#tmp_payment_ins_header') IS NOT NULL
			DROP TABLE #tmp_payment_ins_header
		
		SELECT	payment_ins_header_id	[payment_ins_header_id],
				payment_ins_name		[payment_ins_name],
				prod_date				[prod_date],
				comments				[comments],
				calc_id					[calc_id]
		INTO #tmp_payment_ins_header
		FROM OPENXML(@idoc, '/Root/FormXML', 1)
		WITH (
			payment_ins_header_id	INT,
			payment_ins_name		VARCHAR(100),
			prod_date				VARCHAR(20),
			comments				VARCHAR(500),
			calc_id					INT
		)

		IF EXISTS (SELECT 1 FROM payment_instruction_header pih
		INNER JOIN Calc_invoice_Volume_variance civv ON pih.counterparty_id = civv.counterparty_id
		INNER JOIN #tmp_payment_ins_header tmp ON tmp.payment_ins_name = pih.payment_ins_name AND civv.calc_id = civv.calc_id)
		BEGIN
			EXEC spa_ErrorHandler -1,
				 'Payment Instruction',
				 'spa_payment_instruction',
				 'Error',
				 'Duplicate Payment Instruction Name.',
				 ''

			RETURN
		END	
		
		INSERT INTO payment_instruction_header (counterparty_id, payment_ins_name, prod_date, comments)
		SELECT civv.counterparty_id, tmp.payment_ins_name, tmp.prod_date, tmp.comments
		FROM #tmp_payment_ins_header tmp
		INNER JOIN Calc_invoice_Volume_variance civv ON tmp.calc_id = civv.calc_id
		WHERE tmp.payment_ins_header_id = 0
		
		UPDATE pih
		SET pih.payment_ins_name = tmp.payment_ins_name,
			pih.prod_date = tmp.prod_date,
			pih.comments = tmp.comments
		FROM payment_instruction_header pih
		INNER JOIN #tmp_payment_ins_header tmp ON tmp.payment_ins_header_id = pih.payment_ins_header_id
		WHERE tmp.payment_ins_header_id > 0


		EXEC spa_ErrorHandler 0,
             'Payment Instruction',
             'spa_payment_instruction',
             'Success',
             'Changes have been saved successfully.',
             ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Payment Instruction',
             'spa_payment_instruction',
             'Error',
             'Fail to save the changes.',
             ''
	END CATCH
END

-- Insert/Update detail
ELSE IF @flag = 'j'
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_data

		IF OBJECT_ID('tempdb..#tmp_payment_ins_detail') IS NOT NULL
			DROP TABLE #tmp_payment_ins_detail
		
		SELECT	payment_ins_detail_id	[payment_ins_detail_id],
				payment_ins_header_id	[payment_ins_header_id],
				calc_detail_id			[calc_detail_id]
		INTO #tmp_payment_ins_detail
		FROM OPENXML(@idoc, '/Root/FormXML', 1)
		WITH (
			payment_ins_detail_id	INT,
			payment_ins_header_id	INT,
			calc_detail_id			INT
		)

		INSERT INTO payment_instruction_detail (payment_ins_header_id, calc_detail_id, invoice_line_item_id)
		SELECT tmp.payment_ins_header_id, tmp.calc_detail_id, civ.invoice_line_item_id
		FROM #tmp_payment_ins_detail tmp
		INNER JOIN calc_invoice_volume civ ON tmp.calc_detail_id = civ.calc_detail_id
		WHERE tmp.payment_ins_detail_Id = 0
		
		UPDATE pid
		SET pid.payment_ins_header_id = tmp.payment_ins_header_id,
			pid.calc_detail_id = tmp.calc_detail_id,
			pid.invoice_line_item_id = civ.invoice_line_item_id
		FROM payment_instruction_detail pid
		INNER JOIN #tmp_payment_ins_detail tmp ON tmp.payment_ins_detail_Id = pid.payment_ins_detail_Id
		INNER JOIN calc_invoice_volume civ ON tmp.calc_detail_id = civ.calc_detail_id
		WHERE tmp.payment_ins_detail_Id > 0


		EXEC spa_ErrorHandler 0,
             'Payment Instruction',
             'spa_payment_instruction',
             'Success',
             'Changes have been saved successfully.',
             ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Payment Instruction',
             'spa_payment_instruction',
             'Error',
             'Fail to save the changes.',
             ''
	END CATCH
END

-- Delete header
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			DELETE pid FROM payment_instruction_detail pid
			INNER JOIN payment_instruction_header pih ON pid.payment_ins_header_id = pih.payment_ins_header_id
			INNER JOIN Calc_invoice_Volume_variance civv ON civv.counterparty_id = pih.counterparty_id
			WHERE pih.payment_ins_name = @payment_ins_header AND civv.calc_id = @calc_id

			DELETE pih FROM payment_instruction_header  pih
			INNER JOIN Calc_invoice_Volume_variance civv ON civv.counterparty_id = pih.counterparty_id
			WHERE payment_ins_name = @payment_ins_header AND civv.calc_id = @calc_id

		COMMIT
		EXEC spa_ErrorHandler 0,
             'Payment Instruction',
             'spa_payment_instruction',
             'Success',
             'Changes have been saved successfully.',
             ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Payment Instruction',
             'spa_payment_instruction',
             'Error',
             'Fail to save the changes.',
             ''
	END CATCH
END

-- Delete detail
ELSE IF @flag = 'e'
BEGIN
	BEGIN TRY
		DELETE FROM payment_instruction_detail WHERE payment_ins_detail_id = @payment_ins_detail_id

		EXEC spa_ErrorHandler 0,
             'Payment Instruction',
             'spa_payment_instruction',
             'Success',
             'Changes have been saved successfully.',
             ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Payment Instruction',
             'spa_payment_instruction',
             'Error',
             'Fail to save the changes.',
             ''
	END CATCH
END

-- For payment instruction dropdown
ELSE IF @flag = 'p'
BEGIN
	SELECT pih.payment_ins_header_id, pih.payment_ins_name 
	FROM payment_instruction_header pih
	INNER JOIN Calc_invoice_Volume_variance civv ON pih.counterparty_id = civv.counterparty_id
	WHERE civv.calc_id = @calc_id
END

-- For charge type dropdown
ELSE IF @flag = 'c'
BEGIN
	SELECT calc_detail_id, sdv.code FROM Calc_invoice_Volume civ
	INNER JOIN static_data_value sdv ON civ.invoice_line_item_id = sdv.value_id
	WHERE calc_id = @calc_id AND finalized = 'y'
END

-- Get detail about payment ins header
ELSE IF @flag = 'a'
BEGIN
	SELECT	pih.payment_ins_header_id,
			pih.payment_ins_name,
			pih.prod_date,
			pih.comments
	FROM payment_instruction_header pih
	INNER JOIN Calc_invoice_Volume_variance civv ON pih.counterparty_id = civv.counterparty_id
	WHERE civv.calc_id = @calc_id AND pih.payment_ins_name = @payment_ins_header
END