IF OBJECT_ID(N'[dbo].[spa_get_hedge_eff_date]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_hedge_eff_date]
GO 

-- exec spa_get_hedge_eff_date 130006
-- 


create proc [dbo].[spa_get_hedge_eff_date]
	(@deal_ids varchar(500))
AS

declare @sql_str varchar(5000)

-- select dbo.FNADateFormat('05/06/2006')

set @sql_str = '
select dbo.FNAGetSQLStandardDate(case when (isnull(dedesig.rel_eff_date, deal.rel_eff_date) >  deal.rel_eff_date) then
		isnull(dedesig.rel_eff_date, deal.rel_eff_date) else deal.rel_eff_date end)
	rel_eff_date
from 
(select 1 link_id, MAX(deal_date) rel_eff_date from source_deal_header
where source_deal_header_id IN (' + @deal_ids  + ')) deal
left outer join
(
select 1 link_id,  MAX(fdlh.dedesignation_date) rel_eff_date from 
fas_dedesignated_link_detail fdld inner join
fas_dedesignated_link_header fdlh on fdlh.dedesignated_link_id = fdld.dedesignated_link_id
where fdld.hedge_or_item = ''h''
and fdld.source_deal_header_id IN (' + @deal_ids  + ')) dedesig
on dedesig.link_id = deal.link_id '

exec (@sql_str)








