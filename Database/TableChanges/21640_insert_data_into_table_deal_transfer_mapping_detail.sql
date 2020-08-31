/* Condition checked before inserting data due to column being 
   dropped before data insertion in new table in dev version.
 */
IF COL_LENGTH('deal_transfer_mapping','source_book_mapping_id_offset') IS NOT NULL
AND COL_LENGTH('deal_transfer_mapping','trader_id_offset') IS NOT NULL
AND COL_LENGTH('deal_transfer_mapping','counterparty_id_offset') IS NOT NULL
AND COL_LENGTH('deal_transfer_mapping','contract_id_offset') IS NOT NULL
AND COL_LENGTH('deal_transfer_mapping','template_id_offset') IS NOT NULL
AND COL_LENGTH('deal_transfer_mapping','source_book_mapping_id_to') IS NOT NULL
AND COL_LENGTH('deal_transfer_mapping','trader_id_to') IS NOT NULL
AND COL_LENGTH('deal_transfer_mapping','counterparty_id') IS NOT NULL
AND COL_LENGTH('deal_transfer_mapping','contract_id') IS NOT NULL
AND COL_LENGTH('deal_transfer_mapping','template_id_to') IS NOT NULL
AND COL_LENGTH('deal_transfer_mapping','transfer_type') IS NOT NULL
AND COL_LENGTH('deal_transfer_mapping','fixed') IS NOT NULL
AND COL_LENGTH('deal_transfer_mapping','index_adder') IS NOT NULL
AND COL_LENGTH('deal_transfer_mapping','fixed_adder') IS NOT NULL
BEGIN
	EXEC('INSERT INTO deal_transfer_mapping_detail(
											 deal_transfer_mapping_id
											,sub_book
											,trader_id
											,counterparty_id
											,contract_id
											,template_id
											,transfer_sub_book
											,transfer_trader_id
											,transfer_counterparty_id
											,transfer_contract_id
											,transfer_template_id
											,transfer_type
											,fixed_price
											,index_adder
											,fixed_adder
											)
	SELECT  dtm.deal_transfer_mapping_id
		   ,dtm.source_book_mapping_id_offset
		   ,dtm.trader_id_offset
		   ,dtm.counterparty_id_offset
		   ,dtm.contract_id_offset
		   ,dtm.template_id_offset
		   ,dtm.source_book_mapping_id_to
		   ,dtm.trader_id_to
		   ,dtm.counterparty_id
		   ,dtm.contract_id
		   ,dtm.template_id_to
		   ,dtm.transfer_type
		   ,dtm.fixed
		   ,dtm.index_adder
		   ,dtm.fixed_adder
	FROM deal_transfer_mapping dtm
	LEFT JOIN deal_transfer_mapping_detail dtmd
		ON dtmd.deal_transfer_mapping_id = dtm.deal_transfer_mapping_id
	WHERE dtmd.deal_transfer_mapping_detail_id IS NULL
	'
	)
END


  
 
  
  
  
