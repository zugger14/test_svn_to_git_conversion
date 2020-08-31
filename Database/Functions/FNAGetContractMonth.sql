IF OBJECT_ID(N'FNAGetContractMonth', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAGetContractMonth]
GO
 
--SELECT DBO.FNAGetContractMonth('2004-11-28')
--SELECT convert(datetime, '2004-2-28', 102)
-- This function converst a datatime to ADIHA format 'yyyy-mm-1'
-- Inpute is SQL datatime...
-- Input is a SQl Date variable
CREATE FUNCTION [dbo].[FNAGetContractMonth]
(
	@DATE DATETIME
)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @FNAGetContractMonth AS VARCHAR(50)  
	SET @FNAGetContractMonth = CONVERT(VARCHAR(7), @DATE, 120) + '-01' 
	
	RETURN(@FNAGetContractMonth)
END