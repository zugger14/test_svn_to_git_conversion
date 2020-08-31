/****** Object:  UserDefinedFunction [dbo].[FNAForwardCurveValue]    Script Date: 07/16/2018 13:59:23 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAForwardCurveValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAForwardCurveValue]
/****** Object:  UserDefinedFunction [dbo].[FNAForwardCurveValue]    Script Date: 07/16/2018 13:59:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO 

CREATE FUNCTION [dbo].[FNAForwardCurveValue] (    
	@maturity_date DATETIME,   
	@as_of_date DATETIME,  
	@he INT,  
	@curve_source_value_id int,  --4500
	@curve_id INT,  
	@relative_year int,   
	@relative_month int,   
	@relative_day int,  
	@same_as_of_date INT,  
	@use_same_as_of_date INT,  
	@prior_year1 INT,  
	@prior_year2 INT,
	@cal_period INT --TO DO: For future reterence(to limit the calculation)
 )  

 --dbo.FNAForwardCurveValue('@prod_date','@as_of_date',0,4500,16,0,0,0,0,1,1,2,0)
RETURNS float AS    
BEGIN   
	DECLARE @x as float  
	DECLARE @maturity DATETIME  
  
	SET @x = NULL  
	IF @he IS NULL  
		SET @he=1  
	IF @he>0
		SET @he=@he-1  
  
   
	SET @maturity_date = DATEADD(yy, @relative_year, @maturity_date)  
	SET @maturity_date = DATEADD(mm, @relative_month, @maturity_date)  
	SET @maturity_date = DATEADD(dd, @relative_day, @maturity_date)  
   
  
	SET @maturity = CAST(dbo.FNAGetSQLStandardDate(@maturity_date) + ' ' +   
	  CASE WHEN (@he < 10) THEN '0' ELSE '' END +  
	  CAST(@he AS VARCHAR) + ':00:00' AS DATETIME)   
	 
	IF @same_as_of_date = 1  
	BEGIN  
		SET @as_of_date = DATEADD(YY, @relative_year, @as_of_date)  
		SET @as_of_date = DATEADD(MM, @relative_month, @as_of_date)  
		SET @as_of_date = DATEADD(DD, @relative_day, @as_of_date)  
	END  
	 
	SELECT @x = curve_value   
	FROM source_price_curve  
	WHERE  source_curve_def_id = @curve_id AND  
		as_of_date = @as_of_date AND  
		assessment_curve_type_value_id = 77 AND --spot daily  
		curve_source_value_id = @curve_source_value_id   
		AND (maturity_date) = @maturity  
	
	 
	IF @x IS NULL AND @use_same_as_of_date = 1  
	BEGIN  
		SELECT @x = cv1 * (1 + ((cv1 - cv2))/NULLIF(cv2,0)) FROM (
			SELECT curve_value cv1, cv2
			FROM source_price_curve  spc
			OUTER APPLY (
					SELECT curve_value cv2
					FROM source_price_curve spc1
					WHERE source_curve_def_id = spc.source_curve_def_id 
						AND as_of_date = @as_of_date
						AND assessment_curve_type_value_id = 77 --spot daily  
						AND curve_source_value_id = @curve_source_value_id 
						AND (maturity_date) = DATEADD(YY, @prior_year2 * -1, @maturity)
			) b
			WHERE source_curve_def_id = @curve_id
				AND as_of_date = @as_of_date
				AND assessment_curve_type_value_id = 77 --spot daily  
				AND curve_source_value_id = @curve_source_value_id 
				AND (maturity_date) = DATEADD(YY, @prior_year1 * -1, @maturity)
		) a
	END  
  
 RETURN @x  
END  
  