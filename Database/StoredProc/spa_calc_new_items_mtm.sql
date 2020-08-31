IF OBJECT_ID(N'spa_calc_new_items_mtm', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_calc_new_items_mtm]
 GO 



--exec spa_calc_new_items_mtm 724, '2005-10-30', 4500
CREATE proc [dbo].[spa_calc_new_items_mtm]
@link_id int,
@reprice_date varchar(20),
@curve_source_id int
as 

create table #temp_source_id(
sid int identity(1,1),
source_deal_header_id int
)

insert into #temp_source_id
SELECT fas_link_detail.source_deal_header_id  
FROM    fas_link_detail 
where  hedge_or_item = 'i' and percentage_included <> 0
and fas_link_detail.link_id = @link_id

declare @i int
select @i = count(*) from #temp_source_id

If (@i = 0)
	return


-- SELECT source_deal_header.source_deal_header_id  
-- FROM   gen_hedge_group INNER JOIN
-- gen_fas_link_header ON gen_hedge_group.gen_hedge_group_id = gen_fas_link_header.gen_hedge_group_id INNER JOIN
-- gen_fas_link_detail ON gen_fas_link_header.gen_link_id = gen_fas_link_detail.gen_link_id INNER JOIN
-- source_deal_header ON source_deal_header.deal_id = CAST(gen_fas_link_detail.deal_number AS varchar) + '-Farrms'
-- where gen_hedge_group.reprice_items_id =@link_id 


declare @source_id int
declare @multi_source_id varchar(50)
set @multi_source_id = NULL
--set @i=@@rowcount
while @i <> 0
begin
	select @source_id=source_deal_header_id from #temp_source_id where sid=@i
	if @multi_source_id is null
		set @multi_source_id= cast(@source_id as varchar)
	else
		set @multi_source_id=@multi_source_id +','+ cast(@source_id as varchar)
	set @i=@i-1
end

-- EXEC spa_print @multi_source_id
-- EXEC spa_print @reprice_date
-- EXEC spa_print @curve_source_id

exec spa_calc_mtm_job NULL, NULL, NULL, NULL, @multi_source_id, @reprice_date, @curve_source_id, 775, 'i', 
NULL, null,null









