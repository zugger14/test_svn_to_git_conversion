IF OBJECT_ID(N'[dbo].[spa_deal_status_privileges]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_deal_status_privileges]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2012-01-10
-- Description: CRUD operations for table deal_status_privileges

-- Params:
-- @flag CHAR(1) - Operation flag - -- i: INSERT Privileges, u: Select assigned users, r: Select assigned roles, x: List Users, y: List Roles
-- @deal_status_privileges_id INT - deal_status_privileges id
-- @user_id VARCHAR(500) - user id.
-- @role_id VARCHAR(500) - role id
-- @deal_status_id INT - deal status id
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_deal_status_privileges]
    @flag CHAR(1),
    @user_id VARCHAR(500) = NULL,
    @role_id VARCHAR(500) = NULL,
    @deal_status_id INT = NULL
AS
IF @flag = 'x'
BEGIN
    SELECT au.user_login_id
    FROM   application_users au
           LEFT OUTER JOIN deal_status_privileges dsp
                ON  au.user_login_id = dsp.[user_id]
                AND dsp.deal_status_id = @deal_status_id
    WHERE  dsp.deal_status_id IS NULL
END

IF @flag = 'y'
BEGIN
    SELECT asr.[role_id],
           asr.[role_name]
    FROM   application_security_role asr
           LEFT OUTER JOIN deal_status_privileges dsp
                ON  asr.[role_id] = dsp.[role_id]
                AND dsp.deal_status_id = @deal_status_id
    WHERE  dsp.deal_status_id IS NULL
END

IF @flag = 'u'
BEGIN
    SELECT [user_id]
    FROM   deal_status_privileges
    WHERE  deal_status_id = @deal_status_id
           AND [user_id] IS NOT NULL
END

IF @flag = 'r'
BEGIN
    SELECT asr.[role_id],
           asr.[role_name]
    FROM   deal_status_privileges dsp
           INNER JOIN application_security_role asr
                ON  asr.[role_id] = dsp.[role_id]
    WHERE  dsp.deal_status_id = @deal_status_id
           AND dsp.[role_id] IS NOT NULL
END
	
IF @flag = 'i'
BEGIN
    BEGIN TRY
    	DELETE 
    	FROM   deal_status_privileges
    	WHERE  [deal_status_id] = @deal_status_id
    	       AND [user_id] IS NOT NULL
    	
    	INSERT INTO deal_status_privileges
    	  (
    	    [user_id],
    	    [role_id],
    	    [deal_status_id]
    	  )
    	SELECT fna.item,
    	       NULL,
    	       @deal_status_id
    	FROM   dbo.SplitCommaSeperatedValues(@user_id) fna
    	       LEFT OUTER JOIN deal_status_privileges dsp
    	            ON  dsp.[user_id] = fna.item
    	            AND dsp.[deal_status_id] = @deal_status_id
    	WHERE  dsp.[deal_status_id] IS NULL
    END TRY
    BEGIN CATCH
    	IF @@ERROR <> 0
    	    EXEC spa_ErrorHandler -1,
    	         "deal_status_privileges",
    	         "spa_deal_status_privileges",
    	         "DB Error",
    	         "Failed to assign privileges for Deal Status.",
    	         ''
    	
    	RETURN
    END CATCH
    
    BEGIN TRY
    	DELETE 
    	FROM   deal_status_privileges
    	WHERE  [deal_status_id] = @deal_status_id
    	       AND [role_id] IS NOT NULL
    	
    	INSERT INTO deal_status_privileges
    	  (
    	    [user_id],
    	    [role_id],
    	    [deal_status_id]
    	  )
    	SELECT NULL,
    	       fna.item,
    	       @deal_status_id
    	FROM   dbo.SplitCommaSeperatedValues(@role_id) fna
    	       LEFT OUTER JOIN deal_status_privileges dsp
    	            ON  dsp.[role_id] = fna.item
    	            AND dsp.[deal_status_id] = @deal_status_id
    	WHERE  dsp.[deal_status_id] IS NULL
    END TRY
    BEGIN CATCH
    	IF @@ERROR <> 0
    	    EXEC spa_ErrorHandler -1,
    	         "deal_status_privileges",
    	         "spa_deal_status_privileges",
    	         "DB Error",
    	         "Failed to assign privileges for Deal Status.",
    	         ''
    	
    	RETURN
    END CATCH
    
    EXEC spa_ErrorHandler 0,
         'deal_status_privileges',
         'spa_deal_status_privileges',
         'Success',
         'Privileges successfully assigned for Deal Status.',
         ''
END