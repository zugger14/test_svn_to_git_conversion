IF OBJECT_ID(N'FNARolling', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNARolling]
GO 

CREATE FUNCTION [dbo].[FNARolling]
(
	@x  INT,
	@y  INT
)
RETURNS FLOAT
AS
BEGIN
	RETURN 1
END