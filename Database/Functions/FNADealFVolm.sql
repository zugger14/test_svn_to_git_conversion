IF OBJECT_ID(N'FNADealFVolm', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNADealFVolm]
GO 

CREATE FUNCTION [dbo].[FNADealFVolm]
(
	@udf_type_value_id INT
)
RETURNS FLOAT AS
BEGIN
	RETURN 1
END