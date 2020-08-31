IF OBJECT_ID(N'FNARow', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNARow]
 GO 

CREATE FUNCTION [dbo].[FNARow]
(
	@row               INT,
	@offset            INT,
	@aggregation_type  INT
)-- 0 OR null = sum, 1= Average
RETURNS FLOAT
AS
BEGIN
	RETURN 1
END






