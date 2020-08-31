/****** Object:  UserDefinedFunction [dbo].[FNARMxRwValue]    Script Date: 05/02/2011 11:04:41 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARMxRwValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARMxRwValue]
GO
/****** Object:  UserDefinedFunction [dbo].[FNARMxRwValue]    Script Date: 05/02/2011 11:04:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARMxRwValue](
	@prod_date varchar(20),
	@counterparty_id int,
	@contract_id int,
	@invoice_line_item_id int,
	@formula_id int,
	@he int,
	@seq_number int,
	@num_month int
	
)

RETURNS FLOAT AS
BEGIN

DECLARE @value FLOAT
DECLARE @new_prod_date datetime

--set 	@new_prod_date=DATEADD(month,-(@num_month+1),@prod_date)
--set 	@prod_date=DATEADD(month,-1,@prod_date)

set 	@new_prod_date=DATEADD(month,-(@num_month),@prod_date)
set 	@prod_date=DATEADD(month,0,@prod_date)

	select @value=MAX(value) from calc_formula_value where
		isnull(counterparty_id,'')=isnull(@counterparty_id,'')  and isnull(contract_id,'')=isnull(@contract_id,'')
		and isnull(invoice_line_item_id,'')=isnull(@invoice_line_item_id,'') and prod_date between @new_prod_date and @prod_date
		 and seq_number=@seq_number
		 and isnull([hour],0)= @he 
		 and isnull(formula_id,'')=isnull(@formula_id,'') 

	return @value
END













