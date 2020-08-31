IF EXISTS (
       SELECT *
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_source_fees]')
              AND TYPE IN (N'P', N'PC')
   )
    DROP PROCEDURE [dbo].[spa_source_fees]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Stored procedure for Source Fees
	
	Parameters
	@flag: Operation flag
			'i' - insert Fees
			'u' - Update Fees
	@xml: Source fee XML
	@idoc: XML Document
	@source_fee_id:  Source Fee id
	@counterparty: Counterparty id
	@fees: Fees
	@fee_name: Name of fee
	@contract: Contract id
	@effective_date: Effective Date
	@tenor_from: Tenor from date
	@tenor_to: Tenor to date
	@type: Fee type
	@value: Fee value
	@minimum_trade: Minimum trade value
	@maximum_trade: Maximum trade value
	@uom: UOM id
	@product: Product
	@currency: Currency id
	@product_id: Product id
	@Commodity: Commodity id
	@deal_type: Deal type
	@location: Location id
	@index: 
	@tiered_value_id: Tired value id
	@from_volume: Volume from value
	@to_volume: Volume to value
	@to_value: To value
	@typ: Type
	@function_id: Application function id
	@desc: Description
*/
CREATE PROC [dbo].[spa_source_fees]
	 @flag CHAR(1) = 's',
	 @xml VARCHAR(MAX) = NULL,
	 @idoc INT = NULL,
	 @source_fee_id INT = NULL,
	 @counterparty INT = NULL,
	 @fees INT = NULL,
	 @fee_name VARCHAR(100) = NULL,
	 @contract INT = NULL,
	 @effective_date DATE = NULL,
	 @tenor_from VARCHAR(100) = NULL,
	 @tenor_to VARCHAR(100) = NULL,
	 @type INT = NULL,
	 @value VARCHAR(50) = NULL,
	 @minimum_trade INT = NULL,
	 @maximum_trade INT = NULL,
	 @uom INT = NULL, 
	 @product INT = NULL,
	 @currency INT = NULL,
	 @product_id INT = NULL,
	 @Commodity INT = NULL,
	 @deal_type INT = NULL,
	 @location INT = NULL,
	 @index INT = NULL,
	 @tiered_value_id INT = NULL,
	 @from_volume VARCHAR(100) = NULL,
	 @to_volume VARCHAR(100) = NULL,
	 @to_value VARCHAR(100) = NULL,
	 @typ INT = NULL,
	 @function_id VARCHAR(100) = NULL,
	 @desc VARCHAR(MAX) = NULL
 AS
 /*
 DECLARE @flag CHAR(1) = 's',
	 @xml VARCHAR(MAX) = NULL,
	 @idoc INT = NULL,
	 @source_fee_id INT = NULL,
	 @counterparty INT = NULL,
	 @fees INT = NULL,
	 @fee_name VARCHAR(100) = NULL,
	 @contract INT = NULL,
	 @effective_date DATE = NULL,
	 @tenor_from VARCHAR(100) = NULL,
	 @tenor_to VARCHAR(100) = NULL,
	 @type INT = NULL,
	 @value VARCHAR(50) = NULL,
	 @minimum_trade INT = NULL,
	 @maximum_trade INT = NULL,
	 @uom INT = NULL,
	 @product INT = NULL,
	 @currency INT = NULL,
	 @product_id INT = NULL,
	 @Commodity INT = NULL,
	 @deal_type INT = NULL,
	 @location INT = NULL,
	 @index INT = NULL,
	 @tiered_value_id INT = NULL,
	 @from_volume VARCHAR(100) = NULL,
	 @to_volume VARCHAR(100) = NULL,
	 @to_value VARCHAR(100) = NULL,
	 @typ INT = NULL,
	 @function_id VARCHAR(100) = NULL,
	 @desc VARCHAR(MAX) = NULL

 select @flag='u',
@source_fee_id= 14,
@xml= '<Root function_id="20001200" object_id="14"><FormXML  counterparty="7802" fees="307473" fee_name="Broker Fee 2" contract="8210" source_fee_id="14"></FormXML><GridGroup><GridSourceFeeVolume><GridRow  volume_id="46" source_fee_id="14" effective_date="2017-08-30" value="0.036" subsidiary="" deal_type="" buy_sell="" index_market="" commodity="" location="" product="50000131" jurisdiction="50002934" tier="50003087" type="" from_volume="" to_volume="" minimum_value="" maximum_value="" uom="" currency="" ></GridRow> </GridSourceFeeVolume></GridGroup></Root>'
 --*/
