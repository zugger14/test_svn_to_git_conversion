/****** Object:  UserDefinedFunction [dbo].[FNARGetCurveValue]    Script Date: 03/23/2009 22:51:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FNARGetCurveValue]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARGetCurveValue]
GO
/****** Object:  UserDefinedFunction [dbo].[FNARGetCurveValue]    Script Date: 03/23/2009 22:51:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- select dbo.FNARGetCurveValue('2015-07-01','2015-07-01',4399,NULL,NULL,0,0,NULL,NULL)

CREATE FUNCTION [dbo].[FNARGetCurveValue] (@curve_source_value_id INT, @maturity_date DATETIME,@as_of_date DATETIME, @volume_mult FLOAT,@he int,@mins int,@is_dst int,@curve_shift_val FLOAT ,@curve_shift_per FLOAT)
RETURNS FLOAT AS  

/*
DECLARE @maturity_date DATETIME,@as_of_date DATETIME, @curve_source_value_id INT, @volume_mult FLOAT,@he int,@mins int,@is_dst int,@curve_shift_val FLOAT ,@curve_shift_per FLOAT

SET @maturity_date ='2015-02-01'
SET @as_of_date ='2015-01-01' 
SET @curve_source_value_id =4405 
SET @volume_mult =null
SET @he =1
SET @mins =
SET @curve_shift_val =0 
SET @curve_shift_per =1

--*/
BEGIN 
	DECLARE @x							AS FLOAT
	DECLARE @settlement_curve_id		INT
	DECLARE @settlement_maturity_date	DATETIME
	DECLARE @pnl_as_of_date				DATETIME
	DECLARE @settlement_granularity		INT 
	DECLARE @min_d						VARCHAR(2)
	DECLARE @granularity				INT
	DECLARE	@as_of_date_eom				DATETIME
	
	declare @maturity_date_980 datetime,@maturity_date_981 datetime,
	@maturity_date_993 datetime,@maturity_date_var DATETIME
	
	declare @maturity as varchar(30)
	declare @qtr_min as varchar(2);

	

	SELECT 	@granularity = granularity FROM source_price_curve_def spcd WHERE source_curve_def_id=@curve_source_value_id
	
	IF @granularity IN(987,989,993,994,995)
		SET @as_of_date = @maturity_date
		
	--RETURN @granularity
	IF(@granularity NOT IN(987,989,994,995))
	BEGIN
		
		IF @he IS NULL
			SET @he = 0

		IF @mins IS NULL
			SET @mins = 0
		
		--select @maturity_date_980 =CONVERT(VARCHAR(8),@maturity_date,120) + '01'
		--	,@maturity_date_981=@maturity_date,
		--	@maturity_date_991 =CAST(YEAR(@maturity_date) AS VARCHAR) + '-' + CAST(DATEPART(q, @maturity_date) AS VARCHAR) + '-01'
		--	,@maturity_date_993 =CAST(YEAR(@maturity_date) AS VARCHAR) + '-01-01' 
		--	,@maturity_date_var =@maturity_date
	
			SELECT @maturity_date_var = CASE WHEN spcd.Granularity IN (980) THEN CONVERT(VARCHAR(8),@maturity_date,120) + '01'
				WHEN spcd.Granularity IN (993) THEN CAST(YEAR(@maturity_date) AS VARCHAR) + '-01-01' else @maturity_date end
			FROM source_price_curve_def spcd where spcd.source_curve_def_id = @curve_source_value_id

			set @is_dst=isnull(@is_dst,0) 

		SELECT @curve_shift_val=ISNULL(@curve_shift_val,0),@curve_shift_per=ISNULL(@curve_shift_per,1)

		SET @min_d = '00'
	
		IF @he>0
			SET @he=@he-1

		--RETURN(@granularity)
		SET @as_of_date_eom = CASE WHEN @granularity = 980 THEN DATEADD(m,1,CAST(CONVERT(VARCHAR(7),@as_of_date,120)+'-01' AS DATETIME))-1 
							   WHEN @granularity = 993 THEN CAST(YEAR(@as_of_date) AS VARCHAR) + '-' +'12-31' END

	
		IF ((@granularity IN(980) AND ((MONTH(@maturity_date) = MONTH(@as_of_date) AND @as_of_date>=@as_of_date_eom AND @maturity_date<=@as_of_date) OR (MONTH(@maturity_date) <> MONTH(@as_of_date) AND @maturity_date<=@as_of_date)))
			OR((@granularity IN(993) AND ((YEAR(@maturity_date) = YEAR(@as_of_date) AND @as_of_date>=@as_of_date_eom AND @maturity_date<=@as_of_date) OR (YEAR(@maturity_date) <> YEAR(@as_of_date) AND @maturity_date<=@as_of_date))))
			OR(@granularity IN(981,982,987,994,995) AND  @maturity_date<=@as_of_date))					

		BEGIN

			SELECT	@settlement_curve_id = ISNULL(spcd_s.source_curve_def_id, spcd.source_curve_def_id), 
					@settlement_maturity_date = CASE WHEN (hg.hol_date IS NULL AND 
						ISNULL(spcd_s.Granularity, spcd.Granularity) IN(981,982,987,994,995)) THEN @maturity_date ELSE hg.hol_date END, 
					@pnl_as_of_date = CASE WHEN (hg.hol_date IS NULL AND 
						ISNULL(spcd_s.Granularity, spcd.Granularity) IN(981,982,987,994,995)) THEN @maturity_date ELSE hg.exp_date END, 
					@settlement_granularity = spcd.Granularity	 
			FROM 
				 source_price_curve_def spcd LEFT  JOIN
				 source_price_curve_def spcd_s ON spcd_s.source_curve_def_id  = spcd.settlement_curve_id LEFT  JOIN
				 holiday_group hg ON hg.hol_group_value_id = ISNULL(spcd_s.exp_calendar_id, spcd.exp_calendar_id)
			WHERE spcd.source_curve_def_id = @curve_source_value_id AND
				 (hg.hol_date IS NULL OR
				  hg.hol_date = @maturity_date_var	)

			SELECT @maturity_date_var = CASE WHEN @settlement_granularity IN (980) THEN CONVERT(VARCHAR(8),@maturity_date,120) + '01'
						WHEN @settlement_granularity IN (993) THEN CAST(YEAR(@maturity_date) AS VARCHAR) + '-01-01' else @maturity_date end
					FROM source_price_curve_def spcd where spcd.source_curve_def_id = @curve_source_value_id

			IF @pnl_as_of_date IS NULL
			BEGIN
				SET @pnl_as_of_date = @maturity_date_var 

				SET @settlement_maturity_date = @pnl_as_of_date
			END
		
			SET @maturity_date =dbo.FNAGetSQLStandardDate(@settlement_maturity_date) + ' ' + 
											case when (@he < 10) then '0' else '' end +
											cast(@he as varchar) + ':'+@min_d+':00'	
			SELECT @x = (spc.curve_value+ @curve_shift_val) * @curve_shift_per
			FROM 
					source_price_curve spc 
			WHERE 
					spc.source_curve_def_id = @settlement_curve_id AND
					spc.curve_source_value_id=4500 AND 
					spc.as_of_date = @pnl_as_of_date AND
					spc.assessment_curve_type_value_id IN (77,78) AND 
					spc.curve_source_value_id = 4500 AND 
					spc.maturity_date = 	@maturity_date	and
					spc.is_dst=@is_dst	
		END
		ELSE
		BEGIN
		
			SET @maturity_date = dbo.FNAGetSQLStandardDate(@maturity_date) + ' ' + 
											case when (@he < 10) then '0' else '' end +
											cast(@he as varchar) + ':'+@min_d+':00'	
													
			select @maturity_date_980 =CONVERT(VARCHAR(8),@maturity_date,120) + '01'
				,@maturity_date_981=@maturity_date
				,@maturity_date_993 =CAST(YEAR(@maturity_date) AS VARCHAR) + '-01-01' 
				,@maturity_date_var =@maturity_date
														
			select @maturity_date_var = CASE  @granularity WHEN 980 THEN @maturity_date_980 WHEN 993 THEN @maturity_date_993 ELSE @maturity_date END										
			SELECT @x = (COALESCE(spc.curve_value, spc_p1.curve_value, spc_p2.curve_value, spc_p3.curve_value)+ @curve_shift_val) * @curve_shift_per
			FROM source_price_curve_def spcd LEFT JOIN 
				 source_price_curve_def spcd1 ON spcd1.source_curve_def_id = spcd.proxy_source_curve_def_id LEFT JOIN 
				 source_price_curve_def spcd2 ON spcd2.source_curve_def_id = spcd.monthly_index LEFT JOIN 
				 source_price_curve_def spcd3 ON spcd3.source_curve_def_id = spcd.proxy_curve_id3 LEFT JOIN 
				 source_price_curve spc ON 
					spcd.source_curve_def_id = spc.source_curve_def_id AND
					spc.curve_source_value_id=4500 AND 
					spc.as_of_date = @as_of_date AND
					spc.assessment_curve_type_value_id IN (77,78) AND 
					spc.curve_source_value_id = 4500 AND 
					spc.maturity_date =  @maturity_date_var  and spc.is_dst=@is_dst LEFT JOIN
				 source_price_curve spc_p1 ON 
					spcd.proxy_source_curve_def_id = spc_p1.source_curve_def_id AND
					spc_p1.curve_source_value_id=4500 AND 
					spc_p1.as_of_date = @as_of_date AND 
					spc_p1.assessment_curve_type_value_id IN (77,78) AND 
					spc_p1.curve_source_value_id = 4500 AND 
					spc_p1.maturity_date= @maturity_date_var and spc_p1.is_dst=@is_dst LEFT JOIN		 
				 source_price_curve spc_p2 ON 
					spcd.monthly_index = spc_p2.source_curve_def_id AND
					spc_p2.as_of_date = @as_of_date AND 
					spc_p2.curve_source_value_id=4500 AND 
					spc_p2.assessment_curve_type_value_id IN (77,78) AND 
					spc_p2.curve_source_value_id = 4500 AND 
					spc_p2.maturity_date =  @maturity_date_var and spc_p2.is_dst=@is_dst LEFT JOIN				
				 source_price_curve spc_p3 ON 
					spcd.proxy_curve_id3 = spc_p3.source_curve_def_id AND
					spc_p3.curve_source_value_id=4500 AND 
					spc_p3.as_of_date = @as_of_date AND 
					spc_p3.assessment_curve_type_value_id IN (77,78) AND 
					spc_p3.curve_source_value_id = 4500 AND 
					spc_p3.maturity_date = @maturity_date_var
						and spc_p3.is_dst=@is_dst
			
				WHERE 	spcd.source_curve_def_id = @curve_source_value_id 
			END		
		
		--return isnull(@x, 0)
		--return (@x * ISNULL(@volume_mult, 1))
