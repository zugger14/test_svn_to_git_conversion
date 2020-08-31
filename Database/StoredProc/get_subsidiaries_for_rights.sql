IF OBJECT_ID(N'get_subsidiaries_for_rights', N'P') IS NOT NULL
DROP PROCEDURE dbo.get_subsidiaries_for_rights
 GO 

-----this procedure returns only subsidiaries that the user has rights for a passed function_id

CREATE PROCEDURE dbo.get_subsidiaries_for_rights @function_id int
as

If dbo.FNAAppAdminRoleCheck(dbo.FNADBUser()) = 1
begin
	select entity_id, entity_name from portfolio_hierarchy where entity_type_value_id  = 525 and entity_id<>-1
end
else
begin

	select distinct ph.entity_id, ph.entity_name from portfolio_hierarchy ph right outer join
	(
		SELECT  distinct application_functional_users.entity_id AS entity_id 
		FROM       application_users INNER JOIN
		           application_functional_users ON application_users.user_login_id = application_functional_users.login_id
		WHERE      application_functional_users.function_id = @function_id AND 	   
			   application_functional_users.role_user_flag = 'u' AND 
			   application_users.user_login_id = dbo.FNADBUser() 
		UNION 
		
		SELECT     distinct  application_functional_users.entity_id AS entity_id
		FROM       application_users INNER JOIN
		           application_role_user ON application_users.user_login_id = application_role_user.user_login_id INNER JOIN
		           application_functional_users ON application_role_user.role_id = application_functional_users.role_id
		WHERE      application_functional_users.role_user_flag = 'r'
		 AND 	   application_users.user_login_id = dbo.FNADBUser() 
		 AND        application_functional_users.function_id  = @function_id
	) er
	on isnull(er.entity_id, ph.entity_id) = ph.entity_id
where ph.entity_type_value_id  = 525
and ph.entity_id<>-1
end






