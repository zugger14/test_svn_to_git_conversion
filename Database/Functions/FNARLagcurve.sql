/****** Object:  UserDefinedFunction [dbo].[FNARLagcurve]    Script Date: 06/30/2009 18:13:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARLagcurve]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARLagcurve]
/****** Object:  UserDefinedFunction [dbo].[FNARLagcurve]    Script Date: 06/30/2009 18:13:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNARLagcurve](
	@Delivery_date DATETIME,
	@as_of_date DATETIME,
	@curve_source_id INT,
	@contract_id INT ,
	@curve_Id INT,
	@pricing_option int, -- 0  Monthly Avg with Avg FX conversion, 1  Monthly Avg with actual FX conversion, 2  All months avg with avg FX conversion,3 All months avg with with actual FX conversion
	@Strip_Month_From TINYINT, --(i.e., 6)
	@Lag_Months tinyint, --(i.e., 2)
	@Strip_Month_To TINYINT, --(i.e., 6)
	@Convert_to_currency INT=null, -- (if passed null then don’t convert)
	@price_adder FLOAT,
	@volume_multiplier FLOAT,
	@expiration_type VARCHAR(30), --1=Exact date, 2=relative to end of month, 3=relative to end of month business days, 4=relative to expiration date,5= relative to expiration date business days
	@expiration_value VARCHAR(30)

)
RETURNS float
AS
BEGIN

	


/*
DECLARE @Delivery_date DATETIME
,@as_of_date DATETIME
,@curve_Id INT
,@pricing_option int --( could be 0 or negative values. Negative value will use the prior year values)
,@Convert_to_currency INT -- (if passed null then don’t convert)
,@Strip_Month_From TINYINT --(i.e., 6)
,@Lag_Months tinyint --(i.e., 2)
,@Strip_Month_To TINYINT --(i.e., 6)
,@curve_source_id int
,@price_adder FLOAT
,@volume_multiplier FLOAT
,@expiration_type VARCHAR(30)
,@expiration_value VARCHAR(30)
,@contract_id INT 

SET @Delivery_date ='2011-05-01'
SET @as_of_date= '2011-06-30'
SET @curve_Id =97
SET @pricing_option =0	  --( could be 0 or negative values. Negative value will use the prior year values)
SET @Convert_to_currency =2 -- (if passed null then don’t convert)
SET @Strip_Month_From =0 --(i.e., 6)
SET @Lag_Months =0 --(i.e., 2)
SET @Strip_Month_To =1 --(i.e., 6)
SET @curve_source_id=4500
SET @price_adder=0
SET @volume_multiplier=0.2304
SET @contract_id =1
--*/


DECLARE @ret_val float
DECLARE @calc_avg_method INT -- 1 Monhtly average calculations, 0- Average calculations
SET @calc_avg_method = 1
DECLARE @index_round_value INT,@fx_round_value INT,@total_round_value INT
DECLARE @settlement_curve_id INT
SELECT @index_round_value=index_round_value,
	   @fx_round_value=fx_round_value,
	   @total_round_value=total_round_value
FROM
	contract_formula_rounding_options
WHERE
	contract_id=@contract_id
	AND curve_id=@curve_id
	

IF @price_adder IS NULL
	SET @price_adder=0

