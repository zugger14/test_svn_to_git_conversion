IF OBJECT_ID(N'[dbo].[FNARAverageCurveValue]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNARAverageCurveValue]
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNARAverageCurveValue](
@price_multiplier float,
 @source_deal_detail_id INT, --- -ve id for 
 @as_of_date DATETIME,@curve_shift_val FLOAT ,@curve_shift_per FLOAT
)
 RETURNS FLOAT
AS
BEGIN
/* Test Data
SELECT dbo.FNARAverageCurveValue(null,19,'2013-11-29') 
DROP TABLE #price_dates


DECLARE @price_multiplier float,@source_deal_detail_id INT, @as_of_date DATETIME,@curve_shift_val FLOAT ,@curve_shift_per FLOAT
SET @source_deal_detail_id = 55080
SET @as_of_date='2016-01-22'

--*/
--select * from source_deal_detail where source_deal_header_id=3730
DECLARE @avg_curve_value FLOAT, @udf_fx_mult float,@pricing int,@formula_currency_id int,@id int
,@settlement_currency_id int,@func_currency_id INT,@price_uom_multiplier FLOAT,@udf_adder FLOAT,@org_as_of_date DATETIME
DECLARE @price_dates TABLE(curve_id INT,price_date DATETIME)
DECLARE @fx_value TABLE(fx_date DATETIME,fx_value float)
DECLARE @price_value TABLE(typ varchar(1),price_date DATETIME,val float)
DECLARE @price_value_f TABLE(typ varchar(1),price_date DATETIME,val float)
DECLARE @pricing_type INT,@formula_curve_id int

declare @pricing_index varchar(10)
select @pricing_index=value_id from static_data_value 
where code = 'Pricing Index'



if @source_deal_detail_id<0
begin
	set @id= abs(@source_deal_detail_id)
	select @source_deal_detail_id=source_deal_detail_id from wacog_fixed_price_deemed where wacog_fixed_price_deemed_id=@id
end
else 
	set @id= null

set @org_as_of_date=@as_of_date
set @as_of_date=null

SELECT @curve_shift_val=ISNULL(@curve_shift_val,0),@curve_shift_per=ISNULL(@curve_shift_per,1)


select @udf_fx_mult =udddf.udf_value
FROM source_deal_detail sdd
INNER JOIN user_defined_deal_detail_fields udddf ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
INNER JOIN user_defined_deal_fields_template uddft ON uddft.udf_template_id = udddf.udf_template_id 
WHERE
sdd.source_deal_detail_id=@source_deal_detail_id and uddft.internal_field_type=18725

select @udf_adder =udddf.udf_value
FROM source_deal_detail sdd
INNER JOIN user_defined_deal_detail_fields udddf ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
INNER JOIN user_defined_deal_fields_template uddft ON uddft.udf_template_id = udddf.udf_template_id 
WHERE
sdd.source_deal_detail_id=@source_deal_detail_id and uddft.Field_label='Adder'
set @price_multiplier=isnull(nullif(@price_multiplier,0),1)
--- convert price UOM to position UOM

SELECT @price_uom_multiplier = COALESCE(dm.conversion_factor,vuc.conversion_factor,1.0/vuc1.conversion_factor,1),@pricing_type = detail_pricing
FROM source_deal_header sdh 
INNER JOIN source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
	AND sdd.source_deal_detail_id=@source_deal_detail_id 
INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id
LEFT JOIN deal_uom_conversion_factor dm on sdd.source_deal_detail_id=dm.source_deal_detail_id
	AND COALESCE(dm.from_uom_id,spcd.uom_id)=spcd.uom_id 
	AND COALESCE(dm.to_uom_id,spcd.display_uom_id,spcd.uom_id)=ISNULL(spcd.display_uom_id,spcd.uom_id) 
LEFT JOIN rec_volume_unit_conversion vuc ON vuc.from_source_uom_id = spcd.uom_id
	AND vuc.to_source_uom_id = isnull(spcd.display_uom_id, spcd.uom_id)
