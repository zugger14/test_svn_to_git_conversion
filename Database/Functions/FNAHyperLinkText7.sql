/****** Object:  function [dbo].[FNAHyperLinkText7]    Script Date: 10/19/2008 11:49:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAHyperLinkText7]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
Drop function [dbo].[FNAHyperLinkText7]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go








CREATE function [dbo].[FNAHyperLinkText7](@func_id varchar(50),@label varchar(500),@arg1 varchar(50),@arg2 varchar(50),@arg3 varchar(50))
returns varchar(500) as
begin
declare @hyper_text varchar(500)

set @hyper_text='<span style=cursor:hand onClick=parent.openHyperLinkMore('+@func_id+','+@arg1+','''+@arg2+''','''+@arg3+''')><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'

return @hyper_text
end
