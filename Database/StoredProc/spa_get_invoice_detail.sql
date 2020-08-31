IF OBJECT_ID(N'[dbo].[spa_get_invoice_detail]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_invoice_detail]
GO 

CREATE PROCEDURE [dbo].[spa_get_invoice_detail]
	@asofdate DATETIME,
	@counterparty_id INT = NULL
	 	
AS

BEGIN

DECLARE @user_login_id VARCHAR(100)
DECLARE @process_id VARCHAR(100)
DECLARE @tempTable VARCHAR(100)
DECLARE @SQL VARCHAR(5000)


	set @sql='
		select 
		sc.counterparty_name Counterparty,
		ISNULL(dbo.FNADateFormat(inv.invoice_date),dbo.FNADateFormat(GETDATE()))as [Invoice Date],
		inv.total as Total,	
		inv.units as Units,
		inv.price as Price,
		ISNULL(inv.uom_id,27) as UOM,
		inv.charge1 as Charge1,
		inv.charge2 as Charge2,
		inv.charge3 as Charge3,
		inv.charge4 as Charge4,
		inv.charge5 as Charge5,
		inv.charge6 as Charge6,
		inv.charge7 as Charge7	,
		inv.charge8 as Charge8,
		inv.charge9 as Charge9,
		inv.charge10 as Charge10,
		ISNULL(inv.paid,''No'') as Paid 
		 from 
		(select * from invoice_detail inv where dbo.FNAGetContractMonth(inv.asofdate)=dbo.FNAGetContractMonth('''+cast(@asofdate as varchar)+''')) inv RIGHT JOIN
		source_counterparty sc on inv.counterparty_id=sc.source_counterparty_id where sc.int_ext_flag=''e''
		'
		+case when @counterparty_id is not null then ' AND  sc.source_counterparty_id='+cast(@counterparty_id as varchar) else '' end
		+ '	order by sc.counterparty_name'
	--print @sql
	exec (@sql)

END
--exec spa_allocate_invoice_amt




