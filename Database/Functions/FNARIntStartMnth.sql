/****** Object:  UserDefinedFunction [dbo].[FNARIntStartMnth]    Script Date: 05/02/2011 11:35:34 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARIntStartMnth]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARIntStartMnth]
GO
/****** Object:  UserDefinedFunction [dbo].[FNARIntStartMnth]    Script Date: 05/02/2011 11:35:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select dbo.FNARIsInterrupt('2008-01-01',275,218)
create FUNCTION [dbo].[FNARIntStartMnth] (
	@maturity_date datetime,
	@counterparty_id as varchar(50),
	@contract_id as varchar(50)
	
	)
RETURNS int AS  
BEGIN 
DECLARE @retvalue int
	select @retvalue=ISNULL(max(int_begin_month),0) from contract_group_detail where contract_id=@contract_id


return @retValue
end









