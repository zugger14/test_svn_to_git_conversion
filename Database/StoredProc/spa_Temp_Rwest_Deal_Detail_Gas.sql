
/****** Object:  StoredProcedure [dbo].[spa_Temp_Rwest_Deal_Detail_Gas]    Script Date: 07/18/2011 23:23:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_Temp_Rwest_Deal_Detail_Gas]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Temp_Rwest_Deal_Detail_Gas]
GO

/****** Object:  StoredProcedure [dbo].[spa_Temp_Rwest_Deal_Detail_Gas]    Script Date: 07/18/2011 23:23:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE proc [dbo].[spa_Temp_Rwest_Deal_Detail_Gas]
as

delete rwest_detail_gas where Trade_Id=''
update rwest_detail_gas set energy_vol=REPLACE(rtrim(ltrim(energy_vol)),',','')
UPDATE rwest_detail_gas SET energy_vol=0 WHERE price_unit='Currency'

delete RWEST_Detail_Gas where Trade_Id in (
select trade_id from RWEST_Detail_Gas 
group by trade_id,Start_Date
having count(*)>1
) and 
((Adder='buy' and cast(Energy_Vol as float)<0) 
or (Adder='sell' and cast(Energy_Vol as float)>1)
)


select h.source_deal_header_id,r.Trade_Id,r.Energy_Unit,MAX(r.Delivery_Location) delivery_location into #temp from source_deal_header h join RWEST_detail_gas r 
on h.deal_id=r.Trade_Id join RWEST rw on rw.Trade_Id=r.Trade_Id
group by h.source_deal_header_id,r.Trade_Id,r.Energy_Unit


update source_deal_detail set deal_volume= abs(cast(g.energy_vol as float)),
fixed_float_leg=case when t.energy_unit='Currency' then 'f' else 't' end ,
buy_sell_flag=case when cast(g.energy_vol as float) <0 then 's' else 'b' end ,
deal_volume_uom_id=u.source_uom_id,
curve_id=p.source_curve_def_id,
fixed_price=g.price
 from source_deal_detail sdd join #temp t on 
sdd.source_deal_header_id=t.source_deal_header_id
join RWEST_detail_gas g on g.trade_id=t.trade_id
and cast(g.start_date as datetime)=sdd.term_start and 
cast(g.end_date as datetime)=sdd.term_end
join  source_uom u on u.uom_id=t.Energy_Unit
left outer join source_price_curve_def p
on case when g.delivery_location='vGO_0.1_BRG_FOB_RTD.USD' then 'ESS#OLFW_GB1 - M' 
when g.Delivery_Location in ('Profiled NonShipped L G1 Comm','TTF51.7','TTF SPM','Metered NonShipped Committed L') then 'ESS#GSFW_TT7 - D'
when g.Delivery_Location='vHFO_1.0_BRG_FOB_RTD.USD' then 'ESS#OLFW_1HB - M'
when g.Delivery_Location in ('BE Exit-Profiled NonShipped-Low','ZEE SPM') then 'ESS#GSFW_ZBH - D'
else NULL end=p.curve_id
WHERE deal_volume_frequency <> 'h'

update source_deal_detail set curve_id=source_curve_def_id,
deal_volume_uom_id=case when deal_volume_frequency <> 'h' then u.source_uom_id else deal_volume_uom_id END,
location_id=case WHEN physical_financial_flag='f' then NULL else sml.source_minor_location_id END
from source_deal_detail sdd join #temp t on 
sdd.source_deal_header_id=t.source_deal_header_id
join  source_uom u on u.uom_id=t.Energy_Unit
left outer join source_price_curve_def p
on case when delivery_location='vGO_0.1_BRG_FOB_RTD.USD' then 'ESS#OLFW_GB1 - M' 
when delivery_location in ('Profiled NonShipped L G1 Comm','TTF51.7','TTF SPM','Metered NonShipped Committed L') then 'ESS#GSFW_TT7 - D'
when delivery_location='vHFO_1.0_BRG_FOB_RTD.USD' then 'ESS#OLFW_1HB'
when delivery_location in ('BE Exit-Profiled NonShipped-Low','ZEE SPM') then 'ESS#GSFW_ZBH - D'
else NULL end=p.curve_id
LEFT OUTER JOIN dbo.source_minor_location sml ON sml.location_name=t.delivery_location





GO


