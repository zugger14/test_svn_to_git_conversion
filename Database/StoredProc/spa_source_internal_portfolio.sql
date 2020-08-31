IF OBJECT_ID('[dbo].[spa_source_internal_portfolio]','p') IS NOT NULL 
DROP PROCEDURE [dbo].[spa_source_internal_portfolio]
 GO 



/*



[spa_source_internal_portfolio] 's'
[spa_source_internal_portfolio] 'a',10
[spa_source_internal_portfolio] 'u',10,2,'test','test','test'
[spa_source_internal_portfolio] 'a',10
[spa_source_internal_portfolio] 'i',null,2,'test1','test1','test1'
[spa_source_internal_portfolio] 's'


*/









CREATE proc [dbo].[spa_source_internal_portfolio]	@flag as Char(1),					
	@source_internal_portfolio_id int=null,
	@source_system_id int=null,
	@internal_portfolio_id varchar(50)=null,
	@internal_portfolio_name varchar(100)=null,
	@internal_portfolio_desc varchar(250)=null,
						@strategy_id INT = NULL
AS 
Declare @Sql_Select varchar(5000)

if @flag = 'i'
begin
	declare @count varchar(100)
	select @count= count(*) from source_internal_portfolio where internal_portfolio_id =@internal_portfolio_id  AND source_system_id=@source_system_id
	if (@count>0)
	BEGIN
		select 'Error', 'Internal Portfolio ID must be unique', 
			'spa_application_security_role', 'DB Error', 
			'Internal Portfolio ID must be unique', ''
		RETURN
	END
       INSERT INTO source_internal_portfolio
		(
			source_system_id
			,internal_portfolio_id
			,internal_portfolio_name
			,internal_portfolio_desc
			,create_user
			,create_ts
			,update_user
			,update_ts
		)
	values
		(				
			@source_system_id
			,@internal_portfolio_id
			,@internal_portfolio_name
			,@internal_portfolio_desc
			,dbo.FNADBUser()
			,GETDATE()
			,dbo.FNADBUser()
			,GETDATE()
		)
		
		SET @source_internal_portfolio_id = SCOPE_IDENTITY()

		IF @@Error <> 0
		    EXEC spa_ErrorHandler @@Error,
		         'source_internal_portfolio',
		         'spa_source_internal_portfolio',
		         'DB Error',
		         'Failed to insert value.',
		         ''
		ELSE
		    EXEC spa_ErrorHandler 0,
		         'source_internal_portfolio',
		         'spa_source_internal_portfolio',
		         'Success',
		         'source_internal_portfolio data value inserted.',
		         @source_internal_portfolio_id
end

else if @flag='a' 
begin
	select 
		source_internal_portfolio_id,
		source_system_description.source_system_name,
		internal_portfolio_id,
		internal_portfolio_name,
		internal_portfolio_desc
	from source_internal_portfolio s
	 inner join source_system_description on
		source_system_description.source_system_id = s.source_system_id 
	where source_internal_portfolio_id=@source_internal_portfolio_id
	

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'source_internal_portfolio table', 
				'spa_source_internal_portfolio', 'DB Error', 
				'Failed to select source_internal_portfolio detail record.', ''
	Else
		Exec spa_ErrorHandler 0, 'source_internal_portfolio table', 
				'spa_source_internal_portfolio', 'Success', 
				'source_internal_portfolio detail record successfully selected.', ''
end

else if @flag='s' 
begin
set @Sql_Select='select
		source_internal_portfolio_id ID,
		internal_portfolio_name + CASE WHEN source_system_description.source_system_id=2 THEN '''' ELSE ''.'' + source_system_description.source_system_name END AS Name
	    from source_internal_portfolio s
	    inner join source_system_description on
			source_system_description.source_system_id = s.source_system_id
	
'
	if @strategy_id is not null 
		set @Sql_Select=@Sql_Select +  ' inner join fas_strategy fs on fs.source_system_id = source_system_description.source_system_id where fs.fas_strategy_id='+CAST(@strategy_id AS VARCHAR)

	if @source_system_id is not null and @strategy_id is not null
		set @Sql_Select=@Sql_Select +  ' and s.source_system_id='+convert(varchar(20),@source_system_id)+''

	if @source_system_id is not null and @strategy_id is null
		set @Sql_Select=@Sql_Select +  ' where s.source_system_id='+convert(varchar(20),@source_system_id)+''
	
	set @Sql_Select=@Sql_Select +  ' order by internal_portfolio_name'
	exec(@SQL_select)
end
else if @flag='l'  --list in grid .. without suffixing source system id.
begin
set @Sql_Select='select
		source_internal_portfolio_id ID,
		internal_portfolio_name AS Name,
		internal_portfolio_desc Description,
			source_system_description.source_system_name System,
		s.create_ts [Created Date],
		s.create_user [Created User],
		dbo.FNADateTimeFormat(s.update_user,1) [Updated Date],
		s.update_ts [Updated User] 
	from source_internal_portfolio s
	 inner join source_system_description on
		source_system_description.source_system_id = s.source_system_id
	order by internal_portfolio_name
'


	if @source_system_id is not null 
		set @Sql_Select=@Sql_Select +  ' where s.source_system_id='+convert(varchar(20),@source_system_id)+''
	exec(@SQL_select)
end
Else if @flag = 'u'
begin
	declare @cont varchar(100)
	select @cont= count(*) from source_internal_portfolio where internal_portfolio_id =@internal_portfolio_id AND source_system_id=@source_system_id AND source_internal_portfolio_id <> @source_internal_portfolio_id
	if (@cont>0)
	BEGIN
		SELECT 'Error', 'Internal Portfolio ID must be unique', 
			'spa_application_security_role', 'DB Error', 
			'Internal Portfolio ID must be unique', ''
		RETURN
	END

	UPDATE source_internal_portfolio
	SET    internal_portfolio_id = @internal_portfolio_id,
	       internal_portfolio_name = @internal_portfolio_name,
	       internal_portfolio_desc = @internal_portfolio_desc,
	       update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	WHERE  source_internal_portfolio_id = @source_internal_portfolio_id

	IF @@Error <> 0
	    EXEC spa_ErrorHandler @@Error,
	         'source_internal_portfolio',
	         'spa_source_internal_portfolio',
	         'DB Error',
	         'Failed to update source_internal_portfolio.',
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'source_internal_portfolio',
	         'spa_source_internal_portfolio',
	         'Success',
	         'source_internal_portfolio data value updated.',
	         @source_internal_portfolio_id
end

Else if @flag = 'd'
BEGIN
	DELETE 
	FROM   source_internal_portfolio
	WHERE  source_internal_portfolio_id = @source_internal_portfolio_id

	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR,
	         "source_internal_portfolio",
	         "spa_source_internal_portfolio",
	         "DB Error",
	         "Delete of source_internal_portfolio Data failed.",
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'source_internal_portfolio',
	         'spa_source_internal_portfolio',
	         'Success',
	         'source_internal_portfolio Data sucessfully deleted',
	         @source_internal_portfolio_id
END