IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_delivery_status]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_delivery_status]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

--exec spa_delivery_status 's'
--exec spa_delivery_status 's',NULL,6
CREATE procedure [dbo].[spa_delivery_status]
	@flag char(1),
	@id int=NULL,
	@deal_transport_id int=NULL,
	@delivery_status int=NULL,
	@status_timestamp datetime=NULL,
	@current_facility int=NULL,
    @estimated_delivery_date datetime=NULL,
    @estimated_delivery_time varchar(100)=null,
    @memo1 varchar(100)=null,
	@memo2 varchar(100)=null,
	@scheduled_volume float=null,
	@delivered_volume float=null,
	@deal_transport_detail_id INT=NULL

as
DECLARE @sql VARCHAR(MAX)
BEGIN
	
	
IF @flag = 's'
BEGIN
	set @sql = 'SELECT ds.id [ID],
	                   ds.deal_transport_id [Deal Transport],
	                   CASE 
	                        WHEN sdd.leg = 1 THEN ''Delivery''
	                        ELSE ''Receipt''
	                   END AS [Type],
	                   sdv.code [Status],
	                   status_timestamp [Status TimeStamp],
	                   sml.location_name [Current Facility],
	                   mi.recorderid [Meter],
	                   memo1 [Memo1],
	                   memo2 [Memo2],
	                   delivered_volume [Volume],
	                   dbo.FNADateFormat(estimated_delivery_date) 
	                   [Estimated Delivery Date],
	                   estimated_delivery_time [Estimated Delivery Time]
	            FROM   delivery_status ds
	                   LEFT JOIN static_data_value sdv ON  sdv.value_id = ds.delivery_status
	                   LEFT JOIN source_minor_location sml ON  sml.source_minor_location_ID = ds.current_facility
	                   LEFT JOIN deal_transport_detail dtd ON  dtd.deal_transport_deatail_id = ds.deal_transport_detail_id
	                   LEFT JOIN source_deal_detail sdd ON  dtd.source_deal_detail_id_to = sdd.source_deal_detail_id
	                   LEFT JOIN source_minor_location_meter smlm ON  smlm.meter_id = sdd.meter_id
	                   LEFT JOIN meter_id mi ON  smlm.meter_id = mi.meter_id
	            WHERE  1 = 1 '

IF @deal_transport_id IS NOT NULL
    SET @sql = @sql + ' and ds.deal_transport_id=' + CAST(@deal_transport_id AS VARCHAR) 

IF @deal_transport_detail_id IS NOT NULL
    SET @sql = @sql + ' and ds.deal_transport_detail_id=' + CAST(@deal_transport_detail_id AS VARCHAR)

SET @sql = @sql + ' ORDER BY status_timestamp desc'

EXEC spa_print @sql
EXEC (@sql)
END
	

IF @flag = 'a'
BEGIN
	SELECT id,
	       deal_transport_id,
	       delivery_status,
	       status_timestamp,
	       current_facility,
	       dbo.FNADateFormat(estimated_delivery_date),
	       estimated_delivery_time,
	       memo1,
	       memo2,
	       scheduled_volume,
	       delivered_volume,
	       create_user,
		   create_ts,
		   update_user,    
		   update_ts
	FROM   delivery_status
	WHERE  id = @id
END
	


IF @flag='i'
BEGIN

insert into delivery_status(deal_transport_id,delivery_status,status_timestamp,current_facility,estimated_delivery_date,estimated_delivery_time,memo1,memo2,scheduled_volume,delivered_volume,deal_transport_detail_id)
    values(@deal_transport_id,@delivery_status,getdate(),@current_facility,@estimated_delivery_date,@estimated_delivery_time,@memo1,@memo2,@scheduled_volume,@delivered_volume,@deal_transport_detail_id)	


	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Delivery Status', 
				'spa_Delivery_Status', 'DB Error', 
			'Error Inserting Values', ''
	else
		Exec spa_ErrorHandler 0, 'Delivery Status', 
				'spa_Delivery_Status', 'Success', 
				'Delivery Status values successfully Inserted.', ''
END

IF @flag='u'
BEGIN
	update delivery_status
	set
		deal_transport_id=@deal_transport_id,
		delivery_status=@delivery_status,
		status_timestamp=getdate(),
		current_facility=@current_facility,
		estimated_delivery_date=@estimated_delivery_date,
		estimated_delivery_time=@estimated_delivery_time,
		memo1=@memo1,
		memo2=@memo2,
		scheduled_volume=@scheduled_volume,
		delivered_volume=@delivered_volume
		--deal_transport_detail_id=@deal_transport_detail_id
	where 
		id=@id

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Delivery Status', 
				'spa_Delivery_Status', 'DB Error', 
			'Error Updating Values', ''
	else
		Exec spa_ErrorHandler 0, 'Delivery Status', 
				'spa_Delivery_Status', 'Success', 
				'Delivery Status values successfully Updated.', ''
END

IF @flag='d'
BEGIN
	delete from delivery_status where id=@id

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Delivery Status', 
				'spa_Delivery_Status', 'DB Error', 
			'Error Deleting Values', ''
	else
		Exec spa_ErrorHandler 0, 'Delivery Status', 
				'spa_Delivery_Status', 'Success', 
				'Delivery Status values successfully Deleted.', ''
END

IF @flag='x'
BEGIN
	set @sql='select distinct sml.source_minor_location_id,dbo.FNADATEFORMAT(sdd.term_start),dbo.FNAGetSQLStandardDateTime(getdate())
	from 	
    deal_transport_detail dtd 
	left join source_deal_detail sdd on dtd.source_deal_detail_id_to =sdd.source_deal_detail_id
	left join source_minor_location sml on	sml.source_minor_location_ID=sdd.location_id
	left join source_minor_location_meter smlm on	smlm.meter_id=sdd.meter_id

	where 1=1'

if @deal_transport_id is not null
	set @sql=@sql+ 'and dtd.deal_transport_id=' +cast(@deal_transport_id as varchar)

if @deal_transport_detail_id is not null
	set @sql=@sql+ 'and dtd.deal_transport_deatail_id=' +cast(@deal_transport_detail_id as varchar)

	exec(@sql)
END
END






