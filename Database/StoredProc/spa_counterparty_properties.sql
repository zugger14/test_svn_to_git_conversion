IF OBJECT_ID(N'spa_counterparty_properties', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_counterparty_properties]
 GO 



CREATE PROCEDURE [dbo].[spa_counterparty_properties]
	@flag CHAR(1),
	@counterparty_id int,
	@from_text varchar(1000)=NULL,
	@to_text varchar(1000)=NULL,
	@instruction varchar(1000)=NULL,
	@pre_text varchar(250)=NULL,
	@post_text varchar(250)=NULL,
	@bill_to varchar(1000)=NULL,
	@bill_from varchar(1000)=NULL,
	@instruction1 varchar(1000)=NULL,
	@instruction2 varchar(250)=NULL,
	@instruction3 varchar(250)=NULL,
	@instruction4 varchar(250)=NULL,
	@instruction5  varchar(250)=NULL
AS
BEGIN
IF @flag='s'
	select 
	con.from_text,
	con.to_text,
	con.instruction,
	inv.pre_text,
	inv.post_text,
	inv.bill_to,
	inv.bill_from,
	inv.instruction1,
	inv.instruction2,
	inv.instruction3,
	inv.instruction4,
	inv.instruction5
from
	source_counterparty sc LEFT JOIN 
	counterparty_confirm_info con on sc.source_counterparty_id=con.counterparty_id
	LEFT OUTER join
	counterparty_invoice_info inv
	on sc.source_counterparty_id=inv.source_counterparty_id
where 
	inv.source_counterparty_id=@counterparty_id
	
ELSE IF @flag='i'
BEGIN
BEGIN TRAN
	INSERT INTO counterparty_confirm_info(
		counterparty_id,
		from_text,
		to_text,
		instruction
	)
	select 
		@counterparty_id,
		''+@from_text+'',
		''+@to_text+'',
		''+@instruction+''

------------------------------------------

IF @@ERROR<>0 
	BEGIN
		Exec spa_ErrorHandler @@ERROR, 'Counterparty Properties', 
		'spa_counterparty_properties', 'DB Error', 
		'Failed updating record.', ''
	ROLLBACK TRAN
		return

	END

else
	BEGIN
	INSERT INTO counterparty_invoice_info(
		source_counterparty_id,
		pre_text,
		post_text,
		bill_to,
		bill_from,
		instruction1,
		instruction2,
		instruction3,
		instruction4,
		instruction5
	)
	select 
		@counterparty_id,
		''+@pre_text+'',
		''+@post_text+'',
		''+@bill_to+'',
		''+@bill_from+'',
		''+@instruction1+'',
		''+@instruction2+'',
		''+@instruction3+'',
		''+@instruction4+'',
		''+@instruction5+''		

	IF @@ERROR<>0 
		BEGIN
			Exec spa_ErrorHandler @@ERROR, 'Counterparty Properties', 
			'spa_counterparty_properties', 'DB Error', 
			'Failed updating record.', ''
		ROLLBACK TRAN
			return
	
		END
	ELSE
		COMMIT TRAN
	END
END		
ELSE IF @flag='u'
BEGIN
BEGIN TRAN
	update counterparty_confirm_info
	set
		from_text=@from_text,
		to_text=@to_text,
		instruction=@instruction
	where counterparty_id=@counterparty_id

IF @@ERROR<>0 
	BEGIN
		Exec spa_ErrorHandler @@ERROR, 'Counterparty Properties', 
		'spa_counterparty_properties', 'DB Error', 
		'Failed updating record.', ''
	ROLLBACK TRAN

	END

else
BEGIN
	update counterparty_invoice_info
	set 
		pre_text=@pre_text,
		post_text=@post_text,
		bill_to=@bill_to,
		bill_from=@bill_from,
		instruction1=@instruction1,
		instruction2=@instruction2,
		instruction3=@instruction3,
		instruction4=@instruction4,
		instruction5=@instruction5		
	where source_counterparty_id=@counterparty_id

	IF @@ERROR<>0 
		BEGIN
			Exec spa_ErrorHandler @@ERROR, 'Counterparty Properties', 
			'spa_counterparty_properties', 'DB Error', 
			'Failed updating record.', ''
		ROLLBACK TRAN
			return
	
		END
	ELSE
		COMMIT TRAN
END

END

	If @@ERROR <> 0
		Begin
		Exec spa_ErrorHandler @@ERROR, 'Counterparty Properties', 
		'spa_counterparty_properties', 'DB Error', 
		'Failed updating record.', ''
		End
	Else
	Begin
		Exec spa_ErrorHandler 0, 'Counterparty Properties', 

		'spa_counterparty_properties', 'Success', 
		'Record successfully updated.', ''
	End

End









