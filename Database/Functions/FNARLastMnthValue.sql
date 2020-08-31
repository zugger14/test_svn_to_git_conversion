IF OBJECT_ID(N'FNARLastMnthValue', N'FN') IS NOT NULL
DROP FUNCTION dbo.FNARLastMnthValue
GO
 
CREATE FUNCTION [dbo].[FNARLastMnthValue]
(
	@prod_date             VARCHAR(20),
	@counterparty_id       INT,
	@contract_id           INT,
	@invoice_line_item_id  INT,
	@formula_id            INT,
	@he                    INT,
	@seq_number            INT,
	@num_month             INT
)
RETURNS FLOAT
AS
	
BEGIN

DECLARE @value FLOAT
DECLARE @new_prod_date datetime

set 	@new_prod_date=DATEADD(month,-@num_month,@prod_date)

	select @value=value from calc_formula_value where
		isnull(counterparty_id,'')=isnull(@counterparty_id,'')  and isnull(contract_id,'')=isnull(@contract_id,'')
		and isnull(invoice_line_item_id,'')=isnull(@invoice_line_item_id,'') and dbo.fnagetcontractmonth(prod_date)=dbo.fnagetcontractmonth(@new_prod_date)
		 and seq_number=@seq_number and isnull(formula_id,'')=isnull(@formula_id,'') and isnull([hour],0)= @he 

	return @value
END











