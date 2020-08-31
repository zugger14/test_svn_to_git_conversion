IF OBJECT_ID(N'spa_source_deal_prepay', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_source_deal_prepay]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	It is the SP responsible for Insert/Update/Delete the deal complex pricing provisional data.

	Parameters
	@flag : Determines the actions of call for different process for the SP.
	@source_deal_header_id : Acts as input, it is deal header id.
	@header_prepay_xml : Form data in XML representation, which will be saved in corresponding table (source_deal_prepay) on the basis of deal header ID.
*/
CREATE PROC [dbo].[spa_source_deal_prepay]
	@flag CHAR(1),
	@source_deal_header_id INT = NULL,
	@header_prepay_xml XML = NULL
AS

/******************Test Code Start********************
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo

DECLARE @flag CHAR(1),
		@source_deal_header_id INT = NULL,
		@header_prepay_xml VARCHAR(MAX) = NULL

SELECT @flag='i', @source_deal_header_id=225706, 
@header_prepay_xml='
<GridPrePayXML>
	<GridRow  source_deal_prepay_id="" prepay="1476" value="100" percentage="" formula_id="" formula_name="" settlement_date="2019-12-01" settlement_calendar="" settlement_days="" payment_date="" payment_calendar="" payment_days="" granularity=""/>
	<GridRow  source_deal_prepay_id="" prepay="1747" value="60" percentage="" formula_id="" formula_name="" settlement_date="2019-12-07" settlement_calendar="" settlement_days="" payment_date="" payment_calendar="" payment_days="" granularity=""/>
	<GridRow  source_deal_prepay_id="302" prepay="1747" value="260" percentage="" formula_id="" formula_name="" settlement_date="2019-12-07" settlement_calendar="" settlement_days="" payment_date="" payment_calendar="" payment_days="" granularity=""/>
</GridPrePayXML>
	'
--*****************Test Code Start*******************/
SET NOCOUNT ON

IF @flag = 's'
BEGIN
	IF OBJECT_ID ('tempdb..#temp_resolve_formula') IS NOT NULL
		DROP TABLE #temp_resolve_formula

	CREATE TABLE #temp_resolve_formula (
		formula_id INT,
		formula_name VARCHAR(MAX)
	)

	DECLARE @formula_ids VARCHAR(MAX),
			@process_id VARCHAR(100),
			@process_table VARCHAR(300),
			@user_name VARCHAR(50)

	SET @process_id = dbo.FNAGetNewID()
	SET @user_name = dbo.FNADBUser()
	SET @process_table = dbo.FNAProcessTableName('formula_editor', @user_name, @process_id)

	SELECT @formula_ids = ISNULL(@formula_ids + ',', '') + CAST(formula_id AS VARCHAR(10))
	FROM source_deal_prepay 
	WHERE source_deal_header_id = @source_deal_header_id
		AND formula_id IS NOT NULL
	
	IF @formula_ids IS NOT NULL
	BEGIN
		EXEC spa_resolve_function_parameter @flag = 's', @process_id = @process_id, @formula_id = @formula_ids
		INSERT INTO #temp_resolve_formula
		EXEC ('SELECT * FROM ' + @process_table + '') 
	END
	
	SELECT source_deal_prepay_id,
		   prepay,
		   NULLIF(CAST(value AS FLOAT), 0) value,
		   NULLIF(CAST(percentage AS FLOAT), 0) percentage,
		   fe.formula_id,
		   fe.formula_name formula,
		   settlement_date,
		   NULLIF(settlement_calendar, 0) settlement_calendar,
		   NULLIF(settlement_days, 0) settlement_days,
		   payment_date,
		   NULLIF(payment_calendar, 0) payment_calendar,
		   NULLIF(payment_days, 0) payment_days,
		   NULLIF(granularity, 0) granularity
	FROM source_deal_prepay sdp
	LEFT JOIN #temp_resolve_formula fe
		ON fe.formula_id = sdp.formula_id
	WHERE source_deal_header_id = @source_deal_header_id
