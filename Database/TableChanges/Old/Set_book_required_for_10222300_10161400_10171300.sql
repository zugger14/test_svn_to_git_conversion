--Set book required for Run Deal Settlement
IF EXISTS(SELECT * FROM application_functions WHERE function_id = 10222300 AND book_required = 0)
	BEGIN
		UPDATE application_functions SET book_required = 1 WHERE function_id = 10222300
		PRINT 'Set book required for Run Deal Settlement'
	END
ELSE
	BEGIN
		PRINT 'Book required for Run Deal Settlement'
	END

--Set book required for Gas Storage Position Report
IF EXISTS(SELECT * FROM application_functions WHERE function_id = 10161400 AND book_required = 0)
	BEGIN
		UPDATE application_functions SET book_required = 1 WHERE function_id = 10161400
		PRINT 'Set book required for Gas Storage Position Report'
	END
ELSE
	BEGIN
		PRINT 'Book required for Gas Storage Position Report'
	END

--Set book required for Deal Confirm Report
IF EXISTS(SELECT * FROM application_functions WHERE function_id = 10171300 AND book_required = 0)
	BEGIN
		UPDATE application_functions SET book_required = 1 WHERE function_id = 10171300
		PRINT 'Set book required for Deal Confirm Report'
	END
ELSE
	BEGIN
		PRINT 'Book required for Deal Confirm Report'
	END