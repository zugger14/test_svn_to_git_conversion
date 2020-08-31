IF OBJECT_ID(N'[dbo].[spa_get_confirm_info]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_confirm_info]
GO 




-- EXEC spa_get_confirm_info 2


CREATE PROCEDURE [dbo].[spa_get_confirm_info] 
	@confirm_id int
AS


--set @invoice_number = '10013'


select scs.confirm_id, cci.from_text, cci.to_text,
cci.instruction, dbo.FNADateFormat(scs.as_of_date) as_of_date

from save_confirm_status scs inner join
counterparty_confirm_info cci on cci.counterparty_id = scs.counterparty_id 
where scs.counterparty_id = @confirm_id

-- select * from save_confirm_status

-- 
-- select * from counterparty_confirm_info





