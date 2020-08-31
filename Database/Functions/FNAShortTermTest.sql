IF OBJECT_ID(N'FNAShortTermTest', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAShortTermTest]
GO 

-- This function tests if a passed in date is withing the month range passed for 
-- short/long term logic
-- 
--DROP FUNCTION FNAShortTermTest
CREATE FUNCTION [dbo].[FNAShortTermTest]
(
	@asOfDate   DATETIME,
	@termMonth  DATETIME,
	@months     INT
)
RETURNS INT
AS
BEGIN
	DECLARE @FNAShortTermTest AS INT
	
	IF @termMonth <= DATEADD(mm, @months - 1, @asOfDate)
	    SET @FNAShortTermTest = 1
	ELSE
	    SET @FNAShortTermTest = 0
	
	RETURN(@FNAShortTermTest)
END