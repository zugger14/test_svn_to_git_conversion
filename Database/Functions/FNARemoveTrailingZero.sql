IF OBJECT_ID(N'dbo.FNARemoveTrailingZero', N'FN') IS NOT NULL
	DROP FUNCTION dbo.FNARemoveTrailingZero

GO

/***********************************MODIFICATION HISTORY**********************************/
/* Author      : Vishwas Khanal															 */
/* Date		   : 26.Jan.2009															 */
/* Description : Removes the Trailing Zeros from the Numeric Field 						 */
/* Purpose     : Removal of Exponential in the View Price and other UIs					 */
/*****************************************************************************************/
-- SELECT dbo.FNARemoveTrailingZero(12.100000000) Output : 12.1
-- SELECT dbo.FNARemoveTrailingZero(12.00001)     Output : 12.00001
CREATE FUNCTION dbo.FNARemoveTrailingZero (@num NUMERIC(38,15))
RETURNS VARCHAR(38)
AS 
BEGIN
	RETURN REPLACE(RTRIM(REPLACE(REPLACE(RTRIM(REPLACE(@num,'0',' ')),' ','0'),'.',' ')),' ','.')	
END






