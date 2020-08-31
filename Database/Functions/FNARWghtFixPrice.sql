/****** Object:  UserDefinedFunction [dbo].[FNARWghtFixPrice]    Script Date: 12/16/2010 10:53:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARWghtFixPrice]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARWghtFixPrice]
GO
/****** Object:  UserDefinedFunction [dbo].[FNARWghtFixPrice]    Script Date: 12/16/2010 10:52:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
select [dbo].FNARDealFixedVolm(123,1)
*/
CREATE FUNCTION [dbo].[FNARWghtFixPrice](
	@term_start DATETIME,
	@counterparty_id INT,
	@contract_id INT
)
--DECLARE @term_start DATETIME,@counterparty_id INT,@contract_id INT
--SET @term_start='2011-03-01'
--SET @counterparty_id=94
--SET @contract_id=51
--
RETURNS FLOAT AS
BEGIN
--RETURN 5.00
DECLARE @meter_volume FLOAT
DECLARE @wght_price FLOAT 
DECLARE @total_volume FLOAT

	SELECT @total_volume=dbo.FNARFixedVolm(@term_start,@counterparty_id,@contract_id)


	SELECT @meter_volume=SUM(mv90.volume*rp.mult_factor)
		FROM
		(SELECT DISTINCT sdh.counterparty_id,smlm.meter_id 
			FROM
				source_deal_header sdh
				INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id
				INNER JOIN source_minor_location sml ON sml.source_minor_location_id=sdd.location_id
				INNER JOIN source_minor_location_meter smlm ON smlm.source_minor_location_id=sml.source_minor_location_id
				LEFT JOIN rec_generator rg On rg.ppa_counterparty_id=sdh.counterparty_id
			WHERE
				ISNULL(sdh.contract_id,rg.ppa_contract_id)=@contract_id
				AND sdh.counterparty_id=@counterparty_id	
			) a	
				INNER JOIN recorder_properties rp ON rp.meter_id=a.meter_id
				INNER JOIN mv90_data mv90 ON mv90.meter_id=a.meter_id AND rp.channel=mv90.channel
			WHERE			
				mv90.from_date= dbo.FNAGETCONTRACTMONTH(@term_start)	
			
IF ISNULL(@total_volume,0)<>0
BEGIN
		;WITH CTE AS(
		SELECT 	price_1,price_2 FROM
		(SELECT 	
			CAST(SUM(sdd.total_volume*CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END*ISNULL(sdd.multiplier,1)*ISNULL(sdd.volume_multiplier2,1)*((sdd.fixed_price*ISNULL(sdd.price_multiplier,1))+ISNULL(sdd.price_adder,0)+ISNULL(sdd.price_adder2,0))) AS FLOAT) price_1
					from 
						source_deal_detail sdd 
						join source_deal_header sdh on sdd.source_deal_header_id=sdh.source_deal_header_id	
					where 1=1
						AND sdh.contract_id=@contract_id
						AND sdh.counterparty_id=@counterparty_id
						AND sdd.term_start= dbo.FNAGETCONTRACTMONTH(@term_start)		
						AND ISNULL(product_id,4101)=4101
						--AND sdd.leg=1
						AND ISNULL(sdh.internal_desk_id,17300)=17300
			)as price_1,

		(SELECT
				CAST(SUM(@meter_volume*CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END*ISNULL(sdd.multiplier,1)*ISNULL(sdd.volume_multiplier2,1)*((sdd.fixed_price*ISNULL(sdd.price_multiplier,1))+ISNULL(sdd.price_adder,0)+ISNULL(sdd.price_adder2,0))) AS FLOAT) price_2
				from 
						source_deal_detail sdd 
						join source_deal_header sdh on sdd.source_deal_header_id=sdh.source_deal_header_id	
					where 1=1
						AND sdh.contract_id=@contract_id
						AND sdh.counterparty_id=@counterparty_id
						AND sdd.term_start= dbo.FNAGETCONTRACTMONTH(@term_start)		
						AND ISNULL(product_id,4101)=4101
						AND sdd.leg=1
						AND ISNULL(sdh.internal_desk_id,17300)<>17300
			) as price_2
		)

		SELECT @wght_price=((ISNULL(price_1,0))+(ISNULL(price_2,0)))/@total_volume FROM cte
END
	ELSE
		SELECT @wght_price=0

	RETURN abs(@wght_price)

END


