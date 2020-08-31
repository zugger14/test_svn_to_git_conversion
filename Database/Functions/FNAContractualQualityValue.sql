IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[FNAContractualQualityValue]') AND [type] IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNAContractualQualityValue]
GO

CREATE FUNCTION [dbo].[FNAContractualQualityValue] (
	@quality INT
)
RETURNS FLOAT AS  
BEGIN
	RETURN 1.0
END
GO