/************************************************************
 * Code formatted by SoftTree SQL Assistant © v4.6.12
 * Time: 12/24/2012 3:36:08 PM
 ************************************************************/

IF OBJECT_ID(N'FNAGetAllEmailAdds', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAGetAllEmailAdds]
 GO
 
CREATE FUNCTION [dbo].[FNAGetAllEmailAdds]
(
	@role_id INT
)
RETURNS VARCHAR(5000)
AS
BEGIN
	DECLARE @ind_email_adds          VARCHAR(5000)
	DECLARE @spa_get_all_email_adds  VARCHAR(5000  )
	
	DECLARE a_cursor                               CURSOR  
	FOR
	    SELECT DISTINCT user_emal_add
	    FROM   application_role_user aru
	           INNER JOIN application_users au
	                ON  au.user_login_id = aru.user_login_id
	    WHERE  role_id = @role_id
	
	OPEN a_cursor
	
	FETCH NEXT FROM a_cursor
	INTO @ind_email_adds
	
	SET @spa_get_all_email_adds = ''
	WHILE @@FETCH_STATUS = 0 -- book
	BEGIN
	    IF @ind_email_adds IS NOT NULL
	    BEGIN
	        IF @spa_get_all_email_adds <> ''
	            SET @spa_get_all_email_adds = @spa_get_all_email_adds + ', '
	        
	        SET @spa_get_all_email_adds = @spa_get_all_email_adds + @ind_email_adds
	    END
	    
	    FETCH NEXT FROM a_cursor
	    INTO @ind_email_adds
	END -- end book
	CLOSE a_cursor
	DEALLOCATE a_cursor
	
	RETURN @spa_get_all_email_adds
END