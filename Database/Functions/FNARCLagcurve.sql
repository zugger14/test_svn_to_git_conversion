IF OBJECT_ID('FNARCLagcurve') IS NOT NULL
DROP FUNCTION  [dbo].[FNARCLagcurve]
GO

/****** Object:  UserDefinedFunction [dbo].[FNARCLagcurve]    Script Date: 07/17/2011 12:33:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Description

	Parameters
    @Delivery_date : Delivery Date
    @as_of_date : As Of Date
    @curve_source_id : Curve Source Id
    @contract_id : Contract Id
    @curve_Id : Curve Id
    @pricing_option : Pricing Option
    @Strip_Month_From : Strip Month From
    @Lag_Months : Lag Months
    @Strip_Month_To : Strip Month To
    @Convert_to_currency : Convert To Currency
    @price_adder : Price Adder
    @volume_multiplier : Volume Multiplier
    @expiration_type : Expiration Type
    @expiration_value : Expiration Value
    @curve_shift_val : Curve Shift Val
    @curve_shift_per : Curve Shift Per
*/

CREATE FUNCTION [dbo].[FNARCLagcurve](
	@Delivery_date DATETIME,
	@as_of_date DATETIME,
	@curve_source_id INT,
	@contract_id INT ,
	@curve_Id INT,
	@pricing_option int, -- 0  Monthly Avg with Avg FX conversion, 1  Monthly Avg with actual FX conversion, 2  All months avg with avg FX conversion,3 All months avg with with actual FX conversion
	@Strip_Month_From INT, --(i.e., 6)
	@Lag_Months INT, --(i.e., 2)
	@Strip_Month_To INT, --(i.e., 6)
	@Convert_to_currency INT=null, -- (if passed null then don’t convert)
	@price_adder FLOAT,
	@volume_multiplier FLOAT,
	@expiration_type VARCHAR(30), --1=Exact date, 2=relative to end of month, 3=relative to end of month business days, 4=relative to expiration date,5= relative to expiration date business days
	@expiration_value VARCHAR(30)
,@curve_shift_val float ,@curve_shift_per float
)
RETURNS FLOAT 
AS
BEGIN

	
/*
DECLARE @Delivery_date DATETIME='2021-01-01',
	@as_of_date DATETIME='2018-01-15',
	@curve_source_id INT=4500,
	@contract_id INT =8210,
	@curve_Id INT=7248,
	@pricing_option int=0, -- 0  Monthly Avg with Avg FX conversion, 1  Monthly Avg with actual FX conversion, 2  All months avg with avg FX conversion,3 All months avg with with actual FX conversion
	@Strip_Month_From INT=0, --(i.e., 6)
	@Lag_Months INT=0, --(i.e., 2)
	@Strip_Month_To INT=12, --(i.e., 6)
	@Convert_to_currency INT=1109, -- (if passed null then don’t convert)
	@price_adder FLOAT=0,
	@volume_multiplier FLOAT=0.8429,
	@expiration_type VARCHAR(30), --1=Exact date, 2=relative to end of month, 3=relative to end of month business days, 4=relative to expiration date,5= relative to expiration date business days
	@expiration_value VARCHAR(30)
,@curve_shift_val float ,@curve_shift_per float



--*/


DECLARE @ret_val float
DECLARE @calc_avg_method INT -- 1 Monhtly average calculations, 0- Average calculations
SET @calc_avg_method = 1
DECLARE @index_round_value INT ,@fx_round_value INT,@total_round_value INT ,  @mid bit,@bid_ask_round_value INT
DECLARE @settlement_curve_id INT,@final_round_value INT		,@lag_round_value INT


select @curve_shift_val=isnull(@curve_shift_val,0),@curve_shift_per=isnull(@curve_shift_per,1)


DECLARE @settle_date DATETIME,@settle BIT

SET @settle_date=dateadd(MONTH,1,cast(convert(varchar(8),@as_of_date,120)+'01' AS DATETIME))-1

