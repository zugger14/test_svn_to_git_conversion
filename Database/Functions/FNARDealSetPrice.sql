/****** Object:  UserDefinedFunction [dbo].[FNARDealSetPrice]    Script Date: 09/15/2011 11:38:56 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARDealSetPrice]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARDealSetPrice]
GO

/****** Object:  UserDefinedFunction [dbo].[FNARDealSettlement]    Script Date: 09/15/2011 11:39:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- select [dbo].[FNARDealSetPrice](NULL,'2012-01-31','2012-01-01',48425,34,4100)
CREATE FUNCTION [dbo].[FNARDealSetPrice] (
					@source_deal_detail_id INT,
					@as_of_date DATETIME,
					@prod_date DATETIME, 
					@source_deal_header_id INT,
					@curve_tou INT,
					@deal_type INT				
				)
RETURNS float AS  
BEGIN 
/*
DECLARE @source_deal_detail_id INT,
		@as_of_date DATETIME,
		@prod_date DATETIME, 
		@source_deal_header_id INT,
		@deal_type INT,
		@fixation INT

	
	
	SET @source_deal_header_id=60280
	SET @as_of_date='2011-01-31'
	SET @prod_date='2011-01-01'
	SET @deal_type=34
	SET @fixation=4100
*/	
	
DECLARE @net_price FLOAT
			
		
		IF @source_deal_detail_id IS NOT NULL
			SELECT @net_price = SUM(sds.net_price)
			FROM 
				source_deal_settlement sds INNER JOIN
				source_deal_detail sdd on sdd.source_deal_header_id = sds.source_deal_header_id
					AND sdd.leg = sds.leg
					AND sdd.term_start = sds.term_start
				INNER JOIN source_deal_header sdh ON sds.source_deal_header_id = sdh.source_deal_header_id
				CROSS APPLY(SELECT MAX(as_of_date) as_of_date FROM source_deal_settlement where source_deal_header_id = sds.source_deal_header_id
					AND  term_start = sds.term_start AND leg=sds.leg ) sds1
			WHERE
				sdd.source_deal_detail_id = @source_deal_detail_id
				AND YEAR(sds.term_start) = YEAR(@prod_date)
				AND MONTH(sds.term_start) = MONTH(@prod_date)
				--AND sdh.source_deal_type_id = @deal_type
				AND sds1.as_of_date = sds.as_of_date
		ELSE
		
		SELECT @net_price = SUM(sds.net_price)
			FROM 
				source_deal_settlement sds
				INNER JOIN source_deal_header sdh ON sds.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN source_deal_detail sdd on sdd.source_deal_header_id = sds.source_deal_header_id 
					AND sdd.leg = sds.leg
					AND sdd.term_start = sds.term_start
				INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
				CROSS APPLY(SELECT MAX(as_of_date) as_of_date FROM source_deal_settlement where source_deal_header_id = sds.source_deal_header_id
					AND  term_start = sds.term_start AND leg=sds.leg ) sds1
			WHERE
				sds.source_deal_header_id = @source_deal_header_id
				AND YEAR(sds.term_start) = YEAR(@prod_date)
				AND MONTH(sds.term_start) = MONTH(@prod_date)
				--AND sdh.source_deal_type_id = @deal_type
				--AND ISNULL(spcd.curve_tou,18900) = @curve_tou
				AND sds1.as_of_date = sds.as_of_date
		
	RETURN isnull(@net_price, 0)
	--SELECT @net_price
END




GO