IF @volume_multiplier IS NULL
	SET @volume_multiplier=1
	
	


	DECLARE @expiration_date DATETIME
	
	SELECT @expiration_date= isnull([dbo].[FNARelativeExpirationDate](@as_of_date,@curve_Id,0 ,@expiration_type,@expiration_value),@as_of_date);
			
	DECLARE @delivery_month TABLE
		(curve_id INT,delivery_month DATETIME)	
	
	INSERT INTO @delivery_month
	SELECT	
		@curve_id,
		dateadd(mm, r.pricing_term, @Delivery_date)
		--dbo.FNALastDayInDate(dateadd(mm, r.pricing_term, @Delivery_date))
		
	FROM	
		position_break_down_rule r 
	WHERE
		r.strip_from=@Strip_Month_From 
		AND r.lag=@Lag_Months 
		AND r.strip_to=@Strip_Month_To 
		AND month(@Delivery_date) = r.phy_month	



	DECLARE @curve_value TABLE
		(curve_id INT,as_of_date DATETIME,term DATETIME,curve_value NUMERIC(30,12),settlement_curve_id INT)	

	;WITH Curve_Value (curve_id,as_of_date,term,curve_value,settlement_curve_id) 
	AS (
		SELECT  COALESCE(spc1.source_curve_def_id,spc.source_curve_def_id,spcd.proxy_source_curve_def_id,spcd.monthly_index,@curve_id) curve_id ,
				COALESCE(spc1.as_of_date,spc.as_of_date,CASE WHEN @expiration_date>=@as_of_date THEN @as_of_date ELSE @expiration_date END) as_of_date,
				COALESCE(spc1.maturity_date,spc.maturity_date,r.delivery_month) term,
				COALESCE(spc1.curve_value,spc2.curve_value,spc.curve_value) curve_value,
				spcd.settlement_curve_id
				
		FROM   
				@delivery_month r
				INNER JOIN 	source_price_curve_def spcd ON spcd.source_curve_def_id=r.curve_id
				LEFT JOIN 	source_price_curve_def spcd1 ON spcd1.source_curve_def_id=spcd.proxy_source_curve_def_id
				LEFT JOIN 	source_price_curve_def spcd2 ON spcd2.source_curve_def_id=spcd.monthly_index
				LEFT JOIN dbo.source_price_curve spc ON spc.source_curve_def_id=spcd.source_curve_def_id
					--AND spc.source_curve_def_id=@curve_id 
					AND spc.curve_source_value_id=@curve_source_id
					AND (spc.as_of_date= CASE WHEN @expiration_date>=@as_of_date	THEN @as_of_date ELSE @expiration_date END)
					AND dbo.FNAgetcontractmonth(spc.maturity_date)=delivery_month
				LEFT JOIN dbo.source_price_curve spc2 ON spc2.source_curve_def_id=ISNULL(spcd.proxy_source_curve_def_id,spcd.monthly_index)
					--AND spc.source_curve_def_id=@curve_id 
					AND spc2.curve_source_value_id=@curve_source_id
					AND (spc2.as_of_date= CASE WHEN @expiration_date>=@as_of_date	THEN @as_of_date ELSE @expiration_date END)
					AND dbo.FNAgetcontractmonth(spc2.maturity_date)=delivery_month
				LEFT JOIN source_price_curve_def spcd3 ON spcd3.source_curve_def_id=spcd.settlement_curve_id
				LEFT JOIN holiday_group hg On hg.hol_group_value_id=spcd3.exp_calendar_id
					AND dbo.FNAGetContractMonth(hg.hol_date)=delivery_month	
			    LEFT JOIN source_price_curve spc1 ON spc1.source_curve_def_id=spcd3.source_curve_def_id
					AND spc1.curve_source_value_id=@curve_source_id
					AND (spc1.as_of_date<=@as_of_date AND (spc1.maturity_date) = hg.hol_date)

		
		UNION ALL -- get the curves not defined in expiration tables
			
		SELECT  spc1.source_curve_def_id curve_id ,
				ISNULL(spc1.as_of_date,CASE WHEN @expiration_date>=@as_of_date THEN @as_of_date ELSE @expiration_date END) as_of_date,
				COALESCE(hg.exp_date,spc1.maturity_date,r.delivery_month) term,
				spc1.curve_value curve_value,
				spcd.settlement_curve_id
				
		FROM   
				@delivery_month r
				INNER JOIN 	source_price_curve_def spcd ON spcd.source_curve_def_id=r.curve_id
				LEFT JOIN source_price_curve_def spcd1 ON spcd1.source_curve_def_id=spcd.settlement_curve_id
				LEFT JOIN holiday_group hg On hg.hol_group_value_id=spcd1.exp_calendar_id
					AND dbo.FNAGetContractMonth(hg.exp_date)=delivery_month	
			    INNER JOIN source_price_curve spc1 ON spc1.source_curve_def_id=spcd1.source_curve_def_id
					AND spc1.curve_source_value_id=@curve_source_id
					AND (spc1.maturity_date<=@as_of_date AND dbo.FNAGetContractMonth(spc1.maturity_date) = delivery_month)	

			WHERE
			hg.exp_date IS NULL 			
			
		)

	

	INSERT INTO @curve_value SELECT * FROM curve_value
	--select round(645.7375,3),@index_round_value

