IF OBJECT_ID(N'FNAMeterVol', N'FN') IS NOT NULL
    DROP FUNCTION FNAMeterVol
GO
CREATE FUNCTION [dbo].[FNAMeterVol]
(
	@meter_id			VARCHAR(100),
	@no_of_month		INT,
	@channel			INT,
	@block_defination	INT
)
RETURNS FLOAT
AS
BEGIN
	RETURN 1
END