LEFT JOIN rec_volume_unit_conversion vuc1 ON vuc1.from_source_uom_id =isnull(spcd.display_uom_id, spcd.uom_id)
	AND vuc1.to_source_uom_id =  spcd.uom_id



SELECT @formula_currency_id = spcd.source_currency_id
FROM source_deal_detail sdd
INNER JOIN user_defined_deal_detail_fields udddf ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
INNER JOIN user_defined_deal_fields_template uddft ON uddft.udf_template_id = udddf.udf_template_id 
INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=udddf.udf_value
WHERE
sdd.source_deal_detail_id=@source_deal_detail_id and uddft.field_id=@pricing_index


IF @pricing_type = 1610
BEGIN
	DECLARE @p_date DATETIME

	SELECT
		@p_date =COALESCE(sda.movement_date_time,mgd.estimated_movement_date,sdd.term_end)
		FROM					
			source_deal_detail sdd
			INNER JOIN user_defined_deal_detail_fields udddf ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
			INNER JOIN user_defined_deal_fields_template uddft	ON  uddft.udf_template_id = udddf.udf_template_id 
			OUTER APPLY(SELECT MAX(split_id) split_id,MIN(estimated_movement_date) estimated_movement_date FROM  match_group_detail
				WHERE source_deal_detail_id = sdd.source_deal_detail_id) mgd
			LEFT JOIN actual_match am ON am.deal_volume_split_id = mgd.split_id
			LEFT JOIN split_deal_actuals sda On sda.split_deal_actuals_id = am.split_deal_actuals_id
		WHERE
			sdd.source_deal_detail_id=@source_deal_detail_id


	SELECT @avg_curve_value = spc1.curve_value,@formula_curve_id=udddf.udf_value
	FROM
		source_deal_detail sdd
		INNER JOIN user_defined_deal_detail_fields udddf ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN user_defined_deal_fields_template uddft ON uddft.udf_template_id = udddf.udf_template_id AND uddft.field_id=@pricing_index
		OUTER APPLY( SELECT MAX(maturity_date) maturity_date,MAX(as_of_date) as_of_date FROM source_price_curve spc 
			WHERE source_curve_def_id = udddf.udf_value AND maturity_date<=case when isnull(@org_as_of_date,@p_date) <=@p_date then @org_as_of_date else @p_date end
		) spc
		LEFT JOIN source_price_curve spc1 ON spc1.source_curve_def_id = udddf.udf_value
			AND spc1.as_of_date = spc.as_of_date
			AND spc1.maturity_date = spc.maturity_date
		
	WHERE
		sdd.source_deal_detail_id=@source_deal_detail_id

	
	SELECT @price_uom_multiplier = COALESCE(dm.conversion_factor,vuc.conversion_factor,1.0/vuc1.conversion_factor,1)
	FROM source_deal_header sdh 
	INNER JOIN source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
		AND sdd.source_deal_detail_id=@source_deal_detail_id 
	cross join
	(select * from  source_price_curve_def  where source_curve_def_id=@formula_curve_id ) spcd 
	LEFT JOIN deal_uom_conversion_factor dm on sdd.source_deal_detail_id=dm.source_deal_detail_id
		AND COALESCE(dm.from_uom_id,spcd.uom_id)=spcd.uom_id 
		AND COALESCE(dm.to_uom_id,spcd.display_uom_id,spcd.uom_id)=ISNULL(spcd.display_uom_id,spcd.uom_id) 
	LEFT JOIN rec_volume_unit_conversion vuc ON vuc.from_source_uom_id =spcd.uom_id  
		AND vuc.to_source_uom_id = isnull(spcd.display_uom_id, spcd.uom_id)
	LEFT JOIN rec_volume_unit_conversion vuc1 ON vuc1.from_source_uom_id = isnull(spcd.display_uom_id, spcd.uom_id) 
		AND vuc1.to_source_uom_id = spcd.uom_id

	set @avg_curve_value=@avg_curve_value*(1.0/@price_uom_multiplier)

	return @avg_curve_value

