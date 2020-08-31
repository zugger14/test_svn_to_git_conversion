if object_id('[dbo].[FNAHyperLinkText8]','fn') is not null
DROP function [dbo].[FNAHyperLinkText8]
go
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go











CREATE function [dbo].[FNAHyperLinkText8](@func_id varchar(50),@label varchar(500),@arg1 varchar(50),@arg2 varchar(50),@arg3 varchar(50),@arg4 varchar(50))
returns varchar(500) as
begin
declare @hyper_text varchar(500)

set @hyper_text='<span style=cursor:hand onClick=parent.openHyperLinkMoreComp('+@func_id+','+@arg1+','''+@arg2+''','''+@arg3+''','''+@arg4+''')><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'

return @hyper_text
end

