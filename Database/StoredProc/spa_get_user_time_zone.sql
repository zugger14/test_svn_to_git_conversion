IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'[dbo].[spa_get_user_time_zone]')
                    AND type IN ( N'P', N'PC' ) ) 
    DROP PROCEDURE [dbo].[spa_get_user_time_zone]
go
/*
spa_get_user_time_zone

*/
CREATE PROCEDURE [dbo].[spa_get_user_time_zone]
AS
BEGIN
	SELECT TIMEZONE_NAME_FOR_PHP
	FROM application_users au
		INNER JOIN time_zones tz on au.timezone_id = tz.timezone_id 
		AND au.user_login_id = dbo.FNADBUser()
END