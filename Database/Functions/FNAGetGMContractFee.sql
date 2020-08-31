IF OBJECT_ID(N'FNAGetGMContractFee', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAGetGMContractFee]
GO 

CREATE FUNCTION [dbo].[FNAGetGMContractFee]
(
	@mapping_table_id INT 
	,@clm1_filter_value numeric(20,8)
)
RETURNS FLOAT
AS
BEGIN
	RETURN 1
END
