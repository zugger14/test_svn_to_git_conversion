IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARGetLogicalValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARGetLogicalValue]
GO

CREATE FUNCTION [dbo].[FNARGetLogicalValue]
(
	@mapping_table_id INT,
	@logical_name VARCHAR(200),
	
	@counterparty_id INT, 
	@contract_id INT
)
RETURNS FLOAT 
AS

BEGIN 
	DECLARE @return_id FLOAT
	--DECLARE @logical_name NVARCHAR(100)
	
	--SELECT @logical_name  = clm3_value FROM generic_mapping_values WHERE generic_mapping_values_id = @logical_name_id
	
	SELECT @return_id = clm4_value FROM generic_mapping_values 
	WHERE	mapping_table_id = @mapping_table_id AND 
			clm3_value = @logical_name AND
			clm1_value = @counterparty_id AND
			clm2_value = @contract_id
	
	RETURN @return_id
END