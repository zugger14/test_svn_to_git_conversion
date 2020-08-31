IF OBJECT_ID(N'FNARYear', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNARYear]
 GO
 
CREATE FUNCTION [dbo].[FNARYear]
(
	@prod_date      VARCHAR(20)
)
RETURNS INT
AS
BEGIN
	DECLARE @ret_value INT

	IF @prod_date IS NOT NULL
		SET @ret_value = YEAR(@prod_date)
	ELSE 
		SET @ret_value =  NULL

	RETURN @ret_value
END








