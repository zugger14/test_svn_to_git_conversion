/****** Object:  StoredProcedure [dbo].[spa_maintain_compliance_risks]    Script Date: 04/15/2009 19:42:45 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_maintain_compliance_risks]') AND type IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_maintain_compliance_risks]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

CREATE  PROCEDURE [dbo].[spa_maintain_compliance_risks]
	@flag varchar(1),
	@risk_description_id int = null,
	@process_id int = null,
	@risk_description varchar(150) = null,
	@risk_priority int = null,
	@risk_owner varchar(50) = NULL,
	@functionId INT = NULL 
AS

SET NOCOUNT ON

declare @sql_stmt varchar(5000)
declare @risk_des_id int

if @flag = 'i'
BEGIN
	insert into process_risk_description
	(process_id, risk_description, risk_priority, risk_owner, create_user, create_ts)
	values
	(@process_id,@risk_description,@risk_priority,@risk_owner, dbo.FNADBUser(), getdate())
	
	set @risk_des_id=scope_identity()

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Maintain Compliance Risks", 
				"spa_maintain_compliance_risks", "DB Error", 
				"Insert of Maintain Compliance Risks data failed.", @risk_des_id
	else
		Exec spa_ErrorHandler 0, 'Maintain Compliance Risks', 
				'spa_maintain_compliance_risks', 'Success', 
				'Maintain Compliance Risks data successfully inserted.', @risk_des_id

END

Else if @flag = 's' 
BEGIN
	set @sql_stmt='SELECT risk_description_id ID, risk_description Description, stc.description as Priority,
						user_l_name +'', ''+ user_f_name Owner 
						 
				FROM process_risk_description pr 
				JOIN static_data_value as stc ON pr.risk_priority = stc.value_id 
				LEFT OUTER JOIN application_users au on pr.risk_owner=au.user_login_id
				where 1=1'
	
	if @process_id is not null
		set @sql_stmt=@sql_stmt +' and process_id = '+ cast(@process_id  as varchar)

   if @risk_description_id is not null
		set @sql_stmt=@sql_stmt +' and risk_description_id = '+ cast(@risk_description_id  as varchar)
	if @risk_owner is not null
		set @sql_stmt=@sql_stmt +' and risk_owner = '''+ @risk_owner +''''
    if @risk_priority is not null
		set @sql_stmt=@sql_stmt +' and stc.value_id  = '''+ cast(@risk_priority  as varchar) +''''


	set @sql_stmt=@sql_stmt +' ORDER BY risk_description'
	EXEC spa_print @sql_Stmt
	exec(@sql_stmt)
	
END

Else if @flag = 'm'		-- for mapping, filter risk description according to functionId against Process id
BEGIN
	set @sql_stmt='
				SELECT prd.risk_description_id AS [ID], prd.risk_description AS [Description], stc.description AS [Priority],
						user_l_name +'', ''+ user_f_name Owner 
				FROM process_functions pf
				JOIN process_risk_description prd ON prd.process_id = pf.process
				JOIN static_data_value as stc ON prd.risk_priority = stc.value_id 
				LEFT OUTER JOIN application_users au on prd.risk_owner=au.user_login_id
				where 1=1'
	
	if @functionId is not null
		set @sql_stmt=@sql_stmt +' and pf.functionId = '+ cast(@functionId  as varchar)


	set @sql_stmt=@sql_stmt +' ORDER BY risk_description'
	EXEC spa_print @sql_Stmt
	exec(@sql_stmt)
	
END


Else if @flag = 'a' 
BEGIN
	
	SELECT	prd.risk_description_id, prd.process_id, prd.risk_description, prd.risk_priority,
			prd.risk_owner, prd.create_user, dbo.FNADateTimeFormat(prd.create_ts,1) create_ts,
			prd.update_user,dbo.FNADateTimeFormat(prd.update_ts,1)  update_ts,psr.standard_url
	FROM process_risk_description prd 
	LEFT OUTER JOIN process_requirements_main prm on prm.requirements_id= prd.requirements_id
	LEFT OUTER JOIN process_standard_revisions psr on psr.standard_revision_id=prm.standard_revision_id
	WHERE
		 risk_description_id=@risk_description_id
END

Else if @flag = 'u'
BEGIN
	update process_risk_description
	set 
	process_id = @process_id,
	risk_description = @risk_description,
	risk_priority = @risk_priority,
	risk_owner = @risk_owner,
	update_user = dbo.FNADBUser(),
	update_ts = getdate() 
	where risk_description_id = @risk_description_id

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Maintain Compliance Risks", 
				"spa_maintain_compliance_risks", "DB Error", 
				"Update of Maintain Compliance Risks data failed.", ''
	else
		Exec spa_ErrorHandler 0, 'Maintain Compliance Risks', 
				'spa_maintain_compliance_risks', 'Success', 
				'Maintain Compliance Risks data successfully udpated.', ''
END
Else if @flag = 'd'
BEGIN
	delete process_risk_description
	where risk_description_id=@risk_description_id

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Maintain Compliance Process", 
				"spa_maintain_compliance_process", "DB Error", 
				"Insert of Maintain Compliance Process data failed.", ''
	else
		Exec spa_ErrorHandler 0, 'Maintain Compliance Process', 
				'spa_maintain_compliance_process', 'Success', 
				'Maintain Compliance Process data successfully deleted.', ''

END











