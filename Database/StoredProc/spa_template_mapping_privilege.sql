IF OBJECT_ID(N'[dbo].[spa_template_mapping_privilege]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_template_mapping_privilege]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/**
	This Stored Procedure is used for CRUD operations for Deal Template Privileges.

	Parameters:
		@flag				:	Operation flag that defines which action to perform.
		@template_id		:	Identifier of Deal Insertion Template.
		@xml_data			:	XML Data for Inserting/Updating Deal Template Privilege.
		@template_id_list	:	List of Template Identifiers in comma separated form selected from Setup Deal Template to show in Deal Template Privileges window.
		@deleted_ids		:	Collection of template identifiers that needs to be deleted in comma separated form.
*/

CREATE PROCEDURE [dbo].[spa_template_mapping_privilege]
    @flag CHAR(1),
	@template_id INT = NULL,
	@xml_data VARCHAR(MAX) = NULL,
	@template_id_list VARCHAR(MAX) = NULL,
	@deleted_ids VARCHAR(MAX) = NULL
AS

SET NOCOUNT ON

/* -- DEBUG SECTION --
DECLARE @flag CHAR(1),
	@template_id INT = NULL,
	@xml_data VARCHAR(MAX) = NULL,
	@template_id_list VARCHAR(MAX) = NULL,
	@deleted_ids VARCHAR(MAX) = NULL

SELECT @flag='y', @xml_data = '<GridXml><GridRow template_name="Capacity NG" template_mapping_id="5" deal_type_id="1179" commodity_id="2294" user_id="aadhikari" role_name="Back Office Manager" ></GridRow></GridXml>'
--*/
 
DECLARE @sql VARCHAR(MAX)

IF @flag = 's'
BEGIN
	IF OBJECT_ID('tempdb..#temp_template_mapping_privilege') IS NOT NULL
		DROP TABLE #temp_template_mapping_privilege

	IF OBJECT_ID('tempdb..#temp_map_concat') IS NOT NULL
		DROP TABLE #temp_map_concat
	
    SELECT sdht.template_name,
		mft.template_description,
		sdht.template_id [template_id],
		tm.template_mapping_id,
		tm.deal_type_id,
		tm.commodity_id,
		tmp.[user_id],
		asr.role_name
	INTO #temp_template_mapping_privilege
	FROM source_deal_header_template sdht
	INNER JOIN maintain_field_template mft
		ON sdht.field_template_id = mft.field_template_id
	LEFT JOIN template_mapping tm ON tm.template_id = sdht.template_id
	INNER JOIN dbo.FNASplit(@template_id_list, ',') tid ON tid.item = sdht.template_id
	LEFT JOIN template_mapping_privilege tmp ON tm.template_mapping_id = tmp.template_mapping_id
	LEFT JOIN application_security_role asr ON tmp.role_id = asr.role_id
	
	-- To show Role and Users name in comma separated value.
	SELECT template_name,template_description, template_mapping_id, template_id, deal_type_id, commodity_id,
			STUFF((SELECT ', ' + [user_id]
					FROM #temp_template_mapping_privilege t1
					WHERE t1.template_mapping_id = t.template_mapping_id
					FOR XML PATH ('')), 1, 1, '') AS [user_id], 
			STUFF((SELECT ', ' + CAST(role_name AS VARCHAR(MAX))
					FROM #temp_template_mapping_privilege t1
					WHERE t1.template_mapping_id = t.template_mapping_id
					FOR XML PATH ('')), 1, 1, '') AS role_name
	INTO #temp_map_concat
	FROM #temp_template_mapping_privilege t
	GROUP BY template_mapping_id, template_description,template_id, deal_type_id, commodity_id, template_name
	
	SELECT template_name, template_description,template_id, template_mapping_id, deal_type_id, commodity_id, [user_id], role_name
	FROM #temp_map_concat
	ORDER BY template_mapping_id
END

ELSE IF @flag = 'y'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			IF OBJECT_ID('tempdb..#temp_template_privilege') IS NOT NULL
				DROP TABLE #temp_template_privilege

			DECLARE @idoc INT
			EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_data

			SELECT NULLIF(template_mapping_id, '') [template_mapping_id]
				, template_id
				, template_name
				, NULLIF(deal_type_id, '') [deal_type_id]
				, CASE WHEN commodity_id = '' THEN NULL ELSE commodity_id END commodity_id
				, CASE WHEN [user_id] = 'None' OR [user_id] = '' THEN NULL ELSE [user_id] END [user_id]
				, CASE WHEN [role_name] = 'None' OR [role_name] = '' THEN NULL ELSE [role_name] END [role_name]
			INTO #temp_template_privilege			
			FROM   OPENXML (@idoc, '/GridXml/GridRow', 1)
			WITH ( 
				template_mapping_id	VARCHAR(1000)	'@template_mapping_id',
				template_id			VARCHAR(5000)	'@template_id',
				template_name		VARCHAR(5000)	'@template_name',
				deal_type_id		VARCHAR(5000)	'@deal_type_id', 
				commodity_id		VARCHAR(5000)	'@commodity_id',
				[user_id]			VARCHAR(5000)	'@user_id',
				[role_name]			VARCHAR(5000)	'@role_name' 
			)

			EXEC sp_xml_removedocument @idoc

			UPDATE tmp
			SET template_id = sdht.template_id
			FROM #temp_template_privilege tmp
			INNER JOIN source_deal_header_template sdht on sdht.template_name = tmp.template_name

			IF EXISTS(
				SELECT template_id,deal_type_id,commodity_id, COUNT(1) 
				FROM #temp_template_privilege
				GROUP BY template_id,deal_type_id,commodity_id
				HAVING COUNT(template_mapping_id) > 1
			)
			BEGIN
				COMMIT
				EXEC spa_ErrorHandler -1
					, 'spa_template_mapping_privilege'
					, 'spa_template_mapping_privilege'
					, 'DB ERROR'
					, 'Combination of Template, Deal Type and Commodity must be unique.'
					, ''
				RETURN
			END

			IF EXISTS(
				SELECT 1 
				FROM template_mapping tm
				INNER JOIN #temp_template_privilege temp
					ON tm.template_id = temp.template_id
					AND ISNULL(tm.deal_type_id,-1) = ISNULL(temp.deal_type_id,-1)
					AND ISNULL(tm.commodity_id,-1) = ISNULL(temp.commodity_id,-1)
				WHERE ISNULL(temp.template_mapping_id, -1) <> CAST(tm.template_mapping_id AS VARCHAR(30))
			)
			BEGIN
				COMMIT
				EXEC spa_ErrorHandler -1 
					, 'spa_template_mapping_privilege'
					, 'spa_template_mapping_privilege'
					, 'DB ERROR'
					, 'Combination of Template, Deal Type and Commodity must be unique.'
					, ''
				RETURN
			END

			--IF EXISTS(
			--	SELECT 1 FROM #temp_template_privilege WHERE NULLIF(deal_type_id, '') IS NULL
			--)
			--BEGIN
			--	COMMIT
			--	EXEC spa_ErrorHandler -1
			--		, 'spa_template_mapping_privilege'
			--		, 'spa_template_mapping_privilege'
			--		, 'DB ERROR'
			--		, 'Deal Type cannot be blank.'
			--		, ''
			--	RETURN
			--END

			/* -- new change commodity can be blank
			IF EXISTS(
				SELECT 1 FROM #temp_template_privilege WHERE NULLIF(commodity_id, '') IS NULL
			)
			BEGIN
				COMMIT
				EXEC spa_ErrorHandler -1
					, 'spa_template_mapping_privilege'
					, 'spa_template_mapping_privilege'
					, 'DB ERROR'
					, 'Commodity cannot be blank.'
					, ''
				RETURN
			END
			*/
			
			
			IF OBJECT_ID('tempdb..#temp_inserted_mapping') IS NOT NULL
					DROP TABLE #temp_inserted_mapping
			CREATE TABLE #temp_inserted_mapping (template_mapping_id INT, template_id INT, deal_type_id INT, commodity_id INT)

			-- If there are rows that need to be inserted. (Insert Mode)
			IF EXISTS(SELECT 1 FROM #temp_template_privilege WHERE template_mapping_id IS NULL)--LIKE '%NEW_%')
			BEGIN
				INSERT INTO template_mapping (template_id, deal_type_id, commodity_id)
				OUTPUT INSERTED.template_mapping_id, INSERTED.template_id, INSERTED.deal_type_id, INSERTED.commodity_id INTO #temp_inserted_mapping(template_mapping_id, template_id, deal_type_id, commodity_id)
				SELECT ttp.template_id,ttp.deal_type_id,
				CASE WHEN ttp.commodity_id = '' THEN NULL ELSE ttp.commodity_id END
				FROM #temp_template_privilege ttp
				LEFT JOIN template_mapping tm 
					ON tm.template_id = ttp.template_id
					AND ISNULL(tm.deal_type_id,-1) = ISNULL(ttp.deal_type_id,-1)
					AND ISNULL(tm.commodity_id,-1) = ISNULL(ttp.commodity_id,-1)
				WHERE ttp.template_mapping_id IS NULL --LIKE '%NEW_%' 
					AND tm.template_mapping_id IS NULL
					
				UPDATE t1
				SET template_mapping_id = t2.template_mapping_id
				FROM #temp_template_privilege t1
				INNER JOIN #temp_inserted_mapping t2
					ON t2.template_id = t1.template_id
					AND ISNULL(t2.deal_type_id,-1) = ISNULL(t1.deal_type_id,-1)
					AND ISNULL(t2.commodity_id, -1) = ISNULL(t1.commodity_id, -1)
			END

			UPDATE tm
			SET deal_type_id = t1.deal_type_id,
				commodity_id = CASE WHEN t1.commodity_id = '' THEN NULL ELSE t1.commodity_id END
			FROM template_mapping tm
			INNER JOIN #temp_template_privilege t1 ON t1.template_mapping_id = tm.template_mapping_id
			LEFT JOIN #temp_inserted_mapping t2 ON t2.template_mapping_id = tm.template_mapping_id
			WHERE t2.template_mapping_id IS NULL

			--IF OBJECT_ID('tempdb..#temp_delete_mapping') IS NOT NULL
			--	DROP TABLE #temp_delete_mapping
			--CREATE TABLE #temp_delete_mapping (template_mapping_id INT)

			--INSERT INTO #temp_delete_mapping
			--SELECT tm.template_mapping_id
			--FROM template_mapping tm
			--LEFT JOIN #temp_template_privilege t1 ON tm.template_mapping_id = t1.template_mapping_id
			--WHERE tm.template_id = @template_id
			--AND t1.template_mapping_id IS NULL

			-- Delete Case (Delete Data from Template Mapping Privileges)
			DELETE tmp
			FROM template_mapping_privilege tmp
			INNER JOIN dbo.FNASplit(@deleted_ids, ',') di ON di.item = tmp.template_mapping_id
			-- Delete Case (Delete Data from Template Mapping)
			DELETE tm
			FROM template_mapping tm
			INNER JOIN dbo.FNASplit(@deleted_ids, ',') di ON di.item = tm.template_mapping_id
			
			IF OBJECT_ID('tempdb..#template_privilege_row') IS NOT NULL
				DROP TABLE #template_privilege_row
				
			CREATE TABLE #template_privilege_row (
				[template_mapping_id] INT,
				[user]                VARCHAR(1000) COLLATE DATABASE_DEFAULT,
				[role]                VARCHAR(1000) COLLATE DATABASE_DEFAULT
			)

			DECLARE @user VARCHAR(50), @role VARCHAR(100), @db_id INT
 			DECLARE template_priv_cursor CURSOR FORWARD_ONLY READ_ONLY 
 			FOR
 				SELECT template_mapping_id, [user_id], [role_name]
 				FROM #temp_template_privilege
 			OPEN template_priv_cursor
 			FETCH NEXT FROM template_priv_cursor INTO @db_id, @user, @role                                      
 			WHILE @@FETCH_STATUS = 0
 			BEGIN
				IF @user = 'All'
				BEGIN 			
					INSERT INTO #template_privilege_row([template_mapping_id], [user])
					SELECT @db_id, user_login_id FROM application_users
				END 
				ELSE IF @user IS NOT NULL
				BEGIN 
					INSERT INTO #template_privilege_row([template_mapping_id], [user])
					SELECT @db_id, item FROM dbo.FNASplit(@user, ',') 
				END 

				IF @role = 'All'
				BEGIN				  
					INSERT INTO #template_privilege_row([template_mapping_id], [role])
					SELECT @db_id, asr.role_id  FROM application_security_role asr 		 			 
				END 
				ELSE IF @role IS NOT NULL 
				BEGIN 
					INSERT INTO #template_privilege_row([template_mapping_id], [role])
					SELECT @db_id, asr.role_id FROM dbo.FNASplit(@role, ',') i
					INNER JOIN application_security_role asr ON RTRIM(LTRIM(asr.role_name)) = i.item
				END 

				FETCH NEXT FROM template_priv_cursor INTO @db_id, @user, @role   
 			END
 			CLOSE template_priv_cursor
 			DEALLOCATE template_priv_cursor
			
			IF EXISTS (SELECT 1 FROM #template_privilege_row)
			BEGIN
				DELETE tmp
				-- SELECT *
				FROM #template_privilege_row tpr
				INNER JOIN template_mapping_privilege tmp ON tmp.template_mapping_id = tpr.template_mapping_id

				INSERT INTO template_mapping_privilege (template_mapping_id, [user_id], role_id)
				SELECT tpr.template_mapping_id, [user], [role]
				FROM #template_privilege_row tpr
				LEFT JOIN template_mapping_privilege tmp ON tmp.template_mapping_id = tpr.template_mapping_id
				WHERE tmp.template_mapping_id IS NULL
			END

			UPDATE tmp
			SET tmp.user_id = NULL
				, tmp.role_id = NULL 
			FROM #temp_template_privilege ttp
			INNER JOIN template_mapping_privilege tmp
				ON ttp.template_mapping_id = tmp.template_mapping_id
			WHERE ttp.user_id IS NULL AND ttp.role_name IS NULL


		COMMIT TRAN

		--release combov2 and UI keys using 'dealtemplate||template_mapping' to load dropdown options.
		DECLARE @cmbobj_key VARCHAR(50) = 'dealtemplate||template_mapping'
	
		IF  EXISTS (
			SELECT 1 FROM sys.objects 
			WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') 
				AND TYPE IN (N'P', N'PC')
		)
		BEGIN
			EXEC [spa_manage_memcache] @flag = 'd', 
				@key_prefix = NULL, 
				@cmbobj_key_source = @cmbobj_key, 
				@other_key_source=NULL,
				@source_object = 'spa_template_mapping_privilege @flag=y'
		END 

		EXEC spa_ErrorHandler 0
		   , 'spa_template_mapping_privilege'
		   , 'spa_template_mapping_privilege'
		   , 'Success'
		   , 'Changes have been saved successfully.'
		   , ''

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRAN
		DECLARE @err_msg VARCHAR(5000) = 'Fail to assign privilege ( Errr Description:' + ERROR_MESSAGE() + ').'
 
	    EXEC spa_ErrorHandler -1
	        , 'spa_template_mapping_privilege'
			, 'spa_template_mapping_privilege'
			, 'DB ERROR'
			, @err_msg
			, ''		
	END CATCH
END

GO