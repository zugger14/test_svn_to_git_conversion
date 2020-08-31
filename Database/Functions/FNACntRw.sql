IF OBJECT_ID(N'FNACntRw', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNACntRw]
 GO 

CREATE FUNCTION [dbo].[FNACntRw]
(
	@row        INT,
	@condition  INT
)-- 0 OR null = sum, 1= Average
RETURNS FLOAT
AS
BEGIN
	RETURN 1
END