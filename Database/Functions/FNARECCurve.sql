/****** Object:  UserDefinedFunction [dbo].[FNARECCurve]    Script Date: 03/23/2009 22:51:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FNARECCurve]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARECCurve]
GO
/****** Object:  UserDefinedFunction [dbo].[FNARECCurve]    Script Date: 03/23/2009 22:51:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- select dbo.FNARECCurve('2011-07-04','2011-06-30',45,1,0,0,10, 1)

CREATE FUNCTION [dbo].[FNARECCurve] (@maturity_date DATETIME,@as_of_date DATETIME, @curve_source_value_id INT, @volume_mult FLOAT,@he int,@mins int,@is_dst int,@curve_shift_val FLOAT ,@curve_shift_per FLOAT)
RETURNS FLOAT AS  


--declare @maturity_date DATETIME='2013-09-30 00:00:00'
--,@as_of_date DATETIME='2013-09-30 00:00:00', @curve_source_value_id INT=156, @volume_mult FLOAT=null
--,@he int=0,@mins int=0,@curve_shift_val FLOAT=0 ,@curve_shift_per FLOAT=1


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
	@maturity_date_991 datetime,@maturity_date_993 datetime,@maturity_date_var datetime
	
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
			 WHEN spcd.Granularity IN (991) THEN CAST(YEAR(@maturity_date) AS VARCHAR) + '-' + CAST(DATEPART(q, @maturity_date) AS VARCHAR) + '-01'
			WHEN spcd.Granularity IN (993) THEN CAST(YEAR(@maturity_date) AS VARCHAR) + '-01-01' else @maturity_date end
		FROM source_price_curve_def spcd where spcd.source_curve_def_id = @curve_source_value_id



		set @is_dst=isnull(@is_dst,0) 


	SELECT @curve_shift_val=ISNULL(@curve_shift_val,0),@curve_shift_per=ISNULL(@curve_shift_per,1)

	SET @min_d = '00'
	
	IF @he>0
		SET @he=@he-1

		
	IF @mins = 1 or @mins=15
		SET @min_d = '00';
	ELSE IF @mins = 2 or @mins=30
		SET @min_d = '15';
	ELSE IF @mins = 3 or @mins=45
		SET @min_d = '30';
	ELSE IF @mins = 4 or @mins=60
		SET @min_d = '45';	
	
	SELECT 	@granularity = granularity FROM source_price_curve_def spcd WHERE source_curve_def_id=@curve_source_value_id

	SET @as_of_date_eom = CASE WHEN @granularity = 980 THEN DATEADD(m,1,CAST(CONVERT(VARCHAR(7),@as_of_date,120)+'-01' AS DATETIME))-1
						   WHEN @granularity = 991 THEN CAST(YEAR(@as_of_date) AS VARCHAR) + '-' +CASE DATEPART(q,@as_of_date) WHEN 1 THEN '03-31' WHEN 2 THEN '06-30' WHEN 3 THEN '10-31' ELSE '12-31' END
						   WHEN @granularity = 992 THEN CAST(YEAR(@as_of_date) AS VARCHAR) + '-' +CASE DATEPART(q,@as_of_date) WHEN 1 THEN '06-30' WHEN 2 THEN '06-30' ELSE '12-31' END 
						   WHEN @granularity = 993 THEN CAST(YEAR(@as_of_date) AS VARCHAR) + '-' +'12-31' END

	
	IF ((@granularity IN(980) AND ((MONTH(@maturity_date) = MONTH(@as_of_date) AND YEAR(@maturity_date) = YEAR(@as_of_date) AND @maturity_date<=@as_of_date) OR (MONTH(@maturity_date) <> MONTH(@as_of_date) AND @maturity_date<@as_of_date)))
		OR((@granularity IN(991) AND ((DATEPART(q, @maturity_date) = DATEPART(q, @as_of_date) AND @as_of_date>=@as_of_date_eom AND @maturity_date<@as_of_date) OR (DATEPART(q, @maturity_date) <> DATEPART(q, @as_of_date) AND @maturity_date<@as_of_date))))
		OR((@granularity IN(992) AND ((CASE WHEN DATEPART(q, @maturity_date) IN(1,2) THEN 1 ELSE 2 END = CASE WHEN DATEPART(q, @as_of_date) IN(1,2) THEN 1 ELSE 2 END AND @as_of_date>=@as_of_date_eom AND @maturity_date<@as_of_date) OR (CASE WHEN DATEPART(q, @maturity_date) IN(1,2) THEN 1 ELSE 2 END <> CASE WHEN DATEPART(q, @as_of_date) IN(1,2) THEN 1 ELSE 2 END AND @maturity_date<@as_of_date))))
		OR((@granularity IN(993) AND ((YEAR(@maturity_date) = YEAR(@as_of_date) AND @as_of_date>=@as_of_date_eom AND @maturity_date<@as_of_date) OR (YEAR(@maturity_date) <> YEAR(@as_of_date) AND @maturity_date<@as_of_date))))
		OR(@granularity IN(981,982,987) AND  @maturity_date<=@as_of_date))					

	BEGIN

		SELECT	@settlement_curve_id = ISNULL(spcd_s.source_curve_def_id, spcd.source_curve_def_id), 
				@settlement_maturity_date = CASE WHEN (hg.hol_date IS NULL AND 
					ISNULL(spcd_s.Granularity, spcd.Granularity) IN(981,982,987,989)) THEN @maturity_date ELSE hg.hol_date END, 
				@pnl_as_of_date = CASE WHEN (hg.hol_date IS NULL AND 
					ISNULL(spcd_s.Granularity, spcd.Granularity) IN(981,982,987,989)) THEN @maturity_date ELSE hg.exp_date END, 
				@settlement_granularity = spcd.Granularity	 
		FROM 
			 source_price_curve_def spcd LEFT  JOIN
			 source_price_curve_def spcd_s ON spcd_s.source_curve_def_id  = spcd.settlement_curve_id LEFT  JOIN
			 holiday_group hg ON hg.hol_group_value_id = ISNULL(spcd_s.exp_calendar_id, spcd.exp_calendar_id)
		WHERE spcd.source_curve_def_id = @curve_source_value_id AND
			 (hg.hol_date IS NULL OR
			  hg.hol_date = @maturity_date_var	)


		SELECT @maturity_date_var = CASE WHEN @settlement_granularity IN (980) THEN CONVERT(VARCHAR(8),@maturity_date,120) + '01'
					 WHEN @settlement_granularity IN (991) THEN CAST(YEAR(@maturity_date) AS VARCHAR) + '-' + CAST(DATEPART(q, @maturity_date) AS VARCHAR) + '-01'
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
			,@maturity_date_981=@maturity_date,
			@maturity_date_991 =CAST(YEAR(@maturity_date) AS VARCHAR) + '-' + CAST(DATEPART(q, @maturity_date) AS VARCHAR) + '-01'
			,@maturity_date_993 =CAST(YEAR(@maturity_date) AS VARCHAR) + '-01-01' 
			,@maturity_date_var =@maturity_date
														
													
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
	return (@x * ISNULL(@volume_mult, 1))
END
