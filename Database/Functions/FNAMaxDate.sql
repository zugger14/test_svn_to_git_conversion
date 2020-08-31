IF OBJECT_ID(N'FNAMaxDate', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAMaxDate]
GO 

CREATE FUNCTION [dbo].[FNAMaxDate]
(
	@arg1  DATETIME,
	@arg2  DATETIME
)
RETURNS DATETIME
AS
BEGIN
	RETURN 
	CASE 
	     WHEN @arg1 > @arg2 THEN @arg1
	     ELSE @arg2
	END
END