IF @settle_date<>@as_of_date
	SET @settle_date=cast(convert(varchar(8),@as_of_date,120)+'01' AS DATETIME)-1
		
--Convert delivery date to always first day of the month
SET @Delivery_date = cast(convert(varchar(8),@Delivery_date,120)+'01' AS DATETIME)		
		
SET @settle=0
IF @Delivery_date <= @settle_date
	SET @settle=1

SELECT @index_round_value=index_round_value,
	   @fx_round_value=fx_round_value,
	   @total_round_value=total_round_value, @mid= case when (@settle =1) then set_mid else mid end,
		@bid_ask_round_value=bid_ask_round_value
		,@final_round_value=final_round_value
		,@lag_round_value=lag_round_value
FROM
	contract_formula_rounding_options
WHERE
	contract_id=@contract_id
	AND curve_id=@curve_id
	
	
	
IF @price_adder IS NULL
	SET @price_adder=0

IF @volume_multiplier IS NULL
	SET @volume_multiplier=1
	
set @ret_val=null
If @expiration_type IS NOT NULL AND @expiration_value IS NOT NULL
BEGIN
	DECLARE @expiration_date datetime, @maturity_date datetime, @expired varchar(1)
	set @expiration_date = dbo.[FNARelativeExpirationDate](@Delivery_date, @curve_Id,0 ,@expiration_type,@expiration_value)
	
	-- IF EXPIRATION DATE NOT FOUND THERE IS A CALENDAR ISSUE
	If @expiration_date IS NULL
		RETURN NULL
		
	set @maturity_date = @Delivery_date	
	set @expired = 'n'
	
	If @expiration_date <= @as_of_date
	BEGIN
		set @as_of_date = @expiration_date
		set @expired = 'y'
		
		select @ret_val =	(spc.curve_value+ @curve_shift_val) * @curve_shift_per
		from source_price_curve_def spcd 
			LEFT JOIN				
			 source_price_curve spc ON 
				spcd.settlement_curve_id = spc.source_curve_def_id and
				spc.curve_source_value_id=4500 and 
				spc.as_of_date = @as_of_date and 
				spc.assessment_curve_type_value_id in (77,78) and 
				spc.maturity_date = 
					CASE WHEN spcd.Granularity =980 THEN CONVERT(varchar(8),@maturity_date,120) + '01'
						 WHEN spcd.Granularity =981 THEN @maturity_date
						 WHEN spcd.Granularity =991 THEN cast(Year(@maturity_date) as varchar) + '-' + cast(case datepart(q, @maturity_date) when 1 then 1 when 2 then 4 when 3 then 7 else 10 end as varchar) + '-01'
						 WHEN spcd.Granularity=993 THEN cast(Year(@maturity_date) as varchar) + '-01-01' 
					ELSE @maturity_date END		
		where 	spcd.source_curve_def_id = @curve_id		
		
		if @ret_val is  null
			select @ret_val =	(spc.curve_value+ @curve_shift_val) * @curve_shift_per
			from source_price_curve_def spcd 
				LEFT JOIN	source_price_curve spc ON 
					spcd.source_curve_def_id = spc.source_curve_def_id and
					spc.curve_source_value_id=4500 and 
					spc.as_of_date = @as_of_date and 
					spc.assessment_curve_type_value_id in (77,78) and 
					spc.maturity_date = 
						CASE WHEN spcd.Granularity =980 THEN CONVERT(varchar(8),@maturity_date,120) + '01'
							 WHEN spcd.Granularity =981 THEN @maturity_date
							 WHEN spcd.Granularity =991 THEN cast(Year(@maturity_date) as varchar) + '-' + cast(case datepart(q, @maturity_date) when 1 then 1 when 2 then 4 when 3 then 7 else 10 end as varchar) + '-01'
							 WHEN spcd.Granularity=993 THEN cast(Year(@maturity_date) as varchar) + '-01-01' 
						ELSE @maturity_date END		
			where 	spcd.source_curve_def_id = @curve_id	
		
	END
	
	else
	begin
	
		if exists(select 1 from source_price_curve_def where source_curve_def_id = @curve_id and settlement_curve_id is not null)
		begin

			if @ret_val is  null
				select @ret_val =	(spc.curve_value+ @curve_shift_val) * @curve_shift_per
				from source_price_curve_def spcd 
					LEFT JOIN				
					 source_price_curve spc ON 
						spcd.source_curve_def_id = spc.source_curve_def_id and
						spc.curve_source_value_id=4500 and 
						spc.as_of_date = @as_of_date and 
						spc.assessment_curve_type_value_id in (77,78) and 
						spc.maturity_date = 
							CASE WHEN spcd.Granularity =980 THEN CONVERT(varchar(8),@maturity_date,120) + '01'
								 WHEN spcd.Granularity =981 THEN @maturity_date
								 WHEN spcd.Granularity =991 THEN cast(Year(@maturity_date) as varchar) + '-' + cast(case datepart(q, @maturity_date) when 1 then 1 when 2 then 4 when 3 then 7 else 10 end as varchar) + '-01'
								 WHEN spcd.Granularity=993 THEN cast(Year(@maturity_date) as varchar) + '-01-01' 
							ELSE @maturity_date END		
				where 	spcd.source_curve_def_id = @curve_id
		
		end
		
		
		if @ret_val is  null
			select @ret_val =	(spc.curve_value+ @curve_shift_val) * @curve_shift_per
			from source_price_curve_def spcd 
				LEFT JOIN				
				 source_price_curve spc ON 
					spcd.proxy_source_curve_def_id = spc.source_curve_def_id and
					spc.curve_source_value_id=4500 and 
					spc.as_of_date = @as_of_date and 
					spc.assessment_curve_type_value_id in (77,78) and 
					spc.maturity_date = 
						CASE WHEN spcd.Granularity =980 THEN CONVERT(varchar(8),@maturity_date,120) + '01'
							 WHEN spcd.Granularity =981 THEN @maturity_date
							 WHEN spcd.Granularity =991 THEN cast(Year(@maturity_date) as varchar) + '-' + cast(case datepart(q, @maturity_date) when 1 then 1 when 2 then 4 when 3 then 7 else 10 end as varchar) + '-01'
							 WHEN spcd.Granularity=993 THEN cast(Year(@maturity_date) as varchar) + '-01-01' 
						ELSE @maturity_date END		
			where 	spcd.source_curve_def_id = @curve_id

		
		if @ret_val is  null
			select @ret_val =	(spc.curve_value+ @curve_shift_val) * @curve_shift_per
			from source_price_curve_def spcd 
				LEFT JOIN source_price_curve spc ON 
					spcd.monthly_index= spc.source_curve_def_id  and
					spc.curve_source_value_id=4500 and 
					spc.as_of_date = @as_of_date and 
					spc.assessment_curve_type_value_id in (77,78) and 
					spc.maturity_date = 
						CASE WHEN spcd.Granularity =980 THEN CONVERT(varchar(8),@maturity_date,120) + '01'
							 WHEN spcd.Granularity =981 THEN @maturity_date
							 WHEN spcd.Granularity =991 THEN cast(Year(@maturity_date) as varchar) + '-' + cast(case datepart(q, @maturity_date) when 1 then 1 when 2 then 4 when 3 then 7 else 10 end as varchar) + '-01'
							 WHEN spcd.Granularity=993 THEN cast(Year(@maturity_date) as varchar) + '-01-01' 
						ELSE @maturity_date END		
			where 	spcd.source_curve_def_id = @curve_id
		
		if @ret_val is  null
			select @ret_val =	(spc.curve_value+ @curve_shift_val) * @curve_shift_per
			from source_price_curve_def spcd 
				LEFT JOIN source_price_curve spc ON 
					spcd.proxy_curve_id3 = spc.source_curve_def_id and
					spc.curve_source_value_id=4500 and 
					spc.as_of_date = @as_of_date and 
					spc.assessment_curve_type_value_id in (77,78) and 
					spc.maturity_date = 
						CASE WHEN spcd.Granularity =980 THEN CONVERT(varchar(8),@maturity_date,120) + '01'
							 WHEN spcd.Granularity =981 THEN @maturity_date
							 WHEN spcd.Granularity =991 THEN cast(Year(@maturity_date) as varchar) + '-' + cast(case datepart(q, @maturity_date) when 1 then 1 when 2 then 4 when 3 then 7 else 10 end as varchar) + '-01'
							 WHEN spcd.Granularity=993 THEN cast(Year(@maturity_date) as varchar) + '-01-01' 
						ELSE @maturity_date END		
			where 	spcd.source_curve_def_id = @curve_id
		
	end
		
		
		
	IF (isnull(@price_adder,0) <>  0)
		set @ret_val = round(round(@ret_val, isnull(@index_round_value, 20))*@price_adder, isnull(@total_round_value,20))

	RETURN round(ROUND(@ret_val, isnull(@final_round_value, 20)) *ISNULL(@volume_multiplier,1),isnull(@lag_round_value,20))
      

		
