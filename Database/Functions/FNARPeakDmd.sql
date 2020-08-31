IF OBJECT_ID(N'FNARPeakDmd', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNARPeakDmd]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARPeakDmd]
(
	@maturity_date    DATETIME,
	@counterparty_id  AS VARCHAR(50),
	@contract_id      AS VARCHAR(50),
	@proxy_date       DATETIME,
	@minFlag          AS INT
)
RETURNS FLOAT
AS
	 
BEGIN 
	
--declare @maturity_date datetime,  @counterparty_id int,@contract_id int,@minFlag int
--
--
--set @maturity_date='2007-07-01'
--
--set @counterparty_id=274
--set @contract_id=219
--set @minFlag=15
--
--

declare @maturity_date_from varchar(50)
declare @maturity_date_to varchar(50)
declare @retValue as float
declare @multiplyBy as int
declare @hourly_block as int
declare @billing_cycle as int
declare @billing_from_date as int
declare @billing_to_date as int
DECLARE @monthI Int
declare @where_condition varchar(500)
declare @maturity_month varchar(50)
declare @tempMonth as int

set @multiplyBy = 4


if NULLIF(@proxy_date,'') is not null
	set @maturity_date=@proxy_date

select @billing_cycle = billing_cycle from contract_group where contract_id = @contract_id 



