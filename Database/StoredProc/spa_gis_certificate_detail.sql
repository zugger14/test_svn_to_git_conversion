IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[spa_gis_certificate_detail]') AND [type] IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_gis_certificate_detail]
GO

/**
	Operations for Certificate in Deal.

	Parameters:
		@flag							:	Operation Flag.
		@certificate_num				:	Certificate Number.
		@source_deal_header_id			:	Deal ID.
		@source_deal_detail_id			:	Deal Detail ID.
		@gis_certificate_number_from	:	Certificate Number From in String (Multiple Support).
		@gis_certificate_number_to		:	Certificate Number To in String (Multiple Support).
		@gis_cert_date					:	Date of Certificate.
		@state_value_id					:	State value ID.
		@tier_type						:	Type of Tier.
		@contract_exp_date				:	Expiration Date of Contract.
		@certificate_number_from_int	:	Single Certificate Number From.
		@certificate_number_to_int		:	Single Certificate Number To.
		@year							:	Year of Certification.
		@certification_entity			:	Certification Object.
		@leg							:	Deal Detail Leg.
		@term_start						:	Deal Detail Term Start.
		@term_end						:	Deal Detail Term End.
		@certificate_process_id			:	Process ID containing data related to certificates.
		@certificate_temp_id			:	Process ID for storing data of certificates temporarily.
		@jurisdiction					:	Jurisdiction.
*/

CREATE PROCEDURE [dbo].[spa_gis_certificate_detail]
	@flag CHAR(1),
	@certificate_num VARCHAR(1000) = NULL,
	@source_deal_header_id INT = NULL,
	@source_deal_detail_id INT = NULL,
	@gis_certificate_number_from VARCHAR(100) = NULL,
	@gis_certificate_number_to VARCHAR(100) = NULL,
	@gis_cert_date DATETIME = NULL,
	@state_value_id INT = NULL,
	@tier_type INT = NULL,
	@contract_exp_date DATETIME = NULL,
	@certificate_number_from_int INT = NULL,
	@certificate_number_to_int INT = NULL,
	@year INT = NULL,
	@certification_entity INT = NULL,
	@leg INT = NULL,
	@term_start DATETIME = NULL,
	@term_end DATETIME = NULL,
	@certificate_process_id VARCHAR(200) = NULL,
	@certificate_temp_id VARCHAR(1000) = NULL,
	@jurisdiction VARCHAR(1000) = NULL
AS

/*-------------------Debug Section---------------
DECLARE @flag CHAR(1),
		@certificate_num INT = NULL,
		@source_deal_header_id INT = NULL,
		@source_deal_detail_id INT = NULL,
		@gis_certificate_number_from VARCHAR(100) = NULL,
		@gis_certificate_number_to VARCHAR(100) = NULL,
		@gis_cert_date DATETIME = NULL,
		@state_value_id INT = NULL,
		@tier_type INT = NULL,
		@contract_exp_date DATETIME = NULL,
		@certificate_number_from_int INT = NULL,
		@certificate_number_to_int INT = NULL,
		@year INT = NULL,
		@certification_entity INT = NULL,
		@leg INT = NULL,
		@term_start  DATETIME = NULL,
		@term_end  DATETIME = NULL,
		@certificate_process_id VARCHAR(200) = NULL,
		@certificate_temp_id VARCHAR(100) = NULL,
		@jurisdiction VARCHAR(100) = NULL

SELECT @flag='i'
	,@certificate_num=NULL
	,@source_deal_header_id=242581
	,@source_deal_detail_id=2339581
	,@gis_certificate_number_from='1'
	,@gis_certificate_number_to='100'
	,@gis_cert_date='2019-11-01'
	,@state_value_id=50002868
	,@tier_type=50000129
	,@contract_exp_date='2019-11-30'
	,@certificate_number_from_int=1
	,@certificate_number_to_int=8
	,@year=5518
	,@certification_entity=NULL
	,@leg=1
	,@term_start='2019-12-01'
	,@term_end='2019-12-31'
	,@certificate_process_id=null
	,@certificate_temp_id=null
	,@jurisdiction=null
	
-----------------------------------------------*/

IF OBJECT_ID('tempdb..#temp_sell_certificate') IS NOT NULL
	DROP TABLE #temp_sell_certificate

DECLARE @sql VARCHAR(MAX)
SET NOCOUNT ON

DECLARE @user_name VARCHAR(100) = dbo.FNADBUser()
DECLARE @is_app_admin INT = dbo.FNAAppAdminRoleCheck(@user_name)
DECLARE @process_id VARCHAR(200) = dbo.FNAGetNewID()
DECLARE @table_name VARCHAR(100), @sql_select VARCHAR(MAX), @sql_insert VARCHAR(MAX), @sql_update VARCHAR(MAX),
		@sql_delete VARCHAR(MAX), @sql_data VARCHAR(MAX), @sql_pre_insert VARCHAR(MAX), @certificate_table_name VARCHAR(100)

SET @table_name = dbo.FNAProcessTableName('certificate', @user_name, @process_id)
SET @certificate_table_name = dbo.FNAProcessTableName('certificate', @user_name, @certificate_process_id)

IF (@certificate_temp_id = 'NULL' OR @certificate_temp_id = '')
BEGIN
	SET @certificate_temp_id = NULL
END

IF (NULLIF(@certificate_process_id,'') IS NULL)
BEGIN
	SET @certificate_table_name = @table_name
	SET @certificate_process_id = @process_id

	SET @sql_select = '
		CREATE TABLE ' + @certificate_table_name + ' (
			[certificate_temp_id] INT IDENTITY(1,1) PRIMARY KEY,
			[source_certificate_number] INT,
			[source_deal_header_id] INT NULL,   
			[certificate_number_from_int] FLOAT NULL,   
			[certificate_number_to_int] FLOAT NULL,   
			[gis_certificate_number_from] VARCHAR(50) NULL,   
			[gis_certificate_number_to] VARCHAR(255) NULL, 
			[gis_cert_date] VARCHAR(255) NULL,
			[state_value_id] INT NULL,   
			[tier_type] INT NULL,   
			[contract_expiration_date] DATETIME NULL,
			[year] INT NULL,
			[certification_entity] INT NULL,
			[insert_del] CHAR NULL
		)
	'

	EXEC (@sql_select)
