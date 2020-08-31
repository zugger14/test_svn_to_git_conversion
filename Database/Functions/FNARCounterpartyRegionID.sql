SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[FNARCounterpartyRegionID]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNARCounterpartyRegionID]
GO

CREATE FUNCTION [dbo].[FNARCounterpartyRegionID](@source_deal_header_id INT)
	RETURNS INT
AS
BEGIN
DECLARE @return_value INT

       SELECT @return_value = sp.region
       FROM   source_deal_header sdh
              INNER JOIN source_counterparty sp
                   ON  sdh.counterparty_id = sp.source_counterparty_id
       WHERE  sdh.source_deal_header_id = @source_deal_header_id             

RETURN @return_value

END