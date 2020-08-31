SET NOCOUNT ON

IF OBJECT_ID(N'[dbo].FNACalculateTimestamp', N'FN') IS NOT NULL 
	DROP FUNCTION [dbo].FNACalculateTimestamp
GO

/**
	Returns elapsed time between given time and now in format Whr Xmin Ysec Zms.
	NOTE: This function is deprecated. Use FNAGetElapsedTime(@reference_date DATETIME, @mode TINYINT)

	Parameters
	@previous_date	:	Previous date
*/

CREATE FUNCTION [dbo].[FNACalculateTimestamp]
(
	@previous_date DATETIME
)
RETURNS VARCHAR(100)
AS
BEGIN
	-- Call another function that returns the time interval in Hr Min Secs form.
	RETURN dbo.FNAGetTimeInterval(@previous_date, GETDATE(), 2)
END

GO