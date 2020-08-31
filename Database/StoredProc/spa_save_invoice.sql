/****** Object:  StoredProcedure [dbo].[spa_save_invoice]    Script Date: 01/05/2010 14:19:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_save_invoice]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_save_invoice]
/****** Object:  StoredProcedure [dbo].[spa_save_invoice]    Script Date: 01/05/2010 14:19:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_save_invoice]
	@flag char(1),
	@save_invoice_id int=NULL,
	@counterparty_id int=NULL,
	@as_of_date  varchar(50)=NULL,
	@term_month varchar(50)=NULL,
	@invoice_number varchar(50)=NULL,
	@comment1 varchar(250)=NULL,
	@comment2 varchar(250)=NULL,
	@comment3 varchar(250)=NULL,
	@comment4 varchar(250)=NULL,
	@comment5 varchar(250)=NULL,
	@status INT =20700,
	@invoice_notes VARCHAR(5000) = NULL
AS 
DECLARE @Sql_st as varchar(max)

IF @flag='s'
BEGIN
	SET @Sql_st=
		'select Save_invoice_id [Invoice ID],  dbo.FNADateFormat(as_of_date)  [As Of Date],  dbo.FNADateFormat(term_month)  [Production Month],  invoice_number  [Invoice Number], 
		sdv.code Status, Comment1, Comment2,
		si.create_user [Created By],si.create_ts [Created TS],si.update_user [Updated By],si.update_ts [Update TS] 
		FROM  save_invoice si
			LEFT JOIN dbo.static_data_value sdv ON sdv.value_id = si.[status]
		WHERE counterparty_id =' + cast(@counterparty_id as varchar)

	IF @term_month is not null
	BEGIN
		set @Sql_st = @Sql_st + 'AND YEAR(term_month)='''+ CAST(YEAR(@term_month) as varchar) +''' AND MONTH(term_month)='''+ CAST(MONTH(@term_month) as varchar) +''''
	END

	SET @Sql_st = @Sql_st + 'Order by Save_invoice_id desc'

  -- print(@Sql_st)
	EXEC (@Sql_st)
END

IF @flag='r'
BEGIN
	SELECT 
		si.Save_invoice_id [Invoice ID],  
		dbo.FNADateFormat(si.as_of_date)  [As Of Date],  
		dbo.FNADateFormat(si.term_month)  [Production Month],  
		si.invoice_number  [Invoice Number], 
		sdv.code Status, 
		Comment1 AS [Comment 1], Comment2 AS [Comment 2],
		si.create_user [Created By],
		si.create_ts [Created TS],
		si.update_user [Updated By],
		si.update_ts [Update TS] 
	FROM
		save_invoice si
		LEFT JOIN dbo.static_data_value sdv ON sdv.value_id = si.[status]
	WHERE invoice_number = @invoice_number
	ORDER BY Save_invoice_id DESC
END

IF @flag='a'
BEGIN
	SELECT
		Save_invoice_id [Invoice ID],
		counterparty_id,
		dbo.FNADateFormat(as_of_date)  [As Of Date],  
		dbo.FNADateFormat(term_month)  [Production Month],  
		invoice_number  [Invoice Number], 
		[Status], 
		Comment1 [Comment 1], 
		Comment2 [Comment 2], Comment3 [Comment 3], Comment4 [Comment 4], Comment5 [Comment 5],invoice_notes [Invoice Notes]
	 FROM 
		save_invoice
	WHERE
		Save_invoice_id = @Save_invoice_id

END
IF @flag='u'
BEGIN
	UPDATE save_invoice
	SET
		as_of_date=@as_of_date,
		term_month=@term_month,
		[Status]=@Status,
		Comment1=@Comment1,
		Comment2=@Comment2,
		Comment3=@Comment3,
		Comment4=@Comment4,
		Comment5=@Comment5,
		invoice_notes = @invoice_notes
	WHERE Save_invoice_id=@Save_invoice_id
	IF @@ERROR <> 0
				EXEC spa_ErrorHandler @@ERROR, "Save Invoice", 
						"spa_save_invoice", "DB Error", 
					"Error on updating Invoice Saved.", ''
	ELSE
				EXEC spa_ErrorHandler 0, 'Save Invoice', 
						'spa_save_invoice', 'Success', 
						'Invoice Saved  successfully Updated.',''
END






