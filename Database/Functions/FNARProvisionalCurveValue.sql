IF OBJECT_ID(N'[dbo].[FNARProvisionalCurveValue]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNARProvisionalCurveValue]
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.FNARProvisionalCurveValue(
	@price_multiplier float,
	@source_deal_detail_id INT,
	@as_of_date DATETIME,@curve_shift_val FLOAT ,@curve_shift_per FLOAT
)
	RETURNS FLOAT
AS
BEGIN
	
/* Test Data
	-- SELECT dbo.FNARProvisionalCurveValue(null,19,'2013-11-29')	
	--DROP TABLE #price_dates
	DECLARE @price_multiplier float,@source_deal_detail_id INT, @as_of_date DATETIME
	SET @source_deal_detail_id = 3510
	SET @as_of_date= '2013-06-30'
	
	--*/

	--select * from source_deal_detail where source_deal_header_id=1839

	DECLARE @avg_curve_value FLOAT
	
	
	DECLARE @price_dates TABLE(curve_id INT,price_date DATETIME)
	
	SELECT @curve_shift_val=ISNULL(@curve_shift_val,0),@curve_shift_per=ISNULL(@curve_shift_per,1)

	set @price_multiplier=isnull(nullif(@price_multiplier,0),1)

	select @avg_curve_value= uddf.udf_value
	FROM source_deal_detail td 
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = td.source_deal_header_id and td.source_deal_detail_id=@source_deal_detail_id 
		INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id=sdh.template_id	and isnull(uddft.leg,td.leg)=td.leg	
		and uddft.udf_type='h'
		LEFT JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = td.source_deal_header_id  
				AND uddf.udf_template_id = uddft.udf_template_id
	WHERE uddft.field_id='-5647'

	if @avg_curve_value is null
	begin

		set @source_deal_detail_id=-1*@source_deal_detail_id

		insert into @price_dates  (curve_id,price_date)
		select [curve_id],[term_start] from dbo.FNAGetBLPricingTerm(@source_deal_detail_id,0)

		--select * into #price_dates from @price_dates

		SELECT
				@avg_curve_value = AVG((coalesce(spc1.curve_value,spc.curve_value,spc2.curve_value,spc3.curve_value,spc4.curve_value)+ @curve_shift_val) * @curve_shift_per)
				--price_date,spc1.curve_value,spc.curve_value,spc2.curve_value,spc3.curve_value,spc4.curve_value	
		 FROM 
			@price_dates pd
			INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = pd.curve_id
			LEFT JOIN source_price_curve_def spcd_s ON spcd_s.source_curve_def_id = spcd.settlement_curve_id
			--left JOIN holiday_group hg On hg.hol_group_value_id=  spcd_s.exp_calendar_id
			--	AND pd.price_date = hg.hol_date		
		
			LEFT  JOIN source_price_curve_def spcd2 ON spcd.proxy_source_curve_def_id=spcd2.source_curve_def_id
			LEFT  JOIN source_price_curve_def spcd3 ON spcd.monthly_index=spcd3.source_curve_def_id
			LEFT  JOIN source_price_curve_def spcd4 ON spcd.proxy_curve_id3=spcd4.source_curve_def_id
			cross apply (
						select price_date [Maturity_hr]
						,cast(convert(varchar(8),price_date,120)+'01' as date) [Maturity_mnth]
						,cast(convert(varchar(5),price_date,120)+ cast(case datepart(q, price_date) when 1 then 1 when 2 then 4 when 3 then 7 when 4 then 10 end as varchar)+'-01' as date) [Maturity_qtr] 
						,cast(convert(varchar(5),price_date,120)+ cast(case when month(price_date) < 7 then 1 else 7 end as varchar)+'-01' as date) [Maturity_semi] 
						,cast(convert(varchar(5),price_date,120)+ '01-01' as date) [Maturity_yr]

					) m 
		left JOIN source_price_curve spc ON spc.source_curve_def_id = spcd.source_curve_def_id AND spc.as_of_date = pd.price_date
				AND spc.maturity_date = case spcd.Granularity when 982 then m.maturity_hr when 981 then pd.price_date when 980 then m.maturity_mnth
				when 991 then m.maturity_qtr when 992 then m.maturity_semi when 993 then m.maturity_yr end			

			--left JOIN source_price_curve spc1 ON spc1.source_curve_def_id = spcd.settlement_curve_id AND spc1.as_of_date = hg.exp_date
			--	AND spc1.maturity_date = hg.hol_date	
	
			left JOIN source_price_curve spc1 ON spc1.source_curve_def_id = isnull(spcd.settlement_curve_id,spcd.source_curve_def_id) AND spc1.as_of_date = pd.price_date
				AND spc1.maturity_date = pd.price_date and 	@as_of_date is null			
			left JOIN source_price_curve spc2 ON spc2.source_curve_def_id = spcd.proxy_source_curve_def_id AND spc2.as_of_date = pd.price_date
				AND spc2.maturity_date = case spcd2.Granularity when 982 then m.maturity_hr when 981 then pd.price_date when 980 then m.maturity_mnth
				when 991 then m.maturity_qtr when 992 then m.maturity_semi when 993 then m.maturity_yr end			
			left JOIN source_price_curve spc3 ON spc3.source_curve_def_id = spcd.monthly_index AND spc3.as_of_date = pd.price_date
				AND spc3.maturity_date = case spcd3.Granularity when 982 then m.maturity_hr when 981 then pd.price_date when 980 then m.maturity_mnth
				when 991 then m.maturity_qtr when 992 then m.maturity_semi when 993 then m.maturity_yr end			
			left JOIN source_price_curve spc4 ON spc4.source_curve_def_id = spcd.proxy_curve_id3 AND spc4.as_of_date = pd.price_date
				AND spc4.maturity_date = case spcd4.Granularity when 982 then m.maturity_hr when 981 then pd.price_date when 980 then m.maturity_mnth
				when 991 then m.maturity_qtr when 992 then m.maturity_semi when 993 then m.maturity_yr end	
			--where  spcd_s.exp_calendar_id  is null  
			--	or ( spcd_s.exp_calendar_id  is not null and hg.hol_group_value_id is not null)



		--IF @avg_curve_value IS NULL
		--	SELECT @avg_curve_value = AVG(spc.curve_value)
		--	FROM source_price_curve_def spcd 
		--		LEFT  JOIN source_price_curve_def spcd2 ON spcd.proxy_source_curve_def_id=spcd2.source_curve_def_id
		--		LEFT  JOIN source_price_curve_def spcd3 ON spcd.monthly_index=spcd3.source_curve_def_id
		--		LEFT  JOIN source_price_curve_def spcd4 ON spcd.proxy_curve_id3=spcd4.source_curve_def_id
		--			INNER JOIN source_price_curve spc ON spc.source_curve_def_id = coalesce(spcd.source_curve_def_id,spcd.settlement_curve_id,spcd2.source_curve_def_id, spcd3.source_curve_def_id, spcd4.source_curve_def_id)  
		--				AND spc.as_of_date = @as_of_date
	end 
	RETURN @avg_curve_value*isnull(@price_multiplier,1)
END	

--select * from @price_dates
--select * from source_price_curve where source_curve_def_id=618 and as_of_date='2014-02-12'