BEGIN
	SET NOCOUNT ON

	DECLARE @subsidiary INT,
			@buy_sell CHAR(1),
			
			@index_market INT,
			@jurisdiction INT = NULL,
			@tier INT = NULL
			

	IF @flag IN ('i', 'u')
	BEGIN
	    EXEC sp_xml_preparedocument @idoc OUTPUT,
	         @xml
	    
	    IF OBJECT_ID('tempdb..#source_fee_id') IS NOT NULL
	        DROP TABLE #source_fee_id
	    
	    SELECT function_id
	    INTO   #source_fee_id
	    FROM   OPENXML(@idoc, '/Root', 2)
	           WITH (function_id VARCHAR(100) '@function_id')
	    
	    SELECT @function_id = function_id
	    FROM   #source_fee_id
	    
	    IF OBJECT_ID('tempdb..#source_fees') IS NOT NULL
	        DROP TABLE #source_fees
	    
	    SELECT counterparty,
	           fees,
	           fee_name,
	           [contract],
	           source_fee_id
	    INTO   #source_fees
	    FROM   OPENXML(@idoc, '/Root/FormXML', 2)
	           WITH (
	               counterparty VARCHAR(100) '@counterparty',
	               fees VARCHAR(100) '@fees',
	               fee_name VARCHAR(100) '@fee_name',
	               [contract] VARCHAR(100) '@contract',
	               source_fee_id VARCHAR(100) '@source_fee_id'
	           )
	    
	    IF OBJECT_ID('tempdb..#source_fee_volume') IS NOT NULL
	        DROP TABLE #source_fee_volume
	    
	    SELECT volume_id,
			source_fee_id,
			IIF(effective_date = '', NULL, effective_date) effective_date,
			tenor_from,
			tenor_to,
			IIF([type] = '', NULL, [type]) [type],
			IIF(from_volume = '', NULL, from_volume) from_volume,
			IIF(to_volume = '', NULL, to_volume) to_volume,
			IIF([value] = '', NULL, [value]) [value],
			IIF(minimum_value = '', NULL, minimum_value) minimum_value,
			IIF(maximum_value = '', NULL, maximum_value) maximum_value,
			IIF(uom = '', NULL, uom) uom,
			IIF(currency = '', NULL, currency) currency,
			NULLIF(subsidiary,'') subsidiary,
			NULLIF(deal_type,'') deal_type,
			NULLIF(buy_sell,'') buy_sell,
			NULLIF(index_market,'') index_market,
			NULLIF(commodity,'') commodity,
			
			NULLIF(location,'') location,
			NULLIF(product,'') product,
			NULLIF(jurisdiction,'') jurisdiction,
			NULLIF(tier,'') tier,
			IIF(fee_for_agressor = '', NULL, fee_for_agressor) fee_for_agressor,
			IIF(fee_for_initiator = '', NULL, fee_for_initiator) fee_for_initiator,
			IIF(minimum_amount_agressor = '', NULL, minimum_amount_agressor) minimum_amount_agressor,
			IIF(rec_pay = '', NULL, rec_pay) rec_pay
	    INTO   #source_fee_volume
	    FROM   OPENXML(@idoc, '/Root/GridGroup/GridSourceFeeVolume/GridRow', 2)
	           WITH (
	               volume_id VARCHAR(100) '@volume_id',
	               source_fee_id VARCHAR(100) '@source_fee_id',
	               effective_date DATE '@effective_date',
	               tenor_from VARCHAR(100) '@tenor_from',
	               tenor_to VARCHAR(100) '@tenor_to',
	               [type] VARCHAR(100) '@type',
	               from_volume VARCHAR(100) '@from_volume',
	               to_volume VARCHAR(100) '@to_volume',
	               [value] VARCHAR(100) '@value',
	               minimum_value VARCHAR(100) '@minimum_value',
	               maximum_value VARCHAR(100) '@maximum_value',
	               uom VARCHAR(100) '@uom',
	               currency VARCHAR(100) '@currency',
				   subsidiary VARCHAR(10) '@subsidiary',
				   deal_type VARCHAR(10) '@deal_type',
				   buy_sell CHAR(1) '@buy_sell',
				   index_market VARCHAR(10) '@index_market',
				   commodity VARCHAR(10) '@commodity',
				  
				   location VARCHAR(10) '@location',
				   product varchar(100) '@product',
				   jurisdiction varchar(100) '@jurisdiction',
				   tier varchar(100) '@tier',
				   fee_for_agressor VARCHAR(100) '@fee_for_agressor',
				   fee_for_initiator VARCHAR(100) '@fee_for_initiator',
				   minimum_amount_agressor VARCHAR(100) '@minimum_amount_agressor',
				   rec_pay NCHAR(1) '@rec_pay'
	           )
	    
	    IF OBJECT_ID('tempdb..#source_fee_product') IS NOT NULL
	        DROP TABLE #source_fee_product
	    
	    SELECT product_id,
	           source_fee_id,
	           NULLIF(Commodity, '')  AS Commodity,
	           NULLIF(deal_type, '')  AS deal_type,
	           NULLIF(location, '')   AS location,
	           NULLIF([index], '')    AS [index]
	    INTO   #source_fee_product
	    FROM   OPENXML(@idoc, '/Root/GridGroup/GridSourceFeeProduct/GridRow', 2)
	           WITH (
	               product_id VARCHAR(100) '@product_id',
	               source_fee_id VARCHAR(100) '@source_fee_id',
	               Commodity VARCHAR(100) '@Commodity',
	               deal_type VARCHAR(100) '@deal_type',
	               location VARCHAR(100) '@location',
	               [index] VARCHAR(100) '@index'
	           )
	    
	    IF @flag = 'i'
	    BEGIN
	        BEGIN TRY
	        	BEGIN TRAN 
	        	INSERT INTO source_fee
	        	  (
	        	    counterparty,
	        	    fees,
	        	    fee_name,
	        	    [contract]
	        	  )
	        	SELECT NULLIF(counterparty, ''),
	        	       NULLIF(fees, ''),
	        	       fee_name,
	        	       NULLIF([contract], '')
	        	FROM   #source_fees
	        	
	        	SET @source_fee_id = SCOPE_IDENTITY()
	        	SELECT @Commodity = Commodity,
	        	       @deal_type     = deal_type,
	        	       @location      = location,
	        	       @index         = [index]
	        	FROM   #source_fee_product
	        	
	        	
	        	IF EXISTS(
	        	       SELECT 1
	        	       FROM   #source_fee_product
	        	   )
	        	BEGIN
	        	    INSERT INTO source_fee_product
	        	      (
	        	        source_fee_id,
	        	        Commodity,
	        	        deal_type,
	        	        location,
	        	        [index]
	        	      )
	        	    SELECT @source_fee_id,
	        	           Commodity,
	        	           deal_type,
	        	           location,
	        	           [index]
	        	    FROM   #source_fee_product
	        	END
	        	
	        	IF EXISTS(
	        	       SELECT 1
	        	       FROM   #source_fee_volume
	        	   )
	        	BEGIN
	        	    INSERT INTO source_fee_volume
	        	      (
						source_fee_id,
	        	        effective_date,
						tenor_from,
						tenor_to,
						[type],
						from_volume,
						to_volume,
						[value],
						minimum_value,
						maximum_value,
						uom,
						currency,
						subsidiary,
						deal_type,
						buy_sell,
						index_market,
						commodity,
						
						location,
						product,
						jurisdiction,
						tier,
						fee_for_agressor,
						fee_for_initiator,
						minimum_amount_agressor,
						rec_pay
	        	      )
	        	    SELECT @source_fee_id,
	        			effective_date,
						tenor_from,
						tenor_to,
						[type],
						ISNULL(from_volume, ''),
						to_volume,
						[value],
						minimum_value,
						maximum_value,
						uom,
						currency,
						subsidiary,
						deal_type,
						buy_sell,
						index_market,
						commodity,
						
						location,
						product,
						jurisdiction,
						tier,
						fee_for_agressor,
						fee_for_initiator,
						minimum_amount_agressor,
						rec_pay
	        	    FROM   #source_fee_volume
	        	END 
	        	
	        	COMMIT
	        	EXEC spa_ErrorHandler @@ERROR,
	        	     'Setup Fees',
	        	     'spa_source_fees',
	        	     'Success',
	        	     'Changes have been saved successfully.',
	        	     @source_fee_id
	        END TRY 
	        BEGIN CATCH
	        	IF @@TRANCOUNT > 0
	        	    ROLLBACK			
	        	
	        	SET @desc = dbo.FNAHandleDBError(@function_id)
	        	EXEC spa_ErrorHandler -1,
	        	     'Setup Fees',
	        	     'spa_source_fees',
	        	     'Error',
	        	     @desc,
	        	     ''
	        END CATCH
	    END
	    ELSE 
	    IF @flag = 'u'
	    BEGIN
	        BEGIN TRY
	        	BEGIN TRAN 
	        	
	        	SELECT @counterparty = NULLIF(counterparty, ''),
	        	       @fees         = NULLIF(fees, ''),
	        	       @fee_name     = fee_name,
	        	       @contract     = NULLIF([contract], '') 
	        	FROM   #source_fees
	        	
	        	UPDATE source_fee
	        	SET    counterparty = @counterparty,
	        	       fees = @fees,
	        	       fee_name = @fee_name,
	        	       [contract] = @contract 
	        	WHERE  source_fee_id = @source_fee_id
	        	
	        	IF OBJECT_ID('tempdb..#delete_source_fee_product') IS NOT NULL
	        	    DROP TABLE #delete_source_fee_product

	        	SELECT product_id
	        	INTO   #delete_source_fee_product
	        	FROM   OPENXML(
	        	           @idoc,
	        	           '/Root/GridGroup/GridDeleteSourceFeeProduct/GridRow',
	        	           2
	        	       )
	        	       WITH (product_id INT '@product_id')
	        	
	        	IF EXISTS(
	        	       SELECT 1
	        	       FROM   #delete_source_fee_product
	        	   )
	        	BEGIN
	        	    DELETE 
	        	    FROM   source_fee_product
	        	    WHERE  product_id IN (SELECT product_id
	        	                          FROM   #delete_source_fee_product)
	        	END
	        	
	        	--to insert/update into source_fee_product table
	        	IF EXISTS(
	        	       SELECT 1
	        	       FROM   #source_fee_product
	        	       WHERE  product_id = ''
	        	   )
	        	BEGIN
	        	    IF OBJECT_ID('tempdb..#insert_source_fee_product') IS NOT NULL
	        	        DROP TABLE #insert_source_fee_product
	        	     
	        	    SELECT product_id,
	        	           source_fee_id,
	        	           Commodity,
	        	           deal_type,
	        	           location,
	        	           [index]
	        	    INTO   #insert_source_fee_product
	        	    FROM   #source_fee_product
	        	    WHERE  product_id = ''
	        	    
	        	    SELECT @Commodity = Commodity,
	        	           @deal_type     = deal_type,
	        	           @location      = location,
	        	           @index         = [index]
	        	    FROM   #insert_source_fee_product
	        	    
	        	    INSERT INTO source_fee_product
	        	      (
	        	        source_fee_id,
	        	        Commodity,
	        	        deal_type,
	        	        location,
	        	        [index]
	        	      )
	        	    SELECT @source_fee_id,
	        	           Commodity,
	        	           deal_type,
	        	           location,
	        	           [index]
	        	    FROM   #insert_source_fee_product
	        	END
	        	
	        	IF EXISTS(
	        	       SELECT 1
	        	       FROM   #source_fee_product
	        	       WHERE  product_id <> ''
	        	   )
	        	BEGIN
	        	    IF OBJECT_ID('tempdb..#update_source_fee_product') IS NOT NULL
	        	        DROP TABLE #update_source_fee_product
	        	    
	        	    SELECT product_id,
	        	           source_fee_id,
	        	           Commodity,
	        	           deal_type,
	        	           location,
	        	           [index]
	        	    INTO   #update_source_fee_product
	        	    FROM   #source_fee_product
	        	    WHERE  product_id <> ''
	        	    
	        	    UPDATE source_fee_product
	        	    SET    source_fee_product.Commodity = usfp.Commodity,
	        	           source_fee_product.deal_type = usfp.deal_type,
	        	           source_fee_product.location = usfp.location,
	        	           source_fee_product.[index] = usfp.[index]
	        	    FROM   source_fee_product sfp
	        	           INNER JOIN #update_source_fee_product usfp
	        	                ON  sfp.product_id = usfp.product_id
	        	END


				IF OBJECT_ID('tempdb..#delete_source_fee_volume') IS NOT NULL
	        	    DROP TABLE #delete_source_fee_volume

				SELECT volume_id
	        	INTO   #delete_source_fee_volume
	        	FROM   OPENXML(
	        	           @idoc,
	        	           '/Root/GridGroup/GridDeleteSourceFeeVolume/GridRow',
	        	           2
	        	       )
	        	       WITH (volume_id INT '@volume_id')

	        	IF EXISTS(
	        	       SELECT 1
	        	       FROM   #delete_source_fee_volume
	        	   )
	        	BEGIN
	        	    DELETE 
	        	    FROM   source_fee_volume
	        	    WHERE  volume_id IN (SELECT volume_id
	        	                          FROM   #delete_source_fee_volume)
	        	END

				--to insert/update into source_fee_volume table
	        	IF EXISTS(
	        	       SELECT 1
	        	       FROM   #source_fee_volume
	        	       WHERE  volume_id = ''
	        	   )
	        	BEGIN
	        	    IF OBJECT_ID('tempdb..#insert_source_fee_volume') IS NOT NULL
	        	        DROP TABLE #insert_source_fee_volume
	        	    
	        	    SELECT volume_id,
						source_fee_id,
						effective_date,
						tenor_from,
						tenor_to,
						[type],
						from_volume,
						to_volume,
						[value],
						minimum_value,
						maximum_value,
						uom,
						currency,
						subsidiary,
						deal_type,
						buy_sell,
						index_market,
						commodity,
						
						location,
						product,
						jurisdiction,
						tier,
						fee_for_agressor,
						fee_for_initiator,
						minimum_amount_agressor,
						rec_pay

	        	    INTO   #insert_source_fee_volume
	        	    FROM   #source_fee_volume
	        	    WHERE  volume_id = ''
	        	    
	        	    SELECT @effective_date = effective_date,
						@tenor_from = tenor_from,
						@tenor_to = tenor_to,
						@type = type,
						@from_volume = from_volume,
						@to_volume = to_volume,
						@value = value,
						@minimum_trade = minimum_value,
						@maximum_trade = maximum_value,
						@uom = uom,
						@currency = currency,
						@subsidiary = subsidiary,
						@deal_type = deal_type,
						@buy_sell = buy_sell,
						@index_market = index_market,
						@commodity = commodity,
						
						@location = location,
						@product = product,
						@jurisdiction = jurisdiction,
						@tier = tier
	        	    FROM   #insert_source_fee_volume
	        	    
	        	    INSERT INTO source_fee_volume
	        	      (
	        	        source_fee_id,
						effective_date,
						tenor_from,
						tenor_to,
						[type],
						from_volume,
						to_volume,
						[value],
						minimum_value,
						maximum_value,
						uom,
						currency,
						subsidiary,
						deal_type,
						buy_sell,
						index_market,
						commodity,
						
						location,
						product,
						jurisdiction,
						tier,
						fee_for_agressor,
						fee_for_initiator,
						minimum_amount_agressor,
						rec_pay
	        	      )
	        	    SELECT @source_fee_id,
						effective_date,
						tenor_from,
						tenor_to,
						[type],
						from_volume,
						to_volume,
						[value],
						minimum_value,
						maximum_value,
						uom,
						currency,
						subsidiary,
						deal_type,
						buy_sell,
						index_market,
						commodity,
						
						location,
						product,
						jurisdiction,
						tier,
						fee_for_agressor,
						fee_for_initiator,
						minimum_amount_agressor,
						rec_pay
	        	    FROM   #insert_source_fee_volume
	        	END
	        	
	        	IF EXISTS(
	        	       SELECT 1
	        	       FROM   #source_fee_volume
	        	       WHERE  volume_id <> ''
	        	   )
	        	BEGIN
	        	    IF OBJECT_ID('tempdb..#update_source_fee_volume') IS NOT NULL
	        	        DROP TABLE #update_source_fee_volume
	        	    
	        	    SELECT volume_id,
						source_fee_id,
						effective_date,
						tenor_from,
						tenor_to,
						IIF([type] = '', NULL, [type]) [type],
						IIF(from_volume = '', NULL, from_volume) from_volume,
						IIF(to_volume = '', NULL, to_volume) to_volume,
						IIF([value] = '', NULL, [value]) [value],
						IIF(minimum_value = '', NULL, minimum_value) minimum_value,
						IIF(maximum_value = '', NULL, maximum_value) maximum_value,
						IIF(uom = '', NULL, uom) uom,
						NULLIF(currency,'') currency,
						NULLIF(subsidiary,'') subsidiary,
						NULLIF(deal_type,'') deal_type,
						NULLIF(buy_sell,'') buy_sell,
						NULLIF(index_market,'') index_market,
						NULLIF(commodity,'') commodity,
						
						NULLIF(location,'') location,
						NULLIF(product,'') product,
						NULLIF(jurisdiction,'') jurisdiction,
						NULLIF(tier,'') tier,
						IIF(fee_for_agressor = '', NULL, fee_for_agressor) fee_for_agressor,
						IIF(fee_for_initiator = '', NULL, fee_for_initiator) fee_for_initiator,
						IIF(minimum_amount_agressor = '', NULL, minimum_amount_agressor) minimum_amount_agressor,
						IIF(rec_pay = '', NULL, rec_pay) rec_pay

	        	    INTO   #update_source_fee_volume
	        	    FROM   #source_fee_volume
	        	    WHERE  volume_id <> ''
					--select * from #update_source_fee_volume

	        	    UPDATE source_fee_volume
	        	    SET		source_fee_volume.effective_date = usfp.effective_date,
							source_fee_volume.tenor_from = usfp.tenor_from,
							source_fee_volume.tenor_to = usfp.tenor_to,
							source_fee_volume.type = usfp.type,
							source_fee_volume.from_volume = IIF(usfp.from_volume ='',NULL,usfp.from_volume),
							source_fee_volume.to_volume = IIF(usfp.to_volume ='',NULL,usfp.to_volume),
							source_fee_volume.value = IIF(usfp.value ='',NULL,usfp.value),
							source_fee_volume.minimum_value = IIF(usfp.minimum_value ='',NULL,usfp.minimum_value),
							source_fee_volume.maximum_value = IIF(usfp.maximum_value ='',NULL,usfp.maximum_value),
							source_fee_volume.uom = IIF(usfp.uom ='',NULL,usfp.uom),
							source_fee_volume.currency = IIF(usfp.currency ='',NULL,usfp.currency),
							source_fee_volume.subsidiary = usfp.subsidiary,
							source_fee_volume.deal_type = usfp.deal_type,
							source_fee_volume.buy_sell = usfp.buy_sell,
							source_fee_volume.index_market = usfp.index_market,
							source_fee_volume.commodity = usfp.commodity,
							
							source_fee_volume.location = usfp.location,
							source_fee_volume.product = usfp.product,
							source_fee_volume.jurisdiction = usfp.jurisdiction,
							source_fee_volume.tier = usfp.tier,
							source_fee_volume.fee_for_agressor = IIF(usfp.fee_for_agressor ='',NULL,usfp.fee_for_agressor),
							source_fee_volume.fee_for_initiator = IIF(usfp.fee_for_initiator ='',NULL,usfp.fee_for_initiator),
							source_fee_volume.minimum_amount_agressor = IIF(usfp.minimum_amount_agressor ='',NULL,usfp.minimum_amount_agressor),
							source_fee_volume.rec_pay = IIF(usfp.rec_pay ='',NULL,usfp.rec_pay)
							 
	        	    FROM   source_fee_volume sfp
	        	           INNER JOIN #update_source_fee_volume usfp
	        	                ON  sfp.volume_id = usfp.volume_id
	        	END

	        	COMMIT
	        	EXEC spa_ErrorHandler @@ERROR,
	        	     'Setup Fees',
	        	     'spa_source_fees',
	        	     'Success',
	        	     'Changes have been saved successfully.',
	        	     @source_fee_id
	        END TRY
	        BEGIN CATCH
	        	IF @@TRANCOUNT > 0
	        	    ROLLBACK
	        	
	        	SET @desc = dbo.FNAHandleDBError(@function_id)
	        	EXEC spa_ErrorHandler -1,
	        	     'Setup Fees',
	        	     'spa_source_fees',
	        	     'Error',
	        	     @desc,
	        	     ''
	        END CATCH
	    END
	END
END

GO
