IF OBJECT_ID(N'[dbo].[spa_payment_instruction_detail]', N'P') IS NOT NULL
drop PROCEDURE [dbo].[spa_payment_instruction_detail]
go

CREATE PROCEDURE [dbo].[spa_payment_instruction_detail]
	@flag CHAR(1) = NULL,
	@payment_ins_header_id INT = NULL,
	@payment_ins_detail_id VARCHAR(100) = NULL,
	@invoice_Line_item_id VARCHAR(100) = NULL,
	@counterparty_id INT = NULL,
	@prod_date DATETIME = NULL,
	@calc_detail_id VARCHAR(100) = NULL
	 --@contract_id int=null			
	 
AS
BEGIN

DECLARE @sql varchar(5000)



if @flag='s' -- show all charge type that is finalized for the production month
BEGIN

			

set @sql= '
	 SELECT DISTINCT '+
		 case when @payment_ins_header_id is not null then ' pid.payment_ins_detail_id 
	        [Payment Ins Detail ID],
	        ' else 'NULL,
	        ' end +'
	        civ.calc_detail_id [Calc Detail ID],
	        civ.invoice_line_item_id [Invoice Line Item ID],
	        sd.description AS [Charge Type],
	        dbo.fnadateformat(civ.prod_date) AS [Prod Month],
	        CASE 
	             WHEN civ.manual_input = ''y'' THEN civ.value
	             WHEN civv.book_entries = ''i'' THEN id.invoice_amount
	             ELSE civ.value
	        END AS [Value],
	        pih.payment_ins_name [Instruction Group]
	from 
		source_counterparty sc 
		INNER JOIN calc_invoice_volume_variance civv on civv.counterparty_id=sc.source_counterparty_id
		join 
		(select max(as_of_date) as_of_date,prod_date,counterparty_id,contract_id from
			calc_invoice_volume_variance group by prod_date,counterparty_id,contract_id) a
		on a.as_of_date=civv.as_of_date and a.prod_date=civv.prod_date and a.counterparty_id=sc.source_counterparty_id
			AND a.contract_id=civv.contract_id
		INNER JOIN  calc_invoice_volume civ on civ.calc_id=civv.calc_id'+
		case when @payment_ins_header_id is not null then ' inner join 
		payment_instruction_detail pid on pid.calc_detail_id=civ.calc_detail_id
		inner join payment_instruction_header pih on pih.payment_ins_header_id=pid.payment_ins_header_id ' else 
		' left join payment_instruction_detail pid on pid.calc_detail_id=civ.calc_detail_id
		 left join payment_instruction_header pih on pih.payment_ins_header_id=pid.payment_ins_header_id ' end+
		' left join static_data_value sd on sd.value_id=civ.invoice_line_item_id
		  left join invoice_header ih on ih.invoice_id=civv.invoice_id
		  left join invoice_detail id on ih.invoice_id=id.invoice_id and id.invoice_line_item_id=civ.invoice_line_item_id		
	where
		sc.source_counterparty_id='+cast(@counterparty_id as varchar)+'
		and civv.prod_date='''+cast(@prod_date as varchar)+'''
		--and civv.finalized=''y'' 
		and ( (civv.finalized=''y'' and isnull(civ.manual_input,''n'')=''n'') or
		((civ.finalized=''y'' and isnull(civ.manual_input,''n'')=''y'') ))'+
		case when @payment_ins_header_id is not null then ' AND pih.payment_ins_header_id='+cast(@payment_ins_header_id as varchar) else '' end

EXEC spa_print @sql
exec(@sql)
END

ELSE IF @flag = 'a'
 BEGIN
     SELECT payment_ins_detail_id, payment_ins_header_id, invoice_Line_item_id
     FROM   payment_instruction_detail
     WHERE  payment_ins_detail_id = @payment_ins_detail_id
END
ELSE IF @flag='i' -- Assign
BEGIN

--## check if this line item already exists 
create table #temp_c(payment_ins_detail_id int)

set @sql='
INSERT  INTO #temp_c
SELECT  payment_ins_detail_id from payment_instruction_detail where payment_ins_header_id in
			(select payment_ins_header_id from payment_instruction_header where 1=1
				--payment_ins_header_id=@payment_ins_header_id 
				and counterparty_id='+cast(@counterparty_id as varchar)+'
				and prod_date='''+cast(@prod_date as varchar)+''') 
				AND invoice_Line_item_id in('+@invoice_Line_item_id+')'
exec(@sql)
if exists(select * from #temp_c)
BEGIN
		
	EXEC spa_ErrorHandler 1,
	     'Charge Type is ALready Assigned',
	     'spa_calc_invoice_volume_input',
	     'DB Error',
	     'Error  Updating Data.',
	     ''
	RETURN
END

set @sql=
	
	'
	INSERT INTO payment_instruction_detail
	  (payment_ins_header_id, invoice_Line_item_id, calc_detail_id)
	SELECT '+cast(@payment_ins_header_id AS VARCHAR)+', invoice_Line_item_id, calc_detail_id
	FROM calc_invoice_volume
		 WHERE calc_detail_id in('+@calc_detail_id+')'	

exec(@sql)

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


	update payment_instruction_detail
		set 
			 payment_ins_header_id=@payment_ins_header_id,
			 invoice_Line_item_id=@invoice_Line_item_id
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

ELSE IF @flag='d' -- Unassign
BEGIN

set @sql=
	' delete payment_instruction_detail

	where 	
		payment_ins_detail_id in ('+@payment_ins_detail_id+')'

exec(@sql)

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























