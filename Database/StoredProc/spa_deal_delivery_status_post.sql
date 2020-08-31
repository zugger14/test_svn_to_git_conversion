IF OBJECT_ID('dbo.spa_deal_delivery_status_post', 'p') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.spa_deal_delivery_status_post
END
GO

CREATE PROCEDURE dbo.spa_deal_delivery_status_post
	@flag CHAR(1),
	@xml VARCHAR(MAX) = NULL,
	@deal_transport_id int = NULL

AS

DECLARE @idoc INT

EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

SELECT [deal_transfer_id],
	   [flow_date],
	   [volume],
	   [uom],
	   [as_of_date],
	   [deal_detail_id],
	   [reciept_delivery],
	   [location],
	   [meter],
	   [pipeline],
	   [contract],
	   [delivery_status_id]
	INTO #delivery_status
FROM   OPENXML(@idoc, '/Root/PSRecordset', 1)
   WITH (
       deal_transfer_id INT '@edit_grid1',
       flow_date DATETIME '@edit_grid2',
       volume INT '@edit_grid3',
       uom VARCHAR(100) '@edit_grid4',
       as_of_date DATETIME '@edit_grid5',
       deal_detail_id INT '@edit_grid6',
       reciept_delivery VARCHAR(100) '@edit_grid7',
       location VARCHAR(100) '@edit_grid8',
       meter VARCHAR(100) '@edit_grid9',
       pipeline VARCHAR(100) '@edit_grid10',
       [contract] VARCHAR(100) '@edit_grid11',
       [delivery_status_id] VARCHAR(100) '@edit_grid14'
       )

     
IF @flag = 'i'
BEGIN       
	BEGIN TRY
		BEGIN TRAN
	    INSERT INTO delivery_status(deal_transport_id
					, estimated_delivery_date
					, status_timestamp
					, delivered_volume
					, deal_transport_detail_id
					, uom_id
					, source_deal_detail_id
					, location_id
					, meter_id
					, pipeline_id
					, contract_id
					, receive_delivery,delivery_status)  
		SELECT	DISTINCT
				dth.deal_transport_id,
				ds.flow_date,
				ds.as_of_date,
				ds.volume,
				dtd.deal_transport_deatail_id, 
				ds.uom,
				ds.deal_detail_id,
				sml.source_minor_location_id,
				mi.meter_id,
				ds.pipeline,
				ds.[contract],
				CASE WHEN ds.reciept_delivery = 'Delivery' THEN 'd' ELSE 'r' END reciept_delivery,1650
		FROM #delivery_status ds
		INNER JOIN source_deal_detail sdd on sdd.source_deal_detail_id = ds.deal_detail_id
		INNER JOIN deal_transport_header dth ON sdd.source_deal_header_id = dth.source_deal_header_id
		INNER JOIN deal_transport_detail dtd ON dtd.deal_transport_id = dth.deal_transport_id
		INNER JOIN source_minor_location sml on sml.Location_Name = ds.location
		INNER JOIN meter_id mi on mi.recorderid = ds.meter
			AND dtd.source_deal_detail_id_from =  sdd.source_deal_detail_id
			AND dth.deal_transport_id = @deal_transport_id

		COMMIT TRAN
	
		EXEC spa_ErrorHandler 0,
			'delivery status',
			'spa_deal_delivery_status_post',
			'Success',
			'Data Successfully inserted.',
			''
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		EXEC spa_ErrorHandler -1,
			'delivery status',
			'spa_deal_delivery_status_post',
			'error',
			'Data insertion failed.',
			''
	END CATCH			
END 
ELSE IF @flag = 'u' 
BEGIN
	BEGIN TRY
		BEGIN TRAN
		 
		UPDATE del_stat
		SET	
		--del_stat.deal_transport_id = dth.deal_transport_id,
		--del_stat.estimated_delivery_date = ds.flow_date,
		--del_stat.status_timestamp = ds.as_of_date,
		del_stat.delivered_volume = ds.volume
		--del_stat.deal_transport_detail_id = dtd.deal_transport_deatail_id, 
		--del_stat.uom_id = ds.uom,
		--del_stat.source_deal_detail_id = ds.deal_detail_id,
		--del_stat.location_id = sml.source_minor_location_id,
		--del_stat.meter_id = mi.meter_id,
		--del_stat.pipeline_id = ds.pipeline,
		--del_stat.contract_id = ds.[contract],
		--del_stat.receive_delivery = CASE WHEN ds.reciept_delivery = 'Delivery' THEN 'd' ELSE 'r' END
		FROM delivery_status del_stat
		INNER JOIN #delivery_status ds ON  del_stat.source_deal_detail_id = ds.deal_detail_id 
		AND del_stat.status_timestamp = ds.as_of_date
		--	AND del_stat.id = ds.[delivery_status_id]
		--	INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = ds.deal_detail_id
		--	INNER JOIN deal_transport_header dth ON sdd.source_deal_header_id = dth.source_deal_header_id
		--	INNER JOIN deal_transport_detail dtd ON dtd.deal_transport_id = dth.deal_transport_id
		--	LEFT JOIN source_minor_location sml on sml.Location_Name = ds.location
		--	INNER JOIN meter_id mi on mi.recorderid = ds.meter
		--		AND dtd.source_deal_detail_id_from =  sdd.source_deal_detail_id
		--		AND dth.deal_transport_id = @deal_transport_id

		--select @@ROWCOUNT
		--return

	IF @@ROWCOUNT < 1
		INSERT INTO  delivery_status(  
									  deal_transport_id,
									  estimated_delivery_date,
									  status_timestamp,
									  delivered_volume,
									  deal_transport_detail_id,
									  uom_id,
									  source_deal_detail_id,
									  location_id,
									  meter_id,
									  pipeline_id,
									  contract_id,
									  receive_delivery,delivery_status
									 )
		SELECT	dth.deal_transport_id,  
				ds.flow_date,  
				ds.as_of_date,  
				ds.volume,   
				dtd.deal_transport_deatail_id,  
				ds.uom,  
				ds.deal_detail_id,  
				sml.source_minor_location_id, 
				mi.meter_id,
				ds.pipeline,  
				ds.[contract],  
				CASE WHEN ds.reciept_delivery = 'Delivery' THEN 'd' ELSE 'r' END reciept_delivery,1650
		FROM #delivery_status ds 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = ds.deal_detail_id  
		INNER JOIN deal_transport_header dth ON sdd.source_deal_header_id = dth.source_deal_header_id  
		INNER JOIN deal_transport_detail dtd ON dtd.deal_transport_id = dth.deal_transport_id  
		INNER JOIN source_minor_location sml on sml.Location_Name = ds.location
		INNER JOIN meter_id mi on mi.recorderid = ds.meter
			AND dtd.source_deal_detail_id_from =  sdd.source_deal_detail_id  
			AND dth.deal_transport_id = @deal_transport_id 
		  
 
		COMMIT TRAN
	
		EXEC spa_ErrorHandler 0,
			'delivery status',
			'spa_deal_delivery_status_post',
			'Success',
			'Data Successfully updated.',
			''
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		
		EXEC spa_ErrorHandler -1,
			'delivery status',
			'spa_deal_delivery_status_post',
			'error',
			'Data updated failed.',
			''
	END CATCH			
END

