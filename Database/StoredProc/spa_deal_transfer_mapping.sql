IF OBJECT_ID('[dbo].[spa_deal_transfer_mapping]','p') IS NOT NULL 
DROP PROCEDURE [dbo].[spa_deal_transfer_mapping]
GO

CREATE PROCEDURE [dbo].[spa_deal_transfer_mapping]
	@flag char(1),
	@mapping_id INT = NULL,
	@deal_type_id INT = NULL,
	@deal_sub_type_id INT = NULL,
	@source_book_mapping_id_from INT = NULL,
	@source_book_mapping_id_to INT = NULL,
	@trader_id_from INT = NULL,
	@trader_id_to INT = NULL,
	@counterparty_id_from INT = NULL,
	@counterparty_id_to INT = NULL,
	@unapprove CHAR(1) = 'y',
	@offset CHAR(1) = 'y',
	@transfer CHAR(1) = 'y',
    @transfer_pricing_option CHAR(1) = 'd',
    @formula_id INT = NULL,
	@template_id INT = NULL,
	@source_book_mapping_id_offset INT = NULL
AS

DECLARE @source_book_mapping_from VARCHAR(100)
DECLARE @source_book_mapping_to VARCHAR(100)

IF @flag = 'a'
BEGIN

--SELECT
--	deal_transfer_mapping_id [Mapping ID],
--	source_deal_type_id [Deal Type],
--	source_deal_sub_type_id [Deal Sub Type],
--	source_book_mapping_id_from [Source Book Map From],
--	transfer_sub_book [Source Book Map To],
--	trader_id_from [Trader From],
--	transfer_trader_id [Trader To],
--	counterparty_id_from [Counterparty From],
--	counterparty_id_to [Counterparty To]
--FROM deal_transfer_mapping WHERE deal_transfer_mapping_id = @mapping_id


SELECT 
	dtm.deal_transfer_mapping_id [Mapping ID],
	source_deal_type_id [Deal Type],
	source_deal_sub_type_id [Deal Sub Type],
	source_book_mapping_id_from [Source Book Map From],
	transfer_sub_book [Source Book Map To],
	trader_id_from [Trader From],
	transfer_trader_id [Trader To],
	counterparty_id_from [Counterparty From],
	counterparty_id_to [Counterparty To],
	
	sb11.source_book_name + ', ' +
	sb12.source_book_name + ', ' +
	sb13.source_book_name + ', ' +
	sb14.source_book_name [Source Book Mapping From],
	
	sb21.source_book_name + ', ' +
	sb22.source_book_name + ', ' +
	sb23.source_book_name + ', ' +
	sb24.source_book_name [Source Book Mapping To],
	
	unapprove [Unapprove],
	offset [Offset],
	transfer [Transfer],
	transfer_pricing_option [Transfer Pricing Option],
	dtm.formula_id,
	dbo.FNAFormulaFormat(fe.formula,'r'),
	fe.formula_type,
	dtm.template_id,
	
	sub_book,
	
	sbo1.source_book_name + ', ' +
	sbo2.source_book_name + ', ' +
	sbo3.source_book_name + ', ' +
	sbo4.source_book_name [Source Book Mapping Offset]
	
