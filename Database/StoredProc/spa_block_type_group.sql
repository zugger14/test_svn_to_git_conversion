/****** Object:  StoredProcedure [dbo].[spa_block_type_group]    Script Date: 10/26/2009 09:04:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_block_type_group]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_block_type_group]
/****** Object:  StoredProcedure [dbo].[spa_block_type_group]    Script Date: 10/26/2009 09:05:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spa_block_type_group] 
	@flag char(1)
	,@id int=NULL
	,@block_type_group_id int=NULL
	,@block_type_id int=NULL
	,@block_name varchar(100)=NULL
	,@hourly_block_id int=null
 AS 
declare @msg_err varchar(2000) 
Begin try
	If @flag='i'
		insert into [block_type_group] (block_type_group_id, block_type_id, block_name, hourly_block_id) values (@block_type_group_id, @block_type_id, @block_name, @hourly_block_id)
	else If @flag='u'
		update [block_type_group] set block_type_group_id=@block_type_group_id, block_type_id=@block_type_id, block_name=@block_name, hourly_block_id=@hourly_block_id where id=@id
	else If @flag='d'
		delete [block_type_group]  where id=@id
	else If @flag='a'

		select id, block_type_group_id, block_type_id, block_name, hourly_block_id from [block_type_group]  where id=@id

	else If @flag='s'
		select 
			id, 
			block_name [Block Name], 
			btg.hourly_block_id AS [Hourly Block],
			btg.block_type_id [Block Type]
			
		from
			[block_type_group]  btg
			--LEFT JOIN static_data_value bt ON bt.value_id=btg.block_type_id
			--LEFT JOIN static_data_value hb ON hb.value_id=btg.hourly_block_id
		where 
			block_type_group_id=@block_type_group_id	ELSE IF @flag = 'l'		SELECT 
			--id, 
			--block_type_group_id, 
			block_name [Block Name], 
			--bt.code [Block Type], 
			hb.code AS [Hourly Block] 
		FROM
			[block_type_group]  btg
			LEFT JOIN static_data_value bt ON bt.value_id=btg.block_type_id
			LEFT JOIN static_data_value hb ON hb.value_id=btg.hourly_block_id
		WHERE 
			block_type_group_id=@block_type_group_id
	DECLARE @msg varchar(2000)
	SELECT @msg=''
	if @flag='i'
		SET @msg='Data Successfully Inserted.'
	ELSE if @flag='u'
		SET @msg='Data Successfully Updated.'
	ELSE if @flag='d'
		SET @msg='Data Successfully Deleted.'

	IF @msg<>''
		select 'Success', 'block_type_grouptable', 
				'spa_block_type_group', 'Success', 
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
		select 'Error', 'block_type_grouptable', 
				'spa_block_type_group', 'DB Error', 
				@msg_err, ''


END catch
