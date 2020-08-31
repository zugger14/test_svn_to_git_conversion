

IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_rec_generator_assignment]') AND [type] in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_rec_generator_assignment]
GO 

CREATE PROC [dbo].[spa_rec_generator_assignment]
	@flag CHAR(1),
	@generator_assignment_id INT=NULL,
	@generator_id INT = NULL,
	@form_xml XML = NULL
AS

/******************************************************
DECLARE @flag CHAR(1),@generator_assignment_id INT=NULL,@form_xml VARCHAR(MAX), @generator_id INT

SET @flag='i'
SET @generator_assignment_id=NULL
SET @generator_id='5'
SET @form_xml='<Root function_id="12101700"><FormXML term_start="2016-06-01" term_end="2016-06-21" assignment_type="5181" assignment_percent="1" max_volume_assign="2" frequency="706" uom="1186" trader="163" assigned_counterparty="4658" sold_price="2" contract="4127" use_market_price="n" exclude_from_inventory="y" allocation="242" offset="242" ></FormXML></Root>'
--****************************************************/
SET NOCOUNT ON
IF @flag='s'
	SELECT 
		generator_assignment_id,
		generator_id,
		ssbm.logical_name [allocation],
		ssbm2.logical_name [offset],
		dbo.fnadateformat(rg.term_start) term_start,
		dbo.fnadateformat(rg.term_end) term_end,
		sd.code assignment_type,
		auto_assignment_per assignment_percent,
		max_volume,
		su.uom_name,
		sc.counterparty_name,
		st.trader_name,
		sold_price,
		cg.contract_name,
		use_market_price,
		exclude_inventory,
		use_deal_price
	FROM rec_generator_assignment rg
	LEFT JOIN static_data_value sd
	  ON rg.auto_assignment_type = sd.value_id
	LEFT JOIN source_system_book_map ssbm
	  ON ssbm.book_deal_type_map_id = rg.source_book_map_id
	LEFT JOIN source_system_book_map ssbm2
	  ON ssbm2.book_deal_type_map_id = rg.source_book_map_offset
	LEFT JOIN source_Counterparty sc
	  ON sc.source_counterparty_id = rg.counterparty_id
	LEFT JOIN source_traders st
	  ON st.source_trader_id = rg.trader_id
	LEFT JOIN source_uom su
	  ON su.source_uom_id = rg.uom_id
	LEFT JOIN contract_group cg
	  ON cg.contract_id = rg.contract_id
	WHERE generator_id = @generator_id
ELSE IF @flag='a'
BEGIN
	SELECT generator_assignment_id,
	       generator_id,
	       auto_assignment_type,
	       auto_assignment_per,
	       term_start,
	       term_end,
	       counterparty_id,
	       trader_id,
	       sold_price,
	       exclude_inventory,
	       max_volume,
	       uom_id,
	       use_market_price,
	       frequency,
	       source_book_map_id,
	       source_book_map_offset,
	       contract_id, 
		   use_deal_price
	FROM rec_generator_assignment
	WHERE generator_assignment_id = @generator_assignment_id	
END	
	
