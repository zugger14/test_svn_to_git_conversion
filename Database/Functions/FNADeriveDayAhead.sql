IF OBJECT_ID(N'FNADAWA', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNADAWA]
GO
 
IF OBJECT_ID(N'FNADeriveDayAhead', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNADeriveDayAhead]
GO 

CREATE FUNCTION [dbo].[FNADeriveDayAhead]
(
	@curve_id1     INT,
	@curve_id2     INT,
	@default_holiday_id int
)
RETURNS FLOAT
AS
BEGIN
	RETURN 1
END

