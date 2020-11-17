SET ANSI_NULLS ON
GO
  
SET QUOTED_IDENTIFIER ON
GO 


/**
	Generic SP to insert/update values in the table defined in the counterparty_shipper_info

	Parameters
	@flag : Operational flag 
	@xml : Grid value in XML form.
	@source_counterparty_id : Source counterparty id
	@counterparty_shipper_info_id : Counterparty shipper info id
    @shipper_code_id : Shipper Code ID
*/

CREATE OR ALTER PROC spa_counterparty_shipper_info
	@flag CHAR(1),
	@xml VARCHAR(MAX) = NULL,
	@source_counterparty_id INT = NUll,
	@counterparty_shipper_info_id INT = NULL,
    @shipper_code_id INT = NULL
AS 

SET NOCOUNT ON

/*

DECLARE @flag CHAR(1),
	@xml VARCHAR(MAX) = NULL,
	@source_counterparty_id INT = NUll,
	@counterparty_shipper_info_id INT = NULL,
    @shipper_code_id INT = NULL

SELECT @flag = 'i'
	, @xml='<Root>
		<GridDelete></GridDelete>
		<GridRow shipper_code_mapping_detail_id="" shipper_code_id="" location_id="2848" effective_date="2020-11-01" shipper_code1="sdasdasd" 
			shipper_code="asdasd" shipper_code1_is_default="y" is_default="y" is_active="y" external_id="" internal_counterparty="">
		</GridRow>
		<GridRow shipper_code_mapping_detail_id="" shipper_code_id="" location_id="2848" effective_date="2020-11-01" shipper_code1="dfgdf" 
			shipper_code="dfg" shipper_code1_is_default="y" is_default="y" is_active="y" external_id="" internal_counterparty="">
		</GridRow>
	</Root>'
	, @source_counterparty_id=7730

--*/

DECLARE @idoc INT
	, @function_id VARCHAR(100)
	, @desc VARCHAR(MAX)
	, @user_login_id NVARCHAR(25) = dbo.FNADBUser()

IF @flag='s'
BEGIN
	SELECT counterparty_shipper_info_id
		, source_counterparty_id
		, [location]
		, commodity		   
		, effective_date
		, shipper_code	   
	FROM counterparty_shipper_info
	WHERE source_counterparty_id = @source_counterparty_id
END

