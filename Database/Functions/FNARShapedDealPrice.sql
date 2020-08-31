IF OBJECT_ID(N'FNARShapedDealPrice', N'FN') IS NOT NULL
DROP FUNCTION FNARShapedDealPrice
GO
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go
--SELECT [dbo].[FNARShapedDealPrice] (19950246,1162,8790,'2013-09-01',10,987,0,15)

CREATE FUNCTION [dbo].[FNARShapedDealPrice](
		@source_deal_detail_id INT,
		@contract_id INT,
		@counterparty_id INT,
		@prod_date datetime,
		@hour INT,
		@granularity INT,
		@dst INT,
		@mins INT
)
--987	15Min
--981	Daily 
--982	Hourly
--980	Monthly
	
	RETURNS FLOAT AS  
	BEGIN 
	DECLARE @price FLOAT
	--SET @hour = @hour - 1
	IF @mins > 0
		SELECT @mins = @mins - 15
			
	IF @source_deal_detail_id IS NOT NULL
	BEGIN 
		
		IF @granularity = 980 
		SELECT @price = SUM(price)
		FROM
			source_deal_header sdh 
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
			INNER JOIN source_deal_detail_hour sddh ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
		WHERE
			((sdd.source_deal_detail_id = @source_deal_detail_id))
			AND YEAR(sddh.term_date) = YEAR(@prod_date)
			AND MONTH(sddh.term_date) = MONTH(@prod_date)		
			
		ELSE IF @granularity = 981
		SELECT @price = SUM(price)
		FROM
			source_deal_header sdh 
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
			INNER JOIN source_deal_detail_hour sddh ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
		WHERE
			((sdd.source_deal_detail_id = @source_deal_detail_id))
			AND sddh.term_date = @prod_date	
		
			
		ELSE IF @granularity = 982
		SELECT @price = SUM(price)
		FROM
			source_deal_header sdh 
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
			INNER JOIN source_deal_detail_hour sddh ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
		WHERE
			((sdd.source_deal_detail_id = @source_deal_detail_id))
			AND sddh.term_date = @prod_date		
			AND sddh.is_dst = @dst
			AND hr =  RIGHT('0' + CAST(@hour AS VARCHAR), 2) + ':00'
			
			
		ELSE 
		BEGIN
						
			SELECT @price = SUM(price)
			FROM
				source_deal_header sdh 
				INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				INNER JOIN source_deal_detail_hour sddh ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
			WHERE
				((sdd.source_deal_detail_id = @source_deal_detail_id))
				AND sddh.term_date = @prod_date		
				AND sddh.is_dst = @dst
				AND hr = RIGHT('0' + CAST(@hour AS VARCHAR), 2) + ':' + RIGHT('0' + CAST(@mins AS VARCHAR), 2)
		END
			
			
	END		
	ELSE	
		SELECT @price = SUM(price)
		FROM 
			source_deal_header sdh 
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
			INNER JOIN source_deal_detail_hour sddh ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
		WHERE
			((sdh.counterparty_id = @counterparty_id AND sdh.contract_id = @contract_id))
			AND sddh.term_date = @prod_date		
			AND hr = RIGHT('0' + CAST(@hour AS VARCHAR), 2) +  ':' + RIGHT('0' + CAST(@mins AS VARCHAR), 2)
			AND sddh.is_dst = @dst
						
		RETURN ISNULL(@price,0)
	END














