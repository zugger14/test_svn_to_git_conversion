IF OBJECT_ID(N'[dbo].[spa_setup_generator]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_setup_generator]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_setup_generator]
	@flag CHAR(1),
	@source_deal_header_id	INT = NULL,
	@xml_data XML = NULL,
	@effective_date VARCHAR(20) = NULL,
	@end_date VARCHAR(20) = NULL,
	@hour_start INT = NULL,
	@hour_end INT = NULL,
	@tou INT = NULL,
	@type INT = NULL,
	@period VARCHAR(2) = NULL,
	@value FLOAT = NULL

AS

SET NOCOUNT ON;
DECLARE @sql VARCHAR(MAX)
DECLARE @idoc INT

IF @flag = 'g'
BEGIN
	SELECT DISTINCT 
			gc.rec_id [id],
			gc.effective_date [effective_date],
			gc.generator_config_value_id [config],
			gc.fuel_value_id [fuel],
			gc.fuel_curve_id [fuel_curve],
			gc.coeff_a [coeff_a],
			gc.coeff_b [coeff_b],
			gc.coeff_c [coeff_c],
			gc.heat_rate [heat_rate],
			gc.unit_min [unit_min],
			gc.unit_max [unit_max],
			gc.is_default [default],
			gc.comments
	FROM generator_characterstics gc
	INNER JOIN source_deal_detail sdd ON sdd.location_id = gc.location_id 
	INNER JOIN source_deal_header sdh On sdd.source_deal_header_id = sdh.source_deal_header_id
	WHERE sdh.source_deal_header_id = @source_deal_header_id
END

ELSE IF @flag = 's'
BEGIN
	SET @sql = '
	SELECT DISTINCT 
			gd.rec_id [id],
			gd.effective_date [effective_date],
			gd.effective_end_date [end_date],
			gd.tou [tou],
			gd.hour_from [hour_start],
			gd.hour_to [hour_end],
			gd.data_type_value_id [type],
			gd.period_type [period],
			gd.data_value [value],
			gd.generator_config_value_id [config],
			gd.comments
	FROM generator_data gd
	INNER JOIN source_deal_detail sdd ON sdd.location_id = gd.location_id 
	INNER JOIN source_deal_header sdh On sdd.source_deal_header_id = sdh.source_deal_header_id
	WHERE sdh.source_deal_header_id = ' + CAST(@source_deal_header_id AS VARCHAR) 

	IF @effective_date <> ''
		SET @sql += ' AND gd.effective_date = ''' + @effective_date + ''''

	IF @end_date <> ''
		SET @sql += ' AND gd.effective_end_date = ''' + @end_date + ''''

	IF @tou <> ''
		SET @sql += ' AND gd.tou = ' + CAST(@tou AS VARCHAR)

	IF @hour_start <> ''
		SET @sql += ' AND gd.hour_from = ' + CAST(@hour_start AS VARCHAR)

	IF @hour_end <> ''
		SET @sql += ' AND gd.hour_to = ' + CAST(@hour_end AS VARCHAR)

	IF @type <> ''
		SET @sql += ' AND gd.data_type_value_id = ' + CAST(@type AS VARCHAR)

	IF @period <> ''
		SET @sql += ' AND gd.period_type = ''' + @period + ''''

	IF @value <> ''
		SET @sql += ' AND gd.data_value = ' + CAST(@value AS VARCHAR)
	
	print @sql
	EXEC(@sql)
END

ELSE IF @flag = 'o'
BEGIN
	SELECT DISTINCT 
			goa.rec_id [id],
			goa.effective_date [effective_date],
			goa.owner_id [owner],
			goa.owner_per [owner_percent],
			goa.comments
	FROM generator_ownership_allocation goa
	INNER JOIN source_deal_detail sdd ON sdd.location_id = goa.location_id 
	INNER JOIN source_deal_header sdh On sdd.source_deal_header_id = sdh.source_deal_header_id
	WHERE sdh.source_deal_header_id = @source_deal_header_id
END

ELSE IF @flag = 'p'
BEGIN
	SELECT DISTINCT	
			po.power_outage_id [id],
			po.[type_name] [type],
			po.planned_start [planned_start],
			po.planned_end [planned_end],
			po.actual_start [actual_start],
			po.actual_end [actual_end],
			po.[status] [status],
			po.request_type [request_type],
			po.derate_mw [derate_mw],
			po.derate_percent [derate_percet],
			po.comments [comments]
	FROM power_outage po
	INNER JOIN source_deal_detail sdd ON sdd.location_id = po.source_generator_id 
	INNER JOIN source_deal_header sdh On sdd.source_deal_header_id = sdh.source_deal_header_id
	WHERE sdh.source_deal_header_id = @source_deal_header_id
END

ELSE IF @flag = 'c'
BEGIN
	SELECT DISTINCT
			ouc.rec_id [id],
			ouc.effective_date [effective_date],
			ouc.effective_end_date [end_date],
			ouc.generator_config_value_id [config],
			ouc.period_type [period],
			ouc.fuel_value_id [fuel],
			ouc.tou [tou],
			ouc.hour_from [hour_start],
			ouc.hour_to [hour_end],
			ouc.unit_from [from_mw],
			ouc.unit_to [to_mw],
			ouc.comments
	FROM operation_unit_configuration ouc
	INNER JOIN source_deal_detail sdd ON sdd.location_id = ouc.location_id 
	INNER JOIN source_deal_header sdh On sdd.source_deal_header_id = sdh.source_deal_header_id
	WHERE sdh.source_deal_header_id = @source_deal_header_id
END

ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY
		BEGIN TRAN
		DECLARE @location_id INT

		SELECT DISTINCT TOP(1) @location_id = sdd.location_id FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
		WHERE sdh.source_deal_header_id = @source_deal_header_id

		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_data

		IF OBJECT_ID('tempdb..#tmp_deleted_grid_data') IS NOT NULL
			DROP TABLE #tmp_general_grid
		
		SELECT	id			[id],
				grid_name	[grid_name]
		INTO #tmp_deleted_grid_data
		FROM OPENXML(@idoc, '/Root/DeletedGridData', 1)
		WITH (
			id			INT,
			grid_name	VARCHAR(100)
		)

		/* 
		 * General Data Grid -> generator_characterstics Table 
		 */
		IF OBJECT_ID('tempdb..#tmp_general_grid') IS NOT NULL
			DROP TABLE #tmp_general_grid
		
		SELECT	id				[id],
				dbo.FNAClientToSqlDate(effective_date)	[effective_date],
				config			[config],
				fuel			[fuel],
				fuel_curve		[fuel_curve],
				coeff_a			[coeff_a],
				coeff_b			[coeff_b],
				coeff_c			[coeff_c],
				heat_rate		[heat_rate],
				unit_min		[unit_min],
				unit_max		[unit_max],
				[default]		[default],
				comments		[comments]
		INTO #tmp_general_grid
		FROM OPENXML(@idoc, '/Root/GeneralGrid', 1)
		WITH (
			id				INT,
			effective_date	VARCHAR(100),
			config			INT,
			fuel			INT,
			fuel_curve		INT,
			coeff_a			VARCHAR(10),
			coeff_b			VARCHAR(10),
			coeff_c			VARCHAR(10),
			heat_rate		VARCHAR(10),
			unit_min		VARCHAR(10),
			unit_max		VARCHAR(10),
			[default]		INT,
			comments		VARCHAR(500)
		)

		INSERT INTO generator_characterstics (location_id, effective_date, generator_config_value_id, fuel_curve_id, fuel_value_id , coeff_a, coeff_b, coeff_c, heat_rate, unit_min, unit_max, is_default, comments)
		SELECT	@location_id		[location_id],
				NULLIF(effective_date,'')		[effective_date],
				NULLIF(config,'')	[config],
				fuel_curve			[fuel_curve],
				fuel				[fuel],
				NULLIF(coeff_a,'')	[coeff_a],
				NULLIF(coeff_b,'')	[coeff_b],
				NULLIF(coeff_c,'')	[coeff_c],
				NULLIF(heat_rate,'')[heat_rate],
				NULLIF(unit_min,'')	[unit_min],
				NULLIF(unit_max,'')	[unit_max],
				[default]			[default],
				comments			[comments]
		FROM #tmp_general_grid
		WHERE id = 0

		UPDATE gc
		SET	gc.location_id				=	@location_id,
			gc.effective_date			=	NULLIF(tgd.[effective_date],''),
			gc.generator_config_value_id=	NULLIF(tgd.[config],''),
			gc.fuel_curve_id			=	tgd.[fuel_curve],
			gc.fuel_value_id			=	tgd.[fuel],
			gc.coeff_a					= 	NULLIF(tgd.[coeff_a],''),
			gc.coeff_b					= 	NULLIF(tgd.[coeff_b],''),
			gc.coeff_c					= 	NULLIF(tgd.[coeff_c],''),
			gc.heat_rate				= 	NULLIF(tgd.[heat_rate],''),
			gc.unit_min					=	NULLIF(tgd.[unit_min],''),
			gc.unit_max					=	NULLIF(tgd.[unit_max],''),
			gc.is_default				= 	tgd.[default],
			gc.comments					= 	tgd.comments
		FROM #tmp_general_grid tgd
		INNER JOIN generator_characterstics gc ON tgd.id = gc.rec_id

		DELETE gc FROM generator_characterstics gc
		INNER JOIN #tmp_deleted_grid_data tmp ON gc.rec_id = tmp.id AND tmp.grid_name = 'General'

		/* 
		 * Data Grid -> generator_data Table 
		 */
		IF OBJECT_ID('tempdb..#tmp_data_grid') IS NOT NULL
			DROP TABLE #tmp_data_grid

		SELECT	id				[id],
				effective_date	[effective_date],
				end_date		[end_date],
				tou				[tou],
				hour_start		[hour_start],
				hour_end		[hour_end],
				[type]			[type],
				period			[period],
				value			[value],
				config			[config],
				comments		[comments]
		INTO #tmp_data_grid
		FROM OPENXML(@idoc, '/Root/DataGrid', 1)
		WITH (
			id				INT,
			effective_date	VARCHAR(100),
			end_date		VARCHAR(100),
			tou				VARCHAR(10),
			hour_start		VARCHAR(10),
			hour_end		INT,
			[type]			INT,
			period			VARCHAR(2),
			value			FLOAT,
			config			INT,
			comments		VARCHAR(500)
		)


		INSERT INTO generator_data (location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id, period_type, data_value,generator_config_value_id, comments)
		SELECT	@location_id			[location_id],
				effective_date			[effective_date],
				NULLIF(end_date,'')		[end_date],
				NULLIF(tou,'')			[tou],
				NULLIF(hour_start,'')	[hour_start],
				NULLIF(hour_end,'')		[hour_end],
				[type]					[type],
				NULLIF(period,'')		[period],
				value					[value],
				NULLIF(config,'')		[config],
				comments				[comments]
		FROM #tmp_data_grid
		WHERE id = 0

		UPDATE gd
		SET	gd.location_id			=	@location_id,
			gd.effective_date		=	tmp.effective_date,
			gd.effective_end_date	=	NULLIF(tmp.end_date,''),
			gd.tou					=	NULLIF(tmp.tou,''),
			gd.hour_from			=	NULLIF(tmp.hour_start,''),
			gd.hour_to				= 	NULLIF(tmp.hour_end,''),
			gd.data_type_value_id	= 	tmp.[type],
			gd.period_type			= 	NULLIF(tmp.period,''),
			gd.data_value			= 	tmp.value,
			gd.generator_config_value_id=	NULLIF(tmp.[config],''),
			gd.comments				= 	tmp.comments
		FROM #tmp_data_grid tmp
		INNER JOIN generator_data gd ON tmp.id = gd.rec_id

		DELETE gd FROM generator_data gd
		INNER JOIN #tmp_deleted_grid_data tmp ON gd.rec_id = tmp.id AND tmp.grid_name = 'Data'


		/* 
		 * Owner Grid -> generator_data Table 
		 */
		IF OBJECT_ID('tempdb..#tmp_owner_grid') IS NOT NULL
			DROP TABLE #tmp_owner_grid

		SELECT	id				[id],
				effective_date	[effective_date],
				[owner]			[owner],
				owner_per		[owner_per],
				comments		[comments]
		INTO #tmp_owner_grid
		FROM OPENXML(@idoc, '/Root/OwnerGrid', 1)
		WITH (
			id				INT,
			effective_date	VARCHAR(100),
			[owner]			INT,
			owner_per		FLOAT,
			comments		VARCHAR(500)
		)

		INSERT INTO generator_ownership_allocation (location_id, effective_date, owner_id, owner_per, comments)
		SELECT	@location_id	[location_id],
				NULLIF(effective_date,'')	[effective_date],
				[owner]			[owner],
				owner_per		[owner_percent],
				comments		[comments]
		FROM #tmp_owner_grid
		WHERE id = 0

		UPDATE gol
		SET	gol.location_id		=	@location_id,
			gol.effective_date	=	NULLIF(tmp.effective_date,''),
			gol.owner_id		=	tmp.[owner],
			gol.owner_per		=	tmp.owner_per,
			gol.comments		=   tmp.comments
		FROM #tmp_owner_grid tmp
		INNER JOIN generator_ownership_allocation gol ON tmp.id = gol.rec_id

		DELETE gol FROM generator_ownership_allocation gol
		INNER JOIN #tmp_deleted_grid_data tmp ON gol.rec_id = tmp.id AND tmp.grid_name = 'Owner'


		/* 
		 * Outage/Derate Grid -> power_outage Table 
		 */
		IF OBJECT_ID('tempdb..#tmp_outage_derate_grid') IS NOT NULL
			DROP TABLE #tmp_outage_derate_grid

		SELECT	id				[id],
				[type]			[type],
				planned_start	[planned_start],
				planned_end		[planned_end],
				actual_start	[actual_start],
				actual_end		[actual_end],
				[status]		[status],
				request_type	[request_type],
				derate_mw		[derate_mw],
				derate_per		[derate_per],
				comments		[comments]
		INTO #tmp_outage_derate_grid
		FROM OPENXML(@idoc, '/Root/OutageDerateGrid', 1)
		WITH (
			id					INT,
			[type]				CHAR(1),
			planned_start		VARCHAR(100),
			planned_end			VARCHAR(100),
			actual_start		VARCHAR(100),
			actual_end			VARCHAR(100),
			[status]			CHAR(1),
			request_type		CHAR(1),
			derate_mw			VARCHAR(10),
			derate_per			VARCHAR(10),
			comments			VARCHAR(500)
		)

		INSERT INTO power_outage ([type_name], source_generator_id, planned_start, planned_end, actual_start, actual_end, [status], request_type, derate_mw, derate_percent, comments)
		SELECT	[type]					[type],
				@location_id			[location_id],
				planned_start			[planned_start],
				planned_end				[planned_end],
				NULLIF(actual_start,'')	[actual_start],
				NULLIF(actual_end,'')	[actual_end],
				[status]				[status],
				request_type			[request_type],
				NULLIF(derate_mw,'')	[derate_mw],
				NULLIF(derate_per,'')	[derate_per],
				comments				[comments]
		FROM #tmp_outage_derate_grid
		WHERE id = 0


		UPDATE po
		SET	po.[type_name]			=	tmp.[type],
			po.source_generator_id	=	@location_id,
			po.planned_start		=	tmp.planned_start,
			po.planned_end			=	tmp.planned_end,
			po.actual_start			=	NULLIF(tmp.actual_start,''),
			po.actual_end			=	NULLIF(tmp.actual_end,''),
			po.[status]				= 	tmp.[status],
			po.request_type			= 	tmp.request_type,
			po.derate_mw			= 	NULLIF(tmp.derate_mw,''),
			po.derate_percent		= 	NULLIF(tmp.derate_per,''),
			po.comments				= 	tmp.comments
		FROM #tmp_outage_derate_grid tmp
		INNER JOIN power_outage po ON tmp.id = po.power_outage_id

		DELETE po FROM power_outage po
		INNER JOIN #tmp_deleted_grid_data tmp ON po.power_outage_id = tmp.id AND tmp.grid_name = 'OutageDerate'


		/* 
		 * Operation Unit Configuration Grid -> operation_unit_configuration Table 
		 */
		SELECT	id				[id],
				effective_date	[effective_date],
				end_date		[end_date],
				config			[config],
				period			[period],
				fuel			[fuel],
				tou				[tou],
				hour_start		[hour_start],
				hour_end		[hour_end],
				from_mw			[from_mw],
				to_mw			[to_mw],
				comments		[comments]
		INTO #tmp_configuration_grid
		FROM OPENXML(@idoc, '/Root/ConfigurationGrid', 1)
		WITH (
			id					INT,
			effective_date		VARCHAR(100),
			end_date			VARCHAR(100),
			config				VARCHAR(100),
			period				VARCHAR(2),
			fuel				INT,
			tou					INT,
			hour_start			VARCHAR(10),
			hour_end			VARCHAR(10),
			from_mw				VARCHAR(10),
			to_mw				VARCHAR(10),
			comments			VARCHAR(500)
		)

		INSERT INTO operation_unit_configuration (location_id, effective_date, effective_end_date, generator_config_value_id, period_type, fuel_value_id, tou, hour_from, hour_to, unit_from, unit_to, comments)
		SELECT	@location_id			[location_id],
				effective_date			[effective_date],
				NULLIF(end_date,'')		[end_date],
				NULLIF(config,'')		[config],
				NULLIF(period,'')		[period],
				NULLIF(fuel,'')			[fuel],
				NULLIF(tou,'')			[tou],
				NULLIF(hour_start,'')	[hour_start],
				NULLIF(hour_end,'')		[hour_end],
				NULLIF(from_mw,'')		[from_mw],
				NULLIF(to_mw,'')		[to_mw],
				comments				[comments]
		FROM #tmp_configuration_grid
		WHERE id = 0

		UPDATE ouc
		SET	ouc.location_id					=	@location_id,
			ouc.effective_date				=	tmp.effective_date,
			ouc.effective_end_date			=	NULLIF(tmp.end_date,''),
			ouc.generator_config_value_id	=	NULLIF(tmp.config,''),
			ouc.period_type					=	NULLIF(tmp.period,''),
			ouc.fuel_value_id				= 	NULLIF(tmp.fuel,''),
			ouc.tou							=	NULLIF(tmp.tou,''),
			ouc.hour_from					= 	NULLIF(tmp.hour_start,''),
			ouc.hour_to						= 	NULLIF(tmp.hour_end,''),
			ouc.unit_from					= 	NULLIF(tmp.from_mw,''),
			ouc.unit_to						= 	NULLIF(tmp.to_mw,''),
			ouc.comments					= 	tmp.comments
		FROM #tmp_configuration_grid tmp
		INNER JOIN operation_unit_configuration ouc ON tmp.id = ouc.rec_id

		DELETE ouc FROM operation_unit_configuration ouc
		INNER JOIN #tmp_deleted_grid_data tmp ON ouc.rec_id = tmp.id AND tmp.grid_name = 'Configuration'

		EXEC spa_ErrorHandler 0,
				 'Setup Generotor',
				 'spa_setup_generator',
				 'Success',
				 'The changes has been successfully saved.',
				 ''
		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Setup Generotor',
             'spa_setup_generator',
             'DB Error',
             'Failed to save.',
             ''
	END CATCH
END

ELSE IF @flag = 'l'
BEGIN
	SELECT DISTINCT 
		sml.source_minor_location_id [location_id], 
		'<a href="#" onclick="open_generation_window(' + CAST(sdh.source_deal_header_id AS VARCHAR) + ')">' + sml.Location_Name + '</a>' [location_name], 
		'<a href="#" onclick="open_deal_window(' + CAST(sdh.source_deal_header_id AS VARCHAR) + ')">' + sdh.deal_id + '</a>' [deal_ref_id],
		sdv.code [group] FROM source_deal_header sdh
	INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
	INNER JOIN source_minor_location sml ON sdd.location_id = sml.source_minor_location_id
	LEFT JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id AND uddft.Field_label = 'Generation Category'
	LEFT JOIN user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id AND uddf.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN static_data_value sdv ON sdv.value_id = uddf.udf_value
	INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
	WHERE sdt.deal_type_id = 'Generation'
END

ELSE IF @flag = 'n'
BEGIN
	SELECT DISTINCT sml.Location_Name [generator] FROM source_deal_detail sdd 
	INNER JOIN source_minor_location sml ON sdd.location_id = sml.source_minor_location_id
	WHERE sdd.source_deal_header_id = @source_deal_header_id
END