END
ELSE
BEGIN
	select @curve_shift_val=isnull(@curve_shift_val,0),@curve_shift_per=isnull(@curve_shift_per,1)

	IF @granularity IN(987,989)
	BEGIN
		if @mins = 1 or @mins=15
			set @qtr_min = '00';
		else if @mins = 2 or @mins=30
			set @qtr_min = '15';
		else if @mins = 3 or @mins=45
			set @qtr_min = '30';
		else if @mins = 4 or @mins=60
			set @qtr_min = '45';
	END
	ELSE IF @granularity IN(994) -- 10 mins
		set @qtr_min = RIGHT('00'+CAST(@mins-10 AS VARCHAR),2)	
	ELSE
		set @qtr_min = RIGHT('00'+CAST(@mins-5 AS VARCHAR),2)		
		
	
	set @x = NULL

	If @he IS NULL
		RETURN NULL

	set @he=@he-1
	SET @maturity = dbo.FNAGetSQLStandardDate(@maturity_date) + ' ' + 
			case when (@he < 10) then '0' else '' end +
			cast(@he as varchar) + ':'+@qtr_min+':00'		

	SELECT @x = (curve_value+ @curve_shift_val) * @curve_shift_per 
	FROM 
		source_price_curve
	WHERE
		source_curve_def_id = @curve_source_value_id and
		as_of_date = @maturity_date and
		assessment_curve_type_value_id = 77 and --spot daily
		curve_source_value_id = 4500 and
		dbo.FNAGetSQLStandardDateTime(maturity_date) = @maturity

	END
RETURN (@x* isnull(@volume_mult, 1))
END