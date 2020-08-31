IF OBJECT_ID(N'FNALastMnthValue', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNALastMnthValue]
 GO
 
CREATE FUNCTION [dbo].[FNALastMnthValue]
(
	@x  INT,
	@y  INT
)
RETURNS FLOAT
AS
BEGIN
	RETURN 1
END