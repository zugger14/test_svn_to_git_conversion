/****** Object:  StoredProcedure [dbo].[spa_manual_je_header]    Script Date: 12/20/2009 17:18:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_manual_je_header]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_manual_je_header]
/****** Object:  StoredProcedure [dbo].[spa_manual_je_header]    Script Date: 12/20/2009 17:18:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spa_manual_je_header] @flag char(1),@manual_je_id int=null, @as_of_date datetime=null, @book_id int=null, @frequency char(1)=null, @until_date datetime=null, @dr_cr_match char(1)=null

 AS 

declare @msg_err varchar(2000) 
DECLARE @SQL VARCHAR(MAX)

Begin try

	If @flag='i'

		insert into [manual_je_header] (as_of_date, book_id, frequency, until_date, dr_cr_match) values (@as_of_date, @book_id, @frequency, @until_date, @dr_cr_match)

	else If @flag='u'

		update [manual_je_header] 
		set 
			as_of_date=@as_of_date, 
			book_id=@book_id, 
			frequency=@frequency,
			until_date=@until_date, 
			dr_cr_match=@dr_cr_match
		WHERE
			manual_je_id=@manual_je_id

	else If @flag='d'

		DELETE [manual_je_header] 
		WHERE	
			manual_je_id=@manual_je_id

	else If @flag='a'

		select 
			manual_je_id, 
			dbo.FNACovertToSTDDate(as_of_date) as_of_Date,
			book_id,
			ph.entity_name as [book_name],
			frequency,
			dbo.FNACovertToSTDDate(until_date),
			dr_cr_match 
		from 
			[manual_je_header]  mjh
			LEFT JOIN portfolio_hierarchy ph ON ph.entity_id=mjh.book_id
		WHERE	
			manual_je_id=@manual_je_id

	else If @flag='s'
		BEGIN
			SET @SQL=	
				'select 
					manual_je_id, 
					dbo.FNADateformat(as_of_date) [As of Date], 
					CASE WHEN frequency=''o'' then ''One Time'' ELSE ''Reoccuring'' END AS [Occurance Frequency], 
					dbo.FNADateformat(until_date) [Occur Until], 
					dr_cr_match [Dr Should Match Cr], 
					ph.entity_name [Book]
				from 
					[manual_je_header] a
					LEFT JOIN portfolio_hierarchy ph ON ph.entity_id=a.book_id
				WHERE 1=1'
					+ CASE WHEN @as_of_date IS NOT NULL THEN ' AND as_of_date='''+CAST(@as_of_date AS VARCHAR)+'''' ELSE '' END
			EXEC(@SQL)
		END

 
	DECLARE @msg varchar(2000)
	SELECT @msg=''
	if @flag='i'
		SET @msg='Data Successfully Inserted.'
	ELSE if @flag='u'
		SET @msg='Data Successfully Updated.'
	ELSE if @flag='d'
		SET @msg='Data Successfully Deleted.'

	IF @msg<>''
		select 'Success', 'manual_je_headertable', 
				'spa_manual_je_header', 'Success', 
				@msg, ''
END try
begin catch
	DECLARE @error_number int
	SET @error_number=error_number()
	SET @msg_err=''


	if @flag='i'
		SET @msg_err='Fail Insert Data.'
	ELSE if @flag='u'
		SET @msg_err='Fail Update Data.'
	ELSE if @flag='d'
		SET @msg_err='Fail Delete Data.'
	SET @msg_err='Fail Delete Data (' + error_message() +')'
		select 'Error', @msg_err, 
				'spa_manual_je_header', 'DB Error', 
				@msg_err, ''


END catch
