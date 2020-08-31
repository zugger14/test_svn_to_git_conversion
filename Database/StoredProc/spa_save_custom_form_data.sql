IF OBJECT_ID(N'[dbo].[spa_save_custom_form_data]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_save_custom_form_data]
GO
 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 --=============================================
 --Author:		gsapkota@pioneersolutionsglobal.com
 --Create date: 2018-07-19
 --Description:	<saves and loads data from custom form and grid>
 --=============================================
CREATE PROCEDURE spa_save_custom_form_data 
 --Add the parameters for the stored procedure here
	@flag							CHAR(1) = 's'
	, @begin_date					DATETIME = NULL 
	, @calendar_from_month			INT = NULL	
	, @calendar_to_month			INT = NULL
	, @detail						CHAR(1) = 'n'
	, @region_id					varchar(2000) = NULL
	, @program_scope				INT = NULL
	, @state_value_id				INT = NULL
	, @grid_xml						VARCHAR(MAX)= NULL
	, @value_id						INT = NULL
	, @is_new						CHAR(1) = 'y'
	, @tier_id						INT = NULL
	, @state_properties_details_id	INT = NULL
	, @selected_tier_value			INT = NULL
	, @source_deal_header_id		INT = NULL
	, @template_id					INT = NULL
	, @details_id_arr				VARCHAR(2000) = NULL
	, @tier_id_arr					VARCHAR(2000) = NULL
	, @value_id_arr					VARCHAR(2000) = NULL
AS
/* -- **DEBUG **
DECLARE @flag						CHAR(1) = 's'
	, @begin_date					DATETIME = NULL 
	, @calendar_from_month			INT = NULL	
	, @calendar_to_month			INT = NULL
	, @detail						CHAR(1) = 'n'
	, @region_id					varchar(2000) = NULL
	, @program_scope				INT = NULL
	, @state_value_id				INT = NULL
	, @grid_xml						VARCHAR(MAX)= NULL
	, @value_id						INT = NULL
	, @is_new						CHAR(1) = 'y'
	, @tier_id						INT = NULL
	, @state_properties_details_id	INT = NULL
	, @selected_tier_value			INT = NULL
	, @source_deal_header_id		INT = NULL
	, @template_id					INT = NULL
	, @details_id_arr				VARCHAR(2000) = NULL
	, @tier_id_arr					VARCHAR(2000) = NULL
	, @value_id_arr					VARCHAR(2000) = NULL
	--select @flag='g',@grid_xml='<Grid><GridRow tier_id="50000010"  technology_id="50000620"  technology_subtype="50000662"  price_index="7180" ></GridRow></Grid>'
--*/
SET NOCOUNT ON;

DECLARE @idoc INT

IF @begin_date = ''
BEGIN
	Set @begin_date = NULL
END

IF @flag = 's' --save form data
BEGIN
	IF @state_value_id NOT IN (
	SELECT state_value_id FROM state_properties
	)
	BEGIN
		INSERT INTO state_properties (
		begin_date			
		, calendar_from_month	
		, calendar_to_month	
		, detail				
		, region_id			
		, program_scope		
		, state_value_id
		) VALUES
		(
		 ISNULL(@begin_date, NULL)			
		, @calendar_from_month  
		, @calendar_to_month	
		, @detail				
		, @region_id			
		, NULLIF(@program_scope, 0)		
		, @state_value_id		
		)
		EXEC spa_ErrorHandler 0, 
					'Save custom Form Data', 
					'spa_save_custom_form_data', 
					'Success', 
					'Changes have been updated successfully.',
					@state_value_id
	END
	ELSE IF @state_value_id IN (SELECT state_value_id FROM state_properties)
	BEGIN 
			UPDATE state_properties
			SET calendar_from_month	 = @calendar_from_month
				, calendar_to_month	 = @calendar_to_month
				, region_id			 = @region_id
				, begin_date		 = @begin_date
				, program_scope		 = NULLIF(@program_scope, 0)
				, detail		     = @detail
			WHERE state_value_id	 = @state_value_id

			EXEC spa_ErrorHandler 0, 
						'Save custom Form Data', 
						'spa_save_custom_form_data', 
						'Success', 
						'Changes have been saved successfully.',
						@state_value_id
	END
END

ELSE IF @flag = 'f' -- load form data
BEGIN
	IF @value_id <> ''
	BEGIN
		DECLARE @code VARCHAR(MAX)
		SELECT @code = COALESCE(@code+',' , '') + sdv.code
		FROM (
			SELECT --state_value_id,  
			CAST ('<M>' + REPLACE(region_id, ',', '</M><M>') + '</M>' AS XML) AS region_id  
			FROM  state_properties
			WHERE state_value_id = @value_id
		) AS A 
		CROSS APPLY region_id.nodes ('/M') AS Split(a)
		INNER JOIN static_data_value sdv
			ON Split.a.value('.', 'VARCHAR(100)') = sdv.value_id
			AND sdv.type_id = 11150

		IF OBJECT_ID('tempdb..#region') IS NOT NULL
			DROP table #region
		SELECT @value_id [state_value_id], @code [code]
		INTO #region

		SELECT sdv.value_id AS state_value_id
			, sdv.code
			, sdv.[description]
			, ISNULL(sp.region_id, '') [region_id]	
			, ISNULL(r.code, '') [region_code]			
			, ISNULL(sp.begin_date, NULL)	[begin_date]
			, ISNULL(sp.program_scope, '') [program_scope]
			, ISNULL(sp.calendar_from_month, '') [calendar_from_month]
			, ISNULL(sp.calendar_to_month, '') [calendar_to_month]	
			, sp.detail			
		FROM static_data_value sdv 
		Left JOIN state_properties sp 
			ON sdv.value_id = sp.state_value_id
		INNER JOIN #region r
			on r.state_value_id = sp.state_value_id
		WHERE sdv.value_id = @value_id
	END
END


ELSE IF @flag = 'g' --save grid data
BEGIN
	DECLARE @errmsg  VARCHAR(200)
	EXEC sp_xml_preparedocument @idoc OUTPUT, @grid_xml

	IF OBJECT_ID('tempdb..#temp_state_properties_details') IS NOT NULL
		DROP table #temp_state_properties_details
	
	CREATE TABLE #temp_state_properties_details (	
		[tier_id]				INT,
		[technology_id]			INT,
		[technology_subtype_id]	INT,
		[price_index]			INT,
		[banking_years]			INT,
		[effective_date]        DATE
	)

	INSERT INTO #temp_state_properties_details 
	SELECT NULLIF(tier_id, ''),
		NULLIF(technology_id, ''),
		NULLIF(technology_subtype_id, ''),
		NULLIF([price_index], ''),
		NULLIF([banking_years], ''),
	    NULLIF([effective_date],'')
	FROM OPENXML(@idoc, '/Grid/GridRow', 1)
	WITH (
		tier_id						INT	'@tier_id',
		technology_id				INT	'@technology_id',
		technology_subtype_id		INT	'@technology_subtype_id',
		price_index					INT	'@price_index',
		banking_years				INT	'@banking_years',
		effective_date				DATE '@effective_date'
	)

	-------------------------------------------------check if duplicate data are inserted into temp table---------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------

	DECLARE @distinct INT, @all INT
	SET @distinct = (
		SELECT COUNT(*) FROM 
		(
			SELECT DISTINCT tier_id
				, technology_id
				, technology_subtype_id
				, price_index
				, effective_date
				--, banking_years
			FROM #temp_state_properties_details
		) T
	)
	SET @all = (
		SELECT COUNT(*) FROM #temp_state_properties_details
	)
	--SELECT @distinct , @all

	IF @distinct <> @all
	BEGIN
		EXEC spa_ErrorHandler -1,
			'Save Custom grid data'
			, 'spa_save_custom_form_data'
			, 'Error'
			, 'Duplicate Grid Data cannot be saved!'
			, ''
		RETURN
	END
	ELSE
	BEGIN
		BEGIN TRY
			DELETE FROM state_properties_details where state_value_id = @state_value_id
			INSERT INTO state_properties_details (state_value_id, technology_id, technology_subtype_id, tier_id, price_index, banking_years, effective_date)
			SELECT @state_value_id
				, NULLIF(technology_id, 0)
				, NULLIF(technology_subtype_id, 0)
				, NULLIF(tier_id, 0)
				, NULLIF(price_index, 0)
				, NULLIF(banking_years, 0)
				, effective_date
			FROM #temp_state_properties_details

			DECLARE @inserted_id VARCHAR(100) = CAST(SCOPE_IDENTITY() AS VARCHAR(100))

			EXEC spa_ErrorHandler @@ERROR,
				'Save Custom Grid data'
				, 'spa_save_custom_form_data'
				, 'Success'
				, 'Changes have been saved successfully.'
				, @inserted_id
		END TRY
		BEGIN CATCH
			EXEC spa_ErrorHandler -1,
				'Save Custom grid data'
				, 'spa_save_custom_form_data'
				, 'Error'
				, 'Grid Data cannot be saved!'
				, ''
		END CATCH
	END
