

IF OBJECT_ID(N'[dbo].[spa_confirm_status]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_confirm_status]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2008-09-09
-- Description: Description of the functionality in brief.
 
-- Params:
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - Description of param3
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_confirm_status]
    @flag CHAR(1),
    @source_deal_header_id VARCHAR(MAX) = NULL,
    @xml XML = NULL,
    @confirm_status_ids VARCHAR(MAX) = NULL
AS
SET NOCOUNT ON

DECLARE @sql		VARCHAR(MAX)
DECLARE @DESC       VARCHAR(500)
DECLARE @err_no     INT

DECLARE @process_table VARCHAR(300)
DECLARE @user_name VARCHAR(100) = dbo.FNADBUser()
DECLARE @process_id VARCHAR(200) = dbo.FNAGETNEWId()
 
IF @flag = 's'
BEGIN
    SELECT cs.confirm_status_id [id],
		cs.source_deal_header_id [deal_id],
		sdv.code [confirm_status],
		dbo.FNAdateformat(as_of_date) [as_of_date],
		cs.comment1 Comment1,
		cs.comment2 Comment2,
		cs.confirm_id [confirm_id],
		cs.update_user [user_id],
		dbo.FNADateTimeFormat(cs.update_ts, 1) [Time Stamp],
		'<a href="../../../adiha.php.scripts/dev/shared_docs/attach_docs/' + an.attachment_folder + '/' + an.attachment_file_name + '" target="_blank">' + an.notes_subject + '</a>'  [confirmation file],
		'<a href="../../../adiha.php.scripts/dev/shared_docs/attach_docs/' + an1.attachment_folder + '/' + an1.attachment_file_name + '" target="_blank">' + an1.notes_subject + '</a>'  [confirmation file 2] 
	FROM confirm_status cs
	INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv ON cs.source_deal_header_id = scsv.item
	INNER JOIN static_data_value sdv ON cs.type = sdv.value_id
	LEFT JOIN application_notes an ON an.category_value_id = 42018 AND cs.confirm_status_id = an.notes_object_id AND an.internal_type_value_id = 33
	LEFT JOIN application_notes an1 ON an.category_value_id = 42018 AND an1.category_value_id = 42021 AND an.notes_object_id = an1.notes_object_id AND an.parent_object_id = an.parent_object_id
	WHERE 1 = 1
    ORDER by cs.confirm_status_id DESC
