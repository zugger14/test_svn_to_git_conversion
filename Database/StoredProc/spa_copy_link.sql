IF OBJECT_ID(N'spa_copy_link', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_copy_link]
 GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Procedure that is used to copy the link header/detail.
	
	Parameters:
		@link_id	:	Numeric Identifier for Link.
		@book_id	:	Numeric Identifier of FAS Book in Book Structure.
		@flag		:	Operation flag that decides the action to be performed.
*/

CREATE PROCEDURE [dbo].[spa_copy_link]
	@link_id INT,
	@book_id INT = NULL,
	@flag CHAR(1) = NULL -- NULL means copy, m means move
AS
SET NOCOUNT ON

/** Debug Section **
DECLARE @link_id INT,
	@book_id INT = NULL,
	@flag CHAR(1) = NULL -- NULL means copy, m means move

SELECT @link_id = 8, @book_id = 36, @flag = 'm'
--*/

DECLARE @sql NVARCHAR(MAX)
DECLARE @no_deals INT
DECLARE @deal_copy_from_id INT
DECLARE @deal_copy_from_d_id VARCHAR(50)
declare @err_no INT
declare @new_link_id INT
DECLARE @new_id INT
DECLARE @deal_id_text VARCHAR(20)
SET @no_deals = 0

IF @flag = 'm' -- MOVE/TRANSFER
BEGIN
	UPDATE fas_link_header
	SET fas_book_id = @book_id
	WHERE link_id = @link_id

	EXEC spa_ErrorHandler 0,
		'Fas Link Header Table', 
		'spa_copy_link', 'Success', 
		'Fas Link detail transfered successfully.',
		''
