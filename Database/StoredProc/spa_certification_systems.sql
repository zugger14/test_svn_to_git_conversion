SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[spa_certification_systems]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_certification_systems]
GO

CREATE PROCEDURE [dbo].[spa_certification_systems]
	@flag AS CHAR(1),
	@value_id AS VARCHAR(1000) = NULL,
	@xmlValue1 AS VARCHAR(MAX) = NULL,
	@xmlValue2 AS VARCHAR(MAX) = NULL,
	@call_from VARCHAR(MAX) = NULL
	
AS

SET NOCOUNT ON

DECLARE @sql VARCHAR(MAX) = ''

IF @flag = 's' 
BEGIN
	SELECT sdv.[value_id], 
		   sdv.[type_id], 
		   sdv.code, 
		   sdv.[description], 
		   cr.gis_id, 
		   cr.curve_id, 
		   cr.cert_rule, 
		   cr.reporting_type, 
		   cr.[address], 
		   cr.phone_no, 
		   cr.fax_email, 
		   cr.website, 
		   cr.interconnecting_utility, 
		   cr.voltage_level, 
		   cr.contact_name, 
		   cr.contact_address, 
		   cr.contact_phone, 
		   cr.contact_email, 
		   cr.control_area_operator 
	FROM static_data_value sdv
	LEFT JOIN certificate_rule cr ON sdv.[value_id] = cr.gis_id
	INNER JOIN dbo.FNASplit(@value_id, ',') di ON di.item = sdv.value_id
	WHERE sdv.[type_id] = 10011