FROM deal_transfer_mapping dtm
	INNER JOIN deal_transfer_mapping_detail dtmd 
		ON dtmd.deal_transfer_mapping_id = dtm.deal_transfer_mapping_id 
	LEFT JOIN source_system_book_map ssbm1 ON ssbm1.book_deal_type_map_id = dtm.source_book_mapping_id_from
		LEFT JOIN source_book sb11 ON sb11.source_book_id = ssbm1.source_system_book_id1
		LEFT JOIN source_book sb12 ON sb12.source_book_id = ssbm1.source_system_book_id2
		LEFT JOIN source_book sb13 ON sb13.source_book_id = ssbm1.source_system_book_id3
		LEFT JOIN source_book sb14 ON sb14.source_book_id = ssbm1.source_system_book_id4
		
	INNER JOIN source_system_book_map ssbm2 ON ssbm2.book_deal_type_map_id = dtmd.transfer_sub_book
		INNER JOIN source_book sb21 ON sb21.source_book_id = ssbm2.source_system_book_id1
		INNER JOIN source_book sb22 ON sb22.source_book_id = ssbm2.source_system_book_id2
		INNER JOIN source_book sb23 ON sb23.source_book_id = ssbm2.source_system_book_id3
		INNER JOIN source_book sb24 ON sb24.source_book_id = ssbm2.source_system_book_id4	

	LEFT JOIN source_system_book_map ssbm_offset ON ssbm_offset.book_deal_type_map_id = dtmd.sub_book
		LEFT JOIN  source_book sbo1 ON sbo1.source_book_id = ssbm_offset.source_system_book_id1
		LEFT JOIN source_book sbo2 ON sbo2.source_book_id = ssbm_offset.source_system_book_id2
		LEFT JOIN source_book sbo3 ON sbo3.source_book_id = ssbm_offset.source_system_book_id3
		LEFT JOIN source_book sbo4 ON sbo4.source_book_id = ssbm_offset.source_system_book_id4			
	LEFT JOIN formula_editor fe ON fe.formula_id = dtm.formula_id
WHERE dtm.deal_transfer_mapping_id = @mapping_id
	
END


IF @flag = 's'
BEGIN

--SELECT 
--	dtm.deal_transfer_mapping_id [Mapping ID],
--	sdt1.source_deal_type_name [Deal Type],
--	sdt2.source_deal_type_name [Deal Sub Type],
--	source_book_mapping_id_from [Source Book Map From],
--	transfer_sub_book [Source Book Map To],
--	st1.trader_name [Trader From],
--	st2.trader_name [Trader To],
--	sc1.counterparty_name [Counterparty From],
--	sc2.counterparty_name [Counterparty To]
--FROM deal_transfer_mapping dtm
--	INNER JOIN source_deal_type sdt1 ON dtm.source_deal_type_id = sdt1.source_deal_type_id
--	INNER JOIN source_deal_type sdt2 ON dtm.source_deal_sub_type_id = sdt2.source_deal_type_id
--	INNER JOIN source_traders st1 ON dtm.trader_id_from = st1.source_trader_id
--	INNER JOIN source_traders st2 ON dtm.transfer_trader_id = st2.source_trader_id
--	INNER JOIN source_counterparty sc1 ON dtm.counterparty_id_from = sc1.source_counterparty_id
--	INNER JOIN source_counterparty sc2 ON dtm.counterparty_id_to = sc2.source_counterparty_id
--WHERE dtm.source_deal_type_id = @deal_type_id AND dtm.source_deal_sub_type_id = @deal_sub_type_id


SELECT 
	dtm.deal_transfer_mapping_id [Mapping ID],
	sdt1.source_deal_type_name [Deal Type],
	sdt2.source_deal_type_name [Deal Sub Type],
--	source_book_mapping_id_from [Source Book Mapping From],
	sb11.source_book_name + ', ' +
	sb12.source_book_name + ', ' +
	sb13.source_book_name + ', ' +
	sb14.source_book_name [Source Book Mapping From],
