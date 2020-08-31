IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAHyperLinkText2]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [FNAHyperLinkText2]
GO 
/****** Object:  UserDefinedFunction [dbo].[FNAHyperLinkText2]    Script Date: 09/15/2009 14:23:16 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAHyperLinkText2]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAHyperLinkText2]
GO 

CREATE function [dbo].FNAHyperLinkText2(@func_id varchar(50),@label varchar(500),@arg1 varchar(50),@arg2 varchar(150))
returns varchar(500) as
BEGIN
declare @hyper_text varchar(500)


set @hyper_text= case when CAST(@func_id AS INT)= 10161210 AND CAST(@arg1 AS float) < 0.00  then
	'<span style=cursor:hand onClick=openHyperLink('+@func_id+','+CAST(@arg1 AS VARCHAR)+','+CAST(@arg2 AS VARCHAR(150))+')>
	<font color=#FF0000><u><l>' +CAST(@label AS VARCHAR(500))+ '</l></u></font></span>'
when  @func_id = 10161210 AND CAST(@arg1 AS float) = 0.00 then 
	'<span style=cursor:hand onClick=openHyperLink('+@func_id +','+CAST(@arg1 AS VARCHAR)+','+CAST(@arg2 AS VARCHAR(150))+')>
	<font color=#000000><u><l>' +CAST(@label AS VARCHAR(500))+ '</l></u></font></span>'
ELSE
	'<span style=cursor:hand onClick=openHyperLink('+@func_id +','+CAST(@arg1 AS VARCHAR)+','+CAST(@arg2 AS VARCHAR(150))+')><font color=#0000ff><u><l>' +CAST(@label AS VARCHAR(500))+ '</l></u></font></span>'
END 

--set @hyper_text='<span style=cursor:hand onClick=openHyperLink('+@func_id+','+@arg1+','+@arg2+')><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'
return @hyper_text
end