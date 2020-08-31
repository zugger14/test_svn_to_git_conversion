
IF OBJECT_ID(N'[dbo].[spa_maintain_portfolio_group]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_maintain_portfolio_group]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: sangam@pioneersolutionsglobal.com
-- Create date: 6/28/2012
-- portfolio_group_description: Maintain portfolio group operations 

-- Params:
-- @flag CHAR(1) - Operation flag
-- @portfolio_group_id int - portfolio_group_id of the entry
-- @portfolio_group_name varchar(500) - portfolio_group_name of the group
-- @portfolio_group_description varchar(1000) - portfolio_group_description of the person
-- @user - user of the entry data
-- @role - role of the entry data 
-- @is_public - defines the public entry or not
-- @is_active - defines the active entry or not      
-- ============================  v    ===============================================================================

CREATE PROCEDURE [dbo].[spa_maintain_portfolio_group]
	@flag CHAR(1),
	@portfolio_group_id INT = NULL ,
	@portfolio_group_name VARCHAR(500) = NULL ,
	@portfolio_group_description VARCHAR(1000) = NULL,
	@user VARCHAR(250) = NULL,
	@role VARCHAR(250) = NULL,
	@is_public CHAR(1) = NULL,
	@is_active CHAR(1) = NULL,
	@users VARCHAR(100) = NULL,
	@form_xml TEXT = NULL,
	@portfolio_xml TEXT = NULL,
	--for multiple delete
	@del_portfolio_group_id VARCHAR(MAX) = NULL
AS
SET NOCOUNT ON

DECLARE @sql VARCHAR(MAX)
DECLARE @portfolio_mapping_source INT = 23202 --Portfolio Group Mapping Source

IF @flag = 's'
BEGIN
    SELECT [portfolio_group_name],
           [portfolio_group_description],
           [users],
           [role],
           [is_public],
           [is_active]
    FROM   maintain_portfolio_group
    WHERE portfolio_group_id = @portfolio_group_id;
END
ELSE IF @flag = 'a'
BEGIN
    SELECT  [portfolio_group_id] AS [ID],
			mpg.portfolio_group_name AS [Portfolio Group Name],
			mpg.[portfolio_group_description] AS [Group Description], 
			mpg.[users] AS [User],
			asr.role_name AS [Role], 
			CASE WHEN mpg.[is_public] = 'y' THEN 'Yes' ELSE 'No' END [Public],
			CASE WHEN mpg.[is_active] = 'y' THEN 'Yes' ELSE 'No' END [Active]
	FROM maintain_portfolio_group mpg 
	LEFT JOIN application_security_role asr ON asr.role_id= mpg.[role]
    ORDER BY mpg.portfolio_group_name
END
ELSE IF @flag = 'e'
BEGIN
    SELECT  [portfolio_group_id] AS [ID],
			mpg.portfolio_group_name AS [Portfolio Group Name]			
	FROM maintain_portfolio_group mpg 
	LEFT JOIN application_security_role asr ON asr.role_id= mpg.[role]
	WHERE mpg.is_active='y'	
END
ELSE IF @flag IN ('i', 'u')
BEGIN
	BEGIN TRY
		DECLARE @idoc INT
		EXEC sp_xml_preparedocument @idoc OUTPUT, @form_xml
	
		IF OBJECT_ID('tempdb..#temp_form_data') IS NOT NULL
			DROP TABLE #temp_form_data
		
		CREATE TABLE #temp_form_data
		(
			portfolio_group_name            VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			portfolio_group_description     VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			users                           VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			[role]                          VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			is_public                       VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			is_active                       VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			portfolio_group_id              VARCHAR(100) COLLATE DATABASE_DEFAULT 		
		)
	
		INSERT INTO #temp_form_data
		SELECT  portfolio_group_name       ,
				portfolio_group_description,
				users                      ,
				[role]                     ,
				is_public                  ,
				is_active                  ,
				portfolio_group_id
		FROM   OPENXML(@idoc, '/Root/FormXML', 1)
				WITH (
	       			portfolio_group_name        VARCHAR(100) '@portfolio_group_name',
					portfolio_group_description VARCHAR(100) '@portfolio_group_description',
					users                       VARCHAR(100) '@users',
					[role]                      VARCHAR(100) '@role',
					is_public                   VARCHAR(100) '@is_public',
					is_active                   VARCHAR(100) '@is_active',
					portfolio_group_id          VARCHAR(100) '@portfolio_group_id'
				)
			
		SELECT @portfolio_group_name = portfolio_group_name,
			   @portfolio_group_description = portfolio_group_description,
			   @users = users,
			   @role = [role],
			   @is_public = is_public,
			   @is_active = is_active,
			   @portfolio_group_id = portfolio_group_id
		FROM #temp_form_data	
	
		DECLARE @err_msg VARCHAR(1000)
		SET @err_msg = 'Duplicate data in <b> Portfolio Group Name</b>.'
	
		BEGIN TRAN
		IF @flag = 'i'
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM maintain_portfolio_group WHERE portfolio_group_name = @portfolio_group_name)
			BEGIN
				INSERT INTO maintain_portfolio_group (portfolio_group_name, portfolio_group_description, [role], is_public, users, is_active)
				VALUES (@portfolio_group_name, @portfolio_group_description, @role, @is_public, @users, @is_active)
		
				SET @portfolio_group_id = SCOPE_IDENTITY()
		
				EXEC spa_generic_portfolio_mapping_template @flag = @flag, @mapping_source_id = @portfolio_mapping_source, @mapping_source_value_id = @portfolio_group_id, @xml = @portfolio_xml
		
				EXEC spa_ErrorHandler 0
					, 'maintain_portfolio_group'
					, 'spa_maintain_portfolio_group'
					, 'Success'
					, 'Changes have been saved successfully.'
					, @portfolio_group_id
			END
			ELSE
			BEGIN
				EXEC spa_ErrorHandler 1, 
				'maintain_portfolio_group', 
				'spa_maintain_portfolio_group', 
				'DB Error', 
				@err_msg,
				''
			END
		END	
		ELSE IF @flag = 'u'
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM maintain_portfolio_group WHERE portfolio_group_name = @portfolio_group_name AND portfolio_group_id <> @portfolio_group_id)
			BEGIN
				UPDATE maintain_portfolio_group
				SET portfolio_group_name = @portfolio_group_name,
					portfolio_group_description = @portfolio_group_description,
					[role] = @role,
					is_public = @is_public,
					users = @users,
					is_active = @is_active
				WHERE portfolio_group_id = @portfolio_group_id
		
				EXEC spa_generic_portfolio_mapping_template @flag = @flag, @mapping_source_id = @portfolio_mapping_source, @mapping_source_value_id = @portfolio_group_id, @xml = @portfolio_xml
		
				EXEC spa_ErrorHandler 0
					, 'maintain_portfolio_group'
					, 'spa_maintain_portfolio_group'
					, 'Success'
					, 'Changes have been saved successfully.'
					, ''
			END
			ELSE
			BEGIN
				EXEC spa_ErrorHandler 1, 
				'maintain_portfolio_group', 
				'spa_maintain_portfolio_group', 
				'DB Error', 
				@err_msg,
				''
			END
		END
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK
		EXEC spa_ErrorHandler 1, 
			'maintain_portfolio_group', 
			'spa_maintain_portfolio_group', 
			'DB Error', 
			'Failed to save data.',
			''
	END CATCH
