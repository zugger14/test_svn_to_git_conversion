IF OBJECT_ID('[dbo].[spa_broker_fees]','p') IS NOT NULL 
DROP PROCEDURE [dbo].[spa_broker_fees]
GO

CREATE PROC [dbo].[spa_broker_fees]
@flag AS CHAR(1),
@broker_fees_id INT = NULL,
@effective_date VARCHAR(50) = NULL,
@deal_type INT = NULL,
@commodity INT = NULL,
@product INT = NULL,
@unit_price FLOAT = NULL,
@fixed_price FLOAT = NULL,
@currency INT = NULL,
@counterparty_id INT = NULL,
	@xml TEXT = NULL
AS 
/*****************************************************************
DECLARE @flag AS CHAR(1),
		@broker_fees_id INT = NULL,
		@effective_date VARCHAR(50) = NULL,
		@deal_type INT = NULL,
		@commodity INT = NULL,
		@product INT = NULL,
		@unit_price FLOAT = NULL,
		@fixed_price FLOAT = NULL,
		@currency INT = NULL,
		@counterparty_id INT = NULL,
		@xml varchar(max) = NULL

SELECT @flag='v',
@xml='<Root><GridUpdate broker_fees_id="29" counterparty_id="4276" effective_date="2016-09-01" deal_type="1175" commodity="-2" product="4492" unit_price="1" fixed_price="1" currency="1"></GridUpdate><GridUpdate broker_fees_id="44" counterparty_id="4276" effective_date="2016-09-01" deal_type="1175" commodity="-2" product="4492" unit_price="2" fixed_price="2" currency="1106"></GridUpdate></Root>'
--@xml='<Root><GridUpdate broker_fees_id="29" counterparty_id="4276" effective_date="2016-09-01" deal_type="1175" commodity="-2" product="4492" unit_price="1" fixed_price="1" currency="1"></GridUpdate><GridUpdate broker_fees_id="44" counterparty_id="4276" effective_date="2016-09-14" deal_type="1175" commodity="-2" product="4492" unit_price="2" fixed_price="2" currency="1106"></GridUpdate></Root>'
--***************************************************************/
SET NOCOUNT ON

DECLARE @sql_stmt VARCHAR(8000),
	@idoc INT