END
ELSE -- COPY FUNCTION
BEGIN
	BEGIN TRY
		BEGIN TRAN
			INSERT INTO [fas_link_header] (
				[fas_book_id]
				,[perfect_hedge]
				,[fully_dedesignated]
				,[link_description]
				,[eff_test_profile_id]
				,[link_effective_date]
				,[link_type_value_id]
				,[link_active]
				,[original_link_id]
				,[link_end_date]
				,[dedesignated_percentage]
			)
			SELECT ISNULL(@book_id, [fas_book_id])
				,[perfect_hedge]
				,[fully_dedesignated]
				,[link_description]+'-Copy'
				,[eff_test_profile_id]
				,[link_effective_date]
				,[link_type_value_id]
				,[link_active]
				,[original_link_id]
				,[link_end_date]
				,[dedesignated_percentage]
			FROM [fas_link_header] 
			WHERE link_id = @link_id
		
			SET @new_link_id = SCOPE_IDENTITY()

			IF CURSOR_STATUS('global','fas_link_deal') >= -1
			BEGIN
				CLOSE fas_link_deal
				DEALLOCATE fas_link_deal
			END
		
			DECLARE fas_link_deal CURSOR FOR 
			SELECT sdh.source_deal_header_id, sdh.deal_id
			FROM fas_link_detail fld 
			INNER JOIN source_deal_header sdh ON fld.source_deal_header_id = sdh.source_deal_header_id
			WHERE link_id = @link_id

			OPEN fas_link_deal
			FETCH NEXT FROM fas_link_deal INTO @deal_copy_from_id, @deal_copy_from_d_id

			IF @@FETCH_STATUS <> 0 
			EXEC spa_print '         <<None>>'

			WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @err_no = 1
				SET @deal_id_text = ''
				DECLARE @new_sdh INT
		
				SET @new_sdh = IDENT_CURRENT('source_deal_header') + 1
				SET @deal_id_text = CAST(@deal_copy_from_id AS VARCHAR) + '_LC_' + CAST(@new_sdh AS VARCHAR)
			
				SDH_INSERT:
				BEGIN TRY
					DECLARE @insert_columns_build VARCHAR(MAX)
					DECLARE @select_columns_build VARCHAR(MAX)
					DECLARE @insert_columns_build_detail VARCHAR(MAX)
					DECLARE @select_columns_build_detail VARCHAR(MAX)

					DECLARE @params NVARCHAR(500)
					SET @params = N'@new_id INT OUTPUT'

					SELECT @insert_columns_build = CONCAT(@insert_columns_build, ',[', sc.[name], ']')
					FROM sys.tables st
					INNER JOIN sys.columns sc ON sc.[object_id] = st.[object_id]
					WHERE st.[name] = 'source_deal_header'
						AND sc.[name] NOT IN ('source_deal_header_id', 'create_user', 'create_ts', 'update_user', 'update_ts') -- exclude these columns

					SET @insert_columns_build = STUFF(@insert_columns_build, 1, 1, '')
					SET @select_columns_build = REPLACE(@insert_columns_build, '[deal_id]', CONCAT('''', @deal_id_text, ''''))

					SET @sql = '
						INSERT INTO source_deal_header (' + @insert_columns_build + ')
						SELECT ' + @select_columns_build + '
						FROM source_deal_header
						WHERE source_deal_header_id = ' + CAST(@deal_copy_from_id AS VARCHAR) + '
						
						SET @new_id = SCOPE_IDENTITY()
					'

					SET @insert_columns_build = NULL
					SET @select_columns_build = NULL

					EXEC spa_print 'Deal Header Insert: ', @sql
					EXEC sp_executesql @sql, @params, @new_id = @new_id OUTPUT;

					UPDATE source_deal_header
					SET deal_status = 5604, -- New
						confirm_status_type = 17200 -- Not Confirmed
					WHERE source_deal_header_id = @new_id
				END TRY
				BEGIN CATCH
					EXEC spa_print 'errrrrrrrrr'

					IF ERROR_NUMBER() = 2627
					BEGIN
						EXEC spa_print '@no_deals:', @no_deals
						--set @deal_id_text = left(@deal_copy_from_d_id,(case when CHARINDEX('_HYP',@deal_copy_from_d_id,1)=0 then len(@deal_copy_from_d_id)+1 else CHARINDEX('_HYP',@deal_copy_from_d_id,1) end)-1)+'_HYP'+cast(@no_deals as varchar)+'_C'+cast(@err_no as varchar)
						SET @deal_id_text = CONCAT(@deal_id_text, '_1')
						SET @err_no = @err_no + 1
						GOTO SDH_INSERT
					END
					ELSE
					BEGIN
						SELECT
						ERROR_SEVERITY() AS ErrorSeverity,
						ERROR_STATE() AS ErrorState,
						ERROR_PROCEDURE() AS ErrorProcedure,
						ERROR_LINE() AS ErrorLine,
						ERROR_MESSAGE() AS ErrorMessage;
						ROLLBACK
						RETURN
					END
				END CATCH

				EXEC spa_print 'dealId'
				EXEC spa_print @new_id

				SELECT @insert_columns_build_detail = CONCAT(@insert_columns_build_detail, ',[', sc.[name], ']')
				FROM sys.tables st
				INNER JOIN sys.columns sc ON sc.[object_id] = st.[object_id]
				WHERE st.[name] = 'source_deal_detail'
					AND sc.[name] NOT IN ('source_deal_detail_id', 'create_user', 'create_ts', 'update_user', 'update_ts') -- exclude these columns

				SET @insert_columns_build_detail = STUFF(@insert_columns_build_detail, 1, 1, '')
				SET @select_columns_build_detail = REPLACE(@insert_columns_build_detail, '[source_deal_header_id]', @new_id)

				SET @sql = '
						INSERT INTO source_deal_detail (' + @insert_columns_build_detail + ')
						SELECT ' + @select_columns_build_detail + '
						FROM source_deal_detail
						WHERE source_deal_header_id = ' + CAST(@deal_copy_from_id AS VARCHAR) + '
					'

				EXEC spa_print 'Deal Detail Insert: ', @sql
				EXEC (@sql)

				SET @insert_columns_build_detail = NULL
				SET @select_columns_build_detail = NULL

				INSERT INTO [fas_link_detail] ([link_id] ,[source_deal_header_id] ,[percentage_included] ,[hedge_or_item] ,[effective_date])
				SELECT @new_link_id, @new_id source_deal_header_id, [percentage_included], [hedge_or_item], [effective_date]
				FROM [fas_link_detail]
				WHERE [link_id] = @link_id
					AND [source_deal_header_id] = @deal_copy_from_id

				FETCH NEXT FROM fas_link_deal INTO @deal_copy_from_id, @deal_copy_from_d_id
			END

			CLOSE fas_link_deal
			DEALLOCATE fas_link_deal

		COMMIT TRAN

		EXEC spa_ErrorHandler 0,
			'Fas Link Header Table', 
			'spa_copy_link', 'Success', 
			'Fas Link detail copied successfully.', ''

		-- Alert throw if the deal volume exceeds.
		EXEC spa_alert_deal_vol_update @is_automatic = 'n', @call_from = 'Links'
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRAN

		IF ERROR_NUMBER() = 16915
		BEGIN
			CLOSE fas_link_deal
			DEALLOCATE fas_link_deal
		END
			SELECT
			ERROR_NUMBER() AS ErrorNumber,
			ERROR_SEVERITY() AS ErrorSeverity,
			ERROR_STATE() AS ErrorState,
			ERROR_PROCEDURE() AS ErrorProcedure,
			ERROR_LINE() AS ErrorLine,
			ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END

GO