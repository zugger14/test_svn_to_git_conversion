
/****** Object:  UserDefinedFunction [dbo].[FNAHyperLinkInput]    Script Date: 08/20/2009 12:37:33 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAHyperLinkInput]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAHyperLinkInput]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


CREATE function [dbo].[FNAHyperLinkInput](@label varchar(100),@frequency int,
@input_name varchar(500),
@estimate_type char(1),
@uom_id int,
@ems_input_id int,
@generator_id int,
@term_start varchar(20),
@forecast_type int)
returns varchar(500) as
begin
declare @hyper_text varchar(500)

set @hyper_text='<span style=cursor:hand onClick=''openEmissionInput('+cast(@ems_input_id as varchar)+','+cast(@generator_id as varchar)+',"'+@input_name+'","NULL",'+cast(@uom_id as varchar)+',"'+@term_start+'",'+cast(@frequency as varchar)+','+cast(@forecast_type as varchar)+')''><font color=blue><u><l>'+ @label +'<l></u></font></span>'

return @hyper_text
end






