/****** Object:  UserDefinedFunction [dbo].[FNARRelativeDailyCurve]    Script Date: 03/23/2009 22:51:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARRelativeDailyCurve]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARRelativeDailyCurve]
GO
/****** Object:  UserDefinedFunction [dbo].[FNARRelativeDailyCurve]    Script Date: 03/23/2009 22:51:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- select dbo.[FNARRelativeDailyCurve]('2013-07-08', 46, 1)

CREATE FUNCTION [dbo].[FNARRelativeDailyCurve] (@term_start DATETIME,@as_of_date datetime, @curve_source_def_id int,@offset INT)
RETURNS float AS  


--DECLARE @term_start DATETIME='2013-07-17',@as_of_date DATETIME='2013-07-30', @curve_source_def_id INT=242,@offset INT=1
BEGIN 
	DECLARE @curve_vaue FLOAT,@maturity_date DATETIME,@exp_calendar_id int

	IF @offset IS NULL 
		SET @offset = 0

	if @term_start<=@as_of_date --settle
	begin
	
		select @exp_calendar_id=isnull(spcd1.exp_calendar_id,spcd.exp_calendar_id) from source_price_curve_def spcd 
		left join source_price_curve_def spcd1 on spcd1.source_curve_def_id=spcd.settlement_curve_id
			where spcd.source_curve_def_id = @curve_source_def_id
			
		if @offset>0
			select @maturity_date= max(a.hol_date)
			from (
				select top(@offset) hol_date from holiday_group where hol_group_value_id = @exp_calendar_id
					and hol_date>@term_start
				order by 1 
			) a
		else if @offset<0
			select @maturity_date= min(a.hol_date)
			from (
				select top(@offset) hol_date from holiday_group where hol_group_value_id = @exp_calendar_id
					and hol_date<@term_start
				order by 1 desc
			) a	
			
		SET @as_of_date=@maturity_date
		
		SELECT @curve_vaue =  curve_value FROM source_price_curve_def spcd 
		inner join source_price_curve spc on spc.source_curve_def_id=isnull(spcd.settlement_curve_id,spcd.source_curve_def_id)
		WHERE spcd.source_curve_def_id = @curve_source_def_id
			AND assessment_curve_type_value_id in (77,78)
			AND curve_source_value_id = 4500 	
			AND as_of_date = @as_of_date
			AND maturity_date = @maturity_date				
				

	end
	else 	 --forwad mtm
	BEGIN
		
		SET @maturity_date= isnull(@maturity_date,DATEADD(d,@offset,@term_start))
		
		SELECT @curve_vaue = coalesce(spc.curve_value,spc2.curve_value,spc3.curve_value,spc4.curve_value)  
		FROM  source_price_curve_Def spcd LEFT  JOIN source_price_curve_def spcd2 ON spcd.proxy_source_curve_def_id=spcd2.source_curve_def_id
			LEFT  JOIN source_price_curve_def spcd3 ON spcd.monthly_index=spcd3.source_curve_def_id
			LEFT  JOIN source_price_curve_def spcd4 ON spcd.proxy_curve_id3=spcd4.source_curve_def_id
			LEFT JOIN source_price_curve spc ON spcd.source_curve_def_id=spc.source_curve_def_id
				AND spc.curve_Source_value_id=4500	AND spc.as_of_date =@as_of_date
				and spc.maturity_date=
				case  spcd.Granularity when 982 then @maturity_date when 981 then @maturity_date when 980 then cast(convert(varchar(8),@maturity_date,120)+'01' as date)
						when 991 then cast(convert(varchar(5),@maturity_date,120)+ cast(case datepart(q, @maturity_date) when 1 then 1 when 2 then 4 when 3 then 7 when 4 then 10 end as varchar)+'-01' as date)  when 992 then cast(convert(varchar(5),@maturity_date,120)+ cast(case when month(@maturity_date) < 7 then 1 else 7 end as varchar)+'-01' as date) when 993 then cast(convert(varchar(5),@maturity_date,120)+ '01-01' as date)
				end and spcd.settlement_curve_id is not null
			LEFT JOIN source_price_curve spc2 ON spcd2.source_curve_def_id=spc2.source_curve_def_id
				AND spc2.curve_Source_value_id=4500	AND spc2.as_of_date = @as_of_date
				and spc2.maturity_date=
				case  spcd2.Granularity when 982 then @maturity_date when 981 then @maturity_date when 980 then cast(convert(varchar(8),@maturity_date,120)+'01' as date)
					when 991 then cast(convert(varchar(5),@maturity_date,120)+ cast(case datepart(q, @maturity_date) when 1 then 1 when 2 then 4 when 3 then 7 when 4 then 10 end as varchar)+'-01' as date)  when 992 then cast(convert(varchar(5),@maturity_date,120)+ cast(case when month(@maturity_date) < 7 then 1 else 7 end as varchar)+'-01' as date) when 993 then cast(convert(varchar(5),@maturity_date,120)+ '01-01' as date)
				end 
			LEFT JOIN source_price_curve spc3 ON spcd3.source_curve_def_id=spc3.source_curve_def_id
				AND spc3.curve_Source_value_id=4500 AND spc3.as_of_date = @as_of_date
				and spc3.maturity_date=
				case  spcd3.Granularity when 982 then @maturity_date when 981 then @maturity_date when 980 then cast(convert(varchar(8),@maturity_date,120)+'01' as date)
					when 991 then cast(convert(varchar(5),@maturity_date,120)+ cast(case datepart(q, @maturity_date) when 1 then 1 when 2 then 4 when 3 then 7 when 4 then 10 end as varchar)+'-01' as date)  when 992 then cast(convert(varchar(5),@maturity_date,120)+ cast(case when month(@maturity_date) < 7 then 1 else 7 end as varchar)+'-01' as date) when 993 then cast(convert(varchar(5),@maturity_date,120)+ '01-01' as date)
				end 
			LEFT JOIN source_price_curve spc4 ON spcd4.source_curve_def_id=spc4.source_curve_def_id
				AND spc4.curve_Source_value_id=4500	AND spc4.as_of_date = @as_of_date
				and spc4.maturity_date=
				case  spcd4.Granularity when 982 then @maturity_date when 981 then @maturity_date when 980 then cast(convert(varchar(8),@maturity_date,120)+'01' as date)
					when 991 then cast(convert(varchar(5),@maturity_date,120)+ cast(case datepart(q, @maturity_date) when 1 then 1 when 2 then 4 when 3 then 7 when 4 then 10 end as varchar)+'-01' as date)  when 992 then cast(convert(varchar(5),@maturity_date,120)+ cast(case when month(@maturity_date) < 7 then 1 else 7 end as varchar)+'-01' as date) when 993 then cast(convert(varchar(5),@maturity_date,120)+ '01-01' as date)
				end 
		WHERE spcd.source_curve_def_id=@curve_source_def_id
			and coalesce(spc.assessment_curve_type_value_id,spc2.assessment_curve_type_value_id,spc3.assessment_curve_type_value_id,spc4.assessment_curve_type_value_id) in (77,78)
		
	END	
	
		--SELECT @curve_vaue
	RETURN (@curve_vaue)
END