DECLARE @avg_curve_value NUMERIC(30,20)
IF @pricing_option =0
BEGIN



SELECT @settlement_curve_id=MAX(settlement_curve_id) FROM @curve_value


		
--select @avg_curve_value
		--SELECT  --@ret_val=
		----		AVG(curve_value_FX_Avg)*ISNULL(@volume_multiplier,1)  
		--	spcd1.source_curve_def_id,
		--	spcd2.source_curve_def_id,
		--	cv.curve_id,
		--	--cv.curve_value,
		--	spc1.curve_value,spc.curve_value,spcd2.exp_calendar_id,term,
		--	hg1.exp_date				
		 	--CASE WHEN @index_round_value IS NOT NULL THEN ROUND(CAST(AVG(cv.curve_value) AS NUMERIC(30,12)),3) ELSE CAST(AVG(cv.curve_value) AS NUMERIC(30,12)) END,
			--CASE WHEN @fx_round_value IS NOT NULL THEN (COALESCE(1/ROUND(CAST(AVG(NULLIF(spc1.curve_value,0)) AS NUMERIC(30,12)),@fx_round_value),ROUND(CAST(AVG(spc.curve_value) AS NUMERIC(30,12)),@fx_round_value),CASE WHEN @Convert_to_currency IS NULL THEN 1 ELSE NULL END)) ELSE COALESCE(1/CAST(AVG(NULLIF(spc1.curve_value,0)) AS NUMERIC(30,12)),CAST(AVG(spc.curve_value) AS NUMERIC(30,12)),CASE WHEN @Convert_to_currency IS NULL THEN 1 ELSE NULL END) END

		 --CASE WHEN @index_round_value IS NOT NULL THEN ROUND(CAST(@avg_curve_value AS NUMERIC(30,12)),3) ELSE CAST(@avg_curve_value AS NUMERIC(30,12)) END*
		 --CASE WHEN @fx_round_value IS NOT NULL THEN (COALESCE(1/ROUND(CAST(AVG(NULLIF(spc1.curve_value,0)) AS NUMERIC(30,12)),@fx_round_value),ROUND(CAST(AVG(spc.curve_value) AS NUMERIC(30,12)),@fx_round_value),CASE WHEN @Convert_to_currency IS NULL THEN 1 ELSE NULL END)) ELSE COALESCE(1/CAST(AVG(NULLIF(spc1.curve_value,0)) AS NUMERIC(30,12)),CAST(AVG(spc.curve_value) AS NUMERIC(30,12)),CASE WHEN @Convert_to_currency IS NULL THEN 1 ELSE NULL END) END
			--ISNULL(hg.exp_date,hg1.exp_date),cv.curve_value,spc1.curve_value,spc.curve_value
		
		SELECT @ret_val=
			CASE WHEN @index_round_value IS NOT NULL THEN ROUND(CAST(curve_value AS NUMERIC(30,12)),3) ELSE CAST(curve_value AS NUMERIC(30,12)) END*@volume_multiplier
		FROM
		(
			SELECT 
				AVG(CASE WHEN @index_round_value IS NOT NULL THEN ROUND(curve_value,@index_round_value) ELSE curve_value END) curve_value,
				dbo.FNAGETContractMonth(term) term
			FROM
				@curve_value
			WHERE
				curve_value IS NOT NULL
			GROUP BY 
				dbo.FNAGETContractMonth(term)	
						
		) a
		
		
		--select * from @curve_value
		IF @Convert_to_currency IS NOT NULL
			SELECT @ret_val = 
					CASE WHEN @total_round_value IS NOT NULL THEN 
						AVG(ROUND(CASE WHEN @index_round_value IS NOT NULL THEN ROUND(CAST(b.curve_value AS NUMERIC(30,12)),@index_round_value) ELSE CAST(b.curve_value AS NUMERIC(30,12)) END * 
								CASE WHEN @fx_round_value IS NOT NULL THEN CASE WHEN is_divide=1 THEN 1/ROUND(CAST((NULLIF(a.curve_value,0)) AS NUMERIC(30,12)),@fx_round_value) ELSE ROUND(CAST((NULLIF(a.curve_value,0)) AS NUMERIC(30,12)),@fx_round_value) END  
						ELSE CASE WHEN is_divide=1 THEN 1/CAST((NULLIF(a.curve_value,0)) AS NUMERIC(30,12)) ELSE CAST((NULLIF(a.curve_value,0)) AS NUMERIC(30,12)) END END,@total_round_value)*(sc_factor))
					ELSE
						AVG(CASE WHEN @index_round_value IS NOT NULL THEN ROUND(CAST(b.curve_value AS NUMERIC(30,12)),@index_round_value) ELSE CAST(b.curve_value AS NUMERIC(30,12)) END * CASE WHEN @fx_round_value IS NOT NULL THEN CASE WHEN is_divide=1 THEN 1/ROUND(CAST((NULLIF(a.curve_value,0)) AS NUMERIC(30,12)),@fx_round_value)  ELSE ROUND(CAST((NULLIF(a.curve_value,0)) AS NUMERIC(30,12)),@fx_round_value) END
						ELSE CASE WHEN is_divide=1 THEN 1/CAST((NULLIF(a.curve_value,0)) AS NUMERIC(30,12)) ELSE CAST((NULLIF(a.curve_value,0)) AS NUMERIC(30,12)) END END*(sc_factor))
					END*@volume_multiplier		
				FROM 	
			(	
			
			SELECT		--MAX(sc1.factor),MAX(sc.factor),MAX(spc1.curve_value),MAX(spc.curve_value),
						dbo.FNAGETContractMonth(COALESCE(hg.exp_date,spc1.maturity_date,r.delivery_month)) term,
						AVG(ISNULL(spc1.curve_value,spc.curve_value)) curve_value,
						MAX(CASE WHEN spcd2.source_curve_def_id IS NOT NULL THEN 1 ELSE 0 END) AS is_divide,	
						MAX(COALESCE(sc1.factor,sc.factor,1)) sc_factor
					--spcd6.source_curve_def_id,	spcd.source_curve_def_id,
					--ISNULL(spcd6.granularity,spcd.granularity),
					--spcd1.source_curve_def_id,spcd2.source_curve_def_id,
					--spc1.curve_value,spc.curve_value	
				FROM
						
						@delivery_month r
						INNER JOIN 	source_price_curve_def spcd ON spcd.source_curve_def_id=r.curve_id
						LEFT JOIN 	source_price_curve_def spcd6 ON spcd6.source_curve_def_id=spcd.proxy_source_curve_def_id
						LEFT JOIN source_currency sc ON sc.source_currency_id=ISNULL(spcd6.source_currency_id,spcd.source_currency_id)
						LEFT JOIN source_price_curve_def spcd1 ON	spcd1.source_system_id = spcd.source_system_id  
								AND spcd1.source_currency_id = COALESCE(sc.currency_id_to,spcd6.source_currency_id,spcd.source_currency_id) 
								AND	spcd1.source_currency_to_ID = @Convert_to_currency
								AND spcd1.granularity = ISNULL(spcd6.granularity,spcd.granularity)
						LEFT JOIN source_price_curve_def spcd2 ON	spcd2.source_system_id = spcd.source_system_id  
								AND spcd2.source_currency_id = @Convert_to_currency
								AND	spcd2.source_currency_to_ID = COALESCE(sc.currency_id_to,spcd6.source_currency_id,spcd.source_currency_id) 
								AND spcd2.granularity = ISNULL(spcd6.granularity,spcd.granularity)
						LEFT JOIN source_price_curve spc ON spc.source_curve_def_id = COALESCE(spcd2.source_curve_def_id,spcd1.source_curve_def_id) 
								AND spc.curve_source_value_id=@curve_source_id
								AND (spc.as_of_date= CASE WHEN @expiration_date>=@as_of_date	THEN @as_of_date ELSE @expiration_date END)
								AND dbo.FNAgetcontractmonth(spc.maturity_date)=delivery_month
								
						LEFT JOIN source_price_curve_def spcd3 ON spcd3.source_curve_def_id=@settlement_curve_id
						LEFT JOIN source_currency sc1 ON sc1.source_currency_id=spcd3.source_currency_id
						LEFT JOIN source_price_curve_def spcd4 ON	spcd4.source_system_id = spcd3.source_system_id  
								AND spcd4.source_currency_id = ISNULL(sc1.currency_id_to,spcd3.source_currency_id) 
								AND	spcd4.source_currency_to_ID = @Convert_to_currency
								AND spcd4.granularity = 981
						LEFT JOIN source_price_curve_def spcd5 ON	spcd5.source_system_id = spcd3.source_system_id  
								AND spcd5.source_currency_id = @Convert_to_currency
								AND	spcd5.source_currency_to_ID = ISNULL(sc1.currency_id_to,spcd3.source_currency_id) 
								AND spcd5.granularity = 981
						LEFT JOIN holiday_group hg On hg.hol_group_value_id=ISNULL(spcd4.exp_calendar_id,spcd5.exp_calendar_id)
							AND dbo.FNAGetContractMonth(hg.hol_date)=delivery_month	
						LEFT JOIN source_price_curve spc1 ON spc1.source_curve_def_id=ISNULL(spcd4.source_curve_def_id,spcd5.source_curve_def_id)
							AND spc1.curve_source_value_id=@curve_source_id
							AND (spc1.as_of_date<=@as_of_date AND (spc1.maturity_date) = hg.hol_date)
						 	
					GROUP BY
						dbo.FNAGETContractMonth(COALESCE(hg.exp_date,spc1.maturity_date,r.delivery_month))
						,ISNULL(spcd2.source_curve_def_id,spcd1.source_curve_def_id) 
								
						UNION ALL -- get the curves not defined in expiration tables
					
				SELECT  
					
						dbo.FNAGETContractMonth(COALESCE(hg.exp_date,spc1.maturity_date,r.delivery_month)) term,
						AVG(spc1.curve_value) curve_value,
						MAX(CASE WHEN spcd2.source_curve_def_id IS NOT NULL THEN 1 ELSE 0 END) AS is_divide,
						MAX(ISNULL(sc.factor,1)) sc_factor	
				FROM   
						@delivery_month r
						LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=@settlement_curve_id
						LEFT JOIN source_currency sc ON sc.source_currency_id=spcd.source_currency_id
						LEFT JOIN source_price_curve_def spcd2 ON	spcd2.source_system_id = spcd.source_system_id  
								AND spcd2.source_currency_id = ISNULL(sc.currency_id_to,spcd.source_currency_id) 
								AND	spcd2.source_currency_to_ID = @Convert_to_currency
								AND spcd2.granularity = spcd.granularity
						LEFT JOIN source_price_curve_def spcd3 ON	spcd3.source_system_id = spcd.source_system_id  
								AND spcd3.source_currency_id = @Convert_to_currency
								AND	spcd3.source_currency_to_ID = ISNULL(sc.currency_id_to,spcd.source_currency_id) 
								AND spcd3.granularity = spcd.granularity				
						LEFT JOIN holiday_group hg On hg.hol_group_value_id=spcd.exp_calendar_id
							AND dbo.FNAGetContractMonth(hg.exp_date)=delivery_month	
						INNER JOIN source_price_curve spc1 ON spc1.source_curve_def_id=ISNULL(spcd2.source_curve_def_id,spcd3.source_curve_def_id)
							AND spc1.curve_source_value_id=@curve_source_id
							AND (spc1.maturity_date<=@as_of_date AND dbo.FNAGetContractMonth(spc1.maturity_date) = delivery_month)	

					WHERE
					hg.exp_date IS NULL	
					GROUP BY dbo.FNAGETContractMonth(COALESCE(hg.exp_date,spc1.maturity_date,r.delivery_month))
					--,ISNULL(spcd2.source_curve_def_id,spcd3.source_curve_def_id)
								
				) a	
				LEFT JOIN
				(
					SELECT 
						AVG(curve_value) curve_value,
						dbo.FNAGETContractMonth(term) term
					FROM
						@curve_value
					WHERE
						curve_value IS NOT NULL
					GROUP BY 
						dbo.FNAGETContractMonth(term)	
								
				) b
				ON a.term=b.term
			
			