IF @flag = 's'
BEGIN 
	SELECT @sql_stmt = '
		SELECT broker_fees_id AS [Broker Fees ID],
			   scp.counterparty_name AS [Counterparty],
			   dbo.FNADateFormat(effective_date) AS [Effective Date],
			   sdt.source_deal_type_name AS [Deal Type],
			   sc.commodity_name AS [Commodity],
			   spcd.curve_id AS [Product],
			   unit_price AS [Unit Price],
			   fixed_price AS [Fixed Price],
	scy.currency_name AS [Currency]
	FROM broker_fees bf
		LEFT JOIN source_counterparty scp
			ON bf.counterparty_id = scp.source_counterparty_id
		LEFT JOIN source_deal_type sdt
			ON sdt.source_deal_type_id = bf.deal_type
		LEFT JOIN source_commodity sc
			ON sc.source_commodity_id = bf.commodity
		LEFT JOIN source_currency scy
			ON scy.source_currency_id = bf.currency
		LEFT JOIN dbo.source_price_curve_def spcd
			ON spcd.source_curve_def_id = bf.product
		WHERE 1 = 1
	'
	
	IF @effective_date IS NOT NULL 
		SELECT @sql_stmt = @sql_stmt + ' AND bf.effective_date <= ''' + CAST(@effective_date AS VARCHAR) + ''''
	
	IF @deal_type IS NOT NULL 
		SELECT @sql_stmt = @sql_stmt + ' AND bf.deal_type = ' + CAST(@deal_type AS VARCHAR)
	
	IF @commodity IS NOT NULL 
		SELECT @sql_stmt = @sql_stmt + ' AND bf.commodity = ' + CAST(@commodity AS VARCHAR)
	
	IF @product IS NOT NULL 
		SELECT @sql_stmt = @sql_stmt + ' AND bf.product = ' + CAST(@product AS VARCHAR) 
	
--	IF @counterparty_id IS NOT NULL 
		SELECT @sql_stmt = @sql_stmt + ' AND bf.counterparty_id = ' + CAST(@counterparty_id AS VARCHAR) 
		
	EXEC(@sql_stmt)
END 
ELSE IF @flag = 'g' --Added for DHTMLX Fees Grid in Setup Counterparty UI
BEGIN 
	SELECT bf.broker_fees_id AS [Broker Fees ID],
		   bf.effective_date AS [Effective Date],
		   bf.deal_type AS [Deal Type],
		   bf.commodity AS [Commodity],
		   bf.product AS [Product],
		   bf.unit_price AS [Unit Price], 
		   bf.fixed_price AS [Fixed Price],
		   bf.currency AS [Currency]
	FROM broker_fees bf
	LEFT JOIN source_counterparty scp
		ON bf.counterparty_id = scp.source_counterparty_id
	LEFT JOIN source_deal_type sdt
		ON sdt.source_deal_type_id = bf.deal_type
	LEFT JOIN source_commodity sc
		ON sc.source_commodity_id = bf.commodity
	LEFT JOIN source_currency scy
		ON scy.source_currency_id = bf.currency
	LEFT JOIN dbo.source_price_curve_def spcd
		ON spcd.source_curve_def_id = bf.product
	LEFT JOIN source_currency scu
		ON bf.currency = scu.source_currency_id
	WHERE bf.counterparty_id=@counterparty_id
END 
ELSE IF @flag = 'h' -- Returns int_ext_flag for source_counterparty
BEGIN
	SELECT int_ext_flag 
	FROM source_counterparty 
	WHERE source_counterparty_id=@counterparty_id
END
ELSE IF @flag = 'a'
BEGIN
	SELECT broker_fees_id,
		   dbo.FNADateFormat(effective_date) AS effective_date,
		   deal_type,
		   commodity,
		   product,
		   unit_price,
		   fixed_price,
		   currency,
	counterparty_id 
	FROM broker_fees
	WHERE broker_fees_id = @broker_fees_id
END 
ELSE IF @flag = 'i'
BEGIN 
	IF NOT EXISTS (
			SELECT 'x'
			FROM broker_fees
			WHERE effective_date = @effective_date
				AND deal_type = @deal_type
				AND commodity = @commodity
				AND product = @product
				AND counterparty_id = @counterparty_id
			)
	BEGIN
		INSERT INTO broker_fees (
			effective_date,
			deal_type,
			commodity,
			product,
			unit_price,
			fixed_price,
			currency,
			counterparty_id
			)
		VALUES (
			@effective_date,
			@deal_type,
			@commodity,
			@product,
			@unit_price,
			@fixed_price,
			@currency,
			@counterparty_id
			)
	END	
	ELSE	
	BEGIN
		EXEC spa_ErrorHandler - 1,
			'Insert Broker Fees.',
			'spa_broker_fees',
			'DB Error',
			'Broker fee for the given information already exists.',
			''
	
		RETURN
	END

	IF @@ERROR <> 0
	BEGIN 
		EXEC spa_ErrorHandler @@ERROR,
			'Insert Broker Fees.',
			'spa_broker_fees',
			'DB Error',
			'Insert Broker Fees failed.',
			''

		RETURN
	END
	ELSE
		EXEC spa_ErrorHandler 0,
			'Insert Broker Fees.',
			'spa_broker_fees',
			'Success',
			'Successfully Inserted Broker Fees.',
			''
END 
ELSE IF @flag = 'u'
BEGIN 
	BEGIN TRY
		UPDATE broker_fees
		SET effective_date = @effective_date,
		deal_type = @deal_type, 
		commodity = @commodity, 
		product = @product, 
		unit_price = @unit_price, 
		fixed_price = @fixed_price,
		currency = @currency,
		counterparty_id = @counterparty_id 
	WHERE broker_fees_id = @broker_fees_id 

		EXEC spa_ErrorHandler 0,
			'Update Broker Fees.',
			'spa_broker_fees',
			'Success',
			'Successfully updated Broker Fees.',
			''
	END TRY

	BEGIN CATCH
		IF @@ERROR = 2601
		BEGIN
			EXEC spa_ErrorHandler - 1,
				"Update Broker Fees.",
				"spa_broker_fees",
				"DB Error",
				"Broker fee for the given information already exists.",
				''
	
		RETURN
	END
		ELSE
			EXEC spa_ErrorHandler - 1,
				"Update Broker Fees.",
				"spa_broker_fees",
				"DB Error",
				"Update Broker Fees failed.",
				''
	END CATCH
END 
ELSE IF @flag = 'd'
BEGIN 
	DELETE
	FROM broker_fees
	WHERE broker_fees_id = @broker_fees_id
	
	IF @@ERROR <> 0
	BEGIN 
		EXEC spa_ErrorHandler @@ERROR,
			"Delete Broker Fees.",
			"spa_broker_fees",
			"DB Error",
			"Delete Broker Fees failed.",
			''

		RETURN
	END
	ELSE
		EXEC spa_ErrorHandler 0,
			'Delete Broker Fees.',
			'spa_broker_fees',
			'Success',
			'Successfully deleted Broker Fees.',
			''
END 
ELSE IF @flag = 'v'
BEGIN
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
	IF OBJECT_ID('tempdb..#temp_update_detail') IS NOT NULL
		DROP TABLE #temp_update_detail

	IF OBJECT_ID('tempdb..#temp_delete_detail') IS NOT NULL
		DROP TABLE #temp_delete_detail

	IF OBJECT_ID('tempdb..#temp_insert_detail') IS NOT NULL
		DROP TABLE #temp_insert_detail

	SELECT broker_fees_id,
		effective_date,
		deal_type,
		commodity, 
		counterparty_id,
		product,
		   broker_contract,
		   unit_price,
		   fixed_price,
		   currency
	INTO #temp_update_detail
	FROM OPENXML(@idoc, '/Root/GridUpdate', 1) WITH (
		broker_fees_id INT,
			effective_date DATETIME,
		deal_type INT,
		commodity INT,
		counterparty_id INT,
		product INT,
			broker_contract INT,
			unit_price INT,
			fixed_price INT,
			currency INT
	)
		
	SELECT grid_id
	INTO #temp_delete_detail
	FROM OPENXML(@idoc, '/Root/GridDelete', 1) WITH (grid_id INT)

	SELECT broker_fees_id,
		   CAST(effective_date AS DATETIME) AS effective_date,
		deal_type,
		commodity,
		counterparty_id, 
		product,
		   broker_contract,
		   unit_price,
		   fixed_price,
		   currency
	INTO #temp_insert_detail
	FROM OPENXML(@idoc, '/Root/GridInsert', 1) WITH (
		broker_fees_id INT,
			effective_date DATETIME,
		deal_type INT,
		commodity INT,
		counterparty_id INT,
		product INT,
			broker_contract INT,
			unit_price INT,
			fixed_price INT,
			currency INT
	)

	IF EXISTS (
			SELECT 1
			FROM broker_fees bf
			INNER JOIN #temp_update_detail tud
				ON bf.broker_fees_id <> tud.broker_fees_id
			WHERE bf.counterparty_id = tud.counterparty_id
				AND bf.commodity = tud.commodity
				AND bf.product = tud.product
				AND bf.deal_type = tud.deal_type
				AND bf.effective_date = tud.effective_date
			)
	BEGIN
		EXEC spa_ErrorHandler - 1,
			'Broker Fees detail saved.',
			'spa_broker_fees',
			'DBError',
			'Duplicate data in (<b>Commodity</b>, <b>Product</b>, <b>Deal Type</b> and <b>Effective Date</b>) in Broker Fees grid.',
			''

		RETURN
	END
	ELSE
	BEGIN
	UPDATE cea
	SET cea.effective_date = tud.effective_date,
		cea.deal_type = tud.deal_type,
		cea.commodity = tud.commodity,
		cea.counterparty_id = tud.counterparty_id,
		cea.product = tud.product,
			cea.broker_contract = tud.broker_contract,
			cea.unit_price = tud.unit_price,
			cea.fixed_price = tud.fixed_price,
			cea.currency = tud.currency
		FROM broker_fees cea
		INNER JOIN #temp_update_detail tud
			ON cea.broker_fees_id = tud.broker_fees_id
	END
			 
	IF EXISTS (
			SELECT 1
			FROM broker_fees bf
			INNER JOIN #temp_insert_detail tid
				ON bf.counterparty_id = tid.counterparty_id
			WHERE bf.commodity = tid.commodity
				AND bf.product = tid.product
				AND bf.deal_type = tid.deal_type
				AND bf.effective_date = tid.effective_date
			)
	BEGIN
		EXEC spa_ErrorHandler - 1,
			'Broker Fees detail saved.',
			'spa_broker_fees',
			'DBError',
			'Duplicate data in (<b>Commodity</b>, <b>Product</b>, <b>Deal Type</b> and <b>Effective Date</b>) in Broker Fees grid.',
			''
		
		RETURN
	END
	ELSE
	BEGIN
	INSERT INTO broker_fees(
	effective_date,
		deal_type,
		commodity,
		counterparty_id, 
		product,
			broker_contract,
			unit_price,
			fixed_price,
			currency
		)
		SELECT CAST(tid.effective_date AS DATETIME),
			tid.deal_type,
			tid.commodity,
			tid.counterparty_id,
			tid.product,
			   tid.broker_contract,
			   tid.unit_price,
			   tid.fixed_price,
			   tid.currency
	FROM #temp_insert_detail tid
	END

	DELETE cea 
	FROM broker_fees cea
	INNER JOIN #temp_delete_detail tdd
		ON cea.broker_fees_id = tdd.grid_id

	EXEC spa_ErrorHandler @@error,
							'Broker Fees detail saved.',
							'spa_broker_fees',
							'Success',
							'Changes have been saved successfully.',
							''	
END
ELSE IF @flag='t'
BEGIN
	SELECT broker_fees_id[Broker Fees ID],
		   CONVERT(VARCHAR(11), effective_date, 101) [Effective Date],
	broker_contract[Broker Contract],
	deal_type[Deal Type],
	commodity[Commodity],
	product[Product] 
	FROM broker_fees
	WHERE counterparty_id=@counterparty_id
END
GO