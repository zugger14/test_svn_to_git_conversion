/****** Object:  StoredProcedure [dbo].[spa_Temp_Rwest_Deal_detail]    Script Date: 07/18/2011 23:26:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_Temp_Rwest_Deal_detail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Temp_Rwest_Deal_detail]
GO

/****** Object:  StoredProcedure [dbo].[spa_Temp_Rwest_Deal_detail]    Script Date: 07/18/2011 23:26:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[spa_Temp_Rwest_Deal_detail]
as

select d.*,sdh.source_deal_header_id into #temp_detail from rwest_detail d join source_deal_header sdh 
on d.trade_id=sdh.deal_id

update #temp_detail set [Energy_vol]=case when [Energy_vol]='' then NULL else [Energy_vol] end,
price=case when price='' then NULL else price end

update source_deal_detail set deal_volume=0
where  source_deal_header_id in (select distinct source_deal_header_id from #temp_detail)

update source_deal_detail set fixed_price=case when t.price is not null then t.price else fixed_price end,
deal_volume=case when energy_vol is NULL then deal_volume else ABS(cast(energy_vol as FLOat)) end, 
buy_sell_flag=case when energy_vol is NULL then buy_sell_flag
when cast(energy_vol as FLOat)<0 then 's' 
when cast(energy_vol as FLOat)>0 then 'b' 
else buy_sell_flag end
from  #temp_detail t join source_deal_detail sdd 
on t.source_deal_header_id=sdd.source_deal_header_id
and cast(t.start_date as datetime)=sdd.term_start and 
cast(t.end_date as datetime)=sdd.term_end

GO