--	transfer_sub_book [Source Book Mapping To],

	sbo1.source_book_name + ', ' +
	sbo2.source_book_name + ', ' +
	sbo3.source_book_name + ', ' +
	sbo4.source_book_name [Source Book Mapping Offset],
	
	sb21.source_book_name + ', ' +
	sb22.source_book_name + ', ' +
	sb23.source_book_name + ', ' +
	sb24.source_book_name [Source Book Mapping To],
	
	st1.trader_name [Trader From],
	st2.trader_name [Trader To],
	sc1.counterparty_name [Counterparty From],
	sc2.counterparty_name [Counterparty To],
	CASE unapprove WHEN 'y' THEN 'Yes' ELSE 'No' END [Unapprove],
	CASE offset WHEN 'y' THEN 'Yes' ELSE 'No' END [Offset],
	CASE transfer WHEN 'y' THEN 'Yes' ELSE 'No' END [Transfer],
	CASE dtm.transfer_pricing_option 
		WHEN 'd' THEN 'Original Price'
		WHEN 'm' THEN 'Market Price'
		WHEN 'f' THEN 'Formula Price'
		WHEN 'x' THEN 'Fixed Price'
	END 
	[Transfer Pricing Option]
FROM deal_transfer_mapping dtm
	INNER JOIN deal_transfer_mapping_detail dtmd 
		ON dtmd.deal_transfer_mapping_id = dtm.deal_transfer_mapping_id 
	INNER JOIN source_deal_type sdt1 ON dtm.source_deal_type_id = sdt1.source_deal_type_id
	INNER JOIN source_deal_type sdt2 ON dtm.source_deal_sub_type_id = sdt2.source_deal_type_id
	LEFT JOIN source_traders st1 ON dtm.trader_id_from = st1.source_trader_id
	INNER JOIN source_traders st2 ON dtmd.trader_id = st2.source_trader_id
	LEFT JOIN source_counterparty sc1 ON dtm.counterparty_id_from = sc1.source_counterparty_id
	INNER JOIN source_counterparty sc2 ON dtm.counterparty_id_to = sc2.source_counterparty_id
	
	LEFT JOIN source_system_book_map ssbm1 ON ssbm1.book_deal_type_map_id = dtm.source_book_mapping_id_from
		LEFT JOIN source_book sb11 ON sb11.source_book_id = ssbm1.source_system_book_id1
		LEFT JOIN source_book sb12 ON sb12.source_book_id = ssbm1.source_system_book_id2
		LEFT JOIN source_book sb13 ON sb13.source_book_id = ssbm1.source_system_book_id3
		LEFT JOIN source_book sb14 ON sb14.source_book_id = ssbm1.source_system_book_id4
		
	INNER JOIN source_system_book_map ssbm2 ON ssbm2.book_deal_type_map_id = dtmd.transfer_sub_book
		INNER JOIN source_book sb21 ON sb21.source_book_id = ssbm2.source_system_book_id1
		INNER JOIN source_book sb22 ON sb22.source_book_id = ssbm2.source_system_book_id2
		INNER JOIN source_book sb23 ON sb23.source_book_id = ssbm2.source_system_book_id3
		INNER JOIN source_book sb24 ON sb24.source_book_id = ssbm2.source_system_book_id4	
		
	LEFT JOIN source_system_book_map ssbm_offset ON ssbm_offset.book_deal_type_map_id = dtmd.sub_book
		LEFT JOIN source_book sbo1 ON sbo1.source_book_id = ssbm_offset.source_system_book_id1
		LEFT JOIN source_book sbo2 ON sbo2.source_book_id = ssbm_offset.source_system_book_id2
		LEFT JOIN source_book sbo3 ON sbo3.source_book_id = ssbm_offset.source_system_book_id3
		LEFT JOIN source_book sbo4 ON sbo4.source_book_id = ssbm_offset.source_system_book_id4			
		
WHERE 
--	dtm.source_deal_type_id = @deal_type_id AND dtm.source_deal_sub_type_id = @deal_sub_type_id AND 
	dtm.template_id = @template_id
	
END


IF @flag = 'i'
BEGIN

