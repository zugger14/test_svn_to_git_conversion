/****** Object:  StoredProcedure [dbo].[spa_maintain_compliance_process]    Script Date: 04/15/2009 19:42:45 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_maintain_compliance_process]') AND type IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_maintain_compliance_process]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

CREATE PROCEDURE [dbo].[spa_maintain_compliance_process] 
	@flag varchar(1),
	@process_id int=NULL,
	@process_number varchar(50)=null,
	@fas_subsidiary_id int=NULL,
	@process_name varchar(50)=NULL,
	@process_internal int=NULL,
	@process_owner varchar(50)=null
AS
declare @sql_stmt varchar(5000)
if @flag = 'i'
BEGIN
	insert into process_control_header
	(process_number,fas_subsidiary_id,process_name,process_internal,process_owner, create_user, create_ts)
	values
	(@process_number,@fas_subsidiary_id,@process_name,@process_internal,@process_owner, dbo.FNADBUser(), getdate())

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Maintain Compliance Process", 
				"spa_maintain_compliance_process", "DB Error", 
				"Insert of Maintain Compliance Process data failed.", ''
	else
		Exec spa_ErrorHandler 0, 'Maintain Compliance Process', 
				'spa_maintain_compliance_process', 'Success', 
				'Maintain Compliance Process data successfully inserted.', ''

END
Else if @flag = 's' 
BEGIN

	/* removed ph.entity_name AS Subsidiary */

	set @sql_stmt='
	SELECT process_id AS ID, process_number AS
	[Group 1 (Process) Number], process_number+'' - ''+ process_name AS [Group1 (Process) Name], user_l_name +'', ''+ user_f_name Owner
	FROM process_control_header as pc left join portfolio_hierarchy as ph 
	on pc.fas_subsidiary_id=ph.entity_id  
	left outer join application_users au on pc.process_owner=au.user_login_id	
	where 1=1 '
	if @fas_subsidiary_id is not null
		set @sql_stmt=@sql_stmt +' and  ph.entity_id = '+ cast(@fas_subsidiary_id  as varchar)
	if @process_owner is not null
		set @sql_stmt=@sql_stmt +' and pc.process_owner = '''+ @process_owner +''''

	set @sql_stmt=@sql_stmt +' ORDER BY process_number'
	EXEC spa_print @sql_Stmt
	exec(@sql_stmt)
	
END
Else if @flag = 'a' 
BEGIN
	
	SELECT process_id , process_number ,fas_subsidiary_id,
	 process_name ,create_user, dbo.FNADateTimeFormat(create_ts,1) create_ts, update_user, 
	dbo.FNADateTimeFormat(update_ts,1) update_ts, process_owner
	FROM process_control_header where process_id=@process_id	
END
if @flag = 'u'
BEGIN
	update process_control_header
	set process_number=@process_number,
	fas_subsidiary_id=@fas_subsidiary_id,
	process_name=@process_name,
	process_owner=@process_owner,
	update_user = dbo.FNADBUser(),
	update_ts = getdate()
	where process_id=@process_id

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Maintain Compliance Process", 
				"spa_maintain_compliance_process", "DB Error", 
				"Insert of Maintain Compliance Process data failed.", ''
	else
		Exec spa_ErrorHandler 0, 'Maintain Compliance Process', 
				'spa_maintain_compliance_process', 'Success', 
				'Maintain Compliance Process data successfully updated.', ''

END
if @flag = 'd'
BEGIN
	delete process_control_header
	where process_id=@process_id

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Maintain Compliance Process", 
				"spa_maintain_compliance_process", "DB Error", 
				"Insert of Maintain Compliance Process data failed.", ''
	else
		Exec spa_ErrorHandler 0, 'Maintain Compliance Process', 
				'spa_maintain_compliance_process', 'Success', 
				'Maintain Compliance Process data successfully deleted.', ''
END
IF @flag = 'x'
BEGIN
	SELECT process_id AS ID,
       process_number + ' - ' + process_name AS [Group1 (process) Name]
	FROM   process_control_header AS pc
       LEFT JOIN portfolio_hierarchy AS ph ON  pc.fas_subsidiary_id = ph.entity_id
       LEFT OUTER JOIN application_users au ON  pc.process_owner = au.user_login_id
	WHERE  1 = 1
	ORDER BY process_number
END





