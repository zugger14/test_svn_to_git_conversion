/*
Author		: Vishwas Khanal
Dated		: 24.June.2009
Description : Compliance Renovation
*/

IF OBJECT_ID ('[dbo].[FNAComplianceHyperlink]','FN') IS NOT NULL
DROP FUNCTION [dbo].[FNAComplianceHyperlink]
GO
CREATE FUNCTION [dbo].[FNAComplianceHyperlink]
(
	@flag		 CHAR(1),
	@func_id	 VARCHAR(50),
	@label		 VARCHAR(500)	=	NULL,
	@arg1		 VARCHAR(50)	=	NULL,
	@arg2		 VARCHAR(50)	=	NULL,
	@arg3		 VARCHAR(50)	=	NULL,
	@arg4		 VARCHAR(50)	=	NULL,
	@arg5		 VARCHAR(50)	=	NULL,
	@asofdate	 VARCHAR(50)	=	NULL,
	@asofdate_to VARCHAR(50)	=	NULL
)
RETURNS VARCHAR(500) AS
BEGIN	
	--Below are the flags against the previously used functions.
	-- a : FNAHyperLinkText
	-- b : FNAHyperLinkText2 / FNAHyperLinkText5
	-- c : FNAHyperLinkText7
	-- d : FNAHyperLinkTextComp3
	-- e : FNAHyperLinkText8
	-- f : FNAHyperLinkTextComp10
	-- g : FNAHyperLinkTextComp9
	-- h : FNAHyperLinkText5

	DECLARE @hyper_text VARCHAR(500)
	
	SELECT @hyper_text = 
		CASE @flag 
			WHEN 'a' THEN '<span style=cursor:hand onClick=complianceHyperlink('+@func_id+','+@arg1+',null,null,null,null,null,null)><font color=#0000ff><u>'+ @label +'</u></font></span>'
			WHEN 'b' THEN '<span style=cursor:hand onClick=complianceHyperlink('+@func_id+','+@arg1+','''  +@arg2+''',null,null,null,null,null)><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'						  
			WHEN 'c' THEN '<span style=cursor:hand onClick=complianceHyperlink('+@func_id+','+@arg1+','''+@arg2+''','''+@arg3+''',null,null,null,null)><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'
			WHEN 'd' THEN '<span style=cursor:hand onClick=complianceHyperlink('+@func_id+','+@arg1+','''+@arg2+''','''+@arg3+''',null,null,null,null)><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'
			WHEN 'e' THEN '<span style=cursor:hand onClick=complianceHyperlink('+@func_id+','+@arg1+','''+@arg2+''','''+@arg3+''','''+@arg4+''',null,null,null)><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'
			WHEN 'f' THEN '<span style=cursor:hand onClick=complianceHyperlink('+@func_id+','+@arg1+','  +@arg2+','+@arg3+',null,null,'''+@asofdate+''','''+@asofdate_to+''')><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'
			WHEN 'g' THEN '<span style=cursor:hand onClick=complianceHyperlink('+@func_id+','+@arg1+','''+@arg2+''','''+@arg3+''','''+@arg4+''','''+@arg5+''',null,null)><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'
			WHEN 'm' THEN '<span style=cursor:hand onClick=complianceHyperlink('+@func_id+','+@arg1+',null,null,null,null,null,null)>' -- This is used in compliance calendar.
			WHEN 'n' THEN '<span style=cursor:hand onClick=complianceHyperlink('+@func_id+',null,null,null,null,null,null,null)><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>' -- This is used in compliance calendar.

			ELSE ''
		END	
	
	RETURN @hyper_text
END	


