IF OBJECT_ID(N'FNAGetElapsedTime', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNAGetElapsedTime]
GO 

 /**
	To return Elapsed duration of a datetime from current time

	Parameters :
	@reference_date : Reference Date
	@mode : 1: returns elapsed time in “hh:mm:ss” format
			2: returns elapsed time in “X hrs Y mins Z secs” forma

	Returns Elapsed Time
 */

CREATE FUNCTION [dbo].[FNAGetElapsedTime]
(
	-- IN yy-mm-dd hh:mm:ss format
	@reference_date DATETIME,
	@mode TINYINT
)
RETURNS VARCHAR(50)
AS
BEGIN
	-- Call another function which returns time interval.
	RETURN dbo.FNAGetTimeInterval(@reference_date, GETDATE(), @mode)
END

GO