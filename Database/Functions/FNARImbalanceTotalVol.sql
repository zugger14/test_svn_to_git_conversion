/****** Object:  UserDefinedFunction [dbo].[FNARImbalanceTotalVol]    Script Date: 01/07/2011 17:49:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARImbalanceTotalVol]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARImbalanceTotalVol]
GO
/****** Object:  UserDefinedFunction [dbo].[FNARImbalanceTotalVol]    Script Date: 01/07/2011 17:47:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARImbalanceTotalVol](
	@deal_id int, -- @deal_id is @source_deal_detail_id
	@term DATETIME
	
)

RETURNS FLOAT AS
BEGIN

DECLARE @imbalance_volume FLOAT
DECLARE @meter_id INT

	
	SELECT @meter_id=meter_id 
	FROM 
		source_deal_detail sdd 
		join source_deal_header sdh on sdd.source_deal_header_id=sdh.source_deal_header_id	
	WHERE 
		  sdd.source_deal_detail_id = @deal_id 


	--SELECT @imbalance_volume = SUM(sdd.deal_volume-ISNULL(ds.delivered_volume,0))
	SELECT @imbalance_volume = SUM(ISNULL(ds.delivered_volume,0)-sdd.deal_volume)
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
	return @imbalance_volume
END






