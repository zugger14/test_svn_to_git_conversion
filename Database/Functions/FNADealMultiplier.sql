IF OBJECT_ID(N'FNADealMultiplier', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNADealMultiplier]
GO 

CREATE FUNCTION [dbo].[FNADealMultiplier]()

RETURNS FLOAT
AS
BEGIN
	RETURN 1
END