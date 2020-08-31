IF OBJECT_ID(N'spa_source_internal_desk', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_source_internal_desk]
GO
 
/*

[spa_source_internal_desk] 's'
[spa_source_internal_desk] 'a',10
[spa_source_internal_desk] 'u',10,2,'test','test','test'
[spa_source_internal_desk] 'a',10
[spa_source_internal_desk] 'i',null,2,'test1','test1','test1'
[spa_source_internal_desk] 's'



*/
CREATE PROC [dbo].[spa_source_internal_desk]	
	@flag AS CHAR(1),					
	@source_internal_desk_id INT = NULL,
	@source_system_id INT = NULL,
	@internal_desk_id VARCHAR(50) = NULL,
	@internal_desk_name VARCHAR(100) = NULL,
	@internal_desk_desc VARCHAR(250) = NULL,
	@strategy_id INT = NULL
AS
SET NOCOUNT ON 
DECLARE @Sql_Select VARCHAR(5000)

IF @flag = 'i'
BEGIN
    DECLARE @count VARCHAR(100)
	SELECT  @count= count(*) FROM source_internal_desk WHERE internal_desk_id=@internal_desk_id AND source_system_id=@source_system_id
	IF (@count>0)
	BEGIN
	BEGIN
		select 'Error', 'Internal Desk ID must be unique', 
			'spa_application_security_role', 'DB Error', 
			'Internal Desk ID must be unique', ''
		RETURN
	END
	END

	INSERT INTO source_internal_desk
		(
			source_system_id
			,internal_desk_id
			,internal_desk_name
			,internal_desk_desc
			,create_user
			,create_ts
			,update_user
			,update_ts
		)
	VALUES
		(				
			@source_system_id
			,@internal_desk_id
			,@internal_desk_name
			,@internal_desk_desc
			,dbo.FNADBUser()
			,GETDATE()
			,dbo.FNADBUser()
			,GETDATE()
		)
		
		SET @source_internal_desk_id = SCOPE_IDENTITY()

		IF @@Error <> 0
		EXEC spa_ErrorHandler @@Error,
		     'source_internal_desk',
		     'spa_source_internal_desk',
		     'DB Error',
		     'Failed to insert value.',
		     ''
		ELSE
		EXEC spa_ErrorHandler 0,
		     'source_internal_desk',
		     'spa_source_internal_desk',
		     'Success',
		     'source_internal_desk data value inserted.',
		     @source_internal_desk_id
END
ELSE IF @flag = 'a' 
BEGIN
	SELECT source_internal_desk_id,
	       source_system_description.source_system_name,
	       internal_desk_id,
	       internal_desk_name,
	       internal_desk_desc
	FROM   source_internal_desk s
	       INNER JOIN source_system_description ON source_system_description.source_system_id = s.source_system_id
	WHERE  source_internal_desk_id = @source_internal_desk_id
	
	
	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR,
	         'source_internal_desk table',
	         'spa_source_internal_desk',
	         'DB Error',
	         'Failed to select source_internal_desk detail record.',
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'source_internal_desk table',
	         'spa_source_internal_desk',
	         'Success',
	         'source_internal_desk detail record successfully selected.',
	         @source_internal_desk_id
END

ELSE IF @flag = 's' 
BEGIN
	SET  @Sql_Select='select
		source_internal_desk_id IDS,
		internal_desk_name + CASE WHEN source_system_description.source_system_id=2 THEN '''' ELSE ''.'' + source_system_description.source_system_name END AS Name,
		internal_desk_desc Description,
		source_system_description.source_system_name System,
		dbo.FNADateTimeFormat(s.create_ts,1) [Created Date],
		s.create_user [Created User],		
		dbo.FNADateTimeFormat(s.update_ts,1) [Updated Date] ,
		s.update_user [Updated User]
		from source_internal_desk s
		inner join source_system_description on
			source_system_description.source_system_id = s.source_system_id 
'
	IF @strategy_id IS NOT NULL 
		SET  @Sql_Select=@Sql_Select +  ' inner join fas_strategy fs on fs.source_system_id = source_system_description.source_system_id where fs.fas_strategy_id='+CAST(@strategy_id AS VARCHAR)


	IF @source_system_id IS NOT NULL AND @strategy_id IS NOT NULL
		SET @Sql_Select = @Sql_Select + ' and s.source_system_id=' + CONVERT(VARCHAR(20), @source_system_id) + ''

	IF @source_system_id IS NOT NULL AND @strategy_id IS NULL
		SET @Sql_Select = @Sql_Select + ' where s.source_system_id=' + CONVERT(VARCHAR(20), @source_system_id) + ''	

	SET @Sql_Select = @Sql_Select + ' order by internal_desk_name'

	EXEC (@SQL_select)
END
ELSE IF @flag = 'l' --list in grid .. without suffixing source system id.
begin
set @Sql_Select='select
		source_internal_desk_id IDS,
		internal_desk_name AS Name,
		internal_desk_desc Description,
			source_system_description.source_system_name System,
		dbo.FNADateTimeFormat(s.create_ts,1) [Created Date],
		s.create_user [Created User],
		dbo.FNADateTimeFormat(s.update_user,1) [Updated Date],
		s.update_ts [Updated User] 
	from source_internal_desk s
	 inner join source_system_description on
		source_system_description.source_system_id = s.source_system_id 
	order by internal_desk_name
'


	if @source_system_id is not null 
		set @Sql_Select=@Sql_Select +  ' where s.source_system_id='+convert(varchar(20),@source_system_id)+''
	exec(@SQL_select)
end

ELSE IF @flag = 'u'
BEGIN
	DECLARE @count1 VARCHAR(100)
	SELECT @count1 = COUNT(*)
	FROM   source_internal_desk
	WHERE  internal_desk_id = @internal_desk_id
	       AND source_system_id = @source_system_id
	       AND source_internal_desk_id <> @source_internal_desk_id
	IF (@count1 > 0)
	BEGIN
		SELECT 'Error',
		       'Internal Desk ID must be unique',
		       'spa_application_security_role',
		       'DB Error',
		       'Internal Desk ID must be unique',
		       ''
		RETURN
	END

	UPDATE source_internal_desk
	SET    internal_desk_id = @internal_desk_id,
	       internal_desk_name = @internal_desk_name,
	       internal_desk_desc = @internal_desk_desc,
	       update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	WHERE  source_internal_desk_id = @source_internal_desk_id

	IF @@Error <> 0
	    EXEC spa_ErrorHandler @@Error,
	         'source_internal_desk',
	         'spa_source_internal_desk',
	         'DB Error',
	         'Failed to update source_internal_desk.',
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'source_internal_desk',
	         'spa_source_internal_desk',
	         'Success',
	         'source_internal_desk data value updated.',
	         ''
END
ELSE IF @flag = 'd'
BEGIN
	DELETE 
	FROM   source_internal_desk
	WHERE  source_internal_desk_id = @source_internal_desk_id
	
	EXEC spa_maintain_udf_header 'd', NULL, @source_internal_desk_id
	
	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR,
	         "source_internal_desk",
	         "spa_source_internal_desk",
	         "DB Error",
	         "Delete of source_internal_desk Data failed.",
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'source_internal_desk',
	         'spa_source_internal_desk',
	         'Success',
	         'source_internal_desk Data sucessfully deleted',
	         ''
END
ELSE IF @flag = 'g'
BEGIN
	SELECT source_internal_desk_id IDS
		, internal_desk_name  Name
	FROM source_internal_desk
END












