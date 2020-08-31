/****** Object:  UserDefinedFunction [dbo].[FNARRow]    Script Date: 12/11/2010 15:00:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARRow]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARRow]
/****** Object:  UserDefinedFunction [dbo].[FNARRow]    Script Date: 12/11/2010 15:00:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARRow](
	@prod_date varchar(20),
	@counterparty_id int,
	@contract_id int,
	@invoice_line_item_id int,
	@formula_id int,
	@he int,
	@granularity INT,
	@deal_id INT,
	@estimate_calc CHAR(1),
--	@half int,
--	@qtr int,
	@seq_number int
)

RETURNS FLOAT AS
BEGIN

DECLARE @value FLOAT
declare @maturity_date_from varchar(50),@maturity_date_to varchar(50)
declare @billing_cycle as int
declare @billing_from_date as int
declare @billing_to_date as int
DECLARE @monthI Int
declare @where_condition varchar(500)
declare @maturity_month varchar(50)
declare @interruptVol float
declare @ganularity_row int
declare @calc_id INT

SELECT @ganularity_row=granularity from formula_nested where formula_group_id=@formula_id and sequence_order=@seq_number

select @billing_cycle = billing_cycle from contract_group where contract_id = @contract_id 

set @maturity_date_from=@prod_date
set @maturity_date_to=@prod_date


--Temp Logic
IF @counterparty_id IS NULL
select @value=SUM(ISNULL(value,0)) from deal_calc_cashflow_earnings_detail 
	where
		ISNULL(deal_id,'')=ISNULL(@invoice_line_item_id,'') 
		and as_of_date=@prod_date
		and sequence_number=@seq_number 
		and isnull(formula_id,'')=isnull(@formula_id,'')  
		--and calc_id=@calc_id	
ELSE
BEGIN


if @billing_cycle = 986
begin
	select @billing_from_date = billing_from_date from contract_group where contract_id = @contract_id
	select @billing_to_date = billing_to_date from contract_group where contract_id = @contract_id

	SET @monthI = MONTH(@prod_date)
	set @maturity_date_from = CAST(case when @monthI=1 then Year(@prod_date)-1 else Year(@prod_date) end As Varchar)  + '-' + 
					CASE WHEN (case when @monthI=1 then 12 else  @monthI - 1 end < 10) then '0' else '' end + 
						(CAST(case when @monthI=1 then 12 else  @monthI - 1 end As Varchar)) + '-' + CAST(@billing_from_date as varchar)

	set @maturity_date_to = CAST(Year(@prod_date) As Varchar)  + '-' + 
					CASE WHEN (@monthI < 10) then '0' else '' end + 
						(CAST(@monthI As Varchar)) + '-' + CAST(@billing_to_date as varchar)

	set @where_condition = ' prod_date between ''' + @maturity_date_from + ''' and ''' + @maturity_date_to + ''''
end


IF @estimate_calc='y'
	BEGIN
	select @calc_id=MAX(calc_id)
	from calc_formula_value_estimates where
			ISNULL(counterparty_id,'')=ISNULL(@counterparty_id,'')  and ISNULL(contract_id,-1)=ISNULL(@contract_id,-1)
			and ISNULL(invoice_line_item_id,'')=ISNULL(@invoice_line_item_id,'') 
			--and dbo.fnagetcontractmonth(prod_date)=dbo.fnagetcontractmonth(@prod_date)
			and ((@billing_cycle<> 986 and cast(CAST(Year(prod_date) As Varchar)+'-'+ CAST(month(prod_date) As Varchar) +'-01' as datetime) =cast(CAST(Year(@prod_date) As Varchar)+'-'+ CAST(month(@prod_date) As Varchar) +'-01' as datetime))
				  OR(prod_date between 	@maturity_date_from and @maturity_date_to))
			and seq_number=@seq_number and isnull(formula_id,'')=isnull(@formula_id,'')  

	 if @granularity=980 -- Monthly
		select @value=SUM(ISNULL(value,0)) from calc_formula_value_estimates where
			ISNULL(counterparty_id,'')=ISNULL(@counterparty_id,'')  and ISNULL(contract_id,-1)=ISNULL(@contract_id,-1)
			and ISNULL(invoice_line_item_id,'')=ISNULL(@invoice_line_item_id,'') 
			--and dbo.fnagetcontractmonth(prod_date)=dbo.fnagetcontractmonth(@prod_date)
			and ((@billing_cycle<> 986 and cast(CAST(Year(prod_date) As Varchar)+'-'+ CAST(month(prod_date) As Varchar) +'-01' as datetime) =cast(CAST(Year(@prod_date) As Varchar)+'-'+ CAST(month(@prod_date) As Varchar) +'-01' as datetime))
				  OR(prod_date between 	@maturity_date_from and @maturity_date_to))
			and seq_number=@seq_number and isnull(formula_id,'')=isnull(@formula_id,'')  
			and calc_id=@calc_id
			and ISNULL(deal_id,'')=ISNULL(@deal_id,'')

	 else if @granularity=981 -- Daily
		select @value=SUM(ISNULL(value,0)) from calc_formula_value_estimates where
			ISNULL(counterparty_id,'')=ISNULL(@counterparty_id,'')  and ISNULL(contract_id,-1)=ISNULL(@contract_id,-1)
			and ISNULL(invoice_line_item_id,'')=ISNULL(@invoice_line_item_id,'') 
			and prod_date=@prod_date
			and seq_number=@seq_number and isnull(formula_id,'')=isnull(@formula_id,'')  
			and calc_id=@calc_id	
			and ISNULL(deal_id,'')=ISNULL(@deal_id,'')
	 else if @granularity=982 -- Hourly
		select @value=ISNULL(value,0) from calc_formula_value_estimates where
			ISNULL(counterparty_id,'')=ISNULL(@counterparty_id,'')  and ISNULL(contract_id,-1)=ISNULL(@contract_id,-1)
			and ISNULL(invoice_line_item_id,'')=ISNULL(@invoice_line_item_id,'') and prod_date=@prod_date
			 and seq_number=@seq_number and isnull(formula_id,'')=isnull(@formula_id,'')  and isnull([hour],0)= @he
			 and calc_id=@calc_id
			 and ISNULL(deal_id,'')=ISNULL(@deal_id,'')
	END
	ELSE
	BEGIN
	select @calc_id=MAX(calc_id)
	from calc_formula_value where
			ISNULL(counterparty_id,'')=ISNULL(@counterparty_id,'')  and ISNULL(contract_id,-1)=ISNULL(@contract_id,-1)
			and ISNULL(invoice_line_item_id,'')=ISNULL(@invoice_line_item_id,'') 
			--and dbo.fnagetcontractmonth(prod_date)=dbo.fnagetcontractmonth(@prod_date)
			and ((@billing_cycle<> 986 and cast(CAST(Year(prod_date) As Varchar)+'-'+ CAST(month(prod_date) As Varchar) +'-01' as datetime) =cast(CAST(Year(@prod_date) As Varchar)+'-'+ CAST(month(@prod_date) As Varchar) +'-01' as datetime))
				  OR(prod_date between 	@maturity_date_from and @maturity_date_to))
			and seq_number=@seq_number and isnull(formula_id,'')=isnull(@formula_id,'')  

	 if @granularity=980 -- Monthly
		select @value=SUM(ISNULL(value,0)) from calc_formula_value where
			ISNULL(counterparty_id,'')=ISNULL(@counterparty_id,'')  and ISNULL(contract_id,-1)=ISNULL(@contract_id,-1)
			and ISNULL(invoice_line_item_id,'')=ISNULL(@invoice_line_item_id,'') 
			--and dbo.fnagetcontractmonth(prod_date)=dbo.fnagetcontractmonth(@prod_date)
			and ((@billing_cycle<> 986 and cast(CAST(Year(prod_date) As Varchar)+'-'+ CAST(month(prod_date) As Varchar) +'-01' as datetime) =cast(CAST(Year(@prod_date) As Varchar)+'-'+ CAST(month(@prod_date) As Varchar) +'-01' as datetime))
				  OR(prod_date between 	@maturity_date_from and @maturity_date_to))
			and seq_number=@seq_number and isnull(formula_id,'')=isnull(@formula_id,'')  
			and calc_id=@calc_id
			and ISNULL(deal_id,'')=ISNULL(@deal_id,'')

	 else if @granularity=981 -- Daily
		select @value=SUM(ISNULL(value,0)) from calc_formula_value where
			ISNULL(counterparty_id,'')=ISNULL(@counterparty_id,'')  and ISNULL(contract_id,-1)=ISNULL(@contract_id,-1)
			and ISNULL(invoice_line_item_id,'')=ISNULL(@invoice_line_item_id,'') 
			and prod_date=@prod_date
			and seq_number=@seq_number and isnull(formula_id,'')=isnull(@formula_id,'')  
			and calc_id=@calc_id	
			and ISNULL(deal_id,'')=ISNULL(@deal_id,'')
	 else if @granularity=982 -- Hourly
		select @value=ISNULL(value,0) from calc_formula_value where
			ISNULL(counterparty_id,'')=ISNULL(@counterparty_id,'')  and ISNULL(contract_id,-1)=ISNULL(@contract_id,-1)
			and ISNULL(invoice_line_item_id,'')=ISNULL(@invoice_line_item_id,'') and prod_date=@prod_date
			 and seq_number=@seq_number and isnull(formula_id,'')=isnull(@formula_id,'')  and isnull([hour],0)= @he
			 and calc_id=@calc_id
			 and ISNULL(deal_id,'')=ISNULL(@deal_id,'')
	-- else if @granularity=987 -- 15 minutes
	--	select @value=ISNULL(value,0) from calc_formula_value where
	--		ISNULL(counterparty_id,'')=ISNULL(@counterparty_id,'')  and ISNULL(contract_id,'')=ISNULL(@contract_id,'')
	--		and ISNULL(invoice_line_item_id,'')=ISNULL(@invoice_line_item_id,'') and prod_date=@prod_date
	--		 and seq_number=@seq_number and isnull(formula_id,'')=isnull(@formula_id,'')  and isnull([hour],0)= @he
	--		 and ISNULL([qtr],0)=@qtr
	--		
	-- else if @granularity=989 -- 30 minutes
	--
	--	BEGIN	
	--		IF @ganularity_row=980
	--		select @value=ISNULL(value,0) from calc_formula_value where
	--			ISNULL(counterparty_id,'')=ISNULL(@counterparty_id,'')  and ISNULL(contract_id,'')=ISNULL(@contract_id,'')
	--			and ISNULL(invoice_line_item_id,'')=ISNULL(@invoice_line_item_id,'') and dbo.fnagetcontractmonth(prod_date)=dbo.fnagetcontractmonth(@prod_date)
	--			 and seq_number=@seq_number and isnull(formula_id,'')=isnull(@formula_id,'')  
	--		ELSE
	--		select @value=ISNULL(value,0) from calc_formula_value where
	--			ISNULL(counterparty_id,'')=ISNULL(@counterparty_id,'')  and ISNULL(contract_id,'')=ISNULL(@contract_id,'')
	--			and ISNULL(invoice_line_item_id,'')=ISNULL(@invoice_line_item_id,'') and prod_date=@prod_date
	--			 and seq_number=@seq_number and isnull(formula_id,'')=isnull(@formula_id,'')  
	--			and isnull([hour],0)= @he and ISNULL([half],0)=@half
	--
	--
	--	END	
	END

END
	if @value IS NULL
		SET @value=0

	return  @value
END















