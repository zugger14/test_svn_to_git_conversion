/****** Object:  UserDefinedFunction [dbo].[FNAEMSRow]    Script Date: 11/01/2009 12:31:46 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAEMSRow]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAEMSRow]
/****** Object:  UserDefinedFunction [dbo].[FNAEMSRow]    Script Date: 11/01/2009 12:31:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAEMSRow](
	@prod_date varchar(20),
	@counterparty_id int,
	@contract_id int,
	@invoice_line_item_id int,
	@formula_id int,
	@he int,
	@granularity INT,
	@generator_id int,
	@ems_generator_id INT,
	@seq_number int

)

RETURNS FLOAT AS
BEGIN

DECLARE @value FLOAT

if @he is null
	select @value=value from calc_formula_value where
		ISNULL(counterparty_id,'')=ISNULL(@counterparty_id,'')  and ISNULL(contract_id,'')=ISNULL(@contract_id,'')
		and ISNULL(invoice_line_item_id,'')=ISNULL(@invoice_line_item_id,'') and prod_date=@prod_date
		 and seq_number=@seq_number and isnull(formula_id,'')=isnull(@formula_id,'')  
		 and isnull(generator_id,'')=isnull(@generator_id,'')
		 --and ISNULL(ems_generator_id,'')=isnull(@ems_generator_id,'')
else
	select @value=value from calc_formula_value_hour where 1=1
		and ISNULL(counterparty_id,'')=ISNULL(@counterparty_id,'')  and ISNULL(contract_id,'')=ISNULL(@contract_id,'')
		and ISNULL(invoice_line_item_id,'')=ISNULL(@invoice_line_item_id,'') and prod_date=@prod_date
		 and seq_number=@seq_number and isnull(formula_id,'')=isnull(@formula_id,'')  
		 and isnull([hour],0)= isnull(@he,0)
		 and isnull(generator_id,'')=isnull(@generator_id,'')
	
	
	return  @value
END









