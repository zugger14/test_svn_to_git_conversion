IF OBJECT_ID(N'FNARMonth', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNARMonth]
GO 

CREATE FUNCTION [dbo].[FNARMonth]
(
	@prod_date VARCHAR(20)
)
RETURNS INT AS
BEGIN

DECLARE @value INT


set 	@value=MONTH(@prod_date)

	return @value
END