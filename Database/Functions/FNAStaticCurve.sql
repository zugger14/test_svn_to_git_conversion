IF OBJECT_ID(N'FNAStaticCurve', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].FNAStaticCurve
GO

CREATE FUNCTION [dbo].FNAStaticCurve(@curve_id  INT)
RETURNS FLOAT
AS
BEGIN
	RETURN 1
END