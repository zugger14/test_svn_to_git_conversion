/****** Object:  StoredProcedure [dbo].[spa_interface_Adapter_email]    Script Date: 02/11/2010 16:30:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_interface_Adapter_email]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_interface_Adapter_email]
/****** Object:  StoredProcedure [dbo].[spa_interface_Adapter_email]    Script Date: 02/11/2010 16:31:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

CREATE procedure  [dbo].[spa_interface_Adapter_email]
@process_id varchar(50),
@cust_id int,
@message_board varchar(5000),
	@msg varchar(5000)='',
	@url_body varchar(5000)='',
@attachment_file_name VARCHAR(1000) = NULL
AS

--************************************
--declare @process_id varchar(50),@cust_id int,@message_board varchar(5000),@msg varchar(5000)
--
--set @process_id='test'
--set @cust_id=1
--set @message_board='summarry test'
--set @msg='description test'
--*************************************


declare @sub varchar(500)
declare @body varchar(5000)
declare @user_login_id varchar(50)
select @sub=email_subject,@body=email_body from admin_email_configuration where cust_id=@cust_id

set @sub=replace(@sub,'<fas_subject>',@message_board)

if isnull(@url_body,'')=''
begin
set @body=replace(@body,'<fas_summary>',@message_board)
set @body=replace(@body,'<fas_description>',@msg)
set @body=replace(@body,'<fas_date>',cast(convert(datetime,getdate(),13) as varchar))
end
else
	set @body=@message_board+ '  <a target="_blank" href="' + @url_body + '">Click here to view details</a>'


	INSERT INTO [email_notes]
		   ([internal_type_value_id],[category_value_id],notes_object_name,notes_object_id,[send_status],active_flag
			,[notes_subject]
		   ,[notes_text]
		   ,[send_from]
		   ,[send_to]
		,[attachment_file_name]
   )
	 select
			max(2),max(4),max('lll'),max(1),max('n'),max('y')
			,max(@sub)
		   ,max(@body)
	   ,max('no-reply@pioneersolutions.us')
			,user_emal_add
		,@attachment_file_name
	FROM  dbo.application_role_user INNER JOIN
			   dbo.application_security_role ON dbo.application_role_user.role_id = dbo.application_security_role.role_id INNER JOIN
			   dbo.application_users ON dbo.application_role_user.user_login_id = dbo.application_users.user_login_id
	WHERE (dbo.application_users.user_active = 'y') AND (dbo.application_security_role.role_type_value_id =2) and  dbo.application_users.user_emal_add  is not null
	GROUP BY dbo.application_users.user_login_id,  dbo.application_users.user_emal_add


DECLARE list_user CURSOR FOR 
select application_users.user_login_id	FROM  dbo.application_role_user INNER JOIN
			   dbo.application_security_role ON dbo.application_role_user.role_id = dbo.application_security_role.role_id INNER JOIN
			   dbo.application_users ON dbo.application_role_user.user_login_id = dbo.application_users.user_login_id
	WHERE (dbo.application_users.user_active = 'y') AND (dbo.application_security_role.role_type_value_id =2)
	GROUP BY dbo.application_users.user_login_id,  dbo.application_users.user_emal_add
OPEN list_user

FETCH NEXT FROM list_user INTO 	@user_login_id
WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC spa_print @user_login_id

	Declare @url varchar(500)
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
		'&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''

	select @message_board = '<a target="_blank" href="' + @url + '">' + 
				@message_board +
			'.</a>'

	EXEC  spa_message_board 'i', @user_login_id,
				NULL, 'Import.Data',
				@message_board, '', '', 'e', 'Interface Adaptor'
FETCH NEXT FROM list_user INTO 	@user_login_id
end
CLOSE list_user
DEALLOCATE list_user



