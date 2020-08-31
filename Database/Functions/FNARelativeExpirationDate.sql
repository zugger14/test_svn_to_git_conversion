/****** Object:  UserDefinedFunction [dbo].[FNARLagcurve]    Script Date: 06/30/2009 18:13:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARelativeExpirationDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARelativeExpirationDate]
/****** Object:  UserDefinedFunction [dbo].[FNARLagcurve]    Script Date: 06/30/2009 18:13:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNARelativeExpirationDate](
	@as_of_date DATETIME,
	@curve_Id INT,
	@Relative_Year int, --( could be 0 or negative values. Negative value will use the prior year values)
	@expiration_type VARCHAR(8), --1=Exact date,  2=relative to end of month, 3=relative to end of month business days, 4=relative to expiration date,5= relative to expiration date business days
	@expiration_value VARCHAR(30)
)
RETURNS DATETIME
AS
BEGIN


	SET @as_of_date=DATEADD(YEAR, @Relative_Year,@as_of_date)	
	DECLARE @expiration_date DATETIME
	
--Exact Date = ED
--Relative to End of Month = RM
--Relative to End of Month Business Days = RBD
--Relative to Expiration Date = RED
--Relative to Expiration date business days = REBD
		
	if @expiration_type='ED' AND ISDATE(@expiration_value)=1
		set @expiration_date=@expiration_value
	else if @expiration_type='RM'
		set @expiration_date=dateadd(day,cast(ISNULL(@expiration_value,0) as int),dateadd(month,1,cast(convert(varchar(8),@as_of_date,120)+'01' AS DATETIME))-1)
	else if @expiration_type='RBD'
		select @expiration_date=max(term_date) from hour_block_term where hol_date is  null and DATENAME(weekday, term_date) not in ('Sunday','Saturday')
			AND term_date<=dateadd(day,cast(ISNULL(@expiration_value,0) as int),dateadd(month,1,cast(convert(varchar(8),@as_of_date,120)+'01' AS DATETIME))-1)
	else if @expiration_type='RED'
			SELECT @expiration_date= dateadd(day,cast(ISNULL(@expiration_value,0) as int),ISNULL(exp_date,@as_of_date)) 
			FROM source_price_curve_def spcd 
			LEFT JOIN source_price_curve_def spcd1 ON spcd1.source_curve_def_id=spcd.settlement_curve_id
			left join holiday_group hd
			ON	hd.hol_date=@as_of_date
				and ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id)=hd.hol_group_value_id
			WHERE
				spcd.source_curve_def_id=@curve_Id	
	else if @expiration_type='REBD'  AND @expiration_value IS NOT NULL
	BEGIN 
		--SELECT @expiration_date= ISNULL(exp_date,@as_of_date) 
		--FROM source_price_curve_def spcd 
		--		LEFT JOIN source_price_curve_def spcd1 ON spcd1.source_curve_def_id=spcd.settlement_curve_id
		--		left join holiday_group hd
		--	ON ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id)=hd.hol_group_value_id
		--		AND hd.hol_date=@as_of_date
		--WHERE
		--	spcd.source_curve_def_id=@curve_Id	

		--select @expiration_date=dateadd(day,cast(ISNULL(@expiration_value,0) as int),max(term_date)) from hour_block_term where hol_date is  null and DATENAME(weekday, term_date) not in ('Sunday','Saturday')
		--	AND term_date<=@expiration_date
			
			
		;WITH CTE AS(
		SELECT 
			row_number()OVER(ORDER BY exp_date DESC) seq_number,
			spcd.source_curve_def_id,
			exp_date
		FROM
		source_price_curve_def spcd 
				LEFT JOIN source_price_curve_def spcd1 ON spcd1.source_curve_def_id=spcd.settlement_curve_id
				left join holiday_group hd
			ON ISNULL(spcd.exp_calendar_id,spcd1.exp_calendar_id)=hd.hol_group_value_id
				AND @as_of_date BETWEEN hd.hol_date AND ISNULL(hd.hol_date_to,hol_date)
			WHERE
			spcd.source_curve_def_id=@curve_Id		
		)
		
		SELECT @expiration_date=exp_date FROM CTE WHERE	seq_number = ABS(@expiration_value)+1
	END	
	--else
	--	SELECT @expiration_date= ISNULL(exp_date,@as_of_date) FROM source_price_curve_def spcd left join holiday_group hd
	--		on spcd.source_curve_def_id=@curve_Id AND hd.hol_date=@as_of_date
	--		and spcd.exp_calendar_id=hd.hol_group_value_id;
			

	RETURN(@expiration_date)
END