END
ELSE IF @flag IN ('i' , 'u')
BEGIN
	BEGIN TRY
		DECLARE @idoc INT
		DECLARE @doc VARCHAR(1000)

		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlValue1

		SELECT * INTO #ztbl_xmlvalue
		FROM OPENXML (@idoc, '/Root/PSRecordset', 2)
			 WITH (	 [value_id] INT '@value_id',
					 [type_id] INT '@type_id',
					 [code]  VARCHAR(500) '@code',
					 [description]  VARCHAR(500) '@description')

		DECLARE @idoc2 INT
		DECLARE @doc2 VARCHAR(1000)

		EXEC sp_xml_preparedocument @idoc2 OUTPUT, @xmlValue2

		SELECT * INTO #ztbl_xmlvalue2
		FROM OPENXML (@idoc2, '/Root/PSRecordset', 2)
			WITH (  gis_id INT '@gis_id',
					curve_id INT '@curve_id',
					cert_rule VARCHAR(500) '@cert_rule',
					reporting_type INT '@reporting_type',
					[address] VARCHAR(500) '@address',
					phone_no VARCHAR(500) '@phone_no',
					fax_email VARCHAR(500) '@fax_email',
					website VARCHAR(500) '@website',
					interconnecting_utility VARCHAR(500) '@interconnecting_utility',
					voltage_level VARCHAR(500) '@voltage_level',
					contact_name VARCHAR(500) '@contact_name',
					contact_address VARCHAR(500) '@contact_address',
					contact_phone VARCHAR(500) '@contact_phone',
					contact_email VARCHAR(500) '@contact_email',
					control_area_operator VARCHAR(500) '@control_area_operator')

		BEGIN TRAN
			MERGE static_data_value AS sdv USING (
				SELECT [type_id], [value_id], [code], [description]
				FROM #ztbl_xmlvalue) zxv ON sdv.[value_id] = zxv.[value_id]
				WHEN NOT MATCHED BY TARGET THEN
					INSERT ([type_id], [code], [description])
					VALUES (zxv.[type_id], zxv.[code], zxv.[description])
				WHEN MATCHED THEN
					UPDATE SET    code = zxv.code
								, [description] = zxv.[description];

				DECLARE @value_id_iu INT
				SELECT @value_id_iu = [value_id] FROM #ztbl_xmlvalue
				IF(@value_id_iu = '' OR @value_id_iu = null)
				BEGIN
					SET @value_id_iu = SCOPE_IDENTITY()
				END

			IF @flag = 'u'
			BEGIN
				MERGE certificate_rule AS cr USING (
					SELECT  gis_id,
							curve_id,
							cert_rule,
							reporting_type,
							[address],
							phone_no,
							fax_email,
							website,
							interconnecting_utility,
							voltage_level,
							contact_name,
							contact_address,
							contact_phone,
							contact_email,
							control_area_operator
					FROM #ztbl_xmlvalue2) zxv2 ON cr.gis_id = zxv2.gis_id
					WHEN NOT MATCHED BY TARGET THEN 
						INSERT (gis_id, curve_id, cert_rule, reporting_type, [address], phone_no, fax_email, website, interconnecting_utility, voltage_level, contact_name, contact_address, contact_phone, contact_email, control_area_operator)
						VALUES (zxv2.gis_id, 
								NULLIF(zxv2.curve_id, ''), 
								NULLIF(zxv2.cert_rule, ''), 
								NULLIF(zxv2.reporting_type, ''), 
								NULLIF(zxv2.[address], ''), 
								NULLIF(zxv2.phone_no, ''), 
								NULLIF(zxv2.fax_email, ''), 
								NULLIF(zxv2.website, ''), 
								NULLIF(zxv2.interconnecting_utility, ''), 
								NULLIF(zxv2.voltage_level, ''), 
								NULLIF(zxv2.contact_name, ''), 
								NULLIF(zxv2.contact_address, ''), 
								NULLIF(zxv2.contact_phone, ''), 
								NULLIF(zxv2.contact_email, ''), 
								NULLIF(zxv2.control_area_operator, ''))
					WHEN MATCHED THEN
						UPDATE SET  gis_id					= NULLIF(zxv2.gis_id, ''),
									curve_id				= NULLIF(zxv2.curve_id, ''),
									cert_rule				= NULLIF(zxv2.cert_rule, ''),
									reporting_type			= NULLIF(zxv2.reporting_type, ''),
									[address]				= NULLIF(zxv2.[address], ''),
									phone_no				= NULLIF(zxv2.phone_no, ''),
									fax_email				= NULLIF(zxv2.fax_email, ''),
									website					= NULLIF(zxv2.website, ''),
									interconnecting_utility = NULLIF(zxv2.interconnecting_utility, ''),
									voltage_level			= NULLIF(zxv2.voltage_level, ''),
									contact_name			= NULLIF(zxv2.contact_name, ''),
									contact_address			= NULLIF(zxv2.contact_address, ''),
									contact_phone			= NULLIF(zxv2.contact_phone, ''),
									contact_email			= NULLIF(zxv2.contact_email, ''),
									control_area_operator	= NULLIF(zxv2.control_area_operator, '');
				END

				EXEC spa_ErrorHandler 0
									, 'Certification Systems'
									, 'spa_certification_systems'
									, 'Success'
									, 'Changed have been saved successfully.'
									, @value_id_iu
		COMMIT
				
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK
		
		DECLARE @msg VARCHAR(5000)
		SELECT @msg = 'Failed Inserting record (' + ERROR_MESSAGE() + ').'
		DECLARE @err_num INT = ERROR_NUMBER()
		IF @err_num = 2601
				SELECT @msg = 'Duplicate data in Date From'
		ELSE IF @err_num = 2627
			SELECT @msg = 'Duplicate data in (Data Type and <b>Name</b>)'
	
		EXEC spa_ErrorHandler -1
			, 'Certification Systems'
			, 'spa_certification_systems'
			, 'Error'
			, @msg
			, 'Failed Inserting Record'
	END CATCH
END
ELSE IF @flag = 'd' 
BEGIN
	BEGIN TRY
		BEGIN TRAN
			IF @call_from = 'setup_static_data'
			BEGIN
				DECLARE @idoc3 INT
				EXEC sp_xml_preparedocument @idoc3 OUTPUT,
					 @xmlValue1
				
				IF OBJECT_ID('tempdb..#delete_static_data') IS NOT NULL
					DROP TABLE #delete_static_data
	      
				SELECT grid_id
				INTO #delete_static_data
				FROM   OPENXML(@idoc3, '/Root/GridGroup/GridDelete', 1) 
				WITH (
					grid_id INT
				)
				
				DELETE cr
				FROM certificate_rule cr 
				INNER JOIN #delete_static_data dsd ON dsd.grid_id = cr.gis_id
				
				DELETE sdv
				FROM static_data_value sdv
				INNER JOIN #delete_static_data dsd ON dsd.grid_id = sdv.value_id
				
				EXEC spa_ErrorHandler 0
				, 'Certification Systems'
				, 'spa_certification_systems'
				, 'Success'
				, 'Changed have been saved successfully.'
				, ''
			END
			ELSE
			BEGIN
				DELETE cr
				FROM certificate_rule cr
				INNER JOIN dbo.FNASplit(@value_id, ',') di ON di.item = cr.gis_id

				DELETE sdv
				FROM static_data_value sdv
				INNER JOIN dbo.FNASplit(@value_id, ',') di ON di.item = sdv.value_id

				EXEC spa_ErrorHandler 0
					, 'Certification Systems'
					, 'spa_certification_systems'
					, 'Success'
					, 'Changed have been saved successfully.'
					, @value_id
			END
		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
	
		DECLARE @msg_del VARCHAR(5000)
		SELECT @msg_del = 'Failed deleting record (' + ERROR_MESSAGE() + ').'
	
		EXEC spa_ErrorHandler -1
				, 'Certification Systems'
				, 'spa_certification_systems'
				, 'Error'
				, @msg_del
				, 'Failed Deleteing Record'
	END CATCH
END

GO