END

IF @flag = 'i'
BEGIN
	IF EXISTS (SELECT 1 FROM gis_certificate WHERE  state_value_id = @state_value_id AND source_deal_header_id = @source_deal_header_id)
	BEGIN
		EXEC spa_ErrorHandler -1, 'spa_certificate_detail', 'insert_certificate_detail', 'insert_certificate_detail', 'The selected Jurisdiction already exists.', ''
	END
	ELSE    
	BEGIN TRY
		IF (@source_deal_header_id IS NOT NULL)
		BEGIN
		IF OBJECT_ID('tempdb..#data_exist') IS NOT NULL
			DROP TABLE #data_exist

			CREATE TABLE #data_exist(
				id INT
			)

			SET @sql_data = '
			INSERT INTO #data_exist
			SELECT ctn.source_deal_header_id
			FROM ' + @certificate_table_name + ' ctn
				INNER JOIN source_deal_detail sdd ON ctn.source_deal_header_id = sdd.source_deal_detail_id
					AND MONTH(sdd.term_start) >= ' + ISNULL(CAST(MONTH(@term_start) AS  VARCHAR(200)), 'NULL') + '  
					AND YEAR(sdd.term_start) = ' + ISNULL(CAST(YEAR(@term_start) AS VARCHAR(200)), 'NULL') + ' 
					AND MONTH(sdd.term_end) <= ' + ISNULL(CAST(MONTH(@term_end) AS VARCHAR(200)), 'NULL') + ' 
					AND YEAR(sdd.term_end) = ' + ISNULL(CAST(YEAR(@term_end) AS VARCHAR(200)), 'NULL') + '
					AND sdd.leg = ' + CAST(@leg AS VARCHAR(10)) + '
				WHERE ctn.source_deal_header_id = ''' + CAST(@source_deal_detail_id AS VARCHAR(10)) + '''
					AND ctn.state_value_id = ''' + CAST(@state_value_id AS VARCHAR(10)) + '''
					AND ctn.tier_type = ''' + CAST(@tier_type AS VARCHAR(10)) + '''
			UNION
			SELECT gc.source_deal_header_id
			FROM gis_certificate gc
				INNER JOIN source_deal_detail sdd ON gc.source_deal_header_id = sdd.source_deal_detail_id
					AND MONTH(sdd.term_start) >= ' + ISNULL(CAST(MONTH(@term_start) AS  VARCHAR(200)), 'NULL') + '  
					AND YEAR(sdd.term_start) = ' + ISNULL(CAST(YEAR(@term_start) AS VARCHAR(200)), 'NULL') + ' 
					AND MONTH(sdd.term_end) <= ' + ISNULL(CAST(MONTH( @term_end) AS VARCHAR(200)), 'NULL') + ' 
					AND YEAR(sdd.term_end) = ' + ISNULL(CAST(YEAR(@term_end) AS VARCHAR(200)), 'NULL') +'
			WHERE gc.source_deal_header_id = ''' + CAST(@source_deal_detail_id AS VARCHAR) + '''
				AND gc.state_value_id = ''' + CAST(@state_value_id AS VARCHAR) + '''
				AND gc.tier_type = ''' + CAST(@tier_type AS VARCHAR) + '''
		'

			EXEC(@sql_data)

		IF EXISTS(SELECT 1 from #data_exist)
		BEGIN
				EXEC spa_ErrorHandler -1, 'spa_certificate_detail', 'insert_certificate_detail', 'insert_certificate_detail', 'Duplicate Data in <b>Juridiction</b>, <b>Tier</b>, <b>Term Start</b> and <b>Term End</b>.', ''
			RETURN
		END

			 SET @sql_insert = ('
				INSERT INTO ' + @certificate_table_name + ' (
					source_deal_header_id, certificate_number_from_int, certificate_number_to_int, gis_certificate_number_from, gis_certificate_number_to,
					gis_cert_date, state_value_id, tier_type, contract_expiration_date, [year], certification_entity, insert_del
	    )
				SELECT sdd.source_deal_detail_id, ' + 
					   ISNULL(CAST(@certificate_number_from_int AS VARCHAR(200)), 'NULL') + ','  + 
					   ISNULL(CAST(@certificate_number_to_int AS VARCHAR(200)), 'NULL') + ',' +
					   ISNULL('''' + CAST(@gis_certificate_number_from AS VARCHAR(200)) + '''', 'NULL') + ',' +
					   ISNULL('''' + CAST(@gis_certificate_number_to AS VARCHAR(200)) + '''', 'NULL') + ',' +
					   ISNULL('''' + CONVERT(VARCHAR(10), @gis_cert_date, 120) + '''', 'NULL') + ',' +
					   ISNULL(CAST(@state_value_id AS VARCHAR(200)), 'NULL') + ',' +
					   ISNULL(CAST(@tier_type AS VARCHAR(200)), 'NULL') + ',' + 
					   ISNULL('''' + CONVERT(VARCHAR, @contract_exp_date, 120) + '''', 'NULL') + ',' +
					   ISNULL(CAST(@year AS VARCHAR(200)), 'NULL') + ',' +
					   ISNULL(CAST(@certification_entity AS VARCHAR(200)), 'NULL') + ',
					   ''i''
	    FROM source_deal_header sdh
				INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
				AND MONTH(sdd.term_start) >= ' + ISNULL(CAST(MONTH(@term_start) AS  VARCHAR(200)), 'NULL') + '  
				AND YEAR(sdd.term_start) = ' +  ISNULL(CAST( YEAR(@term_start) AS VARCHAR(200)),'NULL') + ' 
					AND MONTH(sdd.term_end) <= ' + ISNULL(CAST(MONTH( @term_end) AS VARCHAR(200)),'NULL') + ' 
					AND YEAR(sdd.term_end) = '+ ISNULL(CAST(YEAR(@term_end) AS VARCHAR(200)), 'NULL') + '
					AND sdd.leg = ' + CAST(@leg AS VARCHAR(10)) + '
				LEFT JOIN gis_certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id	
					AND gc.tier_type = ' + ISNULL(CAST(@tier_type AS VARCHAR(200)), 'NULL') + '
					AND gc.state_value_id = ' + ISNULL(CAST(@state_value_id AS VARCHAR(200)), 'NULL') + '							 
				WHERE sdh.source_deal_header_id = ' + ISNULL(CAST(@source_deal_header_id AS VARCHAR(200)), 'NULL') +'
					--AND sdd.source_deal_detail_id = ' + ISNULL(CAST(@source_deal_detail_id AS VARCHAR(200)), 'NULL') + '
					AND gc.source_certificate_number IS NULL'
			)
		END
		
		EXEC (@sql_insert)
		
		IF (@source_deal_header_id IS NULL)		
		BEGIN
			SET @sql_pre_insert = ('
				INSERT INTO ' + @certificate_table_name + ' (
					source_deal_header_id, certificate_number_from_int, certificate_number_to_int, gis_certificate_number_from, gis_certificate_number_to, 
					gis_cert_date, state_value_id, tier_type, contract_expiration_date, [year], certification_entity, insert_del
	    )
				SELECT ' + ISNULL(CAST(@source_deal_header_id AS VARCHAR(200)), 'NULL') + ',
					   ' + ISNULL(CAST(@certificate_number_from_int AS VARCHAR(200)), 'NULL') + ',
					   ' + ISNULL(CAST(@certificate_number_to_int AS VARCHAR(200)), 'NULL') + ',
					   ' + ISNULL('''' + CAST(@gis_certificate_number_from AS VARCHAR(200)) + '''', 'NULL') + ',
					   ' + ISNULL('''' + CAST(@gis_certificate_number_to AS VARCHAR(200)) + '''', 'NULL') + ',
					   ' + ISNULL('''' + CONVERT(VARCHAR, @gis_cert_date, 120) + '''', 'NULL') + ',
					   ' + ISNULL(CAST(@state_value_id AS VARCHAR(200)), 'NULL') + ',
					   ' + ISNULL(CAST(@tier_type AS VARCHAR(200)), 'NULL') + ',
					   ' + ISNULL('''' + CONVERT(VARCHAR, @contract_exp_date, 120) + '''', 'NULL') + ',
					   ' + ISNULL(CAST(@year AS VARCHAR(200)), 'NULL') + ',
					   ' + ISNULL(CAST(@certification_entity AS VARCHAR(200)), 'NULL') + ',
					   ''i''
				')
		END
 	
		EXEC (@sql_pre_insert)

		UPDATE  source_deal_detail 
		SET source_deal_detail.Leg = @leg  
		FROM source_deal_detail sdd
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
			AND (MONTH(sdd.term_start) >= MONTH(@term_start ) AND YEAR(sdd.term_start) = YEAR(@term_start)) 
			AND (MONTH(sdd.term_end) <= MONTH(@term_end ) AND YEAR(sdd.term_end) = YEAR(@term_end)) 
			AND sdd.leg = @leg
		WHERE sdh.source_deal_header_id = @source_deal_header_id
			AND sdd.source_deal_detail_id = @source_deal_detail_id
		
		EXEC spa_ErrorHandler 0, 'spa_certificate_detail', 'insert_certificate_detail', 'Success', 'Change have been saved successfully.', @certificate_process_id
	END TRY
	BEGIN CATCH
		DECLARE @error_msg VARCHAR(MAX)
 		SET @error_msg = ERROR_MESSAGE()  
 		
 		IF @error_msg LIKE '%Violation of UNIQUE KEY constraint ''UC_Gis_Certificate''.%'
 		BEGIN
 			EXEC spa_ErrorHandler -1, 'spa_certificate_detail', 'insert_certificate_detail', 'insert_certificate_detail', 'Jurisdiction should be unique.', ''	
 		END
 		ELSE
 		BEGIN
 			EXEC spa_ErrorHandler -1, 'spa_certificate_detail', 'insert_certificate_detail', 'insert_certificate_detail', @error_msg, ''	
 		END		
	END CATCH
END
 
ELSE IF @flag = 'u'
BEGIN
	IF EXISTS (
		SELECT 1 
		FROM gis_certificate 
		WHERE state_value_id = @state_value_id 
			AND source_deal_header_id = @source_deal_header_id 
			AND source_certificate_number <> @certificate_num
	)
	BEGIN
	    EXEC spa_ErrorHandler -1, 'spa_certificate_detail', 'update_certificate_detail', 'update_certificate_detail', 'The selected Jurisdiction already exists.', ''
	END
	
	IF((@certificate_num IS NOT NULL) AND (@certificate_temp_id = 'NULL' OR @certificate_temp_id is NULL))
	BEGIN
				BEGIN TRY  
			SET @sql_update = ('
				INSERT INTO ' + @certificate_table_name + ' (
					source_deal_header_id, certificate_number_from_int, certificate_number_to_int, gis_certificate_number_from, gis_certificate_number_to,
					gis_cert_date, state_value_id, tier_type, contract_expiration_date, [year], certification_entity, source_certificate_number, insert_del
					 )
					SELECT sdd.source_deal_detail_id, ' + 
						ISNULL(CAST(@certificate_number_from_int AS VARCHAR(200)), 'NULL') + ', ' +
						ISNULL(CAST(@certificate_number_to_int AS VARCHAR(200)), 'NULL') + ', ''' +
						ISNULL(CAST(@gis_certificate_number_from AS VARCHAR(200)), '') + ''', ''' +
						ISNULL(CAST(@gis_certificate_number_to AS VARCHAR(200)), '') + ''', ' +
						ISNULL('''' + CONVERT(VARCHAR, @gis_cert_date, 120) + '''', 'NULL') + ', ' +
						ISNULL(CAST(@state_value_id AS VARCHAR(200)), 'NULL') + ', ' +
						ISNULL(CAST(@tier_type AS VARCHAR(200)), 'NULL') + ', ' +
						ISNULL('''' + CONVERT(VARCHAR, @contract_exp_date, 120) + '''', 'NULL') + ',' +
						ISNULL(CAST(@year AS VARCHAR(200)), 'NULL') + ', ' +
						ISNULL(CAST(@certification_entity AS VARCHAR(200)), 'NULL') + ', ' +
						ISNULL(CAST(@certificate_num AS VARCHAR(200)), 'NULL') + ',
						''u''
				FROM source_deal_header sdh
				INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
						AND MONTH(sdd.term_start) >= ' + ISNULL(CAST(MONTH(@term_start) AS  VARCHAR(200)), 'NULL') + '  
						AND YEAR(sdd.term_start) = ' +  ISNULL(CAST( YEAR(@term_start) AS VARCHAR(200)),'NULL') + ' 
						AND MONTH(sdd.term_end) <= ' +  ISNULL(CAST(MONTH( @term_end) AS VARCHAR(200)),'NULL') +' 
					AND YEAR(sdd.term_end) = '+ ISNULL(CAST(YEAR(@term_end) AS VARCHAR(200)), 'NULL') + '
					AND sdd.leg = ' + CAST(@leg AS VARCHAR(10)) + '
				LEFT JOIN gis_certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				WHERE gc.source_certificate_number = ' + ISNULL(CAST(@certificate_num AS VARCHAR(200)), 'NULL') + '
			')
	   
			EXEC (@sql_update)		
		   
			EXEC spa_ErrorHandler 0, 'spa_certificate_detail', 'update_certificate_detail', 'update_certificate_detail', 'Successfully Updated Certificate Detail.', @certificate_process_id
			END TRY
			BEGIN CATCH 
 				SET @error_msg = ERROR_MESSAGE()  
 		
 				IF @error_msg LIKE '%Violation of UNIQUE KEY constraint ''UC_Gis_Certificate''.%'
 				BEGIN
 					EXEC spa_ErrorHandler -1, 'spa_certificate_detail', 'update_certificate_detail', 'update_certificate_detail', 'Jurisdiction should be unique.', ''	
 				END
 				ELSE
 				BEGIN
 					EXEC spa_ErrorHandler  -1, 'spa_certificate_detail', 'update_certificate_detail', 'update_certificate_detail', 'Failed to Updated Certificate Detail', ''
 				END
			END CATCH
		END
	ELSE IF((@certificate_num is not null) AND (@certificate_temp_id is not NULL))
		BEGIN
		SET @sql = '
			UPDATE ' + @certificate_table_name + ' 
			SET source_certificate_number = ' + ISNULL(CAST(@certificate_num AS VARCHAR(200)), 'NULL') + ',
				certificate_number_from_int = ' + ISNULL(CAST(@certificate_number_from_int AS VARCHAR(200)), 'NULL') +',
				certificate_number_to_int = ' + ISNULL(CAST(@certificate_number_to_int AS VARCHAR(200)), 'NULL') + ',
				gis_certificate_number_from = ' + ISNULL('''' + CAST(@gis_certificate_number_from AS VARCHAR(200)) + '''', 'NULL') + ',
				gis_certificate_number_to = ' + ISNULL('''' + CAST(@gis_certificate_number_to AS VARCHAR(200)) + '''', 'NULL') + ',
				gis_cert_date = ' + ISNULL(CAST('''' + CONVERT(VARCHAR, @gis_cert_date, 120) + '''' AS VARCHAR(200)), 'NULL') + ',
				state_value_id = ' + ISNULL(CAST(@state_value_id AS VARCHAR(200)), 'NULL') + ',
				tier_type = ' + ISNULL(CAST(@tier_type AS VARCHAR(200)), 'NULL') + ',
				contract_expiration_date = ' + ISNULL(CAST('''' + CONVERT(VARCHAR, @contract_exp_date, 120) + '''' AS VARCHAR(200)), 'NULL') + ',
				year = ' + ISNULL(CAST(@year AS VARCHAR(200)), 'NULL') + ',
				certification_entity = ' + ISNULL(CAST(@certification_entity AS VARCHAR(200)), 'NULL') + '
			WHERE certificate_temp_id = ' + @certificate_temp_id + '
		'

			EXEC (@sql)

		EXEC spa_ErrorHandler 0, 'spa_certificate_detail', 'update_certificate_detail', 'update_certificate_detail', 'Successfully Updated Certificate Detail.', @certificate_process_id	  
			END
	ELSE 
	BEGIN
		SET @sql = '
			UPDATE ' + @certificate_table_name + '
			SET source_certificate_number = ' + ISNULL(CAST(@certificate_num AS VARCHAR(200)), 'NULL') + ',
				certificate_number_from_int = ' + ISNULL(CAST(@certificate_number_from_int AS VARCHAR(200)), 'NULL') + ',
				certificate_number_to_int = ' + ISNULL(CAST(@certificate_number_to_int AS VARCHAR(200)), 'NULL') + ',
				gis_certificate_number_from = ' + ISNULL('''' + CAST(@gis_certificate_number_from AS VARCHAR(200)) + '''', 'NULL') + ',
				gis_certificate_number_to = ' + ISNULL('''' + CAST(@gis_certificate_number_to AS VARCHAR(200)) + '''', 'NULL') + ',
				gis_cert_date = ' + ISNULL(CAST('''' + CONVERT(VARCHAR, @gis_cert_date, 120) + '''' AS VARCHAR(200)), 'NULL') + ',
				state_value_id = ' + ISNULL(CAST(@state_value_id AS VARCHAR(200)), 'NULL') + ',
				tier_type = ' + ISNULL(CAST(@tier_type AS VARCHAR(200)), 'NULL') + ',
				contract_expiration_date = ' + ISNULL(CAST('''' + CONVERT(VARCHAR, @contract_exp_date, 120) + '''' AS VARCHAR(200)), 'NULL') + ',	
				year = ' + ISNULL(CAST(@year AS VARCHAR(200)), 'NULL') + ',
				certification_entity = ' + ISNULL(CAST(@certification_entity AS VARCHAR(200)), 'NULL') + '
			WHERE certificate_temp_id = ' + @certificate_temp_id + ''
		
			EXEC (@sql)

		EXEC spa_ErrorHandler 0, 'spa_certificate_detail', 'update_certificate_detail', 'update_certificate_detail', 'Successfully Updated Certificate Detail.', @certificate_process_id	  
			END
	END
		
ELSE IF @flag = 's'
BEGIN
	IF(@source_deal_header_id IS NOT NULL)
	BEGIN
		CREATE TABLE #temp_sell_certificate(
			id INT IDENTITY(1, 1),
			[group] VARCHAR(7),
			source_certificate_number INT,
			certification_entity VARCHAR(500),
			jurisdiction VARCHAR(500),
			tier VARCHAR(500),
			cert_from VARCHAR(100),
			cert_to VARCHAR(100),
			[year] VARCHAR(100),
			term_start VARCHAR(50),
			term_end VARCHAR(50),
			certificate_date VARCHAR(50),
			expiration_date VARCHAR(50),
			sequence_from VARCHAR(100),
			sequence_to VARCHAR(100),
			source_deal_detail_id INT,
			create_ts VARCHAR(50),
			update_ts VARCHAR(50),
			leg INT,
			source_deal_header_id INT,
			certificate_temp_id INT
		)

	IF OBJECT_ID( @certificate_table_name) IS NOT NULL
	BEGIN
		SET @sql = '
				INSERT INTO #temp_sell_certificate (
					[group], source_certificate_number, certification_entity, jurisdiction, tier, cert_from, cert_to, [year], term_start, term_end, certificate_date,
					expiration_date, sequence_from, sequence_to, source_deal_detail_id, create_ts, update_ts, leg, source_deal_header_id, certificate_temp_id
				)
			SELECT CONVERT(VARCHAR(7), sdd.term_start, 120) [group],
				   gc.source_certificate_number,
				   sdv2.code [Certification Entity],
				   sdv.code [Jurisdiction],
				   sdv1.code [Tier],
				   gc.gis_certificate_number_from [Cert# From],
				   gc.gis_certificate_number_to [Cert# To],
				   sdv_year.code [year],
				   dbo.FNADateFormat(sdd.term_start) [Term Start],
				   dbo.FNADateFormat(sdd.term_end) [Term End],
				   dbo.FNADateFormat(gc.gis_cert_date) [Certificate Date],
				   dbo.FNADateFormat(gc.contract_expiration_date) [Expiration Date],
				   gc.certificate_number_from_int [Sequence From],
				   gc.certificate_number_to_int [Sequence To],
				   sdd.source_deal_detail_id [Source Deal Detail ID],
				   dbo.FNAUserDateTimeFormat(getdate(), 2, dbo.FNADBUSER()) [Create TS],
				   dbo.FNAUserDateTimeFormat(getdate(), 2, dbo.FNADBUSER()) [Update TS],
				   sdd.Leg [Leg],
				   sdd.source_deal_header_id [Source Deal Header ID],
				   gc.certificate_temp_id [Certificate Temp ID]
				FROM ' + @certificate_table_name + ' gc
				LEFT JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = gc.source_deal_header_id
				LEFT JOIN static_data_value sdv ON sdv.value_id = gc.state_value_id
				LEFT JOIN static_data_value sdv1 ON sdv1.value_id = gc.tier_type
				LEFT JOIN static_data_value sdv2 ON sdv2.value_id = gc.certification_entity
				LEFT JOIN static_data_value sdv_year ON sdv_year.value_id = gc.[year]
				WHERE gc.insert_del = ''i'' OR gc.insert_del = ''u''
			'
		EXEC(@sql)
	END

		IF EXISTS(
			SELECT 1
			FROM matching_header_detail_info m
		INNER JOIN matching_header_detail_info m2 ON m2.source_deal_detail_id_from = m.source_deal_detail_id_from
			WHERE m.source_deal_header_id = @source_deal_header_id
		)
	BEGIN
 		--	DECLARE @link_id INT
			--SELECT @link_id = link_id
			--FROM matching_header_detail_info
			--WHERE source_deal_header_id = @source_deal_header_id
			
		SET @sql = '
				INSERT INTO #temp_sell_certificate (
					[group], 
					source_certificate_number, 
					certification_entity, 
					jurisdiction, 
					tier, 
					cert_from, 
					cert_to, 
					[year], 
					term_start, 
					term_end, 
					certificate_date,
					expiration_date, 
					sequence_from, 
					sequence_to, 
					source_deal_detail_id, 
					create_ts, 
					update_ts, 
					leg, 
					source_deal_header_id, 
					certificate_temp_id)
			SELECT CONVERT(VARCHAR(7), sdd_sale.term_start, 120) [group],
				gc_assign.source_certificate_number,
				sdv2.code certification_entity,
				sdv.code jurisdiction,
				sdv1.code tier,
				CONCAT(SUBSTRING(gc_assign.gis_certificate_number_from, 1, LEN(gc_assign.gis_certificate_number_from) - CHARINDEX(''-'', REVERSE(gc_assign.gis_certificate_number_from))), ''-'', mhdi.sequence_from) cert_from,
				--gc_assign.gis_certificate_number_from cert_from,
				CONCAT(SUBSTRING(gc_assign.gis_certificate_number_to, 1, LEN(gc_assign.gis_certificate_number_to) - CHARINDEX(''-'', REVERSE(gc_assign.gis_certificate_number_to))), ''-'', mhdi.sequence_to) cert_to,
				--gc_assign.gis_certificate_number_to cert_to,
				sdv_year.code [year],
				dbo.FNADateFormat(sdd_assign.term_start) term_start,
				dbo.FNADateFormat(sdd_assign.term_end) term_end,
				dbo.FNADateFormat(gc_assign.gis_cert_date) certificate_date,
				dbo.FNADateFormat(gc_assign.contract_expiration_date) expiration_date,
				mhdi.sequence_from,
				mhdi.sequence_to,
				sdd_sale.source_deal_detail_id source_deal_detail_id,
				dbo.FNAUserDateTimeFormat(gc_assign.create_ts, 2, dbo.FNADBUSER()) create_ts,
				dbo.FNAUserDateTimeFormat(gc_assign.update_ts, 2, dbo.FNADBUSER()) update_ts,
				sdd_sale.Leg leg,
				sdd_sale.source_deal_header_id source_deal_header_id,
				NULL certificate_temp_id
			FROM matching_header_detail_info mhdi
			INNER JOIN source_deal_detail sdd_assign ON sdd_assign.source_deal_detail_id = mhdi.source_deal_detail_id_from 
			INNER JOIN gis_certificate gc_assign ON gc_assign.source_deal_header_id = mhdi.source_deal_detail_id_from
				AND gc_assign.state_value_id = mhdi.state_value_id
				AND gc_assign.tier_type = mhdi.tier_value_id
			INNER JOIN source_deal_detail sdd_sale on sdd_sale.source_deal_detail_id = mhdi.source_deal_detail_id
			LEFT JOIN static_data_value sdv	ON sdv.value_id = mhdi.state_value_id
			LEFT JOIN static_data_value sdv1 ON sdv1.value_id = mhdi.tier_value_id
			LEFT JOIN static_data_value sdv2 ON sdv2.value_id = gc_assign.certification_entity
			LEFT JOIN static_data_value sdv_year ON sdv_year.value_id = gc_assign.[year]' + 
			CASE WHEN OBJECT_ID(@certificate_table_name) IS NOT NULL THEN ' 
			LEFT JOIN ' + @certificate_table_name + ' eta ON eta.source_certificate_number = gc_assign.source_certificate_number ' ELSE '' END + '	
			WHERE mhdi.source_deal_header_id = ' + ISNULL(CAST(@source_deal_header_id AS VARCHAR(200)), 'NULL')
				+ CASE WHEN OBJECT_ID(@certificate_table_name) IS NOT NULL THEN ' AND eta.insert_del IS NULL' ELSE '' END

		--PRINT(@sql)
 		EXEC(@sql)

		SELECT [group], source_certificate_number, certification_entity [Certification Entity], jurisdiction [Jurisdiction], tier [Tier], cert_from [Cert# From], 
			   cert_to [Cert# To], [year], term_start [Term Start], term_end [Term End], leg [Leg], certificate_date [Certificate Date], expiration_date [Expiration Date], 
		sequence_from [Sequence From], sequence_to [Sequence To], source_deal_detail_id [Source Deal Detail ID], create_ts [Create TS], update_ts [Update TS], 
			   source_deal_header_id [Source Deal Header ID],certificate_temp_id [Certificate Temp ID]
		FROM #temp_sell_certificate
		ORDER BY [group]
	END
	ELSE
	BEGIN
		SET @sql = '
			SELECT CONVERT(VARCHAR(7), sdd.term_start, 120) [group],
			   gc.source_certificate_number,
			   sdv2.code [Certification Entity],
			   sdv.code [Jurisdiction],
			   sdv1.code [Tier],
			   gc.gis_certificate_number_from [Cert# From],
			   gc.gis_certificate_number_to [Cert# To],
			   sdv_year.code [year],
			   dbo.FNADateFormat(sdd.term_start) [Term Start],
			   dbo.FNADateFormat(sdd.term_end) [Term End],
				   sdd.Leg [Leg],
			   dbo.FNADateFormat(gc.gis_cert_date) [Certificate Date],
			   dbo.FNADateFormat(gc.contract_expiration_date) [Expiration Date],
			   gc.certificate_number_from_int [Sequence From],
			   gc.certificate_number_to_int [Sequence To],
			   sdd.source_deal_detail_id [Source Deal Detail ID],
			   dbo.FNAUserDateTimeFormat(gc.create_ts, 2, dbo.FNADBUSER()) [Create TS],
			   dbo.FNAUserDateTimeFormat(gc.update_ts, 2, dbo.FNADBUSER()) [Update TS],
			   sdd.source_deal_header_id [Source Deal Header ID],
			   NULL [Certificate Temp ID]
		FROM Gis_Certificate gc
			LEFT JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = gc.source_deal_header_id
			LEFT JOIN static_data_value sdv ON sdv.value_id = gc.state_value_id
			LEFT JOIN static_data_value sdv1 ON sdv1.value_id = gc.tier_type
			LEFT JOIN static_data_value sdv2 ON sdv2.value_id = gc.certification_entity
			LEFT JOIN static_data_value sdv_year ON sdv_year.value_id = gc.[year]
		'
		+
		CASE WHEN OBJECT_ID(@certificate_table_name) IS NOT NULL THEN 'LEFT JOIN ' + @certificate_table_name + ' eta ON eta.source_certificate_number = gc.source_certificate_number ' ELSE '' END
			+ 
		' WHERE sdd.source_deal_header_id = ' + ISNULL(CAST(@source_deal_header_id AS VARCHAR(200)), 'NULL')
		+ CASE WHEN OBJECT_ID( @certificate_table_name) IS NOT NULL THEN ' AND eta.insert_del IS NULL' ELSE '' END
		
		SET @sql = @sql + ' ' + 'UNION ALL 
			SELECT [group], source_certificate_number, certification_entity [Certification Entity], jurisdiction [Jurisdiction], tier [Tier], cert_from [Cert# From], cert_to [Cert# To], [year], term_start [Term Start],
				   term_end [Term End], leg [Leg], certificate_date [Certificate Date], expiration_date [Expiration Date], sequence_from [Sequence From], sequence_to [Sequence To], source_deal_detail_id [Source Deal Detail ID],
				   create_ts [Create TS], update_ts [Update TS], source_deal_header_id [Source Deal Header ID], certificate_temp_id[Certificate Temp ID]
			FROM #temp_sell_certificate
			ORDER BY [group]
			'

	  EXEC(@sql)
	END 
	END
	
	IF(@source_deal_header_id IS NULL)
	BEGIN
		SET @sql =  '
		SELECT CONVERT(VARCHAR(7), sdd.term_start, 120) [group],
			   gc.source_certificate_number,
			   sdv2.code [Certification Entity],
			   sdv.code [Jurisdiction],
			   sdv1.code [Tier],
			   gc.gis_certificate_number_from [Cert# From],
			   gc.gis_certificate_number_to [Cert# To],
			   sdv_year.code [year],
			   dbo.FNADateFormat(sdd.term_start) [Term Start],
			   dbo.FNADateFormat(sdd.term_end) [Term End],
			  sdd.Leg [Leg],
			   dbo.FNADateFormat(gc.gis_cert_date) [Certificate Date],
			   dbo.FNADateFormat(gc.contract_expiration_date) [Expiration Date],
			   gc.certificate_number_from_int [Sequence From],
			   gc.certificate_number_to_int [Sequence To],
			   sdd.source_deal_detail_id [Source Deal Detail ID],
			   dbo.FNAUserDateTimeFormat(getdate(), 2, dbo.FNADBUSER()) [Create TS],
			   dbo.FNAUserDateTimeFormat(getdate(), 2, dbo.FNADBUSER()) [Update TS],
			   sdd.source_deal_header_id [Source Deal Header ID],
			   gc.certificate_temp_id[Certificate Temp ID]
		FROM '+ @certificate_table_name + ' gc
		LEFT JOIN source_deal_detail sdd
			ON sdd.source_deal_detail_id = gc.source_deal_header_id
		LEFT JOIN static_data_value sdv
			ON sdv.value_id = gc.state_value_id
		LEFT JOIN static_data_value sdv1
			ON sdv1.value_id = gc.tier_type
		LEFT JOIN static_data_value sdv2
			ON sdv2.value_id = gc.certification_entity
		LEFT JOIN static_data_value sdv_year
			ON sdv_year.value_id = gc.[year]			
		 where gc.source_certificate_number is NULL and gc.insert_del =''i''
		 ORDER BY sdd.term_start
		 '

	    EXEC(@sql)

	END	
END
 
ELSE IF @flag = 'a'
IF(@certificate_temp_id IS NOT NULL)
BEGIN
	SET @sql = '
		SELECT gc.gis_certificate_number_from [Cert# From],
			 gc.gis_certificate_number_to [Cert# To],
			 dbo.FNAGetSQLStandardDate(gc.gis_cert_date),
			 sdd.deal_volume, 
			 gc.state_value_id,
			 gc.tier_type,
			 dbo.FNAGetSQLStandardDate(gc.contract_expiration_date),
			 dbo.FNAGetSQLStandardDate(sdd.term_start) [Term Start],
			 dbo.FNAGetSQLStandardDate(sdd.term_end) [Term End],
			 sdd.source_deal_header_id [Source Deal Header ID],
			 sdd.source_deal_detail_id [Source Deal Detail ID], 
			 sdd.leg [Leg],
			 gc.certificate_number_from_int [Sequence From],
			 gc.certificate_number_to_int [Sequence To],
			   dbo.FNAUserDateTimeFormat(GETDATE(), 2, dbo.FNADBUSER()) [Create TS],
			   dbo.FNAUserDateTimeFormat(GETDATE(), 2, dbo.FNADBUSER())[Update TS],
			 gc.source_certificate_number,
			 gc.[year],
			 gc.certification_entity [Certification Entity],
			 dbo.FNAGetSQLStandardDate(sdh.entire_term_start) AS [term_start],
			 dbo.FNAGetSQLStandardDate(sdh.entire_term_end) AS [term_end]
		FROM ' + @certificate_table_name + ' gc
		LEFT JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = gc.source_deal_header_id
		LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
		WHERE gc.certificate_temp_id = ' + @certificate_temp_id +'	
		'
		 EXEC(@sql)
END
ELSE
BEGIN
		SELECT gc.gis_certificate_number_from [Cert# From],
			   gc.gis_certificate_number_to [Cert# To],
			   dbo.FNAGetSQLStandardDate(gis_cert_date), 
			   sdd.deal_volume, 
			   gc.state_value_id,
			   gc.tier_type, 
			   dbo.FNAGetSQLStandardDate(gc.contract_expiration_date), 
			   dbo.FNAGetSQLStandardDate(sdd.term_start) [Term Start],
			   dbo.FNAGetSQLStandardDate(sdd.term_end) [Term End],	
			   sdd.source_deal_header_id [Source Deal Header ID],
			   sdd.source_deal_detail_id [Source Deal Detail ID], 
			   sdd.leg [Leg],
			   gc.certificate_number_from_int [Sequence From],
			   gc.certificate_number_to_int [Sequence To],
		   dbo.FNAUserDateTimeFormat(gc.create_ts, 2, dbo.FNADBUSER()) [Create TS],
		   dbo.FNAUserDateTimeFormat(gc.update_ts, 2, dbo.FNADBUSER())[Update TS],
			   gc.source_certificate_number,
			   gc.[year],
			   gc.certification_entity [Certification Entity],
			   dbo.FNAGetSQLStandardDate(sdh.entire_term_start) AS [term_start],
			   dbo.FNAGetSQLStandardDate(sdh.entire_term_end) AS [term_end]
		FROM source_deal_header sdh
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	LEFT JOIN Gis_Certificate gc ON sdd.source_deal_detail_id = gc.source_deal_header_id
		WHERE gc.source_certificate_number = @certificate_num
END

ELSE IF @flag = 'd'
BEGIN
	IF (@certificate_temp_id IS NOT NULL)
	BEGIN 
		IF(@certificate_temp_id != '')
		BEGIN
			EXEC('DELETE FROM ' + @certificate_table_name + ' WHERE certificate_temp_id IN (' + @certificate_temp_id + ')')
		END
	END

	SET @sql_delete = ('
		INSERT INTO ' + @certificate_table_name + ' (source_certificate_number, insert_del)
		SELECT ISNULL(item,''NULL''), ''d''
		FROM dbo.FNASplit(''' + @certificate_num + ''', '','')
	')

	EXEC(@sql_delete)

	EXEC spa_ErrorHandler 0, 'spa_certificate_detail', 'update_certificate_detail', 'update_certificate_detail', 'Successfully Updated Certificate Detail.', @certificate_process_id
END
 
ELSE IF @flag = 'q'
BEGIN
	SELECT dbo.FNAGetSQLStandardDate(sdh.entire_term_start) AS [term_start],
	       dbo.FNAGetSQLStandardDate(sdh.entire_term_end) AS [term_end],
	       sdd.source_deal_detail_id,
	       sdd.leg
	FROM source_deal_header sdh
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	WHERE sdh.source_deal_header_id = @source_deal_header_id
END

ELSE IF @flag = 't' --## To load depenedent combo Tier in Certificate Detail UI
BEGIN
	IF OBJECT_ID('tempdb..#temp_dependen_load') IS NOT NULL
	DROP TABLE #temp_dependen_load		

	CREATE TABLE #temp_dependen_load (
		value_id INT,
		code VARCHAR(1000),
		[state] VARCHAR(1000)
	)
	
	INSERT INTO #temp_dependen_load
	SELECT DISTINCT sdv.value_id, sdv.code, 
	CASE WHEN ISNULL(is_enable, 1) = 1 THEN 'enable' WHEN sdad.is_active = 1 AND ISNULL(max(is_enable), 1) = 0 AND @is_app_admin = 0 THEN 'disable' ELSE 'enable' END [state] 
	FROM static_data_value sdv
	LEFT JOIN static_data_privilege sdp ON sdv.value_id = sdp.value_id
	LEFT JOIN application_security_role asr ON sdp.role_id = asr.role_id
	LEFT JOIN application_role_user aru ON aru.role_id = asr.role_id
	LEFT JOIN state_properties_details spd ON spd.tier_id = sdv.value_id
			AND sdv.type_id = 15000	
	LEFT JOIN static_data_active_deactive sdad ON sdad.type_id = sdv.type_id
	WHERE sdv.type_id = 15000
		AND spd.state_value_id = @state_value_id
		AND (
			@user_name = sdp.user_id 
			OR @is_app_admin = 1 
			OR sdp.role_id IN (SELECT role_id FROM dbo.FNAGetUserRole(@user_name))
			OR ISNULL(sdad.is_active, 0) = 0
			)
		GROUP BY sdv.value_id, sdv.code, sdad.is_active, is_enable	

	SELECT value_id,
		   code,
		   MIN([state]) [state]
	FROM #temp_dependen_load
	GROUP BY value_id, code

END

ELSE IF @flag = 'v' 
BEGIN
	DECLARE @tmp_eligible_deals VARCHAR(150)
    SET @tmp_eligible_deals = dbo.FNAProcessTableName('TmpEligibleDeals', @user_name, @process_id)    
	
	IF OBJECT_ID ('tempdb..#inserted_detail_id') IS NOT NULL
		DROP TABLE #inserted_detail_id

	CREATE TABLE #inserted_detail_id (
		source_deal_detail_id INT
	)

	EXEC ('
		INSERT INTO Gis_Certificate (
			Source_deal_header_id, certificate_number_from_int, certificate_number_to_int, gis_certificate_number_from, gis_certificate_number_to,
			gis_cert_date, state_value_id, tier_type, contract_expiration_date, [year], certification_entity
		)
		OUTPUT INSERTED.source_deal_header_id INTO #inserted_detail_id 
	
		SELECT source_deal_header_id, certificate_number_from_int, certificate_number_to_int, gis_certificate_number_from, gis_certificate_number_to,
			   gis_cert_date, state_value_id, tier_type, contract_expiration_date, [year], certification_entity
		FROM ' + @certificate_table_name + ' cfa
		WHERE source_deal_header_id = cfa.source_deal_header_id
			AND insert_del = ''i''
	')
	
	EXEC ('
		UPDATE gc
	    SET gc.gis_certificate_number_from = gcp.gis_certificate_number_from,
	        gc.gis_certificate_number_to = gcp.gis_certificate_number_to,
	        gc.certificate_number_from_int = gcp.certificate_number_from_int,
	        gc.certificate_number_to_int = gcp.certificate_number_to_int,
	        gc.gis_cert_date = gcp.gis_cert_date,
	        gc.state_value_id = gcp.state_value_id,
	        gc.tier_type = gcp.tier_type,
	        gc.contract_expiration_date = gcp.contract_expiration_date,
	        gc.update_ts = GETDATE(),
	        gc.[year] = gcp.year,
	        gc.certification_entity = gcp.certification_entity
	    FROM gis_certificate gc
		INNER JOIN ' + @certificate_table_name + ' gcp ON gcp.source_certificate_number = gc.source_certificate_number
		WHERE gcp.insert_del = ''u''
			AND gc.source_certificate_number = gcp.source_certificate_number
	')
	   
	EXEC ('
		DELETE gcc
		FROM gis_certificate gcc 
		INNER JOIN ' + @certificate_table_name + ' etn ON etn.source_certificate_number = gcc.source_certificate_number
			AND etn.insert_del = ''d''
	')

	EXEC('SELECT DISTINCT id.source_deal_detail_id 
        INTO ' + @tmp_eligible_deals + ' 
        FROM #inserted_detail_id id
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = id.source_deal_detail_id
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id 
			AND sdh.is_environmental = ''y'' AND sdh.header_buy_sell_flag = ''b''')
 
    EXEC spa_return_certificate_volume_detail 'u', NULL, @process_id

	IF @@ERROR <> 0
	BEGIN
	    EXEC spa_ErrorHandler @@ERROR, 'spa_certificate_detail', 'delete_certificate', 'delete_certificate', 'Failed to delete certificate.', ''
	END
END
GO