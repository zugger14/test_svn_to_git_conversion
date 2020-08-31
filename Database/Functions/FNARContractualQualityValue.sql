IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[FNARContractualQualityValue]') AND [type] IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNARContractualQualityValue]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE function	[dbo].[FNARContractualQualityValue] (
	@quality INT,
	@source_deal_detail_id INT
)
RETURNS FLOAT AS
BEGIN
	DECLARE @retValue AS FLOAT

	SELECT @retValue = numeric_value
	FROM deal_price_quality
	WHERE source_deal_detail_id = @source_deal_detail_id
		AND attribute = @quality

	RETURN ISNULL(@retValue, 0)
END
GO