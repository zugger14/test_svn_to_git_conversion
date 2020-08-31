IF OBJECT_ID(N'[dbo].[spa_setup_delivery_path]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_setup_delivery_path]
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Stored procedure for Delivery path

	Parameters
	@flag: Operation Flag
			'c' - copy path
			'l' - list in drop down
			'p' - List group path details.
	@commodity: Commodity id
	@path_id: Path id
	@grid_xml: Delivery path Grid XML
	@form_xml: Path Form XML
	@rate_schedule_xml: Rate schedule XML
	@fuel_loss_xml: Fuel loss XML
	@is_group_path: Flag if path is a group path or not
	@group_path_xml: Group path XML
	@single_path_id: path id in case of single path
	@mdq_grid_xml: MDQ grid XML
	@is_confirm: confirmation flag for MDQ grid validation
	@is_bookout: Flag if path is bookout or not
	@show_message: Flag whether to show success message or not.
	@path_type: Path type
*/
CREATE PROC [dbo].[spa_setup_delivery_path]
	@flag				CHAR(1),
	@commodity			VARCHAR(3) = NULL,
	@path_id			VARCHAR(500) = NULL,
	@grid_xml			NVARCHAR(MAX) = NULL,
	@form_xml			NVARCHAR(MAX) = NULL,
	@rate_schedule_xml	NVARCHAR(MAX) = NULL,
	@fuel_loss_xml		NVARCHAR(MAX) = NULL,
	@is_group_path		CHAR(1) = NULL,
	@group_path_xml		NVARCHAR(MAX) = NULL,
	@single_path_id		VARCHAR(500) = NULL,
	@mdq_grid_xml		NVARCHAR(MAX) = NULL,
	@is_confirm			BIT = 0,
	@is_bookout			BIT = 0,
	@show_message		BIT = 1,
	@path_type			INT = NULL

AS
/*
--For debugging purpose

--SET NOCOUNT ON
----exec spa_setup_delivery_path 'd','6,7,8' 
DECLARE @flag			CHAR(1) = N'i',
	@commodity			VARCHAR(3) = NULL,
	@path_id			VARCHAR(500) = NULL,
	@grid_xml			NVARCHAR(MAX) = NULL,
	@form_xml			NVARCHAR(MAX) = N'<FormXML  groupPath="n" rateSchedule="" path_id="" priority="303954" from_location="12563" label_from_location="?????" to_location="12582" label_to_location="?????????" path_name="" path_code="" mdq="0" logical_name="" isactive="y" is_backhaul="n" deal_link=""></FormXML>',
	@rate_schedule_xml	NVARCHAR(MAX) = N'<GridGroup><PSRecordset  counterparty_contract_rate_schedule_id="" counterparty_name="10318" contract_id="14530" rate_schedule_id="" rank="" ></PSRecordset> </GridGroup>',
	@fuel_loss_xml		NVARCHAR(MAX) = N'<GridGroup></GridGroup>',
	@is_group_path		CHAR(1) = NULL,
	@group_path_xml		NVARCHAR(MAX) = NULL,
	@single_path_id		NVARCHAR(500) = NULL,
	@mdq_grid_xml		NVARCHAR(MAX) = N'<GridGroup></GridGroup>',
	@is_confirm			BIT = N'0',
	@is_bookout			BIT = 0,
	@show_message		BIT = 1,
	@path_type			INT = NULL

--select   @flag='u',@form_xml='<FormXML  groupPath="n" rateSchedule="" path_id="327" priority="303954" from_location="2737" label_from_location="A" to_location="2738" label_to_location="B" path_name="aa" path_code="aa" mdq="0.00" logical_name="" isactive="y" is_backhaul="y" deal_link=""></FormXML>',@rate_schedule_xml='<GridGroup><PSRecordset  counterparty_contract_rate_schedule_id="376" counterparty_name="8886" contract_id="8223" rate_schedule_id="" rank="" ></PSRecordset> <PSRecordset  counterparty_contract_rate_schedule_id="" counterparty_name="7828" contract_id="11325" rate_schedule_id="9" rank="307508" ></PSRecordset> </GridGroup>',@fuel_loss_xml='<GridGroup></GridGroup>',@group_path_xml=NULL,@mdq_grid_xml='<GridGroup></GridGroup>',@is_confirm='1'

	select  @flag='u',@form_xml='<FormXML  groupPath="n" rateSchedule="" path_id="6" priority="303954" from_location="2670" label_from_location="Default_Location" to_location="2744" label_to_location="AECO" path_name="Default_Location-AECO-Copy of test" path_code="Default_Location-AECO-Copy of test" mdq="200000.00" logical_name="" isactive="y" is_backhaul="n" deal_link=""></FormXML>',@rate_schedule_xml='<GridGroup><PSRecordset  counterparty_contract_rate_schedule_id="2" counterparty_name="7650" contract_id="8194" rate_schedule_id="1" rank="" ></PSRecordset> </GridGroup>',@fuel_loss_xml='<GridGroup></GridGroup>',@group_path_xml=NULL,@mdq_grid_xml='<GridGroup><PSRecordset  delivery_path_mdq_id="2" path_id="6" contract="Copy of test" effective_date="1992-02-01" mdq="200000" rec_del="d" ></PSRecordset> </GridGroup>',@is_confirm='1'

--*/
SET NOCOUNT ON

DECLARE @sql NVARCHAR(MAX)
		, @err_msg VARCHAR(2000)
		, @err_at VARCHAR(100)
		, @idoc_loss INT
		, @user_name VARCHAR(100) = dbo.fnadbuser()

IF OBJECT_ID (N'tempdb..#temp_path_loss_shrinkage1') IS NOT NULL  
	DROP TABLE 	#temp_path_loss_shrinkage1

IF OBJECT_ID (N'tempdb..#temp_path_loss_shrinkage') IS NOT NULL  
	DROP TABLE 	#temp_path_loss_shrinkage


CREATE TABLE #temp_path_loss_shrinkage (
	path_loss_shrinkage_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
	loss_factor VARCHAR(200) COLLATE DATABASE_DEFAULT,
	shrinkage_curve_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
	is_receipt VARCHAR(200) COLLATE DATABASE_DEFAULT,
	effective_date VARCHAR(200) COLLATE DATABASE_DEFAULT,
	path_id VARCHAR(200) COLLATE DATABASE_DEFAULT
)
	
IF @flag = 'a'
BEGIN
	SET @sql = 'SELECT dp.path_id
						, dp.path_name
						, CASE WHEN sml_from.Location_Name = sml_from.location_id THEN sml_from.location_id ELSE sml_from.Location_id + '' - '' + sml_from.Location_Name END + '' ['' + sml_from.Location_Description + '']'' from_location
						, CASE WHEN sml_to.Location_Name = sml_to.location_id THEN sml_to.location_id ELSE sml_to.Location_id + '' - '' + sml_to.Location_Name END + '' ['' + sml_to.Location_Description + '']'' to_location
						, sc.counterparty_name
						, cg.contract_name
						, dbo.FNARemoveTrailingZero(dp.mdq) mdq
						, sdv.code [priority]
						, dp.[logical_name]
						, dp.isactive
				FROM delivery_path dp
				LEFT JOIN source_minor_location sml_from ON sml_from.source_minor_location_id = dp.from_location
				LEFT JOIN source_minor_location sml_to ON sml_to.source_minor_location_id = dp.to_location	
				LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = dp.counterParty		
				LEFT JOIN contract_group cg ON cg.contract_id = dp.CONTRACT
				LEFT JOIN static_data_value sdv ON sdv.value_id = dp.[priority] AND sdv.type_id = 31400
				WHERE 1 = 1 ' + 
				CASE WHEN @path_id IS NULL THEN '' ELSE ' AND dp.path_id = ' + @path_id END +				
				CASE WHEN @commodity IS NULL THEN '' ELSE ' AND dp.commodity = ' + @commodity END				
	EXEC(@sql)
