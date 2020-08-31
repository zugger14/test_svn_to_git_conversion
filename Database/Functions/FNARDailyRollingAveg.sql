/****** Object:  UserDefinedFunction [dbo].[FNARDailyRollingAveg]    Script Date: 05/02/2011 11:39:08 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARDailyRollingAveg]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARDailyRollingAveg]
GO
/****** Object:  UserDefinedFunction [dbo].[FNARDailyRollingAveg]    Script Date: 05/02/2011 11:39:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create FUNCTION [dbo].[FNARDailyRollingAveg](
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

set 	@new_prod_date=DATEADD(month,-(@num_month-1),dbo.FNAGETCONTRACTMONTH(@prod_date))

	select @value=--avg(value) from (
		avg(value)  from calc_formula_value where
		isnull(counterparty_id,'')=isnull(@counterparty_id,'')  and isnull(contract_id,'')=isnull(@contract_id,'')
		and isnull(invoice_line_item_id,'')=isnull(@invoice_line_item_id,'') and dbo.FNAGETCONTRACTMONTH(prod_date)
			between dbo.FNAGETCONTRACTMONTH(@new_prod_date) and dbo.FNAGETCONTRACTMONTH(@prod_date)
		 and seq_number=@seq_number
		and isnull(formula_id,'')=isnull(@formula_id,'') 
		and isnull(value,0)<>0
		group by dbo.FNAGETCONTRACTMONTH(prod_date),counterparty_id,contract_id,invoice_line_item_id,formula_id
		--) a
		
		

	return @value
END




