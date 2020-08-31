IF OBJECT_ID(N'FNARAnnualVolCOD', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNARAnnualVolCOD]
 GO
 
CREATE FUNCTION [dbo].[FNARAnnualVolCOD]
(
	@prod_date             VARCHAR(20),
	@counterparty_id       INT,
	@contract_id           INT,
	@invoice_line_item_id  INT,
	@formula_id            INT,
	@seq_number            INT
)

RETURNS FLOAT AS
BEGIN

DECLARE @value FLOAT
DECLARE @from_COD datetime
DECLARE @COD_date datetime
DECLARE @to_COD datetime

	select @COD_date=term_start from contract_group where contract_id=@contract_id
	
	set @from_COD= cast(''+cast(year(@prod_date)-1 as varchar)+'-'+cast(month(@COD_date)as varchar)+'-'+cast(day(@COD_date) as varchar)+'' as datetime)
	set @to_COD=  cast(''+cast(year(@prod_date) as varchar)+'-'+cast(month(@COD_date)as varchar)+'-'+cast(day(@COD_date)-1 as varchar)+'' as datetime)

	select @value=sum(value) from calc_formula_value where
		ISNULL(counterparty_id,'')=ISNULL(@counterparty_id,'')  and ISNULL(contract_id,'')=ISNULL(@contract_id,'')
		and ISNULL(invoice_line_item_id,'')=ISNULL(@invoice_line_item_id,'') and prod_date between @from_COD and @to_COD
		and seq_number=@seq_number and isnull(formula_id,'')=isnull(@formula_id,'')

	return @value
END










