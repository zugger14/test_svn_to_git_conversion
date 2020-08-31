IF OBJECT_ID('FNATRMWinHyperlink', 'FN') IS NOT NULL 
	DROP FUNCTION dbo.FNATRMWinHyperlink 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
	Function to build hyperlink from given argument

	Parameters
	@flag : Flag
	@func_id : Func Id
	@label : Label
	@arg1 : Arg1
	@arg2 : Arg2
	@arg3 : Arg3
	@arg4 : Arg4
	@arg5 : Arg5
	@arg6 : Arg6
	@arg7 : Arg7
	@arg8 : Arg8
	@arg9 : Arg9
	@arg10 : Arg10
	@asofdate : As of Date
	@asofdate_to : As of Date To
	@click_type : 0 - 'on click' else 'on double click'

	Return: Hyperlink Text
*/
CREATE FUNCTION [dbo].[FNATRMWinHyperlink] (
	@flag		 CHAR(1),
	@func_id	 VARCHAR(50),
	@label		 NVARCHAR(500)	=	NULL,
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
	@asofdate_to VARCHAR(50)	=	NULL,
	@click_type  INT			= 0
)
RETURNS NVARCHAR(500) AS
BEGIN	

	IF @arg1 IS NULL
	    SELECT @arg1 = 'NULL'
	
	IF @arg2 IS NULL
	    SELECT @arg2 = 'NULL'
	
	IF @arg3 IS NULL
	    SELECT @arg3 = 'NULL'
	
	IF @arg4 IS NULL
	    SELECT @arg4 = 'NULL'
	
	IF @arg5 IS NULL
	    SELECT @arg5 = 'NULL'
	
	IF @arg6 IS NULL
	    SELECT @arg6 = 'NULL'
	
	IF @arg7 IS NULL
	    SELECT @arg7 = 'NULL'
	
	IF @arg8 IS NULL
	    SELECT @arg8 = 'NULL'
	
	IF @arg9 IS NULL
	    SELECT @arg9 = 'NULL'
	
	IF @arg10 IS NULL
	    SELECT @arg10 = 'NULL'
	
	IF @asofdate IS NULL
	    SELECT @asofdate = 'NULL'
	
	IF @asofdate_to IS NULL
	    SELECT @asofdate_to = 'NULL'
	
	DECLARE @hyper_text NVARCHAR(500)
	DECLARE @on_click_type VARCHAR(50)

	IF @click_type = 0
		SET @on_click_type = 'onClick' 
	ELSE 
		SET @on_click_type = 'ondblclick'
	
	SELECT @hyper_text = 
		CASE @flag 
			WHEN 'a' THEN '<span style="cursor:pointer" '+ @on_click_type + '="window.top.TRMWinHyperlink('+@func_id+','+@arg1+','''+@arg2+''','''+@arg3+''','''+@arg4+''','''+@arg5+''','''+@arg6+''','''+@arg7+''','''+@arg8+''','''+@arg9+''','''+@arg10+''','''+@asofdate+''','''+@asofdate_to+''')"><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'
			WHEN 'b' THEN '<span style="cursor:pointer" '+ @on_click_type + '="window.top.TRMWinHyperlink('+@func_id+','+@arg1+','''  +@arg2+''',null,null,null,null,null)"><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'						  
			WHEN 'c' THEN '<span style="cursor:pointer" '+ @on_click_type + '="window.top.TRMWinHyperlink('+@func_id+','+@arg1+','''+@arg2+''','''+@arg3+''',null,null,null,null)"><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'
			WHEN 'd' THEN '<span style="cursor:pointer" '+ @on_click_type + '="window.top.TRMWinHyperlink('+@func_id+','+@arg1+','''+@arg2+''','''+@arg3+''',null,null,null,null)"><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'
			WHEN 'e' THEN '<span style="cursor:pointer" '+ @on_click_type + '="window.top.TRMWinHyperlink('+@func_id+','+@arg1+','''+@arg2+''','''+@arg3+''','''+@arg4+''',null,null,null)"><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'
			WHEN 'f' THEN '<span style="cursor:pointer" '+ @on_click_type + '="window.top.TRMWinHyperlink('+@func_id+','+@arg1+','  +@arg2+','+@arg3+',null,null,'''+@asofdate+''','''+@asofdate_to+''')"><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'
			WHEN 'g' THEN '<span style="cursor:pointer" '+ @on_click_type + '="window.top.TRMWinHyperlink('+@func_id+','+@arg1+','''+@arg2+''','''+@arg3+''','''+@arg4+''','''+@arg5+''',null,null)"><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'
			WHEN 'i' THEN '<span style="cursor:pointer" '+ @on_click_type + '="window.top.TRMWinHyperlink('+@func_id+','+@arg1+','''+@arg2+''','''+@arg3+''')"><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'
			WHEN 'j' THEN '<span style="cursor:pointer" '+ @on_click_type + '="window.top.TRMWinHyperlink('+@func_id+','+@arg1+','''+@arg2+''','''+@arg3+''','''+@arg4+''','''+@arg5+''','''+@arg6+''','''+@arg7+''','''+@arg8+''','''+@arg9+''','''+@arg10+''','''+@asofdate+''','''+@asofdate_to+''')"><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'
			WHEN 'k' THEN '<span style="cursor:pointer" '+ @on_click_type + '="window.top.TRMWinHyperlink('+@func_id+','''+@arg1+''','''+@arg2+''','''+@arg3+''','''+@arg4+''','''+@arg5+''','''+@arg6+''','''+@arg7+''','''+@arg8+''','''+@arg9+''','''+@arg10+''','''+@asofdate+''','''+@asofdate_to+''')"><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'			
			WHEN 'm' THEN '<span style="cursor:pointer" '+ @on_click_type + '="call_from_hyperlink('+@func_id+','+@arg1+','''+@arg2+''','''+@arg3+''','''+@arg4+''','''+@arg5+''','''+@arg6+''','''+@arg7+''','''+@arg8+''','''+@arg9+''','''+@arg10+''','''+@asofdate+''','''+@asofdate_to+''')"><font color=#0000ff><u><l>'+ @label +'</l></u></font></span>'			
			
			ELSE ''
		END	
	
	RETURN @hyper_text
END	



