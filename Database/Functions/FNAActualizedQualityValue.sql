IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[FNAActualizedQualityValue]') AND [type] IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNAActualizedQualityValue]
GO

CREATE FUNCTION [dbo].[FNAActualizedQualityValue] (
	@quality INT
)
RETURNS FLOAT AS  
BEGIN
	RETURN 1
END
GO