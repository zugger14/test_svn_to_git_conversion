IF EXISTS (
       SELECT *
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_gis_product_detail]')
              AND TYPE IN (N'P', N'PC')
   )
    DROP PROCEDURE [dbo].[spa_gis_product_detail]
GO

CREATE PROCEDURE [dbo].[spa_gis_product_detail]
	@flag CHAR(1), 
	@xml xml = NULL,
	@source_deal_header_id INT = NULL,  
	@in_or_not INT = NULL,
	@state_value_id INT = NULL,
	@tier_type INT = NULL, 
	@vintage INT = NULL,
	@certification_entity INT = NULL,
	@template_id INT = NULL,
	@environment_process_id varchar(200) = NULL
AS
/*
-----------**Debug**--------------------
	DECLARE @flag CHAR(1), 
	@xml xml = NULL,
	@source_deal_header_id INT = NULL,  
	@in_or_not INT = NULL,
	@state_value_id INT = NULL,
	@tier_type INT = NULL, 
	@vintage INT = NULL,
	@certification_entity INT = NULL,
	@template_id INT = NULL
	
	select @flag='i',@xml='<Root><GridGroup><GridRow  source_product_number="179" source_deal_header_id="3861" in_or_not="1" region_id="" jurisdiction="50002831" tier_id="50000009" technology_id="50000620" vintage="" ></GridRow> <GridRow  source_product_number="209" source_deal_header_id="3861" in_or_not="1" region_id="" jurisdiction="50002841" tier_id="50000664" technology_id="50000621" vintage="" ></GridRow> <GridRow  source_product_number="210" source_deal_header_id="3861" in_or_not="1" region_id="" jurisdiction="50002827" tier_id="50000664" technology_id="" vintage="" ></GridRow> <GridRow  source_product_number="211" source_deal_header_id="3861" in_or_not="1" region_id="" jurisdiction="50002831" tier_id="50000009" technology_id="" vintage="" ></GridRow> <GridRow  source_product_number="212" source_deal_header_id="3861" in_or_not="1" region_id="" jurisdiction="50002819" tier_id="50000664" technology_id="" vintage="" ></GridRow> <GridRow  source_product_number="213" source_deal_header_id="3861" in_or_not="1" region_id="" jurisdiction="50002827" tier_id="50000664" technology_id="" vintage="" ></GridRow> <GridRow  source_product_number="214" source_deal_header_id="3861" in_or_not="1" region_id="" jurisdiction="50002841" tier_id="50000664" technology_id="" vintage="" ></GridRow> <GridRow  source_product_number="215" source_deal_header_id="3861" in_or_not="1" region_id="" jurisdiction="" tier_id="" technology_id="" vintage="" ></GridRow> <GridRow  source_product_number="216" source_deal_header_id="3861" in_or_not="1" region_id="" jurisdiction="" tier_id="" technology_id="" vintage="" ></GridRow> <GridRow  source_product_number="217" source_deal_header_id="3861" in_or_not="1" region_id="" jurisdiction="50002841" tier_id="50000664" technology_id="" vintage="" ></GridRow> </GridGroup></Root>'
--*/

SET NOCOUNT ON
DECLARE @idoc INT
DECLARE @DESC VARCHAR(500)
DECLARE @err_no INT 
DECLARE @tablename varchar(100)
DECLARE @process_id varchar(100) = dbo.FNAGetNewID()
DECLARE @Sql_Select varchar(MAX)
DECLARE @Sql_Select_exec varchar(MAX)
DECLARE @Sql_Select_del varchar(MAX)
--SET @process_id = dbo.FNAGetNewID()
DECLARE @user_name varchar(100)
SET  @user_name = dbo.FNADBUser()

SET @tablename = dbo.FNAProcessTableName('environmental', @user_name, @process_id) 

IF(@environment_process_id = '0')
BEGIN
	SET @environment_process_id = NULL
END

IF(@environment_process_id = 'undefined')
BEGIN
	SET @environment_process_id = NULL
END

DECLARE @environmental_table_name varchar(100)
SET @environmental_table_name = dbo.FNAProcessTableName('environmental', @user_name, @environment_process_id)


IF OBJECT_ID('tempdb..#temp_check_delete_previous_stage') IS NOT NULL
	DROP TABLE #temp_check_delete_previous_stage
	
CREATE TABLE #temp_check_delete_previous_stage
		(source_product_number int, insert_delete char)