BEGIN TRY 
	INSERT INTO deal_transfer_mapping(
		source_deal_type_id,
		source_deal_sub_type_id,
		source_book_mapping_id_from,
		trader_id_from,
		counterparty_id_from,
		counterparty_id_to,
		unapprove,
		offset,
		transfer,
		transfer_pricing_option,
		formula_id,
		template_id
	)
	VALUES (
		@deal_type_id,
		@deal_sub_type_id,
		@source_book_mapping_id_from,
		@trader_id_from,
		@counterparty_id_from,
		@counterparty_id_to,
		@unapprove,
		@offset,
		@transfer,
		@transfer_pricing_option,
		@formula_id,
		@template_id
	)
END TRY 
BEGIN CATCH 
	IF @@ERROR = 2601 
	BEGIN
		EXEC spa_ErrorHandler -1, 'Deal Transfer Mapping Table', 
			'spa_deal_transfer_mapping', 'DB Error', 
			'Mapping already exists for the selected Template and Source Book Mapping From', ''
		RETURN 
	END

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, 'Deal Transfer Mapping Table', 
				'spa_deal_transfer_mapping', 'DB Error', 
				'Failed inserting Data.', ''
	ELSE
		EXEC spa_ErrorHandler 0, 'Deal Transfer Mapping Table', 
				'spa_deal_transfer_mapping', 'Success', 
				'Data insert Success', ''
END CATCH 

END 

IF @flag = 'u'
BEGIN

UPDATE deal_transfer_mapping SET 
	source_deal_type_id = @deal_type_id,
	source_deal_sub_type_id = @deal_sub_type_id,
	source_book_mapping_id_from = @source_book_mapping_id_from,
	trader_id_from = @trader_id_from,
	counterparty_id_from = @counterparty_id_from,
	counterparty_id_to = @counterparty_id_to,
	unapprove = @unapprove,
	offset = @offset,
	transfer = @transfer,
	transfer_pricing_option = @transfer_pricing_option,
	formula_id = @formula_id,
	template_id = @template_id
WHERE deal_transfer_mapping_id = @mapping_id

IF @@ERROR <> 0
	EXEC spa_ErrorHandler @@ERROR, 'Deal Transfer Mapping Table', 
			'spa_deal_transfer_mapping', 'DB Error', 
			'Failed updating Data.', ''
ELSE
	EXEC spa_ErrorHandler 0, 'Deal Transfer Mapping Table', 
			'spa_deal_transfer_mapping', 'Success', 
			'Data update Success', ''		
			
END

IF @flag = 'd'
BEGIN
	
DELETE FROM deal_transfer_mapping WHERE deal_transfer_mapping_id = @mapping_id

IF @@ERROR <> 0
	EXEC spa_ErrorHandler @@ERROR, 'Deal Transfer Mapping Table', 
			'spa_deal_transfer_mapping', 'DB Error', 
			'Failed deleting Data.', ''
ELSE
	EXEC spa_ErrorHandler 0, 'Deal Transfer Mapping Table', 
			'spa_deal_transfer_mapping', 'Success', 
			'Data delete Success', ''
	
END

IF @flag = 'g'
BEGIN
	SELECT deal_transfer_mapping_detail_id [Transfer Mapping Detail ID] 
	    , deal_transfer_mapping_id [Transfer Mapping ID]
		, sub_book [Offset Sub Book]
		, trader_id [Offset Trader]
		, counterparty_id [Offset Counterparty]
		, contract_id [Offset Contract]
		, template_id [Offset Template]
		, transfer_sub_book [Transfer Sub Book]
		, transfer_trader_id [Transfer Trader]
		, transfer_counterparty_id [Transfer Counterparty]
		, transfer_contract_id [Transfer Contract]
		, transfer_template_id [Transfer Template]
		, location_id [Location]
		, transfer_volume [Transfer Volume]
		, volume_per [Volume%]
		, pricing_options [Pricing Options]
		, fixed_price [Fixed Price]
		, transfer_date [Transfer Date]
		, index_adder [Index Adder]
		, fixed_adder [Fixed Adder] 
	FROM deal_transfer_mapping_detail
	WHERE deal_transfer_mapping_id = @mapping_id
END