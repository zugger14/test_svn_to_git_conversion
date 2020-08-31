IF OBJECT_ID(N'FNACurve', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNACurve]
GO
--select dbo.FNACurve('3/1/2004', 4500, '7/1/2004', 1)
--select dbo.FNACurve('4/1/2004', 4500, '7/1/2004', 1)

CREATE FUNCTION [dbo].[FNACurve]
(
	@curve_id     INT,
	@volume_mult  FLOAT
)
RETURNS FLOAT
AS
BEGIN
	RETURN 1
END