IF OBJECT_ID( @environmental_table_name ) IS NOT NULL 
EXEC ('Insert into #temp_check_delete_previous_stage
	select source_product_number, insert_del FROM  ' + @environmental_table_name + ' WHERE insert_del = ''d''')


SET @Sql_Select='create table '+ @tablename+'( 
	 [source_product_number] [varchar] (255)  NULL ,      
	 [source_deal_header_id] [varchar] (255)  NULL ,      
	 [in_or_not] [varchar] (50)  NULL ,      
	 [jurisdiction] [varchar] (50)  NULL ,      
	 [tier_id] [varchar] (255)  NULL ,      
	 [technology_id] [varchar] (50)  NULL ,      
	 [vintage] [varchar] (255)  NULL ,      
	 [region_id] [varchar] (255)  NULL,
	 [insert_del] char  
)'
EXEC (@Sql_Select)

IF (@flag = 's' and @source_deal_header_id is not null)
BEGIN
BEGIN
	DECLARE @sql VARCHAR(MAX)
	IF OBJECT_ID( @environmental_table_name ) IS NULL 
	SET @sql = '
	SELECT gp.source_product_number
	, gp.source_deal_header_id
	, gp.in_or_not
	, gp.region_id [region_id]
	, sdv.value_id [jurisdiction_id]
	, sdv1.value_id [tier_id]
	, sdv4.value_id [technology_id]
	, sdv2.value_id [vintage]
	--, sdv3.value_id [cert_entity]
	FROM Gis_Product gp
	LEFT JOIN static_data_value AS sdv ON sdv.value_id = gp.jurisdiction_id
	LEFT JOIN static_data_value AS sdv1 ON sdv1.value_id = gp.tier_id
	LEFT JOIN static_data_value AS sdv4 ON sdv4.value_id = gp.technology_id
	LEFT JOIN static_data_value AS sdv2 ON sdv2.value_id = gp.vintage '+
	CASE WHEN OBJECT_ID( @environmental_table_name ) IS NOT NULL 
	THEN 'LEFT JOIN ' + @environmental_table_name + ' eta  ON eta.source_product_number = gp.source_product_number  
	' ELSE '' 
		END + 
	'WHERE '+ CASE WHEN OBJECT_ID( @environmental_table_name ) IS NOT NULL THEN 'eta.insert_del <> ''d'' AND ' ELSE '' END + ' gp.source_deal_header_id = ' + CAST(@source_deal_header_id AS VARCHAR(100))
	Else 
	SET @sql = '
	SELECT source_product_number,
	source_deal_header_id,
	in_or_not,
	region_id,
	jurisdiction [jurisdiction_id],
	tier_id,
	technology_id,
	vintage
	FROM '+ @environmental_table_name + ' WHERE in_or_not IS NOT NULL'
	--EXEC (@sql)

	IF @template_id <> ''
	SET @sql = @sql + ' ' + 'UNION ALL 
	SELECT	NULL [source_product_number]' 
			+ ', ' + cast(@source_deal_header_id AS VARCHAR(100)) + '[source_deal_header_id]
			, 1 [in_or_not]
			, NULL [region_id]
			, state_value_id [jurisdiction_id]
			, tier_id 
			, NULL [technology_id]
			, NULL [vintage]
		FROM eligibility_mapping_template_detail 
		WHERE template_id =' + CAST(@template_id AS VARCHAR(100))
END 
	EXEC (@sql)

END
ELSE IF (@flag = 's' and @source_deal_header_id is NULL and @template_id = '')
BEGIN
IF OBJECT_ID(@environmental_table_name) IS NOT NULL
SET @sql = '
	SELECT source_product_number,
	source_deal_header_id,
	in_or_not,
	region_id,
	jurisdiction [jurisdiction_id],
	tier_id,
	technology_id,
	vintage
	FROM '+ @environmental_table_name + ' where source_product_number = 0 and insert_del =''i'''
EXEC (@sql)
END
ELSE IF (@flag = 's' and @source_deal_header_id is NULL and @template_id <> '')
BEGIN
	SET @sql = ' 
	SELECT	NULL [source_product_number] 
			, NULL [source_deal_header_id]
			, 1 [in_or_not]
			, NULL [region_id]
			, state_value_id [jurisdiction_id]
			, tier_id 
			, NULL [technology_id]
			, NULL [vintage]
		FROM eligibility_mapping_template_detail 
		WHERE template_id = ' + CAST(@template_id AS VARCHAR(100))
	EXEC (@sql)

END

ELSE IF @flag = 'i'
BEGIN	
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
	IF OBJECT_ID('tempdb..#temp_product_detail') IS NOT NULL
		DROP TABLE #temp_product_detail
	SELECT 
				source_product_number,
				source_deal_header_id,
				in_or_not,
				CASE  WHEN jurisdiction =  0 THEN NULL ELSE jurisdiction END [jurisdiction],
				--tier_id,
				CASE  WHEN tier_id =  0 THEN NULL ELSE tier_id END [tier_id],
				CASE  WHEN technology_id =  0 THEN NULL ELSE technology_id END [technology_id],
				CASE  WHEN vintage =  0 THEN NULL ELSE vintage END [vintage],
				--CASE  WHEN certification_entity =  0 THEN NULL ELSE certification_entity END [certification_entity],
				NULLIF(region_id,0) [region_id],
				insert_delete
	into #temp_product_detail
	FROM OPENXML(@idoc, '/Root/GridGroup/GridRow', 1)
	WITH (
				source_product_number INT	'@source_product_number',
				source_deal_header_id VARCHAR(20) '@source_deal_header_id',
				in_or_not			  INT	'@in_or_not',
				jurisdiction		  INT	'@jurisdiction',
				tier_id				  INT   '@tier_id',
				technology_id		  INT	'@technology_id',
				vintage				  INT	'@vintage',
				--certification_entity INT '@certification_entity',
				region_id		     VARCHAR(500) '@region_id',
				insert_delete char 'i'
	)
	
	IF OBJECT_ID('tempdb..#temp_product_detail_delete') IS NOT NULL
		DROP TABLE #temp_product_detail_delete
		
	SELECT source_product_number, insert_delete
	into #temp_product_detail_delete
	FROM OPENXML(@idoc, '/Root/GridGroup/GridDelete/GridRow', 1)
	WITH (
			source_product_number INT '@source_product_number',
			insert_delete char 'd'
	)	

	DECLARE @all INT, @distinct INT
	SET @all = (SELECT COUNT(*) FROM #temp_product_detail)
	--select @all

	SET @distinct = (
	SELECT COUNT (*) FROM (
		SELECT DISTINCT 
			source_deal_header_id
			, in_or_not
			, jurisdiction
			, tier_id
			, technology_id
			, vintage
			--certification_entity,
			, region_id 
			FROM #temp_product_detail) t
	)
	--select @distinct
	IF @distinct <> @all
	BEGIN
	DECLARE @msg VARCHAR(500)
	SET @msg = 'Duplicate Data in <b>(IN/NOT, Region, Jurisdiction, Tier, Technology and Vintage)</b> in <b>Product Detail</b> grid.'
		EXEC spa_ErrorHandler -1,
		'Product Detail'
		, 'spa_gis_product_detail'
		, 'Error'
		, @msg
		, ''
	RETURN
	END
	ELSE
	BEGIN
	
SET @Sql_Select_exec =
	'INSERT INTO ' + @tablename + '
					SELECT
						source_product_number,
						source_deal_header_id,
						in_or_not,
						jurisdiction,
						tier_id,
						technology_id,
						vintage,
						--certification_entity,
						region_id,
						''i''
					FROM #temp_product_detail					
					UNION ALL					
					SELECT
						source_product_number,
						NULL source_deal_header_id,
						NULL in_or_not,
						NULL jurisdiction,
						NULL tier_id,
						NULL technology_id,
						NULL vintage,
						--certification_entity,
						NULL region_id,
						''d''
					FROM #temp_product_detail_delete
					UNION ALL
						SELECT 
						source_product_number,
						NULL source_deal_header_id,
						NULL in_or_not,
						NULL jurisdiction,
						NULL tier_id,
						NULL technology_id,
						NULL vintage,
						--certification_entity,
						NULL region_id,
						''d''
						FROM #temp_check_delete_previous_stage
						where insert_delete = ''d''
				'

	--PRINT(@Sql_Select_exec)
	EXEC (@Sql_Select_exec)

	
EXEC spa_ErrorHandler 0,
		'Product Detail'
		, 'spa_gis_product_detail'
		, 'Success'
		, ''
		, @process_id	
END
END
	

IF @flag = 'v'
BEGIN
	BEGIN TRY
	BEGIN TRAN
		EXEC ('BEGIN
	MERGE Gis_Product AS gp
	USING 
		(
			SELECT
				source_product_number,
				source_deal_header_id,
				in_or_not,
				jurisdiction,
				tier_id,
				technology_id,
				vintage,
				--certification_entity,
						region_id,
						insert_del
					FROM '+ @environmental_table_name +'
		) AS tbl
			ON (gp.source_product_number = tbl.source_product_number and tbl.insert_del <> ''d'') 
	WHEN NOT MATCHED BY TARGET 
	THEN 
		INSERT(source_deal_header_id, in_or_not, jurisdiction_id, tier_id,technology_id, vintage, --cert_entity, 
		region_id) 
		VALUES(tbl.source_deal_header_id, tbl.in_or_not, tbl.jurisdiction, tbl.tier_id, tbl.technology_id, tbl.vintage, --tbl.certification_entity,
		 tbl.region_id)
	WHEN MATCHED 
	THEN 
		UPDATE 
		SET source_deal_header_id	= tbl.source_deal_header_id,
			in_or_not				= tbl.in_or_not, 
			jurisdiction_id			= NULLIF(tbl.jurisdiction, 0),
			tier_id					= NULLIF(tbl.tier_id, 0),
			technology_id			= NULLIF(tbl.technology_id, 0),
			vintage					= NULLIF(tbl.vintage, 0), 
			--cert_entity				= tbl.certification_entity,
			region_id				= NULLIF(tbl.region_id, 0)
	;
					END')

			EXEC ('Delete  gpp from Gis_Product gpp INNER JOIN '+ @environmental_table_name + ' etn on etn.source_product_number = gpp.source_product_number and etn.insert_del = ''d'' ')

	--		EXEC('Drop table ' + @environmental_table_name )
		
			
	COMMIT
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0 
		ROLLBACK
	EXEC spa_ErrorHandler -1,
				'Product Detail',
				'spa_gis_product_detail',
				'Error'
				, 'Sorry there was a error.Please try again'
				, ''
	END CATCH
END	