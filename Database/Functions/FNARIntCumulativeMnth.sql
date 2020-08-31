/****** Object:  UserDefinedFunction [dbo].[FNARIntCumulativeMnth]    Script Date: 05/02/2011 11:34:25 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARIntCumulativeMnth]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARIntCumulativeMnth]
GO
/****** Object:  UserDefinedFunction [dbo].[FNARIntCumulativeMnth]    Script Date: 05/02/2011 11:34:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
---- select dbo.[FNARIntCumulativeMnth]('2008-01-01',339,287)
---- select dbo.FNARIsInterrupt('2007-12-01',275,218)
--
create FUNCTION [dbo].[FNARIntCumulativeMnth] (
	@maturity_date datetime,
	@counterparty_id as varchar(50),
	@contract_id as varchar(50)
)
RETURNS float AS  
BEGIN 
--declare @maturity_date datetime,@counterparty_id int,@contract_id int
--
--set @maturity_date='2007-07-01'
--set @counterparty_id=316
--set @contract_id=255

declare @maturity_date_from varchar(50),@isinterrupt datetime,@retValue as float,@int_end_month int,@multiply_factor float,
@intstartmonth int
Declare @int_start_period datetime
Declare @int_end_period datetime

select @int_end_month=max(int_end_month) from contract_group_detail where contract_id=@contract_id
select @isinterrupt=dbo.FNARIsInterrupt(@maturity_date,@counterparty_id,@contract_id,2)
set @intstartmonth=month(@isinterrupt)

select @int_start_period=(cast(case when max(int_begin_month)>max(int_end_month) and month(@maturity_date)<=max(int_end_month) then 
				 year(@maturity_date)-1 
			when max(int_begin_month)>max(int_end_month) and month(@maturity_date)>max(int_end_month) then 
				 year(@maturity_date)
			when max(int_begin_month)<max(int_end_month)then 
				 year(@maturity_date) 
			end as varchar)+'-'+cast(max(int_begin_month) as varchar)+'-01' ),
		 @int_end_period=(cast(case when max(int_begin_month)>max(int_end_month) and month(@maturity_date)<=max(int_end_month) then 
				 year(@maturity_date)
			when max(int_begin_month)>max(int_end_month) and month(@maturity_date)>max(int_end_month) then 
				 year(@maturity_date)+1
			when max(int_begin_month)<max(int_end_month)then 
				 year(@maturity_date)
			end as varchar)+'-'+cast(max(int_end_month) as varchar)+'-01')
	  from contract_group_detail where contract_id=@contract_id
		

	if @isinterrupt is null
		set @retValue=0
	else 
	begin
		select @retValue= case when month(@maturity_date)<@intstartmonth then
							datediff(month,cast(cast(year(@maturity_date)-1 as varchar)+'-'+cast(@intstartmonth as varchar)+'-01' as datetime),@maturity_date)+1
						  else 
							month(@maturity_date)-@intstartmonth+1 end	
		
		select @multiply_factor=
						case when (@maturity_date) between @int_start_period and @int_end_period 
						
						then
						abs(
								--datediff(month,@isinterrupt,dbo.fnagetcontractmonth(@maturity_date))+1
								datediff(month,@isinterrupt,@int_end_period)+1
						 )
						else 0 end
				
				
		if @multiply_factor=0  
			set @retValue=0
		else
			set @retValue=(@retValue)/@multiply_factor


	end

--select @int_end_month,month(@maturity_date),@intstartmonth,@multiply_factor
--
return @retValue
END
--	


	













