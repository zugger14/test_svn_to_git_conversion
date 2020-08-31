
IF OBJECT_ID(N'[dbo].[spa_maintain_limit]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_maintain_limit]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
	Limit detail (maintain limit) CRUD operations
	Parameters
	@flag				: 'i' Insert maintain limit
						  'u' Update maintain limit
						  's' Select maintain limit information for matched limit header id
						  'a' Select mainain limit information for matched maintain limit id
						  'd' Delete maintain limit for matched maintain limit id
						  'r' Delete maintain limit for limit header id
	@maintain_limit_id	: Maintain Limit Id
	@limit_id			: Limit Header Id
	@active_grid_ids	: Maintain limit ids from grid comma separated
	@xml				: string of the Data to be inserted/updated in XML format
*/
CREATE PROCEDURE [dbo].[spa_maintain_limit]
    @flag					CHAR(1),
    @maintain_limit_id		INT = NULL,
	@limit_id				INT = NULL,
    --@logical_description	VARCHAR(100) = NULL,	
	--@limit_type				INT = NULL,
	--@var_criteria_det_id	INT = NULL,
	--@deal_type				INT = NULL,
	--@curve_id				INT = NULL,
	--@limit_value			FLOAT = NULL,
	--@limit_uom				INT = NULL,
	--@limit_currency			INT = NULL,
	--@tenor_month_from		INT = NULL,
	--@tenor_month_to			INT = NULL,
	--@tenor_granularity		INT = NULL,
	--added for new fx
	@active_grid_ids AS VARCHAR(MAX) = NULL,
	@xml VARCHAR(max) = NULL

AS

/*****************************Debug*****************************
DECLARE @flag	CHAR(1),
    @maintain_limit_id		INT = NULL,
	@limit_id				INT = NULL,
	@active_grid_ids AS VARCHAR(MAX) = NULL,
	@xml VARCHAR(max) = NULL
	--select * from maintain_limit where limit_type ='1584'
SELECT  @flag='i',@xml='<Root function_id=""><FormXML  limit_type="1584" limit_value="13" min_limit_value="1" limit_percentage="null" limit_uom="null" limit_currency="null" deal_type="null" curve_id="null" var_criteria_det_id="null" tenor_granularity="null" tenor_month_from="" tenor_month_to="" tenor_duration="null" delivery_duration="null" limit_id="2" maintain_limit_id="null" deal_subtype="null" effective_date="" logical_description="" is_active="y"></FormXML></Root>'
--*************************************************************/
	SET NOCOUNT ON
	DECLARE @SQL VARCHAR(MAX),
	@idoc INT

IF @flag IN ('i', 'u')
BEGIN
	BEGIN TRY
    EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
	IF OBJECT_ID('tempdb..#temp_maintain_limit') IS NOT NULL
		DROP TABLE #temp_maintain_limit
	SELECT
		NULLIF(maintain_limit_id, 'NULL') maintain_limit_id,
		logical_description,
		limit_id ,
		limit_type,
		NULLIF(var_criteria_det_id, 'NULL') var_criteria_det_id,
		NULLIF(deal_type, 'NULL') deal_type,
		NULLIF(curve_id, 'NULL') curve_id,
		NULLIF(limit_value, 'NULL') limit_value,
		NULLIF(min_limit_value, 'NULL') min_limit_value,
		NULLIF(limit_percentage, 'NULL') limit_percentage,
		NULLIF(limit_uom, 'NULL') limit_uom,
		NULLIF(limit_currency, 'NULL') limit_currency,
		NULLIF(tenor_month_from, 'NULL') tenor_month_from,
		NULLIF(tenor_month_to, 'NULL') tenor_month_to,
		NULLIF(tenor_duration, 'NULL') tenor_duration,
		NULLIF(delivery_duration, 'NULL') delivery_duration,
		NULLIF(tenor_granularity, 'NULL') tenor_granularity,
		NULLIF(deal_subtype, 'NULL') deal_subtype,
		NULLIF(effective_date,'') effective_date,
		is_active
		INTO #temp_maintain_limit
	FROM OPENXML(@idoc, '/Root/FormXML', 2)
	WITH (
		maintain_limit_id VARCHAR(10) '@maintain_limit_id',
		logical_description VARCHAR(100) '@logical_description',
		limit_id INT '@limit_id',
		limit_type VARCHAR(10) '@limit_type',
		var_criteria_det_id VARCHAR(10) '@var_criteria_det_id',
		deal_type VARCHAR(10) '@deal_type',
		curve_id VARCHAR(10) '@curve_id',
		limit_value VARCHAR(10) '@limit_value',
		min_limit_value VARCHAR(10) '@min_limit_value',
		limit_percentage VARCHAR(10) '@limit_percentage',
		limit_uom VARCHAR(10) '@limit_uom',
		limit_currency VARCHAR(10) '@limit_currency',
		tenor_month_from VARCHAR(10) '@tenor_month_from',
		tenor_month_to VARCHAR(10) '@tenor_month_to',
		tenor_duration VARCHAR(10) '@tenor_duration',
		delivery_duration VARCHAR(10) '@delivery_duration',
		tenor_granularity VARCHAR(10) '@tenor_granularity',
		deal_subtype VARCHAR(10)'@deal_subtype' ,
		effective_date DATETIME '@effective_date',
		is_active CHAR(2) '@is_active'
	) 
	
	UPDATE tml
	SET tml.tenor_month_from = NULL
		, tml.tenor_month_to = NULL
	FROM #temp_maintain_limit tml
	WHERE tml.limit_type NOT IN (1581, 1587)

	IF @flag = 'i'
	BEGIN
		BEGIN TRY
			INSERT INTO maintain_limit
				(logical_description,
				limit_id,
				limit_type,
				var_criteria_det_id,
				deal_type,
				curve_id,
				limit_value,
				min_limit_value,
				limit_uom,
				limit_currency,
				tenor_month_from,
				tenor_month_to,
				tenor_granularity,
				deal_subtype,
				effective_date,
				limit_percentage,
				is_active)
			SELECT
				logical_description,
				limit_id,
				limit_type,
				var_criteria_det_id,
				deal_type,
				curve_id,
				limit_value,
				min_limit_value,
				limit_uom,
				limit_currency,
				COALESCE(tenor_month_from,tenor_duration,NULL),
				COALESCE(tenor_month_to,delivery_duration, NULL),
				tenor_granularity,
				deal_subtype,
				effective_date,
				limit_percentage,
				is_active
			FROM #temp_maintain_limit
			
			DECLARE @new_id INT
			SET @new_id = SCOPE_IDENTITY()
			
			EXEC spa_ErrorHandler 0, 
				'Maintain Limit', 
				'spa_maintain_limit', 
				'Success', 
				'Data saved successfully.', 
				@new_id
		END TRY
		BEGIN CATCH
    	EXEC spa_ErrorHandler 1, 
			'Maintain Limit', 
			'spa_maintain_limit', 
			'DB Error', 
			'Failed to insert maintain limit data.', 
			''
		END CATCH
	END

	IF @flag = 'u'
		BEGIN
			BEGIN TRY
				UPDATE maintain_limit
				SET logical_description = t.logical_description,
    				limit_id = t.limit_id,
    				limit_type = t.limit_type,
    				var_criteria_det_id = t.var_criteria_det_id,
    				deal_type = t.deal_type,
    				curve_id = t.curve_id,
    				limit_value = t.limit_value,
					min_limit_value = t.min_limit_value,
    				limit_uom = t.limit_uom,
    				limit_currency = t.limit_currency,
    				tenor_month_from = COALESCE(t.tenor_month_from,t.tenor_duration,NULL),
    				tenor_month_to = COALESCE(t.tenor_month_to,t.delivery_duration, NULL),
    				tenor_granularity = t.tenor_granularity,
					deal_subtype = t.deal_subtype,
					effective_date = t.effective_date,
					limit_percentage = t.limit_percentage,
    				is_active = t.is_active 
				FROM #temp_maintain_limit AS t
				INNER JOIN maintain_limit ml ON ml.maintain_limit_id = t.maintain_limit_id

				SELECT @maintain_limit_id = maintain_limit_id FROM #temp_maintain_limit

				EXEC spa_ErrorHandler 0, 'Maintain Limit', 'spa_maintain_limit', 'Success', 'Data Saved Successfully.', @maintain_limit_id
			END TRY
			BEGIN CATCH
				EXEC spa_ErrorHandler 1, 
				'Maintain Limit',  
				'spa_maintain_limit', 
				'DB Error', 
				'Failed to update maintain limit data.', 
				''
			END CATCH
		END
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler 1, 
		'Maintain Limit',  
		'spa_maintain_limit', 
		'DB Error', 
		'Failed to update maintain limit data.', 
		''
	END CATCH
END
ELSE IF @flag = 's'
BEGIN
    SELECT ml.maintain_limit_id AS [ID],
		   dbo.FNAHyperLinkText(10181311, ml.logical_description, ml.maintain_limit_id) AS [Logical Description],
		   ml.limit_id AS [Limit ID],
		   sdv.code AS [Limit Type],
		   vmcd.[name] AS [VaR Criteria],
		   sdt.source_deal_type_name AS [Deal Type],
		   spcd.curve_name AS [Index],
		   ml.limit_value AS [Limit Value],
		   su.uom_name AS [Limit UOM],
		   sc.currency_name AS [Limit Currency],
		   ml.tenor_month_from AS [Tenor From],
		   ml.tenor_month_to AS [Tenor To],
		   sdv3.code AS [Tenor Granularity]
	FROM   maintain_limit ml
	LEFT JOIN static_data_value sdv ON sdv.value_id = ml.limit_type
	LEFT JOIN var_measurement_criteria_detail vmcd ON vmcd.id = ml.var_criteria_det_id
	LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = ml.deal_type
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = ml.curve_id
	LEFT JOIN source_uom su ON su.source_uom_id = ml.limit_uom
	LEFT JOIN source_currency sc ON sc.source_currency_id = ml.limit_currency
	LEFT JOIN static_data_value sdv3 ON sdv3.value_id = ml.tenor_granularity
    WHERE ml.limit_id = @limit_id
    
END
ELSE IF @flag = 't'
BEGIN
    SELECT ml.maintain_limit_id,
		   ml.limit_id AS limit_id,
		   ml.logical_description AS logical_description,
		   sdv.code AS limit_type,
		   vmcd.[name] AS var_criteria_det_id,
		   sdt.source_deal_type_name AS deal_type,
		   spcd.curve_name AS curve_id,
		   ml.min_limit_value AS min_limit_value,
		   ml.limit_value AS limit_value,
		   CONVERT(VARCHAR(10),ml.effective_date ,101) AS effective_date,
		   su.uom_name AS limit_uom,
		   sc.currency_name AS limit_currency,
		   ml.tenor_month_from tenor_month_from,
		   ml.tenor_month_to tenor_month_to,
		   sdv3.code AS tenor_granularity,
		   CASE WHEN ml.is_active = 'n' THEN 'No'
		   ELSE 'Yes' END AS is_active
		   
	FROM   maintain_limit ml
	LEFT JOIN static_data_value sdv ON sdv.value_id = ml.limit_type
	LEFT JOIN var_measurement_criteria_detail vmcd ON vmcd.id = ml.var_criteria_det_id
	LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = ml.deal_type
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = ml.curve_id
	LEFT JOIN source_uom su ON su.source_uom_id = ml.limit_uom
	LEFT JOIN source_currency sc ON sc.source_currency_id = ml.limit_currency
	LEFT JOIN static_data_value sdv3 ON sdv3.value_id = ml.tenor_granularity
    WHERE ml.limit_id = @limit_id
    
END
ELSE IF @flag = 'a'
BEGIN
    SELECT ml.maintain_limit_id, 
		   ml.logical_description, 
		   ml.limit_id,
           ml.limit_type, 
		   ml.var_criteria_det_id, 
		   ml.deal_type, 
		   ml.curve_id,
           ml.limit_value, 
		   ml.limit_uom, 
		   ml.limit_currency, 
		   ml.tenor_month_from tenor_month_from,
		   ml.tenor_month_to tenor_month_to,
		   ml.tenor_granularity,
		   CASE WHEN  ml.is_active = 'n' THEN 'n'
		   ELSE 'y' END,
		   ml.effective_date,
		   ml.deal_subtype,
		   ml.min_limit_value,
		   ml.limit_percentage
    FROM maintain_limit ml
    WHERE ml.maintain_limit_id = @maintain_limit_id
END

ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		DELETE FROM maintain_limit WHERE maintain_limit_id = @maintain_limit_id
	
		EXEC spa_ErrorHandler 0, 'Maintain Limit', 'spa_maintain_limit', 'Success', 'Data have been saved successfully.', @maintain_limit_id
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler 1, 'Maintain Limit', 'spa_maintain_limit', 'DB Error', 'Failed to delete limit header data.',''
	END CATCH
END
ELSE IF @flag = 'r'
BEGIN
	BEGIN TRY
		DELETE ml
		FROM maintain_limit ml
		INNER JOIN dbo.FNASplit(@active_grid_ids, ',') di ON di.item = ml.maintain_limit_id
		WHERE limit_id = @limit_id

		EXEC spa_ErrorHandler 0, 
				'Maintain Limit', 
				'spa_maintain_limit', 
				'Success', 
				'Changes have been saved successfully.',
				@limit_id
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler 1, 
			'Maintain Limit', 
			'spa_maintain_limit', 
			'DB Error', 
			'Failed to delete limit header data.',
			''
	END CATCH
END

GO