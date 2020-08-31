IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_dealclose]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_dealclose]
GO
--
--set ANSI_NULLS ON
--set QUOTED_IDENTIFIER ON
--go
/*
	
	exec [spa_get_dealclose] 2197


*/

CREATE proc [dbo].[spa_get_dealclose]
@source_deal_header_id varchar(1000)=NULL
as
DECLARE @sql_select as varchar(max)
--set @source_deal_header_id=2197
create table #offset (
[close_reference_id] int,term_start datetime,term_end datetime,leg int,
offset_vol float
)



set @sql_select='
insert into #offset ([close_reference_id],term_start,term_end,leg,offset_vol)
select [close_reference_id],term_start,term_end,leg,sum(case when buy_sell_flag=''b'' then 1 else -1 end * deal_volume) offset_vol 
from source_deal_detail a join
		source_deal_header h on
		a.source_deal_header_id=h.source_deal_header_id and process_deal_status=12500
where [close_reference_id] in ('+@source_deal_header_id+')
group by [close_reference_id],term_start,term_end,leg

'

exec(@sql_select)
EXEC spa_print @sql_select
--select * from  #offset
--case when buy_sell_flag='b' then 1 else -1 end * deal_volume

set @sql_select='select  h.source_deal_header_id as [Deal ID],dbo.FNADateFormat(h.deal_date) [Deal Date],dbo.FNADateFormat(a.term_start) as [Term Start],dbo.FNADateFormat(a.term_end) as [Term End],
a.curve_id  as [Index]	,
	a.Leg,
		case when buy_sell_flag =''b'' then ''Buy(Receive)'' else ''Sell(Pay)'' End as [Buy Sell],
				a.deal_volume as [Deal Volume],
				abs((case when buy_sell_flag=''b'' then 1 else -1 end * deal_volume)+isnull(offset_vol,0)) [Available Volume],
				abs((case when buy_sell_flag=''b'' then 1 else -1 end * deal_volume)+isnull(offset_vol,0)) [Close Volume],
				deal_volume_frequency as Frequency,a.deal_volume_uom_id as UOM,					
			fixed_price  as [Price],	
		 	a.fixed_price_currency_id  as Currency
		from source_deal_detail a join
		source_deal_header h on
		a.source_deal_header_id=h.source_deal_header_id and isnull(h.deal_reference_type_id,0)<>12501 left join
		#offset t on t.[close_reference_id]=a.source_deal_header_id and t.term_start=a.term_start
		and t.term_end=a.term_end and t.leg=a.leg join
		source_deal_type sdt on sdt.source_deal_type_id=h.source_deal_type_id 
		left outer join source_price_curve_def pcd on pcd.source_curve_def_id=a.curve_id 
		left outer join rec_generator rg on rg.generator_id=h.generator_id
		left outer join formula_editor fe on fe.formula_id=a.formula_id
		left outer join source_currency sc on sc.source_currency_id=a.fixed_price_currency_id
		left outer join source_commodity sco on sco.source_commodity_id=pcd.commodity_id
		left outer join source_uom uom on uom.source_uom_id=a.deal_volume_uom_id	
		where a.source_deal_header_id in ('+@source_deal_header_id +') and abs((case when buy_sell_flag=''b'' then 1 else -1 end * deal_volume)+isnull(offset_vol,0))>0'

		
		
		set @sql_select= @sql_select+ ' order by a.source_deal_header_id,a.term_start,a.term_end,a.leg '
		
		EXEC spa_print @sql_select
	

		exec(@sql_select)