END


if @id is not null --id is not @source_deal_detail_id
begin


	insert into @price_dates (curve_id,price_date)
	select [curve_id],[term_start] from dbo.FNAGetBLPricingTermRatio(-1*@id)

	--select @source_deal_detail_id
	---select * from @price_dates
	set @formula_currency_id =null

	select @pricing=sdh.pricing ,@formula_currency_id =wd.currency,@settlement_currency_id =sdd.settlement_currency
		,@func_currency_id= fs.func_cur_value_id,@source_deal_detail_id=sdd.source_deal_detail_id
	from source_deal_header sdh inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
	inner join wacog_fixed_price_deemed wd on  wd.source_deal_detail_id=sdd.source_deal_detail_id
		and wd.wacog_fixed_price_deemed_id=@id --and sdd.formula_currency_id<>sdd.settlement_currency
	INNER JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1=sdh.source_system_book_id1
	AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
	AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
	AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	INNER JOIN portfolio_hierarchy ph ON ph.entity_id = ssbm.fas_book_id
	INNER JOIN portfolio_hierarchy ph1 ON ph1.entity_id = ph.parent_entity_id
	INNER JOIN portfolio_hierarchy ph2 ON ph2.entity_id = ph1.parent_entity_id 
	INNER JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = ph2.entity_id

end
else
begin

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
	


	insert into @price_dates (curve_id,price_date)
	select [curve_id],[term_start] from dbo.FNAGetBLPricingTerm(@source_deal_detail_id,0)
end


