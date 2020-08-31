IF OBJECT_ID(N'FNAHCurve', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAHCurve]
GO 

--select dbo.FNAHCurve('3/1/2004', 4500, '7/1/2004', 1)
--select dbo.FNAHCurve('4/1/2004', 4500, '7/1/2004', 1)

CREATE FUNCTION [dbo].[FNAHCurve]
(
	@curve_id INT
)
RETURNS FLOAT
AS
BEGIN
	RETURN 1
END