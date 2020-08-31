/****** Object:  UserDefinedFunction [dbo].[FNARawLagcurve]    Script Date: 07/24/2011 21:41:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARawLagcurve]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARawLagcurve]
GO

/****** Object:  UserDefinedFunction [dbo].[FNARCLagcurve]    Script Date: 07/21/2011 16:28:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNARawLagcurve](
	@Delivery_date DATETIME,
	@as_of_date DATETIME,
	@curve_source_id INT,
	@contract_id INT ,
	@curve_Id INT,
	@pricing_option int, -- 0  Monthly Avg with Avg FX conversion, 1  Monthly Avg with actual FX conversion, 2  All months avg with avg FX conversion,3 All months avg with with actual FX conversion
	@Strip_Month_From INT, --(i.e., 6)
	@Lag_Months INT, --(i.e., 2)
	@Strip_Month_To INT --(i.e., 6)
	)

RETURNS FLOAT 
AS
BEGIN

	
/*
DECLARE @Delivery_date DATETIME
,@as_of_date DATETIME
,@curve_Id INT
,@pricing_option int --( could be 0 or negative values. Negative value will use the prior year values)
,@Convert_to_currency INT -- (if passed null then don’t convert)
,@Strip_Month_From INT --(i.e., 6)
,@Lag_Months INT --(i.e., 2)
,@Strip_Month_To INT --(i.e., 6)
,@curve_source_id int
,@price_adder FLOAT
,@volume_multiplier FLOAT
,@expiration_type VARCHAR(30)
,@expiration_value VARCHAR(30)
,@contract_id INT 


SET @Delivery_date ='2011-06-01'
SET @as_of_date= '2011-06-30'
SET @curve_Id =97
SET @pricing_option =0	  --( could be 0 or negative values. Negative value will use the prior year values)
SET @Convert_to_currency =2 -- (if passed null then don’t convert)
SET @Strip_Month_From =0 --(i.e., 6)
SET @Lag_Months =0 --(i.e., 2)
SET @Strip_Month_To =1 --(i.e., 6)
SET @curve_source_id=4500
SET @price_adder=0
SET @volume_multiplier=1
SET @contract_id =1
--*/


DECLARE @ret_val float
DECLARE @calc_avg_method INT -- 1 Monhtly average calculations, 0- Average calculations
SET @calc_avg_method = 1
DECLARE @index_round_value INT ,@fx_round_value INT,@total_round_value INT ,  @mid bit,@bid_ask_round_value INT
DECLARE @settlement_curve_id INT,@final_round_value INT		,@lag_round_value INT


DECLARE @settle_date DATETIME,@settle BIT

SET @settle_date=dateadd(MONTH,1,cast(convert(varchar(8),@as_of_date,120)+'01' AS DATETIME))-1

IF @settle_date<>@as_of_date
	SET @settle_date=cast(convert(varchar(8),@as_of_date,120)+'01' AS DATETIME)-1
		
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
	
--select @settle

IF @settle=1
	SELECT @ret_val=round(org_mid_value, isnull(@index_round_value, 20))
	from cached_curves_value v INNER JOIN cached_curves c ON c.rowid=v.Master_ROWID
	WHERE  v.term=@Delivery_date AND v.curve_source_id=@curve_source_id
		and c.Strip_Month_From=@Strip_Month_From AND c.Lag_Months=@Lag_Months AND c.Strip_Month_To=@Strip_Month_To 
		AND v.pricing_option=@pricing_option AND c.curve_id=@curve_Id
		AND isnull(index_round_value,-1)=isnull(@index_round_value,-1) AND
		   isnull(fx_round_value,-1)=isnull(@fx_round_value,-1)
		 AND isnull(total_round_value,-1)=isnull(@total_round_value,-1)
		  AND isnull(bid_ask_round_value,-1)=isnull(@bid_ask_round_value,-1)
		 AND v.value_type= 's'
		
ELSE
	SELECT @ret_val=round(org_mid_value, isnull(@index_round_value, 20))
		from cached_curves_value v INNER JOIN cached_curves c ON c.rowid=v.Master_ROWID
		WHERE  v.term=@Delivery_date AND v.curve_source_id=@curve_source_id
			and c.Strip_Month_From=@Strip_Month_From AND c.Lag_Months=@Lag_Months AND c.Strip_Month_To=@Strip_Month_To 
			AND v.pricing_option=@pricing_option AND c.curve_id=@curve_Id
			AND isnull(index_round_value,-1)=isnull(@index_round_value,-1) AND
			   isnull(fx_round_value,-1)=isnull(@fx_round_value,-1)
			 AND isnull(total_round_value,-1)=isnull(@total_round_value,-1)
			  AND isnull(bid_ask_round_value,-1)=isnull(@bid_ask_round_value,-1)
			 AND v.value_type= 'f' 	AND  v.as_of_date= @as_of_date 	
	


--select @ret_val

  RETURN @ret_val
      


	
END
	
