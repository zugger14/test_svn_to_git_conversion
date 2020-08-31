IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[FNARActualizedQualityValue]') AND [type] IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNARActualizedQualityValue]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE function	[dbo].[FNARActualizedQualityValue](
	@quality INT,
	@source_deal_detail_id INT
)
RETURNS float AS
BEGIN
	DECLARE @retValue AS FLOAT

	SELECT @retValue = tq.[value] 
	FROM ticket_header th 
	INNER JOIN ticket_detail td ON td.ticket_header_id  = th.ticket_header_id
	INNER JOIN ticket_quality tq ON  tq.ticket_detail_id = td.ticket_detail_id
	INNER JOIN ticket_match tm ON tm.ticket_detail_id = td.ticket_detail_id
	INNER JOIN match_group_detail mgd ON mgd.match_group_detail_id = tm.match_group_detail_id
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = mgd.source_deal_detail_id
	WHERE sdd.source_deal_detail_id = @source_deal_detail_id
		AND tq.quality = @quality
	
	RETURN ISNULL(@retValue, 0)
END
GO