END
ELSE IF @flag = 'l'
BEGIN
	SET @sql = 'SELECT dp.path_id, dp.path_code
				FROM delivery_path dp
				WHERE 1 = 1' + 
				CASE WHEN @is_group_path = '' THEN ' ' ELSE ' AND groupPath = ''' + @is_group_path + '''' END +				
				CASE WHEN @commodity IS NULL THEN ' ' ELSE ' AND dp.commodity = ' + @commodity END

	EXEC(@sql)
END
ELSE IF @flag IN ('i', 'u')
BEGIN	
BEGIN TRY
	BEGIN TRAN
	DECLARE @idoc INT
		, @idoc1 INT
		, @delivery_path_id INT
		, @pipeline INT
		, @contract_name NVARCHAR(100)
		, @contract_id INT
		, @new_path_name NVARCHAR(100)
		, @new_path_id INT
	
	IF @form_xml IS NOT NULL
	BEGIN
		/*-- process ON delivery_path table starts */
		IF OBJECT_ID(N'tempdb..#temp_general_form') IS NOT NULL DROP TABLE #temp_general_form
	
		EXEC sp_xml_preparedocument @idoc OUTPUT, @form_xml		
		
		SELECT path_id,
			NULLIF(path_name, '') path_name,
			ISNULL(NULLIF(path_code, ''), path_name) path_code,
			from_location,
			to_location,
			counterparty_id,
			contract_id,
			NULLIF([priority], '') [priority],
			logical_name,
			mdq mdq,
			isgrouppath,
			isactive,
			NULLIF(commodity, '') commodity,
			NULLIF(delivery_means, '') delivery_means,
			path_type,
			is_backhaul
		INTO #temp_general_form
		FROM   OPENXML(@idoc, '/FormXML', 1)
		WITH (
			path_id INT '@path_id',
			path_name NVARCHAR(100) '@path_name',
			path_code NVARCHAR(100) '@path_code',
			from_location INT '@from_location',
			to_location INT '@to_location',
			counterparty_id INT '@counterParty',
			contract_id INT '@CONTRACT',
			[priority] INT '@priority',
			logical_name NVARCHAR(100) '@logical_name',
			mdq FLOAT '@mdq',
			isgrouppath CHAR(1) '@groupPath',
			isactive CHAR(1) '@isactive',
			commodity INT '@commodity',
			delivery_means INT '@delivery_means',
			path_type INT '@path_type',
			is_backhaul CHAR(1) '@is_backhaul'
		)
		
		EXEC sp_xml_preparedocument @idoc1 OUTPUT, @rate_schedule_xml
		
		IF OBJECT_ID (N'tempdb..#temp_rate_schedule_grid') IS NOT NULL  
			DROP TABLE 	#temp_rate_schedule_grid

		SELECT NULLIF(counterparty_contract_rate_schedule_id, '') counterparty_contract_rate_schedule_id,
			counterparty_name,
			contract_id,
			NULLIF(rate_schedule_id, '') rate_schedule_id,
			
			NULLIF(rank, '') rank,
			NULLIF(effective_date, '') effective_date
		INTO #temp_rate_schedule_grid
		
		FROM   OPENXML(@idoc1, '/GridGroup/PSRecordset', 2)
				WITH (
					counterparty_contract_rate_schedule_id INT '@counterparty_contract_rate_schedule_id',
					counterparty_name NVARCHAR(1000) '@counterparty_name',
					contract_id VARCHAR(100) '@contract_id',
					rate_schedule_id INT '@rate_schedule_id',
					rank INT '@rank',
					effective_date VARCHAR(100) '@effective_date'
				)
		
		IF @mdq_grid_xml IS NOT NULL
		BEGIN
			EXEC sp_xml_preparedocument @idoc1 OUTPUT, @mdq_grid_xml
			
			IF OBJECT_ID (N'tempdb..#temp_mdq_grid') IS NOT NULL  
				DROP TABLE 	#temp_mdq_grid

			SELECT NULLIF(delivery_path_mdq_id, '') delivery_path_mdq_id,
				effective_date,
				contract_id,
				mdq,
				rec_del
			INTO #temp_mdq_grid
			FROM   OPENXML(@idoc1, '/GridGroup/PSRecordset', 2)
			WITH (
				delivery_path_mdq_id INT '@delivery_path_mdq_id',
				effective_date DATETIME '@effective_date',
						contract_id VARCHAR(100) '@contract_id',
				mdq VARCHAR(100) '@mdq',
				rec_del CHAR(1) '@rec_del'
			)
		END

		--VALIDATION FOR SEGMENTED AND NON SEGMENTED CONTRACT MDQ
		DECLARE @current_contract INT
				, @current_pmdq FLOAT
				, @current_gmdq FLOAT
				, @current_path INT
		
		SELECT @current_contract = mcid.contract_id
			, @current_pmdq = tgf.mdq
			, @current_path = tgf.path_id
			, @pipeline = mcid1.counterparty_id
		FROM #temp_general_form tgf
		OUTER APPLY(SELECT MAX(contract_id) AS contract_id FROM #temp_rate_schedule_grid) mcid
		OUTER APPLY(SELECT MAX(counterparty_name) AS counterparty_id  FROM #temp_rate_schedule_grid) mcid1

		SET @contract_id = @current_contract
	
		IF @mdq_grid_xml IS NOT NULL
		BEGIN
			SELECT @current_gmdq = tmg.mdq 
			FROM #temp_mdq_grid tmg 
			WHERE tmg.effective_date = (SELECT MAX(effective_date) FROM #temp_mdq_grid)
		END
		ELSE 
		BEGIN
			SET @current_gmdq = NULL
		END

		SET @current_pmdq = ISNULL(@current_gmdq, @current_pmdq)
		
		DECLARE @available_mdq FLOAT
				, @insert_mdq FLOAT
				, @update_mdq FLOAT
				, @is_segmented_contract BIT = 0

		SELECT @is_segmented_contract = CASE cg.segmentation WHEN 'y' THEN 1 ELSE 0 END
		FROM contract_group cg
		WHERE cg.contract_id = @current_contract

		SELECT @available_mdq = COALESCE(tcm.mdq , cg.mdq, '0')
		FROM contract_group cg
		LEFT JOIN transportation_contract_mdq tcm 
			ON tcm.contract_id = cg.contract_id 
			AND tcm.effective_date = (
											SELECT MAX(effective_date) 
											FROM transportation_contract_mdq 
											WHERE contract_id = @current_contract				
										)
		WHERE cg.contract_id = @current_contract

		SELECT @insert_mdq = CAST(SUM(COALESCE(dpm.mdq, dp.mdq, '0')) AS FLOAT) + CAST(@current_pmdq AS FLOAT) 
		FROM delivery_path dp
		LEFT JOIN delivery_path_mdq  dpm 
			ON dpm.path_id = dp.path_id 
			AND effective_date = (
				SELECT MAX(effective_date) 
				FROM delivery_path_mdq 
				WHERE contract_id = @current_contract 
					AND dp.path_id = path_id
			)
		WHERE contract_id = @current_contract

		SELECT @update_mdq = CAST(SUM(COALESCE(dpm.mdq, dp.mdq, '0')) AS FLOAT) + CAST(@current_pmdq AS FLOAT) 
		FROM delivery_path dp
		LEFT JOIN delivery_path_mdq dpm 
			ON dpm.path_id = dp.path_id 
			AND dpm.effective_date = (
											SELECT MAX(effective_date) 
											FROM delivery_path_mdq 
											WHERE contract_id = @current_contract AND dp.path_id = path_id
										)
		WHERE dp.contract = @current_contract 
			AND dp.path_id <> @current_path

		IF @is_segmented_contract = 1
		BEGIN
			SET @insert_mdq = @current_pmdq
			SET @update_mdq = @current_pmdq
		END

		IF(@is_confirm = 0)
		BEGIN
			IF (CASE WHEN @flag = 'i' THEN @insert_mdq ELSE @update_mdq END > @available_mdq)
			BEGIN
				DECLARE @exceed_err_msg VARCHAR(2000)

				IF @is_segmented_contract = 1
					SET @exceed_err_msg = 'Path MDQ exceeds contract MDQ.'
				ELSE
					SET @exceed_err_msg = 'Total MDQ level assigned exceeds the available MDQ for the selected contract.'
				
				SET @err_at = 'form'

				RAISERROR (@exceed_err_msg, -- Message text.
								12, -- Severity,
								1, -- State
								@err_at
					);
			END
		END
		--VALIDATION FOR SEGMENTED AND NON SEGMENTED CONTRACT MDQ		


		--if path name of single path is null then update path name with Receipt Location id, Delivery Location id and Contract (i.e. as Receipt Loc ID-Deliver Loc ID – Contract Name). 
		
		--SELECT * FROM #temp_general_form
		
 		IF @contract_id IS NOT NULL
		BEGIN
		UPDATE tmp
			SET tmp.path_name = sml_from.location_id + '-' + sml_to.location_id + '-' + cg.contract_name 
				, tmp.path_code = sml_from.location_id + '-' + sml_to.location_id + '-' + cg.contract_name 
		FROM #temp_general_form tmp
			LEFT JOIN source_minor_location sml_from ON sml_from.source_minor_location_id = tmp.from_location
			LEFT JOIN source_minor_location sml_to ON sml_to.source_minor_location_id = tmp.to_location
			LEFT JOIN contract_group cg  ON cg.contract_id = @contract_id --tmp.contract_id
			WHERE tmp.path_name IS NULL AND tmp.isgrouppath = 'n'
		END
		ELSE
		BEGIN
			UPDATE tmp
			SET tmp.path_name = sml_from.location_id + '-' + sml_to.location_id + (CASE WHEN tmp.delivery_means IS NOT NULL AND tmp.delivery_means <> 0 THEN '-' + sdv.code ELSE '' END)
				, tmp.path_code = sml_from.location_id + '-' + sml_to.location_id + (CASE WHEN tmp.delivery_means IS NOT NULL AND tmp.delivery_means <> 0 THEN '-' + sdv.code ELSE '' END)
			FROM #temp_general_form tmp
			LEFT JOIN source_minor_location sml_from ON sml_from.source_minor_location_id = tmp.from_location
			LEFT JOIN source_minor_location sml_to ON sml_to.source_minor_location_id = tmp.to_location
			--LEFT JOIN contract_group cg  ON cg.contract_id = tmp.contract_id
			LEFT JOIN static_data_value sdv ON sdv.value_id = tmp.delivery_means
			WHERE tmp.path_name IS NULL AND tmp.isgrouppath = 'n'
		END
		
		 
		--SELECT * FROM #temp_general_form

		IF EXISTS(SELECT 1 FROM #temp_general_form WHERE path_name IS NULL)
		BEGIN		
			SET @err_at = 'form'			
			
			RAISERROR (N'Path Name is required field.', -- Message text.
							12, -- Severity,
							1, -- State
							@err_at
				);				
			
		END

		IF @flag = 'i'
		BEGIN
			IF EXISTS(SELECT 1 FROM dbo.delivery_path dp INNER JOIN #temp_general_form tdp ON tdp.path_name = dp.path_name)
			BEGIN				
				SET @err_at = 'Rate Schedule'			
				RAISERROR (N'Duplicate Name in (Path Name).', -- Message text.
								12, -- Severity,
								1, -- State
								@err_at
					);	
			END
			
			IF EXISTS (
				SELECT 1 FROM #temp_general_form tgf
				LEFT JOIN source_minor_location smlf
					ON smlf.source_minor_location_id = tgf.from_location
				LEFT JOIN source_minor_location smlt
					ON smlt.source_minor_location_id = tgf.to_location
				WHERE smlf.region = smlt.region
			) BEGIN
				EXEC spa_ErrorHandler -1,
				'Setup Delivery Path.',
				'spa_setup_delivery_path',
				'Error',
				N'Both receipt and delivery location have the same region.',
				NULL
				RETURN
			END
			
			IF @is_bookout = 0
			BEGIN			
				INSERT INTO delivery_path(
					path_name
					, path_code
					, from_location
					, to_location
					, counterParty
					, [CONTRACT]
					, [priority]
					, logical_name
					, mdq
					, groupPath
					, isactive 
					, commodity
					, delivery_means
					, is_backhaul

				)
				SELECT path_name
					, path_code	
					, from_location	
					, to_location	
					, @pipeline
					, @current_contract	
					, [priority]	
					, logical_name	
					, mdq
					, isgrouppath	
					, isactive
					, commodity
					, delivery_means
					, is_backhaul
				FROM #temp_general_form
				SET @new_path_id = SCOPE_IDENTITY()
			END
			ELSE 
			BEGIN
				--removed negative path logic since, db level permission issue for identity_insert
				--ADD DELIVERY PATH WITH SAME FROM AND TO LOCATION NEEDED FOR BOOKOUT LOGIC
				--DECLARE @neg_path_id INT

				--SET IDENTITY_INSERT delivery_path ON

				--SELECT @neg_path_id = ISNULL(MIN(path_id), 0) - 1
				--FROM delivery_path 
				--WHERE path_id < 0
				
				INSERT INTO delivery_path(
					--path_id
					path_name
					, path_code
					, from_location
					, to_location
					, counterParty
					, [CONTRACT]
					, [priority]
					, logical_name
					, mdq
					, groupPath
					, isactive 
					, commodity
					, is_backhaul
				)
				SELECT 
					--@neg_path_id
					path_name
					, path_code	
					, from_location	
					, to_location	
					, counterparty_id	
					, contract_id
					, [priority]	
					, logical_name	
					, mdq
					, isgrouppath	
					, isactive
					, commodity
					, is_backhaul
				FROM #temp_general_form
			
				--SET IDENTITY_INSERT delivery_path OFF
				SET @new_path_id = SCOPE_IDENTITY()
			END
			 
			SELECT @delivery_path_id = path_id
				, @new_path_name = path_name
				--, @pipeline = counterparty
				--, @contract_id = [contract]
			FROM delivery_path 
			WHERE path_id = @new_path_id
		END
		ELSE 
		BEGIN
			IF EXISTS(	SELECT 1 
						FROM dbo.delivery_path dp
						INNER JOIN #temp_general_form tdp 
							ON tdp.path_name = dp.path_name 
							AND dp.path_id <> tdp.path_id
						)
			BEGIN
				SET @err_at = 'form'			
				RAISERROR (N'Duplicate Name in (Path Name).', -- Message text.
								12, -- Severity,
								1, -- State
								@err_at
					);	
			END

			IF EXISTS (
				SELECT 1 FROM #temp_general_form tgf
				LEFT JOIN source_minor_location smlf
					ON smlf.source_minor_location_id = tgf.from_location
				LEFT JOIN source_minor_location smlt
					ON smlt.source_minor_location_id = tgf.to_location
				WHERE smlf.region = smlt.region
			) BEGIN
				EXEC spa_ErrorHandler -1,
				'Setup Delivery Path.',
				'spa_setup_delivery_path',
				'Error',
				N'Both receipt and delivery location have the same region.',
				NULL
				RETURN
			END

			UPDATE dp
			SET path_name = tdp.path_name
				, path_code = tdp.path_code
				, from_location = tdp.from_location
				, to_location = tdp.to_location
				, counterParty = isnull(@pipeline,tdp.counterparty_id)
				, [contract] = isnull(@current_contract,tdp.contract_id)
				, [priority] = tdp.[priority]
				, logical_name = tdp.logical_name
				, mdq = tdp.mdq
				, groupPath = tdp.isgrouppath
				, isactive  = tdp.isactive
				, commodity = tdp.commodity
				, delivery_means = tdp.delivery_means
				, is_backhaul = tdp.is_backhaul
			FROM delivery_path dp
			INNER JOIN #temp_general_form tdp 
				ON tdp.path_id = dp.path_id
			
			SELECT @delivery_path_id = dp.path_id
				, @new_path_name = dp.path_name
				--, @pipeline = dp.counterParty 
				--, @contract_id = [contract]
			FROM delivery_path dp
			INNER JOIN #temp_general_form tdp 
				ON tdp.path_id = dp.path_id
			
		END
		/*-- process ON delivery_path table ends */
	END
	
	IF @rate_schedule_xml IS NOT NULL
	BEGIN
		/*-- process ON counterparty_contract_rate_schedule table starts */

		--EXEC sp_xml_preparedocument @idoc1 OUTPUT, @rate_schedule_xml
		
		--IF OBJECT_ID (N'tempdb..#temp_rate_schedule_grid') IS NOT NULL  
		--	DROP TABLE 	#temp_rate_schedule_grid

		--SELECT NULLIF(counterparty_contract_rate_schedule_id, '') counterparty_contract_rate_schedule_id,
		--	counterparty_name,
		--	contract_id,
		--	NULLIF(rate_schedule_id, '') rate_schedule_id,
		--	CASE WHEN [rank] = '' THEN NULL ELSE [rank] END rank
		--INTO #temp_rate_schedule_grid
		--FROM   OPENXML(@idoc1, '/GridGroup/PSRecordset', 2)
		--WITH (
		--	counterparty_contract_rate_schedule_id INT '@counterparty_contract_rate_schedule_id',
		--	counterparty_name VARCHAR(100) '@counterparty_name',
		--	contract_id VARCHAR(100) '@contract_id',
		--	rate_schedule_id INT '@rate_schedule_id',
		--	rank INT '@rank'
		--)
		---Remove FROM counterparty_contract_rate_schedule
		DELETE ccrs
		FROM counterparty_contract_rate_schedule ccrs
		LEFT JOIN #temp_rate_schedule_grid trs 
			ON trs.counterparty_contract_rate_schedule_id = ccrs.counterparty_contract_rate_schedule_id
		WHERE ccrs.path_id = @delivery_path_id
			AND trs.counterparty_contract_rate_schedule_id IS NULL
			
		--Update
		IF EXISTS(SELECT 1 FROM #temp_rate_schedule_grid GROUP BY counterparty_name,contract_id HAVING COUNT(counterparty_name) > 1)
		BEGIN		
			SET @err_at = 'Rate Schedule'			
			RAISERROR (N'Duplicate data(Pipeline AND Contract) in Rate Schedule grid.', -- Message text.
							12, -- Severity,
							1, -- State
							@err_at
				);
		END
		ELSE
		BEGIN
			UPDATE ccrs
				SET counterparty_id = ISNULL(@pipeline, trs.counterparty_name),
				contract_id = trs.contract_id,
				rate_schedule_id = ISNULL(trs.rate_schedule_id, cg.maintain_rate_schedule),
					rank = trs.rank ,
					effective_date = trs.effective_date 
			FROM counterparty_contract_rate_schedule ccrs
				INNER JOIN #temp_rate_schedule_grid trs ON trs.counterparty_contract_rate_schedule_id = ccrs.counterparty_contract_rate_schedule_id
				LEFT JOIN contract_group cg ON cg.contract_id = trs.contract_id AND cg.pipeline = ISNULL(@pipeline, trs.counterparty_name)

			--insert
			INSERT INTO counterparty_contract_rate_schedule (
				counterparty_id,
				contract_id,
				rate_schedule_id,
				path_id,
				[RANK],
				effective_date
			)
				SELECT ISNULL(@pipeline, trs.counterparty_name),
					contract_id,
				rate_schedule_id,
				@delivery_path_id,
					[rank],
					effective_date
			FROM #temp_rate_schedule_grid trs	  
			WHERE trs.counterparty_contract_rate_schedule_id IS NULL
		END

			--Add rate schedule detail from contract group if rate schedule for selected contract is not found.
		IF NOT EXISTS(SELECT 1 FROM #temp_rate_schedule_grid WHERE contract_id = @contract_id)
		BEGIN
			--insert default values
			INSERT INTO counterparty_contract_rate_schedule (
				counterparty_id,
				contract_id,
				rate_schedule_id,
				path_id

			) 
			SELECT pipeline,contract_id,maintain_rate_schedule,@delivery_path_id 
			FROM contract_group 
			WHERE contract_id = @contract_id			
				AND pipeline IS NOT NULL
		END	
	END	
/*-- process ON counterparty_contract_rate_schedule table ends */
	
	IF @fuel_loss_xml IS NOT NULL
	BEGIN
		--Collect data
		EXEC sp_xml_preparedocument @idoc_loss OUTPUT, @fuel_loss_xml
		

		SELECT NULLIF(path_loss_shrinkage_id, '') path_loss_shrinkage_id,
			NULLIF(loss_factor, '') loss_factor,
			NULLIF(shrinkage_curve_id, '') shrinkage_curve_id,
			is_receipt,
			effective_date,
			CASE WHEN contract_id = '' THEN NULL ELSE contract_id END contract_id
		INTO #temp_path_loss_shrinkage1
		FROM   OPENXML(@idoc_loss, '/GridGroup/PSRecordset', 1)
				WITH (
					path_loss_shrinkage_id INT '@path_loss_shrinkage_id',
					loss_factor VARCHAR(100) '@loss_factor',
					shrinkage_curve_id INT '@shrinkage_curve_id',
					is_receipt CHAR(1) '@is_receipt',
					effective_date DATETIME '@effective_date',
					contract_id INT '@contract_id'
				)
		IF NOT EXISTS(SELECT 1 FROM #temp_path_loss_shrinkage1)
		BEGIN
			DELETE FROM path_loss_shrinkage
			WHERE path_id = @delivery_path_id
		END
		ELSE
		BEGIN
			MERGE path_loss_shrinkage AS T
			USING #temp_path_loss_shrinkage1 AS S
			ON (
					T.path_id = @delivery_path_id 
					AND T.effective_date = S.effective_date 
					AND  T.is_receipt = S.is_receipt
				) 
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(path_id, loss_factor, shrinkage_curve_id, is_receipt, effective_date, contract_id) 
				VALUES(@delivery_path_id, S.loss_factor, S.shrinkage_curve_id, S.is_receipt, S.effective_date, S.contract_id)
			WHEN MATCHED THEN 
			UPDATE SET T.loss_factor = S.loss_factor
				, T.shrinkage_curve_id = S.shrinkage_curve_id
				, T.is_receipt = S.is_receipt
				, T.effective_date = S.effective_date
				, T.contract_id = S.contract_id
			WHEN NOT MATCHED BY SOURCE AND T.path_id = @delivery_path_id THEN 
			DELETE;
		END
	END
	
	/*-- process ON path_loss_shrinkage table ends */
	
	IF @mdq_grid_xml IS NOT NULL
	BEGIN
		---Remove FROM delivery_path_mdq
		DELETE dpm
		FROM delivery_path_mdq dpm
		LEFT JOIN #temp_mdq_grid mdq 
			ON mdq.delivery_path_mdq_id = dpm.delivery_path_mdq_id
		WHERE dpm.path_id = @delivery_path_id
			AND mdq.delivery_path_mdq_id IS NULL

		UPDATE dpm
		SET 
			contract_id = @contract_id,
			effective_date = mdq.effective_date,
			mdq = mdq.mdq,
			rec_del = mdq.rec_del 
		FROM delivery_path_mdq dpm
		INNER JOIN #temp_mdq_grid mdq 
			ON mdq.delivery_path_mdq_id = dpm.delivery_path_mdq_id

		INSERT INTO delivery_path_mdq (
			path_id,
			contract_id,
			effective_date,
			mdq,
			rec_del
		)
		SELECT 
			@delivery_path_id,
			@contract_id,
			mdq.effective_date,
			mdq.mdq,
			mdq.rec_del 
		FROM #temp_mdq_grid mdq	  
		WHERE mdq.delivery_path_mdq_id IS NULL
	END

	IF @fuel_loss_xml IS NOT NULL
	BEGIN
		--Collect data
		EXEC sp_xml_preparedocument @idoc_loss OUTPUT, @fuel_loss_xml
		
		INSERT INTO #temp_path_loss_shrinkage (path_loss_shrinkage_id, loss_factor, shrinkage_curve_id, is_receipt, effective_date)
		SELECT NULLIF(path_loss_shrinkage_id, '') path_loss_shrinkage_id,
			NULLIF(loss_factor, '') loss_factor,
			NULLIF(shrinkage_curve_id, '') shrinkage_curve_id,
			is_receipt,
			effective_date		
		FROM   OPENXML(@idoc_loss, '/GridGroup/PSRecordset', 1)
		WITH (
			path_loss_shrinkage_id INT '@path_loss_shrinkage_id',
			loss_factor VARCHAR(100) '@loss_factor',
			shrinkage_curve_id INT '@shrinkage_curve_id',
			is_receipt CHAR(1) '@is_receipt',
			effective_date DATETIME '@effective_date'
		)

		IF NOT EXISTS(SELECT 1 FROM #temp_path_loss_shrinkage)
		BEGIN
			DELETE FROM path_loss_shrinkage
			WHERE path_id = @delivery_path_id
		END
		ELSE
		BEGIN
			MERGE path_loss_shrinkage AS T
			USING #temp_path_loss_shrinkage AS S
			ON (T.path_id = @delivery_path_id 
				AND T.effective_date = S.effective_date 
				AND  T.is_receipt = S.is_receipt
				) 
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(path_id, loss_factor, shrinkage_curve_id, is_receipt, effective_date) 
				VALUES(@delivery_path_id, S.loss_factor, S.shrinkage_curve_id, S.is_receipt, S.effective_date)
			WHEN MATCHED THEN 
			UPDATE SET T.loss_factor = S.loss_factor
				, T.shrinkage_curve_id = S.shrinkage_curve_id
				, T.is_receipt = S.is_receipt
				, T.effective_date = S.effective_date
			WHEN NOT MATCHED BY SOURCE AND T.path_id= @delivery_path_id THEN 
			DELETE;
		END
	END
	/*-- process ON path_loss_shrinkage table ends */
	
	IF @mdq_grid_xml IS NOT NULL
	BEGIN
		---Remove FROM delivery_path_mdq
		DELETE dpm
		FROM delivery_path_mdq dpm
		LEFT JOIN #temp_mdq_grid mdq 
			ON mdq.delivery_path_mdq_id = dpm.delivery_path_mdq_id
		WHERE dpm.path_id = @delivery_path_id
			AND mdq.delivery_path_mdq_id IS NULL

		UPDATE dpm
		SET 
			contract_id = @contract_id,
			effective_date = mdq.effective_date,
			mdq = mdq.mdq,
			rec_del = mdq.rec_del 
		FROM delivery_path_mdq dpm
		INNER JOIN #temp_mdq_grid mdq 
			ON mdq.delivery_path_mdq_id = dpm.delivery_path_mdq_id

		--insert
		INSERT INTO delivery_path_mdq (
			path_id,
			contract_id,
			effective_date,
			mdq,
			rec_del
		)
		SELECT 
			@delivery_path_id,
			@contract_id,
			mdq.effective_date,
			mdq.mdq,
			mdq.rec_del 
		FROM #temp_mdq_grid mdq	  
		WHERE mdq.delivery_path_mdq_id IS NULL
		

		/*******Create Deal FROM MDQ Grid data*********/
		IF @fuel_loss_xml IS NOT NULL
		BEGIN			 
			UPDATE #temp_path_loss_shrinkage SET path_id = @delivery_path_id
		END


		IF OBJECT_ID('tempdb..#temp_table') IS NOT NULL
			DROP TABLE #temp_table 
		
		CREATE TABLE #temp_table (														
						  [path_id]						INT						
						, [deal_date]					DATETIME
						, [counterparty_id]				INT
						, [deal_type_id]				VARCHAR(30) COLLATE DATABASE_DEFAULT				
						, [header_buy_sell_flag]		CHAR(1) COLLATE DATABASE_DEFAULT
						, [physical_financial_flag]		CHAR(1) COLLATE DATABASE_DEFAULT						
						, [trader_id]					INT
						, [contract_id]					INT					
						, [sub_book]					VARCHAR(30) COLLATE DATABASE_DEFAULT
						, [term_start]					DATETIME
						, [term_end]					DATETIME
						, [leg]							INT
						, [deal_volume]					NUMERIC(38,20)
						, [deal_volume_frequency]		CHAR(1) COLLATE DATABASE_DEFAULT
						, [template_name]				VARCHAR(50) COLLATE DATABASE_DEFAULT
						, [commodity_id]				INT
						, [deal_status]					INT
						, [subbook]						VARCHAR(50) COLLATE DATABASE_DEFAULT
						, [contract_expiration_date]	DATETIME
						, [fixed_float_leg]				CHAR(1) COLLATE DATABASE_DEFAULT
						, [buy_sell_flag]				CHAR(1) COLLATE DATABASE_DEFAULT
						, [location_id]					VARCHAR(50) COLLATE DATABASE_DEFAULT
						, [fixed_price]					NUMERIC(38,20)
						, [deal_category_value_id] 		INT						
						, [position_uom]				INT
						, [from_location]				INT
						, [to_location ]				INT
						, [deal_volume_uom_id]			INT
						, [curve_id]					INT
						, [term_frequency]				CHAR(1) COLLATE DATABASE_DEFAULT
		
		)


		DECLARE @mdq_sql VARCHAR(MAX)

		SET @mdq_sql = 'INSERT INTO #temp_table						
						SELECT tgf.path_id									
								, cg.flow_start_date			[deal_date] --effective date FROM mdq grid
								, tgf.counterparty_id			[counterparty_id] 
								, sdt.deal_type_id				[deal_type_id]								
								, sdht.header_buy_sell_flag		[header_buy_sell_flag] 
								, sdht.physical_financial_flag	[physical_financial_flag] 								
								, sdht.trader_id
								, tgf.contract_id								
								, a.clm2_value					sub_book			
								, DATEADD(MONTH, DATEDIFF(MONTH, 0, cg.flow_start_date), 0)			[term_start] --effective date FROM mdq grid
								, DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, cg.flow_end_date) + 1, 0)) 	[term_end]  -- BOM
								, sddt.leg						[leg]
							'
		IF CAST(@fuel_loss_xml  AS VARCHAR(MAX)) <> '<GridGroup></GridGroup>'						
			SET @mdq_sql += ', CASE WHEN sddt.leg = 1 AND CONVERT(DECIMAL(8,4), ISNULL(tpls.loss_factor,0)) <> 0 THEN ROUND(tmg.mdq /(1 - (CONVERT(DECIMAL(8,4),ISNULL(tpls.loss_factor,0)))/100),0) ELSE tmg.mdq END [deal_volume] --volume FROM mdq grid'
		ELSE
			SET @mdq_sql += ', tmg.mdq [deal_volume]'

		SET @mdq_sql += '        
								, sddt.deal_volume_frequency	[deal_volume_frequency]								
								, sdht.template_name			[template_name] 
								, sdht.commodity_id				[commodity_id] 
								, sdht.deal_status				[deal_status]
								, ssbm.logical_name				[subbook]
								, cg.flow_end_date				[contract_expiration_date] --BOM date
								, sddt.fixed_float_leg			[fixed_float_leg]
								, sddt.buy_sell_flag			[buy_sell_flag] 
								, sml.location_name				[location_id]
								, sddt.fixed_price				[fixed_price]
								, 475							[deal_category_value_id] --475 for ''real'' static data 								
								, sddt.position_uom				[position_uom]
								, tgf.from_location				[from_location]
								, tgf.to_location				[to_location ]
								, sddt.deal_volume_uom_id		[deal_volume_uom_id]
								, sddt.curve_id					[curve_id]
								, sdht.term_frequency_type			[term_frequency]
						FROM source_deal_header_template sdht
						INNER JOIN source_deal_detail_template sddt
							ON sdht.template_id = sddt.template_id
						INNER JOIN source_deal_type sdt 
							ON sdt.source_deal_type_id = sdht.source_deal_type_id						
						INNER JOIN source_uom su
							ON su.source_uom_id  = sddt.deal_volume_uom_id
						CROSS JOIN #temp_general_form tgf
						LEFT JOIN (	
								SELECT gmv.* FROM generic_mapping_header gmh
								left JOIN generic_mapping_values gmv
								ON gmh.mapping_table_id = gmv.mapping_table_id
								WHERE gmh.mapping_name = ''Flow Optimization Mapping''
						) a 
							ON a.clm1_value = CAST(tgf.counterparty_id AS VARCHAR(20))
						LEFT JOIN source_system_book_map ssbm
							ON ssbm.book_deal_type_map_id = a.clm2_value						
						INNER JOIN contract_group cg
							ON cg.contract_id = tgf.contract_id
						--INNER JOIN #temp_mdq_grid tmg
						--	ON tmg.contract_id = cg.contract_name
						CROSS APPLY (
							SELECT top 1 tmg1.*
							FROM #temp_mdq_grid tmg1
							WHERE tmg1.contract_id = cg.contract_name
								AND tmg1.effective_date <= dbo.FNAGetFirstLastDayOfMonth(cg.flow_end_date, ''l'')
							ORDER BY tmg1.effective_date ASC
						) tmg
						LEFT JOIN source_minor_location sml
							ON sml.source_minor_location_id = CASE WHEN sddt.leg = 1 
																		THEN tgf.from_location 
																   ELSE tgf.to_location 
															  END
						'
		IF @fuel_loss_xml IS NOT NULL					
			SET @mdq_sql += ' LEFT JOIN (SELECT TOP 1 * FROM #temp_path_loss_shrinkage ORDER BY effective_date DESC) tpls
								ON tpls.path_id = tgf.path_id '
		
		SET @mdq_sql += ' WHERE sdht.template_name = ''Capacity NG'''
		
		EXEC(@mdq_sql)	

		
		IF EXISTS(SELECT 1 FROM #temp_table WHERE [deal_date] IS NOT NULL)
		BEGIN 
			IF NOT EXISTS ( SELECT 1 FROM user_defined_deal_fields uddf
						INNER JOIN user_defined_deal_fields_template_main uddft
							ON uddf.udf_template_id = uddft.udf_template_id
						INNER JOIN user_defined_fields_template udft
							ON uddft.field_id = udft.field_id
						INNER JOIN source_deal_header_template sdht
							ON sdht.template_id = uddft.template_id	
						WHERE udft.field_label = 'Delivery Path'  							
							AND sdht.template_name = 'Capacity NG' 
							AND udf_value = CAST(@delivery_path_id AS VARCHAR(5))
			) --INSERT DEAL
			BEGIN 

				DECLARE @header_dxml VARCHAR(MAX),
						@detail_dxml VARCHAR(MAX)
		 
				SELECT DISTINCT @header_dxml =
								 '<GridXML>
										<GridRow  
											row_id="1"			
											deal_id = ""	
											deal_date = "' + CAST(deal_date AS VARCHAR(50)) + '"	
											counterparty_id	= "' + CAST(counterparty_id AS VARCHAR(10)) + '"
											deal_type_id= "' + CAST(deal_type_id AS VARCHAR(10)) + '"	
											header_buy_sell_flag= "' + CAST(header_buy_sell_flag AS VARCHAR(10)) + '"	
											physical_financial_flag	= "' + CAST(physical_financial_flag AS VARCHAR(10)) + '"
											trader_id	= "' + CAST(trader_id AS VARCHAR(10)) + '"
											contract_id	= "' + CAST(contract_id AS VARCHAR(10)) + '"
											sub_book= "' + CAST(sub_book AS VARCHAR(10)) + '"'

				--select deal_date,counterparty_id ,deal_type_id,header_buy_sell_flag,physical_financial_flag,trader_id,contract_id,sub_book 
				FROM #temp_table



				
				SELECT
					@header_dxml += ' UDF___' + CAST(sub.udf_template_id AS VARCHAR(10)) + ' = "'+ CASE field_label WHEN 'Delivery Path' THEN CAST(path_id AS VARCHAR(10)) ELSE '' END +'"' 
				FROM (
					SELECT DISTINCT udft.udf_template_id
						, udft.field_label
						, CASE WHEN path_id = 0 THEN @delivery_path_id ELSE path_id END path_id
					FROM #temp_table tt
					INNER JOIN source_deal_header_template sdht
						ON tt.template_name = sdht.template_name 
					INNER JOIN user_defined_deal_fields_template_main  uddft
						ON uddft.template_id = sdht.template_id
					INNER JOIN  user_defined_fields_template udft
						ON udft.field_name = uddft.field_name 
					WHERE udft.udf_type= 'h'
				) sub

				SET @header_dxml += '></GridRow></GridXML>'


				SELECT  @detail_dxml = 
					'<GridXML>
						<GridRow
							deal_group="New Group" 
							group_id="1" 
							detail_flag="0"  
							row_id="1" 
							blotterleg="1" 
							term_start= "' + CAST(term_start AS VARCHAR(50)) + '"
							term_end= "' + CAST(term_start AS VARCHAR(50)) + '"
							fixed_float_leg= "' + CAST(fixed_float_leg AS VARCHAR(50)) + '"
							location_id= "' + CAST(from_location AS VARCHAR(50)) + '"
							curve_id= "' + CAST(curve_id AS VARCHAR(50)) + '"			
							deal_volume= "' + CAST(deal_volume AS VARCHAR(50)) + '"
							deal_volume_uom_id = "' + CAST(deal_volume_uom_id AS VARCHAR(50)) + '"
							deal_volume_frequency = "' + CAST(deal_volume_frequency AS VARCHAR(50)) + '"
							total_volume="" 
							fixed_price="" 
						>
						</GridRow>	'			
				FROM #temp_table 
				WHERE leg = 1
				
				SELECT @detail_dxml += 
					'
						<GridRow
							deal_group="New Group1" 
							group_id="2" 
							detail_flag="0"  
							row_id="1" 
							blotterleg="2" 
							term_start= "' + CAST(term_start AS VARCHAR(50)) + '"
							term_end= "' + CAST(term_start AS VARCHAR(50)) + '"
							fixed_float_leg= "' + CAST(fixed_float_leg AS VARCHAR(50)) + '"
							location_id= "' + CAST(to_location AS VARCHAR(50)) + '"
							curve_id= "' + CAST(curve_id AS VARCHAR(50)) + '"			
							deal_volume= "' + CAST(deal_volume AS VARCHAR(50)) + '"
							deal_volume_uom_id = "' + CAST(deal_volume_uom_id AS VARCHAR(50)) + '"
							deal_volume_frequency = "' + CAST(deal_volume_frequency AS VARCHAR(50)) + '"
							total_volume="" 
							fixed_price="" 
						>
						</GridRow>
					</GridXML>'			
				FROM #temp_table 
				WHERE leg = 2
		
				DECLARE @process_id  VARCHAR(50) , @template_id INT, @term_frequency CHAR(1)
		
				SET @process_id= REPLACE(NEWID(), '-', '_')	
				SELECT @template_id = template_id
					, @term_frequency = term_frequency_type  
				FROM source_deal_header_template 
				WHERE template_name = 'Capacity NG'
				


				EXEC spa_insert_blotter_deal  
									@flag='i',
									@process_id = @process_id,
									@header_xml = @header_dxml,
									@detail_xml = @detail_dxml,
									@template_id = @template_id, 
									@term_frequency = @term_frequency
									,@call_from_delivery_path='y'
				
				
				/** UPDATE DEAL TO MATCH TERM LEVEL MDQ AND FUEL LOSS DEFINED START **/
				DECLARE @deal_id_mdq_update INT
				DECLARE @capacity_deal_table VARCHAR(300) = dbo.FNAProcessTableName('capacity_deal_table', @user_name, @process_id)

				IF OBJECT_ID (N'tempdb..##tmp_capacity_deal') IS NOT NULL  DROP TABLE 	##tmp_capacity_deal
				exec('SELECT source_deal_header_id INTO ##tmp_capacity_deal FROM ' + @capacity_deal_table)
				SELECT @deal_id_mdq_update = source_deal_header_id FROM ##tmp_capacity_deal

				--exec('SELECT * FROM source_deal_detail WHERE source_deal_header_id=' + @deal_id_mdq_update)

				IF OBJECT_ID (N'tempdb..##tmp_capacity_deal') IS NOT NULL  DROP TABLE 	##tmp_capacity_deal


				DECLARE @min_term DATETIME, @max_term DATETIME, @term_frequency_mdq_update CHAR(1)

				SELECT @min_term = MIN(sdd.term_start), @max_term = MAX(sdd.term_end), @term_frequency_mdq_update = MAX(sdht.term_frequency_type)
				FROM source_deal_detail sdd
				LEFT JOIN source_deal_header_template sdht ON sdht.source_deal_header_id = sdd.source_deal_header_id
				WHERE sdd.source_deal_header_id = @deal_id_mdq_update
				GROUP BY sdd.source_deal_header_id

				IF OBJECT_ID (N'tempdb..#mdq_set_pre') IS NOT NULL  DROP TABLE 	#mdq_set_pre

				SELECT  a.category,a.term_start
				, CASE 
					WHEN lead(a.mdq) OVER(ORDER BY a.term_start) IS NULL THEN @max_term
					ELSE DATEADD(DAY,-1,lead(a.term_start) OVER(ORDER BY a.term_start)) 
				  END term_end
				, CASE WHEN a.category = 'term_start' AND a.mdq IS NULL THEN ISNULL(lag(a.mdq) OVER(ORDER BY a.term_start),0.0) ELSE a.mdq END [mdq]
				INTO #mdq_set_pre
				FROM (
					SELECT tmg.effective_date term_start
						,CAST(tmg.mdq AS NUMERIC(10,5)) [mdq]
						, 'mdq_set_'+CAST(ROW_NUMBER() OVER(ORDER BY tmg.effective_date ASC) AS VARCHAR(10)) [category]
					FROM #temp_mdq_grid tmg
					WHERE tmg.effective_date <= @max_term

					UNION ALL 
					SELECT @min_term, NULL, 'term_start' 
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #temp_mdq_grid tmg1 WHERE tmg1.effective_date = @min_term)

					UNION ALL 
					SELECT @max_term, NULL, 'term_end'
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #temp_mdq_grid tmg1 WHERE tmg1.effective_date = @max_term)

				) a

				

				--fuel adjust ON term level
				IF OBJECT_ID (N'tempdb..#fuel_set_pre') IS NOT NULL  DROP TABLE 	#fuel_set_pre
				SELECT  a.category,a.term_start
				, CASE 
					WHEN lead(a.loss_factor) OVER(ORDER BY a.term_start) IS NULL THEN @max_term
					ELSE DATEADD(DAY,-1,lead(a.term_start) OVER(ORDER BY a.term_start)) 
				  END term_end
				, CASE WHEN a.category = 'term_start' AND a.loss_factor IS NULL THEN ISNULL(lag(a.loss_factor) OVER(ORDER BY a.term_start),0.0) ELSE a.loss_factor END [loss_factor]
				INTO #fuel_set_pre
				FROM (
					SELECT tmg.effective_date term_start
						,CAST(tmg.loss_factor AS NUMERIC(10,5)) [loss_factor]
						, 'loss_factor_set_'+CAST(ROW_NUMBER() OVER(ORDER BY tmg.effective_date ASC) AS VARCHAR(10)) [category]
					FROM #temp_path_loss_shrinkage tmg
					WHERE tmg.effective_date <= @max_term

					UNION ALL 
					SELECT @min_term, NULL, 'term_start' 
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #temp_path_loss_shrinkage tmg1 WHERE tmg1.effective_date = @min_term)

					UNION ALL 
					SELECT @max_term, NULL, 'term_end'
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #temp_path_loss_shrinkage tmg1 WHERE tmg1.effective_date = @max_term)

				) a

				DECLARE @detail_xml_update_mdq VARCHAR(MAX) = '<GridXML> '

				
				SELECT 
					@detail_xml_update_mdq += '<GridRow  
						deal_group="' + ISNULL(sdg.source_deal_groups_name, '') +  '" 
						group_id="' + CAST(tdd.source_deal_group_id AS VARCHAR(10)) + '"
						detail_flag="1"
						blotterleg="' + CAST(tdd.leg AS VARCHAR(10)) + '"
						source_deal_detail_id="' + CAST(tdd.source_deal_detail_id AS VARCHAR(10)) + '"								
						term_start="' + CAST(dbo.FNAUserDateFormat(tdd.term_start,1) AS VARCHAR(10)) + '"
						term_end="' + CAST(dbo.FNAUserDateFormat(tdd.term_end,1) AS VARCHAR(10)) + '"
						location_id="' + CAST(tdd.location_id AS VARCHAR(10)) + '"
						deal_volume="' + CAST(CASE WHEN tdd.Leg = 2 THEN mdq_info.mdq ELSE mdq_info.mdq / (1-fuel_info.loss_factor) END AS VARCHAR(100)) + '"																
						deal_volume_uom_id="' + CAST(tdd.deal_volume_uom_id AS VARCHAR(10)) + '"
						fixed_price="" 
						fixed_price_currency_id="' + CAST(tdd.fixed_price_currency_id AS VARCHAR(10)) + '"
						' + CASE WHEN tdd.leg = 2 THEN ' deal_detail_description="' + CAST(fuel_info.loss_factor AS VARCHAR(10)) + '"' ELSE '' END  + '
						>
					</GridRow>'					
				FROM source_deal_detail tdd
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = tdd.source_deal_header_id
				INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
				INNER JOIN source_deal_groups sdg
					ON tdd.source_deal_group_id = sdg.source_deal_groups_id
				OUTER APPLY(
					SELECT msp.category, msp.term_start, msp.term_end, msp.mdq
					FROM #mdq_set_pre msp
					WHERE msp.mdq IS NOT NULL AND msp.term_start >= @min_term
						AND tdd.term_start BETWEEN msp.term_start AND msp.term_end
						AND sdht.term_frequency_type = 'd'
					UNION ALL
					SELECT a.category, a.term_month, a.term_month, a.mdq
					FROM (
						SELECT dbo.FNAGetFirstLastDayOfMonth(term_start, 'f') term_month
							, DENSE_RANK() OVER(PARTITION BY dbo.FNAGetFirstLastDayOfMonth(term_start, 'f') ORDER BY term_start DESC) rnk
							, term_start
							, mdq
							, category
						FROM #mdq_set_pre
						WHERE mdq IS NOT NULL
							
					) a 
					WHERE a.rnk = 1
						AND a.term_month = tdd.term_start
						AND sdht.term_frequency_type = 'm'
				) mdq_info
				OUTER APPLY(
					SELECT fsp.*
					FROM #fuel_set_pre fsp
					WHERE fsp.loss_factor IS NOT NULL AND fsp.term_start >= @min_term
						AND tdd.term_start BETWEEN fsp.term_start AND fsp.term_end
				) fuel_info
				WHERE tdd.source_deal_header_id = @deal_id_mdq_update
				ORDER BY tdd.leg,tdd.term_start
																
				SET @detail_xml_update_mdq +=  ' </GridXML>'

				--deal update
				EXEC spa_deal_update_new  @flag='s'
										,@source_deal_header_id = @deal_id_mdq_update
										,@header_xml = NULL
										,@detail_xml = @detail_xml_update_mdq 
										,@pricing_process_id = NULL
										,@header_cost_xml = NULL
										,@deal_type_id = '1179'
										,@pricing_type = NULL
										,@term_frequency = @term_frequency_mdq_update
										,@shaped_process_id = NULL
										, @call_from = 'Delivery_path'

				
										

				
				/** UPDATE DEAL TO MATCH TERM LEVEL MDQ AND FUEL LOSS DEFINED END **/
			END
			ELSE
			BEGIN 
				DECLARE @source_deal_header_id INT
							
				--get deal id for update
				SELECT @source_deal_header_id = uddf.source_deal_header_id 
				FROM user_defined_deal_fields uddf
				INNER JOIN user_defined_deal_fields_template_main uddft
					ON uddf.udf_template_id = uddft.udf_template_id
				INNER JOIN user_defined_fields_template udft
					ON uddft.field_id = udft.field_id	
				INNER JOIN source_deal_header_template sdht
					ON sdht.template_id = uddft.template_id	
				WHERE udft.field_label = 'Delivery Path'  							
					AND sdht.template_name = 'Capacity NG' 
					AND udf_value =  @delivery_path_id
				
				DECLARE @min_term1 DATETIME
						, @deal_max_term DATETIME
						, @max_term1 DATETIME
						, @term_frequency_mdq_update1 CHAR(1)

				SELECT @min_term1 = MIN(sdd.term_start)
					, @deal_max_term = MAX(sdd.term_end)
					, @max_term1 = IIF(MAX(dbo.FNAGetFirstLastDayOfMonth(cg.flow_end_date,'l')) > MAX(sdd.term_end), MAX(dbo.FNAGetFirstLastDayOfMonth(cg.flow_end_date,'l')), MAX(sdd.term_end))
					, @term_frequency_mdq_update1 = MAX(sdht.term_frequency_type)
				FROM source_deal_detail sdd
				LEFT JOIN source_deal_header_template sdht 
					ON sdht.source_deal_header_id = sdd.source_deal_header_id
				LEFT JOIN source_deal_header sdh  
					ON sdh.source_deal_header_id = sdd.source_deal_header_id
				LEFT JOIN contract_group cg 
					ON cg.contract_id = sdh.contract_id
				WHERE sdd.source_deal_header_id = @source_deal_header_id 
				GROUP BY sdd.source_deal_header_id

				
				IF OBJECT_ID (N'tempdb..#mdq_set_pre1') IS NOT NULL  
					DROP TABLE #mdq_set_pre1

				SELECT  a.category
						,a.term_start
						, CASE WHEN lead(a.mdq) OVER(ORDER BY a.term_start) IS NULL THEN @max_term1
							ELSE DATEADD(DAY,-1,lead(a.term_start) OVER(ORDER BY a.term_start)) 
						  END term_end
						, CASE WHEN a.category = 'term_start' AND a.mdq IS NULL THEN ISNULL(lag(a.mdq) OVER(ORDER BY a.term_start),0.0) ELSE a.mdq END [mdq]
				INTO #mdq_set_pre1
				FROM (
					SELECT tmg.effective_date term_start
						, CAST(tmg.mdq AS NUMERIC(10,5)) [mdq]
						, 'mdq_set_' + CAST(ROW_NUMBER() OVER(ORDER BY tmg.effective_date ASC) AS VARCHAR(10)) [category]
					FROM #temp_mdq_grid tmg
					WHERE tmg.effective_date <= @max_term1

					UNION ALL 
					SELECT @min_term1, NULL, 'term_start' 
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #temp_mdq_grid tmg1 WHERE tmg1.effective_date = @min_term1)

					UNION ALL 
					SELECT @max_term1, NULL, 'term_end'
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #temp_mdq_grid tmg1 WHERE tmg1.effective_date = @max_term1)

				) a
				
				--fuel adjust ON term level
				IF OBJECT_ID (N'tempdb..#fuel_set_pre1') IS NOT NULL  
					DROP TABLE 	#fuel_set_pre1

				SELECT  a.category
						,a.term_start
						, CASE 
							WHEN lead(a.loss_factor) OVER(ORDER BY a.term_start) IS NULL THEN @max_term1
							ELSE DATEADD(DAY,-1,lead(a.term_start) OVER(ORDER BY a.term_start)) 
						  END term_end
						, CASE WHEN a.category = 'term_start' AND a.loss_factor IS NULL THEN ISNULL(lag(a.loss_factor) OVER(ORDER BY a.term_start),0.0) ELSE a.loss_factor END [loss_factor]
				INTO #fuel_set_pre1
				FROM (
					SELECT tmg.effective_date term_start
						,CAST(tmg.loss_factor AS NUMERIC(10,5)) [loss_factor]
						, 'loss_factor_set_'+CAST(ROW_NUMBER() OVER(ORDER BY tmg.effective_date ASC) AS VARCHAR(10)) [category]
					FROM #temp_path_loss_shrinkage tmg
					WHERE tmg.effective_date <= @max_term1

					UNION ALL 
					SELECT @min_term1, NULL, 'term_start' 
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #temp_path_loss_shrinkage tmg1 WHERE tmg1.effective_date = @min_term1)

					UNION ALL 
					SELECT @max_term1, NULL, 'term_end'
					WHERE NOT EXISTS(SELECT TOP 1 1 FROM #temp_path_loss_shrinkage tmg1 WHERE tmg1.effective_date = @max_term1)

				) a

				IF OBJECT_ID (N'tempdb..#xml_temp') IS NOT NULL  DROP TABLE 	#xml_temp
				SELECT 
						'<GridRow  
							deal_group="' + ISNULL(sdg.source_deal_groups_name, '') +  '" 
							group_id="' + CAST(tdd.source_deal_group_id AS VARCHAR(10)) + '"
							detail_flag="1"
							blotterleg="' + CAST(tdd.leg AS VARCHAR(10)) + '"
							source_deal_detail_id="' + CAST(tdd.source_deal_detail_id AS VARCHAR(10)) + '"								
							term_start="' + CAST(dbo.FNAUserDateFormat(tdd.term_start,1) AS VARCHAR(10)) + '"
							term_end="' + CAST(dbo.FNAUserDateFormat(tdd.term_end,1) AS VARCHAR(10)) + '"
							location_id="' + CAST(tdd.location_id AS VARCHAR(10)) + '"
							deal_volume="' + CAST(CASE WHEN tdd.Leg = 2 THEN mdq_info.mdq ELSE mdq_info.mdq / (1-fuel_info.loss_factor) END AS VARCHAR(100)) + '"																
							deal_volume_uom_id="' + CAST(tdd.deal_volume_uom_id AS VARCHAR(10)) + '"
							fixed_price="" 
							fixed_price_currency_id="' + CAST(tdd.fixed_price_currency_id AS VARCHAR(10)) + '"
							' + CASE WHEN tdd.leg = 2 THEN ' deal_detail_description="' + CAST(fuel_info.loss_factor AS VARCHAR(10)) + '"' ELSE '' END  + '
							>
						</GridRow>' [xml_string], tdd.leg, tdd.term_start
					INTO #xml_temp
					FROM source_deal_detail tdd
					INNER JOIN source_deal_header sdh 
						ON sdh.source_deal_header_id = tdd.source_deal_header_id
					INNER JOIN source_deal_header_template sdht 
						ON sdht.template_id = sdh.template_id
					INNER JOIN source_deal_groups sdg
						ON tdd.source_deal_group_id = sdg.source_deal_groups_id
					OUTER APPLY(
						SELECT msp.category, msp.term_start, msp.term_end, msp.mdq
						FROM #mdq_set_pre1 msp
						WHERE msp.mdq IS NOT NULL AND msp.term_start >= @min_term1
							AND tdd.term_start BETWEEN msp.term_start AND msp.term_end
							AND sdht.term_frequency_type = 'd'
						UNION ALL
						SELECT a.category, a.term_month, a.term_month, a.mdq
						FROM (
							SELECT dbo.FNAGetFirstLastDayOfMonth(term_start, 'f') term_month
									, DENSE_RANK() OVER(PARTITION BY dbo.FNAGetFirstLastDayOfMonth(term_start, 'f') ORDER BY term_start DESC) rnk
									, term_start
									, mdq
									, category
							FROM #mdq_set_pre1
							WHERE mdq IS NOT NULL
							
						) a 
						WHERE a.rnk = 1
							AND a.term_month = tdd.term_start
							AND sdht.term_frequency_type = 'm'
					) mdq_info
					OUTER APPLY(
						SELECT fsp.*
						FROM #fuel_set_pre1 fsp
						WHERE fsp.loss_factor IS NOT NULL 
							AND fsp.term_start >= @min_term1
							AND tdd.term_start BETWEEN fsp.term_start AND fsp.term_end
					) fuel_info
					WHERE tdd.source_deal_header_id = @source_deal_header_id
				
					UNION ALL
					SELECT 
					'<GridRow  
							deal_group="' + ISNULL(last_term_detail_values.source_deal_groups_name, '') +  '" 
							group_id="' + CAST(last_term_detail_values.source_deal_groups_id AS VARCHAR(10)) + '"
							detail_flag="1"
							blotterleg="' + CAST(leg_info.leg AS VARCHAR(10)) + '"
							source_deal_detail_id="NEW_' + CAST(ROW_NUMBER() OVER(ORDER BY leg_info.leg, a.term_start) AS VARCHAR(500)) + '"								
							term_start="' + CAST(dbo.FNAUserDateFormat(a.term_start,1) AS VARCHAR(10)) + '"
							term_end="' + CAST(dbo.FNAUserDateFormat(a.term_end,1) AS VARCHAR(10)) + '"
							location_id="' + CAST(last_term_detail_values.location_id AS VARCHAR(10)) + '"
							deal_volume="' + CAST(CASE WHEN leg_info.leg = 2 THEN mdq_info.mdq ELSE mdq_info.mdq / (1-fuel_info.loss_factor) END AS VARCHAR(100)) + '"
							deal_volume_uom_id="' + CAST(last_term_detail_values.deal_volume_uom_id AS VARCHAR(10)) + '"
							fixed_price="" 
							fixed_price_currency_id="' + CAST(last_term_detail_values.fixed_price_currency_id AS VARCHAR(10)) + '"
							' + CASE WHEN leg_info.leg = 2 THEN ' deal_detail_description="' + CAST(fuel_info.loss_factor AS VARCHAR(10)) + '"' ELSE '' END  + '
							>
						</GridRow>', leg_info.leg, a.term_start
						--last_term_detail_values.source_deal_groups_name [source_deal_groups_name],
						--last_term_detail_values.source_deal_groups_id [source_deal_group_id],
						--leg_info.leg,
						--NULL [source_deal_detail_id],
						--a.term_start,
						--a.term_end,
						--last_term_detail_values.location_id [location_id],
						--CASE WHEN leg_info.leg = 2 THEN mdq_info.mdq ELSE mdq_info.mdq / (1-fuel_info.loss_factor) END deal_volume,
						--last_term_detail_values.deal_volume_uom_id [deal_volume_uom_id],
						--last_term_detail_values.fixed_price_currency_id [fixed_price_currency_id],
						--CASE WHEN leg_info.leg = 2 THEN fuel_info.loss_factor ELSE NULL END [deal_detail_description]
					FROM (
						SELECT DATEADD(DAY, sq.n , @deal_max_term) term_start, DATEADD(DAY, sq.n , @deal_max_term) term_end  
						FROM seq sq
						WHERE @max_term1 >= DATEADD(DAY, sq.n, @deal_max_term) 
					) a
					CROSS JOIN (SELECT 1 leg UNION ALL SELECT 2) leg_info
					OUTER APPLY(
						SELECT msp.category, msp.term_start, msp.term_end, msp.mdq
						FROM #mdq_set_pre1 msp
						WHERE msp.mdq IS NOT NULL AND msp.term_start >= @min_term1
							AND a.term_start BETWEEN msp.term_start AND msp.term_end
							AND @term_frequency_mdq_update1 = 'd'
						UNION ALL
						SELECT a1.category, a1.term_month, a1.term_month, a1.mdq
						FROM (
							SELECT dbo.FNAGetFirstLastDayOfMonth(term_start, 'f') term_month
									, DENSE_RANK() OVER(PARTITION BY  dbo.FNAGetFirstLastDayOfMonth(term_start, 'f') ORDER BY term_start DESC) rnk
									, term_start
									, mdq
									, category
							FROM #mdq_set_pre1
							WHERE mdq IS NOT NULL
							
						) a1
						WHERE a1.rnk = 1
							AND a1.term_month = a.term_start
							AND @term_frequency_mdq_update1 = 'm'
					) mdq_info
					OUTER APPLY(
						SELECT fsp.*
						FROM #fuel_set_pre1 fsp
						WHERE fsp.loss_factor IS NOT NULL AND fsp.term_start >= @min_term1
							AND a.term_start BETWEEN fsp.term_start AND fsp.term_end
					) fuel_info
					OUTER APPLY (
						SELECT sdg.source_deal_groups_name
							, sdg.source_deal_groups_id
							, sdd.location_id
							, sdd.deal_volume_uom_id
							, sdd.fixed_price_currency_id
						FROM source_deal_detail sdd
						INNER JOIN source_deal_groups sdg 
							ON sdd.source_deal_group_id = sdg.source_deal_groups_id
						WHERE sdd.source_deal_header_id = @source_deal_header_id
							AND sdd.term_end = @deal_max_term
							AND sdd.leg = leg_info.leg
					) last_term_detail_values

				DECLARE @detail_xml_update_mdq1 VARCHAR(MAX) = '<GridXML> '
				
				SELECT @detail_xml_update_mdq1 += xt.[xml_string]
				FROM #xml_temp xt
				ORDER BY xt.Leg, xt.term_start
				

				SET @detail_xml_update_mdq1 +=  ' </GridXML>'
				
				--deal update
				EXEC spa_deal_update_new  @flag='s'
										,@source_deal_header_id=@source_deal_header_id
										,@header_xml=NULL
										,@detail_xml= @detail_xml_update_mdq1 
										,@pricing_process_id=NULL
										,@header_cost_xml=NULL
										,@deal_type_id='1179'
										,@pricing_type=NULL
										,@term_frequency=@term_frequency_mdq_update1
										,@shaped_process_id=NULL
										,@call_from = 'Delivery_path'

				/** UPDATE DEAL TO MATCH TERM LEVEL MDQ AND FUEL LOSS DEFINED END **/
				
			END
		END		
		/*************Deal insert code ends************/
	END
	--raiserror('forced_debug',16,1)
	--return
	IF @group_path_xml IS NOT NULL
	BEGIN
		--Collect data
		DECLARE @idoc_gp INT

		EXEC sp_xml_preparedocument @idoc_gp OUTPUT, @group_path_xml

		IF OBJECT_ID (N'tempdb..#temp_gp_detail') IS NOT NULL  
			DROP TABLE 	#temp_gp_detail

		CREATE TABLE #temp_gp_detail(
			row_id INT IDENTITY(1,1)
			, delivery_path_detail_id INT
			, path_id	INT
		)

		INSERT INTO #temp_gp_detail (delivery_path_detail_id, path_id)
		SELECT NULLIF(delivery_path_detail_id, '') delivery_path_detail_id,
			path_id		
		FROM   OPENXML(@idoc_gp, '/GridGroup/PSRecordset', 1)
		WITH (
			delivery_path_detail_id INT '@delivery_path_detail_id',
			path_id VARCHAR(100) '@path_id'
		)
		
		
		DELETE delivery_path_detail 
		WHERE path_id = @delivery_path_id

		INSERT INTO delivery_path_detail (Path_id, Path_name) 
		SELECT @delivery_path_id, path_id FROM #temp_gp_detail ORDER BY row_id

	
		UPDATE dp SET from_location = from_dp.from_location
				, to_location = to_dp.to_location
				, [contract] = from_dp.[contract]
		FROM delivery_path dp
			LEFT JOIN 
				(
					SELECT  from_dpd.path_name from_path, to_dpd.path_name to_path, s.group_path
					FROM 
						(
							SELECT MIN(dpd.delivery_path_detail_id) from_path, 
								MAX(dpd.delivery_path_detail_id) to_path ,
								MAX(dpd.path_id) group_path	
							FROM delivery_path_detail dpd  
							WHERE dpd.path_id = ISNULL(@new_path_id, @current_path)
							
						) s

					INNER JOIN delivery_path_detail from_dpd
						ON from_dpd.delivery_path_detail_id = s.from_path
					INNER JOIN delivery_path_detail to_dpd
						ON to_dpd.delivery_path_detail_id = s.to_path
				) p
			ON dp.path_id = p.group_path
			INNER JOIN delivery_path from_dp
				ON from_dp.path_id = p.from_path
			INNER JOIN delivery_path to_dp
				ON to_dp.path_id = p.to_path
	
	END
	ELSE IF @flag = 'u' AND @group_path_xml IS NULL
	BEGIN


	DECLARE @backhaul_path_id INT
	DECLARE @backhaul_path_name VARCHAR(100)

	IF EXISTS (SELECT 1 FROM #temp_general_form WHERE is_backhaul = 'y' AND @flag = 'i' AND NULLIF(isgrouppath, 'n') IS NULL)
		OR EXISTS(
					SELECT 1
					FROM #temp_general_form tgf
					INNER JOIN delivery_path dp
						ON tgf.path_id = dp.path_id
					WHERE dp.is_backhaul = 'y' 
						AND dp.backhaul_path_id IS NULL  
						AND @flag = 'u'
						AND NULLIF(tgf.isgrouppath, 'n') IS NULL
				)
	BEGIN
		
		DECLARE @to_be_copy_path_id INT = ISNULL(@new_path_id, @current_path)		
		
		EXEC spa_setup_delivery_path  @flag = 'c', @path_id = @to_be_copy_path_id, @show_message = 0
			
		SELECT @backhaul_path_name = 'Copy of ' + path_name  
		FROM delivery_path 
		WHERE path_id = @to_be_copy_path_id

		SELECT @backhaul_path_id = MAX(path_id) 
		FROM delivery_path 
		WHERE path_name = @backhaul_path_name

		UPDATE delivery_path 
			SET path_name = SUBSTRING(path_name, 9, LEN(path_name) ) + ' backhaul',
				path_code =  SUBSTRING(path_name, 9, LEN(path_name) ) + ' backhaul',
				from_location = to_location,
				to_location = from_location
		WHERE path_id = @backhaul_path_id

		UPDATE delivery_path
			SET backhaul_path_id = @backhaul_path_id
		WHERE path_id = @to_be_copy_path_id

	END
	ELSE IF EXISTS(SELECT 1
					FROM #temp_general_form tgf
					INNER JOIN delivery_path dp
						ON tgf.path_id = dp.path_id
					WHERE dp.is_backhaul = 'y' 
						AND dp.backhaul_path_id IS NOT NULL  
						AND @flag = 'u'
						AND NULLIF(tgf.isgrouppath, 'n') IS NULL
					)
	 BEGIN
		DECLARE @label_from_location VARCHAR(200)
		DECLARE @label_to_location VARCHAR(200)

		SELECT @backhaul_path_id = dp.backhaul_path_id
		FROM #temp_general_form tgf
		INNER JOIN delivery_path dp
			ON tgf.path_id = dp.path_id
		
		DELETE FROM counterparty_contract_rate_schedule WHERE path_id = @backhaul_path_id
		DELETE FROM path_loss_shrinkage WHERE path_id = @backhaul_path_id
		DELETE FROM delivery_path_mdq WHERE path_id = @backhaul_path_id
					
		UPDATE dp_b 
		SET path_code = dp.path_code + ' backhaul'
			,path_name = dp.path_name + ' backhaul'
			,delivery_means = dp.delivery_means
			,commodity = dp.commodity
			,isactive = dp.isactive
			,meter_from = dp.meter_from
			,meter_to = dp.meter_to
			,rateSchedule = dp.rateSchedule
			,counterParty = dp.counterParty
			,CONTRACT = dp.CONTRACT
			,location_id = dp.location_id
			,from_location = dp.to_location
			,to_location = dp.from_location
			,groupPath = dp.groupPath
			,shipping_counterparty = dp.shipping_counterparty
			,receiving_counterparty = dp.receiving_counterparty
			,formula_from = dp.formula_from
			,formula_to = dp.formula_to
			,imbalance_from = dp.imbalance_from
			,imbalance_to = dp.imbalance_to
			,loss_factor = dp.loss_factor
			,fuel_factor = dp.fuel_factor
			,mdq_at = dp.mdq_at
			,logical_name = dp.logical_name
			,mdq = dp.mdq
			,priority = dp.priority
			,path_type = dp.path_type

		FROM #temp_general_form tgf
		INNER JOIN delivery_path dp
			ON tgf.path_id = dp.path_id
		INNER JOIN delivery_path dp_b
			ON dp.backhaul_path_id = dp_b.path_id
		
		INSERT INTO counterparty_contract_rate_schedule (
						counterparty_id
						,contract_id
						,rate_schedule_id
						,path_id
						,RANK
						,effective_date
					)
		
		SELECT ccrs.counterparty_id
			,ccrs.contract_id
			,ccrs.rate_schedule_id
			,dp.backhaul_path_id
			,ccrs.RANK
			,ccrs.effective_date
		FROM #temp_general_form tgf
		INNER JOIN delivery_path dp
			ON tgf.path_id = dp.path_id
		INNER JOIN counterparty_contract_rate_schedule ccrs
			ON ccrs.path_id = tgf.path_id

		INSERT INTO path_loss_shrinkage (path_id
										,loss_factor
										,shrinkage_curve_id
										,is_receipt
										,effective_date
										,contract_id
										)		
		SELECT
			dp.backhaul_path_id
			,pls.loss_factor
			,pls.shrinkage_curve_id
			,pls.is_receipt
			,pls.effective_date
			,pls.contract_id		
		FROM #temp_general_form tgf
		INNER JOIN delivery_path dp
			ON tgf.path_id = dp.path_id
		INNER JOIN path_loss_shrinkage pls
			ON pls.path_id = tgf.path_id

		INSERT INTO  delivery_path_mdq (	path_id
											,effective_date
											,mdq
											,contract_id
											,rec_del
		)
		
		SELECT 
				dp.backhaul_path_id
				,dpm.effective_date
				,dpm.mdq
				,dpm.contract_id
				,dpm.rec_del
		FROM #temp_general_form tgf
		INNER JOIN delivery_path dp
			ON tgf.path_id = dp.path_id
		INNER JOIN delivery_path_mdq dpm
			ON dpm.path_id = tgf.path_id

	 END
	END
	-- return
	/*-- process ON delivery_path_detail table ends. Sequence of path detail should be in ORDER AS it IS listed in grid each process insert new pah detail. */
	COMMIT TRAN
	DECLARE @return_value NVARCHAR(500) = CAST(@delivery_path_id AS NVARCHAR(10)) + ';' + @new_path_name
	IF @show_message = 1
	BEGIN
		EXEC spa_ErrorHandler @@ERROR,
				  'Setup Delivery Path',
				  'spa_setup_delivery_path',
				  'Success',
				  'Changes have been saved successfully.',
				  @return_value
	END
	
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @err_no INT
	SELECT @err_no = ERROR_NUMBER()
	SET @err_msg = ERROR_MESSAGE()

	print @err_msg
		
	IF @err_no = 50000	--thrown by RAISE statement
	BEGIN
			
				
		EXEC spa_ErrorHandler -1,
			'Setup Delivery Path.',
			'spa_setup_delivery_path',
			'Error',
			@err_msg,
			@err_at
	END
	ELSE
	begin
		EXEC spa_ErrorHandler -1,
			'Setup Delivery Path.',
			'spa_setup_delivery_path',
			'Error',
			'SQL Error.',
			@err_msg
	END
		
END CATCH
  
END
ELSE IF @flag = 'g'
BEGIN
	SELECT DISTINCT i.item path_type 
		, dp.path_name grouping_name
		, dp.path_code
		, dp.path_id 
		, CASE WHEN sml_from.Location_Name <> sml_from.location_id THEN sml_from.location_id + ' - ' + sml_from.Location_Name ELSE sml_from.Location_Name END + CASE WHEN sml.location_name IS NULL THEN '' ELSE  ' [' + isnull(sml_1.location_name,'') + ']' END  AS [receipt_location]
		, CASE WHEN sml_to.Location_Name <> sml_to.location_id THEN sml_to.location_id + ' - ' + sml_to.Location_Name ELSE sml_to.Location_Name END + CASE WHEN sml.location_name IS NULL THEN '' ELSE  ' [' + isnull(sml.location_name,'') + ']' END  AS [delivery_location]
		, sc.counterparty_name
		, cg.contract_name
		, dbo.FNARemoveTrailingZero(ISNULL(aa.mdq, dp.mdq)) mdq
		, dbo.FNADateFormat(aa.effective_date) effective_date
		, sdvp.code [priority]
		, sdv.code  [rate_schedule]	
		, CASE WHEN dp.groupPath = 'y' THEN 'group' ELSE 'single' END is_grouppath,
		cg.contract_id,
		sdv_method_of_trans.code [method_of_transportation],
		CASE dp.isactive WHEN 'y' THEN 'Yes' WHEN 'n' THEN 'No' Else '' END
	FROM (VALUES('GROUP PATH'), ('SINGLE PATH')) i(item) 
	LEFT JOIN delivery_path dp ON i.item = CASE WHEN dp.groupPath = 'y' THEN 'GROUP PATH' ELSE 'SINGLE PATH' END
	LEFT JOIN delivery_path_mdq dpm ON dpm.path_id = dp.path_id
	LEFT JOIN source_minor_location sml_to ON sml_to.source_minor_location_id = dp.to_location
	LEFT JOIN source_major_location sml ON  sml_to.source_major_location_ID = sml.source_major_location_ID
	LEFT JOIN source_minor_location sml_from ON sml_from.source_minor_location_id = dp.from_location
	LEFT JOIN source_major_location sml_1 ON sml_from.source_major_location_ID = sml_1.source_major_location_ID
	LEFT JOIN source_counterparty sc  ON sc.source_counterparty_id = dp.counterParty
	LEFT JOIN contract_group cg ON cg.contract_id = dp.CONTRACT
	LEFT JOIN static_data_value sdv ON sdv.value_id = dp.rateSchedule AND sdv.[type_id] = 1800 --Transportation Rate Schedule
	LEFT JOIN static_data_value sdvp ON sdvp.value_id = dp.[priority] AND sdvp.[type_id] = 31400 --Priority
	LEFT JOIN static_data_value sdv_method_of_trans ON sdv_method_of_trans.value_id = dp.delivery_means AND sdv_method_of_trans.type_id = 100200  --[method_of_transportation]
	OUTER APPLY (
		SELECT TOP 1 effective_date, mdq 
		FROM delivery_path_mdq m 
		WHERE ISNULL(m.path_id, 0) = ISNULL(@single_path_id, ISNULL(dp.path_id, 0))
			AND m.path_id = dp.path_id 
			AND m.effective_date <= GETDATE()
		ORDER BY m.effective_date DESC
	) aa
	WHERE 1 = 1 AND ISNULL(dp.path_id, 0) = ISNULL(@single_path_id, ISNULL(dp.path_id, 0));
END
ELSE IF @flag = 'j'
BEGIN
	
	SELECT DISTINCT i.item path_type 
		, dp.path_name grouping_name
		, dp.path_code
		, dp.path_id 
		, CASE WHEN sml_from.Location_Name <> sml_from.location_id THEN sml_from.location_id + ' - ' + sml_from.Location_Name ELSE sml_from.Location_Name END + CASE WHEN sml.location_name IS NULL THEN '' ELSE  ' [' + sml_1.location_name + ']' END  AS [receipt_location]
		, CASE WHEN sml_to.Location_Name <> sml_to.location_id THEN sml_to.location_id + ' - ' + sml_to.Location_Name ELSE sml_to.Location_Name END + CASE WHEN sml.location_name IS NULL THEN '' ELSE  ' [' + sml.location_name + ']' END  AS [delivery_location]
		, sc.counterparty_name
		, cg.contract_name
		, dbo.FNARemoveTrailingZero(ISNULL(aa.mdq, dp.mdq)) mdq
		, dbo.FNADateFormat(aa.effective_date) effective_date
		, sdvp.code [priority]
		, sdv.code  [rate_schedule]	
		, CASE WHEN dp.groupPath = 'y' THEN 'group' ELSE 'single' END is_grouppath,
		cg.contract_id
	FROM (VALUES('GROUP PATH'), ('SINGLE PATH')) i(item) 
	LEFT JOIN delivery_path dp ON i.item = CASE WHEN dp.groupPath = 'y' THEN 'GROUP PATH' ELSE 'SINGLE PATH' END
	LEFT JOIN delivery_path_mdq dpm ON dpm.path_id = dp.path_id
	LEFT JOIN source_minor_location sml_to ON sml_to.source_minor_location_id = dp.to_location
	LEFT JOIN source_major_location sml ON  sml_to.source_major_location_ID = sml.source_major_location_ID
	LEFT JOIN source_minor_location sml_from ON sml_from.source_minor_location_id = dp.from_location
	LEFT JOIN source_major_location sml_1 ON sml_from.source_major_location_ID = sml_1.source_major_location_ID
	LEFT JOIN source_counterparty sc  ON sc.source_counterparty_id = dp.counterParty
	LEFT JOIN contract_group cg ON cg.contract_id = dp.CONTRACT
	LEFT JOIN static_data_value sdv ON sdv.value_id = dp.rateSchedule AND sdv.[type_id] = 1800 --Transportation Rate Schedule --#HARDCODED
	LEFT JOIN static_data_value sdvp ON sdvp.value_id = dp.[priority] AND sdvp.[type_id] = 31400 --Priority --#HARDCODED
	OUTER APPLY (
		SELECT TOP 1 effective_date, mdq 
		FROM delivery_path_mdq m 
		WHERE ISNULL(m.path_id, 0) = ISNULL(@single_path_id, ISNULL(dp.path_id, 0))
			AND m.path_id = dp.path_id 
			AND m.effective_date <= GETDATE()
		ORDER BY m.effective_date DESC
	) aa
	WHERE 1 = 1 
		AND dp.commodity = '123' --#HARDCODED
		AND ISNULL(dp.path_id, 0) = ISNULL(@single_path_id, ISNULL(dp.path_id, 0));
END
ELSE IF @flag = 'd'
BEGIN
		DECLARE @idoc4 INT
		EXEC sp_xml_preparedocument @idoc4 OUTPUT, @grid_xml
		
		IF OBJECT_ID (N'tempdb..#path_to_delete') IS NOT NULL  
			DROP TABLE #path_to_delete

		SELECT 
			path_id
		INTO #path_to_delete
		FROM   OPENXML(@idoc4, '/GridGroup/GridDelete/GridRow', 1)
		WITH (
			path_id INT '@path_id'
		)

		DECLARE @delivery_path INT

		SELECT @delivery_path = value_id
		FROM   static_data_value sdv
		WHERE  sdv.code = 'Delivery Path' --#HARDCODED 
		AND TYPE_ID = 5500 
		
		--293432
		IF EXISTS(
			SELECT	udf_value
			FROM	[dbo].user_defined_deal_fields_template_main uddft    
			INNER JOIN user_defined_deal_fields uddf 
				ON uddf.udf_template_id = uddft.udf_template_id 
				AND uddft.field_id = @delivery_path
			INNER JOIN #path_to_delete pd 
				ON CAST(pd.path_id AS VARCHAR(10)) = uddf.udf_value	
			UNION
			SELECT dpd.Path_name
			FROM delivery_path_detail dpd
			INNER JOIN delivery_path dp 
				ON dp.path_id = dpd.path_id
			INNER JOIN #path_to_delete pd 
				ON pd.path_id = dpd.Path_name
					
		)
		BEGIN
			DECLARE @err_path VARCHAR(250)

			SELECT @err_path = STUFF((SELECT ',' + CAST(udf_value  AS VARCHAR)  
										FROM	[dbo].user_defined_deal_fields_template_main uddft    
										INNER JOIN user_defined_deal_fields uddf 
											ON uddf.udf_template_id = uddft.udf_template_id 
											AND uddft.field_id = @delivery_path
										INNER JOIN #path_to_delete pd 
											ON CAST(pd.path_id AS VARCHAR(10)) = uddf.udf_value	
										ORDER BY  udf_value  FOR XML PATH ('')), 1, 1, '') 

			
				EXEC spa_ErrorHandler -1,
					'Setup Delivery Path',
					'spa_setup_delivery_path',
					'Error',
					'Path IS in use.',
					@err_path
				RETURN
		END
		ELSE
		BEGIN 

			SET @grid_xml = NULL

			IF EXISTS (SELECT 1 FROM #path_to_delete ptd
						INNER JOIN delivery_path dp
							ON dp.path_id = ptd.path_id
						WHERE backhaul_path_id IS NOT NULL
			)
			BEGIN
				SET @grid_xml = '<GridGroup><GridDelete> '

				SELECT @grid_xml += ' <GridRow path_id="' + CAST(backhaul_path_id AS VARCHAR(10)) + '" ></GridRow> '
				FROM #path_to_delete ptd
				INNER JOIN delivery_path dp
					ON dp.path_id = ptd.path_id
				WHERE backhaul_path_id IS NOT NULL

				SET @grid_xml += ' </GridDelete></GridGroup>'
			END 

			DELETE ccrs 
			FROM counterparty_contract_rate_schedule ccrs
			INNER JOIN #path_to_delete pd 
				ON pd.path_id = ccrs.path_id	

			DELETE ls 
			FROM path_loss_shrinkage ls
			INNER JOIN #path_to_delete pd 
				ON pd.path_id = ls.path_id	

			DELETE dpd 
			FROM delivery_path_detail dpd
			INNER JOIN delivery_path dp 
				ON dp.path_id = dpd.Path_id 
				AND dp.groupPath = 'y'
			INNER JOIN #path_to_delete pd 
				ON pd.path_id = dp.path_id

			DELETE dp 
			FROM delivery_path dp
			INNER JOIN #path_to_delete pd 
				ON pd.path_id = dp.path_id	

			UPDATE dp
			SET  is_backhaul = NULL,
				backhaul_path_id = NULL
			FROM delivery_path dp
			INNER JOIN #path_to_delete ptd
				ON dp.backhaul_path_id = ptd.path_id
			

			IF @grid_xml IS NOT NULL
			BEGIN
				EXEC spa_setup_delivery_path  @flag='d', @grid_xml = @grid_xml, @show_message = 0
			END

			IF @show_message = 1
			BEGIN
				EXEC spa_ErrorHandler 0,
						'Setup Delivery Path',
						'spa_setup_delivery_path',
						'Success',
						'Changes have been saved successfully.',
						''
			END
		END
END
ELSE IF @flag = 'f'
BEGIN
	SELECT ls.path_loss_shrinkage_id,
		ls.path_id,
		ls.contract_id,
		dbo.FNARemoveTrailingZero(ls.loss_factor) loss_factor,
		ls.shrinkage_curve_id,
		ls.is_receipt,
		dbo.FNAGetSQLStandardDate(ls.effective_date) effective_date
	FROM path_loss_shrinkage ls
	INNER JOIN delivery_path dp 
		ON dp.path_id = ls.path_id 
		AND dp.path_id = @path_id
END
ELSE IF @flag = 'p'
BEGIN
	SELECT
		dpd.delivery_path_detail_id
		, dp1.path_id
		, dp1.path_code + '^javascript:open_single_path(' + CAST(dp1.path_id AS VARCHAR(20)) + ')^' path_code
		, sml_from.Location_Name from_location
		, sml_to.Location_Name to_location
		, sc.counterparty_name
		, cg.contract_name
		, dbo.FNARemoveTrailingZero(dp.mdq) mdq
		, sdv.code [priority]
		, dp1.logical_name
	FROM delivery_path_detail dpd
	INNER JOIN delivery_path dp 
		ON dpd.path_id = dp.path_id 
	INNER JOIN delivery_path dp1 
		ON dp1.path_id = dpd.path_name
	LEFT JOIN source_minor_location sml_from 
		ON sml_from.source_minor_location_id = dp1.from_location
	LEFT JOIN source_minor_location sml_to 
		ON sml_to.source_minor_location_id = dp1.to_location	
	LEFT JOIN source_counterparty sc 
		ON sc.source_counterparty_id = dp1.counterParty		
	LEFT JOIN contract_group cg 
		ON cg.contract_id = dp1.CONTRACT
	LEFT JOIN static_data_value sdv 
		ON sdv.value_id = dp1.[priority] 
		AND sdv.type_id = 31400
	WHERE dp.path_id =  @path_id 
		AND dp.groupPath = @is_group_path

END

ELSE IF @flag = 'c'
BEGIN	
	BEGIN TRY
		BEGIN TRAN
		IF OBJECT_ID(N'tempdb..#map_path_to_copy') IS NOT NULL 
			DROP TABLE #map_path_to_copy

		CREATE TABLE #map_path_to_copy (
			old_path INT
			, new_path INT
			, new_path_code VARCHAR(100) COLLATE DATABASE_DEFAULT
		)

		INSERT INTO delivery_path(
			path_code,
			path_name,
			delivery_means,
			commodity,
			isactive,
			meter_from,
			meter_to,
			rateSchedule,
			counterParty,
			CONTRACT,
			location_id,
			from_location,
			to_location,
			groupPath,
			shipping_counterparty,
			receiving_counterparty,
			formula_from,
			formula_to,
			imbalance_from,
			imbalance_to,
			loss_factor,
			fuel_factor,
			logical_name,
			mdq,
			priority,
			mdq_at
		)
		OUTPUT INSERTED.path_id,INSERTED.path_id,INSERTED.path_code
		INTO #map_path_to_copy
		SELECT  'Copy of ' + dp.path_code,
				'Copy of ' + path_name,
				delivery_means,
				commodity,
				isactive,
				meter_from,
				meter_to,
				rateSchedule,
				counterParty,
				CONTRACT,
				location_id,
				from_location,
				to_location,
				groupPath,
				shipping_counterparty,
				receiving_counterparty,
				formula_from,
				formula_to,
				imbalance_from,
				imbalance_to,
				loss_factor,
				fuel_factor,
				logical_name,
				mdq,
				priority,
				mdq_at
		FROM delivery_path dp
		INNER JOIN dbo.SplitCommaSeperatedValues(@path_id) i 
			ON i.item = dp.path_id	

		UPDATE temp_path
		SET old_path = dp.path_id
		FROM #map_path_to_copy temp_path
		INNER JOIN delivery_path dp 
			ON  'Copy of ' + dp.path_code = temp_path.new_path_code

		UPDATE dp
		SET dp.path_code = dp.path_code + CASE WHEN new_num IS NOT NULL THEN ' ' + CAST(new_num AS VARCHAR(4)) ELSE '' END,
			dp.path_name = dp.path_name + CASE WHEN new_num IS NOT NULL THEN ' ' +  CAST(new_num AS VARCHAR(4)) ELSE '' END	
		FROM #map_path_to_copy temp_path
		INNER JOIN delivery_path dp ON dp.path_id = temp_path.new_path
		INNER JOIN (
			SELECT n.new_path_code,
			MAX(SUBSTRING(t.path_code, LEN(n.new_path_code) + 1, LEN(t.path_code)) + 1) new_num
			FROM delivery_path t
			INNER JOIN #map_path_to_copy n 
				ON t.path_code LIKE n.new_path_code + '%' 
				AND t.path_id <> n.new_path			
			GROUP BY n.new_path_code
		) inner_path 
			ON inner_path.new_path_code = temp_path.new_path_code

		--Copy path detail
		INSERT INTO delivery_path_detail(
			Path_id,
			Path_name,
			From_meter,
			To_meter)
		SELECT
			map_path.new_path,
			dpd.Path_name,
			dpd.From_meter,
			dpd.To_meter
		FROM delivery_path_detail dpd
		INNER JOIN delivery_path dp 
			ON dp.path_id = dpd.path_id
		INNER JOIN #map_path_to_copy map_path 
			ON map_path.old_path = dp.path_id
	
		--Copy counterparty contract rate schedule
		INSERT INTO counterparty_contract_rate_schedule(
			counterparty_id,
			contract_id,
			rate_schedule_id,
			path_id,
			RANK
		)
		SELECT ccrs.counterparty_id,
			ccrs.contract_id,
			ccrs.rate_schedule_id,
			map_path.new_path,
			ccrs.RANK
		FROM counterparty_contract_rate_schedule ccrs
		INNER JOIN #map_path_to_copy map_path 
			ON map_path.old_path = ccrs.path_id
	
		--Copy loss shrinkage detail
		INSERT INTO path_loss_shrinkage(
			path_id,
			loss_factor,
			shrinkage_curve_id,
			is_receipt,
			effective_date
			)
		SELECT map_path.new_path,
			ls.loss_factor,
			ls.shrinkage_curve_id,
			ls.is_receipt,
			ls.effective_date
		FROM path_loss_shrinkage ls
		INNER JOIN #map_path_to_copy map_path 
			ON map_path.old_path = ls.path_id

		--Copy MDQ
		INSERT INTO delivery_path_mdq(
			path_id,
			mdq,
			effective_date,
			contract_id,
			rec_del
			)
		SELECT map_path.new_path,
			dpm.mdq,
			dpm.effective_date,
			dpm.contract_id,
			dpm.rec_del
		FROM delivery_path_mdq dpm
		INNER JOIN #map_path_to_copy map_path 
			ON map_path.old_path = dpm.path_id
	
		IF @show_message = 1
		BEGIN
			EXEC spa_ErrorHandler @@ERROR,
					  'Setup Delivery Path',
					  'spa_setup_delivery_path',
					  'Success',
					  'Changes have been saved successfully.',
					  ''
		END
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		EXEC spa_ErrorHandler @@ERROR,
				  'Setup Delivery Path.',
				  'spa_setup_delivery_path',
				  'ERROR',
				  'Failed to save changes..',
				  ''
	END CATCH
END
ELSE IF @flag = 'h'
BEGIN
	SELECT dpm.delivery_path_mdq_id, 
			dpm.path_id,
			cg.[contract_name],
			dbo.FNAGetSQLStandardDate(dpm.effective_date)[effective_date],
			dbo.FNARemoveTrailingZero(dpm.mdq)[mdq],
			dpm.rec_del
	FROM delivery_path_mdq dpm
	INNER JOIN delivery_path dp 
		ON dp.path_id = dpm.path_id 
		AND dp.path_id = @path_id
	INNER JOIN contract_group cg 
		ON cg.contract_id = dpm.contract_id
	ORDER BY dpm.effective_date DESC
END
ELSE IF @flag = 'k'
BEGIN
	SELECT  uddf.source_deal_header_id 
	FROM user_defined_deal_fields uddf
	INNER JOIN user_defined_deal_fields_template_main uddft
		ON uddf.udf_template_id = uddft.udf_template_id
	INNER JOIN user_defined_fields_template udft
		ON uddft.field_id = udft.field_id	
	INNER JOIN source_deal_header_template sdht
		ON sdht.template_id = uddft.template_id	
	WHERE udft.field_label = 'Delivery Path' --#HARDCODED  							
		AND sdht.template_name = 'Capacity NG' --#HARDCODED  		
		AND udf_value = @path_id
END	

