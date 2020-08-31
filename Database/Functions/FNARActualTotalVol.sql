/****** Object:  UserDefinedFunction [dbo].[FNARActualTotalVol]    Script Date: 01/11/2011 10:22:23 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARActualTotalVol]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARActualTotalVol]
GO
/****** Object:  UserDefinedFunction [dbo].[FNARActualTotalVol]    Script Date: 01/11/2011 10:22:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARActualTotalVol](
	@deal_id int, -- @deal_id is @source_deal_detail_id
	@term DATETIME
)

RETURNS FLOAT AS
BEGIN

DECLARE @allocated_volume FLOAT
DECLARE @meter_id INT

	
	SELECT @meter_id=meter_id 
	FROM 
		source_deal_detail sdd 
		join source_deal_header sdh on sdd.source_deal_header_id=sdh.source_deal_header_id	
	WHERE 
		  sdd.source_deal_detail_id = @deal_id 

	SELECT @allocated_volume = SUM(ISNULL(ds.delivered_volume,0))
	FROM 
		source_deal_detail sdd 
		join source_deal_header sdh on sdd.source_deal_header_id=sdh.source_deal_header_id	
		LEFT JOIN deal_transport_detail dtd ON dtd.source_deal_detail_id_to=sdd.source_deal_detail_id
		LEFT JOIN delivery_status ds ON ds.deal_transport_detail_id=dtd.deal_transport_deatail_id	
	WHERE 
		  sdd.meter_id = @meter_id 
		  --sdd.source_deal_detail_id = @deal_id 
		  AND dbo.FNAGetcontractMonth(sdd.term_start)=dbo.FNAGetcontractMonth(@term)
		  AND sdh.source_deal_type_id=4
		  AND ds.deal_transport_detail_id IS NOT NULL 

	return isnull(@allocated_volume, 0)
END






