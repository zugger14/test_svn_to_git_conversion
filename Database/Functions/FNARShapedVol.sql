IF OBJECT_ID(N'FNARShapedVol', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNARShapedVol]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARShapedVol]
(
	@source_deal_detail_id  INT,
	@contract_id            INT,
	@counterparty_id        INT,
	@prod_date              DATETIME,
	@hour                   VARCHAR(20),
	@granularity            INT,
	@dst                    INT,
	@mins					INT
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @volume FLOAT
	
	IF @granularity = 987
		SET @mins = @mins - 15

	IF @granularity = 989
		SET @mins = @mins - 30

	
		
			SELECT @volume = SUM(volume*CASE WHEN sdd.buy_sell_flag='b' THEN 1 ELSE -1 END)
			FROM
				source_deal_header sdh 
				INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				INNER JOIN source_deal_detail_hour sddh ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
			WHERE
				YEAR(sddh.term_date) = YEAR(@prod_date)
				AND MONTH(sddh.term_date) = MONTH(@prod_date)	
				AND sdh.counterparty_id = @counterparty_id 
				AND sdh.contract_id =@contract_id
				AND ((DAY(sddh.term_date) = DAY(@prod_date) AND @granularity <> 980) OR @granularity=980) 	
				AND (@source_deal_detail_id IS NULL OR sdd.source_deal_detail_id = @source_deal_detail_id)
				AND @hour = CASE WHEN @granularity IN(980,981) THEN 0 ELSE CAST(LEFT(sddh.[hr],2) AS INT) END
				AND @mins = CASE WHEN @granularity IN(980,981,982) THEN 0 
								 WHEN @granularity = 987 THEN CAST(RIGHT(sddh.[hr],2) AS INT)
								 WHEN @granularity = 989 THEN CAST(RIGHT(sddh.[hr],2) AS INT)
								 ELSE  CAST(RIGHT(sddh.[hr],2) AS INT) END
		
		
		RETURN ISNULL(@volume, 0)
END