END

--select @settle

IF @settle=1
	SELECT @ret_val=(CASE WHEN isnull(@mid,1)=1 THEN curve_value ELSE bid_ask_curve_value END + @curve_shift_val) * @curve_shift_per
	from cached_curves_value v INNER JOIN cached_curves c ON c.rowid=v.Master_ROWID
	WHERE  v.term=@Delivery_date AND v.curve_source_id=@curve_source_id
		and c.Strip_Month_From=@Strip_Month_From AND c.Lag_Months=@Lag_Months AND c.Strip_Month_To=@Strip_Month_To 
		AND v.pricing_option=@pricing_option AND c.curve_id=@curve_Id
		AND isnull(index_round_value,-1)=coalesce(@index_round_value,index_round_value,-1) 
		AND isnull(fx_round_value,-1)=coalesce(@fx_round_value,fx_round_value,-1)
		AND isnull(total_round_value,-1)=coalesce(@total_round_value,total_round_value,-1)
		AND isnull(bid_ask_round_value,-1)=coalesce(@bid_ask_round_value,bid_ask_round_value,-1)
		 AND v.value_type= 's'
		 --AND isnull(c.expiration_type, '') = isnull(@expiration_type, '')
		 --AND isnull(c.expiration_value, '') = isnull(@expiration_value, '')
		 