--select * into #price_dates from @price_dates
--set @udf_fx_mult=null


 --settlement

	if NULLIF(@udf_fx_mult,0) is null 
	begin
		--set @formula_currency_id=2
		if @formula_currency_id<>@settlement_currency_id
		begin
		--1601 1600 Avg of curve and FX Avg of curve and FX NULL NULL NULL NULL Systrmtrackert 2011-06-22 14:56:57.947 Systrmtrackert 2011-06-22 14:56:57.953
		--1602 1600 Avg of curve and with FX 
			if isnull(@pricing,1601)=1601
				select @udf_fx_mult=avg(isnull(1.00/spc.curve_value,spc1.curve_value)) from @price_dates dt
				LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = dt.curve_id 
				left join source_price_curve_def fx_curve ON fx_curve.source_currency_id = @formula_currency_id and
				fx_curve.source_currency_to_id = @settlement_currency_id 
				left join source_price_curve spc1 ON spc1.source_curve_def_id=fx_curve.source_curve_def_id AND spc1.as_of_date = dt.price_date and spc1.maturity_date = spc1.as_of_date
				left join source_price_curve_def fx_curve1 ON fx_curve1.source_currency_id = @settlement_currency_id and
				fx_curve1.source_currency_to_id =@formula_currency_id AND spc1.source_curve_def_id = fx_curve1.source_curve_def_id
				left join source_price_curve spc ON spc.as_of_date = dt.price_date and spc.maturity_date = spc.as_of_date AND spc.source_curve_def_id = fx_curve1.source_curve_def_id
			else if @pricing=1602
				insert into @fx_value (fx_date ,fx_value )
				select dt.price_date,isnull(1.00/spc.curve_value,spc1.curve_value) curve_value from @price_dates dt
				LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = dt.curve_id 
				left join source_price_curve_def fx_curve ON fx_curve.source_currency_id = @formula_currency_id and
				fx_curve.source_currency_to_id = @settlement_currency_id 
				left join source_price_curve spc1 ON spc1.source_curve_def_id=fx_curve.source_curve_def_id AND spc1.as_of_date = dt.price_date and spc1.maturity_date = spc1.as_of_date
				left join source_price_curve_def fx_curve1 ON fx_curve1.source_currency_id = @settlement_currency_id and
				fx_curve1.source_currency_to_id =@formula_currency_id AND spc1.source_curve_def_id = fx_curve1.source_curve_def_id
				left join source_price_curve spc ON spc.as_of_date = dt.price_date and spc.maturity_date = spc.as_of_date AND spc.source_curve_def_id = fx_curve1.source_curve_def_id
		end
	end
	
	IF @pricing_type = 1609
	BEGIN
	
		insert into @price_value (typ ,price_date ,val )
				SELECT 's',pd.price_date,
					(spc1.curve_value*isnull(fv.fx_value,1)*isnull(@price_multiplier,1)+ISNULL(@udf_adder,0))*isnull(NULLIF(@udf_fx_mult,0),1)*(1/@price_uom_multiplier)
				FROM 
				@price_dates pd
				INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = pd.curve_id
				left JOIN source_price_curve spc1 ON spc1.source_curve_def_id = isnull(spcd.settlement_curve_id,spcd.source_curve_def_id) 
				AND spc1.as_of_date = pd.price_date and @as_of_date is null and spc1.as_of_date <=@org_as_of_date
				left join @fx_value fv on pd.price_date=fv.fx_date AND fv.fx_value IS NOT NULL
	
	END
	ELSE
	BEGIN
	insert into @price_value (typ ,price_date ,val )
	SELECT 's',pd.price_date,
		(spc1.curve_value*isnull(fv.fx_value,1)*isnull(@price_multiplier,1)+ISNULL(@udf_adder,0))*isnull(NULLIF(@udf_fx_mult,0),1)*(1/@price_uom_multiplier)
	FROM 
	@price_dates pd
	INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = pd.curve_id
	left JOIN source_price_curve spc1 ON spc1.source_curve_def_id = isnull(spcd.settlement_curve_id,spcd.source_curve_def_id) AND spc1.as_of_date = pd.price_date
			AND spc1.maturity_date = pd.price_date and spc1.as_of_date <=@org_as_of_date
	left join @fx_value fv on pd.price_date=fv.fx_date AND fv.fx_value IS NOT NULL
	END 		
	if @org_as_of_date is null
	begin
		SELECT @avg_curve_value = avg(val) from @price_value where val is not null
	end
	else
	begin
		

	 --run for mtm

		set @as_of_date=@org_as_of_date
	
	
		insert into @price_value_f (typ ,price_date ,val )
		SELECT 'm',pd.price_date,
		((coalesce(spc.curve_value,spc2.curve_value,spc3.curve_value,spc4.curve_value)+ @curve_shift_val) * @curve_shift_per
		*isnull(@price_multiplier,1)+ISNULL(@udf_adder,0) * COALESCE(1.00/spc6.curve_value,spc5.curve_value,1) )*(1.0/@price_uom_multiplier)
		-- price_date,spc1.curve_value,spc.curve_value,spc2.curve_value,spc3.curve_value,spc4.curve_value 
		FROM 
			@price_dates pd
			INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = pd.curve_id and pd.price_date>@as_of_date
			LEFT JOIN source_price_curve_def spcd2 ON spcd.proxy_source_curve_def_id=spcd2.source_curve_def_id
			LEFT JOIN source_price_curve_def spcd3 ON spcd.monthly_index=spcd3.source_curve_def_id
			LEFT JOIN source_price_curve_def spcd4 ON spcd.proxy_curve_id3=spcd4.source_curve_def_id
			cross apply (
			select price_date [Maturity_hr]
			,cast(convert(varchar(8),price_date,120)+'01' as date) [Maturity_mnth]
			,cast(convert(varchar(5),price_date,120)+ cast(case datepart(q, price_date) when 1 then 1 when 2 then 4 when 3 then 7 when 4 then 10 end as varchar)+'-01' as date) [Maturity_qtr] 
			,cast(convert(varchar(5),price_date,120)+ cast(case when month(price_date) < 7 then 1 else 7 end as varchar)+'-01' as date) [Maturity_semi] 
			,cast(convert(varchar(5),price_date,120)+ '01-01' as date) [Maturity_yr]
			) m 
			left JOIN source_price_curve spc ON spc.source_curve_def_id = spcd.source_curve_def_id AND spc.as_of_date = @as_of_date
			AND spc.maturity_date = case spcd.Granularity when 982 then m.maturity_hr when 981 then pd.price_date when 980 then m.maturity_mnth
			when 991 then m.maturity_qtr when 992 then m.maturity_semi when 993 then m.maturity_yr end 
			left JOIN source_price_curve spc2 ON spc2.source_curve_def_id = spcd.proxy_source_curve_def_id AND spc2.as_of_date = @as_of_date
			AND spc2.maturity_date = case spcd2.Granularity when 982 then m.maturity_hr when 981 then pd.price_date when 980 then m.maturity_mnth
			when 991 then m.maturity_qtr when 992 then m.maturity_semi when 993 then m.maturity_yr end 
			left JOIN source_price_curve spc3 ON spc3.source_curve_def_id = spcd.monthly_index AND spc3.as_of_date = @as_of_date
			AND spc3.maturity_date = case spcd3.Granularity when 982 then m.maturity_hr when 981 then pd.price_date when 980 then m.maturity_mnth
			when 991 then m.maturity_qtr when 992 then m.maturity_semi when 993 then m.maturity_yr end 
			left JOIN source_price_curve spc4 ON spc4.source_curve_def_id = spcd.proxy_curve_id3 AND spc4.as_of_date = @as_of_date
			AND spc4.maturity_date = case spcd4.Granularity when 982 then m.maturity_hr when 981 then pd.price_date when 980 then m.maturity_mnth
			when 991 then m.maturity_qtr when 992 then m.maturity_semi when 993 then m.maturity_yr end 
			left join source_price_curve_def fx_curve ON fx_curve.source_currency_id = @formula_currency_id and
			fx_curve.source_currency_to_id = @func_currency_id AND fx_curve.Granularity=980
			left join source_price_curve spc5 ON spc5.source_curve_def_id=fx_curve.source_curve_def_id AND spc5.as_of_date =@as_of_date 
			and spc5.maturity_date = case COALESCE(spcd2.Granularity,spcd2.Granularity,spcd3.Granularity,spcd4.Granularity) when 982 then m.maturity_hr when 981 then pd.price_date when 980 then m.maturity_mnth
			when 991 then m.maturity_qtr when 992 then m.maturity_semi when 993 then m.maturity_yr end 
			left join source_price_curve_def fx_curve1 ON fx_curve1.source_currency_id = @func_currency_id and
			fx_curve1.source_currency_to_id =@formula_currency_id AND fx_curve1.Granularity=980 
			left join source_price_curve spc6 ON spc6.source_curve_def_id = fx_curve1.source_curve_def_id AND spc6.as_of_date = @as_of_date 
			AND spc6.maturity_date = case COALESCE(spcd2.Granularity,spcd2.Granularity,spcd3.Granularity,spcd4.Granularity) when 982 then m.maturity_hr when 981 then pd.price_date when 980 then m.maturity_mnth
			when 991 then m.maturity_qtr when 992 then m.maturity_semi when 993 then m.maturity_yr end
	


	 end
	 --select * from @price_value


	
	 SELECT @avg_curve_value = avg(val) from
	 (
	  select price_date,val from  @price_value where val is not null  ---and price_date<=@as_of_date
	  union all
		 select f.price_date,f.val from  @price_value_f f left join @price_value s on f.price_date=s.price_date and s.val is not null
			--and s.price_date<=@as_of_date
			where --s.price_date is null and 
			f.val is not null

	) v

	return (@avg_curve_value)
end

	 --select price_date,val from  @price_value where val is not null  --and price_date<=@as_of_date
	 ---- union all
		-- select f.price_date,f.val from  @price_value_f f left join @price_value s on f.price_date=s.price_date and s.val is not null
		----	and s.price_date<=@as_of_date
		--	where s.price_date is null and f.val is not null