END
ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY
		--SOME SQL INSERT, UPDATE or DELETE operations
		--DECLARE @sql VARCHAR(MAX)
		--DECLARE @xml XML = '<Grid><GridRow id="New_1436557007125" deal_id="17389" confirm_status="17202" as_of_date="2015-07-31" comment1="" comment2="" confirm_id="" user_id="farrms_admin" time_stamp=""></GridRow></Grid>'
		
		DECLARE @deal_ids VARCHAR(MAX)
		
		SET @process_table = dbo.FNAProcessTableName('confirm_status', @user_name, @process_id)
		EXEC spa_parse_xml_file 'b', NULL, @xml, @process_table
		
		IF OBJECT_ID('tempdb..#temp_insert_confirm_status') IS NOT NULL
			DROP TABLE #temp_insert_confirm_status
		
		IF OBJECT_ID('tempdb..#temp_update_confirm_status') IS NOT NULL
			DROP TABLE #temp_update_confirm_status
			
		IF OBJECT_ID('tempdb..#temp_all_deal_ids') IS NOT NULL
			DROP TABLE #temp_all_deal_ids
		
		CREATE TABLE #temp_all_deal_ids(
			id                        INT,
			source_deal_header_id     INT,
			as_of_date                DATETIME,
			confirm_status            INT,
			comment1                  VARCHAR(5000) COLLATE DATABASE_DEFAULT ,
			comment2                  VARCHAR(5000) COLLATE DATABASE_DEFAULT ,
			confirm_id                VARCHAR(200) COLLATE DATABASE_DEFAULT 
		)	
			
		CREATE TABLE #temp_insert_confirm_status (
			id VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			deal_id INT,
			as_of_date DATETIME,
			confirm_status INT,
			comment1 VARCHAR(5000) COLLATE DATABASE_DEFAULT ,
			comment2 VARCHAR(5000) COLLATE DATABASE_DEFAULT ,
			confirm_id VARCHAR(200) COLLATE DATABASE_DEFAULT 
		)
		
		CREATE TABLE #temp_update_confirm_status (
			id VARCHAR(200) COLLATE DATABASE_DEFAULT ,
			deal_id INT,
			as_of_date DATETIME,
			confirm_status INT,
			comment1 VARCHAR(5000) COLLATE DATABASE_DEFAULT ,
			comment2 VARCHAR(5000) COLLATE DATABASE_DEFAULT ,
			confirm_id VARCHAR(200) COLLATE DATABASE_DEFAULT 
		)
		
		SET @sql = 'INSERT INTO #temp_insert_confirm_status (id, deal_id, as_of_date, confirm_status, comment1, comment2, confirm_id)
					SELECT id, deal_id, as_of_date, confirm_status, comment1, comment2, confirm_id
					FROM ' + @process_table + '
					WHERE id LIKE ''%New_%'''
		
		EXEC(@sql)
		
		SET @sql = 'INSERT INTO #temp_update_confirm_status (id, deal_id, as_of_date, confirm_status, comment1, comment2, confirm_id)
					SELECT id, deal_id, as_of_date, confirm_status, comment1, comment2, confirm_id
					FROM ' + @process_table + '
					WHERE id NOT LIKE ''%New_%'''
		
		EXEC(@sql)
		
		IF OBJECT_ID('tempdb..#inserted_confirm_status') IS NOT NULL
			DROP TABLE #inserted_confirm_status
			
		CREATE TABLE #inserted_confirm_status (confirm_status_id INT, source_deal_header_id INT, [type] INT)
			
		IF EXISTS(SELECT 1 FROM #temp_insert_confirm_status)
		BEGIN
			INSERT confirm_status (
	            source_deal_header_id,
	            TYPE,
	            as_of_date,
	            comment1,
	            comment2,
	            confirm_id
			)
			OUTPUT INSERTED.confirm_status_id, INSERTED.source_deal_header_id, INSERTED.[type]
			INTO #inserted_confirm_status (confirm_status_id, source_deal_header_id, [type])
			SELECT temp.deal_id, temp.confirm_status, temp.as_of_date, temp.comment1, temp.comment2, temp.confirm_id
			FROM #temp_insert_confirm_status temp
			
			IF NOT EXISTS(SELECT 1
			          FROM #temp_insert_confirm_status t
			          INNER JOIN confirm_status_recent csr 
			          	ON csr.source_deal_header_id = t.deal_id
			)
			BEGIN
				INSERT confirm_status_recent (
					source_deal_header_id,
					TYPE,
					as_of_date,
					comment1,
					comment2,
					confirm_id
				)
				SELECT temp.deal_id, temp.confirm_status, temp.as_of_date, temp.comment1, temp.comment2, temp.confirm_id 
				FROM #temp_insert_confirm_status temp
				LEFT JOIN confirm_status_recent csr ON csr.source_deal_header_id = temp.deal_id
				WHERE csr.confirm_status_id IS NULL
			END
			ELSE 
			BEGIN
				UPDATE csr
				SET [type] = t.confirm_status
				FROM #temp_insert_confirm_status t
				INNER JOIN confirm_status_recent csr ON t.deal_id = csr.source_deal_header_id
			END
			
			UPDATE source_deal_header
			SET confirm_status_type = t.confirm_status,
				update_ts = GETDATE(),
				update_user = dbo.FNADBUSer()
			FROM source_deal_header sdh
			INNER JOIN #temp_insert_confirm_status t ON sdh.source_deal_header_id = t.deal_id
			
			SELECT @deal_ids = COALESCE(@deal_ids + ',', '') + deal_id
			FROM #temp_insert_confirm_status
			GROUP BY deal_id
				
			EXEC spa_insert_update_audit 'u', @deal_ids
		END
		
		IF EXISTS(SELECT 1 FROM #temp_update_confirm_status)
		BEGIN 
			UPDATE cs
			SET type = t.confirm_status,
				as_of_date = t.as_of_date,
				comment1 = t.comment1,
				comment2 = t.comment2,
				confirm_id = t.confirm_id
			FROM confirm_status cs
			INNER JOIN #temp_update_confirm_status t ON t.id = cs.confirm_status_id 
			
			-- update confirm status recent and confirm status in deal, only if new data is not inserted
			IF NOT EXISTS(SELECT 1 FROM #temp_insert_confirm_status)
			BEGIN
				-- update using most recent data from confirm_status
				UPDATE csr
				SET [type] = t.confirm_status
				FROM confirm_status_recent csr
				INNER JOIN (
					SELECT TOP(1) t.id, t.deal_id, t.confirm_status FROM #temp_update_confirm_status t ORDER BY CAST(t.id AS INT) DESC
				) t ON t.deal_id = csr.source_deal_header_id
				
				-- update using most recent data from confirm_status
				UPDATE source_deal_header
				SET confirm_status_type = t.confirm_status,
					update_ts = GETDATE(),
					update_user = dbo.FNADBUSer()
				FROM source_deal_header sdh
				INNER JOIN (
					SELECT TOP(1) t.id, t.deal_id, t.confirm_status FROM #temp_update_confirm_status t ORDER BY CAST(t.id AS INT)  DESC
				) t ON t.deal_id = sdh.source_deal_header_id
				
				INSERT INTO #inserted_confirm_status
				SELECT id, deal_id, confirm_status
				FROM #temp_update_confirm_status
				
				SELECT @deal_ids = COALESCE(@deal_ids + ',', '') + deal_id
				FROM #temp_update_confirm_status
				GROUP BY deal_id
				
				EXEC spa_insert_update_audit 'u', @deal_ids
			END
		END
		
		DECLARE @alert_process_table varchar(300)
		SET @alert_process_table = 'adiha_process.dbo.alert_deal_confirm_status_' + @process_id + '_adcs'
		
		EXEC('CREATE TABLE ' + @alert_process_table + '(
		      	confirm_status_id         INT NOT NULL,
		      	source_deal_header_id     INT NOT NULL,
		      	confirm_status            INT NOT NULL,
		      	hyperlink1                VARCHAR(5000),
		      	hyperlink2                VARCHAR(5000),
		      	hyperlink3                VARCHAR(5000),
		      	hyperlink4                VARCHAR(5000),
		      	hyperlink5                VARCHAR(5000)
		      )')
		
		SET @sql = 'INSERT INTO ' + @alert_process_table + '(confirm_status_id, source_deal_header_id, confirm_status) 
					SELECT  confirm_status_id,
							source_deal_header_id,
							TYPE
					FROM #inserted_confirm_status scsv
					'						   
		exec spa_print @sql
		EXEC(@sql)	
		EXEC spa_register_event 20601, 20513, @alert_process_table, 0, @process_id				 
		
		EXEC spa_ErrorHandler 0
			, 'confirm_status'
			, 'spa_confirm_status'
			, 'Success' 
			, 'Changes have been saved successfully.'
			, ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @DESC = 'Fail to save data ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'confirm_status'
		   , 'spa_confirm_status'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
END 
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		DELETE cs
		FROM confirm_status cs
		INNER JOIN dbo.SplitCommaSeperatedValues(@confirm_status_ids) scsv ON cs.confirm_status_id = scsv.item
	
		EXEC spa_ErrorHandler 0
			, 'confirm_status'
			, 'spa_confirm_status'
			, 'Success' 
			, 'Changes have been saved successfully.'
			, ''
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @desc = 'Fail to delete data ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'confirm_status'
		   , 'spa_confirm_status'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH
END
ELSE IF @flag = 'x' -- insert confirm status for multiple deals
BEGIN
	BEGIN TRY
		SET @process_table = dbo.FNAProcessTableName('confirm_status', @user_name, @process_id)
		EXEC spa_parse_xml_file 'b', NULL, @xml, @process_table
	
		IF OBJECT_ID('tempdb..#temp_confirm_status') IS NOT NULL
			DROP TABLE #temp_confirm_status
		
		CREATE TABLE #temp_confirm_status (
			deal_id INT, 
			as_of_date DATETIME,
			comment1 NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
			comment2 NVARCHAR(500) COLLATE DATABASE_DEFAULT ,
			confirm_id NVARCHAR(50) COLLATE DATABASE_DEFAULT ,
			confirm_status INT
		)
		SET @sql = 'INSERT INTO #temp_confirm_status(deal_id, as_of_date, comment1, comment2, confirm_id, confirm_status)
					SELECT scsv.item [deal_id], temp.as_of_date, temp.comment1, temp.comment2, temp.confirm_id, temp.confirm_status 
					FROM ' + @process_table + ' temp
					OUTER APPLY (SELECT item FROM dbo.SplitCommaSeperatedValues(temp.deal_ids)) scsv'
		EXEC(@sql)
		
		IF EXISTS(SELECT 1 FROM #temp_confirm_status)
		BEGIN
			INSERT confirm_status (
				source_deal_header_id,
				TYPE,
				as_of_date,
				comment1,
				comment2,
				confirm_id
			)
			SELECT temp.deal_id, temp.confirm_status, temp.as_of_date, temp.comment1, temp.comment2, temp.confirm_id
			FROM #temp_confirm_status temp
		
			UPDATE csr
			SET [type] = temp.confirm_status
			FROM confirm_status_recent csr 
			INNER JOIN #temp_confirm_status temp ON csr.source_deal_header_id = temp.deal_id 
		
			INSERT confirm_status_recent (
				source_deal_header_id,
				TYPE,
				as_of_date,
				comment1,
				comment2,
				confirm_id
			)
			SELECT temp.deal_id, temp.confirm_status, temp.as_of_date, temp.comment1, temp.comment2, temp.confirm_id 
			FROM #temp_confirm_status temp
			LEFT JOIN confirm_status_recent csr ON csr.source_deal_header_id = temp.deal_id
			WHERE csr.confirm_status_id IS NULL
		
			UPDATE source_deal_header
			SET confirm_status_type = t.confirm_status,
				update_ts = GETDATE(),
				update_user = dbo.FNADBUSer()
			FROM source_deal_header sdh
			INNER JOIN #temp_confirm_status t ON sdh.source_deal_header_id = t.deal_id
		END
		
		EXEC spa_ErrorHandler 0
				, 'confirm_status'
				, 'spa_confirm_status'
				, 'Success' 
				, 'Changes have been saved successfully.'
				, ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @DESC = 'Fail to save data ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'confirm_status'
		   , 'spa_confirm_status'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
	            
END

ELSE IF @flag = 'c'
BEGIN
	DECLARE @notes_id INT
	SELECT @notes_id = MAX(notes_id) FROM confirm_status cs
	INNER JOIN application_notes an ON cs.confirm_status_id = an.notes_object_id
	WHERE source_deal_header_id = @source_deal_header_id 

	IF EXISTS (SELECT 1 FROM application_notes WHERE notes_id = @notes_id)
		SELECT 'Success' [status], '../../../adiha.php.scripts/dev/shared_docs/attach_docs/' + sdv.code + '/' + attachment_file_name [file] FROM application_notes an
		INNER JOIN static_data_value sdv ON sdv.value_id = an.internal_type_value_id
		WHERE notes_id = @notes_id
	ELSE 
		SELECT 'Error' [status], 'No Confirmation file found.' [file]
END
ELSE IF @flag = 'e'
BEGIN
	BEGIN TRY
		IF OBJECT_ID('tempdb..#temp_confirm_deals') IS NOT NULL
			DROP TABLE #temp_confirm_deals
			
		CREATE TABLE #temp_confirm_deals(deal_id INT, confirm_status INT, recent_confirm_status INT, insert_update CHAR(1) COLLATE DATABASE_DEFAULT )
	
		INSERT INTO #temp_confirm_deals(deal_id, confirm_status, recent_confirm_status, insert_update)
		SELECT sdh.source_deal_header_id, sdh.confirm_status_type, csr.type, 'u'
		FROM   dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = scsv.item
		INNER JOIN confirm_status_recent csr ON csr.source_deal_header_id = sdh.source_deal_header_id
	
		INSERT INTO #temp_confirm_deals(deal_id, confirm_status, recent_confirm_status, insert_update)
		SELECT sdh.source_deal_header_id, ISNULL(sdh.confirm_status_type, 17200), NULL, 'i'
		FROM   dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = scsv.item
		LEFT JOIN confirm_status_recent csr ON csr.source_deal_header_id = sdh.source_deal_header_id
		WHERE csr.confirm_status_id IS NULL	
		
		IF EXISTS(SELECT 1 FROM #temp_confirm_deals)
		BEGIN
			INSERT confirm_status (
				source_deal_header_id,
				TYPE,
				as_of_date
			)
			SELECT temp.deal_id, temp.confirm_status, GETDATE()
			FROM #temp_confirm_deals temp
			WHERE temp.insert_update = 'i' OR (temp.insert_update = 'u' AND temp.confirm_status <> temp.recent_confirm_status)
		
			UPDATE csr
			SET [type] = temp.confirm_status
			FROM confirm_status_recent csr 
			INNER JOIN #temp_confirm_deals temp ON csr.source_deal_header_id = temp.deal_id 
			WHERE temp.confirm_status <> temp.recent_confirm_status AND temp.insert_update = 'u'
		
			INSERT confirm_status_recent (
				source_deal_header_id,
				TYPE,
				as_of_date
			)
			SELECT temp.deal_id, temp.confirm_status, GETDATE()
			FROM #temp_confirm_deals temp
			WHERE temp.insert_update = 'i'
		END
		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @DESC = 'Fail to save data ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'confirm_status'
		   , 'spa_confirm_status'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
END
