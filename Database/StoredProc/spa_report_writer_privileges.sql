/*
Author : Sudeep Lamsal
Dated  : 07 Sept 2010
Desc   : Stores and verify the privileges for Report Writer.
*/


GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_report_writer_privileges]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_report_writer_privileges]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.spa_report_writer_privileges
	@flag				CHAR(1)			= NULL , -- i: INSERT Privileges, u: Select assigned users, r: Select assigned roles, x: List Users, y: List Roles
	@listuser			VARCHAR(1000)	= NULL , -- 
	@listroles			VARCHAR(1000)	= NULL , -- 
	@report_writer_id	INT				= NULL  --
	--@message			VARCHAR(100)	= NULL	 --
	
AS
SET NOCOUNT ON 
BEGIN

	DECLARE @source VARCHAR(50);
	SET @source=dbo.FNADBUser(); --sender
	
	IF @flag='i'
	BEGIN
		--IF @listuser IS NOT NULL
		--BEGIN
			BEGIN TRY
				DELETE FROM report_writer_privileges WHERE [report_writer_id]=@report_writer_id AND [user_id] IS NOT NULL
				INSERT INTO report_writer_privileges([user_id], [role_id], [report_writer_id])
				SELECT fna.item,NULL,@report_writer_id FROM dbo.SplitCommaSeperatedValues(@listuser) fna
				LEFT OUTER JOIN report_writer_privileges rwp ON	rwp.[user_id]=fna.item 
				AND rwp.[report_writer_id]=@report_writer_id
			WHERE
				rwp.[report_writer_id] IS NULL	
			END TRY
			BEGIN CATCH 
				IF @@ERROR <> 0
					EXEC spa_ErrorHandler -1, "report_writer_privileges", 
						"spa_report_writer_privileges", "DB Error", 
						"Failed to assign privileges for Report Writer.", ''
					RETURN
				 
			END CATCH
		--END
		--IF @listroles IS NOT NULL
		--BEGIN

			BEGIN TRY
				DELETE FROM report_writer_privileges WHERE [report_writer_id]=@report_writer_id AND [role_id] IS NOT NULL
				INSERT INTO report_writer_privileges([user_id], [role_id], [report_writer_id])
				SELECT NULL,fna.item,@report_writer_id
				FROM dbo.SplitCommaSeperatedValues(@listroles) fna
				LEFT OUTER JOIN report_writer_privileges rwp ON	rwp.[role_id]=fna.item 
				AND rwp.[report_writer_id]=@report_writer_id
			WHERE
				rwp.[report_writer_id] IS NULL
			END TRY
			BEGIN CATCH 
				IF @@ERROR <> 0
					EXEC spa_ErrorHandler -1, "report_writer_privileges", 
						"spa_report_writer_privileges", "DB Error", 
						"Failed to assign privileges for Report Writer.", ''
					RETURN
				 
			END CATCH
		--END

			EXEC spa_ErrorHandler 0, 'Send Message', 
				'spa_report_writer_privileges', 'Success', 
				'Privileges assigned successfully for report writer.', ''
	END
	IF @flag='u'
	BEGIN
		--print 'Select Assigned USERS'
		SELECT [user_id] FROM report_writer_privileges WHERE report_writer_id=@report_writer_id AND [user_id] IS NOT NULL 
	END
	IF @flag='r'
	BEGIN
		--print 'Select Assigned ROLES'
		SELECT asr.[role_id],asr.[role_name] FROM report_writer_privileges rwp
			INNER JOIN application_security_role asr ON asr.[role_id]= rwp.[role_id]
		WHERE rwp.report_writer_id=@report_writer_id AND rwp.[role_id] IS NOT NULL 
	END

	IF @flag='x'
	BEGIN
		--print 'Select USERS Lists not yet assigned for a individual report writer'
		SELECT au.user_login_id FROM application_users au 
			LEFT OUTER JOIN report_writer_privileges rwp ON au.user_login_id = rwp.[user_id] 
			AND rwp.report_writer_id = @report_writer_id
		WHERE  rwp.report_writer_id  IS  NULL
	END
	IF @flag='y'
	BEGIN
		--print 'Select ROLES Lists not yet assigned for a individual report writer'
		SELECT asr.[role_id],asr.[role_name] FROM application_security_role asr
			LEFT OUTER JOIN report_writer_privileges rwp ON asr.[role_id]= rwp.[role_id] 
			AND rwp.report_writer_id = @report_writer_id
		WHERE  rwp.report_writer_id IS NULL
		
	END

-- The script to delete the duplicate records in a table
--	DELETE FROM report_writer_privileges WHERE report_writer_privilege_ID IN(
--	SELECT MAX(report_writer_privilege_ID) FROM report_writer_privileges GROUP BY [user_id],[role_id],[report_writer_id] HAVING COUNT(*)>1 ) ;

END

GO
