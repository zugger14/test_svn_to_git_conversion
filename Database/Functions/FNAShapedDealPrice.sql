IF OBJECT_ID(N'FNAShapedDealPrice', N'FN') IS NOT NULL
DROP FUNCTION FNAShapedDealPrice
GO
CREATE FUNCTION [dbo].[FNAShapedDealPrice]()
RETURNS FLOAT AS  
BEGIN 
	RETURN 1
END









