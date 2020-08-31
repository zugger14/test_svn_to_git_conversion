IF OBJECT_ID(N'FNARRolling', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNARRolling]
 GO 
CREATE FUNCTION [dbo].[FNARRolling]
(
	@prod_date             VARCHAR(20),
	@counterparty_id       INT,
	@contract_id           INT,
	@invoice_line_item_id  INT,
	@formula_id            INT,
	@he                    INT,
	@granularity           INT,
	@seq_number            INT,
	@num_month             INT
)

RETURNS FLOAT AS
BEGIN

DECLARE @value FLOAT
DECLARE @new_prod_date datetime

set 	@new_prod_date=DATEADD(month,-(@num_month-1),@prod_date)

 if 	@granularity=980
	select @value=AVG(value) from calc_formula_value where
		ISNULL(counterparty_id,'')=ISNULL(@counterparty_id,'')  and ISNULL(contract_id,'')=ISNULL(@contract_id,'')
		and ISNULL(invoice_line_item_id,'')=ISNULL(@invoice_line_item_id,'') 
		 and cast(CAST(Year(prod_date) As Varchar)+'-'+CAST(month(prod_date) As Varchar) +'-01' as datetime) between @new_prod_date and @prod_date
		and seq_number=@seq_number 
		--and isnull([hour],0)= @he 
		and isnull(formula_id,'')=isnull(@formula_id,'')
else if 	@granularity=981
	select @value=AVG(value) from calc_formula_value where
		ISNULL(counterparty_id,'')=ISNULL(@counterparty_id,'')  and ISNULL(contract_id,'')=ISNULL(@contract_id,'')
		and ISNULL(invoice_line_item_id,'')=ISNULL(@invoice_line_item_id,'') 
		and prod_date between @new_prod_date and @prod_date
		and seq_number=@seq_number 
		--and isnull([hour],0)= @he 
		and isnull(formula_id,'')=isnull(@formula_id,'')
else if	@granularity=982
	select @value=AVG(value) from calc_formula_value where
		ISNULL(counterparty_id,'')=ISNULL(@counterparty_id,'')  
		and ISNULL(contract_id,'')=ISNULL(@contract_id,'')
		and ISNULL(invoice_line_item_id,'')=ISNULL(@invoice_line_item_id,'') 
		and prod_date between @new_prod_date and @prod_date
		and seq_number=@seq_number 
		and isnull([hour],0)= @he 
		and isnull(formula_id,'')=isnull(@formula_id,'')
	return @value
END






