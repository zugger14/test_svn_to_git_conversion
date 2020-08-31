
IF OBJECT_ID(N'[dbo].spa_delivery_path', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_delivery_path]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	 General stored procedure for delivery path.

	Parameters
		@flag : 
				'i' - insert 
				'u' - update
				'e' - copy of path
				's' - Return path data according to different filters
				's' - Return path data according to different filters
				'x' - Return path id and path name according to different filters for combo
				'd' - delete path
				'a' - Return path data of a particular path
				'c' - Return counterparty id and name  
				'p' - Return counterparty id and name of a contract
				'j' - Return path data according to different filters
				'r' - Called in deal level scheduling to change the related from_location, to_location, avg loss factor and contract of specified path.
				'n' - Return path id and path name according to different filters for combo
				'w' - Return path id and path name of active path
				'z' - Return loss factor of path
		@path_id : ID of delivery path
		@path_code : Code for Delivery path
		@path_name : Name of delivery path
		@delivery_means : ID for movement type
		@commodity : ID of commodity type
		@deliveryIsActive : Flag for active or inactive path, 'y' for active and 'n' for inactive
		@fromMeter : ID of from meter
		@toMeter : ID of To Meter
		@rateSchedule : Rate Schedule
		@counterParty : ID of CounterParty
		@contract : ID of Contract
		@location_id : TBD (value is null for all delivery path)
		@from_location : Starting Location of delivery path
		@to_location : Distination Location of delivery path
		@groupPath : Flag for group path, 'y' for group path 'n' for single path
		@shipping : Shipping counterparty ID
		@receiving : Receiving counterpaty ID
		@path_id2 : Use to pass mulitple path ids in comma separated form
		@formula_id_from : From Formula ID
		@formula_id_to : To Formula ID
		@loss_factor : Loss Factor of path
		@fuel_factor : TBD
		@imbalance_from : Flag for Imbalance From
		@imbalance_to : Flag for Imbalance To
		@check_proxy : Flag for Check Proxy
		@call_from : Call From flag
		@from_source_deal_header_id : From Source Deal Header Id
*/
CREATE PROC [dbo].[spa_delivery_path]
	@flag						CHAR(1),
	@path_id					INT = NULL,
	@path_code					VARCHAR(50) = NULL,
	@path_name					VARCHAR(50) = NULL,
	@delivery_means				INT = NULL,
	@commodity					INT = NULL,
	@deliveryIsActive			CHAR(1) = NULL,
	@fromMeter					INT = NULL,
	@toMeter					INT = NULL,
	@rateSchedule				INT = NULL,
	@counterParty				INT = NULL,
	@contract					INT = NULL,
	@location_id				INT = NULL,
	@from_location				INT = NULL,
	@to_location				INT = NULL,
	@groupPath					CHAR(1) = NULL,
	@shipping					INT = NULL,
	@receiving					INT = NULL ,
	@path_id2					VARCHAR(250) = NULL,
	@formula_id_from			INT = NULL,
	@formula_id_to				INT = NULL,
	@loss_factor				FLOAT = NULL,
	@fuel_factor				FLOAT = NULL,
	@imbalance_from				CHAR(1) = NULL,
	@imbalance_to				CHAR(1) = NULL,
	@check_proxy				CHAR(1) = 'y',
	@call_from					VARCHAR(200) = NULL, 
	@from_source_deal_header_id INT = NULL
AS
SET NOCOUNT ON
DECLARE @sql VARCHAR(MAX)

SET @from_location	= NULLIF(@from_location, 0)			
SET	@to_location = NULLIF(@to_location, 0)			


IF @path_id2 IS NULL
	SET @path_id2 = @path_id

IF @flag IN ( 'i', 'u')
BEGIN
	IF @fromMeter IS NULL
	BEGIN
		SELECT @fromMeter = MAX(meter_id) 
		FROM source_minor_location_meter 
		WHERE source_minor_location_id = @from_location
	END
		
	IF @toMeter IS NULL
	BEGIN
		SELECT @toMeter = MAX(meter_id) 
		FROM source_minor_location_meter 
		WHERE source_minor_location_id = @to_location
	END
END