if @billing_cycle = 990
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

	set @where_condition = ' prod_date between ''' + @maturity_date_from + ''' and ''' + @maturity_date_to + ''''
end
else
	set @maturity_month = CAST(Year(@maturity_date) As Varchar)  + '-' + 
					CASE WHEN (@monthI < 10) then '0' else '' end + 
						(CAST(Month(@maturity_date) As Varchar))


--print @where_condition

declare @sql_stmt varchar(5000)

select @hourly_block = hourly_block 
from contract_group where contract_id = @contract_id

	if @minFlag =15
	begin
		--
		--select a.*,b.* from 
		if @hourly_block is null
		begin
			
			select @retValue =  (max(b.[Value])*@multiplyBy)  from 
			--select prod_date,Hr,(b.[Value])*@multiplyBy  from 
			(
				SELECT meter_id,channel,prod_date, Hr, [Value]
				FROM 
					(
						SELECT max(md.meter_id) meter_id, max(md.channel) channel, mdm.prod_date, 
							sum(mdm.Hr1_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr1_15, sum(mdm.Hr1_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr1_30, sum(mdm.Hr1_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr1_45, sum(mdm.Hr1_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr1_60,
					sum(mdm.Hr2_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr2_15, sum(mdm.Hr2_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr2_30, sum(mdm.Hr2_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr2_45, sum(mdm.Hr2_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr2_60,
					sum(mdm.Hr3_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr3_15, sum(mdm.Hr3_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr3_30, sum(mdm.Hr3_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr3_45, sum(mdm.Hr3_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr3_60,
					sum(mdm.Hr4_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr4_15, sum(mdm.Hr4_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr4_30, sum(mdm.Hr4_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr4_45, sum(mdm.Hr4_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr4_60,
					sum(mdm.Hr5_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr5_15, sum(mdm.Hr5_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr5_30, sum(mdm.Hr5_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr5_45, sum(mdm.Hr5_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr5_60,
					sum(mdm.Hr6_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr6_15, sum(mdm.Hr6_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr6_30, sum(mdm.Hr6_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr6_45, sum(mdm.Hr6_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr6_60,
					sum(mdm.Hr7_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr7_15, sum(mdm.Hr7_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr7_30, sum(mdm.Hr7_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr7_45, sum(mdm.Hr7_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr7_60,
					sum(mdm.Hr8_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr8_15, sum(mdm.Hr8_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr8_30, sum(mdm.Hr8_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr8_45, sum(mdm.Hr8_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr8_60,
					sum(mdm.Hr9_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr9_15, sum(mdm.Hr9_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr9_30, sum(mdm.Hr9_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr9_45, sum(mdm.Hr9_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr9_60,
					sum(mdm.Hr10_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr10_15, sum(mdm.Hr10_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr10_30, sum(mdm.Hr10_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr10_45, sum(mdm.Hr10_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr10_60,
					sum(mdm.Hr11_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr11_15, sum(mdm.Hr11_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr11_30, sum(mdm.Hr11_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr11_45, sum(mdm.Hr11_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr11_60,
					sum(mdm.Hr12_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr12_15, sum(mdm.Hr12_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr12_30, sum(mdm.Hr12_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr12_45, sum(mdm.Hr12_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr12_60,
					sum(mdm.Hr13_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr13_15, sum(mdm.Hr13_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr13_30, sum(mdm.Hr13_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr13_45, sum(mdm.Hr13_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr13_60,
					sum(mdm.Hr14_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr14_15, sum(mdm.Hr14_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr14_30, sum(mdm.Hr14_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr14_45, sum(mdm.Hr14_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr14_60,
					sum(mdm.Hr15_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr15_15, sum(mdm.Hr15_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr15_30, sum(mdm.Hr15_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr15_45, sum(mdm.Hr15_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr15_60,
					sum(mdm.Hr16_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr16_15, sum(mdm.Hr16_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr16_30, sum(mdm.Hr16_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr16_45, sum(mdm.Hr16_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr16_60,
					sum(mdm.Hr17_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr17_15, sum(mdm.Hr17_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr17_30, sum(mdm.Hr17_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr17_45, sum(mdm.Hr17_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr17_60,
					sum(mdm.Hr18_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr18_15, sum(mdm.Hr18_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr18_30, sum(mdm.Hr18_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr18_45, sum(mdm.Hr18_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr18_60,
					sum(mdm.Hr19_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr19_15, sum(mdm.Hr19_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr19_30, sum(mdm.Hr19_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr19_45, sum(mdm.Hr19_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr19_60,
					sum(mdm.Hr20_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr20_15, sum(mdm.Hr20_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr20_30, sum(mdm.Hr20_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr20_45, sum(mdm.Hr20_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr20_60,
					sum(mdm.Hr21_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr21_15, sum(mdm.Hr21_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr21_30, sum(mdm.Hr21_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr21_45, sum(mdm.Hr21_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr21_60,
					sum(mdm.Hr22_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr22_15, sum(mdm.Hr22_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr22_30, sum(mdm.Hr22_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr22_45, sum(mdm.Hr22_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr22_60,
					sum(mdm.Hr23_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr23_15, sum(mdm.Hr23_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr23_30, sum(mdm.Hr23_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr23_45, sum(mdm.Hr23_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr23_60,
					sum(mdm.Hr24_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr24_15, sum(mdm.Hr24_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr24_30, sum(mdm.Hr24_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr24_45, sum(mdm.Hr24_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr24_60
						FROM mv90_data md
						INNER JOIN mv90_data_mins mdm ON md.meter_data_id = mdm.meter_data_id
						INNER JOIN recorder_properties rp ON rp.meter_id = md.meter_id AND rp.channel = md.channel
						inner join recorder_generator_map rgm on rgm.meter_id = rp.meter_id
						inner join rec_generator rg on rg.generator_id = rgm.generator_id and rg.ppa_counterparty_id = @counterparty_id
						and rg.ppa_contract_id = @contract_id 
						where 
						((@billing_cycle = 990 AND prod_date between @maturity_date_from and @maturity_date_to)
								OR
						(@billing_cycle = 976 AND	
								CAST(Year(prod_date) As Varchar)  + '-' + CASE WHEN (prod_date < 10) then '0' else '' end + 
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

		
		end

		else 
		begin





			select @retValue =  max((b.[Value]*a.flag)*@multiplyBy)  from 
			--select ((b.[Value]*a.flag)*@multiplyBy)  from 
			(
			select  Hr, flag,week_day
			from
				( select hb.block_value_id, hb.week_day, hb.onpeak_offpeak,
						hb.Hr1, hb.Hr2, hb.Hr3, hb.Hr4, hb.Hr5, hb.Hr6, hb.Hr7, hb.Hr8, hb.Hr9, hb.Hr10, hb.Hr11, hb.Hr12, 
						hb.Hr13, hb.Hr14, hb.Hr15, hb.Hr16, hb.Hr17, hb.Hr18, hb.Hr19, hb.Hr20, hb.Hr21,hb.Hr22, hb.Hr23, hb.Hr24
					from hourly_block hb
					
					where hb.block_value_id = @hourly_block and hb.onpeak_offpeak = 'p'
					
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
					sum(mdm.Hr1_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr1_15, sum(mdm.Hr1_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr1_30, sum(mdm.Hr1_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr1_45, sum(mdm.Hr1_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr1_60,
					sum(mdm.Hr2_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr2_15, sum(mdm.Hr2_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr2_30, sum(mdm.Hr2_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr2_45, sum(mdm.Hr2_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr2_60,
					sum(mdm.Hr3_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr3_15, sum(mdm.Hr3_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr3_30, sum(mdm.Hr3_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr3_45, sum(mdm.Hr3_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr3_60,
					sum(mdm.Hr4_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr4_15, sum(mdm.Hr4_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr4_30, sum(mdm.Hr4_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr4_45, sum(mdm.Hr4_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr4_60,
					sum(mdm.Hr5_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr5_15, sum(mdm.Hr5_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr5_30, sum(mdm.Hr5_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr5_45, sum(mdm.Hr5_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr5_60,
					sum(mdm.Hr6_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr6_15, sum(mdm.Hr6_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr6_30, sum(mdm.Hr6_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr6_45, sum(mdm.Hr6_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr6_60,
					sum(mdm.Hr7_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr7_15, sum(mdm.Hr7_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr7_30, sum(mdm.Hr7_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr7_45, sum(mdm.Hr7_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr7_60,
					sum(mdm.Hr8_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr8_15, sum(mdm.Hr8_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr8_30, sum(mdm.Hr8_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr8_45, sum(mdm.Hr8_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr8_60,
					sum(mdm.Hr9_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr9_15, sum(mdm.Hr9_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr9_30, sum(mdm.Hr9_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr9_45, sum(mdm.Hr9_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr9_60,
					sum(mdm.Hr10_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr10_15, sum(mdm.Hr10_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr10_30, sum(mdm.Hr10_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr10_45, sum(mdm.Hr10_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr10_60,
					sum(mdm.Hr11_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr11_15, sum(mdm.Hr11_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr11_30, sum(mdm.Hr11_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr11_45, sum(mdm.Hr11_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr11_60,
					sum(mdm.Hr12_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr12_15, sum(mdm.Hr12_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr12_30, sum(mdm.Hr12_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr12_45, sum(mdm.Hr12_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr12_60,
					sum(mdm.Hr13_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr13_15, sum(mdm.Hr13_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr13_30, sum(mdm.Hr13_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr13_45, sum(mdm.Hr13_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr13_60,
					sum(mdm.Hr14_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr14_15, sum(mdm.Hr14_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr14_30, sum(mdm.Hr14_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr14_45, sum(mdm.Hr14_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr14_60,
					sum(mdm.Hr15_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr15_15, sum(mdm.Hr15_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr15_30, sum(mdm.Hr15_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr15_45, sum(mdm.Hr15_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr15_60,
					sum(mdm.Hr16_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr16_15, sum(mdm.Hr16_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr16_30, sum(mdm.Hr16_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr16_45, sum(mdm.Hr16_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr16_60,
					sum(mdm.Hr17_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr17_15, sum(mdm.Hr17_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr17_30, sum(mdm.Hr17_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr17_45, sum(mdm.Hr17_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr17_60,
					sum(mdm.Hr18_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr18_15, sum(mdm.Hr18_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr18_30, sum(mdm.Hr18_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr18_45, sum(mdm.Hr18_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr18_60,
					sum(mdm.Hr19_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr19_15, sum(mdm.Hr19_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr19_30, sum(mdm.Hr19_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr19_45, sum(mdm.Hr19_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr19_60,
					sum(mdm.Hr20_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr20_15, sum(mdm.Hr20_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr20_30, sum(mdm.Hr20_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr20_45, sum(mdm.Hr20_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr20_60,
					sum(mdm.Hr21_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr21_15, sum(mdm.Hr21_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr21_30, sum(mdm.Hr21_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr21_45, sum(mdm.Hr21_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr21_60,
					sum(mdm.Hr22_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr22_15, sum(mdm.Hr22_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr22_30, sum(mdm.Hr22_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr22_45, sum(mdm.Hr22_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr22_60,
					sum(mdm.Hr23_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr23_15, sum(mdm.Hr23_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr23_30, sum(mdm.Hr23_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr23_45, sum(mdm.Hr23_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr23_60,
					sum(mdm.Hr24_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr24_15, sum(mdm.Hr24_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr24_30, sum(mdm.Hr24_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr24_45, sum(mdm.Hr24_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) as Hr24_60
				FROM mv90_data md
				INNER JOIN mv90_data_mins mdm ON md.meter_data_id = mdm.meter_data_id
				INNER JOIN recorder_properties rp ON rp.meter_id = md.meter_id AND rp.channel = md.channel
				inner join recorder_generator_map rgm on rgm.meter_id = rp.meter_id
				inner join rec_generator rg on rg.generator_id = rgm.generator_id and rg.ppa_counterparty_id = @counterparty_id
				and rg.ppa_contract_id = @contract_id 
				where 
				((@billing_cycle = 990 AND prod_date between @maturity_date_from and @maturity_date_to)
						OR
				(@billing_cycle = 976 AND	
						CAST(Year(prod_date) As Varchar)  + '-' + CASE WHEN (prod_date < 10) then '0' else '' end + 
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
	end

	else if @minFlag = 60
	begin

		if @hourly_block is null
		begin
			select @retValue =  (max(b.[Value])*@multiplyBy)  from 
			(SELECT meter_id,channel,prod_date, Hr, [Value]
			--SELECT max([Value]*4)
			FROM 


				(SELECT max(md.meter_id) meter_id, max(md.channel) channel, mdm.prod_date, 
					(sum(mdm.Hr1_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr1_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr1_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr1_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr1,
					(sum(mdm.Hr2_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr2_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr2_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr2_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr2,
					(sum(mdm.Hr3_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr3_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr3_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr3_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr3,
					(sum(mdm.Hr4_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr4_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr4_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr4_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr4,
					(sum(mdm.Hr5_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr5_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr5_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr5_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr5,
					(sum(mdm.Hr6_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr6_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr6_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr6_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr6,
					(sum(mdm.Hr7_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr7_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr7_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr7_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr7,
					(sum(mdm.Hr8_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr8_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr8_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr8_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr8,
					(sum(mdm.Hr9_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr9_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr9_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr9_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr9,
					(sum(mdm.Hr10_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr10_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr10_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr10_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr10,
					(sum(mdm.Hr11_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr11_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr11_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr11_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr11,
					(sum(mdm.Hr12_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr12_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr12_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr12_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr12,
					(sum(mdm.Hr13_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr13_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr13_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr13_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr13,
					(sum(mdm.Hr14_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr14_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr14_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr14_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr14,
					(sum(mdm.Hr15_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr15_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr15_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr15_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr15,
					(sum(mdm.Hr16_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr16_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr16_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr16_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr16,
					(sum(mdm.Hr17_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr17_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr17_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr17_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr17,
					(sum(mdm.Hr18_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr18_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr18_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr18_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr18,
					(sum(mdm.Hr19_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr19_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr19_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr19_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr19,
					(sum(mdm.Hr20_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr20_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr20_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr20_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr20,
					(sum(mdm.Hr21_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr21_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr21_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr21_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr21,
					(sum(mdm.Hr22_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr22_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr22_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr22_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr22,
					(sum(mdm.Hr23_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr23_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr23_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr23_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr23,
					(sum(mdm.Hr24_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr24_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr24_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr24_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr24
				FROM  mv90_data md
				INNER JOIN mv90_data_mins mdm ON md.meter_data_id = mdm.meter_data_id
				INNER JOIN recorder_properties rp ON rp.meter_id = md.meter_id AND rp.channel = md.channel
				inner join recorder_generator_map rgm on rgm.meter_id = rp.meter_id
				inner join rec_generator rg on rg.generator_id = rgm.generator_id and rg.ppa_counterparty_id = @counterparty_id
				and rg.ppa_contract_id = @contract_id 
				where 
				((@billing_cycle = 990 AND prod_date between @maturity_date_from and @maturity_date_to)
						OR
				(@billing_cycle = 976 AND	
						CAST(Year(prod_date) As Varchar)  + '-' + CASE WHEN (prod_date < 10) then '0' else '' end + 
						(CAST(Month(prod_date) As Varchar)) = @maturity_month ))

			group by  mdm.prod_date
				)
		
			 p
				UNPIVOT
					([Value] FOR Hr IN 
						(
							Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13, Hr14, Hr15, Hr16, Hr17, Hr18,
						Hr19, Hr20, Hr21, Hr22, Hr23, Hr24
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
		end
		else
		begin
	
			--select @retValue =  max((b.[Value]*a.flag)*@multiplyBy)  from 
			select @retValue =  max((b.[Value]*a.flag)*@multiplyBy) from 
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
					(sum(mdm.Hr1_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr1_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr1_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr1_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr1,
					(sum(mdm.Hr2_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr2_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr2_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr2_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr2,
					(sum(mdm.Hr3_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr3_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr3_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr3_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr3,
					(sum(mdm.Hr4_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr4_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr4_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr4_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr4,
					(sum(mdm.Hr5_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr5_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr5_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr5_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr5,
					(sum(mdm.Hr6_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr6_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr6_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr6_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr6,
					(sum(mdm.Hr7_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr7_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr7_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr7_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr7,
					(sum(mdm.Hr8_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr8_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr8_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr8_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr8,
					(sum(mdm.Hr9_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr9_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr9_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr9_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr9,
					(sum(mdm.Hr10_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr10_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr10_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr10_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr10,
					(sum(mdm.Hr11_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr11_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr11_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr11_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr11,
					(sum(mdm.Hr12_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr12_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr12_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr12_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr12,
					(sum(mdm.Hr13_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr13_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr13_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr13_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr13,
					(sum(mdm.Hr14_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr14_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr14_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr14_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr14,
					(sum(mdm.Hr15_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr15_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr15_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr15_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr15,
					(sum(mdm.Hr16_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr16_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr16_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr16_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr16,
					(sum(mdm.Hr17_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr17_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr17_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr17_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr17,
					(sum(mdm.Hr18_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr18_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr18_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr18_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr18,
					(sum(mdm.Hr19_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr19_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr19_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr19_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr19,
					(sum(mdm.Hr20_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr20_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr20_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr20_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr20,
					(sum(mdm.Hr21_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr21_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr21_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr21_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr21,
					(sum(mdm.Hr22_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr22_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr22_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr22_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr22,
					(sum(mdm.Hr23_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr23_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr23_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr23_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr23,
					(sum(mdm.Hr24_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr24_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr24_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr24_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/4 as Hr24
				FROM mv90_data md
				INNER JOIN mv90_data_mins mdm ON md.meter_data_id = mdm.meter_data_id
				INNER JOIN recorder_properties rp ON rp.meter_id = md.meter_id AND rp.channel = md.channel
				inner join recorder_generator_map rgm on rgm.meter_id = rp.meter_id
				inner join rec_generator rg on rg.generator_id = rgm.generator_id and rg.ppa_counterparty_id = @counterparty_id
				and rg.ppa_contract_id = @contract_id 
				where 
				((@billing_cycle = 990 AND prod_date between @maturity_date_from and @maturity_date_to)
						OR
				(@billing_cycle = 976 AND	
						CAST(Year(prod_date) As Varchar)  + '-' + CASE WHEN (prod_date < 10) then '0' else '' end + 
						(CAST(Month(prod_date) As Varchar)) = @maturity_month ))

			group by  mdm.prod_date
				)
		
			 p
			UNPIVOT
				([Value] FOR Hr IN 
					(
						Hr1, Hr2, Hr3, Hr4,
						Hr5, Hr6, Hr7, Hr8,
						Hr9, Hr10, Hr11, Hr12,
						Hr13, Hr14,	Hr15, Hr16,
						Hr17, Hr18,	Hr19, Hr20,
						Hr21, Hr22,	Hr23, Hr24
					)
			)AS unpvt 
			) b
	--		on a.hr=substring(b.Hr,charindex('r',b.Hr)+1,len(b.Hr))
			on a.hr=b.Hr
			and a.week_day=DATEPART(dw, b.[prod_date]) 
			and b.prod_date not in
			(select ISNULL(hol_date,'')
			from contract_group cg  left outer join
			(select block_value_Id,	max(holiday_value_id) holiday_value_id from hourly_block group by block_value_Id) hb	
			on cg.hourly_block=hb.block_value_id left outer join
			holiday_group hg on hb.holiday_value_id=hg.hol_group_value_Id
			where cg.contract_id = @contract_id)
		end
	end

	else if @minFlag = 30
	begin
		if @hourly_block is null
		begin
			select @retValue =  (max(b.[Value])*@multiplyBy)  from 
			(SELECT meter_id,channel,prod_date, Hr, [Value]
			--SELECT max([Value]*4)
			FROM 


				(SELECT max(md.meter_id) meter_id, max(md.channel) channel, mdm.prod_date, 
					(sum(mdm.Hr1_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end))  + sum(mdm.Hr1_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr1_30, (sum(mdm.Hr1_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr1_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr1_60,
					(sum(mdm.Hr2_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr2_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr2_30, (sum(mdm.Hr2_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr2_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr2_60,
					(sum(mdm.Hr3_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr3_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr3_30, (sum(mdm.Hr3_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr3_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr3_60,
					(sum(mdm.Hr4_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr4_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr4_30, (sum(mdm.Hr4_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr4_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr4_60,
					(sum(mdm.Hr5_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr5_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr5_30, (sum(mdm.Hr5_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr5_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr5_60,
					(sum(mdm.Hr6_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr6_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr6_30, (sum(mdm.Hr6_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr6_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr6_60,
					(sum(mdm.Hr7_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr7_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr7_30, (sum(mdm.Hr7_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr7_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr7_60,
					(sum(mdm.Hr8_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr8_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr8_30, (sum(mdm.Hr8_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr8_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr8_60,
					(sum(mdm.Hr9_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr9_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr9_30, (sum(mdm.Hr9_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr9_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr9_60,
					(sum(mdm.Hr10_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr10_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr10_30, (sum(mdm.Hr10_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr10_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr10_60,
					(sum(mdm.Hr11_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr11_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr11_30, (sum(mdm.Hr11_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr11_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr11_60,
					(sum(mdm.Hr12_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr12_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr12_30, (sum(mdm.Hr12_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr12_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr12_60,
					(sum(mdm.Hr13_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr13_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr13_30, (sum(mdm.Hr13_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr13_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr13_60,
					(sum(mdm.Hr14_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr14_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr14_30, (sum(mdm.Hr14_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr14_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr14_60,
					(sum(mdm.Hr15_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr15_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr15_30, (sum(mdm.Hr15_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr15_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr15_60,
					(sum(mdm.Hr16_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr16_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr16_30, (sum(mdm.Hr16_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr16_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr16_60,
					(sum(mdm.Hr17_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr17_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr17_30, (sum(mdm.Hr17_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr17_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr17_60,
					(sum(mdm.Hr18_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr18_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr18_30, (sum(mdm.Hr18_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr18_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr18_60,
					(sum(mdm.Hr19_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr19_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr19_30, (sum(mdm.Hr19_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr19_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr19_60,
					(sum(mdm.Hr20_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr20_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr20_30, (sum(mdm.Hr20_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr20_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr20_60,
					(sum(mdm.Hr21_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr21_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr21_30, (sum(mdm.Hr21_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr21_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr21_60,
					(sum(mdm.Hr22_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr22_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr22_30, (sum(mdm.Hr22_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr22_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr22_60,
					(sum(mdm.Hr23_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr23_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr23_30, (sum(mdm.Hr23_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr23_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr23_60,
					(sum(mdm.Hr24_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr24_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr24_30, (sum(mdm.Hr24_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr24_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr24_60
				FROM mv90_data md
				INNER JOIN mv90_data_mins mdm ON md.meter_data_id = mdm.meter_data_id
				INNER JOIN recorder_properties rp ON rp.meter_id = md.meter_id AND rp.channel = md.channel
				inner join recorder_generator_map rgm on rgm.meter_id = rp.meter_id
				inner join rec_generator rg on rg.generator_id = rgm.generator_id and rg.ppa_counterparty_id = @counterparty_id
				and rg.ppa_contract_id = @contract_id
				
				where 
				--prod_date between @maturity_date_from and @maturity_date_to
				((@billing_cycle = 990 AND prod_date between @maturity_date_from and @maturity_date_to)
						OR
				(@billing_cycle = 976 AND	
						CAST(Year(prod_date) As Varchar)  + '-' + CASE WHEN (prod_date < 10) then '0' else '' end + 
						(CAST(Month(prod_date) As Varchar)) = @maturity_month ))
				group by  mdm.prod_date
				)
			 p
				UNPIVOT
					([Value] FOR Hr IN 
						(
							Hr1_30, Hr1_60,
						Hr2_30, Hr2_60,
						Hr3_30, Hr3_60,
						Hr4_30, Hr4_60,
						Hr5_30, Hr5_60,
						Hr6_30, Hr6_60,
						Hr7_30, Hr7_60,
						Hr8_30, Hr8_60,
						Hr9_30, Hr9_60,
						Hr10_30, Hr10_60,
						Hr11_30, Hr11_60,
						Hr12_30, Hr12_60,
						Hr13_30, Hr13_60,
						Hr14_30, Hr14_60,
						Hr15_30, Hr15_60,
						Hr16_30, Hr16_60,
						Hr17_30, Hr17_60,
						Hr18_30, Hr18_60,
						Hr19_30, Hr19_60,
						Hr20_30, Hr20_60,
						Hr21_30, Hr21_60,
						Hr22_30, Hr22_60,
						Hr23_30, Hr23_60,
						Hr24_30, Hr24_60
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
		end
		else
		begin
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
					(sum(mdm.Hr1_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end))  + sum(mdm.Hr1_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr1_30, (sum(mdm.Hr1_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr1_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr1_60,
					(sum(mdm.Hr2_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr2_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr2_30, (sum(mdm.Hr2_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr2_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr2_60,
					(sum(mdm.Hr3_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr3_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr3_30, (sum(mdm.Hr3_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr3_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr3_60,
					(sum(mdm.Hr4_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr4_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr4_30, (sum(mdm.Hr4_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr4_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr4_60,
					(sum(mdm.Hr5_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr5_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr5_30, (sum(mdm.Hr5_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr5_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr5_60,
					(sum(mdm.Hr6_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr6_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr6_30, (sum(mdm.Hr6_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr6_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr6_60,
					(sum(mdm.Hr7_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr7_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr7_30, (sum(mdm.Hr7_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr7_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr7_60,
					(sum(mdm.Hr8_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr8_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr8_30, (sum(mdm.Hr8_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr8_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr8_60,
					(sum(mdm.Hr9_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr9_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr9_30, (sum(mdm.Hr9_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr9_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr9_60,
					(sum(mdm.Hr10_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr10_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr10_30, (sum(mdm.Hr10_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr10_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr10_60,
					(sum(mdm.Hr11_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr11_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr11_30, (sum(mdm.Hr11_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr11_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr11_60,
					(sum(mdm.Hr12_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr12_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr12_30, (sum(mdm.Hr12_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr12_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr12_60,
					(sum(mdm.Hr13_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr13_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr13_30, (sum(mdm.Hr13_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr13_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr13_60,
					(sum(mdm.Hr14_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr14_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr14_30, (sum(mdm.Hr14_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr14_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr14_60,
					(sum(mdm.Hr15_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr15_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr15_30, (sum(mdm.Hr15_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr15_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr15_60,
					(sum(mdm.Hr16_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr16_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr16_30, (sum(mdm.Hr16_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr16_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr16_60,
					(sum(mdm.Hr17_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr17_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr17_30, (sum(mdm.Hr17_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr17_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr17_60,
					(sum(mdm.Hr18_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr18_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr18_30, (sum(mdm.Hr18_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr18_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr18_60,
					(sum(mdm.Hr19_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr19_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr19_30, (sum(mdm.Hr19_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr19_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr19_60,
					(sum(mdm.Hr20_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr20_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr20_30, (sum(mdm.Hr20_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr20_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr20_60,
					(sum(mdm.Hr21_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr21_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr21_30, (sum(mdm.Hr21_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr21_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr21_60,
					(sum(mdm.Hr22_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr22_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr22_30, (sum(mdm.Hr22_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr22_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr22_60,
					(sum(mdm.Hr23_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr23_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr23_30, (sum(mdm.Hr23_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr23_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr23_60,
					(sum(mdm.Hr24_15*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr24_30*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr24_30, (sum(mdm.Hr24_45*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)) + sum(mdm.Hr24_60*(case when rp.mult_factor<0 then -1 else rp.mult_factor end)))/2 as Hr24_60
				FROM mv90_data md
				INNER JOIN mv90_data_mins mdm ON md.meter_data_id = mdm.meter_data_id
				INNER JOIN recorder_properties rp ON rp.meter_id = md.meter_id AND rp.channel = md.channel
				inner join recorder_generator_map rgm on rgm.meter_id = rp.meter_id
				inner join rec_generator rg on rg.generator_id = rgm.generator_id and rg.ppa_counterparty_id = @counterparty_id
				and rg.ppa_contract_id = @contract_id
				
				where 
				--prod_date between @maturity_date_from and @maturity_date_to
				((@billing_cycle = 990 AND prod_date between @maturity_date_from and @maturity_date_to)
						OR
				(@billing_cycle = 976 AND	
						CAST(Year(prod_date) As Varchar)  + '-' + CASE WHEN (prod_date < 10) then '0' else '' end + 
						(CAST(Month(prod_date) As Varchar)) = @maturity_month ))
				group by  mdm.prod_date
				)
			 p
			UNPIVOT
				([Value] FOR Hr IN 
					(
						Hr1_30, Hr1_60,
						Hr2_30, Hr2_60,
						Hr3_30, Hr3_60,
						Hr4_30, Hr4_60,
						Hr5_30, Hr5_60,
						Hr6_30, Hr6_60,
						Hr7_30, Hr7_60,
						Hr8_30, Hr8_60,
						Hr9_30, Hr9_60,
						Hr10_30, Hr10_60,
						Hr11_30, Hr11_60,
						Hr12_30, Hr12_60,
						Hr13_30, Hr13_60,
						Hr14_30, Hr14_60,
						Hr15_30, Hr15_60,
						Hr16_30, Hr16_60,
						Hr17_30, Hr17_60,
						Hr18_30, Hr18_60,
						Hr19_30, Hr19_60,
						Hr20_30, Hr20_60,
						Hr21_30, Hr21_60,
						Hr22_30, Hr22_60,
						Hr23_30, Hr23_60,
						Hr24_30, Hr24_60
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
		end


	END
return isnull(@retValue,0)
end




















