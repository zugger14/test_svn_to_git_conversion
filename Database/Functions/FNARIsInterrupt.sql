/****** Object:  UserDefinedFunction [dbo].[FNARIsInterrupt]    Script Date: 12/30/2008 11:44:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARIsInterrupt]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARIsInterrupt]


GO
 -- select dbo.FNARIsInterrupt('2007-06-01',316,255,2)
CREATE FUNCTION [dbo].[FNARIsInterrupt] (
	@maturity_date datetime,
	@counterparty_id as varchar(50),
	@contract_id as varchar(50),
	@daily as int		-- 1 for daily , 0 for production month
	)
RETURNS DateTime AS  
BEGIN 

--declare @maturity_date datetime,@counterparty_id int,@contract_id int, @daily int
--
--set @maturity_date='2008-06-01'
--set @counterparty_id= 339
--set @contract_id=287
--set @daily = 2
--
--set @maturity_date='2007-11-01'
--set @counterparty_id= 316
--set @contract_id=255
--set @daily = 2

declare @maturity_date_from varchar(50)
declare @maturity_date_to varchar(50)

declare @retValue as datetime
declare @countInterrupt as datetime


declare @billing_cycle as int
declare @billing_from_date as int
declare @billing_to_date as int
DECLARE @monthI Int
declare @where_condition varchar(500)
declare @maturity_month varchar(50)
Declare @int_start_period datetime
Declare @int_end_period datetime


select @billing_cycle = billing_cycle from contract_group where contract_id = @contract_id 

--select @billing_cycle

if @billing_cycle = 990
begin
	select @billing_from_date = billing_from_date from contract_group where contract_id = @contract_id
	select @billing_to_date = billing_to_date from contract_group where contract_id = @contract_id

	

	SET @monthI = MONTH(@maturity_date)
	
	set @maturity_date_from = CAST(Year(@maturity_date)-case when month(@maturity_date)=1 then 1 else 0 end As Varchar)  + '-' + 
					CASE WHEN (@monthI< 10 and month(@maturity_date)<>1 ) then '0' else '' end + 
						(CAST(case when month(@maturity_date)=1 then 12 else @monthI-1 end As Varchar)) + '-' + CAST(@billing_from_date as varchar)
	
 set @maturity_date_to = CAST(Year(@maturity_date) As Varchar)  + '-' + 
					CASE WHEN (@monthI < 10) then '0' else '' end + 
						(CAST(@monthI As Varchar)) + '-' + CAST(@billing_to_date as varchar)

	set @where_condition = ' prod_date between ''' + @maturity_date_from + ''' and ''' + @maturity_date_to + ''''
end
else
	set @maturity_month = CAST(Year(@maturity_date) As Varchar)  + '-' + 
					CASE WHEN (@monthI < 10) then '0' else '' end + 
						(CAST(Month(@maturity_date) As Varchar))

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



select @countInterrupt =
		case when @daily=3 then min(dbo.fnagetcontractmonth(ida.prod_date))
			 when @billing_cycle = 990 then min(dbo.fnagetcontractmonth(dateadd(month,1,ida.prod_date))) 
		else min(dbo.fnagetcontractmonth(ida.prod_date)) end
		--select min(dbo.fnagetcontractmonth(prod_date))
		from interrupt_data ida join contract_group_detail cgd on ida.contract_id=cgd.contract_id and 
			(cgd.int_begin_month is not null and cgd.int_end_month is not null)		
		where
		ida.contract_id = @contract_id
		--ida.contract_id = @contract_id --and ida.prod_date between @maturity_date_from and @maturity_date_to
		--and
		 
			--(
--			(@billing_cycle = 990 AND ida.prod_date between @maturity_date_from and @maturity_date_to)
--					OR
			--(
			--and @billing_cycle = 976 
				AND 
				((
					@daily = 0
					and ((@billing_cycle = 976  and dbo.fnagetcontractmonth(@maturity_date)=dbo.fnagetcontractmonth(ida.prod_date))
						 or (@billing_cycle = 990  and ida.prod_date between @maturity_date_from and @maturity_date_to))
				)
				OR(@daily = 1 and @maturity_date=ida.prod_date)
				OR((@daily = 2 or @daily=3) and ((@billing_cycle = 976 and (@maturity_date)
									   between @int_start_period and @int_end_period and ida.prod_date between
									    @int_start_period and @int_end_period)	
									OR
									 (@billing_cycle = 990 and month(@maturity_date_from)
									   between  cgd.int_begin_month and cgd.int_end_month
									   and month(ida.prod_date) between
									    cgd.int_begin_month and cgd.int_end_month
									))		

				)	
			)
				 			
			--))
		
		and 1=1--	ida.prod_date between cgd.
		--group by ida.contract_id,prod_date



if @countInterrupt is not null
	set @retValue = @countInterrupt
else
	set @retValue = NULL	

--print 'retValue: ' +  cast(@retValue as varchar)
--
return @retValue
end
















