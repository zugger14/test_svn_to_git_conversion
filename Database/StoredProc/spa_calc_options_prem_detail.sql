IF OBJECT_ID('spa_calc_options_prem_detail') IS NOT NULL
DROP PROC dbo.spa_calc_options_prem_detail
/************************************************************
 * Time: 6/12/2014 14:14:34 PM
 * By : Shushil Bohara (sbohara@pioneersolutionsglobal.com)
 * Desc: This sp is replacement of function FNACalcOptionsPrem 
		it calculated value at once instead of row wise
 ************************************************************/
GO
CREATE PROC dbo.spa_calc_options_prem_detail
	@input_table_name VARCHAR(250),
	@output_table_name VARCHAR(100)
AS
BEGIN
	DECLARE @d1 VARCHAR(MAX)
	DECLARE @d2 VARCHAR(MAX)
	DECLARE @BS FLOAT
	DECLARE @PI VARCHAR(200)
	DECLARE @DELTA FLOAT
	DECLARE @DELTA2 FLOAT
	DECLARE @GAMMA FLOAT
	DECLARE @VEGA FLOAT
	DECLARE @THETA FLOAT
	DECLARE @RHO FLOAT
	DECLARE @CND_D1 VARCHAR(MAX)
	DECLARE @CND_D2 VARCHAR(MAX)
	DECLARE @CND_ND1 VARCHAR(MAX)
	DECLARE @CND_ND2 VARCHAR(MAX)
	DECLARE @CND_D1_Q VARCHAR(MAX)
	--NEW
	DECLARE @CND_D2_Q VARCHAR(MAX), @PDVS2 VARCHAR(MAX), @PD2VS2 VARCHAR(MAX), @PDd2S2 VARCHAR(MAX)
	--NEW
	DECLARE @sql VARCHAR(8000), @sql_one VARCHAR(8000), @P_VOL VARCHAR(MAX), @tmp_vol VARCHAR(MAX)
	DECLARE @GAMMA2 FLOAT, @VEGA2 FLOAT, @RHO2 FLOAT, @THETA2 FLOAT

	SET @PI = '3.14159265358979323846'

	SET @P_VOL = 'SQRT(ABS(POWER(V1, 2) - (2 * S2 * C * V1 * V2) / (S2 + X1) + POWER(S2/(S2 + X1), 2) * POWER(V2, 2)))'
	SET @tmp_vol = 'CASE WHEN IDT = 2 THEN V1 ELSE ' + @P_VOL + ' END'
	

	SET @d1 = '(LOG(S1 / NULLIF(X, 0)) + (POWER( ' + @tmp_vol + ', 2) / 2) * T) / NULLIF(( ' + @tmp_vol + '  * SQRT(T)), 0)'
	SET @d2 = @d1 + '-' + @tmp_vol + '  * SQRT(T)'


	SET @CND_D1 = 'dbo.FNACND(' + @d1 + ')'
	SET @CND_D2 = 'dbo.FNACND(' + @d2 + ')'
	SET @CND_ND1 = 'dbo.FNACND(-(' + @d1 + '))'
	SET @CND_ND2 = 'dbo.FNACND(-(' + @d2 + '))'
	SET @CND_D1_Q = 'EXP(-0.5 * POWER(' + @d1 + ', 2)) / SQRT(2 * ' + @PI + ')'

	--Table to store above declared variable's value
	IF OBJECT_ID('tempdb..#tmp_parameter') IS NOT NULL
		DROP TABLE #tmp_parameter

	CREATE TABLE #tmp_parameter (
		row_id INT, 
		[PI] FLOAT, 
		P_VOL FLOAT, 
		tmp_vol FLOAT,
		d1 FLOAT, 
		d2 FLOAT, 
		CND_D1 FLOAT, 
		CND_D2 FLOAT, 
		CND_ND1 FLOAT, 
		CND_ND2 FLOAT, 
		CND_D1_Q  FLOAT)

	SET @sql = '
		INSERT INTO #tmp_parameter
		SELECT
			row_id, 
			' + CAST(@PI AS VARCHAR(50)) + ', 
			' + @P_VOL + ', 
			' + @tmp_vol + ', 
			' + @d1 + ', 
			' + @d2 + ', 
			' + @CND_D1 + ', 
			' + @CND_D2 + ', 
			' + @CND_ND1 + ', 
			' + @CND_ND2 + ', 
			' + @CND_D1_Q + '
		FROM ' + @input_table_name + '
		WHERE IDT IN(2, 18) AND method IS NULL'

	exec spa_print @sql
	EXEC(@sql)

	SET @sql ='INSERT INTO ' + @output_table_name + ' 
		SELECT
			op.row_id,
			CASE WHEN CallPutFlag = ''c'' THEN 
				S1 * EXP(-R * T) * CND_D1 - X * EXP(-R * T) * CND_D2
			ELSE
				X * EXP(-R * T) * CND_ND2 - S1 * EXP(-R * T) * CND_ND1
			END BS,
			CASE WHEN CallPutFlag = ''c'' THEN 
				EXP(-R * T) * CND_D1
			ELSE
				EXP(-R * T) * (CND_D1 - 1)
			END DELTA,
			CND_D1_Q * EXP(-R * T) / NULLIF((S1 * tmp_vol * SQRT(T)),0) GAMMA,
			CND_D1_Q * S1 * EXP(-R * T) * SQRT(T) VEGA,
			CASE WHEN CallPutFlag = ''c'' THEN
			((-S1 * EXP(-R * T) * CND_D1_Q *  tmp_vol) / NULLIF((2 * SQRT(T)),0)) + (R * S1 * EXP(-R * T) * CND_D1) - (R * X * EXP(-R * T) *  CND_D2) 
			ELSE 
			((-S1 * EXP(-R * T) * CND_D1_Q *  tmp_vol) / NULLIF((2 * SQRT(T)),0)) - (R * S1 * EXP(-R * T) * CND_ND1) + (R * X * EXP(-R * T) *  CND_ND2) 
			END THETA,
			CASE WHEN CallPutFlag = ''c'' THEN 
				X * T * EXP(-R * T) * CND_D2
			ELSE
				-X * T * EXP(-R * T) * CND_ND2
			END RHO,
			CASE WHEN CallPutFlag = ''c'' THEN 
				-1 * EXP(-R * T) * CND_D2	
			ELSE
				-1 * EXP(-R * T) * (CND_D2 - 1)
			END DELTA2,
			NULL GAMMA2,
			NULL VEGA2,
			NULL RHO2,
			NULL THETA2, NULL,op.Attribute_type
			,op.option_excercise_type
			,op.IDT
		FROM ' + @input_table_name + ' op
		INNER JOIN #tmp_parameter tp ON op.row_id = tp.row_id
		WHERE IDT IN(2, 18) AND op.method IS NULL'

	exec spa_print @sql
	EXEC(@sql)

	--FNABlackScholesSpread
	SET @d1 = '(LOG(S1 / NULLIF(S2 + X, 0)) + 0.5 * POWER(' + @P_VOL + ', 2) * T) / NULLIF((' + @P_VOL + ' * SQRT(T)), 0)'
	SET @d2 = @d1 + '-' +  @P_VOL + ' * SQRT(T)'

	SET @CND_D1 = 'dbo.FNACND(' + @d1 + ')'
	SET @CND_D2 = 'dbo.FNACND(' + @d2 + ')'
	SET @CND_ND1 = 'dbo.FNACND(-(' + @d1 + '))'
	SET @CND_ND2 = 'dbo.FNACND(-(' + @d2 + '))'

	SET @CND_D1_Q = 'EXP(-0.5 * POWER(' + @d1 + ', 2)) / SQRT(2 * ' + @PI + ')'
	SET @CND_D2_Q = 'EXP(-0.5 * POWER(' + @d2 + ', 2)) / SQRT(2 * ' + @PI + ')'

	SET	@PDVS2 = '(V2 * X / ' + @P_VOL + ') * ((V2 * S2 / (S2 + X)) - C * V1) / POWER((S2 + X), 2)'
	SET	@PD2VS2 = 'V2 * X / ( POWER( ' + @P_VOL + ', 2) * POWER((S2 + X), 3)) * ( ' + @P_VOL + ' * V2 * X / (S2 + X) + (C * V1 - (V2 * S2 / (S2 + X))) * (2 * ' + @P_VOL + ' + (S2 + X) * ' + @PDVS2 + '))'
	SET	@PDd2S2 = '-1 /  ' + @P_VOL + ' *  ' + @PDVS2 + ' *  ' + @d1 + ' - 1 / ( ' + @P_VOL + ' * SQRT(T) * (S2 + X))'

	--Table to store above declared variable's value
	IF OBJECT_ID('tempdb..#tmp_parameter_new') IS NOT NULL
		DROP TABLE #tmp_parameter_new

	CREATE TABLE #tmp_parameter_new (
		row_id INT, 
		[PI] FLOAT, 
		P_VOL FLOAT, 
		tmp_vol FLOAT,
		d1 FLOAT, 
		d2 FLOAT, 
		CND_D1 FLOAT, 
		CND_D2 FLOAT, 
		CND_ND1 FLOAT, 
		CND_ND2 FLOAT, 
		CND_D1_Q  FLOAT,  
		CND_D2_Q FLOAT, 
		PDVS2 FLOAT, 
		PD2VS2 FLOAT, 
		PDd2S2 FLOAT)

	SET @sql = '
		INSERT INTO #tmp_parameter_new
		SELECT
			row_id, 
			' + CAST(@PI AS VARCHAR(50)) + ', 
			' + @P_VOL + ', 
			' + @tmp_vol + ',
			' + @d1 + ', 
			' + @d2 + ', 
			' + @CND_D1 + ', 
			' + @CND_D2 + ', 
			' + @CND_ND1 + ', 
			' + @CND_ND2 + ', 
			' + @CND_D1_Q + ',
			' + @CND_D2_Q + ',
			' + @PDVS2 + ',
			' + @PD2VS2 + ',
			' + @PDd2S2 + '
		FROM ' + @input_table_name + '
		WHERE IDT = 3 AND method IS NULL'

	exec spa_print @sql
	EXEC(@sql)


	SET @sql ='INSERT INTO ' + @output_table_name + ' 
		SELECT
			op.row_id,
			CASE WHEN CallPutFlag = ''c'' THEN 
				EXP(-R * T) *  ((S1 * CND_D1) - ((S2 + X) * CND_D2))
			ELSE
				(EXP(-R * T) *  ((S1 * CND_D1) - ((S2 + X) * CND_D2))) - EXP(-R * T) * (S1 - S2 - X)
			END BS,
			EXP(-R * T) * CASE WHEN CallPutFlag = ''c'' THEN CND_D1 ELSE (CND_D1 - 1) END DELTA,
			CND_D1_Q * EXP(-R * T) / NULLIF((S1 * P_VOL * SQRT(T)), 0) GAMMA,
			CND_D1_Q * S1 * EXP(-R * T) * SQRT(T) VEGA,
			CASE WHEN CallPutFlag = ''c'' THEN
				((-S1 * EXP(-R * T) * CND_D1_Q *  P_VOL ) / NULLIF((2 * SQRT(T)), 0)) + (R * S1 * EXP(-R * T) * CND_D1) - (R * X * EXP(-R * T) * CND_D2)
			ELSE
				((-S1 * EXP(-R * T) * CND_D1_Q *  P_VOL ) / NULLIF((2 * SQRT(T)), 0)) - (R * S1 * EXP(-R * T) * CND_ND1)+ (R * X * EXP(-R * T) * CND_ND2) 
			END		 
			THETA,
			CASE WHEN CallPutFlag = ''c'' THEN X ELSE -X END * T * EXP(-R * T) * CASE WHEN CallPutFlag = ''c'' THEN CND_D2 ELSE CND_ND2 END RHO,
			(-1 * EXP(-R * T) * CASE WHEN CallPutFlag = ''c'' THEN CND_D2 ELSE (CND_D2 - 1) END) DELTA2,
			EXP(-R * T) * CND_D2_Q * (-PDd2S2 + SQRT(T) * (PDVS2 + (S2 + X) * (PD2VS2 -  d2 * PDd2S2 * PDVS2))) GAMMA2,
			NULL VEGA2,
			NULL RHO2,
			NULL THETA2, NULL,op.Attribute_type
			,op.option_excercise_type
			,op.IDT
		FROM ' + @input_table_name + ' op
		INNER JOIN #tmp_parameter_new tpn ON op.row_id = tpn.row_id
		WHERE IDT = 3 AND op.Method IS NULL'

	exec spa_print @sql
	EXEC(@sql)

	--SELECT * FROM #tmp_parameter_new
	--EXEC('SELECT * FROM ' + @output_table_name)
END