IF @flag = 'u'
BEGIN	
	IF OBJECT_ID('tempdb..#shipper_info') IS NOT NULL 
		DROP TABLE #shipper_info

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml	
	
	SELECT NULLIF(counterparty_shipper_info_id, 0) counterparty_shipper_info_id
		, source_counterparty_id
		, [location]
		, commodity
		, effective_date
		, shipper_code
	INTO #shipper_info
	FROM OPENXML(@idoc, '/Root/GridSave', 2)
	WITH (
		counterparty_shipper_info_id INT '@counterparty_shipper_info_id'
		, source_counterparty_id INT '@source_counterparty_id'
		, [location] INT '@location'
		, commodity INT '@commodity'
		, effective_date DATE '@effective_date'
		, shipper_code VARCHAR(50) '@shipper_code'
	)
	
	MERGE counterparty_shipper_info AS TARGET
	USING (SELECT * FROM #shipper_info) AS SOURCE
		ON TARGET.counterparty_shipper_info_id = SOURCE.counterparty_shipper_info_id
	WHEN MATCHED
		THEN
			UPDATE SET TARGET.[location] = ISNULL(SOURCE.[location], TARGET.[location])
				, TARGET.commodity = ISNULL(SOURCE.commodity, TARGET.commodity)
				, TARGET.effective_date = ISNULL(SOURCE.effective_date, TARGET.effective_date)
				, TARGET.shipper_code = ISNULL(SOURCE.shipper_code, TARGET.shipper_code)
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT ([source_counterparty_id]
				, [location]
				, commodity
				, effective_date
				, shipper_code
			)
			VALUES (SOURCE.[source_counterparty_id]
				, SOURCE.[location]
				, SOURCE.commodity
				, SOURCE.effective_date
				, SOURCE.shipper_code
			);
	
	EXEC spa_ErrorHandler 0
		, 'Shipper Info'
		, 'spa_counterparty_shipper_info'
		, 'Success'
		, 'Changes have been saved successfully.'
		, @counterparty_shipper_info_id
	
END
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY		
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml	
		
		DELETE csi 
		FROM counterparty_shipper_info csi
		INNER JOIN (			
			SELECT NULLIF(grid_id, '') grid_id
			FROM OPENXML (@idoc, '/Root/GridDelete', 2)
			WITH (	
				grid_id VARCHAR(100) '@grid_id'
			)
		) sub
			ON csi.counterparty_shipper_info_id = sub.grid_id
			
		EXEC spa_ErrorHandler @@ERROR
			, 'Shipper Info Delete'
			, 'spa_counterparty_shipper_info'
			, 'Success'
			, 'Changes have been saved successfully.'
			, @source_counterparty_id

		--COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK			
		
		SET @desc = dbo.FNAHandleDBError(@function_id)

		EXEC spa_ErrorHandler -1
			, 'Shipper Info'
			, 'spa_counterparty_shipper_info'
			, 'Error'
			, @desc
			, NULL
	END CATCH
END

IF @flag = 'b' 
BEGIN
	SELECT counterparty_shipper_info_id
		, shipper_code 
	FROM counterparty_shipper_info
END

IF @flag='g'
BEGIN
    SELECT source_counterparty_id
		, counterparty_id 
	FROM source_counterparty
END

IF @flag = 'k'
BEGIN
    SELECT
          scmd.shipper_code_mapping_detail_id
		, scmd.shipper_code_id
		, scmd.location_id
		, scmd.effective_date
		, scmd.shipper_code1 [shipper_code1]
		, scmd.shipper_code [shipper_code2]
        , NULLIF(scmd.shipper_code1_is_default, '') shipper_code1_is_default
        , NULLIF(scmd.is_default, '') shipper_code2_is_default
        , NULLIF(scmd.is_active, '') is_active
		, scmd.external_id
		, scmd.internal_counterparty
	FROM shipper_code_mapping_detail scmd
	INNER JOIN shipper_code_mapping scm
		ON scmd.shipper_code_id = scm.shipper_code_id
	INNER JOIN source_counterparty sc
		ON sc.source_counterparty_id = scm.counterparty_id
	WHERE scm.counterparty_id = @source_counterparty_id
END

IF @flag = 'l' -- Populate Shipper Code dropdown in maintain_field_deal
BEGIN
	SELECT shipper_code_mapping_detail_id
		, shipper_code 
	FROM shipper_code_mapping scm 
	INNER JOIN shipper_code_mapping_detail scmd 
		ON scmd.shipper_code_id = scm.shipper_code_id
END

ELSE IF @flag = 'i'
BEGIN
	DROP TABLE IF EXISTS #delete_shipper_code_mapping_detail

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml	
	
	SELECT NULLIF(shipper_code_mapping_detail_id, 0) shipper_code_mapping_detail_id
		, NULLIF(shipper_code_id, 0) shipper_code_id
		, location_id
		, effective_date
		, shipper_code1
		, shipper_code
		, shipper_code1_is_default
		, is_default
		, is_active
		, external_id
		, internal_counterparty
	INTO #delete_shipper_code_mapping_detail
	FROM OPENXML(@idoc, '/Root/GridDelete/GridRow', 2)
	WITH (
		shipper_code_mapping_detail_id INT '@shipper_code_mapping_detail_id'
		, shipper_code_id INT '@shipper_code_id'
		, location_id INT '@location_id'
		, effective_date DATE '@effective_date'
		, shipper_code1 VARCHAR(100) '@shipper_code1'
		, shipper_code VARCHAR(100) '@shipper_code'
		, shipper_code1_is_default CHAR(1) '@shipper_code1_is_default'
		, is_default CHAR(1) '@is_default'
		, is_active CHAR(1) '@is_active'
		, external_id VARCHAR(50) '@external_id'
		, internal_counterparty VARCHAR(100) '@internal_counterparty'
	)

	DROP TABLE IF EXISTS #shipper_code_mapping_detail

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml	
	
	SELECT NULLIF(shipper_code_mapping_detail_id, 0) shipper_code_mapping_detail_id
		, NULLIF(shipper_code_id, 0) shipper_code_id
		, location_id
		, effective_date
		, shipper_code1
		, shipper_code
		, shipper_code1_is_default
		, is_default
		, is_active
		, external_id
		, internal_counterparty
	INTO #shipper_code_mapping_detail
	FROM OPENXML(@idoc, '/Root/GridRow', 2)
	WITH (
		shipper_code_mapping_detail_id INT '@shipper_code_mapping_detail_id'
		, shipper_code_id INT '@shipper_code_id'
		, location_id INT '@location_id'
		, effective_date DATE '@effective_date'
		, shipper_code1 VARCHAR(100) '@shipper_code1'
		, shipper_code VARCHAR(100) '@shipper_code'
		, shipper_code1_is_default CHAR(1) '@shipper_code1_is_default'
		, is_default CHAR(1) '@is_default'
		, is_active CHAR(1) '@is_active'
		, external_id VARCHAR(50) '@external_id'
		, internal_counterparty VARCHAR(100) '@internal_counterparty'
	)

	BEGIN TRY
		BEGIN TRAN
		DECLARE @new_shipper_code_id INT

		IF NOT EXISTS(
			SELECT 1 FROM shipper_code_mapping
			WHERE counterparty_id = @source_counterparty_id
		) BEGIN
			INSERT INTO shipper_code_mapping (counterparty_id)
			SELECT @source_counterparty_id

			SET @new_shipper_code_id = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			SELECT TOP 1 @new_shipper_code_id = shipper_code_id 
			FROM shipper_code_mapping
			WHERE counterparty_id = @source_counterparty_id
		END

		DELETE scmd
		FROM #delete_shipper_code_mapping_detail dscmd
		INNER JOIN shipper_code_mapping_detail scmd
			ON dscmd.shipper_code_mapping_detail_id = scmd.shipper_code_mapping_detail_id

		IF EXISTS(
			SELECT Count(*)
			FROM #shipper_code_mapping_detail
			GROUP BY effective_date
				, location_id
				, shipper_code1_is_default
				, is_default
			HAVING COUNT(*) > 1 
				AND is_default = 'y' 
				AND shipper_code1_is_default = 'y'

			UNION

			SELECT 1
			FROM #shipper_code_mapping_detail tscmd
			INNER JOIN shipper_code_mapping_detail scmd
				ON scmd.effective_date = tscmd.effective_date
					AND scmd.location_id = tscmd.location_id
					AND (
						scmd.shipper_code1_is_default = tscmd.shipper_code1_is_default 
							OR scmd.is_default = tscmd.is_default
					)
			INNER JOIN shipper_code_mapping scm
				ON scm.shipper_code_id = scmd.shipper_code_id
			WHERE scm.counterparty_id = @source_counterparty_id
				AND (
					tscmd.is_default = 'y' 
						OR tscmd.shipper_code1_is_default = 'y'
				)
				AND tscmd.shipper_code_mapping_detail_id <> scmd.shipper_code_mapping_detail_id
		)
		BEGIN
			EXEC spa_ErrorHandler 1
				, 'Shipper Code Maping Detail'
				, 'spa_counterparty_shipper_info'
				, 'Error'
				, 'Multiple data saved with default value as ''YES'' for the same effective data'
				, @source_counterparty_id

			RETURN
		END

		MERGE shipper_code_mapping_detail AS TARGET
		USING (SELECT * FROM #shipper_code_mapping_detail) AS SOURCE
			ON TARGET.shipper_code_mapping_detail_id = SOURCE.shipper_code_mapping_detail_id
		WHEN MATCHED THEN
			UPDATE SET TARGET.location_id = ISNULL(SOURCE.location_id, TARGET.location_id)
				, TARGET.effective_date = ISNULL(SOURCE.effective_date, TARGET.effective_date)
				, TARGET.shipper_code1 = ISNULL(SOURCE.shipper_code1, TARGET.shipper_code1)
				, TARGET.shipper_code = ISNULL(SOURCE.shipper_code, TARGET.shipper_code)
				, TARGET.shipper_code1_is_default = ISNULL(SOURCE.shipper_code1_is_default, TARGET.shipper_code1_is_default)
				, TARGET.is_default = ISNULL(SOURCE.is_default, TARGET.is_default)
				, TARGET.is_active = ISNULL(SOURCE.is_active, TARGET.is_active)
				, TARGET.external_id = ISNULL(SOURCE.external_id, TARGET.external_id)
				, TARGET.internal_counterparty = ISNULL(SOURCE.internal_counterparty, TARGET.internal_counterparty)
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (shipper_code_id
				, location_id
				, effective_date
				, shipper_code1
				, shipper_code
				, shipper_code1_is_default
				, is_default
				, is_active
				, external_id
				, internal_counterparty
			)
			VALUES (COALESCE(SOURCE.shipper_code_id, @new_shipper_code_id)
				, SOURCE.location_id
				, SOURCE.effective_date
				, SOURCE.shipper_code1
				, SOURCE.shipper_code
				, SOURCE.shipper_code1_is_default
				, SOURCE.is_default
				, SOURCE.is_active
				, SOURCE.external_id
				, SOURCE.internal_counterparty
			);

		IF NOT EXISTS(
			SELECT 1 FROM shipper_code_mapping_detail scmd
			INNER JOIN shipper_code_mapping scm
				on scm.shipper_code_id = scmd.shipper_code_id
			WHERE scm.counterparty_id = @source_counterparty_id
		)
		BEGIN
			DELETE FROM shipper_code_mapping where counterparty_id = @source_counterparty_id
		END

		COMMIT TRAN

		EXEC spa_ErrorHandler 0
			, 'Shipper Code Maping Detail'
			, 'spa_counterparty_shipper_info'
			, 'Success'
			, 'Changes have been saved successfully.'
			, @source_counterparty_id
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN

		SET @desc = dbo.FNAHandleDBError('20016500')
            
        EXEC spa_ErrorHandler -1,
	        'Shipper Code Mapping',
	        'spa_counterparty_shipper_info',
	        'Error',
	        @desc,
	         ''
	END CATCH
END
