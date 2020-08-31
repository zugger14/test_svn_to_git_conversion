IF OBJECT_ID(N'[dbo].[FNARWACOGPrice]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].FNARWACOGPrice
SET ANSI_NULLS ON
GO
--GO

create FUNCTION [dbo].[FNARWACOGPrice](
	@source_deal_detail_id INT,
	@as_of_date DATETIME,@curve_shift_val FLOAT ,@curve_shift_per FLOAT
)
	RETURNS FLOAT
AS
BEGIN
	

/* Test Data
	 --SELECT dbo.FNARAverageCurveValue(null,19,'2013-11-29')	
	--DROP TABLE #price_dates
	DECLARE @source_deal_detail_id INT=9536
	, @as_of_date DATETIME
	,@curve_shift_val FLOAT 
	,@curve_shift_per FLOAT
	
--select * from dbo.FNAGetBLPricingTerm(8676,1)
	
	--*/

	--select * from source_deal_detail where source_deal_header_id=3565

	DECLARE @avg_curve_value FLOAT

	SELECT @curve_shift_val=ISNULL(@curve_shift_val,0),@curve_shift_per=ISNULL(@curve_shift_per,1)

	select @avg_curve_value=sum(
		case when wd.fixed_price is null then
			( ([dbo].[FNARAverageCurveValue](null,-1*wd.wacog_fixed_price_deemed_id ,@as_of_date ,@curve_shift_val  ,@curve_shift_per) 
			* isnull(wd.multiplier,1)+ isnull(wd.adder,0))* isnull(wd.volume,0))
		else
			wd.fixed_price* isnull(wd.volume,0)
		end
	) /max(nullif(vol.volume,0))
	
	
	--select 
	--[dbo].[FNARAverageCurveValue](null,-1*wd.wacog_fixed_price_deemed_id ,@as_of_date ,@curve_shift_val  ,@curve_shift_per)
	--, isnull(wd.adder,0) , isnull(wd.multiplier,1), isnull(wd.volume,0)
	--,vol.volume

	--,(([dbo].[FNARAverageCurveValue](null,-1*wd.wacog_fixed_price_deemed_id ,@as_of_date ,@curve_shift_val  ,@curve_shift_per)
	-- *isnull(wd.multiplier,1)+isnull(wd.adder,0))* isnull(wd.volume,0))/vol.volume
	from  wacog_fixed_price_deemed wd
	cross apply
	(
		select  sum(volume) volume from dbo.wacog_fixed_price_deemed
		where source_deal_detail_id=@source_deal_detail_id
	) vol
	left JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=wd.pricing_index
	LEFT JOIN deal_uom_conversion_factor dm on dm.source_deal_detail_id=@source_deal_detail_id
		AND COALESCE(dm.from_uom_id,spcd.uom_id)=spcd.uom_id 
		AND COALESCE(dm.to_uom_id,spcd.display_uom_id,spcd.uom_id)=ISNULL(spcd.display_uom_id,spcd.uom_id)	 
	LEFT JOIN rec_volume_unit_conversion vuc ON	vuc.from_source_uom_id = spcd.uom_id
		AND vuc.to_source_uom_id = isnull(spcd.display_uom_id, spcd.uom_id)
	where wd.source_deal_detail_id=@source_deal_detail_id
	
	return @avg_curve_value
	
END	

--select * from @price_dates
--select * from source_price_curve where source_curve_def_id=618 and as_of_date='2014-02-12'