IF OBJECT_ID('dbo.spa_deal_delivery_status', 'p') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.spa_deal_delivery_status
END
GO

--EXEC spa_deal_delivery_status 's', 76, 'b', NULL, '2013-05-26'

CREATE PROCEDURE dbo.spa_deal_delivery_status
	@flag CHAR(1),
	@deal_transport_id INT,
	@recieve_delivery CHAR(1) = NULL,
	@flow_date_from DATETIME = NULL,
	@effective_date DATETIME = NULL,
	@flow_date_to DATETIME = NULL,
	@pipeline INT = NULL,
	@contract INT = NULL 

AS
DECLARE @sql VARCHAR(MAX)

IF @flag = 's'
BEGIN
	SET @sql = '
				SELECT source_deal_header_id  
					   , dbo.FNADateFormat(MAX([Flow Date])) [Flow Date]  
					   , MAX([Volume]) [Volume]  
					   , MAX([UOM]) [UOM]  
					   , MAX([As Of Date]) [As Of Date]  
					   , MAX([Deal Detail ID]) [Deal Detail ID]  
					   , CASE WHEN [Receipt/Delivery] = ''d'' THEN ''Delivery'' ELSE ''Reciept'' END  [Receipt/Delivery]
					   , MAX([Location]) [Location]  
					   , MAX([Meter]) [Meter]  
					   , MAX([Pipe Line]) [Pipe Line]  
					   , MAX([Contract]) [Contract]  
					   , MAX(Location_Name) Location_Name  
					   , MAX(recorderid) recorderid  
					   , MAX(deliver_status_id) deliver_status_id  
				FROM(  
						SELECT	sdh.source_deal_header_id ,	       
								ISNULL(ds.estimated_delivery_date,  dbo.FNADateFormat(sdd.term_start)) AS [Flow Date],
								ISNULL(ds.delivered_volume, deal_volume) AS [Volume],	       
								ISNULL(ds.uom_id, su.source_uom_id) AS [UOM],
								dbo.FNADateFormat(isnull(ds.status_timestamp,GETDATE())) AS [As Of Date],    
								ISNULL(ds.source_deal_detail_id, sdd.source_deal_detail_id) AS [Deal Detail ID],
								ISNULL(ds.receive_delivery, CASE WHEN dp.imbalance_from = ''n'' THEN ''Reciept'' ELSE ''Delivery'' END) AS [Receipt/Delivery],								ISNULL(ds.location_id, sml.source_minor_location_id) AS [Location],
								ISNULL(ds.meter_id, mi.meter_id) AS [Meter],
								ISNULL(ds.pipeline_id, sc.source_counterparty_id) AS [Pipe Line],
								ISNULL(ds.contract_id, cg.contract_id) AS [Contract],
								sml.Location_Name Location_Name,
								mi.recorderid,
								ds.ID  as deliver_status_id,
								sc.source_counterparty_id,
								cg.contract_id   
						FROM   source_deal_header sdh
						INNER JOIN source_deal_detail sdd ON  sdd.source_deal_header_id = sdh.source_deal_header_id
						INNER JOIN deal_transport_header dth ON dth.source_deal_header_id = sdh.source_deal_header_id     
						INNER JOIN contract_group cg ON  cg.contract_id = sdh.contract_id
						INNER JOIN source_counterparty sc ON  sc.source_counterparty_id = cg.pipeline
						INNER JOIN source_uom su ON su.source_uom_id = sdd.deal_volume_uom_id
						INNER JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
						LEFT JOIN delivery_path dp ON dp.[contract] = sdh.contract_id    
							AND sdh.counterparty_id = dp.counterParty
							AND CASE dp.imbalance_from
									WHEN ''y'' THEN from_location
									WHEN ''n'' THEN to_location
								END = sdd.location_id
						LEFT JOIN meter_id mi ON  mi.meter_id = sdd.meter_id
						OUTER APPLY (  
							SELECT TOP(1) * FROM delivery_status WHERE source_deal_detail_id = sdd.source_deal_detail_id    
							ORDER BY status_timestamp DESC  
						) ds  
						WHERE ds.ID IS NOT NULL --dth.deal_transport_id = ' + CAST(@deal_transport_id AS VARCHAR(100)) + ' 
					) a  WHERE 1 = 1 '

	IF @recieve_delivery <> 'b'
		SET @sql = @sql + ' AND a.[Receipt/Delivery] = ''' + @recieve_delivery + ''''
	
	IF @pipeline IS NOT NULL 
		SET @sql = @sql + ' AND a.source_counterparty_id = ' + CAST(@pipeline AS VARCHAR(10)) 
	
	IF @contract IS NOT NULL 
		SET @sql = @sql + ' AND a.contract_id = ' + CAST(@contract AS VARCHAR(10)) 
	
	IF @effective_date IS NOT NULL
		SET @sql = @sql + ' AND a.[As Of Date] <= ''' + CAST(@effective_date AS VARCHAR(12)) + ''''
	
	IF @flow_date_from IS NOT NULL
		SET @sql = @sql + ' AND a.[Flow Date] >= ''' + CAST(@flow_date_from AS VARCHAR(12)) + ''''
	
	IF @flow_date_from IS NOT NULL
		SET @sql = @sql + ' AND a.[Flow Date] <= ''' + CAST(@flow_date_to AS VARCHAR(12)) + ''''
	
	SET @sql = @sql + ' GROUP BY source_deal_header_id, [Receipt/Delivery] ORDER BY deliver_status_id'			  
	EXEC spa_print @sql
	EXEC(@sql)				
END
ELSE IF @flag = 'j'
BEGIN
	SELECT DISTINCT source_uom_id,
	       uom_name
	FROM   source_uom su
	INNER JOIN source_deal_detail sdd ON  sdd.deal_volume_uom_id = su.source_uom_id 
END
ELSE IF @flag = 'k'
BEGIN
	SELECT source_counterparty_id, counterparty_name FROM source_counterparty sc
END
ELSE IF @flag  = 'c'-- check mode
BEGIN
	DECLARE @mode char(1)
	IF EXISTS (SELECT 1 FROM source_deal_detail sdd
	INNER JOIN delivery_status ds on ds.source_deal_detail_id = sdd.source_deal_detail_id
	WHERE ds.deal_transport_id = @deal_transport_id)
		SET @mode = 'u'
	ELSE 
		SET @mode = 'i'
		
	SELECT @mode 
END

GO