END
ELSE IF @flag = 'i'
BEGIN
	DECLARE @idoc INT, @collateral_status INT 

	EXEC sp_xml_preparedocument @idoc OUTPUT, @header_prepay_xml

	IF OBJECT_ID('tempdb..#source_deal_prepay') IS NOT NULL
		DROP TABLE #source_deal_prepay

	CREATE TABLE #source_deal_prepay (
		source_deal_prepay_id	INT,
		prepay					INT,
		value					NUMERIC(32,20),
		percentage				FLOAT,
		formula_id				INT,
		settlement_date			DATETIME,
		settlement_calendar		INT,
		settlement_days			INT,
		payment_date			DATETIME,
		payment_calendar		INT,
		payment_days			INT,
		granularity				INT,
		source_deal_header_id	INT
	)

	INSERT INTO #source_deal_prepay
	SELECT	source_deal_prepay_id,
			NULLIF(prepay, 0),
			NULLIF(value, 0),
			NULLIF(percentage, 0),
			NULLIF(formula_id, 0),
			NULLIF(settlement_date, 0),
			NULLIF(settlement_calendar, 0),
			NULLIF(settlement_days, 0),
			NULLIF(payment_date, 0),
			NULLIF(payment_calendar, 0),
			NULLIF(payment_days, 0),
			NULLIF(granularity, 0),
			@source_deal_header_id
	FROM OPENXML(@idoc, '/GridPrePayXML/GridRow', 1)
	WITH #source_deal_prepay

	/* Validation 1 - Insert and Update: Cannot have duplicate prepay inserted for same settlement date */
	IF EXISTS (SELECT 1 FROM #source_deal_prepay tmp
				INNER JOIN source_deal_prepay sdp ON tmp.source_deal_header_id = sdp.source_deal_header_id 
				AND tmp.settlement_date = sdp.settlement_date 
				AND tmp.source_deal_prepay_id <> sdp.source_deal_prepay_id)
	BEGIN
		EXEC spa_ErrorHandler -1, 
					'source_deal_prepay', 
					'spa_source_deal_prepay', 
					'Error', 
					'Failed to delete insert/update. Deal cannot have duplicate prepay for the same settlement date.', 
					''
		RETURN
	END

	/* Validation 2 - Cannot update the prepay if the invoice is created */
	IF EXISTS (SELECT 1 FROM #source_deal_prepay tmp
				INNER JOIN stmt_prepay sp ON tmp.source_deal_header_id = sp.source_deal_header_id 
					AND tmp.settlement_date = sp.settlement_date 
					AND sp.is_prepay = 'y' AND tmp.value <> sp.amount)
	BEGIN
		EXEC spa_ErrorHandler -1, 
					'source_deal_prepay', 
					'spa_source_deal_prepay', 
					'Error', 
					'Failed to delete update. Invoice(s) is mapped to the prepay.', 
					''
		RETURN
	END

	/* Validation 3 - Cannot delete the prepay if the invoice is created */
	IF EXISTS (	SELECT 1 FROM source_deal_prepay sdp
				LEFT JOIN #source_deal_prepay tmp ON tmp.source_deal_header_id = sdp.source_deal_header_id AND tmp.settlement_date = sdp.settlement_date
				INNER JOIN stmt_prepay sp ON sdp.source_deal_header_id = sp.source_deal_header_id 
					AND sdp.settlement_date = sp.settlement_date 
					AND sp.is_prepay = 'y'
				WHERE sdp.source_deal_header_id = @source_deal_header_id AND tmp.source_deal_header_id IS NULL)
	BEGIN
		EXEC spa_ErrorHandler -1, 
					'source_deal_prepay', 
					'spa_source_deal_prepay', 
					'Error', 
					'Failed to delete prepay. Invoice(s) is mapped to the prepay.', 
					''
		RETURN
	END

	SELECT @collateral_status = value_id
	FROM static_data_value 
	WHERE code  = 'Unapproved'
		AND type_id = 105200

	BEGIN TRY
		BEGIN TRANSACTION
			IF OBJECT_ID('tempdb..#inserted_prepay') IS NOT NULL
				DROP TABLE #inserted_prepay
	
			CREATE TABLE #inserted_prepay (
				[action] VARCHAR(10),
				[inserted_source_deal_prepay_id] INT,
				[deleted_source_deal_prepay_id] INT,
				[source_deal_header_id] INT,
				[value] NUMERIC(38,18),
				settlement_date DATETIME
			)
			
			/* INSERT/UPDATE/DELETE source_deal_prepay */
			MERGE source_deal_prepay AS t
			USING (
				SELECT prepay, value, percentage, formula_id, settlement_date, settlement_calendar, settlement_days, payment_date, payment_calendar, payment_days, granularity, source_deal_header_id, source_deal_prepay_id
				FROM #source_deal_prepay
				) AS s
			ON (s.source_deal_prepay_id = t.source_deal_prepay_id
					AND s.source_deal_header_id = t.source_deal_header_id) 
			WHEN NOT MATCHED BY TARGET 
			THEN 
				INSERT(prepay, value, percentage, formula_id, settlement_date, settlement_calendar, settlement_days, payment_date, payment_calendar, payment_days, granularity, source_deal_header_id)
				VALUES(s.prepay, s.value, s.percentage, s.formula_id, s.settlement_date, s.settlement_calendar, s.settlement_days, s.payment_date, s.payment_calendar, s.payment_days, s.granularity, s.source_deal_header_id)
			WHEN MATCHED 
			THEN 
				UPDATE 
				SET prepay = s.prepay, 
					value = s.value, 
					percentage = s.percentage, 
					formula_id = s.formula_id, 
					settlement_date = s.settlement_date, 
					settlement_calendar = s.settlement_calendar, 
					settlement_days = s.settlement_days, 
					payment_date = s.payment_date, 
					payment_calendar = s.payment_calendar, 
					payment_days = s.payment_days, 
					granularity = s.granularity
			WHEN NOT MATCHED BY SOURCE
				AND t.source_deal_header_id = @source_deal_header_id
			THEN DELETE 
			OUTPUT $action, INSERTED.source_deal_prepay_id, DELETED.source_deal_prepay_id,Inserted.source_deal_header_id,Inserted.value, Inserted.settlement_date
			INTO #inserted_prepay;

			/* INSERT/UPDATE/DELETE counterparty_credit_enhancements */
			INSERT INTO counterparty_credit_enhancements(
					counterparty_credit_info_id, 
					enhance_type, 
					eff_date,
					amount, 
					collateral_status, 
					deal_id, 
					currency_code, 
					source_deal_prepay_id,
					margin
			)
			SELECT	cci.counterparty_credit_info_id,
					10102,
					ISNULL(sdp.settlement_date,sdh.deal_date), 
					sdp.[value], 
					@collateral_status, 
					sdp.source_deal_header_id, 
					cci.curreny_code,
					tmp.inserted_source_deal_prepay_id,
					CASE WHEN sdh.header_buy_sell_flag = 's' THEN 'y' ELSE 'n' END
			FROM #source_deal_prepay sdp
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdp.source_deal_header_id
			INNER JOIN counterparty_credit_info cci ON cci.Counterparty_id = sdh.counterparty_id
			INNER JOIN #inserted_prepay tmp ON tmp.source_deal_header_id = sdp.source_deal_header_id AND tmp.settlement_date = sdp.settlement_date AND tmp.[action] = 'INSERT'
			WHERE sdp.source_deal_prepay_id = 0

			UPDATE counterparty_credit_enhancements
			SET	eff_date = ISNULL(sdp.settlement_date,sdh.deal_date),
				amount = sdp.[value],
				margin = CASE WHEN sdh.header_buy_sell_flag = 's' THEN 'y' ELSE 'n' END
			FROM #source_deal_prepay sdp
			INNER JOIN source_deal_prepay sd ON sd.source_deal_prepay_id = sdp.source_deal_prepay_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdp.source_deal_header_id
			INNER JOIN counterparty_credit_info cci ON cci.Counterparty_id = sdh.counterparty_id
			INNER JOIN counterparty_credit_enhancements cce ON cci.counterparty_credit_info_id = cce.counterparty_credit_info_id
			WHERE cce.source_deal_prepay_id = sdp.source_deal_prepay_id
			
			DELETE mcce 
			FROM master_view_counterparty_credit_enhancements mcce
			INNER JOIN counterparty_credit_enhancements cce ON mcce.counterparty_credit_enhancement_id = cce.counterparty_credit_enhancement_id
			INNER JOIN #inserted_prepay tmp ON cce.source_deal_prepay_id = tmp.deleted_source_deal_prepay_id AND tmp.[action] = 'DELETE'
			
			DELETE cce 
			FROM counterparty_credit_enhancements cce 
			INNER JOIN #inserted_prepay tmp ON cce.source_deal_prepay_id = tmp.deleted_source_deal_prepay_id AND tmp.[action] = 'DELETE'

			EXEC spa_ErrorHandler 0,
	         'source_deal_prepay',
	         'spa_source_deal_prepay',
	         'Success',
	         'Changes have been saved successfully.',
	         ''

		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
 			ROLLBACK
		EXEC spa_ErrorHandler -1, 
				'source_deal_prepay', 
				'spa_source_deal_prepay', 
				'Error', 
				'Failed to save data in Pre Pay.', 
				''
	END CATCH
END
ELSE IF @flag = 'j'
BEGIN
	SELECT DISTINCT 
		   udf_template_id prepay, 
		   Field_type, 
		   internal_field_type
	FROM user_defined_fields_template udft
	WHERE internal_field_type IN (18724, 18736)
END
GO