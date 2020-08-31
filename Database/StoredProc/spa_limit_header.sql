IF OBJECT_ID(N'[dbo].[spa_limit_header]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_limit_header]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Generic procedure for CRUD operations on Header Limit.

	Parameters
	@flag			:	Operation flag that decides the action to be performed.
	@limit_id		:	Identifier of Header Limit.
	@limit_name		:	Name of the Specific Header Limit.
	@form_xml		:	String of the Header Limit data to be inserted/updated in form of XML.
	@portfolio_xml	:	Portfolio data built in form of XML.
	@del_limit_ids	:	String of combination of identifier of Header Limit for multiple deletion.
*/

CREATE PROCEDURE [dbo].[spa_limit_header]
    @flag				CHAR(1),
    @limit_id			BIGINT = NULL,
	@limit_name			VARCHAR(MAX) = NULL,
	@form_xml			NVARCHAR(MAX) = NULL,
	@portfolio_xml		VARCHAR(MAX) = NULL,
	@del_limit_ids		VARCHAR(1000) = NULL
AS

/******* DEBUG *******
DECLARE @flag				CHAR(1),
	@limit_id			BIGINT = NULL,
	@limit_name			VARCHAR(MAX) = NULL,
	@form_xml			VARCHAR(MAX) = NULL,
	@portfolio_xml		VARCHAR(MAX) = NULL,
	@del_limit_ids		VARCHAR(1000) = NULL

	select   @flag='i',@form_xml='<Root function_id="10181300"><FormXML  limit_name="test1" limit_for="20201" curve_source_id="4500" commodity="" role="" trader_id="2443" limit_id="1589341038812" counterparty_id="" active="y"></FormXML></Root>',@portfolio_xml='<Root><MappingXML  sub_book_id="" deal_ids="" portfolio_group_id="" trader="" commodity_id="" deal_type_id="" counterparty_id="" fixed_term="0" term_start="" term_end="" relative_term="0" starting_month="" no_of_month=""></MappingXML></Root>'
--*/

SET NOCOUNT ON

DECLARE @SQL VARCHAR(MAX)
	, @portfolio_mapping_source INT
	, @idoc INT

--PRINT 'Process table' + @process_table

--select * from static_data_value where type_id = 23200
SET @portfolio_mapping_source = 23200	-- Mantain Limit portfolio mapping source

IF @flag IN ('i', 'u')
	BEGIN
		BEGIN TRY

		EXEC sp_xml_preparedocument @idoc OUTPUT, @form_xml
		IF OBJECT_ID('tempdb..#temp_limit_header') IS NOT NULL
		DROP TABLE #temp_limit_header

		SELECT
			limit_id,
			limit_name,
			limit_for,
			commodity,
			trader_id,
			[role],
			curve_source_id,
			counterparty_id,
			active
			INTO #temp_limit_header
		FROM OPENXML(@idoc, '/Root/FormXML', 1)
		WITH (
			limit_id					NUMERIC (32,18),
			limit_name					NVARCHAR(100),
			limit_for					VARCHAR(100),
			commodity					VARCHAR(100),
			trader_id					VARCHAR(100),
			[role]						VARCHAR(100),
			[curve_source_id]			VARCHAR(100),
			counterparty_id				VARCHAR(100),
			active						CHAR(2)
		)
		
		BEGIN TRAN
		IF @flag = 'i'
		BEGIN		
			IF NOT EXISTS (SELECT 1 FROM limit_header lh INNER JOIN #temp_limit_header temp ON lh.limit_name = temp.limit_name)
			BEGIN
				INSERT INTO limit_header
				(
					limit_name,
					limit_for,
					trader_id,
					commodity,
					[role],
					curve_source,
					counterparty_id,
					active
				)
				SELECT
					limit_name,
					limit_for,
					NULLIF(trader_id,''),
					NULLIF(commodity,''),
					NULLIF([role],''),
					NULLIF(curve_source_id,''),
					NULLIF(counterparty_id,''),
					active
				FROM #temp_limit_header
			
				SET @limit_id = SCOPE_IDENTITY()
				
				EXEC spa_generic_portfolio_mapping_template @flag = @flag, @mapping_source_id = @portfolio_mapping_source, @mapping_source_value_id = @limit_id, @xml = @portfolio_xml 

				EXEC spa_ErrorHandler 0, 
					'Limit Header', 
					'spa_limit_header', 
					'Success', 
					'Changes have been saved successfully.',
					@limit_id
			END
			ELSE
			BEGIN
				EXEC spa_ErrorHandler 1, 
				'Limit Header', 
				'spa_limit_header', 
				'DB Error', 
				'Duplicate data in <b>Name</b>.',
				''
			END
		END
		ELSE IF @flag = 'u'
		BEGIN
			SELECT @limit_id = limit_id FROM #temp_limit_header

			IF NOT EXISTS (SELECT 1 FROM limit_header lh INNER JOIN #temp_limit_header temp ON lh.limit_name = temp.limit_name AND lh.limit_id <> @limit_id)
			BEGIN
				UPDATE lh
					SET limit_name = t.limit_name,
					limit_for = t.limit_for,
					trader_id = NULLIF(t.trader_id,''),
					commodity = NULLIF(t.commodity,''),
					[role] = NULLIF(t.[role],''),
					[curve_source] = NULLIF(t.[curve_source_id],''),
					lh.counterparty_id = NULLIF(t.counterparty_id,''),
					active = t.active
				FROM #temp_limit_header AS t
				INNER JOIN limit_header lh ON lh.limit_id = t.limit_id
				
				
				EXEC spa_generic_portfolio_mapping_template @flag = @flag, @mapping_source_id = @portfolio_mapping_source, @mapping_source_value_id = @limit_id, @xml = @portfolio_xml 

				EXEC spa_ErrorHandler 0, 
					'Limit Header', 
					'spa_limit_header', 
					'Success', 
					'Changes have been saved successfully.',
					''
			END
			ELSE
			BEGIN
				EXEC spa_ErrorHandler 1, 
				'Limit Header', 
				'spa_limit_header', 
				'DB Error', 
				'Duplicate data in <b>Name</b>.',
				''
			END
		END	-- ends flag u block
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK
		EXEC spa_ErrorHandler 1, 
			'Limit Header', 
			'spa_limit_header', 
			'DB Error', 
			'Failed to save data.',
			''
	END CATCH
END --ends @flag IN ('i', 'u') block
ELSE IF @flag = 't'
BEGIN
	SELECT 
	  sdv.code AS limit_for,
	  lh.limit_id AS limit_id,
	  sdv.value_id,        
	  lh.limit_name AS limit_description,
	  st.trader_id AS trader,
	  sc.commodity_name AS commodity,
	  asr.role_name AS role,
	  sdv1.code AS curve_source,
	  sc2.source_counterparty_id AS counterparty
	FROM static_data_value sdv
	LEFT join limit_header lh ON lh.limit_for = sdv.value_id
	LEFT JOIN source_traders st ON lh.trader_id = st.source_trader_id
	LEFT JOIN source_commodity sc ON lh.commodity = sc.source_commodity_id
	LEFT JOIN application_security_role asr ON lh.[role] = asr.role_id
	LEFT JOIN static_data_value sdv1 ON lh.curve_source = sdv1.value_id
	LEFT JOIN source_counterparty AS sc2 ON sc2.source_counterparty_id = lh.counterparty_id
	WHERE sdv.type_id = 20200 
	ORDER BY limit_for, limit_description ASC
END
ELSE IF @flag = 'a'
BEGIN
    SELECT lh.limit_id,
           lh.limit_name,
           lh.limit_for,
           lh.trader_id,
           lh.commodity,
           lh.[role],
           lh.curve_source,
           lh.book_id,
           lh.counterparty_id,
           CASE WHEN lh.active = 'n' THEN 'n'
           ELSE 'y' END AS [active]
    FROM limit_header lh
    WHERE  lh.limit_id = @limit_id
END
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
	BEGIN TRAN
		DECLARE @portfolio_mapping_source_id INT = NULL

		SELECT @portfolio_mapping_source_id = portfolio_mapping_source_id
		FROM portfolio_mapping_source
		WHERE mapping_source_usage_id = @limit_id
			AND mapping_source_value_id = @portfolio_mapping_source
		
		-------limit header------
		SELECT DISTINCT @limit_name = CONCAT((@limit_name + ','), lh.limit_name)
		FROM limit_header lh
		INNER JOIN maintain_limit ml ON ml.limit_id = lh.limit_id
		INNER JOIN dbo.FNASplit(@del_limit_ids, ',') di ON di.item = lh.limit_id

		IF EXISTS (
			SELECT 1
			FROM maintain_limit ml
			INNER JOIN dbo.FNASplit(@del_limit_ids, ',') di ON di.item = ml.limit_id
		)
		BEGIN
			DECLARE @msg VARCHAR(MAX)
			SET @msg = 'Failed to delete <b>' + @limit_name + '</b>. Limit(s) are entered for this <b>' + @limit_name + '</b>.'
			EXEC spa_ErrorHandler 1, 'Limit Header', 'spa_limit_header', 'DB Error', @msg, ''
			RETURN
		END
		ELSE
		BEGIN
			DELETE ml
			FROM maintain_limit ml
			INNER JOIN dbo.FNASplit(@del_limit_ids, ',') di ON di.item = ml.limit_id
		END
		
		DELETE pms
		FROM portfolio_mapping_source pms
		INNER JOIN dbo.FNASplit(@del_limit_ids, ',') di ON di.item = pms.mapping_source_usage_id
		WHERE mapping_source_value_id = @portfolio_mapping_source

		DELETE lh
		FROM limit_header lh
		INNER JOIN dbo.FNASplit(@del_limit_ids, ',') di ON di.item = lh.limit_id
		
		EXEC spa_ErrorHandler 0, 'Limit Header', 'spa_limit_header', 'Success', 'Data have been saved successfully.', @del_limit_ids
	COMMIT
	--ROLLBACK
	END TRY
	BEGIN CATCH
	ROLLBACK
		EXEC spa_ErrorHandler 1, 'Limit Header', 'spa_limit_header', 'DB Error', 'Failed to delete limit header data.', ''
	END CATCH
END
