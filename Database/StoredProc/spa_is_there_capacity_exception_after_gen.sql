IF OBJECT_ID(N'spa_is_there_capacity_exception_after_gen', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_is_there_capacity_exception_after_gen]
GO

-- declare @exceptions_count int, @exceptions_url varchar(1000) 
-- EXEC spa_is_there_capacity_exception_after_gen 203, @exceptions_count OUTPUT, @exceptions_url OUTPUT
-- select @exceptions_count, @exceptions_url

CREATE PROCEDURE [dbo].[spa_is_there_capacity_exception_after_gen] 
	@gen_hedge_group_id INT,
	@exceptions_count INT OUTPUT,
	@exceptions_url varchar(MAX) OUTPUT
AS
/*
 SET nocount off	
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo


declare
@gen_hedge_group_id INT=1129,
	@exceptions_count INT ,
	@exceptions_url varchar(MAX) 

drop table #gen_exceptions_aa

--*/
SET @exceptions_url = ''
SET @exceptions_count = 0


CREATE TABLE #gen_exceptions_aa
(
sub					VARCHAR(550) COLLATE DATABASE_DEFAULT,
strategy			VARCHAR(550) COLLATE DATABASE_DEFAULT,
book				VARCHAR(550) COLLATE DATABASE_DEFAULT,
index_name			VARCHAR(500) COLLATE DATABASE_DEFAULT,
term				VARCHAR(500) COLLATE DATABASE_DEFAULT,
volume_frequency	VARCHAR(500) COLLATE DATABASE_DEFAULT,
volume_uom			VARCHAR(500) COLLATE DATABASE_DEFAULT,
net_asset_vol		FLOAT,
net_item_vol		FLOAT,
--available_capcity	FLOAT,
over_hedged			VARCHAR(500) COLLATE DATABASE_DEFAULT
)

DECLARE @book_entity_id INT, 
	@sub_entity_id INT,
	@strategy_entity_id INT,
	@convert_unit_id INT,
	@as_of_date varchar(10)

select @book_entity_id = fas_book_id, @strategy_entity_id = stra.entity_id , @sub_entity_id = stra.parent_entity_id,
	@as_of_date = convert(varchar(10),link_effective_date ,120)
FROM gen_fas_link_header INNER JOIN
portfolio_hierarchy book ON  book.entity_id = fas_book_id INNER JOIN
portfolio_hierarchy stra ON  stra.entity_id = book.parent_entity_id 
where gen_hedge_group_id = @gen_hedge_group_id

--@convert_unit_id
SELECT     @convert_unit_id = uom_id 
FROM         source_price_curve_def
where source_curve_def_id = (
SELECT     MIN(gen_deal_detail.curve_id)
FROM         gen_fas_link_header INNER JOIN
                      gen_fas_link_detail ON gen_fas_link_header.gen_link_id = gen_fas_link_detail.gen_link_id INNER JOIN
                      gen_deal_detail ON gen_fas_link_detail.deal_number = gen_deal_detail.gen_deal_header_id
WHERE     (gen_fas_link_header.gen_hedge_group_id = @gen_hedge_group_id) AND (gen_fas_link_detail.hedge_or_item = 'i') AND (gen_deal_detail.curve_id IS NOT NULL)
)



INSERT  #gen_exceptions_aa
EXEC spa_Create_Available_Hedge_Capacity_Exception_Report @as_of_date, 
							@sub_entity_id, 
							@strategy_entity_id, 
							@book_entity_id, 
							'c','m',@convert_unit_id, 'e',402, 'f', 'b'

select @exceptions_count = count(*) from #gen_exceptions_aa
where index_name IN 
(
SELECT  DISTINCT source_price_curve_def.curve_name
FROM    gen_fas_link_header INNER JOIN
        gen_fas_link_detail ON gen_fas_link_header.gen_link_id = gen_fas_link_detail.gen_link_id INNER JOIN
        gen_deal_detail ON gen_fas_link_detail.deal_number = gen_deal_detail.gen_deal_header_id INNER JOIN
	source_price_curve_def ON  source_price_curve_def.source_curve_def_id = gen_deal_detail.curve_id
WHERE   (gen_fas_link_header.gen_hedge_group_id = @gen_hedge_group_id) AND 
	(gen_fas_link_detail.hedge_or_item = 'i') AND (gen_deal_detail.curve_id IS NOT NULL)
)

--select @exceptions_count

If @exceptions_count > 0
BEGIN

	set @exceptions_url = './spa_html.php?spa=EXEC spa_Create_Available_Hedge_Capacity_Exception_Report ''' + dbo.FNAGetSQLStandardDate(@as_of_date) + ''', ' +  
								cast(@sub_entity_id as varchar) + ', ' + 
								cast(@strategy_entity_id as varchar) + ', ' +
								cast(@book_entity_id as varchar) + ', ' + 
								'''c'',''m'', ' +
								cast(@convert_unit_id as varchar) + ', ''e'', 402, ''f'', ''b'''
	
	set @exceptions_url = '<a target="_blank" href="' + @exceptions_url + '">' + 
	         cast(@exceptions_count as varchar) + ' Over hedge capacity exceptions  ocurred.' + 			    			    
		'.</a>'	

END





