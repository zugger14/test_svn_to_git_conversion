IF OBJECT_ID(N'[dbo].[FNAGetBLPricingTermRatio]') IS NOT NULL
    DROP FUNCTION [dbo].[FNAGetBLPricingTermRatio]
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.FNAGetBLPricingTermRatio(
		@source_deal_detail_id INT -- -ve id for wacog_fixed_price_deemed_id
		
) 
	RETURNS @price_dates TABLE 
(
	[curve_id] int,
	[term_start] datetime,
	ratio numeric(28,20)
)
AS
BEGIN
	
	/* Test Data
	-- SELECT * from dbo.FNAGetBLPricingTerm(19)	
	--DROP TABLE #price_dates
	DECLARE @source_deal_detail_id INT, @as_of_date DATETIME,@call_from int=0
	SET @source_deal_detail_id = 9536
	--select * from source_deal_detail where source_deal_header_id=3565
	declare  @price_dates TABLE 
	(
		[curve_id] int,
		[term_start] datetime,ratio float
	)


	
	--*/
	DECLARE @curve_id INT, @from_date VARCHAR(10),@to_date VARCHAR(10),@term_start VARCHAR(10),@logical_name VARCHAR(100)
	,@generic_mapping_name VARCHAR(100),@pricing_type varchar(1), @holiday_calendar INT

	declare  @tmp_price_dates TABLE 
	( id int,
		[curve_id] int,
		[term_start] datetime
	)
	SELECT  @holiday_calendar = calendar_desc   FROM default_holiday_calendar

	IF @holiday_calendar IS NULL
		SET @holiday_calendar = 291898
	

	;WITH CTE AS (
		SELECT 	wacog_fixed_price_deemed_id,pricing_index, CAST(dbo.FNAGetBusinessDay ('n',DATEADD(DAY,-1,pricing_start),@holiday_calendar) AS DATETIME) bl_date ,pricing_end  
		FROM wacog_fixed_price_deemed WHERE abs(@source_deal_detail_id)=case when @source_deal_detail_id<0 then wacog_fixed_price_deemed_id else source_deal_detail_id end and pricing_index is not null
		UNION ALL
		SELECT wacog_fixed_price_deemed_id,pricing_index,CAST(dbo.FNAGetBusinessDay ('n',bl_date,@holiday_calendar) AS DATETIME),pricing_end FROM CTE 
				WHERE CAST(dbo.FNAGetBusinessDay('n',bl_date,@holiday_calendar) AS DATETIME) <= pricing_end
		)
		
		INSERT INTO @tmp_price_dates(id, curve_id,term_start)
		SELECT wacog_fixed_price_deemed_id,pricing_index,bl_date FROM CTE c
		cross apply
		( select exp_calendar_id from   source_price_curve_def where source_curve_def_id=pricing_index ) spcd 
		left JOIN holiday_group hg ON hg.hol_group_value_id = spcd.exp_calendar_id and hg.hol_date  =bl_date
			where spcd.exp_calendar_id is null or (spcd.exp_calendar_id is not null and hg.hol_group_value_id is not null)
		
		
		
		INSERT INTO @price_dates(curve_id,term_start,ratio)
		SELECT curve_id,term_start,sum(cast(cast(c_vol.volume/tot_vol.volume as numeric(28,18))/tot_count.cnt as numeric(28,20))) ratio 
		FROM @tmp_price_dates  c
		outer apply
		( select  count(1) cnt  FROM @tmp_price_dates
			WHERE id=c.id 
		) tot_count
		outer apply
		( select  cast(sum(deal_volume) as numeric(26,10)) volume  FROM source_deal_detail
			WHERE source_deal_detail_id=@source_deal_detail_id 
		) tot_vol
		outer apply
		( select  cast(sum(volume) as numeric(26,10)) volume  FROM wacog_fixed_price_deemed
			WHERE wacog_fixed_price_deemed_id=c.id  
		) c_vol
		group by curve_id,term_start
	
	 --select * from @price_dates
	return 

end
