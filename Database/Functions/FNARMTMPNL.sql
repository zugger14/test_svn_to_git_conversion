IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARMTMPNL]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARMTMPNL]
/****** Object:  UserDefinedFunction [dbo].[FNARMTMPNL]    Script Date: 11/06/2010 10:23:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--USE [TRMTracker_LADWP]
--GO
--/****** Object:  UserDefinedFunction [dbo].[FNARMTMPNL]    Script Date: 09/18/2009 10:46:24 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
---- select [dbo].[FNARMTMPNL](2655,'2010-07-01')
CREATE FUNCTION [dbo].[FNARMTMPNL](
	@deal_id int, -- @deal_id is @source_deal_detail_id
	@term_start datetime
)
--
RETURNS FLOAT AS
BEGIN
--DECLARE @deal_id int
--DECLARE @term_start datetime


DECLARE @pnl FLOAT
DECLARE @as_of_date DATETIME
DECLARE @curve_id INT
DECLARE @market_value FLOAT
DECLARE @volume_multiplier FLOAT

--set @deal_id=7130
--set @term_start='2011-01-01'

	--select @pnl = sum(und_pnl) from source_deal_pnl where source_deal_header_id = @source_deal_header_id and term_start=@term_start;
--	select @as_of_date=max(pnl_as_of_date) from 	
--			source_deal_pnl	sdp
--			join source_deal_detail sdd on sdd.source_deal_header_id=sdp.source_deal_header_id	
--	where sdd.source_deal_detail_id  = @deal_id and sdp.term_start=@term_start
--				--AND month(sdp.pnl_as_of_date)=month(@term_start) and year(sdp.pnl_as_of_date)=YEAR(@term_start)
--
--	select @pnl = sum(und_pnl) 
--	from source_deal_pnl sdp
--		 join source_deal_detail sdd on sdd.source_deal_header_id=sdp.source_deal_header_id	
--	where sdd.source_deal_detail_id = @deal_id and sdp.term_start=@term_start
--		  AND sdp.pnl_as_of_date=@as_of_date

	SELECT @as_of_date=
		MAX(ISNULL(sdd.settlement_date,contract_expiration_date)),
		@curve_id=MAX(curve_id) 
	FROM
		source_deal_detail sdd
	WHERE
		--sdd.ISNULL(sdd.settlement_date,contract_expiration_date)<=@as_of_date
		sdd.source_deal_detail_id=@deal_id
		  

	SELECT @market_value=ISNULL(spc.curve_value,0)
	FROM
		source_price_curve spc
	WHERE
		spc.source_curve_def_id=@curve_Id
		AND maturity_date=@term_start
		AND as_of_date=@as_of_date

	IF @market_value IS NULL
	BEGIN
		SELECT @as_of_date=MAX(as_of_date) FROM
			source_price_curve spc
		WHERE
			spc.source_curve_def_id=@curve_Id
			AND maturity_date=@term_start
			--AND as_of_date=@as_of_date


	SELECT @market_value=ISNULL(spc.curve_value,0)
		FROM
			source_price_curve spc
		WHERE
			spc.source_curve_def_id=@curve_Id
			AND maturity_date=@term_start
			AND as_of_date=@as_of_date
	END


-- Find volume multiplier
		SELECT @volume_multiplier=
			(CASE WHEN sdd.deal_volume_frequency='h' AND sdh.block_type IS NOT NULL THEN
					CASE WHEN MAX(dst.insert_delete)='d' AND MAX(ISNULL(hb.dst_applies,'n'))='y' THEN -1 WHEN MAX(dst.insert_delete)='i' AND MAX(ISNULL(hb.dst_applies,'n'))='y'  THEN 1 ELSE 0 END+
					SUM(
						CASE WHEN hb.onpeak_offpeak='o' AND ISNULL(hg.hol_date,'')<>'' THEN 1 WHEN hb.onpeak_offpeak='p' AND ISNULL(hg.hol_date,'')<>'' THEN 0 ELSE  hb.hr1 END +
						CASE WHEN hb.onpeak_offpeak='o' AND ISNULL(hg.hol_date,'')<>'' THEN 1 WHEN hb.onpeak_offpeak='p' AND ISNULL(hg.hol_date,'')<>'' THEN 0  ELSE  hb.hr2 END +
						CASE WHEN hb.onpeak_offpeak='o' AND ISNULL(hg.hol_date,'')<>'' THEN 1 WHEN hb.onpeak_offpeak='p' AND ISNULL(hg.hol_date,'')<>'' THEN 0  ELSE  hb.hr3 END +
						CASE WHEN hb.onpeak_offpeak='o' AND ISNULL(hg.hol_date,'')<>'' THEN 1 WHEN hb.onpeak_offpeak='p' AND ISNULL(hg.hol_date,'')<>'' THEN 0  ELSE  hb.hr4 END +
						CASE WHEN hb.onpeak_offpeak='o' AND ISNULL(hg.hol_date,'')<>'' THEN 1 WHEN hb.onpeak_offpeak='p' AND ISNULL(hg.hol_date,'')<>'' THEN 0  ELSE  hb.hr5 END +
						CASE WHEN hb.onpeak_offpeak='o' AND ISNULL(hg.hol_date,'')<>'' THEN 1 WHEN hb.onpeak_offpeak='p' AND ISNULL(hg.hol_date,'')<>'' THEN 0  ELSE  hb.hr6 END +
						CASE WHEN hb.onpeak_offpeak='o' AND ISNULL(hg.hol_date,'')<>'' THEN 1 WHEN hb.onpeak_offpeak='p' AND ISNULL(hg.hol_date,'')<>'' THEN 0  ELSE  hb.hr7 END +
						CASE WHEN hb.onpeak_offpeak='o' AND ISNULL(hg.hol_date,'')<>'' THEN 1 WHEN hb.onpeak_offpeak='p' AND ISNULL(hg.hol_date,'')<>'' THEN 0  ELSE  hb.hr8 END +
						CASE WHEN hb.onpeak_offpeak='o' AND ISNULL(hg.hol_date,'')<>'' THEN 1 WHEN hb.onpeak_offpeak='p' AND ISNULL(hg.hol_date,'')<>'' THEN 0  ELSE  hb.hr9 END +
						CASE WHEN hb.onpeak_offpeak='o' AND ISNULL(hg.hol_date,'')<>'' THEN 1 WHEN hb.onpeak_offpeak='p' AND ISNULL(hg.hol_date,'')<>'' THEN 0  ELSE  hb.hr10 END +
						CASE WHEN hb.onpeak_offpeak='o' AND ISNULL(hg.hol_date,'')<>'' THEN 1 WHEN hb.onpeak_offpeak='p' AND ISNULL(hg.hol_date,'')<>'' THEN 0  ELSE  hb.hr11 END +
						CASE WHEN hb.onpeak_offpeak='o' AND ISNULL(hg.hol_date,'')<>'' THEN 1 WHEN hb.onpeak_offpeak='p' AND ISNULL(hg.hol_date,'')<>'' THEN 0  ELSE  hb.hr12 END +
						CASE WHEN hb.onpeak_offpeak='o' AND ISNULL(hg.hol_date,'')<>'' THEN 1 WHEN hb.onpeak_offpeak='p' AND ISNULL(hg.hol_date,'')<>'' THEN 0  ELSE  hb.hr13 END +
						CASE WHEN hb.onpeak_offpeak='o' AND ISNULL(hg.hol_date,'')<>'' THEN 1 WHEN hb.onpeak_offpeak='p' AND ISNULL(hg.hol_date,'')<>'' THEN 0  ELSE  hb.hr14 END +
						CASE WHEN hb.onpeak_offpeak='o' AND ISNULL(hg.hol_date,'')<>'' THEN 1 WHEN hb.onpeak_offpeak='p' AND ISNULL(hg.hol_date,'')<>'' THEN 0  ELSE  hb.hr15 END +
						CASE WHEN hb.onpeak_offpeak='o' AND ISNULL(hg.hol_date,'')<>'' THEN 1 WHEN hb.onpeak_offpeak='p' AND ISNULL(hg.hol_date,'')<>'' THEN 0  ELSE  hb.hr16 END +
						CASE WHEN hb.onpeak_offpeak='o' AND ISNULL(hg.hol_date,'')<>'' THEN 1 WHEN hb.onpeak_offpeak='p' AND ISNULL(hg.hol_date,'')<>'' THEN 0  ELSE  hb.hr17 END +
						CASE WHEN hb.onpeak_offpeak='o' AND ISNULL(hg.hol_date,'')<>'' THEN 1 WHEN hb.onpeak_offpeak='p' AND ISNULL(hg.hol_date,'')<>'' THEN 0  ELSE  hb.hr18 END +
						CASE WHEN hb.onpeak_offpeak='o' AND ISNULL(hg.hol_date,'')<>'' THEN 1 WHEN hb.onpeak_offpeak='p' AND ISNULL(hg.hol_date,'')<>'' THEN 0  ELSE  hb.hr19 END +
						CASE WHEN hb.onpeak_offpeak='o' AND ISNULL(hg.hol_date,'')<>'' THEN 1 WHEN hb.onpeak_offpeak='p' AND ISNULL(hg.hol_date,'')<>'' THEN 0  ELSE  hb.hr20 END +
						CASE WHEN hb.onpeak_offpeak='o' AND ISNULL(hg.hol_date,'')<>'' THEN 1 WHEN hb.onpeak_offpeak='p' AND ISNULL(hg.hol_date,'')<>'' THEN 0  ELSE  hb.hr21 END +
						CASE WHEN hb.onpeak_offpeak='o' AND ISNULL(hg.hol_date,'')<>'' THEN 1 WHEN hb.onpeak_offpeak='p' AND ISNULL(hg.hol_date,'')<>'' THEN 0  ELSE  hb.hr22 END +
						CASE WHEN hb.onpeak_offpeak='o' AND ISNULL(hg.hol_date,'')<>'' THEN 1 WHEN hb.onpeak_offpeak='p' AND ISNULL(hg.hol_date,'')<>'' THEN 0  ELSE  hb.hr23 END +
						CASE WHEN hb.onpeak_offpeak='o' AND ISNULL(hg.hol_date,'')<>'' THEN 1 WHEN hb.onpeak_offpeak='p' AND ISNULL(hg.hol_date,'')<>'' THEN 0  ELSE  hb.hr24 END 
					) 
				WHEN sdd.deal_volume_frequency='h' AND sdh.block_type IS NULL THEN (datediff(hour,term_start,dateadd(DAY,1,term_end)))					
				WHEN sdd.deal_volume_frequency='d'then (datediff(day,term_start,term_end)+1)
				
				ELSE 1 
			END) 
		
		FROM
			source_deal_header sdh 
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id
			AND sdd.source_deal_detail_id=@deal_id
			LEFT JOIN temp_day td on td.term_date between sdd.term_start and sdd.term_end
			LEFT JOIN hourly_block hb on hb.block_value_id=sdh.block_define_id
			and hb.week_day=ISNULL(td.weekdays,DATEPART(dw,sdd.term_start))
			AND  hb.onpeak_offpeak= case when sdh.block_type=12000 THEN 'p'
									when sdh.block_type=12001 THEN 'o'
					END
			LEFT JOIN mv90_DST dst on dst.[date]=td.term_date
			LEFT JOIN holiday_group hg ON hg.hol_group_value_Id=hb.holiday_value_id
				 AND ((sdd.term_start=hg.hol_date AND td.term_date IS NULL) OR (td.term_date=hg.hol_date))
		where 1=1
			AND sdd.deal_volume_frequency IN('d','h')
			AND sdd.term_start=@term_start
		GROUP BY 
			sdd.term_end,sdd.term_start,sdd.deal_volume_frequency,sdh.block_type,sdh.block_define_id



	SELECT @pnl=
		CASE WHEN sdh.option_flag='y' THEN
			CASE WHEN ISNULL(option_type,'n')='c' THEN
				 (ISNULL(@market_value,0)-sdd.option_strike_price)*sdd.deal_volume*CASE WHEN sdd.buy_sell_flag='s' THEN -1 ELSE 1 END* ISNULL(@volume_multiplier,1)
				 WHEN ISNULL(option_type,'n')='p' THEN
				 (sdd.option_strike_price-ISNULL(@market_value,0))*sdd.deal_volume*CASE WHEN sdd.buy_sell_flag='s' THEN -1 ELSE 1 END*ISNULL(@volume_multiplier,1)
			END
		 ELSE	
			ISNULL(sdd.fixed_cost,0)+(ISNULL(@market_value,0)-ISNULL(sdd.fixed_cost,0)-ISNULL(sdd.price_adder,0))*ISNULL(sdd.price_multiplier,1)*sdd.deal_volume*CASE WHEN sdd.buy_sell_flag='s' THEN -1 ELSE 1 END*ISNULL(@volume_multiplier,1) END

	FROM
		source_deal_detail sdd
		INNER JOIN source_deal_header sdh on sdd.source_deal_header_id=sdh.source_deal_header_id
	WHERE
		sdd.source_deal_detail_id=@deal_id

--
	RETURN @pnl
END


