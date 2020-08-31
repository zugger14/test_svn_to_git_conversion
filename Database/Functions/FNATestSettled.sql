IF OBJECT_ID(N'FNATestSettled', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNATestSettled]
GO 

--Returns 1 if  term_month is settled

CREATE FUNCTION [dbo].[FNATestSettled]
(
	@term_month  DATETIME,
	@as_of_date  DATETIME
)
RETURNS INT
AS
BEGIN
	DECLARE @FNATestSettled AS INT
	IF @term_month <= @as_of_date
	    SET @FNATestSettled = 1
	ELSE
	    SET @FNATestSettled = 0
	
	RETURN(@FNATestSettled)
END