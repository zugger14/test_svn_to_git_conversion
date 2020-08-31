IF OBJECT_ID(N'[dbo].[spa_get_role_name]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_role_name]
GO 

---drop proc spa_get_role_name
--exec spa_get_role_name 4

-----this procedure returns Role name


CREATE PROCEDURE [dbo].[spa_get_role_name]
	@role_type_id int

AS

SELECT role_id,
       role_name
FROM   application_security_role
WHERE  role_type_value_id = @role_type_id
ORDER BY
       role_name




