
IF OBJECT_ID('FNATrmHyperlink', 'FN') IS NOT NULL 
	
DROP FUNCTION dbo.FNATrmHyperlink 
	
/****** Object:  UserDefinedFunction [dbo].[FNARRelativePeriod]    Script Date: 10/30/2009 10:24:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create FUNCTION [dbo].[FNATrmHyperlink]
(
	@flag		 CHAR(1),
	@func_id	 VARCHAR(50),
	@label		 VARCHAR(500)	=	NULL,
	@arg1		 VARCHAR(50)	=	NULL,
	@arg2		 VARCHAR(50)	=	NULL,
	@arg3		 VARCHAR(50)	=	NULL,
	@arg4		 VARCHAR(50)	=	NULL,
	@arg5		 VARCHAR(50)	=	NULL,
	@arg6		 VARCHAR(50)	=	NULL,
	@arg7		 VARCHAR(50)	=	NULL,
	@arg8		 VARCHAR(50)	=	NULL,
	@arg9		 VARCHAR(50)	=	NULL,
	@arg10		 VARCHAR(50)	=	NULL,
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

	if @arg1 is null select @arg1 = 'NULL'
	if @arg2 is null select @arg2 = 'NULL'
	if @arg3 is null select @arg3 = 'NULL'
	if @arg4 is null select @arg4 = 'NULL'
	if @arg5 is null select @arg5 = 'NULL'
	if @arg6 is null select @arg6 = 'NULL'
	if @arg7 is null select @arg7 = 'NULL'
	if @arg8 is null select @arg8 = 'NULL'
	if @arg9 is null select @arg9 = 'NULL'
	if @arg10 is null select @arg10 = 'NULL'
	if @asofdate is null select @asofdate = 'NULL'
	if @asofdate_to is null select @asofdate_to = 'NULL'
	
	DECLARE @hyper_text VARCHAR(500)
	
	SELECT @hyper_text = 
		CASE @flag 
			WHEN 'a' THEN '<span style="cursor:pointer" onClick=TRMHyperlink('+@func_id+','+@arg1+','''+@arg2+''','''+@arg3+''','''+@arg4+''','''+@arg5+''','''+@arg6+''','''+@arg7+''','''+@arg8+''','''+@arg9+''','''+@arg10+''','''+@asofdate+''','''+@asofdate_to+''')><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'
			WHEN 'b' THEN '<span style="cursor:pointer" onClick=TRMHyperlink('+@func_id+','+@arg1+','''  +@arg2+''',null,null,null,null,null)><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'						  
			WHEN 'c' THEN '<span style="cursor:pointer" onClick=TRMHyperlink('+@func_id+','+@arg1+','''+@arg2+''','''+@arg3+''',null,null,null,null)><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'
			WHEN 'd' THEN '<span style="cursor:pointer" onClick=TRMHyperlink('+@func_id+','+@arg1+','''+@arg2+''','''+@arg3+''',null,null,null,null)><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'
			WHEN 'e' THEN '<span style="cursor:pointer" onClick=TRMHyperlink('+@func_id+','+@arg1+','''+@arg2+''','''+@arg3+''','''+@arg4+''',null,null,null)><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'
			WHEN 'f' THEN '<span style="cursor:pointer" onClick=TRMHyperlink('+@func_id+','+@arg1+','  +@arg2+','+@arg3+',null,null,'''+@asofdate+''','''+@asofdate_to+''')><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'
			WHEN 'g' THEN '<span style="cursor:pointer" onClick=TRMHyperlink('+@func_id+','+@arg1+','''+@arg2+''','''+@arg3+''','''+@arg4+''','''+@arg5+''',null,null)><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'
			WHEN 'i' THEN '<span style="cursor:pointer" onClick="TRMHyperlink('+@func_id+','+@arg1+','''+@arg2+''','''+@arg3+''')"><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'
			WHEN 'j' THEN '<span style="cursor:pointer" onClick=TRMHyperlink('+@func_id+','+@arg1+','''+@arg2+''','''+@arg3+''','''+@arg4+''','''+@arg5+''','''+@arg6+''','''+@arg7+''','''+@arg8+''','''+@arg9+''','''+@arg10+''','''+@asofdate+''','''+@asofdate_to+''')><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'
			WHEN 'k' THEN '<span style="cursor:pointer" onClick=TRMHyperlink('+@func_id+','''+@arg1+''','''+@arg2+''','''+@arg3+''','''+@arg4+''','''+@arg5+''','''+@arg6+''','''+@arg7+''','''+@arg8+''','''+@arg9+''','''+@arg10+''','''+@asofdate+''','''+@asofdate_to+''')><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'			
			ELSE ''
		END	
	
	RETURN @hyper_text
END	



