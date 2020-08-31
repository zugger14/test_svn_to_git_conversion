IF OBJECT_ID(N'[dbo].[spa_get_sourcebook_from_counterparty]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_sourcebook_from_counterparty]
 GO 

-- exec spa_get_sourcebook_from_counterparty 's',222

CREATE PROCEDURE [dbo].[spa_get_sourcebook_from_counterparty]
	@flag CHAR(1),
	@counterparty_id INT,
	@term_start DATETIME = NULL,
	@term_end DATETIME = NULL
AS
	
BEGIN

declare @strategy_name_for_mv90 varchar(100)
set @strategy_name_for_mv90='PPA'

select 
	
	rg.generator_id,
	ssbm.book_deal_type_map_id,
	SB.SOURCE_BOOK_NAME,
	sdh.source_deal_header_id
--  	265,
--  	'SUB1_PPA_MN'
	
	
	
from 
	rec_generator rg join portfolio_hierarchy s on s.entity_id=rg.legal_entity_value_id
	left join static_data_value sd1 on sd1.value_id=rg.state_value_id
	left join source_book sb on 
	sb.source_system_book_id=s.entity_name+'_'+@strategy_name_for_mv90+'_'+sd1.code
	left join source_system_book_map ssbm on ssbm.source_system_book_id1=sb.source_book_id
	left join source_deal_header sdh on sdh.generator_id=rg.generator_id and 
		sdh.entire_term_start=@term_start and sdh.entire_term_end=@term_end
where	
	rg.ppa_counterparty_id=@counterparty_id

END




