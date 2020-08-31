SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[FNARLocationRegionID]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNARLocationRegionID]
GO

CREATE FUNCTION [dbo].[FNARLocationRegionID](@source_deal_detail_id INT)
	RETURNS INT
AS
BEGIN
DECLARE @return_value INT

       SELECT @return_value = sml.region
       FROM   source_deal_detail sdd
              INNER JOIN source_minor_location sml
                   ON  sdd.location_id = sml.source_minor_location_id
       WHERE  sdd.source_deal_detail_id = @source_deal_detail_id             

RETURN @return_value

END