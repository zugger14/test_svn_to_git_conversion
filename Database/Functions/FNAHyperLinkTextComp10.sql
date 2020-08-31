/***********************************************************************************************/
/* Author	   : Vishwas Khanal																   */
/* Date		   : 27.Nov.2008																   */
/* Purpose     : For the Enhancement on "View status on Compliacne Activities"				   */
/* Dependencies: spa_getRiskControlDependencyHierarchy.sql									   */
/* Key         : VK01CT																		   */
/***********************************************************************************************/

IF EXISTS (SELECT 'X' FROM sys.objects WHERE TYPE = 'fn'and NAME = 'FNAHyperLinkTextComp10')
BEGIN
	DROP FUNCTION dbo.FNAHyperLinkTextComp10
END
GO
CREATE function dbo.FNAHyperLinkTextComp10(@func_id VARCHAR(50),@label VARCHAR(500),@arg1 VARCHAR(50),@arg2 VARCHAR(50),@arg3 VARCHAR(50),@asofdate VARCHAR(50),@asofdate_to VARCHAR(50))
RETURNS VARCHAR(500) AS
BEGIN
	DECLARE @hyper_text VARCHAR(500)

	SET @hyper_text='<span style=cursor:hand onClick=openHierarchyHyperLinkComp('+@func_id+','+@arg1+','+@arg2+','+@arg3+','''+@asofdate+''','''+@asofdate_to+''')><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'

	RETURN @hyper_text
END	


