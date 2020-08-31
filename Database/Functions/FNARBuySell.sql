IF OBJECT_ID(N'FNARBuySell', N'FN') IS NOT NULL
DROP FUNCTION FNARBuySell
 GO 

CREATE FUNCTION dbo.FNARBuySell (
					@source_deal_header_id INT,
					@source_deal_detail_id INT
				)
RETURNS INT AS  
BEGIN 
	DECLARE @is_buy_sell INT
	
	IF @source_deal_detail_id IS NOT NULL
		SELECT @is_buy_sell = CASE buy_sell_flag WHEN 'b' THEN 1 ELSE 0 END FROM source_deal_detail WHERE source_deal_detail_id = @source_deal_detail_id
	ELSE
		SELECT @is_buy_sell = CASE header_buy_sell_flag WHEN 'b' THEN 1 ELSE 0 END FROM source_deal_header WHERE source_deal_header_id = @source_deal_header_id
			
	RETURN @is_buy_sell
END




