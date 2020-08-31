IF OBJECT_ID(N'[dbo].[FNARAverageMonthlyCurveValue]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNARAverageMonthlyCurveValue]
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.FNARAverageMonthlyCurveValue(
	@price_multiplier float,
	@call_from int, -- 2=date from calendar, rest from @CFD_month
	@source_deal_detail_id INT,
	@as_of_date DATETIME -- @as_of_date value will be null while calculating for settlement
	,@curve_shift_val FLOAT ,@curve_shift_per FLOAT
)
	RETURNS FLOAT
AS
BEGIN
	
	/* Test Data
	-- SELECT dbo.FNARAverageCurveValue(null,19,'2013-11-29')	
	DROP TABLE #price_dates
	DECLARE @price_multiplier float,@source_deal_detail_id INT, @as_of_date DATETIME,@call_from int=2,@curve_shift_val FLOAT ,@curve_shift_per FLOAT
	SET @source_deal_detail_id = 8800
	SET @as_of_date='2014-10-01'
	
	--*/

	 
	DECLARE @avg_curve_value FLOAT,@BL_pricing_curve_id int,@CFD_month datetime,@udf_fx_mult float,@pricing int,@formula_currency_id int,@settlement_currency_id int,@func_currency_id INT,@price_uom_multiplier FLOAT,@udf_adder FLOAT
	
	SELECT @curve_shift_val=ISNULL(@curve_shift_val,0),@curve_shift_per=ISNULL(@curve_shift_per,1)
	
	select @pricing=sdh.pricing ,@formula_currency_id =sdd.formula_currency_id,@settlement_currency_id =sdd.settlement_currency,@func_currency_id= fs.func_cur_value_id
				from source_deal_header sdh inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
					and sdd.source_deal_detail_id=@source_deal_detail_id --and sdd.formula_currency_id<>sdd.settlement_currency
					INNER JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1=sdh.source_system_book_id1
						AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
						AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
						AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
					INNER JOIN portfolio_hierarchy ph ON ph.entity_id = ssbm.fas_book_id
					INNER JOIN portfolio_hierarchy ph1 ON ph1.entity_id = ph.parent_entity_id
					INNER JOIN portfolio_hierarchy ph2 ON ph2.entity_id = ph1.parent_entity_id	
					INNER JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = ph2.entity_id
		
		
		SELECT @formula_currency_id = spcd.source_currency_id
				FROM source_deal_detail sdd
						INNER JOIN user_defined_deal_detail_fields udddf ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
						INNER JOIN user_defined_deal_fields_template uddft	ON  uddft.udf_template_id = udddf.udf_template_id 
						INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=udddf.udf_value
				WHERE
						sdd.source_deal_detail_id=@source_deal_detail_id and  uddft.field_id='300859'
	

	
	select @udf_adder =udddf.udf_value
	FROM source_deal_detail sdd
			INNER JOIN user_defined_deal_detail_fields udddf ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
			INNER JOIN user_defined_deal_fields_template uddft	ON  uddft.udf_template_id = udddf.udf_template_id 
	WHERE
			sdd.source_deal_detail_id=@source_deal_detail_id and uddft.Field_label='Adder'


	DECLARE @price_dates TABLE(curve_id INT,price_date DATETIME,maturity_date DATETIME)
	
	set @price_multiplier=isnull(nullif(@price_multiplier,0),1)

	insert into @price_dates  (curve_id,price_date,maturity_date)
	select [curve_id],[term_start],maturity_date from dbo.FNAGetBLPricingTerm(@source_deal_detail_id,@call_from)



	SELECT 	  @BL_pricing_curve_id=udddf.udf_value
					FROM user_defined_deal_detail_fields udddf 
						INNER JOIN  user_defined_deal_fields_template uddft	ON  uddft.udf_template_id = udddf.udf_template_id 
						  AND uddft.Field_id=-5637  and udddf.source_deal_detail_id = @source_deal_detail_id --'CFD Index'

--select @BL_pricing_curve_id
	--SELECT 	  @CFD_month=udddf.udf_value
	--				FROM user_defined_deal_detail_fields udddf 
	--					INNER JOIN  user_defined_deal_fields_template uddft	ON  uddft.udf_template_id = udddf.udf_template_id 
	--					  AND uddft.Field_id=-5636 and udddf.source_deal_detail_id = @source_deal_detail_id --'CFD Month'
	SELECT 	  @CFD_month=term_start from source_deal_detail where source_deal_detail_id = @source_deal_detail_id --'CFD Month'


	--select * into #price_dates from @price_dates

	SELECT
		@avg_curve_value = AVG((
			(coalesce(spc1.curve_value,spc.curve_value,spc2.curve_value,spc3.curve_value,spc4.curve_value)+ @curve_shift_val) * @curve_shift_per 
			*isnull(@price_multiplier,1)+ISNULL(@udf_adder,0)) * COALESCE(1.00/spc6.curve_value,spc5.curve_value,1))
		
		----------price_date,spc1.curve_value,spc.curve_value,spc2.curve_value,spc3.curve_value,spc4.curve_value	
	 FROM @price_dates pd
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = pd.curve_id
		LEFT JOIN source_price_curve_def spcd_s ON spcd_s.source_curve_def_id = spcd.settlement_curve_id
		LEFT  JOIN source_price_curve_def spcd2 ON spcd.proxy_source_curve_def_id=spcd2.source_curve_def_id
		LEFT  JOIN source_price_curve_def spcd3 ON spcd.monthly_index=spcd3.source_curve_def_id
		LEFT  JOIN source_price_curve_def spcd4 ON spcd.proxy_curve_id3=spcd4.source_curve_def_id
		cross apply
			( select exp_calendar_id from   source_price_curve_def where source_curve_def_id=@BL_pricing_curve_id ) cfd_spcd 
	
		left JOIN holiday_group hg ON hg.hol_group_value_id = cfd_spcd.exp_calendar_id and hg.exp_date  =pd.price_date
			and 1=case when isnull(@call_from,0)=2 then 1 else null end
	left JOIN source_price_curve spc ON spc.source_curve_def_id = spcd.source_curve_def_id AND spc.as_of_date = @as_of_date
			AND spc.maturity_date =isnull(hg.hol_date, @CFD_month)	
		left JOIN source_price_curve spc1 ON spc1.source_curve_def_id = isnull(spcd.settlement_curve_id,spcd.source_curve_def_id) AND spc1.as_of_date = pd.price_date
			AND spc1.maturity_date = isnull(hg.hol_date, @CFD_month)		and 1=case when @as_of_date	is null then 1 else 2 end -- 	ignor join for mtm calculation	
		left JOIN source_price_curve spc2 ON spc2.source_curve_def_id = spcd.proxy_source_curve_def_id AND spc2.as_of_date = @as_of_date
			AND spc2.maturity_date = isnull(hg.hol_date, @CFD_month)				
		left JOIN source_price_curve spc3 ON spc3.source_curve_def_id = spcd.monthly_index AND spc3.as_of_date = @as_of_date
			AND spc3.maturity_date = isnull(hg.hol_date, @CFD_month)				
		left JOIN source_price_curve spc4 ON spc4.source_curve_def_id = spcd.proxy_curve_id3 AND spc4.as_of_date = @as_of_date
			AND spc4.maturity_date = isnull(hg.hol_date, @CFD_month)		
		left join source_price_curve_def fx_curve ON fx_curve.source_currency_id = @formula_currency_id and
				fx_curve.source_currency_to_id  = @func_currency_id AND fx_curve.Granularity=980
		left join source_price_curve spc5 ON  spc5.source_curve_def_id=fx_curve.source_curve_def_id AND  spc5.as_of_date =@as_of_date 
			and spc5.maturity_date = isnull(hg.hol_date, @CFD_month)		
		left join source_price_curve_def fx_curve1 ON fx_curve1.source_currency_id = @func_currency_id  and
				fx_curve1.source_currency_to_id  =@formula_currency_id AND fx_curve1.Granularity=980 
		left join source_price_curve spc6 ON  spc6.source_curve_def_id = fx_curve1.source_curve_def_id AND spc6.as_of_date = @as_of_date 
				AND spc6.maturity_date = isnull(hg.hol_date, @CFD_month)	
	
	return @avg_curve_value
END	

--select * from @price_dates
--select * from source_price_curve where source_curve_def_id=1767 and as_of_date='2014-10-22 00:00:00.000'