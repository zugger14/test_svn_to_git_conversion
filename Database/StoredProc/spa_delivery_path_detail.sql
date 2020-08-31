/****** Object:  StoredProcedure [dbo].[spa_delivery_path_detail]    Script Date: 09/16/2009 15:44:41 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_delivery_path_detail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_delivery_path_detail]
GO
CREATE PROC [dbo].[spa_delivery_path_detail]
	@flag char(1),
	@delivery_path_detail_id INT =NULL,
	@path_id INT=NULL ,
	@path_name VARCHAR(50)=NULL,
	@From_meter INT=NULL,
	@To_meter INT=NULL
AS
DECLARE @sql VARCHAR(max)
IF @flag ='s'
	BEGIN			
		SELECT DISTINCT dpd.delivery_path_detail_id [Path Detail ID]
			,dpd.path_id [Path ID]
			,dpd.path_name [Path_Name]
			,[Path] = '<span style=cursor:hand onClick=createWindow(''UpdateDeliveryPath'',false,true,' +
					  '''mode=u&id='+CAST(dpd.path_name as VARCHAR(50)) + ''')><font color=#0000ff><u>'	+ 
					  CAST(dp1.path_code as VARCHAR(50)) + '</u></font></span>'
			--,dp1.path_code [Path]
			,sml.Location_Name [From Location]
			,sml2.Location_Name [To Location]
			,mi.recorderid [From Meter]
			,mi1.recorderid [To Meter]
			,sc.counterparty_name [Counterparty]
			,cg.contract_name [Contract]
			,sdv.Code [Rate Schedule]			
		FROM delivery_path_detail dpd
			INNER JOIN delivery_path dp ON dp.path_id = dpd.path_name
			LEFT JOIN delivery_path dp1 ON dp1.path_id = dpd.path_name
			LEFT JOIN source_minor_location_meter smlm1 ON smlm1.meter_id = dp1.meter_from
			LEFT JOIN source_minor_location_meter smlm2 ON smlm2.meter_id = dp1.meter_to					
			LEFT JOIN source_counterparty sc ON sc.source_counterparty_id=dp.counterParty
			LEFT JOIN contract_group cg ON cg.contract_id = dp.contract
			LEFT JOIN static_data_value sdv ON dp.rateSchedule =  sdv.value_id 
			LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = dp.from_location 
			LEFT JOIN source_minor_location sml2 ON sml2.source_minor_location_id = dp1.to_location 
			LEFT JOIN meter_id mi ON mi.meter_id=smlm1.meter_id
			LEFT JOIN meter_id mi1 ON mi.meter_id=smlm2.meter_id
		WHERE dpd.path_id = @path_id
	END

ELSE IF @flag ='a'
BEGIN
	SELECT path_id,path_name,From_meter,To_meter 
	FROM delivery_path_detail
		WHERE 
		delivery_path_detail_id=@delivery_path_detail_id
END

ELSE IF @flag='i'
BEGIN
	insert into delivery_path_detail(path_id,path_name,From_meter,To_meter)
	values(@path_id,@path_name,@From_meter,@To_meter)

If @@ERROR <> 0
	BEGIN 
		Exec spa_ErrorHandler @@ERROR, "Delivery Path Detail Insert.", 
				"spa_delivery_path_detail", "DB Error", 
				"Delivery Path Detail Insert failed.", ''
		RETURN
	END

		ELSE Exec spa_ErrorHandler 0, 'Delivery Path Detail Insert.', 
				'spa_delivery_path_detail', 'Success', 
				'Successfully inserted Delivery Path Detail Insert.', ''
	
END

ELSE IF @flag ='u'
BEGIN
	UPDATE delivery_path_detail
	SET
	path_id = @path_id,
	path_name= @path_name,
	From_meter = @From_meter,
	To_meter =@To_meter
	where 
	delivery_path_detail_id = @delivery_path_detail_id

If @@ERROR <> 0
	BEGIN 
		Exec spa_ErrorHandler @@ERROR, "Updated Delivery Path Detail..", 
				"spa_delivery_path_detail", "DB Error", 
				"Updated Delivery Path Detail failed.", ''
		RETURN
	END

		ELSE Exec spa_ErrorHandler 0, 'Updated Delivery Path Detail.', 
				'spa_delivery_path_detail', 'Success', 
				'Successfully Updated Delivery Path Detail.', ''
END

ELSE IF @flag ='d'
BEGIN
	DELETE delivery_path_detail 
	WHERE 
		delivery_path_detail_id = @delivery_path_detail_id
	
	If @@ERROR <> 0
	BEGIN 
		Exec spa_ErrorHandler @@ERROR, "Delete Delivery Path Detail.", 
				"spa_delivery_path_detail", "DB Error", 
				"Delete Delivery Path Detail.", ''
		RETURN
	END

		ELSE Exec spa_ErrorHandler 0, 'Delete Delivery Path Detail.', 
				'spa_delivery_path_detail', 'Success', 
				'Successfully Delete Delivery Path Detail.', ''

END

--EXEC spa_delivery_path_detail 's',NULL,NULL,NULL
--EXEC spa_delivery_path_detail 'i',NULL,21,'Path test',22,33
--EXEC spa_delivery_path_detail 'a',1
--EXEC spa_delivery_path_detail 'd',1