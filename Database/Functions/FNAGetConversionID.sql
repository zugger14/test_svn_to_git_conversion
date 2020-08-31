/****** Object:  UserDefinedFunction [dbo].[FNAGetConversionID]    Script Date: 08/20/2009 12:36:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetConversionID]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAGetConversionID]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

CREATE function [dbo].[FNAGetConversionID](
	@formula varchar(100),
	@input_id int
)
Returns int
AS
BEGIN
	declare @conv_type_id int
	declare @index int
	select @index=CHARINDEX('FNAEMSConv('+cast(@input_id as varchar),@formula)
	if @index<>0
	begin
		set @formula=REPLACE(@formula,'dbo.FNAEMSConv('+cast(@input_id as varchar)+',','')
		select @conv_type_id=substring(@formula,1,charindex(',',@formula,1)-1)
		
	end
	return @conv_type_id
END	

-- select dbo.FNAGetConversionID('dbo.FNAInput(28)',29)
-- select CHARINDEX('(29,','dbo.FNAEMSConv(29,1180,38,36)',0)

-- select substring('1180,38,36)',1,charindex(',','1180,38,36)',1)-1)
-- 
-- select charindex(',','1180,38,36)',1)




