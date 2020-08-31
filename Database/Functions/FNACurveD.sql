IF OBJECT_ID(N'FNACurveD', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNACurveD]
 GO 


CREATE FUNCTION [dbo].[FNACurveD]
(
	@curve_id     INT,
	@volume_mult  FLOAT
)
RETURNS FLOAT
AS
BEGIN
	RETURN 1
END




