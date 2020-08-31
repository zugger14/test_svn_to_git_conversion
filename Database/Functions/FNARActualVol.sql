/****** Object:  UserDefinedFunction [dbo].[FNARActualVol]    Script Date: 01/11/2011 09:49:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARActualVol]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARActualVol]
GO
/****** Object:  UserDefinedFunction [dbo].[FNARActualVol]    Script Date: 01/11/2011 09:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARActualVol](
	@deal_id int -- @deal_id is @source_deal_detail_id
)

RETURNS FLOAT AS
BEGIN
	DECLARE @actual_volume FLOAT

	select @actual_volume =ISNULL(SUM(ds.delivered_volume),0) 
	from 
		source_deal_detail sdd 
		join source_deal_header sdh on sdd.source_deal_header_id=sdh.source_deal_header_id	
			LEFT JOIN deal_transport_detail dtd ON dtd.source_deal_detail_id_to=sdd.source_deal_detail_id
			LEFT JOIN delivery_status ds ON ds.deal_transport_detail_id=dtd.deal_transport_deatail_id

	where 
		   sdd.source_deal_detail_id = @deal_id 
--		  AND sdd.term_start=@term_start
	return @actual_volume
END


