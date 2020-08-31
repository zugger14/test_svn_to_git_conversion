IF OBJECT_ID(N'[dbo].FNARollingSum', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNARollingSum]
GO 

CREATE FUNCTION [dbo].[FNARollingSum]
(
	@row_number  INT,
	@num_month   INT,
	@lag_month   INT
)
RETURNS FLOAT
AS
BEGIN
	RETURN 1
END