IF @flag IN  ('i', 'e') 
BEGIN
	
	DECLARE @new_path_id INT
	
	IF @flag = 'i'
	BEGIN
		IF EXISTS(SELECT 1 FROM dbo.delivery_path WHERE path_code = @path_code)
		BEGIN
			EXEC spa_ErrorHandler -1,
				'Data already exists in the database.',
				'spa_delivery_path',
				'Error',
				'',
				''
		RETURN
		END
	
		INSERT INTO dbo.delivery_path (
			path_code,
			path_name,
			delivery_means,
			commodity,
			isactive,
			meter_from,
			meter_to,
			rateSchedule,
			counterParty,
			[contract],
			location_id,
			from_location,
			to_location,
			groupPath,
			shipping_counterparty,
			receiving_counterparty,
			formula_from,
			formula_to,
			loss_factor,
			fuel_factor,
			imbalance_from,
			imbalance_to
		
		) VALUES (
			@path_code,
			@path_name,
			@delivery_means,
			@commodity,
			@deliveryIsActive,
			@fromMeter,
			@toMeter,
			@rateSchedule,
			@counterParty,
			@contract,
			@location_id,
			@from_location,
			@to_location,
			@groupPath,
			@shipping,
			@receiving,
			@formula_id_from,
			@formula_id_to,
			@loss_factor,
			@fuel_factor,
			@imbalance_from,
			@imbalance_to
		)
		
		SET @new_path_id = SCOPE_IDENTITY()
	END
	ELSE IF @flag = 'e'
	BEGIN
				
		INSERT INTO dbo.delivery_path (
			path_code,
			path_name,
			delivery_means,
			commodity,
			isactive,
			meter_from,
			meter_to,
			rateSchedule,
			counterParty,
			[contract],
			location_id,
			from_location,
			to_location,
			groupPath,
			shipping_counterparty,
			receiving_counterparty,
			formula_from,
			formula_to,
			loss_factor,
			fuel_factor,
			imbalance_from,
			imbalance_to			
		
		) 
		SELECT 
			'Copy of ' + [path_code], 
			'Copy of ' + [path_name], 
			[delivery_means], 
			[commodity], 
			[isactive], 
			[meter_from], 
			[meter_to], 
			[rateSchedule], 
			[counterParty], 
			[CONTRACT], 
			[location_id], 
			[from_location], 
			[to_location], 
			[groupPath], 
			[shipping_counterparty], 
			[receiving_counterparty], 
			[formula_from], 
			[formula_to], 
			[loss_factor], 
			[fuel_factor], 
			[imbalance_from], 
			[imbalance_to]
		FROM delivery_path dp 
		WHERE dp.path_id = @path_id		
		
		SET @new_path_id = SCOPE_IDENTITY()
		
		DECLARE @path_count INT, @new_path_name VARCHAR(50)
		SELECT @new_path_name = path_code 
		FROM delivery_path dp 
		WHERE dp.path_id = @new_path_id
		
		SELECT @path_count = COUNT(1)-1 
		FROM delivery_path dp 
		WHERE dp.path_code 
			LIKE @new_path_name + '%'

		IF @path_count > 0
		BEGIN
			UPDATE delivery_path
			SET	path_code = path_code + CAST(@path_count AS VARCHAR(10))
				, path_name = path_name + CAST(@path_count AS VARCHAR(10))
			WHERE path_id = @new_path_id
		END
		
		--Copy delivery path detail 		
		INSERT INTO delivery_path_detail
		(
			Path_id,
			Path_name,
			From_meter,
			To_meter
		)
		SELECT @new_path_id
			, dpd.Path_name
			, dpd.From_meter
			, dpd.To_meter
		FROM delivery_path_detail dpd
		INNER JOIN delivery_path dp 
			ON dp.path_id = dpd.Path_id 
			AND dp.groupPath = 'y'
			AND dp.Path_id = @path_id
			
	END	
	
	IF @@ERROR <> 0
	BEGIN
	    EXEC spa_ErrorHandler @@ERROR,
	         'Insert Delivery Path.',
	         'spa_delivery_path',
	         'DB Error',
	         'Insert Delivery Path failed.',
	         ''
	    
	    RETURN
	END
	ELSE
	BEGIN
		EXEC spa_ErrorHandler 0,
	         'Insert Delivery Path.',
	         'spa_delivery_path',
	         'Success',
	         'Successfully Inserted Delivery Path .',
	         @new_path_id
	END   
END

