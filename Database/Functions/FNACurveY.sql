IF OBJECT_ID(N'FNACurveY', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNACurveY]
GO 

CREATE FUNCTION [dbo].[FNACurveY]
(
	@curve_id     INT,
	@volume_mult  FLOAT
)
RETURNS FLOAT
AS
BEGIN
	RETURN 1
END




