IF OBJECT_ID(N'[dbo].spa_change_process_owner', N'P') IS NOT NULL
DROP PROCEDURE [dbo].spa_change_process_owner
 GO 

-- exec spa_change_process_owner 'urbaral', 'helen', 4, 's'

create procedure [dbo].spa_change_process_owner 	@from_user_login_id varchar(50),
						@to_user_login_id varchar(50),
						@type int,  --1 process_control_header, 2 process_risk_description
							   --3 is process_standard_revisions
							   --4 Roles
							   --5 Activity
						@run_type varchar(1)='s' -- 's' show report first, 'r' run
AS

if @type = 1
begin
	select 	process_id ID, 
		dbo.FNAHyperLinkText(10121500, process_name, process_id) [Group1 (Process)],
--		process_name [Group1 (Process)], 
		isnull(user_l_name, '') + ', ' + isnull(user_f_name, '') + ' ' + isnull(user_m_name, '') [Change From],
		(select isnull(user_l_name, '') + ', ' + isnull(user_f_name, '') + ' ' + isnull(user_m_name, '') 
			from application_users
			where user_login_id = @to_user_login_id) [Change To]
	into #temp
	from process_control_header pch inner join
	application_users au on au.user_login_id = pch.process_owner 
	where process_owner = @from_user_login_id

	if @run_type = 'r'
		update process_control_header set process_owner = @to_user_login_id
		where process_owner = @from_user_login_id
	
	select * from #temp
end
else if @type = 2
begin
	select 	risk_description_id ID, 
		dbo.FNAHyperLinkText(10121012, risk_description, risk_description_id) [Group2 (Risks)], 
-- 		risk_description [Group2 (Risks)], 
		isnull(user_l_name, '') + ', ' + isnull(user_f_name, '') + ' ' + isnull(user_m_name, '') [Change From],
		(select isnull(user_l_name, '') + ', ' + isnull(user_f_name, '') + ' ' + isnull(user_m_name, '') 
			from application_users
			where user_login_id = @to_user_login_id) [Change To]
	into #temp2
	from process_risk_description prd inner join
	application_users au on au.user_login_id = prd.risk_owner
	where risk_owner = @from_user_login_id
	
	if @run_type = 'r'
		update process_risk_description set risk_owner = @to_user_login_id
		where risk_owner = @from_user_login_id

	select * from #temp2

end
else if @type = 3
begin
	select 	standard_id ID, standard_description [Standard/Rules], 
		isnull(user_l_name, '') + ', ' + isnull(user_f_name, '') + ' ' + isnull(user_m_name, '') [Change From],
		(select isnull(user_l_name, '') + ', ' + isnull(user_f_name, '') + ' ' + isnull(user_m_name, '') 
			from application_users
			where user_login_id = @to_user_login_id) [Change To]
	into #temp3
	from process_standard_revisions prd inner join
	application_users au on au.user_login_id = prd.standard_owner
	where standard_owner = @from_user_login_id

	if @run_type = 'r'
		update process_standard_revisions set standard_owner = @to_user_login_id
		where standard_owner = @from_user_login_id

	select * from #temp3
end
else if @type = 4
begin

	select 	asr.role_id ID, 
		asr.role_name [Role/Group], 
		case isnull(prd.user_type, 'o') when 'p' then 'Primary' when 's' then 'Secondary' else 'Other' end [User Type],
		isnull(user_l_name, '') + ', ' + isnull(user_f_name, '') + ' ' + isnull(user_m_name, '') [Change From],
		(select isnull(user_l_name, '') + ', ' + isnull(user_f_name, '') + ' ' + isnull(user_m_name, '') 
			from application_users
			where user_login_id = @to_user_login_id) [Change To]
	into #temp4
	from application_role_user prd inner join
	application_users au on au.user_login_id = prd.user_login_id inner join
	application_security_role asr on asr.role_id = prd.role_id
	where prd.user_login_id = @from_user_login_id


	if @run_type = 'r'
		update application_role_user set user_login_id = @to_user_login_id
		where user_login_id = @from_user_login_id

	select * from #temp4
end
else if @type = 5
begin
	select 	standard_id ID, standard_description [Activity], 
		isnull(user_l_name, '') + ', ' + isnull(user_f_name, '') + ' ' + isnull(user_m_name, '') [Change From],
		(select isnull(user_l_name, '') + ', ' + isnull(user_f_name, '') + ' ' + isnull(user_m_name, '') 
			from application_users
			where user_login_id = @to_user_login_id) [Change To]
	into #temp5
	from process_standard_revisions prd inner join
	application_users au on au.user_login_id = prd.standard_owner
	where standard_owner = @from_user_login_id

	if @run_type = 'r'
		update process_standard_revisions set standard_owner = @to_user_login_id
		where standard_owner = @from_user_login_id

	select * from #temp5
END




