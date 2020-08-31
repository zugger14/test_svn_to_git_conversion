

IF OBJECT_ID('FNAPartialAvgCurve') IS NOT NULL
DROP FUNCTION  [dbo].[FNAPartialAvgCurve]
GO

/****** Object:  UserDefinedFunction [dbo].[FNAPartialAvgCurve]    Script Date: 07/17/2011 12:33:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAPartialAvgCurve](
		@Delivery_date_from DATETIME,
		@Delivery_date_to DATETIME,
		@as_of_date DATETIME,
		@curve_source_id INT,
		@contract_id INT,
		@curve_Id INT,
		@Convert_to_currency INT
)
RETURNS FLOAT 
AS
BEGIN

/*
-- select dbo.FNAPartialAvgCurve ('2011-10-10', '2011-10-31', '2011-10-31', 4500, 1, 92, 2)
DECLARE @Delivery_date_from DATETIME = '2011-07-07',
		@Delivery_date_to DATETIME = '2011-07-09',
		@as_of_date DATETIME = '2011-07-06',
		@curve_source_id INT = 4500,
		@contract_id INT ,
		@curve_Id INT = 92,
		@Convert_to_currency INT = 2
--*/	

DECLARE @baseload_block_define_id INT, @set_value FLOAT, @set_no_prices INT, @total_days INT, @for_value FLOAT, @for_no_prices INT,
		@fx_curve_id INT, @op VARCHAR(1),
		@fx_set_value FLOAT, @fx_set_no_prices INT, @fx_for_value FLOAT, @fx_for_no_prices INT

SELECT @baseload_block_define_id = value_id FROM static_data_value WHERE [type_id] = 10018 AND code LIKE 'Base Load' -- External Static Data
	
select	@fx_curve_id = MAX(CASE WHEN (f.source_curve_def_id IS NOT NULL) THEN f.source_curve_def_id ELSE f2.source_curve_def_id END) ,
		@op = MAX(CASE WHEN (f.source_curve_def_id IS NOT NULL) THEN 'm' ELSE 'd' END)
		from source_price_curve_def  s LEFT JOIN
		source_price_curve_def f ON f.source_currency_id = s.source_currency_id and f.source_currency_to_id = @Convert_to_currency LEFT JOIN
		source_price_curve_def f2 ON f2.source_currency_to_id = s.source_currency_id and f2.source_currency_id = @Convert_to_currency 
	
	
SELECT @total_days = DATEDIFF(DD, @Delivery_date_from, 	@Delivery_date_to) + 1
	
--GET CURVE VALUE ON THE PRIMARY CURVE	
select @set_value = AVG(spc.curve_value) --, @set_no_prices = count(spc.curve_value) 
from source_price_curve_def spcd1  INNER JOIN 
hour_block_term h ON h.block_type=12000 AND h.block_define_id =@baseload_block_define_id
	AND term_date BETWEEN @Delivery_date_from AND @Delivery_date_to 
	AND term_date <= @as_of_date
LEFT  JOIN source_price_curve_def spcd2 ON spcd1.settlement_curve_id=spcd2.source_curve_def_id
LEFT JOIN source_price_curve spc ON spc.source_curve_def_id = ISNULL(spcd2.source_curve_def_id, spcd1.source_curve_def_id)
	AND spc.as_of_date = h.term_date and spc.curve_source_value_id = @curve_source_id AND
	spc.maturity_date = h.term_date
where spcd1.source_curve_def_id=@curve_id	

--NOW GET FX CURVE
If @fx_curve_id IS NOT NULL 
BEGIN
	select @fx_set_value = AVG(spc.curve_value) --, @fx_set_no_prices = count(spc.curve_value) 
	from source_price_curve_def spcd1  INNER JOIN 
	hour_block_term h ON h.block_type=12000 AND h.block_define_id =@baseload_block_define_id
		AND term_date BETWEEN @Delivery_date_from AND @Delivery_date_to 
		AND term_date <= @as_of_date
	LEFT  JOIN source_price_curve_def spcd2 ON spcd1.settlement_curve_id=spcd2.source_curve_def_id
	LEFT JOIN source_price_curve spc ON spc.source_curve_def_id = ISNULL(spcd2.source_curve_def_id, spcd1.source_curve_def_id)
		AND spc.as_of_date = h.term_date and spc.curve_source_value_id = @curve_source_id AND
		spc.maturity_date = h.term_date
	where spcd1.source_curve_def_id=@fx_curve_id	

END

DECLARE @index_round_value FLOAT, @fx_round_value FLOAT, @total_round_value FLOAT,
		@avg_curve_value FLOAT, @avg_fx_curve_value FLOAT

SELECT @index_round_value=index_round_value,
	   @fx_round_value=fx_round_value,
	   @total_round_value=total_round_value
FROM
	contract_formula_rounding_options
WHERE
	contract_id=@contract_id
	AND curve_id=@curve_id

SET @avg_curve_value = ROUND(isnull(@set_value, 0), ISNULL(@index_round_value, 100))
SET @fx_set_value = ROUND(@fx_set_value, ISNULL(@fx_round_value, 100))
SET @avg_fx_curve_value = ISNULL( CASE @op WHEN 'm' THEN (isnull(@fx_set_value, 0)) ELSE 1/NULLIF((isnull(@fx_set_value, 0)),0) END, 1)

RETURN  ROUND(@avg_curve_value * @avg_fx_curve_value, ISNULL(@total_round_value, 100))
		

END

