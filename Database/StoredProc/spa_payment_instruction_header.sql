IF OBJECT_ID(N'[dbo].[spa_payment_instruction_header]', N'P') IS NOT NULL
drop PROCEDURE [dbo].[spa_payment_instruction_header]
go

create PROCEDURE [dbo].[spa_payment_instruction_header]
	@flag CHAR(1)=NULL,
	@payment_ins_header_id int=null,
	@counterparty_id int=NULL,
	@payment_ins_name varchar(100)=null,
	@prod_date datetime=null,
	@comments varchar(500)=null

AS
BEGIN


DECLARE @sql varchar(5000)


if @flag='s'
BEGIN

	 select
		 payment_ins_header_id as [ID],
		 payment_ins_name [Name],
		 dbo.fnadateformat(prod_date) [Date],
		 comments Comments	
	from 
		payment_instruction_header 
	where
		counterparty_id=@counterparty_id
		and prod_date=@prod_date

END

else if @flag='a'
BEGIN
	select payment_ins_header_id ,
		 payment_ins_name, 	 
		 prod_date,
		 comments	
	from 
		payment_instruction_header 
	where
		payment_ins_header_id=@payment_ins_header_id
		
	
END
ELSE IF @flag='i'
BEGIN
	

	insert into payment_instruction_header(
			 counterparty_id,
			 payment_ins_name,
			 prod_date,
			 comments	
		)
	select
			 
			 @counterparty_id,
			 @payment_ins_name,
			 @prod_date,
			 @comments	

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "calc invoice Volume", 
		"spa_calc_invoice_volume_input", "DB Error", 
		"Error  Inserting Data.", ''
	else
		Exec spa_ErrorHandler 0, 'calc invoice Volume', 
		'spa_meter', 'Success', 
		'Data Inserted Successfully.',''

END

ELSE IF @flag='u'
BEGIN


	update payment_instruction_header
		set 
			 payment_ins_name=@payment_ins_name,
			 comments=@comments	
	where 	
		payment_ins_header_id=@payment_ins_header_id

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "calc invoice Volume", 
		"spa_calc_invoice_volume_input", "DB Error", 
		"Error  Updating Data.", ''
	else
		Exec spa_ErrorHandler 0, 'calc invoice Volume', 
		'spa_meter', 'Success', 
		'Data Updated Successfully.',''

END

ELSE IF @flag='d'
BEGIN
	delete payment_instruction_header

	where 	
		payment_ins_header_id=@payment_ins_header_id

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "calc invoice Volume", 
		"spa_calc_invoice_volume_input", "DB Error", 
		"Error  Deleting Data.", ''
	else
		Exec spa_ErrorHandler 0, 'calc invoice Volume', 
		'spa_meter', 'Success', 
		'Data Deleted Successfully.',''

END

END










