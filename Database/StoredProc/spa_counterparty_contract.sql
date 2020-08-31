IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_counterparty_contract]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_counterparty_contract]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_counterparty_contract]
	@flag CHAR(1),
	@ppa_counterparty_id INT = NULL,
    @ppa_contract_id INT = NULL,
	@contract_allocation NUMERIC(6,2) = NULL,
	@generator_id INT = NULL,
	@type VARCHAR(1) = NULL,
	@location_id INT = NULL,
	@grid_xml VARCHAR(MAX) = NULL
AS 
SET NOCOUNT ON
DECLARE @sub_id INT
DECLARE @sum_contract_allocation NUMERIC(6,2)
DECLARE @allocatable_percent NUMERIC(6,2)
DECLARE @error_msg VARCHAR(500)

SELECT @sub_id = sub_id FROM contract_group WHERE contract_id = @ppa_contract_id

IF @type IS NULL	
	SELECT @type = int_ext_flag FROM dbo.source_counterparty

IF @flag = 's'	
BEGIN
	SELECT	generator_id [Generator ID],
			cg.contract_id AS [Contract ID],	
			sml.source_minor_location_id [Location],
			contract_allocation Allocation
	FROM contract_group cg 
	INNER JOIN rec_generator rg ON cg.contract_id = rg.ppa_contract_id
	LEFT JOIN source_minor_location sml ON rg.location_id = sml.source_minor_location_id
	WHERE ppa_counterparty_id = @ppa_counterparty_id
END
ELSE IF @flag = 'a'
	SELECT cg.contract_id AS [CONTRACT Id],
	       cg.contract_name AS [CONTRACT Name],
	       contract_allocation,
	       generator_id,
	       rg.location_id,
	       sml.Location_Name
	FROM   contract_group cg
	INNER JOIN rec_generator rg ON  cg.contract_id = rg.ppa_contract_id
	LEFT JOIN source_minor_location sml ON rg.location_id = sml.source_minor_location_id
	WHERE  ppa_counterparty_id = @ppa_counterparty_id
	       AND generator_id = @generator_id
ELSE IF @flag = 'd'
BEGIN
	IF EXISTS(SELECT 1 FROM dbo.Calc_invoice_Volume_variance WHERE  generator_id = @generator_id)
	BEGIN
		EXEC spa_ErrorHandler  -1
			, 'Counterparty Contract'
			, 'spa_counterparty_contract'
			, 'DB Error'
			, 'Cannot delete contract. The Contract information has been used in Counterparty Invoice.'
			, ''
		RETURN
	END

	DELETE FROM rec_generator WHERE  ppa_counterparty_id=@ppa_counterparty_id AND generator_id = @generator_id
	IF @@ERROR <> 0
		EXEC spa_ErrorHandler  @@ERROR
			, 'Counterparty Contract'
			, 'spa_counterparty_contract'
			, 'DB Error'
			, 'Failed to delete contract.'
			, ''
	ELSE
		EXEC spa_ErrorHandler 0
			, 'Counterparty Contract'
			, 'spa_counterparty_contract'
			, 'Success'
			, 'Contract successfully deleted.'
			, ''
