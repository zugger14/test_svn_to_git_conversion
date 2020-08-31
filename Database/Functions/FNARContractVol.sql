/****** Object:  UserDefinedFunction [dbo].[FNARContractVol]    Script Date: 05/02/2011 13:36:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARContractVol]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARContractVol]
GO
/****** Object:  UserDefinedFunction [dbo].[FNARContractVol]    Script Date: 05/02/2011 13:37:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE function	[dbo].[FNARContractVol](
	@maturity_date datetime,
	@counterparty_id as varchar(50),
	@contract_id as varchar(50)
	)

RETURNS float As
Begin

--declare @maturity_date datetime,@counterparty_id int,@contract_id int
--
--set @maturity_date='2007-07-01'
--set @counterparty_id=279
--set @contract_id=229


declare @maturity_date_temp as datetime
declare @retValue as float



select @retValue = civv.allocationvolume from 
	calc_invoice_volume_variance civv
	inner join
	(
	select max(as_of_date) as as_of_date,prod_date,counterparty_id,contract_id
		 from calc_invoice_volume_variance
	where
	prod_date = @maturity_date
	and contract_id = @contract_id
	group by
	prod_date,counterparty_id,contract_id
	) a
	on 
	civv.prod_date=a.prod_date
	and civv.as_of_date=a.as_of_date
	and civv.contract_id=a.contract_id

--print @retValue
return @retValue
end
