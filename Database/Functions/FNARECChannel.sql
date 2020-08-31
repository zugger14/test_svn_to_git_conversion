/****** Object:  UserDefinedFunction [dbo].[FNARECChannel]    Script Date: 07/28/2009 18:06:26 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARECChannel]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARECChannel]
/****** Object:  UserDefinedFunction [dbo].[FNARECChannel]    Script Date: 07/28/2009 18:06:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select [dbo].[FNARECChannel]('2012-07-01',NULL,980,21388,66,2,NULL)
CREATE FUNCTION [dbo].[FNARECChannel](
			    @maturity_date datetime, 
				@he INT,	
				@mins INT,
				@granularity INT,
			    @meter_id INT,
				@contract_id INT,
				@commodity INT, 	
			    @Channel int,
			    @block_define_id INT,
			    @is_dst INT,
				@counterparty_id INT			   
			)
RETURNS float AS  
BEGIN 

--DECLARE @maturity_date datetime, @he INT,	@granularity INT,@meter_id INT,@contract_id INT,@Channel int,@block_define_id INT 	

--SET @maturity_date = '2012-07-01'
--SET @he = NULL
--SET @granularity = 980
--SET @meter_id = 21388
--SET @contract_id = 66
--SET @Channel = 2
--SET @block_define_id = 291899

declare @maturity_date_from varchar(50)
declare @maturity_date_to varchar(50)
declare @billing_cycle as int
declare @billing_from_date as int
declare @billing_to_date as int
DECLARE @monthI Int
DECLARE @sum_volume as float
DECLARE @baseload_block INT
DECLARE @conversion_factor AS FLOAT
DECLARE @contract_start_Date DATETIME
DECLARE @contract_end_Date DATETIME
DECLARE @dst_group_value_id INT

	SELECT @dst_group_value_id = tz.dst_group_value_id FROM dbo.adiha_default_codes_values (nolock) adcv INNER JOIN time_zones tz
		ON tz.TIMEZONE_ID = adcv.var_value WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1
	
	set @sum_volume = NULL


	select @billing_cycle = billing_cycle, @contract_start_Date = COALESCE(cca.contract_start_date,cg.term_start,'1900-01-01'), @contract_end_Date = COALESCE(cca.contract_end_date,cg.term_end,'9999-01-01') 
		FROM contract_group cg LEFT JOIN counterparty_contract_address cca ON cca.contract_id = cg.contract_id AND cca.counterparty_id = @counterparty_id where cg.contract_id = @contract_id 
	SELECT @baseload_block = value_id  FROM static_data_value WHERE [type_id] = 10018 AND code LIKE 'Base Load'




if @billing_cycle = 986
begin
	select @billing_from_date = billing_from_date from contract_group where contract_id = @contract_id
	select @billing_to_date = billing_to_date from contract_group where contract_id = @contract_id

	SET @monthI = MONTH(@maturity_date)
	
	if @monthI = 1
	
		set @maturity_date_from = CAST(Year(@maturity_date)-1 As Varchar)  + '-' + 
					
						(CAST(12 As Varchar)) + '-' + CAST(@billing_from_date as varchar)
		
	
	else
	set @maturity_date_from = CAST(Year(@maturity_date) As Varchar)  + '-' + 
					CASE WHEN (@monthI < 10) then '0' else '' end + 
						(CAST(@monthI - 1 As Varchar)) + '-' + CAST(@billing_from_date as varchar)
	
	

	set @maturity_date_to = CAST(Year(@maturity_date) As Varchar)  + '-' + 
					CASE WHEN (@monthI < 10) then '0' else '' end + 
						(CAST(@monthI As Varchar)) + '-' + CAST(@billing_to_date as varchar)

end





	IF @granularity=980
	BEGIN
		;WITH CTE AS (
			SELECT
					hb.term_date,
					hb.block_type,
					hb.block_define_id,
					hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24
				FROM
					hour_block_term hb
				WHERE block_type=12000
					AND block_define_id=ISNULL(@block_define_id,@baseload_block)
					AND YEAR(term_date) = YEAR(@maturity_date)
					AND MONTH(term_date) = MONTH(@maturity_date)
					AND hb.dst_group_value_id = @dst_group_value_id
		)
		
		select @sum_volume = SUM(CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr7 ELSE mvh.hr1 END*ISNULL(ct.hr1,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr8 ELSE mvh.hr2 END*ISNULL(ct.hr2,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr9 ELSE mvh.hr3 END*ISNULL(ct.hr3,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr10 ELSE mvh.hr4 END*ISNULL(ct.hr4,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr11 ELSE mvh.hr5 END*ISNULL(ct.hr5,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr12 ELSE mvh.hr6 END*ISNULL(ct.hr6,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr13 ELSE mvh.hr7 END*ISNULL(ct.hr7,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr14 ELSE mvh.hr8 END*ISNULL(ct.hr8,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr15 ELSE mvh.hr9 END*ISNULL(ct.hr9,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr16 ELSE mvh.hr10 END*ISNULL(ct.hr10,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr17 ELSE mvh.hr11 END*ISNULL(ct.hr11,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr18 ELSE mvh.hr12 END*ISNULL(ct.hr12,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr19 ELSE mvh.hr13 END*ISNULL(ct.hr13,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr20 ELSE mvh.hr14 END*ISNULL(ct.hr14,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr21 ELSE mvh.hr15 END*ISNULL(ct.hr15,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr22 ELSE mvh.hr16 END*ISNULL(ct.hr16,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr23 ELSE mvh.hr17 END*ISNULL(ct.hr17,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr24 ELSE mvh.hr18 END*ISNULL(ct.hr18,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN ISNULL(mvh2.hr1,mvh1.hr1) ELSE mvh.hr19 END*ISNULL(ct.hr19,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN ISNULL(mvh2.hr2,mvh1.hr2) ELSE mvh.hr20 END*ISNULL(ct.hr20,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN ISNULL(mvh2.hr3,mvh1.hr3) ELSE mvh.hr21 END*ISNULL(ct.hr21,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN ISNULL(mvh2.hr4,mvh1.hr4) ELSE mvh.hr22 END*ISNULL(ct.hr22,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN ISNULL(mvh2.hr5,mvh1.hr5) ELSE mvh.hr23 END*ISNULL(ct.hr23,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN ISNULL(mvh2.hr6,mvh1.hr6) ELSE mvh.hr24 END*ISNULL(ct.hr24,1))
			
			FROM meter_id mi 
				INNER JOIN mv90_data mv	ON mi.meter_id=mv.meter_id
					AND YEAR(mv.from_date)=YEAR(@maturity_date)
					AND MONTH(mv.from_date)=MONTH(@maturity_date)
					AND mv.meter_id=@meter_id
					AND mv.channel=@channel
				INNER JOIN mv90_data_hour mvh ON mvh.meter_data_id=mv.meter_data_id
					LEFT JOIN mv90_data mv1 ON mv1.meter_id=mv.meter_id
						AND mv1.from_date=DATEADD(m,1,mv.from_date)
						AND mv1.channel=@channel
						AND ISNULL(@commodity,mi.commodity_id) = -1
				LEFT JOIN mv90_data_hour mvh1 ON mvh1.meter_data_id=mv1.meter_data_id
					AND DAY(mvh1.prod_date)=1	
					AND ISNULL(@commodity,mi.commodity_id) = -1
				LEFT JOIN mv90_data_hour mvh2 ON mvh2.meter_data_id=mv.meter_data_id
					AND mvh2.prod_date-1=mvh.prod_date
					AND ISNULL(@commodity,mi.commodity_id) = -1
				LEFT JOIN CTE ct ON ct.term_date = mvh.prod_date						
			WHERE
				mvh.prod_date >= @contract_start_Date AND mvh.prod_date <= @contract_end_Date


		IF @sum_volume IS NULL				
			SELECT @sum_volume = 
					SUM(mv.volume)
			FROM
				mv90_data
				mv
					where 	mv.meter_id=@meter_id and
						mv.channel=@channel	
						AND dbo.fnagetcontractmonth(mv.from_date)=dbo.fnagetcontractmonth(@maturity_date)
			GROUP BY
			mv.meter_id,mv.channel
	END
	ELSE IF @granularity=981
	BEGIN
		declare @maturity_date_eom datetime,@maturity_date_bom datetime

		set @maturity_date_bom=dbo.fnagetcontractmonth(@maturity_date)

		set @maturity_date_eom=dateadd(month,1,@maturity_date_bom)-1



		;WITH CTE AS (
			SELECT
					hb.term_date,
					hb.block_type,
					hb.block_define_id,
					hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24
				FROM
					hour_block_term hb
				WHERE block_type=12000
					AND block_define_id=ISNULL(@block_define_id,@baseload_block)
					AND term_date = @maturity_date
					AND dst_group_value_id = @dst_group_value_id
					
		)
		
		select @sum_volume = CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr7 ELSE mvh.hr1 END*ISNULL(ct.hr1,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr8 ELSE mvh.hr2 END*ISNULL(ct.hr2,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr9 ELSE mvh.hr3 END*ISNULL(ct.hr3,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr10 ELSE mvh.hr4 END*ISNULL(ct.hr4,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr11 ELSE mvh.hr5 END*ISNULL(ct.hr5,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr12 ELSE mvh.hr6 END*ISNULL(ct.hr6,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr13 ELSE mvh.hr7 END*ISNULL(ct.hr7,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr14 ELSE mvh.hr8 END*ISNULL(ct.hr8,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr15 ELSE mvh.hr9 END*ISNULL(ct.hr9,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr16 ELSE mvh.hr10 END*ISNULL(ct.hr10,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr17 ELSE mvh.hr11 END*ISNULL(ct.hr11,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr18 ELSE mvh.hr12 END*ISNULL(ct.hr12,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr19 ELSE mvh.hr13 END*ISNULL(ct.hr13,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr20 ELSE mvh.hr14 END*ISNULL(ct.hr14,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr21 ELSE mvh.hr15 END*ISNULL(ct.hr15,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr22 ELSE mvh.hr16 END*ISNULL(ct.hr16,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr23 ELSE mvh.hr17 END*ISNULL(ct.hr17,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN mvh.hr24 ELSE mvh.hr18 END*ISNULL(ct.hr18,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN ISNULL(mvh2.hr1,mvh1.hr1) ELSE mvh.hr19 END*ISNULL(ct.hr19,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN ISNULL(mvh2.hr2,mvh1.hr2) ELSE mvh.hr20 END*ISNULL(ct.hr20,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN ISNULL(mvh2.hr3,mvh1.hr3) ELSE mvh.hr21 END*ISNULL(ct.hr21,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN ISNULL(mvh2.hr4,mvh1.hr4) ELSE mvh.hr22 END*ISNULL(ct.hr22,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN ISNULL(mvh2.hr5,mvh1.hr5) ELSE mvh.hr23 END*ISNULL(ct.hr23,1)+
			CASE WHEN ISNULL(@commodity,mi.commodity_id)=-1 THEN ISNULL(mvh2.hr6,mvh1.hr6) ELSE mvh.hr24 END*ISNULL(ct.hr24,1)
			
			FROM meter_id mi 
				INNER JOIN mv90_data mv	ON mi.meter_id=mv.meter_id
					AND mv.from_date=@maturity_date_bom
					AND mv.meter_id=@meter_id
					AND mv.channel=@channel
				INNER JOIN mv90_data_hour mvh ON mvh.meter_data_id=mv.meter_data_id
					and mvh.prod_date=@maturity_date
				LEFT JOIN mv90_data mv1 ON mv1.meter_id=mv.meter_id
						AND mv1.from_date=DATEADD(m,1,mv.from_date)
						AND mv1.channel=@channel
						AND ISNULL(@commodity,mi.commodity_id) = -1
						and @maturity_date_eom=@maturity_date --maturity date is end of month
				LEFT JOIN mv90_data_hour mvh1 ON mvh1.meter_data_id=mv1.meter_data_id
					AND DAY(mvh1.prod_date)=1	--and mvh1.prod_date=@maturity_date+1
					AND ISNULL(@commodity,mi.commodity_id) = -1
				LEFT JOIN mv90_data_hour mvh2 ON mvh2.meter_data_id=mv.meter_data_id
					AND mvh2.prod_date-1=mvh.prod_date
					AND ISNULL(@commodity,mi.commodity_id) = -1
				LEFT JOIN CTE ct ON ct.term_date = mvh.prod_date						


		--IF @sum_volume IS NULL				
		--	SELECT @sum_volume = SUM(mv.volume)
		--	FROM mv90_data mv
		--	where 	mv.meter_id=@meter_id and mv.channel=@channel	
		--		AND dbo.fnagetcontractmonth(mv.from_date)=dbo.fnagetcontractmonth(@maturity_date)
		--	GROUP BY mv.meter_id,mv.channel
	END
	ELSE IF @granularity=982
	BEGIN
	
		;WITH CTE AS (
			SELECT
					hb.term_date,
					hb.block_type,
					hb.block_define_id,
					hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24
				FROM
					hour_block_term hb
				WHERE block_type=12000
					AND block_define_id=ISNULL(@block_define_id,@baseload_block)
					AND YEAR(term_date) = YEAR(@maturity_date)
					AND MONTH(term_date) = MONTH(@maturity_date)
					AND dst_group_value_id = @dst_group_value_id
		)
		select @sum_volume = CASE @he 
					WHEN 1 THEN mdh.hr1*ISNULL(ct.hr1,1)
					WHEN 2 THEN mdh.hr2*ISNULL(ct.hr2,1)
					WHEN 3 THEN CASE WHEN @is_dst = 0 THEN mdh.hr3 - ISNULL(mdh.hr25,0) ELSE mdh.hr25 END *ISNULL(ct.hr3,1)
					WHEN 4 THEN mdh.hr4*ISNULL(ct.hr4,1)
					WHEN 5 THEN mdh.hr5*ISNULL(ct.hr5,1)
					WHEN 6 THEN mdh.hr6*ISNULL(ct.hr6,1)
					WHEN 7 THEN mdh.hr7*ISNULL(ct.hr7,1)
					WHEN 8 THEN mdh.hr8*ISNULL(ct.hr8,1)
					WHEN 9 THEN mdh.hr9*ISNULL(ct.hr9,1)
					WHEN 10 THEN mdh.hr10*ISNULL(ct.hr10,1)
					WHEN 11 THEN mdh.hr11*ISNULL(ct.hr11,1)
					WHEN 12 THEN mdh.hr12*ISNULL(ct.hr12,1)
					WHEN 13 THEN mdh.hr13*ISNULL(ct.hr13,1)
					WHEN 14 THEN mdh.hr14*ISNULL(ct.hr14,1)
					WHEN 15 THEN mdh.hr15*ISNULL(ct.hr15,1)
					WHEN 16 THEN mdh.hr16*ISNULL(ct.hr16,1)
					WHEN 17 THEN mdh.hr17*ISNULL(ct.hr17,1)
					WHEN 18 THEN mdh.hr18*ISNULL(ct.hr18,1)
					WHEN 19 THEN mdh.hr19*ISNULL(ct.hr19,1)
					WHEN 20 THEN mdh.hr20*ISNULL(ct.hr20,1)
					WHEN 21 THEN mdh.hr21*ISNULL(ct.hr21,1)
					WHEN 22 THEN mdh.hr22*ISNULL(ct.hr22,1)
					WHEN 23 THEN mdh.hr23*ISNULL(ct.hr23,1)
					WHEN 24 THEN mdh.hr24*ISNULL(ct.hr24,1)
				END
			from mv90_data_hour mdh
				INNER JOIN mv90_data mv ON mv.meter_data_id=mdh.meter_data_id
				LEFT JOIN CTE ct ON ct.term_date = mdh.prod_date	
			where 	mv.meter_id=@meter_id and
				channel=@channel and	
				(prod_date) =(@maturity_date)
				AND  mdh.prod_date >= @contract_start_Date AND mdh.prod_date <= @contract_end_Date
			
	END

	ELSE IF @granularity IN (987,989)
	BEGIN
	
		;WITH CTE AS (
			SELECT
					hb.term_date,
					hb.block_type,
					hb.block_define_id,
					hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24
				FROM
					hour_block_term hb
				WHERE block_type=12000
					AND block_define_id=@block_define_id
					AND YEAR(term_date) = YEAR(@maturity_date)
					AND MONTH(term_date) = MONTH(@maturity_date)
					AND dst_group_value_id = @dst_group_value_id
		)
		select @sum_volume = CASE @he 
				WHEN 1 THEN 
						CASE @mins WHEN 15 THEN mdh.Hr1_15 WHEN 30 THEN mdh.Hr1_30 WHEN 45 THEN mdh.Hr1_45 WHEN 60 THEN mdh.Hr1_60 END *ISNULL(ct.hr1,1)
					WHEN 2 THEN
						CASE @mins WHEN 15 THEN mdh.Hr2_15 WHEN 30 THEN mdh.Hr2_30 WHEN 45 THEN mdh.Hr2_45 WHEN 60 THEN mdh.Hr2_60 END *ISNULL(ct.hr1,1)
					WHEN 3 THEN CASE WHEN @is_dst = 0 THEN
							CASE @mins WHEN 15 THEN mdh.Hr3_15 - ISNULL(mdh.Hr25_15,0) WHEN 30 THEN mdh.Hr3_30 - ISNULL(mdh.Hr25_30,0) WHEN 45 THEN mdh.Hr3_45 - ISNULL(mdh.Hr25_45,0) WHEN 60 THEN mdh.Hr3_60 - ISNULL(mdh.Hr25_60,0) END *ISNULL(ct.hr1,1)
						ELSE
							CASE @mins WHEN 15 THEN mdh.Hr25_15 WHEN 30 THEN mdh.Hr25_30 WHEN 45 THEN mdh.Hr25_45 WHEN 60 THEN mdh.Hr25_60 END *ISNULL(ct.hr1,1)
						END		
					WHEN 4 THEN
						CASE @mins WHEN 15 THEN mdh.Hr4_15 WHEN 30 THEN mdh.Hr4_30 WHEN 45 THEN mdh.Hr4_45 WHEN 60 THEN mdh.Hr4_60 END *ISNULL(ct.hr1,1)
					WHEN 5 THEN 
						CASE @mins WHEN 15 THEN mdh.Hr5_15 WHEN 30 THEN mdh.Hr5_30 WHEN 45 THEN mdh.Hr5_45 WHEN 60 THEN mdh.Hr5_60 END *ISNULL(ct.hr1,1)
					WHEN 6 THEN 
						CASE @mins WHEN 15 THEN mdh.Hr6_15 WHEN 30 THEN mdh.Hr6_30 WHEN 45 THEN mdh.Hr6_45 WHEN 60 THEN mdh.Hr6_60 END *ISNULL(ct.hr1,1)
					WHEN 7 THEN 
						CASE @mins WHEN 15 THEN mdh.Hr7_15 WHEN 30 THEN mdh.Hr7_30 WHEN 45 THEN mdh.Hr7_45 WHEN 60 THEN mdh.Hr7_60 END *ISNULL(ct.hr1,1)
					WHEN 8 THEN 
						CASE @mins WHEN 15 THEN mdh.Hr8_15 WHEN 30 THEN mdh.Hr8_30 WHEN 45 THEN mdh.Hr8_45 WHEN 60 THEN mdh.Hr8_60 END *ISNULL(ct.hr1,1)
					WHEN 9 THEN 
						CASE @mins WHEN 15 THEN mdh.Hr9_15 WHEN 30 THEN mdh.Hr9_30 WHEN 45 THEN mdh.Hr9_45 WHEN 60 THEN mdh.Hr9_60 END *ISNULL(ct.hr1,1)
					WHEN 10 THEN 
						CASE @mins WHEN 15 THEN mdh.Hr10_15 WHEN 30 THEN mdh.Hr10_30 WHEN 45 THEN mdh.Hr10_45 WHEN 60 THEN mdh.Hr10_60 END *ISNULL(ct.hr1,1)
					WHEN 11 THEN 
						CASE @mins WHEN 15 THEN mdh.Hr11_15 WHEN 30 THEN mdh.Hr11_30 WHEN 45 THEN mdh.Hr11_45 WHEN 60 THEN mdh.Hr11_60 END *ISNULL(ct.hr1,1)
					WHEN 12 THEN 
						CASE @mins WHEN 15 THEN mdh.Hr12_15 WHEN 30 THEN mdh.Hr12_30 WHEN 45 THEN mdh.Hr12_45 WHEN 60 THEN mdh.Hr12_60 END *ISNULL(ct.hr1,1)
					WHEN 13 THEN 
						CASE @mins WHEN 15 THEN mdh.Hr13_15 WHEN 30 THEN mdh.Hr13_30 WHEN 45 THEN mdh.Hr13_45 WHEN 60 THEN mdh.Hr13_60 END *ISNULL(ct.hr1,1)
					WHEN 14 THEN 
						CASE @mins WHEN 15 THEN mdh.Hr14_15 WHEN 30 THEN mdh.Hr14_30 WHEN 45 THEN mdh.Hr14_45 WHEN 60 THEN mdh.Hr14_60 END *ISNULL(ct.hr1,1)
					WHEN 15 THEN 
						CASE @mins WHEN 15 THEN mdh.Hr15_15 WHEN 30 THEN mdh.Hr15_30 WHEN 45 THEN mdh.Hr15_45 WHEN 60 THEN mdh.Hr15_60 END *ISNULL(ct.hr1,1)
					WHEN 16 THEN 
						CASE @mins WHEN 15 THEN mdh.Hr16_15 WHEN 30 THEN mdh.Hr16_30 WHEN 45 THEN mdh.Hr16_45 WHEN 60 THEN mdh.Hr16_60 END *ISNULL(ct.hr1,1)
					WHEN 17 THEN 
						CASE @mins WHEN 15 THEN mdh.Hr17_15 WHEN 30 THEN mdh.Hr17_30 WHEN 45 THEN mdh.Hr17_45 WHEN 60 THEN mdh.Hr17_60 END *ISNULL(ct.hr1,1)
					WHEN 18 THEN 
						CASE @mins WHEN 15 THEN mdh.Hr18_15 WHEN 30 THEN mdh.Hr18_30 WHEN 45 THEN mdh.Hr18_45 WHEN 60 THEN mdh.Hr18_60 END *ISNULL(ct.hr1,1)
					WHEN 19 THEN 
						CASE @mins WHEN 15 THEN mdh.Hr19_15 WHEN 30 THEN mdh.Hr19_30 WHEN 45 THEN mdh.Hr19_45 WHEN 60 THEN mdh.Hr19_60 END *ISNULL(ct.hr1,1)
					WHEN 20 THEN 
						CASE @mins WHEN 15 THEN mdh.Hr20_15 WHEN 30 THEN mdh.Hr20_30 WHEN 45 THEN mdh.Hr20_45 WHEN 60 THEN mdh.Hr20_60 END *ISNULL(ct.hr1,1)
					WHEN 21 THEN 
						CASE @mins WHEN 15 THEN mdh.Hr21_15 WHEN 30 THEN mdh.Hr21_30 WHEN 45 THEN mdh.Hr21_45 WHEN 60 THEN mdh.Hr21_60 END *ISNULL(ct.hr1,1)
					WHEN 22 THEN 
						CASE @mins WHEN 15 THEN mdh.Hr22_15 WHEN 30 THEN mdh.Hr22_30 WHEN 45 THEN mdh.Hr22_45 WHEN 60 THEN mdh.Hr22_60 END *ISNULL(ct.hr1,1)
					WHEN 23 THEN 
						CASE @mins WHEN 15 THEN mdh.Hr23_15 WHEN 30 THEN mdh.Hr23_30 WHEN 45 THEN mdh.Hr23_45 WHEN 60 THEN mdh.Hr23_60 END *ISNULL(ct.hr1,1)
					WHEN 24 THEN 
						CASE @mins WHEN 15 THEN mdh.Hr24_15 WHEN 30 THEN mdh.Hr24_30 WHEN 45 THEN mdh.Hr24_45 WHEN 60 THEN mdh.Hr24_60 END *ISNULL(ct.hr1,1)
						
				END
			FROM mv90_data_mins mdh
				INNER JOIN mv90_data mv ON mv.meter_data_id=mdh.meter_data_id
				LEFT JOIN CTE ct ON ct.term_date = mdh.prod_date	
				LEFT JOIN mv90_dst dst ON dst.[date] = mdh.prod_date AND dst.insert_delete ='i'
					AND dst.dst_group_value_id = @dst_group_value_id
			WHERE 
				 mv.meter_id=@meter_id and
				channel=@channel and	
				(prod_date) =(@maturity_date)
				AND  mdh.prod_date >= @contract_start_Date AND mdh.prod_date <= @contract_end_Date
			
	END	
	ELSE IF @granularity IN(994,995) -- 10 amd 15 Minutes
	BEGIN
	
		;WITH CTE AS (
			SELECT
					hb.term_date,
					hb.block_type,
					hb.block_define_id,
					hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24
				FROM
					hour_block_term hb
				WHERE block_type=12000
					AND block_define_id=ISNULL(@block_define_id,@baseload_block)
					AND YEAR(term_date) = YEAR(@maturity_date)
					AND MONTH(term_date) = MONTH(@maturity_date)
					AND dst_group_value_id = @dst_group_value_id
		)
		select @sum_volume = CASE @he 
					WHEN 1 THEN mdh.hr1*ISNULL(ct.hr1,1)
					WHEN 2 THEN mdh.hr2*ISNULL(ct.hr2,1)
					WHEN 3 THEN CASE WHEN @is_dst = 0 THEN mdh.hr3 - ISNULL(mdh.hr25,0) ELSE mdh.hr25 END *ISNULL(ct.hr3,1)
					WHEN 4 THEN mdh.hr4*ISNULL(ct.hr4,1)
					WHEN 5 THEN mdh.hr5*ISNULL(ct.hr5,1)
					WHEN 6 THEN mdh.hr6*ISNULL(ct.hr6,1)
					WHEN 7 THEN mdh.hr7*ISNULL(ct.hr7,1)
					WHEN 8 THEN mdh.hr8*ISNULL(ct.hr8,1)
					WHEN 9 THEN mdh.hr9*ISNULL(ct.hr9,1)
					WHEN 10 THEN mdh.hr10*ISNULL(ct.hr10,1)
					WHEN 11 THEN mdh.hr11*ISNULL(ct.hr11,1)
					WHEN 12 THEN mdh.hr12*ISNULL(ct.hr12,1)
					WHEN 13 THEN mdh.hr13*ISNULL(ct.hr13,1)
					WHEN 14 THEN mdh.hr14*ISNULL(ct.hr14,1)
					WHEN 15 THEN mdh.hr15*ISNULL(ct.hr15,1)
					WHEN 16 THEN mdh.hr16*ISNULL(ct.hr16,1)
					WHEN 17 THEN mdh.hr17*ISNULL(ct.hr17,1)
					WHEN 18 THEN mdh.hr18*ISNULL(ct.hr18,1)
					WHEN 19 THEN mdh.hr19*ISNULL(ct.hr19,1)
					WHEN 20 THEN mdh.hr20*ISNULL(ct.hr20,1)
					WHEN 21 THEN mdh.hr21*ISNULL(ct.hr21,1)
					WHEN 22 THEN mdh.hr22*ISNULL(ct.hr22,1)
					WHEN 23 THEN mdh.hr23*ISNULL(ct.hr23,1)
					WHEN 24 THEN mdh.hr24*ISNULL(ct.hr24,1)
				END
			from mv90_data_hour mdh
				INNER JOIN mv90_data mv ON mv.meter_data_id=mdh.meter_data_id
				LEFT JOIN CTE ct ON ct.term_date = mdh.prod_date	
			where 	mv.meter_id=@meter_id and
				channel=@channel and	
				(prod_date) =(@maturity_date)
				AND  mdh.prod_date >= @contract_start_Date AND mdh.prod_date <= @contract_end_Date
				AND mdh.period = @mins
			
	END


	SELECT @conversion_factor = ISNULL(conversion_factor,1) from recorder_properties rp 
							INNER JOIN  rec_volume_unit_conversion conv ON  conv.from_source_uom_id = rp.uom_id
							INNER JOIN contract_group cg on cg.contract_id = @contract_id
									AND conv.to_source_uom_id = cg.volume_uom
						 WHERE  rp.meter_id = @meter_id AND rp.channel = @channel 	
	RETURN @sum_volume * ISNULL(@conversion_factor,1)

END