ELSE IF @flag = 's' OR @flag = 'x'
BEGIN
	IF @call_from IN (
			'opt_book_out'
			,'opt_book_out_b2b'
			)
	BEGIN
		DECLARE @pipeline INT

		SELECT @pipeline = pipeline
		FROM source_minor_location
		WHERE source_minor_location_id = @from_location

		SELECT - 1 [Path ID]
			,'Dummy Path' [Path Code]
			,@pipeline [Pipeline]

		RETURN
	END	
	IF NOT EXISTS(SELECT 1 FROM delivery_path WHERE from_location = @from_location) AND @check_proxy = 'y'
	BEGIN
		SELECT @from_location = proxy_location_id FROM source_minor_location WHERE source_minor_location_id = @from_location
	END

	IF NOT EXISTS(SELECT 1 FROM delivery_path WHERE to_location = @to_location) AND @check_proxy = 'y'
	BEGIN
		SELECT @to_location = proxy_location_id FROM source_minor_location WHERE source_minor_location_id = @to_location
	END
		


	SET @sql = CAST('' AS VARCHAR(MAX)) + ' SELECT 
		dp.path_id [Path ID],	
		dp.path_code [Path Code]'
			
	IF	@flag = 's'
		SET @sql = @sql +
		'		
			
		,dp.path_name [Path Name]			,
		sdv.code [Delivery Means] ,
		sml.Location_Name  [From Location],
		sml1.Location_Name  [To Location],
		mi.recorderid [From Meter],
		mi1.recorderid [To Meter],
		sc.commodity_name [Commodity],
		scp.counterparty_name [Counterparty],
		dp.loss_factor [Loss Factor],
		dp.fuel_factor [Fuel Factor],	
		sml.source_minor_location_id [From Location ID],
		sml1.source_minor_location_id [To Location ID],
		IIF(smlg.location_name = ''Storage'', ''Yes'', ''No'') [From Storage],
		IIF(smlg1.location_name = ''Storage'', ''Yes'', ''No'') [To Storage]
		'	
					
	SET @sql = @sql + '	
		FROM dbo.delivery_path dp ' 
					+ IIF(CAST(@from_source_deal_header_id AS VARCHAR(100)) IS NULL, '', '
					INNER JOIN  (SELECT TOP 1 location_id 
								FROM source_deal_detail 
								WHERE source_deal_header_id = ' + CAST(@from_source_deal_header_id AS VARCHAR(100))+' 
								AND  leg = 1

								) sdd_loc_from
						ON sdd_loc_from.location_id = dp.from_location

					
					')  + '

					LEFT JOIN source_counterparty scp 
						ON scp.source_counterparty_id = dp.counterparty
					LEFT JOIN source_minor_location_meter smlm	
						ON smlm.source_minor_location_id = dp.from_location 
						--AND smlm.meter_id = dp.meter_from	
					LEFT JOIN source_minor_location_meter smlm1	
						ON smlm1.source_minor_location_id = dp.to_location 
						--AND smlm1.meter_id = dp.meter_to
					LEFT JOIN source_minor_location sml 
						ON dp.from_location = sml.source_minor_location_id
					LEFT JOIN source_minor_location sml1 
						ON dp.to_location = sml1.source_minor_location_id
					LEFT JOIN source_major_location smlg
						ON smlg.source_major_location_id = sml.source_major_location_id
					LEFT JOIN source_major_location smlg1
						ON smlg1.source_major_location_id = sml1.source_major_location_id
					LEFT JOIN meter_id mi 
						ON mi.meter_id = smlm.meter_id
					LEFT JOIN meter_id mi1 
						ON mi1.meter_id=smlm1.meter_id
					LEFT JOIN dbo.static_data_value sdv 
						ON sdv.value_id = dp.delivery_means
					LEFT JOIN source_commodity sc 
						ON sc.source_commodity_id = dp.commodity
					LEFT JOIN location_loss_factor llf 
						ON llf.from_location_id = dp.from_location 
						AND llf.to_location_id=dp.to_location	
					LEFT JOIN 
					(
						SELECT dpd_min.* 
						FROM delivery_path_detail dpd_min
						INNER JOIN 
									(SELECT MIN(delivery_path_detail_id) delivery_path_detail_id
										FROM delivery_path_detail dpd_group
										GROUP BY dpd_group.Path_id
									) p_min 
							ON dpd_min.delivery_path_detail_id = p_min.delivery_path_detail_id
					) dpd_from 
						ON dp.path_id = dpd_from.path_id 
						AND ISNULL(dp.groupPath, ''n'') = ''y''
					LEFT JOIN delivery_path dp_from 
						ON dpd_from.path_name = dp_from.path_id 
					LEFT JOIN 
					(
						SELECT dpd_max.* 
						FROM delivery_path_detail dpd_max
						INNER JOIN 
							(SELECT MAX(delivery_path_detail_id) delivery_path_detail_id
								FROM delivery_path_detail dpd_group
								GROUP BY dpd_group.Path_id
							) p_max 
						ON dpd_max.delivery_path_detail_id = p_max.delivery_path_detail_id
					) dpd_to 
						ON dp.path_id = dpd_to.Path_id 
						AND ISNULL(dp.groupPath, ''n'') = ''y''
					LEFT JOIN delivery_path dp_to 
					ON dpd_to.Path_name = dp_to.path_id 
									
	WHERE 1=1'


	--SET @from_location = ISNULL(@from_location, -1)
	--SET @to_location = ISNULL(@to_location, -1)

	IF @from_location IS NOT NULL
	SELECT @sql = @sql + ' AND (dp_from.from_location = ' + CAST(@from_location AS VARCHAR) + ' OR dp.from_location = ' + CAST(@from_location AS VARCHAR) + ')'
	
	--SELECT @sql = @sql + ' AND (dp_to.to_location = ' + CAST(@to_location AS VARCHAR) + ' OR dp.to_location = ' + CAST(@to_location AS VARCHAR) + ')'
		
	IF @commodity IS NOT NULL
		SELECT @sql = @sql + ' AND dp.commodity	= ' + CAST(@commodity AS VARCHAR)
		
	IF @fromMeter IS NOT NULL
	BEGIN
		SELECT @sql = @sql + ' AND mi.recorderid = ' + CAST(@fromMeter AS VARCHAR)
	END

	IF @toMeter IS NOT NULL
	BEGIN
		SELECT @sql = @sql + ' AND mi1.recorderid = ' + CAST(@toMeter AS VARCHAR)
	END

	IF @location_id IS NOT NULL
		SELECT @sql = @sql + ' AND (sml.source_minor_location_id = ' + CAST(@location_id AS VARCHAR) +
		 ' OR sml1.source_minor_location_id = ' + CAST(@location_id AS VARCHAR) + ')'
		
	IF @deliveryIsActive IS NOT NULL
		SELECT @sql = @sql + ' AND dp.isactive = ''' + CAST(@deliveryIsActive AS VARCHAR) + ''''
		
	IF @counterParty IS NOT NULL
	BEGIN
		SELECT @sql = @sql + ' AND scp.source_counterparty_id = ' + CAST(@counterparty AS VARCHAR)
	END	
		
	IF @loss_factor IS NOT NULL
	BEGIN
		SELECT @sql = @sql + ' AND dp.loss_factor = ' + CAST(@loss_factor AS VARCHAR)
	END
		
	IF @fuel_factor IS NOT NULL
	BEGIN
		SELECT @sql = @sql + ' AND dp.fuel_factor = ' + CAST(@fuel_factor AS VARCHAR)
	END
		
	IF @imbalance_from IS NOT NULL
	BEGIN
		SELECT @sql = @sql + ' AND dp.imbalance_from = ' + CAST(@imbalance_from AS VARCHAR)
	END
		
	IF @imbalance_to IS NOT NULL
	BEGIN
		SELECT @sql = @sql + ' AND dp.imbalance_to = ' + CAST(@imbalance_to AS VARCHAR)
	END

	--print @sql
	EXEC(@sql)
END

ELSE IF @flag = 'd'
BEGIN
     DELETE 
     FROM   dbo.delivery_path
     WHERE  path_id = @path_id 
     
     IF @@ERROR <> 0
     BEGIN
         EXEC spa_ErrorHandler @@ERROR,
              'Delete Delivery Path.',
              'spa_delivery_path',
              'DB Error',
              'Delete Delivery Path failed.',
              ''
         
         RETURN
     END
     ELSE
 	 BEGIN
 		EXEC spa_ErrorHandler 0,
              'Delete Delivery Path.',
              'spa_delivery_path',
              'Success',
              'Successfully Delete Delivery Path .',
              ''
 	 END     
END

ELSE IF @flag = 'a'
BEGIN
	DECLARE @sql_deliverypath VARCHAR(MAX)
	SET @sql_deliverypath ='SELECT dp.path_code,
								   dp.path_name,
								   dp.delivery_means,
								   dp.commodity,
								   dp.isactive,
								   dp.meter_from,
								   dp.meter_to,
								   dp.rateSchedule,
								   dp.counterParty,
								   dp.[CONTRACT],
								   dp.location_id,
								   dp.from_location,
								   dp.to_location,
								   dp.groupPath,
								   dp.shipping_counterparty,
								   dp.receiving_counterparty,
								   dp.formula_from,
								   spcd.curve_id [formula_from_name],
								   dp.formula_to,
								   spcd1.curve_id [formula_to_name],
								   CASE 
										WHEN sml1.location_name IS NULL THEN ''''
										ELSE sml1.location_name + '' - > ''
								   END + sml_from.location_name 
								   [Minor Location From],
								   CASE 
										WHEN sml2.location_name IS NULL THEN ''''
										ELSE sml2.location_name + '' - > ''
								   END + sml_to.location_name [Minor Location From],
								   mi_from.recorderid,
								   mi_to.recorderid,
								   dp.loss_factor,
								   dp.fuel_factor,
   								   dp.imbalance_from,
   								   dp.imbalance_to,
   								   cg.contract_name
							FROM   dbo.delivery_path dp
							LEFT JOIN source_minor_location sml_from
								ON sml_from.source_minor_location_id = dp.from_location
							LEFT JOIN source_major_location sml1 
								ON sml1.source_major_location_id = sml_from.source_major_location_id
							LEFT JOIN source_minor_location sml_to 
								ON sml_to.source_minor_location_id = dp.to_location
							LEFT JOIN source_major_location sml2 
								ON sml2.source_major_location_id = sml_to.source_major_location_id
							LEFT JOIN meter_id mi_from 
								ON mi_from.meter_id = dp.meter_from
							LEFT JOIN meter_id mi_to 
								ON mi_to.meter_id = dp.meter_to
							LEFT JOIN source_price_curve_def spcd
								ON spcd.source_curve_def_id = dp.formula_from
							LEFT JOIN source_price_curve_def spcd1 
								ON spcd1.source_curve_def_id = dp.formula_to
							LEFT JOIN contract_group cg 
								ON cg.contract_id = dp.CONTRACT
							WHERE path_id IN (' + @path_id2 + ')'
							  
	EXEC(@sql_deliverypath)
	--print(@sql_deliverypath)
END

ELSE IF @flag = 'u'
BEGIN
		IF EXISTS(SELECT 1 FROM dbo.delivery_path WHERE path_code = @path_code AND path_id <> @path_id)
		BEGIN
			EXEC spa_ErrorHandler -1,
				'Data already exists in the database.',
				'spa_delivery_path',
				'Error',
				'',
				''
		RETURN
		END
			
		--SELECT @formula_id_from [From],
		--       @formula_id_from [TO]
		
		UPDATE dbo.delivery_path
		SET    path_code = @path_code,
		       path_name = @path_name,
		       delivery_means = @delivery_means,
		       commodity = @commodity,
		       isactive = @deliveryIsActive,
		       meter_from = @fromMeter,
		       meter_to = @toMeter,
		       rateSchedule = @rateSchedule,
		       counterParty = @counterParty,
		       [CONTRACT] = @CONTRACT,
		       location_id = @location_id,
		       from_location = @from_location,
		       to_location = @to_location,
		       groupPath = @groupPath,
		       shipping_counterparty = @shipping,
		       receiving_counterparty = @receiving,
		       formula_from = @formula_id_from,
		       formula_to = @formula_id_to,
		       loss_factor = @loss_factor,
		       fuel_factor = @fuel_factor,
		       imbalance_from = @imbalance_from,
		       imbalance_to = @imbalance_to
		WHERE  path_id = @path_id 			
--	SET @path_id=SCOPE_IDENTITY()
	
		IF @@ERROR <> 0
		BEGIN
			EXEC spa_ErrorHandler @@ERROR,
				 'Updated Delivery Path.',
				 'spa_delivery_path',
				 'DB Error',
				 'Updated Delivery Path failed.',
				 ''
		    
			RETURN
		END
		ELSE
		BEGIN
			EXEC spa_ErrorHandler 0,
				 'Updated Delivery Path.',
				 'spa_delivery_path',
				 'Success',
				 'Successfully Updated Delivery Path .',
				 @path_id
		END	
END
	
ELSE IF @flag = 'c'
BEGIN
	SELECT source_counterparty_id,
	       counterparty_name
	FROM   source_counterparty
END

ELSE IF @flag = 'p'
BEGIN
	SELECT source_counterparty_id,
	       counterparty_name
	FROM  source_counterparty sco 
	INNER JOIN  contract_group cg 
		ON sco.source_counterparty_id = cg.pipeline
	WHERE cg.contract_id = @contract 
	
END

ELSE IF @flag = 'j'
BEGIN
		SELECT @sql = CAST('' AS VARCHAR(MAX)) + 'SELECT 
						dp.path_id "PathID",
						dp.path_code "PathCode",
						dp.path_name "PathName",
						sdv.code "DeliveryMeans",
						sml.Location_Name  "FromLocation",
						sml1.Location_Name  "ToLocation",
						mi.recorderid "FromMeter",
						mi1.recorderid "ToMeter",
						sc.commodity_name "Commodity",
						scp.counterparty_name "Counterparty",
						dp.loss_factor [Loss Factor],
						dp.fuel_factor [Fuel Factor]		
					FROM dbo.delivery_path dp
					LEFT JOIN source_counterparty scp 
						ON scp.source_counterparty_id = dp.counterParty
					LEFT JOIN source_minor_location_meter smlm	
						ON smlm.meter_id = dp.meter_from	
					LEFT JOIN source_minor_location_meter smlm1	
						ON smlm1.meter_id = dp.meter_to
					LEFT JOIN source_minor_location sml 
						ON smlm.source_minor_location_id = sml.source_minor_location_id
					LEFT JOIN source_minor_location sml1 
						ON smlm1.source_minor_location_id = sml1.source_minor_location_id
					LEFT JOIN meter_id mi 
						ON mi.meter_id = smlm.meter_id
					LEFT JOIN meter_id mi1 
						ON mi1.meter_id = smlm1.meter_id
					LEFT JOIN  dbo.static_data_value sdv 
						ON sdv.value_id = dp.delivery_means
					LEFT JOIN source_commodity sc 
						ON sc.source_commodity_id = dp.commodity
					LEFT JOIN location_loss_factor llf 
						ON llf.from_location_id = dp.from_location 
						AND llf.to_location_id = dp.to_location	
					LEFT JOIN 
					(
						SELECT dpd_min.* 
						FROM delivery_path_detail dpd_min
						INNER JOIN 
							(	SELECT MIN(delivery_path_detail_id) delivery_path_detail_id
								FROM delivery_path_detail dpd_group
								GROUP BY dpd_group.Path_id
							) p_min 
						ON dpd_min.delivery_path_detail_id = p_min.delivery_path_detail_id
					)dpd_from 
						ON dp.path_id = dpd_from.path_id 
						AND ISNULL(dp.groupPath, ''n'') = ''y''
					LEFT JOIN delivery_path dp_from 
						ON dpd_from.path_name = dp_from.path_id 
					LEFT JOIN 
					(
						SELECT dpd_max.* 
						FROM delivery_path_detail dpd_max
						INNER JOIN 
							(SELECT MAX(delivery_path_detail_id) delivery_path_detail_id
								FROM delivery_path_detail dpd_group
								GROUP BY dpd_group.Path_id
							) p_max 
							ON dpd_max.delivery_path_detail_id = p_max.delivery_path_detail_id
					)dpd_to 
						ON dp.path_id = dpd_to.Path_id 
						AND ISNULL(dp.groupPath, ''n'') = ''y''
					LEFT JOIN delivery_path dp_to 
						ON dpd_to.Path_name = dp_to.path_id 									
					WHERE dp.CONTRACT=' + CAST(@contract AS VARCHAR (100))
		IF @from_location IS NOT NULL
		BEGIN
		    SELECT @sql = @sql + ' AND (dp_from.from_location = ' + CAST(@from_location AS VARCHAR) + ' OR dp.from_location = ' + CAST(@from_location AS VARCHAR)+ ')'
		END	
		
		IF @to_location IS NOT NULL
		    SELECT @sql = @sql + ' AND (dp_to.to_location = ' + CAST(@to_location AS VARCHAR) + ' OR dp.to_location = ' + CAST(@to_location AS VARCHAR) + ')'
		
		IF @commodity IS NOT NULL
		    SELECT @sql = @sql + ' AND dp.commodity	= ' + CAST(@commodity AS VARCHAR)
		
		IF @fromMeter IS NOT NULL
		    SELECT @sql = @sql + ' AND dp.meter_from = ' + CAST(@fromMeter AS VARCHAR)
		
		IF @toMeter IS NOT NULL
		    SELECT @sql = @sql + ' AND dp.meter_to = ' + CAST(@toMeter AS VARCHAR)
		
		IF @location_id IS NOT NULL
		    SELECT @sql = @sql + ' AND (sml.source_minor_location_id = ' + CAST(@location_id AS VARCHAR) + ' OR sml1.source_minor_location_id = ' + CAST(@location_id AS VARCHAR) + ')'
		
		IF @deliveryIsActive IS NOT NULL
		    SELECT @sql = @sql + ' AND dp.isactive = ''' + CAST(@deliveryIsActive AS VARCHAR) + ''''
		
		EXEC(@sql)
END

ELSE IF @flag = 'r' --'r' Called in deal level scheduling to change the related from_location, to_location, avg loss factor and contract of specified path.
BEGIN
	SELECT --dpd.delivery_path_detail_id
		 dp.path_id
		, MAX(ISNULL(dgp_first.from_location, dp.from_location)) from_location
		, MAX(ISNULL(dgp_last.to_location, dp.to_location)) to_location
		, MAX(ISNULL(dgp_first.[contract], dp.[contract])) [contract] 
		, ROUND(AVG(COALESCE(dp_child_path.loss_factor, dp.loss_factor, 0)), 5) loss_factor
	FROM delivery_path dp
	LEFT JOIN delivery_path_detail dpd 
		ON dpd.path_id = dp.path_id 
	LEFT JOIN delivery_path dp_child_path 
		ON dp_child_path.path_id = ISNULL(dpd.Path_name, dp.path_id)
	OUTER APPLY (
		SELECT TOP 1 dp_inner.from_location
				, dp_inner.[contract]
		FROM delivery_path_detail dpd_inner
		INNER JOIN delivery_path dp_inner 
			ON dp_inner.Path_id = dpd_inner.path_name
		WHERE dpd_inner.path_id = dp.path_id
		ORDER BY dpd_inner.delivery_path_detail_id ASC
	) dgp_first 
	OUTER APPLY (
		SELECT TOP 1 dp_inner.to_location
		FROM delivery_path_detail dpd_inner
		INNER JOIN delivery_path dp_inner 
			ON dp_inner.Path_id = dpd_inner.path_name
		WHERE dpd_inner.path_id = dp.path_id
		ORDER BY dpd_inner.delivery_path_detail_id DESC
	) dgp_last
	WHERE dp.Path_id = @path_id
	GROUP BY dp.path_id
END

ELSE IF @flag = 'n'
BEGIN
	SELECT @sql = CAST('' AS VARCHAR(MAX)) + 
	'SELECT 
		dp.path_id [Path ID],
		dp.path_code [Path Code]
	FROM dbo.delivery_path dp
	LEFT JOIN source_counterparty scp 
		ON scp.source_counterparty_id = dp.counterparty
	LEFT JOIN source_minor_location_meter smlm	
		ON smlm.source_minor_location_id = dp.from_location 
		AND smlm.meter_id = dp.meter_from	
	LEFT JOIN source_minor_location_meter smlm1	
		ON smlm1.source_minor_location_id = dp.to_location 
		AND smlm1.meter_id = dp.meter_to
	LEFT JOIN source_minor_location sml 
		ON smlm.source_minor_location_id = sml.source_minor_location_id
	LEFT JOIN source_minor_location sml1 
		ON smlm1.source_minor_location_id= sml1.source_minor_location_id
	LEFT JOIN meter_id mi 
		ON mi.meter_id=smlm.meter_id
	LEFT JOIN meter_id mi1 
		ON mi1.meter_id=smlm1.meter_id
	LEFT JOIN  dbo.static_data_value sdv 
		ON sdv.value_id = dp.delivery_means
	LEFT JOIN source_commodity sc 
		ON sc.source_commodity_id = dp.commodity
	LEFT JOIN location_loss_factor llf 
		ON llf.from_location_id = dp.from_location 
		AND llf.to_location_id = dp.to_location	
	LEFT JOIN 
	(
		SELECT dpd_min.* 
		FROM delivery_path_detail dpd_min
		INNER JOIN 
			(SELECT MIN(delivery_path_detail_id) delivery_path_detail_id
				FROM delivery_path_detail dpd_group
				GROUP BY dpd_group.Path_id
			) p_min 
		ON dpd_min.delivery_path_detail_id = p_min.delivery_path_detail_id
	) dpd_from 
		ON dp.path_id = dpd_from.path_id 
		AND ISNULL(dp.groupPath, ''n'') = ''y''
	LEFT JOIN delivery_path dp_from 
		ON dpd_from.path_name = dp_from.path_id 
	LEFT JOIN 
	(
		SELECT dpd_max.* 
		FROM delivery_path_detail dpd_max
		INNER JOIN 
			(	SELECT MAX(delivery_path_detail_id) delivery_path_detail_id
				FROM delivery_path_detail dpd_group
				GROUP BY dpd_group.Path_id
			) p_max 
		ON dpd_max.delivery_path_detail_id = p_max.delivery_path_detail_id
	) dpd_to 
		ON dp.path_id = dpd_to.Path_id 
		AND ISNULL(dp.groupPath, ''n'') = ''y''
	LEFT JOIN delivery_path dp_to 
		ON dpd_to.Path_name = dp_to.path_id 
									
	WHERE 1=1 '

	IF @from_location IS NOT NULL
	BEGIN
		SELECT @sql = @sql + ' AND (dp_from.from_location = ' + CAST(@from_location AS VARCHAR) + ' OR dp.from_location = ' + CAST(@from_location AS VARCHAR)+ ')'
	END	
		
	IF @to_location IS NOT NULL
		SELECT @sql = @sql + ' AND (dp_to.to_location = ' + CAST(@to_location AS VARCHAR) + ' OR dp.to_location = ' + CAST(@to_location AS VARCHAR) + ')'
		
	IF @commodity IS NOT NULL
		SELECT @sql = @sql + ' AND dp.commodity	= ' + CAST(@commodity AS VARCHAR)
		
	IF @fromMeter IS NOT NULL
	BEGIN
		SELECT @sql = @sql + ' AND mi.recorderid = ' + CAST(@fromMeter AS VARCHAR)
	END

	IF @toMeter IS NOT NULL
	BEGIN
		SELECT @sql = @sql + ' AND mi1.recorderid = ' + CAST(@toMeter AS VARCHAR)
	END

	IF @location_id IS NOT NULL
		SELECT @sql = @sql + ' AND (sml.source_minor_location_id = ' + CAST(@location_id AS VARCHAR) + ' OR sml1.source_minor_location_id = ' + CAST(@location_id AS VARCHAR) + ')'
		
	IF @deliveryIsActive IS NOT NULL
		SELECT @sql = @sql + ' AND dp.isactive = ''' + CAST(@deliveryIsActive AS VARCHAR) + ''''
		
	IF @counterParty IS NOT NULL
	BEGIN
		SELECT @sql = @sql + ' AND scp.source_counterparty_id = ' + CAST(@counterparty AS VARCHAR)
	END	
		
	IF @loss_factor IS NOT NULL
	BEGIN
		SELECT @sql = @sql + ' AND dp.loss_factor = ' + CAST(@loss_factor AS VARCHAR)
	END
		
	IF @fuel_factor IS NOT NULL
	BEGIN
		SELECT @sql = @sql + ' AND dp.fuel_factor = ' + CAST(@fuel_factor AS VARCHAR)
	END
		
	IF @imbalance_from IS NOT NULL
	BEGIN
		SELECT @sql = @sql + ' AND dp.imbalance_from = ' + CAST(@imbalance_from AS VARCHAR)
	END
		
	IF @imbalance_to IS NOT NULL
	BEGIN
		SELECT @sql = @sql + ' AND dp.imbalance_to = ' + CAST(@imbalance_to AS VARCHAR)
	END

	EXEC(@sql)
END

ELSE IF @flag = 'w'
BEGIN
	SELECT path_id, path_code 
	FROM delivery_path
	WHERE isactive = 'y' 
		AND path_code IS NOT NULL
	ORDER BY path_code
END

ELSE IF @flag = 'z' --get loss factor of path
BEGIN
	SELECT ISNULL(( 
					SELECT dbo.FNARemoveTrailingZeroes(loss_factor) 
					FROM path_loss_shrinkage 
					WHERE path_id = @path_id), 0
				  ) AS [loss]
END