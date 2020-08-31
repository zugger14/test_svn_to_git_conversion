IF OBJECT_ID(N'dbo.FNADealSettlement', N'FN') IS NOT NULL
DROP FUNCTION dbo.FNADealSettlement
 GO 

CREATE FUNCTION dbo.FNADealSettlement(@deal_type INT)
RETURNS float AS  
BEGIN 
	RETURN 1
END



