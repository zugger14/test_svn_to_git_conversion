/****** Object:  UserDefinedFunction [dbo].[FNARCVD]    Script Date: 05/02/2011 11:15:23 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARCVD]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARCVD]
GO
/****** Object:  UserDefinedFunction [dbo].[FNARCVD]    Script Date: 05/02/2011 11:15:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNARCVD] (
	@maturity_date datetime,
	@counterparty_id as varchar(50),
	@contract_id as varchar(50),
	@minFlag int,
	@channel int
	)
RETURNS float AS  
BEGIN 
	
--declare @maturity_date datetime,@counterparty_id int,@contract_id int,@minFlag int
--
--set @maturity_date='2007-07-01'
--set @counterparty_id=323
--set @contract_id=267
--set @minFlag=15


declare @maturity_date_temp as datetime
declare @retValue as float
declare @multiplyBy as int
declare @hourly_block as int


declare @maturity_date_from varchar(50)
declare @maturity_date_to varchar(50)
declare @billing_cycle as int
declare @billing_from_date as int
declare @billing_to_date as int
DECLARE @monthI Int
declare @where_condition varchar(500)
declare @maturity_month varchar(50)


select @billing_cycle = billing_cycle from contract_group where contract_id = @contract_id 


SET @monthI = MONTH(@maturity_date)

if @billing_cycle = 990
begin
	select @billing_from_date = billing_from_date from contract_group where contract_id = @contract_id
	select @billing_to_date = billing_to_date from contract_group where contract_id = @contract_id

	


	
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

	set @where_condition = ' prod_date between ''' + @maturity_date_from + ''' and ''' + @maturity_date_to + ''''
end
else
	set @maturity_month = CAST(Year(@maturity_date) As Varchar)  + '-' + 
					CASE WHEN (@monthI < 10) then '0' else '' end + 
						(CAST(Month(@maturity_date) As Varchar))




if @minFlag = 15
begin
	set @multiplyBy = 4
end
else if @minFlag = 30
begin
	set @multiplyBy = 4
end
else if @minFlag = 60
begin
	set @multiplyBy = 1
end




select @maturity_date_temp = dbo.fnagetcontractmonth(max(prod_date)) 
FROM 
	mv90_data md
	INNER JOIN mv90_data_mins mdm ON md.meter_data_id = mdm.meter_data_id
	INNER JOIN recorder_properties rp on rp.meter_id = md.meter_id and rp.channel = md.channel
	INNER JOIN recorder_generator_map rgm on rgm.meter_id = rp.meter_id
	INNER JOIN rec_generator rg on rg.generator_id = rgm.generator_id and rg.ppa_counterparty_id = @counterparty_id
	and rg.ppa_contract_id = @contract_id
where dbo.fnagetcontractmonth(mdm.prod_date) <= @maturity_date

set @maturity_date = @maturity_date_temp
--print(dbo.fnagetcontractmonth(@maturity_date))

select @hourly_block = hourly_block 
from contract_group where contract_id = @contract_id

	if @minFlag =15
	begin
	

	if @hourly_block IS NOT NULL
	BEGIN
		--select a.*,b.* from 
		select @retValue =  max((b.[Value]*a.flag)*@multiplyBy)  from 
		(
		select  Hr, flag,week_day
		from
			( select hb.block_value_id, hb.week_day, hb.onpeak_offpeak,
					hb.Hr1, hb.Hr2, hb.Hr3, hb.Hr4, hb.Hr5, hb.Hr6, hb.Hr7, hb.Hr8, hb.Hr9, hb.Hr10, hb.Hr11, hb.Hr12, 
					hb.Hr13, hb.Hr14, hb.Hr15, hb.Hr16, hb.Hr17, hb.Hr18, hb.Hr19, hb.Hr20, hb.Hr21,hb.Hr22, hb.Hr23, hb.Hr24
				from hourly_block hb
				
				where hb.block_value_id = @hourly_block and hb.onpeak_offpeak = 'p'
				--where hb.block_value_id = 295490 and hb.onpeak_offpeak = 'p' and week_day = 2
			) p
		unpivot
			( flag for Hr in
				(
					Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17, Hr18,
					Hr19, Hr20, Hr21, Hr22, Hr23, Hr24
				)
			) 
		as unpvt --where flag = 1
		) a inner join

		(SELECT meter_id,channel,prod_date, Hr, [Value]
		--SELECT max([Value]*4)
		FROM 


			(SELECT max(md.meter_id) meter_id, max(md.channel) channel, mdm.prod_date, 
				sum(mdm.Hr1_15 ) as Hr1_15, sum(mdm.Hr1_30 ) as Hr1_30, sum(mdm.Hr1_45 ) as Hr1_45, sum(mdm.Hr1_60 ) as Hr1_60,
				sum(mdm.Hr2_15 ) as Hr2_15, sum(mdm.Hr2_30 ) as Hr2_30, sum(mdm.Hr2_45 ) as Hr2_45, sum(mdm.Hr2_60 ) as Hr2_60,
				sum(mdm.Hr3_15 ) as Hr3_15, sum(mdm.Hr3_30 ) as Hr3_30, sum(mdm.Hr3_45 ) as Hr3_45, sum(mdm.Hr3_60 ) as Hr3_60,
				sum(mdm.Hr4_15 ) as Hr4_15, sum(mdm.Hr4_30 ) as Hr4_30, sum(mdm.Hr4_45 ) as Hr4_45, sum(mdm.Hr4_60 ) as Hr4_60,
				sum(mdm.Hr5_15 ) as Hr5_15, sum(mdm.Hr5_30 ) as Hr5_30, sum(mdm.Hr5_45 ) as Hr5_45, sum(mdm.Hr5_60 ) as Hr5_60,
				sum(mdm.Hr6_15 ) as Hr6_15, sum(mdm.Hr6_30 ) as Hr6_30, sum(mdm.Hr6_45 ) as Hr6_45, sum(mdm.Hr6_60 ) as Hr6_60,
				sum(mdm.Hr7_15 ) as Hr7_15, sum(mdm.Hr7_30 ) as Hr7_30, sum(mdm.Hr7_45 ) as Hr7_45, sum(mdm.Hr7_60 ) as Hr7_60,
				sum(mdm.Hr8_15 ) as Hr8_15, sum(mdm.Hr8_30 ) as Hr8_30, sum(mdm.Hr8_45 ) as Hr8_45, sum(mdm.Hr8_60 ) as Hr8_60,
				sum(mdm.Hr9_15 ) as Hr9_15, sum(mdm.Hr9_30 ) as Hr9_30, sum(mdm.Hr9_45 ) as Hr9_45, sum(mdm.Hr9_60 ) as Hr9_60,
				sum(mdm.Hr10_15 ) as Hr10_15, sum(mdm.Hr10_30 ) as Hr10_30, sum(mdm.Hr10_45 ) as Hr10_45, sum(mdm.Hr10_60 ) as Hr10_60,
				sum(mdm.Hr11_15 ) as Hr11_15, sum(mdm.Hr11_30 ) as Hr11_30, sum(mdm.Hr11_45 ) as Hr11_45, sum(mdm.Hr11_60 ) as Hr11_60,
				sum(mdm.Hr12_15 ) as Hr12_15, sum(mdm.Hr12_30 ) as Hr12_30, sum(mdm.Hr12_45 ) as Hr12_45, sum(mdm.Hr12_60 ) as Hr12_60,
				sum(mdm.Hr13_15 ) as Hr13_15, sum(mdm.Hr13_30 ) as Hr13_30, sum(mdm.Hr13_45 ) as Hr13_45, sum(mdm.Hr13_60 ) as Hr13_60,
				sum(mdm.Hr14_15 ) as Hr14_15, sum(mdm.Hr14_30 ) as Hr14_30, sum(mdm.Hr14_45 ) as Hr14_45, sum(mdm.Hr14_60 ) as Hr14_60,
				sum(mdm.Hr15_15 ) as Hr15_15, sum(mdm.Hr15_30 ) as Hr15_30, sum(mdm.Hr15_45 ) as Hr15_45, sum(mdm.Hr15_60 ) as Hr15_60,
				sum(mdm.Hr16_15 ) as Hr16_15, sum(mdm.Hr16_30 ) as Hr16_30, sum(mdm.Hr16_45 ) as Hr16_45, sum(mdm.Hr16_60 ) as Hr16_60,
				sum(mdm.Hr17_15 ) as Hr17_15, sum(mdm.Hr17_30 ) as Hr17_30, sum(mdm.Hr17_45 ) as Hr17_45, sum(mdm.Hr17_60 ) as Hr17_60,
				sum(mdm.Hr18_15 ) as Hr18_15, sum(mdm.Hr18_30 ) as Hr18_30, sum(mdm.Hr18_45 ) as Hr18_45, sum(mdm.Hr18_60 ) as Hr18_60,
				sum(mdm.Hr19_15 ) as Hr19_15, sum(mdm.Hr19_30 ) as Hr19_30, sum(mdm.Hr19_45 ) as Hr19_45, sum(mdm.Hr19_60 ) as Hr19_60,
				sum(mdm.Hr20_15 ) as Hr20_15, sum(mdm.Hr20_30 ) as Hr20_30, sum(mdm.Hr20_45 ) as Hr20_45, sum(mdm.Hr20_60 ) as Hr20_60,
				sum(mdm.Hr21_15 ) as Hr21_15, sum(mdm.Hr21_30 ) as Hr21_30, sum(mdm.Hr21_45 ) as Hr21_45, sum(mdm.Hr21_60 ) as Hr21_60,
				sum(mdm.Hr22_15 ) as Hr22_15, sum(mdm.Hr22_30 ) as Hr22_30, sum(mdm.Hr22_45 ) as Hr22_45, sum(mdm.Hr22_60 ) as Hr22_60,
				sum(mdm.Hr23_15 ) as Hr23_15, sum(mdm.Hr23_30 ) as Hr23_30, sum(mdm.Hr23_45 ) as Hr23_45, sum(mdm.Hr23_60 ) as Hr23_60,
				sum(mdm.Hr24_15 ) as Hr24_15, sum(mdm.Hr24_30 ) as Hr24_30, sum(mdm.Hr24_45 ) as Hr24_45, sum(mdm.Hr24_60 ) as Hr24_60
			FROM 
			mv90_data md
			INNER JOIN mv90_data_mins mdm ON md.meter_data_id = mdm.meter_data_id
			INNER JOIN recorder_generator_map rgm on rgm.meter_id = md.meter_id
			INNER JOIN rec_generator rg on rg.generator_id = rgm.generator_id and rg.ppa_counterparty_id = @counterparty_id
			and rg.ppa_contract_id = @contract_id
			
			--where dbo.fnagetcontractmonth(prod_date) = @maturity_date
				where md.channel = @channel AND
						((@billing_cycle = 990 AND prod_date between @maturity_date_from and @maturity_date_to)
								OR
						(@billing_cycle = 976 AND	
								CAST(Year(prod_date) As Varchar)  + '-' + CASE WHEN (MONTH(prod_date) < 10) then '0' else '' end + 
								(CAST(Month(prod_date) As Varchar)) = @maturity_month ))
			group by  mdm.prod_date
			)
		 p
		UNPIVOT
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
		) b
		on a.hr=substring(b.hr,0,charindex('_',b.hr))
		and a.week_day=DATEPART(dw, b.[prod_date]) 
		and b.prod_date not in
		(select ISNULL(hol_date,'')
		from contract_group cg  left outer join
		(select block_value_Id,	max(holiday_value_id) holiday_value_id from hourly_block group by block_value_Id) hb	
		on cg.hourly_block=hb.block_value_id left outer join
		holiday_group hg on hb.holiday_value_id=hg.hol_group_value_Id
		where cg.contract_id = @contract_id)

		--select @retValue
		
	END
	ELSE
		BEGIN
	
		select @retValue =  max((b.[Value])*@multiplyBy)  from 
		
		(SELECT meter_id,channel,prod_date, Hr, [Value]
		--SELECT max([Value]*4)
		FROM 


			(SELECT max(md.meter_id) meter_id, max(md.channel) channel, mdm.prod_date, 
				sum(mdm.Hr1_15 ) as Hr1_15, sum(mdm.Hr1_30 ) as Hr1_30, sum(mdm.Hr1_45 ) as Hr1_45, sum(mdm.Hr1_60 ) as Hr1_60,
				sum(mdm.Hr2_15 ) as Hr2_15, sum(mdm.Hr2_30 ) as Hr2_30, sum(mdm.Hr2_45 ) as Hr2_45, sum(mdm.Hr2_60 ) as Hr2_60,
				sum(mdm.Hr3_15 ) as Hr3_15, sum(mdm.Hr3_30 ) as Hr3_30, sum(mdm.Hr3_45 ) as Hr3_45, sum(mdm.Hr3_60 ) as Hr3_60,
				sum(mdm.Hr4_15 ) as Hr4_15, sum(mdm.Hr4_30 ) as Hr4_30, sum(mdm.Hr4_45 ) as Hr4_45, sum(mdm.Hr4_60 ) as Hr4_60,
				sum(mdm.Hr5_15 ) as Hr5_15, sum(mdm.Hr5_30 ) as Hr5_30, sum(mdm.Hr5_45 ) as Hr5_45, sum(mdm.Hr5_60 ) as Hr5_60,
				sum(mdm.Hr6_15 ) as Hr6_15, sum(mdm.Hr6_30 ) as Hr6_30, sum(mdm.Hr6_45 ) as Hr6_45, sum(mdm.Hr6_60 ) as Hr6_60,
				sum(mdm.Hr7_15 ) as Hr7_15, sum(mdm.Hr7_30 ) as Hr7_30, sum(mdm.Hr7_45 ) as Hr7_45, sum(mdm.Hr7_60 ) as Hr7_60,
				sum(mdm.Hr8_15 ) as Hr8_15, sum(mdm.Hr8_30 ) as Hr8_30, sum(mdm.Hr8_45 ) as Hr8_45, sum(mdm.Hr8_60 ) as Hr8_60,
				sum(mdm.Hr9_15 ) as Hr9_15, sum(mdm.Hr9_30 ) as Hr9_30, sum(mdm.Hr9_45 ) as Hr9_45, sum(mdm.Hr9_60 ) as Hr9_60,
				sum(mdm.Hr10_15 ) as Hr10_15, sum(mdm.Hr10_30 ) as Hr10_30, sum(mdm.Hr10_45 ) as Hr10_45, sum(mdm.Hr10_60 ) as Hr10_60,
				sum(mdm.Hr11_15 ) as Hr11_15, sum(mdm.Hr11_30 ) as Hr11_30, sum(mdm.Hr11_45 ) as Hr11_45, sum(mdm.Hr11_60 ) as Hr11_60,
				sum(mdm.Hr12_15 ) as Hr12_15, sum(mdm.Hr12_30 ) as Hr12_30, sum(mdm.Hr12_45 ) as Hr12_45, sum(mdm.Hr12_60 ) as Hr12_60,
				sum(mdm.Hr13_15 ) as Hr13_15, sum(mdm.Hr13_30 ) as Hr13_30, sum(mdm.Hr13_45 ) as Hr13_45, sum(mdm.Hr13_60 ) as Hr13_60,
				sum(mdm.Hr14_15 ) as Hr14_15, sum(mdm.Hr14_30 ) as Hr14_30, sum(mdm.Hr14_45 ) as Hr14_45, sum(mdm.Hr14_60 ) as Hr14_60,
				sum(mdm.Hr15_15 ) as Hr15_15, sum(mdm.Hr15_30 ) as Hr15_30, sum(mdm.Hr15_45 ) as Hr15_45, sum(mdm.Hr15_60 ) as Hr15_60,
				sum(mdm.Hr16_15 ) as Hr16_15, sum(mdm.Hr16_30 ) as Hr16_30, sum(mdm.Hr16_45 ) as Hr16_45, sum(mdm.Hr16_60 ) as Hr16_60,
				sum(mdm.Hr17_15 ) as Hr17_15, sum(mdm.Hr17_30 ) as Hr17_30, sum(mdm.Hr17_45 ) as Hr17_45, sum(mdm.Hr17_60 ) as Hr17_60,
				sum(mdm.Hr18_15 ) as Hr18_15, sum(mdm.Hr18_30 ) as Hr18_30, sum(mdm.Hr18_45 ) as Hr18_45, sum(mdm.Hr18_60 ) as Hr18_60,
				sum(mdm.Hr19_15 ) as Hr19_15, sum(mdm.Hr19_30 ) as Hr19_30, sum(mdm.Hr19_45 ) as Hr19_45, sum(mdm.Hr19_60 ) as Hr19_60,
				sum(mdm.Hr20_15 ) as Hr20_15, sum(mdm.Hr20_30 ) as Hr20_30, sum(mdm.Hr20_45 ) as Hr20_45, sum(mdm.Hr20_60 ) as Hr20_60,
				sum(mdm.Hr21_15 ) as Hr21_15, sum(mdm.Hr21_30 ) as Hr21_30, sum(mdm.Hr21_45 ) as Hr21_45, sum(mdm.Hr21_60 ) as Hr21_60,
				sum(mdm.Hr22_15 ) as Hr22_15, sum(mdm.Hr22_30 ) as Hr22_30, sum(mdm.Hr22_45 ) as Hr22_45, sum(mdm.Hr22_60 ) as Hr22_60,
				sum(mdm.Hr23_15 ) as Hr23_15, sum(mdm.Hr23_30 ) as Hr23_30, sum(mdm.Hr23_45 ) as Hr23_45, sum(mdm.Hr23_60 ) as Hr23_60,
				sum(mdm.Hr24_15 ) as Hr24_15, sum(mdm.Hr24_30 ) as Hr24_30, sum(mdm.Hr24_45 ) as Hr24_45, sum(mdm.Hr24_60 ) as Hr24_60
			FROM 
			mv90_data md
			INNER JOIN mv90_data_mins mdm ON md.meter_data_id = mdm.meter_data_id
			INNER JOIN recorder_generator_map rgm on rgm.meter_id = md.meter_id
			inner join rec_generator rg on rg.generator_id = rgm.generator_id and rg.ppa_counterparty_id = @counterparty_id
			and rg.ppa_contract_id = @contract_id
			where md.channel = @channel AND
						((@billing_cycle = 990 AND prod_date between @maturity_date_from and @maturity_date_to)
								OR
						(@billing_cycle = 976 AND	
								CAST(Year(prod_date) As Varchar)  + '-' + CASE WHEN (MONTH(prod_date) < 10) then '0' else '' end + 
								(CAST(Month(prod_date) As Varchar)) = @maturity_month ))
			group by  mdm.prod_date
			)
		 p
		UNPIVOT
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
		) b
		where
				b.prod_date not in
				(select ISNULL(hol_date,'')
				from contract_group cg  left outer join
				(select block_value_Id,	max(holiday_value_id) holiday_value_id from hourly_block group by block_value_Id) hb	
				on cg.hourly_block=hb.block_value_id left outer join
				holiday_group hg on hb.holiday_value_id=hg.hol_group_value_Id
				where cg.contract_id = @contract_id)


		END
  END	
return isnull(@retValue,0)
end