END
	IF @pricing_option =1

		SELECT @ret_val=
			CASE WHEN @pricing_option=0 THEN AVG(curve_value_FX_Avg)*ISNULL(@volume_multiplier,1)  
				ELSE AVG(curve_value)*ISNULL(@volume_multiplier,1) END 
		FROM(	
			SELECT
				--cv.curve_id,
				dbo.FNAGETContractMonth(cv.term) term,
				AVG(CASE WHEN @index_round_value IS NOT NULL THEN ROUND(cv.curve_value,@index_round_value) ELSE cv.curve_value END*CASE WHEN @fx_round_value IS NOT NULL THEN ROUND(COALESCE(1/NULLIF(spc1.curve_value,0),spc.curve_value,CASE WHEN @Convert_to_currency IS NULL THEN 1 ELSE NULL END),@fx_round_value) ELSE COALESCE(1/NULLIF(spc1.curve_value,0),spc.curve_value,CASE WHEN @Convert_to_currency IS NULL THEN 1 ELSE NULL END) END)  curve_value,
				CASE WHEN @index_round_value IS NOT NULL THEN ROUND(AVG(cv.curve_value),@index_round_value) ELSE AVG(cv.curve_value) END *CASE WHEN @fx_round_value IS NOT NULL THEN ROUND(COALESCE(1/AVG(NULLIF(spc1.curve_value,0)),AVG(spc.curve_value),CASE WHEN @Convert_to_currency IS NULL THEN 1 ELSE NULL END),@fx_round_value) ELSE COALESCE(1/AVG(NULLIF(spc1.curve_value,0)),AVG(spc.curve_value),CASE WHEN @Convert_to_currency IS NULL THEN 1 ELSE NULL END) END curve_value_FX_Avg
			FROM	
				@curve_value cv
				INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=cv.curve_id	
				LEFT JOIN source_price_curve_def spcd1 ON	spcd1.source_system_id = spcd.source_system_id  
						AND spcd1.source_currency_id = spcd.source_currency_id 
						AND	spcd1.source_currency_to_ID = @Convert_to_currency
						AND spcd1.granularity = spcd.granularity
				LEFT JOIN source_price_curve spc ON spc.source_curve_def_id = spcd1.source_curve_def_id 
					AND	spc.as_of_date = cv.as_of_date
					AND spc.maturity_date = cv.term
					AND spc.curve_source_value_id = @curve_source_id 
				LEFT JOIN source_price_curve_def spcd2 ON	spcd2.source_system_id = spcd.source_system_id  
						AND spcd2.source_currency_ID = @Convert_to_currency
						AND	spcd2.source_currency_to_ID= spcd.source_currency_ID
						AND spcd2.granularity = spcd.granularity
				LEFT JOIN source_price_curve spc1 ON spc1.source_curve_def_id = spcd2.source_curve_def_id 
					AND	spc1.as_of_date = cv.as_of_date
					AND spc1.maturity_date = cv.term
					AND spc1.curve_source_value_id = @curve_source_id 		
			WHERE
				cv.curve_value IS NOT NULL		
			GROUP BY 
				--cv.curve_id,
				dbo.FNAGETContractMonth(cv.term)	
			) a		


	ELSE IF @pricing_option IN(2,3)

		SELECT @ret_val=
			CASE WHEN @pricing_option=2 THEN AVG(curve_value_FX_Avg)*ISNULL(@volume_multiplier,1) ELSE 
				AVG(curve_value)*ISNULL(@volume_multiplier,1) END 
		FROM(	
			SELECT
				--cv.curve_id,
				AVG(CASE WHEN @index_round_value IS NOT NULL THEN ROUND(cv.curve_value,@index_round_value) ELSE cv.curve_value END*CASE WHEN @fx_round_value IS NOT NULL THEN ROUND(COALESCE(1/NULLIF(spc1.curve_value,0),spc.curve_value,1),@fx_round_value) ELSE COALESCE(1/NULLIF(spc1.curve_value,0),spc.curve_value,1) END)  curve_value,
				CASE WHEN @index_round_value IS NOT NULL THEN ROUND(AVG(cv.curve_value),@index_round_value) ELSE AVG(cv.curve_value) END *CASE WHEN @fx_round_value IS NOT NULL THEN ROUND(COALESCE(1/AVG(NULLIF(spc1.curve_value,0)),AVG(spc.curve_value),1),@fx_round_value) ELSE COALESCE(1/AVG(NULLIF(spc1.curve_value,0)),AVG(spc.curve_value),1) END curve_value_FX_Avg
			FROM	
				@curve_value cv
				INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=cv.curve_id	
				LEFT JOIN source_price_curve_def spcd1 ON	spcd1.source_system_id = spcd.source_system_id  
						AND spcd1.source_currency_id = spcd.source_currency_id 
						AND	spcd1.source_currency_to_ID = @Convert_to_currency
						AND spcd1.granularity = spcd.granularity
				LEFT JOIN source_price_curve spc ON spc.source_curve_def_id = spcd1.source_curve_def_id 
					AND	spc.as_of_date = cv.as_of_date
					AND spc.maturity_date = cv.term
					AND spc.curve_source_value_id = @curve_source_id 
				LEFT JOIN source_price_curve_def spcd2 ON	spcd2.source_system_id = spcd.source_system_id  
						AND spcd2.source_currency_ID = @Convert_to_currency
						AND	spcd2.source_currency_to_ID= spcd.source_currency_ID
						AND spcd2.granularity = spcd.granularity
				LEFT JOIN source_price_curve spc1 ON spc1.source_curve_def_id = spcd2.source_curve_def_id 
					AND	spc1.as_of_date = cv.as_of_date
					AND spc1.maturity_date = cv.term
					AND spc1.curve_source_value_id = @curve_source_id 		
			WHERE
				cv.curve_value IS NOT NULL		
			) a							


	
	SELECT @ret_val= CASE WHEN @total_round_value IS NOT NULL THEN ROUND(@ret_val,@total_round_value) ELSE @ret_val END

	--SELECT @ret_val
	RETURN @ret_val
	
END
	
	
  
