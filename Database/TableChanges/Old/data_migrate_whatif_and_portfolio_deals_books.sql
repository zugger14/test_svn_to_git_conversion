/**
* old data migration script
**/

/** maintain portfolio group data **/
--deals
IF NOT EXISTS (SELECT 1 FROM portfolio_group_deal)
INSERT INTO portfolio_group_deal
  (
    portfolio_group_id,
    deal_id
  )
SELECT wcd.portfolio_group_id,
       wcd.deal_id
FROM   whatif_criteria_deal wcd
WHERE  wcd.portfolio_group_id IS NOT NULL

--books
IF NOT EXISTS (SELECT 1 FROM portfolio_group_book)
INSERT INTO portfolio_group_book
  (
    portfolio_group_id,
    book_name,
    book_description,
    book_parameter
  )
SELECT wcb.portfolio_group_id,
       wcb.book_name,
       wcb.book_description,
       wcb.book_parameter
FROM   whatif_criteria_book wcb
WHERE  wcb.portfolio_group_id IS NOT NULL

/** mapping table for source and usage ids, table portfolio_mapping_source **/
IF NOT EXISTS (SELECT 1 FROM portfolio_mapping_source)
BEGIN
	INSERT INTO portfolio_mapping_source
	  (
		mapping_source_value_id,
		mapping_source_usage_id,
		portfolio_group_id
	  )
	SELECT 23201,
		   mwc.criteria_id,
		   mwc.portfolio_group_id
	FROM   maintain_whatif_criteria mwc

	/** Limit datas into mapping table **/
	INSERT INTO portfolio_mapping_source
	  (
		mapping_source_value_id,
		mapping_source_usage_id,
		portfolio_group_id
	  )
	SELECT 23200,
		   lh.limit_id,
		   NULL
	FROM   limit_header lh

	/** whatif datas **/

	--whatif deals
	INSERT INTO portfolio_mapping_deal
	  (
		portfolio_mapping_source_id,
		deal_id
	  )
	SELECT pms.portfolio_mapping_source_id,
		   wcd.deal_id
	FROM   whatif_criteria_deal wcd
		   INNER JOIN portfolio_mapping_source pms
				ON  pms.mapping_source_usage_id = wcd.criteria_id
				AND pms.mapping_source_value_id = 23201

	--whatif books
	INSERT INTO portfolio_mapping_book
	  (
		portfolio_mapping_source_id,
		book_name,
		book_description,
		book_parameter
	  )
	SELECT pms.portfolio_mapping_source_id,
		   wcb.book_name,
		   wcb.book_description,
		   wcb.book_parameter
	FROM   whatif_criteria_book wcb
		   INNER JOIN portfolio_mapping_source pms
				ON  pms.mapping_source_usage_id = wcb.criteria_id
				AND pms.mapping_source_value_id = 23201

	--whatif others
	INSERT INTO portfolio_mapping_other
	  (
		portfolio_mapping_source_id,
		counterparty,
		buy,
		sell,
		buy_index,
		buy_price,
		buy_currency,
		buy_volume,
		buy_uom,
		buy_term_start,
		buy_term_end,
		sell_index,
		sell_price,
		sell_currency,
		sell_volume,
		sell_uom,
		sell_term_start,
		sell_term_end
	  )
	SELECT pms.portfolio_mapping_source_id,
		   wco.counterparty,
		   wco.buy,
		   wco.sell,
		   wco.buy_index,
		   wco.buy_price,
		   wco.buy_currency,
		   wco.buy_volume,
		   wco.buy_uom,
		   wco.buy_term_start,
		   wco.buy_term_end,
		   wco.sell_index,
		   wco.sell_price,
		   wco.sell_currency,
		   wco.sell_volume,
		   wco.sell_uom,
		   wco.sell_term_start,
		   wco.sell_term_end
	FROM   whatif_criteria_other wco
		   INNER JOIN portfolio_mapping_source pms
				ON  pms.mapping_source_usage_id = wco.criteria_id
				AND pms.mapping_source_value_id = 23201
END