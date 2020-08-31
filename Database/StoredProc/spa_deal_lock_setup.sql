/****** Object:  StoredProcedure [dbo].[spa_deal_lock_setup]    Script Date: 12/09/2009 09:30:58 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_deal_lock_setup]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_deal_lock_setup]
GO
CREATE PROC [dbo].[spa_deal_lock_setup]
@flag AS CHAR(1),
@id INT = NULL,
@role_id INT = NULL,
@deal_type_id INT = NULL,
@hour INT = NULL,
@minute INT = NULL,
@create_ts DATETIME = NULL,
@create_user VARCHAR(100) = NULL
AS 

DECLARE @sql_stmt VARCHAR(8000)
DECLARE @dt DATETIME
SET @dt=getdate()
SET @create_ts=@dt
SET @create_user = dbo.FNADBUser()

IF @flag = 's'
BEGIN 
	SELECT @sql_stmt = '
	SELECT dls.id AS [Id], asr.role_name AS [Role Name], sdt.deal_type_id AS [Deal Type], 
	dls.hour AS [Hour], dls.minute AS [Minute], dls.create_user [Created User]
	FROM deal_lock_setup dls
	LEFT JOIN application_security_role asr ON asr.role_id = dls.role_id 
	LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = dls.deal_type_id
	WHERE 1=1 '
	
	exec spa_print @sql_stmt
	
	EXEC(@sql_stmt)
	
	
END 
IF @flag = 'g'
BEGIN 
	SELECT dls.id,
		asr.role_id, 
		dls.deal_type_id, 
		dls.hour,
		dls.minute
	FROM deal_lock_setup dls
	LEFT JOIN application_security_role asr ON asr.role_id = dls.role_id 
	LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = dls.deal_type_id
	WHERE 1=1
END 

ELSE IF @flag = 'a'
BEGIN
	SELECT id, role_id, deal_type_id, hour, minute 
	FROM deal_lock_setup WHERE id = @id 
	
END 

ELSE IF @flag = 'i'
BEGIN 
	IF EXISTS( SELECT 'x' FROM deal_lock_setup WHERE role_id=@role_id AND isnull(deal_type_id,-1)=isnull(@deal_type_id,-1))
	BEGIN
		Exec spa_ErrorHandler -1, 'Cannot insert duplicate deal type for the same role.', 
				'spa_deal_lock_setup', 'DB Error', 
				'Cannot insert duplicate deal lock information.', ''
		RETURN
		
	END
	
	INSERT INTO deal_lock_setup (role_id, deal_type_id, hour, minute, create_ts, create_user) 
				VALUES (@role_id, @deal_type_id, @hour, @minute, @create_ts, @create_user)
				
	
	If @@ERROR <> 0
	BEGIN 
		Exec spa_ErrorHandler @@ERROR, 'Insert Deal Lock Setup Failed.', 
				'spa_deal_lock_setup', 'DB Error', 
				'Insert Deal Lock Setup Failed.', ''
		RETURN
	END
	ELSE Exec spa_ErrorHandler 0, 'Insert Deal Lock Setup Sucessfully.', 
				'spa_deal_lock_setup', 'Success', 
				'Insert Deal Lock Setup Sucessfully.',''
								
END 

ELSE IF @flag = 'u'
BEGIN 
	IF EXISTS( SELECT 'x' FROM deal_lock_setup WHERE role_id=@role_id AND isnull(deal_type_id,-1)=isnull(@deal_type_id,-1) AND id!=@id)
	BEGIN
		Exec spa_ErrorHandler -1, 'Cannot insert duplicate deal type for the same role.', 
				'spa_deal_lock_setup', 'DB Error', 
				'Cannot insert duplicate deal lock information.', ''
		RETURN
		
	END
	UPDATE deal_lock_setup SET 
			role_id = @role_id, 
			deal_type_id = @deal_type_id, 
			hour = @hour, 
			minute = @minute,
			create_ts = @create_ts,
			create_user = @create_user
	WHERE id = @id 
	
	If @@ERROR <> 0
	BEGIN 
		Exec spa_ErrorHandler @@ERROR, 'Update Deal Lock Setup Failed.', 
				'spa_deal_lock_setup', 'DB Error', 
				'Update Deal Lock Setup Failed.', ''
		RETURN
	END
	ELSE Exec spa_ErrorHandler 0, 'Update Deal Lock Setup Sucessfully.', 
				'spa_deal_lock_setup', 'Success', 
				'Update Deal Lock Setup Sucessfully.',''
END 

ELSE IF @flag = 'd'
BEGIN 
	DELETE FROM deal_lock_setup WHERE id = @id 
	
	If @@ERROR <> 0
	BEGIN 
		Exec spa_ErrorHandler @@ERROR, 'Delete Deal Lock Setup Failed.', 
				'spa_deal_lock_setup', 'DB Error', 
				'Delete Deal Lock Setup Failed.', ''
		RETURN
	END
	ELSE Exec spa_ErrorHandler 0, 'Delete Deal Lock Setup Sucessfully.', 
				'spa_deal_lock_setup', 'Success', 
				'Delete Deal Lock Setup Sucessfully.',''
				
				
END 