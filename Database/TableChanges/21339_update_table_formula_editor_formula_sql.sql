
DECLARE @formula_id INT

select @formula_id = formula_id From formula_editor where formula_name = 'socal Gas'


 UPDATE formula_editor_sql SET formula_sql = 
	'IF OBJECT_ID(''tempdb..#final_output'') IS NULL
					BEGIN
						CREATE TABLE #final_output (
							[prod_date] DATETIME,
							[hr] INT,
							[mins] INT,
							[value] FLOAT
						)
					END

	IF (dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,16,1) >= 217 
		AND  dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,16,1) <= 360)
	BEGIN
		IF (dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,16,1) >= 241 
		AND  dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,16,1) <= 360)
		BEGIN
			INSERT INTO source_price_curve(	source_curve_def_id, as_of_date, Assessment_curve_type_value_id, curve_source_value_id, maturity_date, curve_value, is_dst)
			SELECT  16, ''@as_of_date'', 77, 4500, ''@prod_date'', isnull(dbo.FNAForwardCurveValue(''@prod_date'',''@as_of_date'',0,4500,16,0,0,0,0,1,1,2,0),0), 0

			INSERT INTO #final_output
				SELECT   ''@prod_date'' [prod_date],0 [hr],0 [mins],  dbo.FNAForwardCurveValue(''@prod_date'',''@as_of_date'',0,4500,16,0,0,0,0,1,1,2,0) [value]
		END
		ELSE
		BEGIN
			INSERT INTO source_price_curve(	source_curve_def_id, as_of_date, Assessment_curve_type_value_id, curve_source_value_id, maturity_date, curve_value, is_dst)
			SELECT  16, ''@as_of_date'', 77, 4500, ''@prod_date'', isnull(dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,16,-CEILING((dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,16,1)-36)/12),0,0,0,1)*(1adiha_add((dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,15,0,0,0,0,1) -dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,15,-CEILING((dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,16,1)-36)/12),0,0,0,1) )/dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,15,-CEILING((dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,16,1)-36)/12),0,0,0,1))),0), 0
			
			INSERT INTO #final_output			
			SELECT   ''@prod_date'' [prod_date],0 [hr],0 [mins],  isnull(dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,16,-CEILING((dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,16,1)-36)/12),0,0,0,1)*(1adiha_add((dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,15,0,0,0,0,1) -dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,15,-CEILING((dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,16,1)-36)/12),0,0,0,1) )/dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,15,-CEILING((dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,16,1)-36)/12),0,0,0,1))),0) [value]
		END
	END
	ELSE
	BEGIN
							 
		INSERT INTO #final_output
		SELECT  ''@prod_date'' [prod_date],0 [hr],0 [mins],  
		CASE  WHEN dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,16,1) <= 36 
			THEN dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,16,0,0,0,0,1) 
		WHEN  dbo.FNARECCurve(''@prod_date'',''@as_of_date'',16, 1,0,0,null  ,null,NULL) IS NOT NULL 
			THEN dbo.FNARECCurve(''@prod_date'',''@as_of_date'',16, 1,0,0,null  ,null,null) 
		ELSE 
			CASE WHEN dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,16,1) <= 144 AND dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,14,1) >= 37
					THEN dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,16,-CEILING((dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,16,1)-36)/12),0,0,0,1)*(1adiha_add((dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,18,0,0,0,0,1) -dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,18,-CEILING((dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,16,1)-36)/12),0,0,0,1) )/dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,18,-CEILING((dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,16,1)-36)/12),0,0,0,1) )) 		 
			ELSE dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,16,-CEILING((dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,16,1)-36)/12),0,0,0,1)*(1adiha_add((dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,15,0,0,0,0,1) -dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,15,-CEILING((dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,16,1)-36)/12),0,0,0,1) )/dbo.FNARPriorCurve(''@prod_date'',''@as_of_date'',0,4500,15,-CEILING((dbo.FNARRelativePeriod(''@prod_date'',''@as_of_date'',4500,16,1)-36)/12),0,0,0,1))) END END [value]  
	END'	
	WHERE formula_id = @formula_id

PRINT 'formula_sql updated successfully'
