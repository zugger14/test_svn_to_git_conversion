/****** Object:  UserDefinedFunction [dbo].[FNARFixedVolm]    Script Date: 12/15/2010 18:41:32 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARFixedVolm]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARFixedVolm]
/****** Object:  UserDefinedFunction [dbo].[FNARFixedVolm]    Script Date: 12/15/2010 18:41:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
select [dbo].FNARDealFixedVolm(123,1)
*/
CREATE FUNCTION [dbo].[FNARFixedVolm](
	@term_start DATETIME,
	@counterparty_id INT,
	@contract_id INT
)

RETURNS FLOAT AS
BEGIN

--RETURN 6.0  

DECLARE @deal_volume FLOAT
DECLARE @profile_id INT
DECLARE @meter_volume FLOAT

	SELECT @profile_id=MAX(internal_desk_id) 
				FROM 
					source_deal_header sdh 
					JOIN source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id	
				where 1=1
					AND sdh.contract_id=@contract_id
					AND sdh.counterparty_id=@counterparty_id
					AND sdd.term_start= dbo.FNAGETCONTRACTMONTH(@term_start)
					AND product_id=4100

	--IF ISNULL(@profile_id,-6)=-6 
		SELECT @deal_volume = 
			SUM(sdd.total_volume*CASE WHEN buy_sell_flag='b' THEN 1 ELSE -1 END*ISNULL(sdd.multiplier,1)*ISNULL(sdd.volume_multiplier2,1)) 
					from 
						source_deal_detail sdd 
						join source_deal_header sdh on sdd.source_deal_header_id=sdh.source_deal_header_id	
					where 1=1
						AND sdh.contract_id=@contract_id
						AND sdh.counterparty_id=@counterparty_id
						AND sdd.term_start= dbo.FNAGETCONTRACTMONTH(@term_start)		
						AND ISNULL(sdh.internal_desk_id,17300)=17300
						AND product_id=4100
--	ELSE 
--	BEGIN
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
		
		
		SELECT @meter_volume = 
			@meter_volume*ISNULL(MAX(ISNULL(sdd.multiplier,1)*ISNULL(sdd.volume_multiplier2,1)),1)
					from 
						source_deal_detail sdd 
						join source_deal_header sdh on sdd.source_deal_header_id=sdh.source_deal_header_id	
					where 1=1
						AND sdh.contract_id=@contract_id
						AND sdh.counterparty_id=@counterparty_id
						AND sdd.term_start= dbo.FNAGETCONTRACTMONTH(@term_start)		
						AND ISNULL(sdh.internal_desk_id,17300)<>17300
						AND product_id=4100

	--END
	
	RETURN abs(ISNULL(@deal_volume,0))+abs(ISNULL(@meter_volume,0))

END


