IF OBJECT_ID(N'FNARelativeDailyCurve', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNARelativeDailyCurve]
GO 

CREATE FUNCTION [dbo].[FNARelativeDailyCurve]
(
	@curve_id  INT,
	@offset    INT
)
RETURNS FLOAT
AS
BEGIN
	RETURN 1
END




