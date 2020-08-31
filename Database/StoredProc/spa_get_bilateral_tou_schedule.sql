/****** Object:  StoredProcedure [dbo].[spa_get_bilateral_tou_schedule]    Script Date: 07/28/2009 18:01:45 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_bilateral_tou_schedule]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_bilateral_tou_schedule]
/****** Object:  StoredProcedure [dbo].[spa_get_bilateral_tou_schedule]    Script Date: 07/28/2009 18:01:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 EXEC spa_get_bilateral_tou_schedule 518, '2009-06-01', 1 
 EXEC spa_get_bilateral_tou_schedule 518, '2009-06-01', 0
*/

-- @weekdays = 1 means Monday through Saturday,  0 means Sunday and holidays
CREATE PROCEDURE [dbo].[spa_get_bilateral_tou_schedule] @contract_id int, @as_of_date varchar(20), @weekdays int = 1 
AS
--declare @contract_id  int
--declare @as_of_date varchar(20)
--set @contract_id = 518
--set @as_of_date = '2009-06-01'

declare @seq_no_tou int, @seq_no_charge int, @seq_no_vol int
declare @day_start int, @day_end int

set @seq_no_tou = 1
set @seq_no_vol = 2
set @seq_no_charge = 3


declare @calc_id int
select @calc_id = calc_id from calc_invoice_volume_variance where contract_id = @contract_id and as_of_date = @as_of_date

select distinct hc.hol_date 
into #holidays
from contract_group cg inner join
	hourly_block hb ON hb.block_value_id = cg.hourly_block inner join
	holiday_group hc ON hc.hol_group_value_id = hb.holiday_value_id
WHERE cg.contract_id = @contract_id

--select * from #holidays

SELECT tou.hour [Time], round(vol.[Volume],2) [KWH DEL], round(tou.[TOU], 4) [TOU Rate], round(val.[Value], 2) [AMOUNT(Php)]
from 
(
select hour , MAX(value) [TOU] from calc_formula_value 
where calc_id = @calc_id AND seq_number = @seq_no_tou AND invoice_line_item_id = 12599 AND 
	((@weekdays = 1 AND prod_date NOT IN (select hol_date from #holidays) AND datepart(dw, prod_date) BETWEEN 2 AND 7) OR
		(@weekdays = 0 AND (prod_date IN (select hol_date from #holidays) OR datepart(dw, prod_date) = 1)))
group by hour
) tou INNER JOIN
(
select hour , SUM(value) [Value] from calc_formula_value 
where calc_id = @calc_id AND seq_number = @seq_no_charge AND invoice_line_item_id = 12599 AND  
	((@weekdays = 1 AND prod_date NOT IN (select hol_date from #holidays) AND datepart(dw, prod_date) BETWEEN 2 AND 7) OR
		(@weekdays = 0 AND (prod_date IN (select hol_date from #holidays) OR datepart(dw, prod_date) = 1)))
group by hour
) val ON val.hour = tou.hour INNER JOIN
(
select hour , SUM(value) [VOLUME] from calc_formula_value 
where calc_id = @calc_id AND seq_number = @seq_no_vol AND invoice_line_item_id = 12599 AND  
	((@weekdays = 1 AND prod_date NOT IN (select hol_date from #holidays) AND datepart(dw, prod_date) BETWEEN 2 AND 7) OR
		(@weekdays = 0 AND (prod_date IN (select hol_date from #holidays) OR datepart(dw, prod_date) = 1)))
group by hour
) vol ON vol.hour = tou.hour 

order by tou.hour
--select * from static_data_value where type_id = 10019 -- generation charge type = 12599
--select * from calc_invoice_volume_Detail where hour<> 0
--select * from calc_formula_value where hour<> 0

