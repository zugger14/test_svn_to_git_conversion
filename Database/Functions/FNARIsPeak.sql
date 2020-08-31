/****** Object:  UserDefinedFunction [dbo].[FNARIsPeak]    Script Date: 05/02/2011 10:58:08 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARIsPeak]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARIsPeak]
/****** Object:  UserDefinedFunction [dbo].[FNARIsPeak]    Script Date: 05/02/2011 10:58:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARIsPeak](@contract_id int,@prod_date datetime,@he int)	
RETURNS float AS  
BEGIN 
		DECLARE @Week_day int
		DECLARE @ispeak int
		select @Week_day=DATEPART(dw,@prod_date)
		
		select @ispeak=	case 
							when @he=1 then Hr1
							when @he=2 then Hr2
							when @he=3 then Hr3
							when @he=4 then Hr4
							when @he=5 then Hr5
							when @he=6 then Hr6
							when @he=7 then Hr7
							when @he=8 then Hr8
							when @he=9 then Hr9
							when @he=10 then Hr10
							when @he=11 then Hr11
							when @he=12 then Hr12
							when @he=13 then Hr13
							when @he=14 then Hr14
							when @he=15 then Hr15
							when @he=16 then Hr16
							when @he=17 then Hr17
							when @he=18 then Hr18
							when @he=19 then Hr19
							when @he=20 then Hr20
							when @he=21 then Hr21
							when @he=22 then Hr22
							when @he=23 then Hr23
							when @he=24 then Hr24
					end
	from
		contract_group cg inner join hourly_block hb on cg.hourly_block=hb.block_value_id
		and week_day=@Week_day
	where 
		contract_id=@contract_id
	return @ispeak						
END













