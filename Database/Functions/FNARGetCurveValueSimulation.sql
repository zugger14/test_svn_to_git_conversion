/****** Object:  UserDefinedFunction [dbo].[FNARGetCurveValueSimulation]    Script Date: 03/23/2009 22:51:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARGetCurveValueSimulation]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARGetCurveValueSimulation]
GO
/****** Object:  UserDefinedFunction [dbo].[FNARGetCurveValueSimulation]    Script Date: 03/23/2009 22:51:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- select dbo.FNARGetCurveValueSimulation('2011-07-04','2011-06-30', 10, 1)

CREATE FUNCTION [dbo].[FNARGetCurveValueSimulation] (@maturity_date datetime,@as_of_date datetime, @curve_id int, @volume_mult float,@curve_source_value_id INT,@curve_shift_val float ,@curve_shift_per float)
RETURNS float AS  
BEGIN 
	declare @x as float
	declare @settlement_curve_id int
	declare @settlement_maturity_date datetime
	declare @pnl_as_of_date datetime
	declare @settlement_granularity int 

	select @curve_shift_val=isnull(@curve_shift_val,0),@curve_shift_per=isnull(@curve_shift_per,1)





	If @maturity_date <= @as_of_date
	Begin
		select	@settlement_curve_id = isnull(spcd_s.source_curve_def_id, spcd.source_curve_def_id), 
				@settlement_maturity_date = CASE WHEN (hg.hol_date IS NULL AND 
					isnull(spcd_s.source_curve_def_id, spcd.source_curve_def_id) = 981) THEN @maturity_date ELSE hg.hol_date END, 
				@pnl_as_of_date = CASE WHEN (hg.hol_date IS NULL AND 
					isnull(spcd_s.source_curve_def_id, spcd.source_curve_def_id) = 981) THEN @maturity_date ELSE hg.exp_date END, 
				@settlement_granularity = spcd.Granularity	 	 
		from 
			 source_price_curve_def spcd LEFT  JOIN
			 source_price_curve_def spcd_s ON spcd_s.source_curve_def_id  = spcd.settlement_curve_id LEFT  JOIN
			 holiday_group hg ON hg.hol_group_value_id = ISNULL(spcd_s.exp_calendar_id, spcd.exp_calendar_id)
		where spcd.source_curve_def_id = @curve_id AND
			 (hg.hol_date IS NULL OR
			  hg.hol_date = 
						CASE WHEN spcd.Granularity IN (980) THEN CONVERT(varchar(8),@maturity_date,120) + '01'
							 WHEN spcd.Granularity IN (981) THEN @maturity_date
							 WHEN spcd.Granularity IN (991) THEN cast(Year(@maturity_date) as varchar) + '-' + cast(datepart(q, @maturity_date) as varchar) + '-01'
							 WHEN spcd.Granularity IN (993) THEN cast(Year(@maturity_date) as varchar) + '-01-01' 
						ELSE @maturity_date END	)
						
		If @pnl_as_of_date IS NULL
		Begin
			SET @pnl_as_of_date = 
						CASE WHEN @settlement_granularity IN (980) THEN CONVERT(varchar(8),@maturity_date,120) + '01'
							WHEN @settlement_granularity IN (981) THEN @maturity_date
							WHEN @settlement_granularity IN (991) THEN cast(Year(@maturity_date) as varchar) + '-' + cast(datepart(q, @maturity_date) as varchar) + '-01'
							WHEN @settlement_granularity IN (993) THEN cast(Year(@maturity_date) as varchar) + '-01-01' 
						ELSE @maturity_date END
			SET @settlement_maturity_date = @pnl_as_of_date
		End

		select @x = (spc.curve_value+ @curve_shift_val) * @curve_shift_per
		from 
				source_price_curve_simulation spc 
		where 
				spc.source_curve_def_id = @settlement_curve_id and
				spc.curve_source_value_id=@curve_source_value_id and 
				spc.as_of_date = @pnl_as_of_date and
				spc.assessment_curve_type_value_id in (77,78) and 
				spc.curve_source_value_id = @curve_source_value_id AND 
				spc.maturity_date = @settlement_maturity_date				
	End
	Else
	Begin
		select @x = (coalesce(spc.curve_value, spc_p1.curve_value, spc_p2.curve_value, spc_p3.curve_value)+ @curve_shift_val) * @curve_shift_per
		from source_price_curve_def spcd left join 
			 source_price_curve_def spcd1 ON spcd1.source_curve_def_id = spcd.proxy_source_curve_def_id left join 
			 source_price_curve_def spcd2 ON spcd2.source_curve_def_id = spcd.monthly_index left join 
			 source_price_curve_def spcd3 ON spcd3.source_curve_def_id = spcd.proxy_curve_id3 left join 
			 source_price_curve_simulation spc ON 
				spcd.source_curve_def_id = spc.source_curve_def_id and
				spc.curve_source_value_id=@curve_source_value_id and 
				spc.as_of_date = @as_of_date and
				spc.assessment_curve_type_value_id in (77,78) and 
				spc.curve_source_value_id = @curve_source_value_id AND 
				spc.maturity_date = 
					CASE WHEN spcd.Granularity IN (980) THEN CONVERT(varchar(8),@maturity_date,120) + '01'
						 WHEN spcd.Granularity IN (981) THEN @maturity_date
						 WHEN spcd.Granularity IN (991) THEN cast(Year(@maturity_date) as varchar) + '-' + cast(datepart(q, @maturity_date) as varchar) + '-01'
						 WHEN spcd.Granularity IN (993) THEN cast(Year(@maturity_date) as varchar) + '-01-01' 
					ELSE @maturity_date END LEFT JOIN
			 source_price_curve_simulation spc_p1 ON 
				spcd.proxy_source_curve_def_id = spc_p1.source_curve_def_id and
				spc_p1.curve_source_value_id=@curve_source_value_id and 
				spc_p1.as_of_date = @as_of_date and 
				spc_p1.assessment_curve_type_value_id in (77,78) and 
				spc_p1.curve_source_value_id = @curve_source_value_id AND 
				spc_p1.maturity_date = 
					CASE WHEN spcd1.Granularity IN (980) THEN CONVERT(varchar(8),@maturity_date,120) + '01'
						 WHEN spcd1.Granularity IN (981) THEN @maturity_date
						 WHEN spcd1.Granularity IN (991) THEN cast(Year(@maturity_date) as varchar) + '-' + cast(datepart(q, @maturity_date) as varchar) + '-01'
						 WHEN spcd1.Granularity IN (993) THEN cast(Year(@maturity_date) as varchar) + '-01-01' 
					ELSE @maturity_date END LEFT JOIN		 
			 source_price_curve_simulation spc_p2 ON 
				spcd.monthly_index = spc_p2.source_curve_def_id and
				spc_p2.as_of_date = @as_of_date and 
				spc_p2.curve_source_value_id=@curve_source_value_id and 
				spc_p2.assessment_curve_type_value_id in (77,78) and 
				spc_p2.curve_source_value_id = @curve_source_value_id AND 
				spc_p2.maturity_date = 
					CASE WHEN spcd2.Granularity IN (980) THEN CONVERT(varchar(8),@maturity_date,120) + '01'
						 WHEN spcd2.Granularity IN (981) THEN @maturity_date
						 WHEN spcd2.Granularity IN (991) THEN cast(Year(@maturity_date) as varchar) + '-' + cast(datepart(q, @maturity_date) as varchar) + '-01'
						 WHEN spcd2.Granularity IN (993) THEN cast(Year(@maturity_date) as varchar) + '-01-01' 
					ELSE @maturity_date END LEFT JOIN				
			 source_price_curve_simulation spc_p3 ON 
				spcd.proxy_curve_id3 = spc_p3.source_curve_def_id and
				spc_p3.curve_source_value_id=@curve_source_value_id and 
				spc_p3.as_of_date = @as_of_date and 
				spc_p3.assessment_curve_type_value_id in (77,78) and 
				spc_p3.curve_source_value_id = @curve_source_value_id AND 
				spc_p3.maturity_date = 
					CASE WHEN spcd3.Granularity IN (980) THEN CONVERT(varchar(8),@maturity_date,120) + '01'
						 WHEN spcd3.Granularity IN (981) THEN @maturity_date
						 WHEN spcd3.Granularity IN (991) THEN cast(Year(@maturity_date) as varchar) + '-' + cast(datepart(q, @maturity_date) as varchar) + '-01'
						 WHEN spcd3.Granularity IN (993) THEN cast(Year(@maturity_date) as varchar) + '-01-01' 
					ELSE @maturity_date END		
			
		where 	spcd.source_curve_def_id = @curve_id 
		End	
		
		
	--return isnull(@x, 0)
	return (@x * isnull(@volume_mult, 1))
END








