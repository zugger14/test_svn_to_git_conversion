
IF OBJECT_ID(N'[dbo].[spa_rfx_resolve_text_param]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_resolve_text_param]
GO
/**
	Resolve dynamic text report item defined in special format (eg. <#as_of_date#>) to its value.
	Parameters
	@criteria		: Report parameter criteria filter string
	@param_value	: Text param value
	@runtime_user	: Run time user called from RDL 
*/
CREATE PROCEDURE [dbo].[spa_rfx_resolve_text_param]
    @criteria VARCHAR(max) = NULL,
	@param_value VARCHAR(max) = NULL,
	@runtime_user			NVARCHAR(200) = NULL
AS
/*
DECLARE 
@criteria VARCHAR(5000) = 'sub_id=122,stra_id=123,book_id=124,sub_book_id=4,curve_id=4595,label_counterparty_id=NULL'
,@param_value VARCHAR(5000) = 'Report for Book : <#sub_book_id#> and Curve : <#curve_id#>'
--*/
SET NOCOUNT ON

IF ISNULL(@runtime_user, '') <> '' AND @runtime_user <> dbo.FNADBUser()   
BEGIN
	--EXECUTE AS USER = @runtime_user;
	DECLARE @contextinfo VARBINARY(128)
	SELECT @contextinfo = CONVERT(VARBINARY(128), @runtime_user)
	SET CONTEXT_INFO @contextinfo
END

DECLARE @language_id INT
SELECT @language_id = [language] FROM application_users WHERE user_login_id = @runtime_user
--SELECT @language_id = 101603

BEGIN TRY
	SELECT @param_value = dbo.FNADecodeXML(@param_value)
	IF CHARINDEX('<#', @param_value, 0) = 0
	BEGIN
		SELECT ISNULL(translated_keyword,@param_value) [value]
		FROM locale_mapping 
			WHERE language_id = @language_id AND original_keyword = @param_value
	END
	ELSE
	BEGIN
		IF OBJECT_ID('tempdb..#tmp_param_values') IS NOT NULL
			DROP TABLE #tmp_param_values

		CREATE TABLE #tmp_param_values (
			context VARCHAR(1000) COLLATE DATABASE_DEFAULT 
			, context_real_value varchar(1000) COLLATE DATABASE_DEFAULT 
			, context_resolved_value VARCHAR(5000) COLLATE DATABASE_DEFAULT 
		)

		INSERT INTO #tmp_param_values(context, context_real_value)
		SELECT SUBSTRING(t.item, CHARINDEX('<#', t.item) + 2, LEN(t.item)), REPLACE(SUBSTRING(l.item, CHARINDEX('=',l.item) + 1, LEN(l.item)), '!', ',')
		FROM dbo.FNASplit(@param_value, '#>') t
		INNER JOIN dbo.SplitCommaSeperatedValues(@criteria) l ON SUBSTRING(l.item, 0, CHARINDEX('=',l.item)) = SUBSTRING(t.item, CHARINDEX('<#', t.item) + 2, LEN(t.item)) 
		
		DECLARE @context VARCHAR(5000), @cur_value VARCHAR(5000)
		IF CURSOR_STATUS('global','cur_context')>=-1
		BEGIN
			DEALLOCATE cur_context
		END
		DECLARE cur_context CURSOR FOR
		SELECT context from #tmp_param_values

		OPEN cur_context
		FETCH NEXT FROM cur_context INTO @context
		WHILE @@FETCH_STATUS = 0
		BEGIN
			DECLARE @filter_values VARCHAR(5000)
			SELECT @filter_values = t.context_real_value
			FROM #tmp_param_values t
			WHERE t.context = @context
			
			IF @context in ( 'counterparty_id','source_counterparty_id')
			BEGIN
				
				SELECT @cur_value = STUFF(
					(SELECT ', '  + sc.counterparty_name
					FROM source_counterparty sc
					INNER JOIN dbo.SplitCommaSeperatedValues(@filter_values) l ON ISNULL(NULLIF(l.item, 'NULL'),-1) = sc.source_counterparty_id
					FOR XML PATH(''))
				, 1, 1, '')
			END
			ELSE IF @context = 'contract_id'
			BEGIN
				SELECT @cur_value = STUFF(
					(SELECT ', '  + cg.[contract_name]
					FROM contract_group cg
					INNER JOIN dbo.SplitCommaSeperatedValues(@filter_values) l ON ISNULL(NULLIF(l.item, 'NULL'),-1) = cg.contract_id
					FOR XML PATH(''))
				, 1, 1, '')

			END
			ELSE IF @context = 'location_id'
			BEGIN
				SELECT @cur_value = STUFF(
					(SELECT ', '  + sml.Location_Name
					FROM source_minor_location sml
					INNER JOIN dbo.SplitCommaSeperatedValues(@filter_values) l ON ISNULL(NULLIF(l.item, 'NULL'),-1) = sml.source_minor_location_id
					FOR XML PATH(''))
				, 1, 1, '')

			END
			ELSE IF @context IN ('sub_id', 'stra_id', 'book_id')
			BEGIN
				SELECT @cur_value = STUFF(
					(SELECT ', '  + ph.[entity_name]
					FROM portfolio_hierarchy ph
					INNER JOIN dbo.SplitCommaSeperatedValues(@filter_values) l ON ISNULL(NULLIF(l.item, 'NULL'),ph.[entity_id]+1) = ph.[entity_id]
					FOR XML PATH(''))
				, 1, 1, '')

			END
			ELSE IF @context IN ('sub_book_id')
			BEGIN
				SELECT @cur_value = STUFF(
					(SELECT ', '  + ssbm.[logical_name]
					FROM source_system_book_map ssbm
					INNER JOIN dbo.SplitCommaSeperatedValues(@filter_values) l ON ISNULL(NULLIF(l.item, 'NULL'), ssbm.[book_deal_type_map_id] + 1) = ssbm.[book_deal_type_map_id]
					FOR XML PATH(''))
				, 1, 1, '')

			END
			ELSE IF @context IN ('curve_id','source_curve_def_id')
			BEGIN
				SELECT @cur_value = STUFF(
					(SELECT ', '  + spcd.[curve_name]
					FROM source_price_curve_def spcd
					INNER JOIN dbo.SplitCommaSeperatedValues(@filter_values) l ON ISNULL(NULLIF(l.item, 'NULL'), spcd.[source_curve_def_id] + 1) = spcd.[source_curve_def_id]
					FOR XML PATH(''))
				, 1, 1, '')

			END
			ELSE
			BEGIN
				SELECT @cur_value = @filter_values
			END

			UPDATE t SET t.context_resolved_value = '[' + ISNULL(@cur_value, 'NULL') + ']'
			FROM #tmp_param_values t
			WHERE t.context = @context

			FETCH NEXT FROM cur_context INTO @context 
		END
		CLOSE cur_context
		DEALLOCATE cur_context

		DECLARE @final_output VARCHAR(3000)
		
		SELECT @final_output = REPLACE(ISNULL(@final_output, @param_value), '<#' + t.context + '#>', t.context_resolved_value)
		FROM #tmp_param_values t 
		
		SELECT @final_output [value]
		
	END
	
END TRY
BEGIN CATCH
	ROLLBACK
	DECLARE @err_msg VARCHAR(1000) = ERROR_MESSAGE()
	EXEC spa_ErrorHandler 1, 'Reporting FX', 'spa_rfx_resolve_text_param', 'Failed', 'Param resolve failed.', @err_msg
END CATCH
--EXEC spa_rfx_resolve_text_param 'sub_id=12,counterparty_id=3830','report: <#counterparty_id#>'
--EXEC spa_rfx_resolve_text_param 'sub_id=12,counterparty_id=3830','Report for : counterparty_id'
