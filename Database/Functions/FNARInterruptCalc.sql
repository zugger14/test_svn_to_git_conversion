/****** Object:  UserDefinedFunction [dbo].[FNARInterruptCalc]    Script Date: 05/02/2011 11:10:33 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARInterruptCalc]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARInterruptCalc]
GO
/****** Object:  UserDefinedFunction [dbo].[FNARInterruptCalc]    Script Date: 05/02/2011 11:10:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



----
----
------ select dbo.[FNARInterruptCalc]('2007-07-31',316,255,15,1)
----
----
CREATE FUNCTION [dbo].[FNARInterruptCalc] (
	@maturity_date datetime,
	@counterparty_id as varchar(50),
	@contract_id as varchar(50),
	@minFlag as int,
	@daily as int		-- 1 for daily , 0 for monthly
	)
RETURNS float AS  
BEGIN 

--declare @maturity_date datetime,@counterparty_id int,@contract_id int,@minFlag int, @interruptFlag int, @daily char(1)
--
--set @maturity_date='2007-09-01'
--set @counterparty_id=284
--set @contract_id=241
--set @minFlag=15
--set @interruptFlag=1
--set @daily = 0	-- 1 for daily , 0 for monthly


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
declare @interruptVol float




if @minFlag = 15
begin
	set @multiplyBy = 4
end
else if @minFlag = 30
begin
	set @multiplyBy = 2
end
else if @minFlag = 60
begin
	set @multiplyBy = 1
end


select @billing_cycle = billing_cycle from contract_group where contract_id = @contract_id 

if @billing_cycle = 990
begin
	select @billing_from_date = billing_from_date from contract_group where contract_id = @contract_id
	select @billing_to_date = billing_to_date from contract_group where contract_id = @contract_id

	

	SET @monthI = MONTH(@maturity_date)
	
	set @maturity_date_from = CAST(Year(@maturity_date) As Varchar)  + '-' + 
					CASE WHEN (@monthI < 10) then '0' else '' end + 
						(CAST(case when @monthI=1 then 12 else  @monthI - 1 end As Varchar)) + '-' + CAST(@billing_from_date as varchar)
	
	

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
	


if @minFlag = 60
begin

	select @interruptVol = avg(Val) from
	(
	select contract_id,prod_date,max([Value]) as Val
		from
		(select contract_id, mv.meter_id,ida.prod_date,hr_begin_proxy,hr_end_proxy,
			Hr1, Hr2, Hr3, Hr4,
			Hr5, Hr6, Hr7, Hr8,
			Hr9, Hr10, Hr11, Hr12,
			Hr13, Hr14, Hr15, Hr16,
			Hr17, Hr18, Hr19, Hr20,
			Hr21, Hr22, Hr23, Hr24

		from interrupt_data ida
		inner join rec_generator rg on rg.ppa_contract_id = ida.contract_id
		inner join recorder_generator_map rgm on rgm.generator_id = rg.generator_id
		inner join recorder_properties rp on rp.meter_id = rgm.meter_id
		inner join mv90_data mv ON mv.meter_id = rgm.meter_id and mv.channel = rp.channel
		inner join mv90_data_hour mdh on mdh.meter_data_id=mv.meter_data_id 
		and mdh.prod_date = ida.prod_date
		where ida.contract_id = @contract_id
		) p
		
		unpivot 
		([Value] FOR Hr IN 
				(
					Hr1, Hr2, Hr3, Hr4,
					Hr5, Hr6, Hr7, Hr8,
					Hr9, Hr10, Hr11, Hr12,
					Hr13, Hr14, Hr15, Hr16,
					Hr17, Hr18, Hr19, Hr20,
					Hr21, Hr22, Hr23, Hr24
				)
		)AS unpvt 
		where
		substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,len(unpvt.Hr)-charindex('r',unpvt.Hr))
		>= hr_begin_proxy and
		substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,len(unpvt.Hr)-charindex('r',unpvt.Hr))
		<= hr_end_proxy 
		group by contract_id,prod_date, Hr
	) a
	group by contract_id
end

else if @minFlag = 15
begin

	select @interruptVol = avg(Val+clq_demand) from
------	--select (Val)*4, Hr from
	(
	select contract_id,prod_date,max([Value])*4 as Val,isnull(max(clq_demand),0) as clq_demand
	FROM
	(SELECT
		max(contract_id) contract_id,ida.prod_date,max(ida.clq_demand) clq_demand,
		max(hr_begin)hr_begin ,max(hr_begin_proxy2) hr_begin_proxy2,max(min_begin_proxy2) min_begin_proxy2,max(hr_end)hr_end,
		max(hr_end_proxy2)hr_end_proxy2,max(min_end_proxy2)min_end_proxy2,
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
		from interrupt_data ida
		inner join rec_generator rg on rg.ppa_contract_id = ida.contract_id and ida.contract_id = @contract_id
		inner join recorder_generator_map rgm on rgm.generator_id = rg.generator_id
		inner join recorder_properties rp on rp.meter_id = rgm.meter_id
		inner join mv90_data mv ON mv.meter_id = rgm.meter_id and mv.channel = rp.channel
		inner join mv90_data_mins mdm on mdm.meter_data_id=mv.meter_data_id 
		and mdm.prod_date = ida.prod_date 
		where		
		ida.contract_id = @contract_id --and ida.prod_date between @maturity_date_from and @maturity_date_to
		and
			(
			 @daily = 0 and 
			 
				((@billing_cycle = 990 AND ida.prod_date between @maturity_date_from and @maturity_date_to)
						OR
				(@billing_cycle = 976 AND	
						CAST(Year(ida.prod_date) As Varchar)  + '-' + CASE WHEN (ida.prod_date < 10) then '0' else '' end + 
						(CAST(Month(ida.prod_date) As Varchar)) = @maturity_month ))
			)
			or
			(@daily = 1 and ida.prod_date = @maturity_date)

			group by  ida.prod_date
		) p
		--select * from mv90_data_mins

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
		where 
		(
			@daily = 0 and 
			(
				cast(substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,(charindex('_',unpvt.Hr)-(charindex('r',unpvt.Hr))-1)) as int) 
				>= hr_begin_proxy2 and
				cast(substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,(charindex('_',unpvt.Hr)-(charindex('r',unpvt.Hr))-1)) as int) 
				<= hr_end_proxy2 
				and
				(
					(
						cast(substring(unpvt.Hr,charindex('_',unpvt.Hr)+1,(len(unpvt.Hr)-(charindex('_',unpvt.Hr))+1)) as int) >=
							case 
								when cast(substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,(charindex('_',unpvt.Hr)-(charindex('r',unpvt.Hr))-1)) as int) 
								= hr_begin_proxy2 then min_begin_proxy2 end
						
					)
				
						OR
					(
						cast(substring(unpvt.Hr,charindex('_',unpvt.Hr)+1,(len(unpvt.Hr)-(charindex('_',unpvt.Hr))+1)) as int) <
							case 
								when cast(substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,(charindex('_',unpvt.Hr)-(charindex('r',unpvt.Hr))-1)) as int) 
								= hr_end_proxy2 then min_end_proxy2 end
						
					)
						OR
					(
						cast(substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,(charindex('_',unpvt.Hr)-(charindex('r',unpvt.Hr))-1)) as int) 
								> hr_begin_proxy2
						AND
					cast(substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,(charindex('_',unpvt.Hr)-(charindex('r',unpvt.Hr))-1)) as int) 
								<= hr_end_proxy2
					)
				)
			)
		)
		or
		(
			@daily = 1 and hr_begin is not null and hr_end is not null and 
			(
				cast(substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,(charindex('_',unpvt.Hr)-(charindex('r',unpvt.Hr))-1)) as int) 
				>= hr_begin_proxy2 and
				cast(substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,(charindex('_',unpvt.Hr)-(charindex('r',unpvt.Hr))-1)) as int) 
				<= hr_end_proxy2 
				and
				(
					(
						cast(substring(unpvt.Hr,charindex('_',unpvt.Hr)+1,(len(unpvt.Hr)-(charindex('_',unpvt.Hr))+1)) as int) >=
							case 
								when cast(substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,(charindex('_',unpvt.Hr)-(charindex('r',unpvt.Hr))-1)) as int) 
								= hr_begin_proxy2 then min_begin_proxy2 end
						
					)
				
						OR
					(
						cast(substring(unpvt.Hr,charindex('_',unpvt.Hr)+1,(len(unpvt.Hr)-(charindex('_',unpvt.Hr))+1)) as int) <
							case 
								when cast(substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,(charindex('_',unpvt.Hr)-(charindex('r',unpvt.Hr))-1)) as int) 
								= hr_end_proxy2 then min_end_proxy2 end
						
					)
						OR
					(
						cast(substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,(charindex('_',unpvt.Hr)-(charindex('r',unpvt.Hr))-1)) as int) 
								> hr_begin_proxy2
						AND
					cast(substring(unpvt.Hr,charindex('r',unpvt.Hr)+1,(charindex('_',unpvt.Hr)-(charindex('r',unpvt.Hr))-1)) as int) 
								<= hr_end_proxy2
					)
				)
			)
		)
		or
		(
			@daily = 1 and hr_begin is null and 1=1
			
		)
		--group by contract_id,prod_date,[Value],Hr
		group by contract_id,prod_date
--order by prod_date, Hr
	) a
	group by contract_id
end
--print(@interruptVol)
if @interruptVol is null
	set @interruptVol=0


return @interruptVol
end