ELSE
	SELECT @ret_val=(CASE WHEN isnull(@mid,1)=1 THEN curve_value ELSE bid_ask_curve_value END + @curve_shift_val) * @curve_shift_per
		from cached_curves_value v INNER JOIN cached_curves c ON c.rowid=v.Master_ROWID
		WHERE  v.term=@Delivery_date AND v.curve_source_id=@curve_source_id
			and c.Strip_Month_From=@Strip_Month_From AND c.Lag_Months=@Lag_Months AND c.Strip_Month_To=@Strip_Month_To 
			AND v.pricing_option=@pricing_option AND c.curve_id=@curve_Id
			AND isnull(index_round_value,-1)=coalesce(@index_round_value,index_round_value,-1) AND
			   isnull(fx_round_value,-1)=coalesce(@fx_round_value,fx_round_value,-1)
			 AND isnull(total_round_value,-1)=coalesce(@total_round_value,total_round_value,-1)
			  AND isnull(bid_ask_round_value,-1)=coalesce(@bid_ask_round_value,bid_ask_round_value,-1)
			 AND v.value_type= 'f' 	AND  v.as_of_date= @as_of_date 	
			 --AND isnull(c.expiration_type, '') = isnull(@expiration_type, '')
			 --AND isnull(c.expiration_value, '') = isnull(@expiration_value, '')
	


--select @ret_val
IF (isnull(@price_adder,0) <>  0)
	set @ret_val = round(@ret_val*@price_adder, isnull(@total_round_value,12))

  RETURN round(ROUND(@ret_val, isnull(@final_round_value, 12)) *ISNULL(@volume_multiplier,1),isnull(@lag_round_value,12))
      


	
END
	
	
  