END

ELSE IF @flag = 'l' --load grid data
 BEGIN
 SELECT state_properties_details_id
	,state_value_id
	, tier_id
	, technology_id		
	, technology_subtype_id	
	, price_index
	, effective_date
	, banking_years
  FROM state_properties_details 
  WHERE state_value_id = @state_value_id
 END

 ELSE IF @flag = 'd'  
 BEGIN
	--DECLARE @check_sql VARCHAR(500)
	--SET @check_sql = 
	IF EXISTS (
		SELECT 1 FROM state_properties_details spd
		INNER JOIN eligibility_mapping_template_detail emtd
			ON emtd.state_value_id = spd.state_value_id 
		INNER JOIN dbo.SplitCommaSeperatedValues(@tier_id_arr) a
			ON cast(emtd.tier_id AS VARCHAR) = a.item
		INNER JOIN dbo.SplitCommaSeperatedValues(@value_id_arr) b
			ON cast(emtd.state_value_id AS VARCHAR) = b.item
		)
	BEGIN
		EXEC spa_ErrorHandler -1,
				'Save Custom Grid data'
				, 'spa_save_custom_form_data'
				, 'Error'
				, 'Please Delete Data from <b>Eligibility Mapping Grid</b> first.'
				, 'Dependency'
			
		
	END
	ELSE
	BEGIN
		BEGIN TRY
			DELETE spd FROM state_properties_details spd 
			INNER JOIN dbo.SplitCommaSeperatedValues(@value_id_arr) c
				ON CAST(spd.state_value_id AS VARCHAR(20)) = c.item 
			INNER JOIN dbo.SplitCommaSeperatedValues(@details_id_arr) d
				ON CAST(spd.state_properties_details_id AS VARCHAR(20)) = d.item
	
	
			EXEC spa_ErrorHandler 0,
				'Save Custom Grid data'
				, 'spa_save_custom_form_data'
				, 'Success'
				, 'Changes have been saved successfully.'
				, ''
		END TRY
		BEGIN CATCH
			EXEC spa_ErrorHandler -1,
			'Save Custom Grid data'
			, 'spa_save_custom_form_data'
			, 'Error'
			, 'Grid data cannot be deleted!.'
			, ''
		END CATCH
	END
 END
 ELSE IF @flag = 'o'
 BEGIN
	IF OBJECT_ID('tempdb..#price_index') IS NOT NULL
	DROP table #price_index
	
	CREATE TABLE #price_index
	(
	[Curve ID] INT
	, [Index] VARCHAR(MAX)
	)
 
	INSERT INTO #price_index ([Curve ID], [Index]) VALUES(NULL, '')
 
	INSERT INTO #price_index ([Curve ID], [Index])
	EXEC spa_GetAllPriceCurveDefinitions 'e'
	
	SELECT * FROM #price_index
 END

 ELSE IF @flag = 't'
 BEGIN
	DECLARE @sql VARCHAR(MAX)
	SET @sql = 'Select null id, '''' value  UNION ALL SELECT value_id, code FROM static_data_value AS sdv WHERE sdv.[type_id] = 10009' 
			
	
	IF (@selected_tier_value <> '' AND @state_value_id <> '')
		SET @sql = 'SELECT DISTINCT sdv.value_id AS id, sdv.code AS value 
			FROM static_data_value sdv
			INNER JOIN state_properties_details spd 
				ON spd.technology_id = sdv.value_id
			WHERE sdv.type_id = 10009 
				AND spd.state_value_id = ' + CAST(@state_value_id AS VARCHAR(10))
			+	'AND spd.tier_id = ' + CAST(@selected_tier_value AS VARCHAR(10))
	--print (@sql)
	EXEC(@sql)	
 END

 ELSE IF @flag = 'i'
 BEGIN
	BEGIN TRY
		DELETE gp
		--gp.source_deal_header_id
		--	, gp.in_or_not
		--	, gp.jurisdiction_id
		--	, gp.tier_id
			FROM gis_product gp 
			INNER   JOIN (
			SELECT @source_deal_header_id [source_deal_header_id]
			, 1 [in_or_not]
			, state_value_id [jurisdiction_id]
			, tier_id 
		FROM eligibility_mapping_template_detail 
		WHERE template_id = @template_id) a
			ON gp.source_deal_header_id = a.source_deal_header_id AND
			gp.jurisdiction_id = a.jurisdiction_id AND
			gp.tier_id = a.tier_id
		WHERE gp.source_deal_header_id = @source_deal_header_id


		INSERT INTO gis_product (
			source_deal_header_id	
			, in_or_not
			, jurisdiction_id
			, tier_id
		)
		SELECT @source_deal_header_id
			, 1
			, state_value_id
			, tier_id 
		FROM eligibility_mapping_template_detail 
		WHERE template_id = @template_id

		EXEC spa_ErrorHandler 0,
					'Load template data to Grid'
					, 'spa_save_custom_form_data'
					, 'Success'
					, 'Changes have been saved successfully.'
					, ''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1,
			'Load template data to Grid'
			, 'spa_save_custom_form_data'
			, 'Error'
			, 'Template data cannot be loaded on Grid!.'
			, ''
	END CATCH
 END

 ELSE IF @flag = 'j'
 BEGIN
	DECLARE @sql_tier VARCHAR(MAX)
	SET @sql_tier = 'Select null, ''''  UNION ALL SELECT value_id, code FROM static_data_value AS sdv WHERE sdv.[type_id] = 15000'

	IF(@state_value_id <> '')
	SET @sql_tier = '
		SELECT DISTINCT sdv.value_id AS id, sdv.code AS value FROM static_data_value sdv
		INNER JOIN state_properties_details spd 
			ON spd.tier_id = sdv.value_id
		WHERE sdv.type_id = 15000 
			AND spd.state_value_id =' + CAST(@state_value_id AS VARCHAR(20))

	EXEC(@sql_tier)

 END

GO