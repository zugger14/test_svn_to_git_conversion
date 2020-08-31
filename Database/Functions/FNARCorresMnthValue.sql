/****** Object:  UserDefinedFunction [dbo].[FNARCorresMnthValue]    Script Date: 05/02/2011 10:41:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARCorresMnthValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARCorresMnthValue]
/****** Object:  UserDefinedFunction [dbo].[FNARCorresMnthValue]    Script Date: 05/02/2011 10:41:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  FUNCTION [dbo].[FNARCorresMnthValue](
	@prod_date varchar(20),
	@counterparty_id int,
	@contract_id int,
	@invoice_line_item_id int,
	@formula_id int,
	@he int,
	@granularity int,
	@seq_number int,
	@num_month int
	--, @month_number int
	
)

RETURNS FLOAT AS
BEGIN

DECLARE @value FLOAT
DECLARE @year int
DECLARE @date_str varchar(500)
DECLARE @month_number int
DECLARE @day int

set  @value=0
set  @year=YEAR(@prod_date)
set  @month_number=MONTH(@prod_date)		
set @day=day(@prod_date)

	set @date_str=''
	set @num_month=@num_month
	while @num_month>0
	begin
		set @date_str=''+cast(@year-@num_month as varchar)+'-'+RIGHT('00'+cast(@month_number as varchar),2)+'-'+cast(@day as varchar)+''
 if @granularity=980 -- Monthly
		select @value=@value+ISNULL(value,0) from calc_formula_value where
		isnull(counterparty_id,'')=isnull(@counterparty_id,'')  and isnull(contract_id,'')=isnull(@contract_id,'')
		and isnull(invoice_line_item_id,'')=isnull(@invoice_line_item_id,'') 
		 and cast(CAST(Year(prod_date) As Varchar)+'-'+CAST(month(prod_date) As Varchar) +'-01' as datetime) in(@date_str)
		 and seq_number=@seq_number and isnull(formula_id,'')=isnull(@formula_id,'') 
		--and isnull([hour],0)= @he 
	
 else if @granularity=981 -- Daily
		select @value=@value+ISNULL(value,0) from calc_formula_value where
		isnull(counterparty_id,'')=isnull(@counterparty_id,'')  and isnull(contract_id,'')=isnull(@contract_id,'')
		and isnull(invoice_line_item_id,'')=isnull(@invoice_line_item_id,'') 
			and prod_date in(@date_str)
		 and seq_number=@seq_number and isnull(formula_id,'')=isnull(@formula_id,'') 
		 --and isnull([hour],0)= @he 
 else if @granularity=982 -- Hourly
		select @value=@value+ISNULL(value,0) from calc_formula_value where
		isnull(counterparty_id,'')=isnull(@counterparty_id,'')  and isnull(contract_id,'')=isnull(@contract_id,'')
		and isnull(invoice_line_item_id,'')=isnull(@invoice_line_item_id,'') 
			and prod_date in(@date_str)
		 and seq_number=@seq_number and isnull(formula_id,'')=isnull(@formula_id,'') and isnull([hour],0)= @he 

	set @num_month=@num_month-1
	end

	return @value
END


