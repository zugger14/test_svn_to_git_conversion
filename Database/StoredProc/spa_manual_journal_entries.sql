
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_manual_journal_entries]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_manual_journal_entries]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
@flag 'i' - Insert/Update .
@flag 'd' - Delete entries.
@flag 't' - Detail info 

*/

CREATE PROCEDURE [dbo].[spa_manual_journal_entries] 
	@flag CHAR(1)
	, @manual_je_id VARCHAR(MAX) = NULL
	, @form_xml VARCHAR(MAX) = NULL
	, @grid_xml VARCHAR(MAX) = NULL

 AS 
SET NOCOUNT ON
/*
DECLARE @flag CHAR(1) = 'u'
	, @manual_je_id VARCHAR(MAX) = NULL
	, @form_xml VARCHAR(MAX) = '<FormXML  as_of_date="2016-01-06"  book_id="1277"  dr_cr_match="y" frequency="o" until_date="2016-01-11" comment="test csc" manual_je_id="7"></FormXML>
'
	, @grid_xml VARCHAR(MAX) = '<GridGroup>
	<PSRecordset  manual_je_detail_id="9" manual_je_id="7" gl_number_id="126" account_type_name="Account Receivable" gl_account_number="Z002254682354" debit_amount="23" credit_amount="45" volume="34" uom="1166" comment="test" >
	</PSRecordset> 
	<PSRecordset  manual_je_detail_id="" manual_je_id="7" gl_number_id="131" account_type_name="Cost of Carry" gl_account_number="0004422" debit_amount="43" credit_amount="45" volume="45" uom="1166" comment="test2" ></PSRecordset> 
	</GridGroup>'

--*/
IF @flag IN ('i','u')
BEGIN
	BEGIN TRY
	BEGIN TRAN	
	IF @form_xml IS NOT NULL
	BEGIN
		/*-- header information */
		IF OBJECT_ID(N'tempdb..#collects_je_header') IS NOT NULL DROP TABLE #collects_je_header
		DECLARE @idoc INT
		EXEC sp_xml_preparedocument @idoc OUTPUT, @form_xml		
		
		SELECT manual_je_id,
			as_of_date,
			book_id,
			dr_cr_match,
			frequency,
			NULLIF(until_date,'') until_date,
			comment
		INTO #collects_je_header
		FROM   OPENXML(@idoc, '/FormXML', 1)
				WITH (
					manual_je_id VARCHAR(8) '@manual_je_id',
					as_of_date DATE '@as_of_date',
					book_id VARCHAR(100) '@book_id',
					dr_cr_match CHAR '@dr_cr_match',
					frequency CHAR '@frequency',
					until_date DATE '@until_date',
					comment VARCHAR(1000) '@comment'
				)

		--SELECT * FROM #collects_je_header
		IF OBJECT_ID(N'tempdb..#new_je') IS NOT NULL DROP TABLE #new_je
		CREATE TABLE #new_je
			(manual_je_id INT NOT NULL
			, frequency CHAR(1) COLLATE DATABASE_DEFAULT
			, as_of_date DATE)
		
		INSERT INTO #new_je(manual_je_id, frequency, as_of_date)
		SELECT manual_je_id, frequency, as_of_date
		FROM
		(MERGE manual_je_header AS T
		 USING #collects_je_header AS S
		 ON T.manual_je_id = S.manual_je_id
		 WHEN NOT MATCHED BY TARGET THEN 
			INSERT(as_of_date, book_id, frequency, until_date, dr_cr_match, comment) 
			VALUES(S.as_of_date, S.book_id, S.frequency, S.until_date, S.dr_cr_match, S.comment)
		WHEN MATCHED THEN 
			UPDATE SET T.as_of_date = S.as_of_date,
				T.book_id = S.book_id,
				T.frequency = S.frequency,
				T.until_date = S.until_date,
				T.dr_cr_match = S.dr_cr_match,
				T.comment  = S.comment
		OUTPUT $action, Inserted.manual_je_id, Inserted.frequency, Inserted.as_of_date)
		AS Changes (Action, manual_je_id, frequency, as_of_date) WHERE Action IN ('INSERT','UPDATE');
		
		DECLARE @new_je_id INT, @frequency CHAR(1),@as_of_date DATE = NULL
		SELECT @new_je_id = manual_je_id 
			, @frequency = frequency
			, @as_of_date = as_of_date
		FROM #new_je
	
	END

	-- When inserting and updating, check if the Accounting book is already closed
	DECLARE @xcel_sub_id INT = -1	
	
	/* Generator logic is not used in FAS so these lines are commented. */
	--SELECT @sub_id=max(legal_entity_value_id) from 	rec_generator where generator_id=@generator_id

	--if exists(select * from close_measurement_books where 
	--	dbo.FNAContractMonthFormat(as_of_date)=dbo.FNAContractMonthFormat(@as_of_date) and (sub_id=@sub_id or sub_id=@xcel_sub_id))
	
	IF EXISTS(SELECT * FROM close_measurement_books WHERE 
		dbo.FNAContractMonthFormat(as_of_date) = dbo.FNAContractMonthFormat(@as_of_date) AND sub_id = @xcel_sub_id)
	BEGIN
			
		Exec spa_ErrorHandler 1, "Accounting Book already Closed for the Accounting Period ", 
				"spa_calc_invoice_volume_input", "DB Error", 
				"Accounting Book already Closed for the Accounting Period", ''

		RETURN
	END
	-----------
	
	IF @grid_xml IS NOT NULL
	BEGIN
		--Collect detail data
		DECLARE @idoc_detail INT
		EXEC sp_xml_preparedocument @idoc_detail OUTPUT, @grid_xml
		IF OBJECT_ID (N'tempdb..#collects_je_detail') IS NOT NULL  DROP TABLE 	#collects_je_detail

		SELECT NUllIF(manual_je_detail_id, '') manual_je_detail_id,
			NULLIF(manual_je_id, '') manual_je_id,
			NULLIF(gl_number_id, '') gl_number_id,
			NULLIF(account_type_name, '') account_type_name,
			NULLIF(gl_account_number, '') gl_account_number,
			NULLIF(debit_amount, '') debit_amount,
			NULLIF(credit_amount,'') credit_amount,
			NULLIF(volume, '') volume,
			NULLIF(uom, '') uom,
			NULLIF(comment, '') comment
		INTO #collects_je_detail
		FROM   OPENXML(@idoc_detail, '/GridGroup/PSRecordset', 1)
				WITH (
					manual_je_detail_id VARCHAR(8) '@manual_je_detail_id',
					manual_je_id VARCHAR(100) '@manual_je_id',
					gl_number_id VARCHAR(8) '@gl_number_id',
					account_type_name VARCHAR(500) '@account_type_name',
					gl_account_number VARCHAR(500) '@gl_account_number',
					debit_amount VARCHAR(100) '@debit_amount',
					credit_amount VARCHAR(100) '@credit_amount',
					volume  VARCHAR(100) '@volume',
					uom INT '@uom',
					comment VARCHAR(1000) '@comment'
				)

		
		IF EXISTS(SELECT 1
			FROM #collects_je_detail WHERE manual_je_detail_id IS NULL AND 
			manual_je_id IS NULL AND gl_number_id IS NULL AND account_type_name IS NULL AND 
			gl_account_number IS NULL AND debit_amount IS NULL AND credit_amount IS NULL AND 
			volume IS NULL AND uom IS NULL AND comment IS NULL)
			BEGIN
				DELETE FROM #collects_je_detail WHERE 
				manual_je_detail_id IS NULL AND manual_je_id IS NULL AND gl_number_id IS NULL AND account_type_name IS NULL 
				AND gl_account_number IS NULL AND debit_amount IS NULL AND credit_amount IS NULL AND volume IS NULL 
				AND uom IS NULL AND comment IS NULL
			END
				
		MERGE manual_je_detail AS T
		USING #collects_je_detail AS S
		ON (T.manual_je_detail_id = S.manual_je_detail_id) 
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(manual_je_id,
				volume,
				uom,
				debit_amount,
				credit_amount,
				gl_number_id,
				frequency,
				create_inventory,
				comment) 
			VALUES(@new_je_id,
				S.volume,
				S.uom,
				S.debit_amount,
				S.credit_amount,
				S.gl_number_id,
				@frequency,
				'n',
				S.comment)
		WHEN MATCHED THEN 
		UPDATE SET T.manual_je_id = S.manual_je_id,
				T.volume = S.volume,
				T.uom = S.uom,
				T.debit_amount = S.debit_amount,
				T.credit_amount = S.credit_amount,
				T.gl_number_id = S.gl_number_id,
				T.frequency = @frequency,
				T.comment = S.comment
		WHEN NOT MATCHED BY SOURCE AND T.manual_je_id= @new_je_id THEN 
		DELETE;
		--OUTPUT $action;
		
	END
	COMMIT
	EXEC spa_ErrorHandler 0, 'Manual Journal Entries',   
		'spa_manual_journal_entries', 'Success',   
		'Data saved successfully.', @new_je_id 
	
	END TRY
	BEGIN CATCH
		ROLLBACK		
	
		EXEC spa_ErrorHandler @@ERROR, 'Manual Journal Entries',   
		'spa_manual_journal_entries', 'DB Error',   
		'Failed to save data.', @new_je_id  
	
	END CATCH 	
		
END
ELSE IF @flag = 'd'
BEGIN
	DELETE mjh 
	FROM manual_je_header mjh
	INNER JOIN dbo.SplitCommaSeperatedValues(@manual_je_id) i ON i.item = mjh.manual_je_id
END
ELSE IF @flag='t'
BEGIN
	SELECT 
			a.manual_je_detail_id, 
			a.manual_je_id, 
			a.gl_number_id,
			gsm.gl_account_name,
			gsm.gl_account_number,
			a.debit_amount, 
			a.credit_amount,  
			a.volume, 
			a.uom,
			a.comment
	FROM [manual_je_detail] a
	LEFT JOIN gl_system_mapping gsm ON gsm.gl_number_id = a.gl_number_id
	WHERE manual_je_id = @manual_je_id
END