END
ELSE IF @flag = 'd'
BEGIN
    BEGIN TRY
		BEGIN TRAN
			
			DELETE pms
			FROM portfolio_mapping_source pms
			INNER JOIN dbo.FNASplit(@del_portfolio_group_id, ',') a
				ON a.item = pms.mapping_source_usage_id
				AND pms.mapping_source_value_id = @portfolio_mapping_source

			UPDATE pms
			SET pms.portfolio_group_id = NULL
			FROM portfolio_mapping_source as pms 
			INNER JOIN dbo.FNASplit(@del_portfolio_group_id, ',') b
				ON b.item = pms.portfolio_group_id
			
			DELETE mpg
			FROM maintain_portfolio_group mpg
			INNER JOIN dbo.FNASplit(@del_portfolio_group_id, ',') c
				ON c.item = mpg.portfolio_group_id

    	COMMIT
		EXEC spa_ErrorHandler 0
			, 'maintain_portfolio_group'
			, 'spa_maintain_portfolio_group'
			, 'Success'
			, 'Changes have been saved successfully.'
			, @del_portfolio_group_id
    END TRY
    BEGIN CATCH
    	ROLLBACK
		EXEC spa_ErrorHandler -1
			, 'maintain_portfolio_group'
			, 'spa_maintain_portfolio_group'
			, 'DB ERROR'
			, 'Delete portfolio group record failed.'
			, ''
    END CATCH
END
ELSE IF @flag = 'b'
BEGIN
	SELECT portfolio_group_id FROM maintain_portfolio_group
	WHERE portfolio_group_name = @portfolio_group_name
END
ELSE IF @flag = 'c'
BEGIN
	SELECT mpg.portfolio_group_id, mpg.portfolio_group_name AS [Portfolio Group Name]
	FROM maintain_portfolio_group mpg WHERE mpg.is_active='y'
	Order by mpg.portfolio_group_name ASC
END
