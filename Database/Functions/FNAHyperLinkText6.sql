if object_id('[dbo].[FNAHyperLinkText6]','fn') is not null
DROP function [dbo].[FNAHyperLinkText6]
go
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


CREATE function [dbo].[FNAHyperLinkText6](@label varchar(500),@arg1 varchar(50),@arg2 varchar(50),@arg3 varchar(50), @approved int=null)
returns varchar(500) as
begin
declare @hyper_text varchar(500)

set @hyper_text='<span style=cursor:hand onClick=openMsgWindow('+ @arg1+ ',''' + @arg2 + ''','''+ @arg3+ ''',' + cast(@approved as varchar) +',''r'')><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'

return @hyper_text
end



