END
ELSE IF @flag = 'i'
BEGIN
	/** Don't allow multiple insertion if the type is broker **/

	IF @type = 'b'
	BEGIN
		DECLARE @count VARCHAR(50)

		SELECT @count=COUNT(*) FROM rec_generator rg 
		LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = rg.ppa_counterparty_id 
		WHERE sc.int_ext_flag='b' AND sc.source_counterparty_id = @ppa_counterparty_id

		IF @count>0
		BEGIN
			EXEC spa_ErrorHandler @count
				, 'Counterparty Contract'
				, 'spa_counterparty_contract'
				, 'DB Error'
				, 'Multiple contract cannot be inserted.'
				, ''
			RETURN
		END
	END
		
	IF @type <> 'm' -- only validate for counterparty_type<>'model' 	
	BEGIN
			SELECT @sum_contract_allocation = SUM(contract_allocation) + @contract_allocation
			FROM contract_group cg 
			JOIN rec_generator rg ON cg.contract_id = rg.ppa_contract_id
			WHERE contract_id = @ppa_contract_id
			GROUP BY contract_id,contract_name
			
			SET @allocatable_percent = 1 - (@sum_contract_allocation - @contract_allocation)
			
			IF @contract_allocation <= 0 OR @contract_allocation > 1
			BEGIN
				EXEC spa_ErrorHandler  -1
					, 'Counterparty Contract'
					, 'spa_counterparty_contract'
					, 'DB Error'
					, 'Contract allocation should be greater than 0 and less than or equal to 1.'
					, ''
				RETURN
			END
			
			IF @sum_contract_allocation > 1
			BEGIN
				SET @error_msg = 'The sum of allocation exceeds 1. The remaining allocatable amount is ' + CAST(@allocatable_percent AS VARCHAR) + '.'
				EXEC spa_ErrorHandler  @sum_contract_allocation
					, 'Counterparty Contract'
					, 'spa_counterparty_contract'
					, 'DB Error'
					, @error_msg
					, ''
				RETURN
			END		
	
	END
	/*************end of validation *******/
	INSERT INTO rec_generator (code, [name], ppa_counterparty_id, ppa_contract_id, contract_allocation, legal_entity_value_id
								, location_id, registered, id) 
	VALUES ('counterparty_' + CAST(@ppa_counterparty_id AS VARCHAR) + CAST(@ppa_contract_id AS VARCHAR)
			, 'counterparty_' + CAST(@ppa_counterparty_id AS VARCHAR) + CAST(@ppa_contract_id AS VARCHAR)
			, @ppa_counterparty_id, @ppa_contract_id, @contract_allocation, @sub_id, @location_id, 'n'
			, 'counterparty_' + CAST(@ppa_counterparty_id AS VARCHAR) + CAST(@ppa_contract_id AS VARCHAR))
			
	IF @@ERROR <> 0
		EXEC spa_ErrorHandler  @@ERROR
			, 'Counterparty Contract'
			, 'spa_counterparty_contract'
			, 'DB Error'
			, 'Failed to insert contract.'
			, ''
	
	ELSE
		EXEC spa_ErrorHandler 0
			, 'Counterparty Contract'
			, 'spa_counterparty_contract'
			, 'Success'
			, 'Contract successfully inserted.'
			, ''
END	
ELSE IF @flag='u'
BEGIN
	UPDATE rec_generator 
		SET code = 'counterparty_' + CAST(@ppa_counterparty_id AS VARCHAR) + CAST(@ppa_contract_id AS VARCHAR)
			, [name] = 'counterparty_'+CAST(@ppa_counterparty_id AS VARCHAR)+CAST(@ppa_contract_id AS VARCHAR)
			, ppa_counterparty_id = @ppa_counterparty_id
			, ppa_contract_id = @ppa_contract_id
			, contract_allocation = @contract_allocation 
			, legal_entity_value_id = @sub_id
			, location_id = @location_id
			, registered = 'n'
	WHERE	ppa_counterparty_id = @ppa_counterparty_id 
		AND generator_id = @generator_id

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler  @@ERROR
			, 'Counterparty Contract'
			, 'spa_counterparty_contract'
			, 'DB Error'
			, 'Failed to update contract.'
			, ''
	
	ELSE
		EXEC spa_ErrorHandler 0
			, 'Counterparty Contract'
			, 'spa_counterparty_contract'
			, 'Success'
			, 'Contract successfully updated.'
			, ''
