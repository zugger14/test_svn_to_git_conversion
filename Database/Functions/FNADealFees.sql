IF OBJECT_ID(N'FNADealFees', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNADealFees]
 GO 

CREATE FUNCTION [dbo].[FNADealFees]
(
	@udf_type_value_id INT
)
RETURNS FLOAT AS
BEGIN
	RETURN 1
END