ELSE IF @flag IN ('i', 'u')
BEGIN
	BEGIN TRY
	IF OBJECT_ID('tempdb..#rec_generator_assignment') IS NOT NULL
		DROP TABLE #rec_generator_assignment
	
	CREATE TABLE #rec_generator_assignment (
		generator_assignment_id   VARCHAR(500) COLLATE DATABASE_DEFAULT  ,
		allocation				  VARCHAR(500) COLLATE DATABASE_DEFAULT  ,
		offset					  VARCHAR(500) COLLATE DATABASE_DEFAULT  ,
		term_start				  VARCHAR(500) COLLATE DATABASE_DEFAULT  ,
		term_end				  VARCHAR(500) COLLATE DATABASE_DEFAULT  ,
		assignment_type			  VARCHAR(500) COLLATE DATABASE_DEFAULT  ,
		assignment_percent		  VARCHAR(500) COLLATE DATABASE_DEFAULT  ,
		max_volume_assign		  VARCHAR(500) COLLATE DATABASE_DEFAULT  ,
		frequency				  VARCHAR(500) COLLATE DATABASE_DEFAULT  ,
		uom						  VARCHAR(500) COLLATE DATABASE_DEFAULT  ,
		trader					  VARCHAR(500) COLLATE DATABASE_DEFAULT  ,
		assigned_counterparty	  VARCHAR(500) COLLATE DATABASE_DEFAULT  ,
		sold_price				  VARCHAR(500) COLLATE DATABASE_DEFAULT  ,
		contract				  VARCHAR(500) COLLATE DATABASE_DEFAULT  ,
		use_market_price		  VARCHAR(500) COLLATE DATABASE_DEFAULT  ,
		exclude_from_inventory	  VARCHAR(500) COLLATE DATABASE_DEFAULT ,
		use_deal_price 			  VARCHAR(500) COLLATE DATABASE_DEFAULT 
	)
	
	DECLARE @idoc INT
	EXEC sp_xml_preparedocument @idoc OUTPUT, @form_xml
	
	INSERT INTO #rec_generator_assignment
	SELECT *
	FROM OPENXML(@idoc, '/Root/FormXML', 1)
	WITH #rec_generator_assignment
	
	DECLARE @auto_assignment_type INT,
			@auto_assignment_per FLOAT,
			@term_start DATETIME,
			@term_end DATETIME,
			@counterparty_id INT,
			@trader_id INT,
			@sold_price FLOAT,
			@exclude_inventory CHAR,
			@max_volume FLOAT,
			@uom_id INT,
			@use_market_price CHAR,
			@frequency INT,
			@source_book_map_id INT,
			@source_book_map_offset INT,
			@contract_id INT,
			@use_deal_price CHAR

	SELECT 
		@source_book_map_id = allocation,
		@source_book_map_offset = offset,
		@term_start = term_start,
		@term_end = term_end,
		@auto_assignment_type = assignment_type,
		@auto_assignment_per = assignment_percent,
		@max_volume = max_volume_assign,
		@frequency = frequency,
		@uom_id = uom,
		@trader_id = trader,
		@counterparty_id = assigned_counterparty,
		@sold_price = sold_price,
		@contract_id = contract,
		@use_market_price = use_market_price,
		@exclude_inventory = exclude_from_inventory,
		@use_deal_price = use_deal_price
	FROM #rec_generator_assignment	

	IF @flag = 'i'
	BEGIN
		INSERT INTO rec_generator_assignment(generator_id, auto_assignment_type, auto_assignment_per, term_start, term_end, counterparty_id, trader_id, sold_price, 
											 exclude_inventory, max_volume, uom_id, use_market_price, frequency, source_book_map_id, source_book_map_offset, contract_id, use_deal_price)
		VALUES (@generator_id, @auto_assignment_type, @auto_assignment_per, @term_start, @term_end, @counterparty_id, @trader_id, @sold_price,
				@exclude_inventory, @max_volume, @uom_id, @use_market_price, @frequency, @source_book_map_id, @source_book_map_offset, @contract_id, @use_deal_price
				)
		SET @generator_assignment_id = SCOPE_IDENTITY();

		EXEC spa_ErrorHandler 0, 'Generator Assignment', 'spa_rec_generator_assignment', 'Success', 'Changes have been successfully saved.', @generator_assignment_id
	END
	ELSE IF @flag = 'u'
	BEGIN
		--IF EXISTS(
		--			SELECT 1 
		--			FROM rec_generator_assignment 
		--			WHERE generator_id = @generator_id 
		--				AND ((@term_start BETWEEN term_start AND term_end) 
		--				OR (@term_end BETWEEN term_start AND term_end)) 
		--				AND generator_assignment_id <> @generator_assignment_id
		--		)
		--BEGIN
		--	EXEC spa_ErrorHandler 0, 
		--						  'Generator Assignment', 
		--						  'spa_rec_generator_assignment',
		--						  'DBError',
		--						  'Term Start and Term End for the generator has already been defined. Please select different term dates.',
		--						  @generator_assignment_id
		--	RETURN   
		--END

		UPDATE rec_generator_assignment
		SET generator_id = @generator_id,
			auto_assignment_type = @auto_assignment_type,
			auto_assignment_per = @auto_assignment_per,
			term_start = @term_start,
			term_end = @term_end,
			counterparty_id = @counterparty_id,
			trader_id = @trader_id,
			sold_price = @sold_price,
			exclude_inventory = @exclude_inventory,
			max_volume = @max_volume,
			uom_id = @uom_id,
			use_market_price = @use_market_price,
			frequency = @frequency,
			source_book_map_id = @source_book_map_id,
			source_book_map_offset = @source_book_map_offset,
			contract_id = @contract_id,
			use_deal_price = @use_deal_price
		WHERE generator_assignment_id = @generator_assignment_id
		
		EXEC spa_ErrorHandler 0, 'Generator Assignment', 'spa_rec_generator_assignment', 'Success', 'Changes have been successfully saved.', @generator_assignment_id
	END	
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		DECLARE @desc varchar(MAX)
		SET @desc = dbo.FNAHandleDBError(12101721)  
		EXEC spa_ErrorHandler -1, 'spa_rec_generator_assignment', 'spa_rec_generator_assignment', 'Error', @desc, ''

	END CATCH
END
ELSE IF @flag='d'
BEGIN
	DELETE 
	FROM rec_generator_assignment
	WHERE generator_assignment_id = @generator_assignment_id

	EXEC spa_ErrorHandler 0, 'Generator Assignment', 'spa_rec_generator_assignment', 'Success', 'Changes have been successfully saved.', @generator_assignment_id
END	
