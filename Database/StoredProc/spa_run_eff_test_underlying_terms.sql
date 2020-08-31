IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_run_eff_test_underlying_terms]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_run_eff_test_underlying_terms]
GO 




--This procedure performs the eff test using underlying terms
--Returns 1 if passed, 0 if failed,  and -1 if error  found
--Check the hedges with the following terms in  items
--     notional volume of hedge <=  item  notional volume
--     term of hedge within the item term
--     same curve index used in  headge as in item
--     same volumen UOM in  hedge as in item
CREATE PROC [dbo].[spa_run_eff_test_underlying_terms]   
	@link_id INT,
	@eff_test_profile_id INT,
	@as_of_date VARCHAR(15),
	@initial_ongoing varchar (1)
AS

-- SET  @link_id = 178
-- --SET @link_id = 177
-- --SET @link_id = 176
-- SET @eff_test_profile_id = 48
-- SET @as_of_date = '2004-06-30'


DECLARE @eff_test_result FLOAT


If ((select perfect_hedge from fas_link_header where link_id = @link_id) = 'n' AND
	(select count(*)
	from
	(SELECT	fld.link_id, 
		sdd.source_deal_header_id, 
		sdd.term_start, 
		sdd.term_end, 
		sdd.buy_sell_flag, 
		sdd.curve_id, 
	        sdd.deal_volume * fld.percentage_included AS deal_volume, sdd.deal_volume_uom_id
	FROM    fas_link_detail fld INNER JOIN
	        source_deal_detail sdd ON fld.source_deal_header_id = sdd.source_deal_header_id
	WHERE   fld.link_id = @link_id AND 
		fld.hedge_or_item = 'h') hedge
	INNER JOIN
	(SELECT	fld.link_id, 
		sdd.source_deal_header_id, 
		sdd.term_start, 
		sdd.term_end, 
		case when (sdd.buy_sell_flag = 'b') then  's' else 'b' end buy_sell_flag, 
		sdd.curve_id, 
	        sdd.deal_volume * fld.percentage_included AS deal_volume, sdd.deal_volume_uom_id
	FROM    fas_link_detail fld INNER JOIN
	        source_deal_detail sdd ON fld.source_deal_header_id = sdd.source_deal_header_id
	WHERE   fld.link_id = @link_id AND 
		fld.hedge_or_item = 'i') item
	ON hedge.buy_sell_flag = item.buy_sell_flag AND isnull(hedge.curve_id, -1) = isnull(item.curve_id, -1)
		and hedge.deal_volume_uom_id = item.deal_volume_uom_id AND
		hedge.deal_volume <= item.deal_volume AND
		hedge.term_start >= item.term_start AND
		hedge.term_end <= item.term_end)
	<> 

	(SELECT	count(*)
	FROM    fas_link_detail fld INNER JOIN
	        source_deal_detail sdd ON fld.source_deal_header_id = sdd.source_deal_header_id
	WHERE   fld.link_id = @link_id AND 
		fld.hedge_or_item = 'h'))
SET @eff_test_result = 0 
Else 
SET @eff_test_result = 1

insert into fas_eff_ass_test_results
values(@eff_test_profile_id,  @as_of_date,  @initial_ongoing, @eff_test_result, NULL, 'n', @link_id, 
			2, 317, NULL, NULL, NULL,  NULL, NULL)
	
DECLARE @eff_test_result_id INT
set @eff_test_result_id = SCOPE_IDENTITY()
		
insert into fas_eff_ass_test_results_process_header
values(@eff_test_result_id, @eff_test_result, @eff_test_result, @eff_test_result,
			@eff_test_result, null, null, null, null, null, null, null)


If @@ERROR <> 0
	Select -1 AS eff_test_result_id
Else
	Select isnull(@eff_test_result_id, -1) as eff_test_result_id





