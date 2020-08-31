/****** Object:  UserDefinedFunction [dbo].[FNARInterruptVol]    Script Date: 05/02/2011 11:23:43 ******/
IF  EXISTS (SELECT * FROM  sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[FNARInterruptVol]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARInterruptVol]
GO
/****** Object:  UserDefinedFunction [dbo].[FNARInterruptVol]    Script Date: 05/02/2011 11:23:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT dbo.FNARInterruptVol('2007-10-01',316,255,0)
CREATE FUNCTION [dbo].[FNARInterruptVol] (
	@maturity_date DATETIME,
	@counterparty_id AS VARCHAR(50),
	@contract_id AS VARCHAR(50),
	@daily INT		-- 1 for daily , 0 for MONTHly
	)
RETURNS FLOAT AS  
BEGIN  
	


	DECLARE @maturity_date_FROM  VARCHAR(50)
	DECLARE @maturity_date_to VARCHAR(50)
	DECLARE @retValue AS FLOAT

	DECLARE @hourly_block INT
	DECLARE @billing_cycle INT
	DECLARE @billing_from_date INT
	DECLARE @billing_to_date INT
	DECLARE @MONTHI INT
	DECLARE @where_condition VARCHAR(500)
	DECLARE @maturity_MONTH VARCHAR(50)
	DECLARE @interruptVol FLOAT
	DECLARE @int_end_MONTH INT
	DECLARE @intstartMONTH INT
	DECLARE @isinterrupt DATETIME
	DECLARE @int_start_period DATETIME
	DECLARE @int_end_period DATETIME

	SELECT @int_end_MONTH=MAX(int_end_MONTH) FROM  contract_group_detail WHERE  contract_id=@contract_id
	SELECT @isinterrupt=dbo.FNARIsInterrupt(@maturity_date,@counterparty_id,@contract_id,3)
	SET @intstartMONTH=MONTH(@isinterrupt)

	SELECT @int_start_period=(CAST(CASE WHEN  MAX(int_BEGIN_MONTH)>MAX(int_end_MONTH) and MONTH(@maturity_date)<=MAX(int_end_MONTH) THEN  
					 YEAR(@maturity_date)-1 
				WHEN  MAX(int_begin_month)>MAX(int_end_MONTH) and MONTH(@maturity_date)>MAX(int_end_MONTH) THEN  
					 YEAR(@maturity_date)
				WHEN  MAX(int_begin_month)<MAX(int_end_MONTH)THEN  
					 YEAR(@maturity_date) 
				END AS VARCHAR)+'-'+CAST(MAX(int_begin_month) AS VARCHAR)+'-01' ),
			 @int_end_period=(CAST(CASE WHEN  MAX(int_begin_month)>MAX(int_end_MONTH) and MONTH(@maturity_date)<=MAX(int_end_MONTH) THEN  
					 YEAR(@maturity_date)
				WHEN  MAX(int_begin_month)>MAX(int_end_MONTH) and MONTH(@maturity_date)>MAX(int_end_MONTH) THEN  
					 YEAR(@maturity_date)+1
				WHEN  MAX(int_begin_month)<MAX(int_end_MONTH)THEN  
					 YEAR(@maturity_date)
				END AS VARCHAR)+'-'+CAST(MAX(int_end_MONTH) AS VARCHAR)+'-01')
		  FROM  contract_group_detail WHERE  contract_id=@contract_id



	SELECT @billing_cycle = billing_cycle FROM  contract_group WHERE  contract_id = @contract_id 



	IF @billing_cycle = 990
	BEGIN 
		SELECT @billing_from_date = billing_from_date FROM  contract_group WHERE  contract_id = @contract_id
		SELECT @billing_to_date = billing_to_date FROM  contract_group WHERE  contract_id = @contract_id

		

		SET @MONTHI = MONTH(@maturity_date)
		
		SET @maturity_date_FROM  = CAST(YEAR(@maturity_date)-CASE WHEN  MONTH(@maturity_date)=1 THEN  1 else 0 END AS VARCHAR)  + '-' + 
						CASE WHEN  (@MONTHI< 10 and MONTH(@maturity_date)<>1 ) THEN  '0' else '' END + 
							(CAST(CASE WHEN  MONTH(@maturity_date)=1 THEN  12 else @MONTHI-1 END AS VARCHAR)) + '-' + CAST(@billing_from_date AS VARCHAR)
		
		

		SET @maturity_date_to = CAST(YEAR(@maturity_date) AS VARCHAR)  + '-' + 
						CASE WHEN  (@MONTHI < 10) THEN  '0' else '' END + 
							(CAST(@MONTHI AS VARCHAR)) + '-' + CAST(@billing_to_date AS VARCHAR)

		SET @where_condition = ' prod_date between ''' + @maturity_date_FROM  + ''' and ''' + @maturity_date_to + ''''
	end
	else
		SET @maturity_MONTH = CAST(YEAR(@maturity_date) AS VARCHAR)  + '-' + 
						CASE WHEN  (@MONTHI < 10) THEN  '0' else '' END + 
							(CAST(MONTH(@maturity_date) AS VARCHAR))

	

		SELECT @interruptVol = avg(Val)*4 FROM 
		(
			  SELECT prod_date,sum([Value]) as Val, Hr--,hr_begin_proxy, min_begin_proxy, hr_end_proxy, min_end_proxy
				FROM 
				(SELECT contract_id,ida.prod_date,mv.channel,hr_BEGIN ,hr_begin_proxy,min_BEGIN ,min_begin_proxy,hr_end,
					hr_end_proxy,min_end,min_end_proxy,
					Hr1_15 , Hr1_30, Hr1_45, Hr1_60,
					Hr2_15, Hr2_30, Hr2_45, Hr2_60,
					Hr3_15, Hr3_30, Hr3_45, Hr3_60,
					Hr4_15, Hr4_30, Hr4_45, Hr4_60,
					Hr5_15, Hr5_30, Hr5_45, Hr5_60,
					Hr6_15, Hr6_30, Hr6_45, Hr6_60,
					Hr7_15, Hr7_30, Hr7_45, Hr7_60,
					Hr8_15, Hr8_30, Hr8_45, Hr8_60,
					Hr9_15, Hr9_30, Hr9_45, Hr9_60,
					Hr10_15, Hr10_30, Hr10_45, Hr10_60,
					Hr11_15, Hr11_30, Hr11_45, Hr11_60,
					Hr12_15, Hr12_30, Hr12_45, Hr12_60,
					Hr13_15, Hr13_30, Hr13_45, Hr13_60,
					Hr14_15, Hr14_30, Hr14_45, Hr14_60,
					Hr15_15, Hr15_30, Hr15_45, Hr15_60,
					Hr16_15, Hr16_30, Hr16_45, Hr16_60,
					Hr17_15, Hr17_30, Hr17_45, Hr17_60,
					Hr18_15, Hr18_30, Hr18_45, Hr18_60,
					Hr19_15, Hr19_30, Hr19_45, Hr19_60,
					Hr20_15, Hr20_30, Hr20_45, Hr20_60,
					Hr21_15, Hr21_30, Hr21_45, Hr21_60,
					Hr22_15, Hr22_30, Hr22_45, Hr22_60,
					Hr23_15, Hr23_30, Hr23_45, Hr23_60,
					Hr24_15, Hr24_30, Hr24_45, Hr24_60

				FROM  interrupt_data ida
				inner join rec_generator rg on rg.ppa_contract_id = ida.contract_id
				inner join recorder_generator_map_submeter rgm on rgm.generator_id = rg.generator_id
				inner join recorder_properties rp on rp.meter_id = rgm.meter_id
				inner join mv90_data mv ON mv.meter_id = rp.meter_id AND mv.channel = rp.channel
				inner join mv90_data_mins mdm on mdm.meter_data_id=mv.meter_data_id
					and mdm.prod_date = ida.prod_date
				WHERE 
				
				ida.contract_id = @contract_id 
				and
					(
						 @daily = 0 and 
						 
							(
							(@int_end_MONTH is not null and @int_end_MONTH=MONTH(@maturity_date) and MONTH(ida.prod_date)
								between @intstartMONTH and @int_end_MONTH )
							OR
							(@billing_cycle = 990-- AND ida.prod_date between @maturity_date_FROM  and @maturity_date_to and @int_end_MONTH<>MONTH(@maturity_date))
								 and ida.prod_date between @int_start_period and @int_end_period
								 and @maturity_date_FROM  between @int_start_period and @int_end_period
								 and ida.prod_date<=@maturity_date_to)
									OR 
							(@billing_cycle = 976 
								 and ida.prod_date between @int_start_period and @int_end_period
								 and @maturity_date between @int_start_period and @int_end_period
								 and ida.prod_date<=@maturity_date)
							))
						or
						(@daily = 1 and ida.prod_date = @maturity_date)
				) p
				
				unpivot 
				([Value] FOR Hr IN 
						(
							Hr1_15, Hr1_30, Hr1_45, Hr1_60,
							Hr2_15, Hr2_30, Hr2_45, Hr2_60,
							Hr3_15, Hr3_30, Hr3_45, Hr3_60,
							Hr4_15, Hr4_30, Hr4_45, Hr4_60,
							Hr5_15, Hr5_30, Hr5_45, Hr5_60,
							Hr6_15, Hr6_30, Hr6_45, Hr6_60,
							Hr7_15, Hr7_30, Hr7_45, Hr7_60,
							Hr8_15, Hr8_30, Hr8_45, Hr8_60,
							Hr9_15, Hr9_30, Hr9_45, Hr9_60,
							Hr10_15, Hr10_30, Hr10_45, Hr10_60,
							Hr11_15, Hr11_30, Hr11_45, Hr11_60,
							Hr12_15, Hr12_30, Hr12_45, Hr12_60,
							Hr13_15, Hr13_30, Hr13_45, Hr13_60,
							Hr14_15, Hr14_30, Hr14_45, Hr14_60,
							Hr15_15, Hr15_30, Hr15_45, Hr15_60,
							Hr16_15, Hr16_30, Hr16_45, Hr16_60,
							Hr17_15, Hr17_30, Hr17_45, Hr17_60,
							Hr18_15, Hr18_30, Hr18_45, Hr18_60,
							Hr19_15, Hr19_30, Hr19_45, Hr19_60,
							Hr20_15, Hr20_30, Hr20_45, Hr20_60,
							Hr21_15, Hr21_30, Hr21_45, Hr21_60,
							Hr22_15, Hr22_30, Hr22_45, Hr22_60,
							Hr23_15, Hr23_30, Hr23_45, Hr23_60,
							Hr24_15, Hr24_30, Hr24_45, Hr24_60
						)
				)AS unpvt 
				WHERE  
				(
				@daily = 0 and 
				(
					CAST(substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,(charindex('_',unpvt.Hr)-(charindex('r',unpvt.Hr))-1)) AS INT) 
					>= hr_begin_proxy and
					CAST(substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,(charindex('_',unpvt.Hr)-(charindex('r',unpvt.Hr))-1)) AS INT) 
					<= hr_end_proxy 
					and
					(
						(
							CAST(substring(unpvt.Hr,charindex('_',unpvt.Hr)+1,(len(unpvt.Hr)-(charindex('_',unpvt.Hr))+1)) AS INT) >=
								case 
									WHEN  CAST(substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,(charindex('_',unpvt.Hr)-(charindex('r',unpvt.Hr))-1)) AS INT) 
									= hr_begin_proxy THEN  min_begin_proxy end
							
						)
					
							OR
						(
							CAST(substring(unpvt.Hr,charindex('_',unpvt.Hr)+1,(len(unpvt.Hr)-(charindex('_',unpvt.Hr))+1)) AS INT) <
								case 
									WHEN  CAST(substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,(charindex('_',unpvt.Hr)-(charindex('r',unpvt.Hr))-1)) AS INT) 
									= hr_end_proxy THEN  min_end_proxy end
							
						)
							OR
						(
							CAST(substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,(charindex('_',unpvt.Hr)-(charindex('r',unpvt.Hr))-1)) AS INT) 
									> hr_begin_proxy
							AND
						CAST(substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,(charindex('_',unpvt.Hr)-(charindex('r',unpvt.Hr))-1)) AS INT) 
									< hr_end_proxy
						)
					)
				)
			)
			or
			(
				@daily = 1 and hr_BEGIN  is not null and hr_END is not null and 
				(
					CAST(substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,(charindex('_',unpvt.Hr)-(charindex('r',unpvt.Hr))-1)) AS INT) 
					>= hr_begin_proxy and
					CAST(substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,(charindex('_',unpvt.Hr)-(charindex('r',unpvt.Hr))-1)) AS INT) 
					<= hr_end_proxy 
					and
					(
						(
							CAST(substring(unpvt.Hr,charindex('_',unpvt.Hr)+1,(len(unpvt.Hr)-(charindex('_',unpvt.Hr))+1)) AS INT) >=
								case 
									WHEN  CAST(substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,(charindex('_',unpvt.Hr)-(charindex('r',unpvt.Hr))-1)) AS INT) 
									= hr_begin_proxy THEN  min_begin_proxy end
							
						)
					
							OR
						(
							CAST(substring(unpvt.Hr,charindex('_',unpvt.Hr)+1,(len(unpvt.Hr)-(charindex('_',unpvt.Hr))+1)) AS INT) <
								case 
									WHEN  CAST(substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,(charindex('_',unpvt.Hr)-(charindex('r',unpvt.Hr))-1)) AS INT) 
									= hr_end_proxy THEN  min_end_proxy end
							
						)
							OR
						(
							CAST(substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,(charindex('_',unpvt.Hr)-(charindex('r',unpvt.Hr))-1)) AS INT) 
									> hr_begin_proxy
							AND
						CAST(substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,(charindex('_',unpvt.Hr)-(charindex('r',unpvt.Hr))-1)) AS INT) 
									< hr_end_proxy
						)
					)
				)
			)
			or
			(
				@daily = 1 and hr_BEGIN  is null and 1=1
				
			)
				GROUP BY contract_id,prod_date, Hr
		) x

	IF @interruptVol is null
		SET @interruptVol = 0

	RETURN @interruptVol
	END














