/***********************************MODIFICATION HISTORY**********************************/
/* Author      : Narendra Shrestha														 */
/* Date		   : 22.Apr.2010															 */
/* Description : Add '.00' to input value												 */
/* Purpose     : Add '.00' in the View Price and other UIs								 */
/*****************************************************************************************/
/*
 SELECT dbo.FNARemoveTrailingZeroes(12.100000000)	Output : 12.1
 SELECT dbo.FNARemoveTrailingZeroes(12.00001)		Output : 12.00001
 SELECT dbo.FNARemoveTrailingZeroes(12.00)			Output : 12.00
 SELECT dbo.FNARemoveTrailingZeroes(12)				Output : 12.00
*/
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARemoveTrailingZeroes]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARemoveTrailingZeroes]

go 

CREATE  FUNCTION [dbo].[FNARemoveTrailingZeroes] (@strValue NUMERIC(38,20) )
RETURNS varchar(100) AS  
BEGIN 
	
	DECLARE @ret varchar(100)
	SET @ret = dbo.FNARemoveTrailingZero(@strValue)
	RETURN CASE WHEN CHARINDEX('.', @ret) > 0 THEN @ret ELSE CAST(@ret AS VARCHAR(97)) + '.00' END
	
END





 