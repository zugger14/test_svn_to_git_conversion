IF OBJECT_ID(N'spa_UpdateInvoiceXml', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_UpdateInvoiceXml]
 GO 


CREATE procedure [dbo].[spa_UpdateInvoiceXml]
@flag char(1)=null,
@xmlValue TEXT,
@invoice_id int=null,
@counterparty_id int=null,
@contract_id int=null,
@prod_date datetime=null,
@as_of_date datetime=null

AS

DECLARE @sqlStmt VARCHAR(8000)
Declare @tempdetailtable varchar(128)
Declare @user_login_id varchar(100),@process_id varchar(50)

set @user_login_id=dbo.FNADBUser()
--select @process_id

set @process_id=REPLACE(newid(),'-','_')

set @tempdetailtable=dbo.FNAProcessTableName('invoice_process', @user_login_id,@process_id)

set @sqlStmt='create table '+ @tempdetailtable+'( 
	 [invoice_detail_id] int  NULL ,    
	 [invoice_line_item_id] int  NULL ,      
	 [invoice_amount] float  NULL ,      
	)     
	'
	
	exec(@sqlStmt)

DECLARE @idoc int
DECLARE @doc varchar(1000)

exec sp_xml_preparedocument @idoc OUTPUT, @xmlValue

SELECT * into #ztbl_xmlvalue
FROM   OPENXML (@idoc, '/Root/PSRecordset',2)
         WITH (	      
		 invoice_detail_id  int    '@invoice_detail_id',
		     invoice_line_item_id int    '@invoice_line_item_id',
               invoice_amount float    '@invoice_amount'
		)
if @flag='m' -- update for manual input
begin
	update a
	set 
		a.value=b.invoice_amount
	from
		calc_invoice_volume a,
		(select t.invoice_amount,civv.calc_id,t.invoice_Line_item_id
			from calc_invoice_volume_variance civv
			inner join calc_invoice_volume civ on civ.calc_id=civv.calc_id
			inner join #ztbl_xmlvalue t on civ.invoice_line_item_id=t.invoice_line_item_id
		where
			civv.counterparty_id=@counterparty_id and
			civv.contract_id=@contract_id and
			dbo.FNAGetContractmonth(civv.prod_date)=dbo.FNAGetContractmonth(@prod_date) and
			dbo.FNAGetContractmonth(civv.as_of_date)=dbo.FNAGetContractmonth(@as_of_date) 
		) b
	where
		a.calc_id=b.calc_id and		
		a.invoice_line_item_id=b.invoice_line_item_id
end	
	
else
begin -- update for invoice input
	update invoice_detail
	set invoice_id=@invoice_id,
	invoice_line_item_id=t.invoice_line_item_id,
	invoice_amount=t.invoice_amount
	from #ztbl_xmlvalue t, invoice_detail d
	where t.invoice_detail_id=d.invoice_detail_id


	insert invoice_detail(invoice_id,invoice_line_item_id,invoice_amount)
	select @invoice_id,invoice_line_item_id,invoice_amount from #ztbl_xmlvalue 
	where invoice_detail_id=-1

end		
	If @@ERROR <> 0
		Begin	
			Exec spa_ErrorHandler @@ERROR, 'Source Deal Detail', 
				'spa_getXml', 'DB Error', 
				'Failed Inserting record.', 'Failed Inserting Record'
			
		End
		Else
		Begin
			Exec spa_ErrorHandler 0, 'Source Deal Detail', 
			'spa_getXml', 'Success', 
			'Source deal  detail record successfully updated.', ''
			
		End



