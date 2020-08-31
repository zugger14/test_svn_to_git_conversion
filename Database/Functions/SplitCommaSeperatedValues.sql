/***********************************MODIFICATION HISTORY**********************************/
/* Author      : Vishwas Khanal															 */
/* Date		   : 25.Dec.2008															 */
/* Description : Any comma separated string passed will return a table with the values   */
/* Purpose     : TRM Demo Requirement.													 */ 
/*****************************************************************************************/

-- SELECT item FROM dbo.SplitCommaSeperatedValues('asdas,asd,a,sd,a,sd,as,d,as,d,qwer,sgvd,fh,fy,uy,f,bzsd,a,se,a,sd,a,e,sdf,sdf,fu,f')

IF OBJECT_ID('dbo.SplitCommaSeperatedValues') IS NOT NULL
DROP FUNCTION dbo.SplitCommaSeperatedValues
GO

CREATE FUNCTION dbo.SplitCommaSeperatedValues
(@list AS VARCHAR(max))
RETURNS @items TABLE (item VARCHAR(max) NOT NULL)
AS
BEGIN
	
	INSERT INTO @items (item)
	SELECT item FROM dbo.FNASplit(@list, ',')
	
	RETURN
END

