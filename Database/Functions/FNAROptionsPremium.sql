IF OBJECT_ID(N'FNAROptionsPremium', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNAROptionsPremium]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAROptionsPremium]    Script Date: 04/05/2009 12:25:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAROptionsPremium]
(
	@source_deal_detail_id INT -- @deal_id is @source_deal_detail_id
)

RETURNS FLOAT AS
BEGIN

DECLARE @total_premium FLOAT
DECLARE @source_deal_header_id INT
declare @source_price_curve varchar(100)
declare @leg int
declare @term_start varchar(20)

select @source_deal_header_id = source_deal_header_id, @leg = leg, @term_start = dbo.FNAGetSQLStandardDate(term_start) 
from source_deal_detail where source_deal_detail_id = @source_deal_detail_id




IF @leg <> 1 
	RETURN 0
ELSE
BEGIN
	
	select 
	   @total_premium=
	   case when a.deal_volume_frequency ='d' then (datediff(day,a.term_start,a.term_end)+1) else 1 end * a.deal_volume * 
	   ((isnull(a.fixed_price, 0) + isnull(ol.premium, 0) + isnull(a.price_adder, 0) --+ isnull(a.formula_value, 0)
			) * isnull(a.price_multiplier, 1)) 
	from source_deal_detail a LEFT OUTER JOIN 
	(
	select  a.source_deal_header_id, a.term_start, a.curve_id strike_curve_id, tc.curve_value strike_curve_value,
					isnull(tc.curve_value, 0) + isnull(a.option_strike_price, 0) strike_price, a.fixed_price premium
			from source_deal_detail a left outer join
			source_price_curve_def spcd ON spcd.source_curve_def_id = a.curve_id left outer join
			source_price_curve tc ON tc.source_curve_def_id = a.curve_id AND 
						 tc.maturity_date = dbo.FNAGetSQLStandardDate(CASE WHEN (spcd.Granularity = 980 OR spcd.Granularity = 991 OR spcd.Granularity = 992 OR spcd.Granularity = 993) 
				THEN cast(Year(a.term_start) as varchar) + '-' + cast(Month(a.term_start) as varchar) + '-01' ELSE a.term_start END) AND
						tc.as_of_date = a.contract_expiration_date 
			
	where a.source_deal_header_id = @source_deal_header_id and leg = 2 and term_start =  @term_start 
	) ol ON a.source_deal_header_id = ol.source_deal_header_id AND 
			a.term_start = ol.term_start 
	WHERE 
			a.leg = 1 AND 
			a.source_deal_detail_id = @source_deal_detail_id 
END


	RETURN @total_premium
END


