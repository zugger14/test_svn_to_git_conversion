/****** Object:  UserDefinedFunction [dbo].[FNARImbalanceVol]    Script Date: 11/10/2010 17:13:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARLocationVol]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARLocationVol]
/****** Object:  UserDefinedFunction [dbo].[FNARImbalanceVol]    Script Date: 11/10/2010 17:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNARLocationVol](
	@deal_id int -- @deal_id is  @source_deal_detail_id
	
)

RETURNS INT AS
BEGIN

DECLARE @volume FLOAT
DECLARE @location_id INT
DECLARE @term_date DATETIME

SELECT @location_id=location_id,@term_date=term_start FROM source_deal_detail WHERE source_deal_detail_id=@deal_id

	select @volume = SUM(CASE WHEN sdd.buy_sell_flag='b' THEN 1 ELSE -1 END*sdd.deal_volume)
	from 
		source_deal_detail sdd 
		join source_deal_header sdh on sdd.source_deal_header_id=sdh.source_deal_header_id	
		LEFT JOIN deal_transport_header dth ON dth.source_deal_header_id=sdh.source_deal_header_id	
		LEFT JOIN delivery_status ds ON ds.deal_transport_id=dth.deal_transport_id	

	where 
		  sdd.location_id = @location_id 
		  and sdd.term_start=@term_date	
		  
	return @volume
END


