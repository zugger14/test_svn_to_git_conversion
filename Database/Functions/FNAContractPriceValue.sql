IF OBJECT_ID(N'FNAContractPriceValue', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAContractPriceValue]
GO

CREATE FUNCTION [dbo].[FNAContractPriceValue]
(
	@curve_id     VARCHAR(200),
	@granularity  INT,
	@index_group  INT
)
RETURNS FLOAT
AS
BEGIN
	RETURN 1
END