END	
ELSE IF @flag = 'm'	-- call from Model
BEGIN
	SELECT	cg.contract_id AS [SystemID],
			cg.UD_Contract_id AS [ID],
			cg.contract_name AS [Name]
	FROM contract_group cg 
	INNER JOIN rec_generator rg ON cg.contract_id = rg.ppa_contract_id
	WHERE ppa_counterparty_id = @ppa_counterparty_id
END

/*
*	Added By: Achyut Khadka
*	Modified Date: 12/15/2015
*/
ELSE IF @flag = 'n'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			DECLARE @idoc INT

			IF OBJECT_ID('tempdb..#temp_contract_allocation') IS NOT NULL
				DROP TABLE #temp_contract_allocation
		
			CREATE TABLE #temp_contract_allocation
			(
				generator_id INT,
				ppa_contract_id INT,
				location_id INT,
				contract_allocation NUMERIC(6,2),
				ppa_counterparty_id INT
			)

			EXEC sp_xml_preparedocument @idoc OUTPUT, @grid_xml

			INSERT INTO #temp_contract_allocation (
											generator_id,
											ppa_contract_id,
											location_id,
											contract_allocation,
											ppa_counterparty_id
										)
			SELECT							NULLIF(generator_id, ''),
											NULLIF(ppa_contract_id,''),
											NULLIF(location_id,''),
											contract_allocation,
											NULLIF(ppa_counterparty_id,'')
			FROM OPENXML (@idoc, '/GridGroup/Grid/GridRow', 2)
				WITH ( 
					generator_id				VARCHAR(20)	 '@generator_id'
					,ppa_contract_id			VARCHAR(20)	 '@ppa_contract_id'
					,location_id				VARCHAR(20)	 '@location_id'
					,contract_allocation		NUMERIC(6,2) '@contract_allocation'
					,ppa_counterparty_id		VARCHAR(20)	 '@ppa_counterparty_id'
				)

			IF OBJECT_ID('tempdb..#temp_contract_allocation_sum') IS NOT NULL
				DROP TABLE #temp_contract_allocation_sum

			CREATE TABLE #temp_contract_allocation_sum
			(	generator_id INT,
				ppa_contract_id INT,
				contract_allocation NUMERIC(6,2)
			)
			
			INSERT INTO #temp_contract_allocation_sum
			SELECT rg.generator_id, rg.ppa_contract_id, SUM(rg.contract_allocation) sum_allocation
			FROM rec_generator rg
			LEFT JOIN #temp_contract_allocation tca ON  rg.generator_id = tca.generator_id
			WHERE tca.generator_id IS NULL
			GROUP BY rg.ppa_contract_id,rg.generator_id

			IF OBJECT_ID('tempdb..#temp_contract_allocation_exceed') IS NOT NULL
				DROP TABLE #temp_contract_allocation_exceed

			CREATE TABLE #temp_contract_allocation_exceed
			(	
				ppa_contract_id INT,
				contract_allocation NUMERIC(6,2)
			)
			
			INSERT INTO #temp_contract_allocation_exceed
			SELECT tca.ppa_contract_id, ISNULL(tca.contract_allocation,'0') + ISNULL(tcas.contract_allocation,'0') -1  sum_allocation
			FROM (SELECT  ppa_contract_id, SUM(contract_allocation) contract_allocation FROM #temp_contract_allocation GROUP BY ppa_contract_id) tca
			LEFT JOIN (SELECT ppa_contract_id, SUM(contract_allocation) contract_allocation FROM #temp_contract_allocation_sum GROUP BY ppa_contract_id) tcas ON tca.ppa_contract_id = tcas.ppa_contract_id
			WHERE ISNULL(tca.contract_allocation,'0') + ISNULL(tcas.contract_allocation,'0') > 1

			IF EXISTS(SELECT 1 FROM #temp_contract_allocation_exceed)
			BEGIN
				SELECT @error_msg = ISNULL(@error_msg + ', ', ' ')  + '<b>' + cg.contract_name + '</b> by '+ CAST(tcae.contract_allocation AS VARCHAR(30))
				FROM #temp_contract_allocation_exceed tcae
				LEFT JOIN contract_group cg ON cg.contract_id = tcae.ppa_contract_id
				
				SET @error_msg = 'The sum of allocation exceeds 1 for Contract(s)' + @error_msg
				
				EXEC spa_ErrorHandler  -1
					, 'Counterparty Contract'
					, 'spa_counterparty_contract'
					, 'DB Error'
					, @error_msg
					, ''
				
				IF @@TRANCOUNT > 0
					ROLLBACK
				
				RETURN
			END
			
			UPDATE m
				SET m.ppa_contract_id = tma.ppa_contract_id,
					m.location_id = tma.location_id,
					m.contract_allocation = tma.contract_allocation
				FROM #temp_contract_allocation tma
					INNER JOIN rec_generator m
						ON tma.generator_id = m.generator_id
				WHERE tma.generator_id IS NOT NULL
		
			INSERT INTO rec_generator(ppa_counterparty_id,code, name, ppa_contract_id, location_id, contract_allocation, id, registered)
			SELECT	ppa_counterparty_id,
					'counterparty_' + CAST(ppa_counterparty_id AS VARCHAR) + CAST(ppa_contract_id AS VARCHAR)
					, 'counterparty_' + CAST(ppa_counterparty_id AS VARCHAR) + CAST(ppa_contract_id AS VARCHAR)
					, ppa_contract_id,location_id,contract_allocation
					, 'counterparty_' + CAST(ppa_counterparty_id AS VARCHAR) + CAST(ppa_contract_id AS VARCHAR)
					, 'n'
			FROM #temp_contract_allocation
			WHERE generator_id IS NULL

			IF OBJECT_ID('tempdb..#temp_contract_allocation_delete') IS NOT NULL
				DROP TABLE #temp_contract_allocation_delete
		
			CREATE TABLE #temp_contract_allocation_delete
			(
				generator_id INT
			)

			EXEC sp_xml_preparedocument @idoc OUTPUT, @grid_xml

			INSERT INTO #temp_contract_allocation_delete (generator_id)
			SELECT	generator_id
			FROM OPENXML (@idoc, '/GridGroup/GridDelete/GridRow', 2)
				WITH ( 
					generator_id	VARCHAR(20)	 '@generator_id'
				)
			
			IF EXISTS(SELECT 1 FROM dbo.Calc_invoice_Volume_variance  civv
							LEFT JOIN #temp_contract_allocation_delete d
							ON d.generator_id = civv.generator_id
						WHERE d.generator_id IS NOT NULL)
			BEGIN
				EXEC spa_ErrorHandler  -1
					, 'Counterparty Contract'
					, 'spa_counterparty_contract'
					, 'DB Error'
					, 'Cannot delete contract. The Contract information has been used in Counterparty Invoice.'
					, ''
				RETURN
			END
			ELSE
			BEGIN
				DELETE rgm 
				FROM recorder_generator_map rgm
					LEFT JOIN #temp_contract_allocation_delete d
						ON d.generator_id = rgm.generator_id
					WHERE d.generator_id IS NOT NULL

				DELETE rg 
				FROM rec_generator rg
					LEFT JOIN #temp_contract_allocation_delete d
						ON d.generator_id = rg.generator_id
					WHERE d.generator_id IS NOT NULL
			END
		COMMIT 
 		EXEC spa_ErrorHandler 0, 'ContractAllocation', 
 				'spa_counterparty_contract', 'Success', 
 				'Changes have been saved successfully.', ''
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
			ROLLBACK
			
		DECLARE @desc VARCHAR(500) = dbo.FNAHandleDBError(10166600)
			
		EXEC spa_ErrorHandler -1, 'ContractAllocation', 
 						'spa_counterparty_contract', 'DB Error', 
 						@desc, ''
			
	END CATCH
END
GO