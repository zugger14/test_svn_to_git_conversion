/****** Object:  StoredProcedure [dbo].[spa_meter_id_allocation]    Script Date: 03/02/2009 14:08:26 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_meter_id_allocation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_meter_id_allocation]
Go
CREATE PROCEDURE [dbo].[spa_meter_id_allocation]
	@flag char(1),
	@allocation_id int=null,
	@meter_id varchar(1000) =NULL,
	@gre_per float=null,
	@production_month datetime=null,
	@gre_volume float=null ,
	@FROM_date datetime=null,
	@to_date datetime=null	

	
AS
BEGIN

DECLARE @sql varchar(8000)

	IF @flag='s'
	BEGIN
	SET @sql= 
 		' SELECT 
 			allocation_id [Allocation ID],
 			mi.recorderid [Recorder ID],
 			cast(gre_per as float)*100 [Third Party %],
 			gre_volume as [Volume],
			dbo.FNADateFormat(production_month) [Production Month]
		 FROM
			meter_id_allocation mia
			INNER JOIN meter_id mi ON mi.meter_id=mia.meter_id
		WHERE 1=1 
			AND mia.meter_id='''+@meter_id+''''+
 		CASE WHEN @production_month IS NOT NULL THEN ' and dbo.FNAgetcontractMonth(production_month)='''+cast(dbo.FNAgetcontractMonth(@production_month) AS VARCHAR)+'''' ELSE '' END 

		EXEC(@sql)
	END


	ELSE IF @flag='a'
	BEGIN
		SELECT 
			meter_id [Recorder ID],
			gre_per [GRE Percentage],
			dbo.FNADateFormat(production_month),
			gre_volume
		FROM 	
			meter_id_allocation WHERE allocation_id=@allocation_id
	END

	ELSE IF @flag='i'
	BEGIN
		
		IF NOT EXISTS(SELECT 1 FROM meter_id_allocation WHERE meter_id = @meter_id)
			BEGIN
				INSERT INTO meter_id_allocation(meter_id,gre_per,production_month,gre_volume)
				SELECT @meter_id,ISNULL(@gre_per,0),dbo.FNAgetcontractMonth(@production_month),@gre_volume

				IF @@ERROR <> 0
					EXEC spa_ErrorHandler @@ERROR, "Recorder ID Detail", 
					"spa_meter", "DB Error", 
					"Error Inserting Recoder Information.", ''
				ELSE
					EXEC spa_ErrorHandler 0, 'Recorder ID', 
					'spa_meter', 'Success', 
					'Recorder Information successfully inserted.',''
		END
		ELSE
			BEGIN
				EXEC spa_ErrorHandler -1,
					'Recorder ID', 
					'spa_meter', 'Error', 
					'Meter ID already exists. Please select another Meter ID.',''
			END
		
		
			

	END

	ELSE IF @flag='u'
	BEGIN

		UPDATE	 
			meter_id_allocation
		SET	
			gre_per=ISNULL(@gre_per,0),
			production_month=dbo.FNAgetcontractMonth(@production_month),
			gre_volume=@gre_volume
		WHERE
			allocation_id=@allocation_id


		IF @@ERROR <> 0
			EXEC spa_ErrorHandler @@ERROR, "Recorder ID", 
			"spa_meter", "DB Error", 
			"Error Updating Recoder Information.", ''
		ELSE
			EXEC spa_ErrorHandler 0, 'Recorder ID', 
			'spa_meter', 'Success', 
			'Recoder Information successfully Updated.',''

	END
	ELSE IF @flag='d'
	BEGIN

		DELETE FROM 
			meter_id_allocation
		WHERE 
			allocation_id=@allocation_id

		IF @@ERROR <> 0
			EXEC spa_ErrorHandler @@ERROR, "Recorder ID", 
			"spa_meter", "DB Error", 
			"Error  Deleting Recoder Information.", ''
		ELSE
			EXEC spa_ErrorHandler 0, 'Recorder ID', 
			'spa_meter', 'Success', 
			'Recoder Information Deleted Successfully.',''

	END
	ELSE IF @flag='r' -- report
	BEGIN
		IF @to_date is null and @FROM_date is not null
			SET @to_date=@FROM_date
		IF @FROM_date is null and @to_date is not null
			SET @FROM_date=@to_date

		SET @sql= 
 			'
		SELECT 
			mi.recorderid+''&nbsp;'' as  [Recorder ID],
			mv.channel Channel, dbo.FNADateformat(dbo.FNAgetcontractMonth(mv.FROM_date)) [Production Month],
			mv.volume Volume, su.uom_name UOM,mv.descriptions [Descriptions]	
		FROM
			meter_id mi 
			INNER JOIN mv90_data mv on mi.recorderid=mv.recorderid
			LEFT JOIN recorder_properties rp on rp.meter_id=mv.meter_id and rp.channel=mv.channel
			LEFT JOIN source_uom su on su.source_uom_id=rp.uom_id
		WHERE 1=1 
			AND dbo.fnagetcontractmonth(mv.FROM_date) between dbo.fnagetcontractmonth('''+cast(@FROM_date AS VARCHAR)+''')
			AND dbo.fnagetcontractmonth('''+cast(@to_date AS VARCHAR)+''') 	
		'+
		CASE WHEN @meter_id is not null THEN ' And mi.meter_id in('+@meter_id+')' ELSE '' END +
		' ORDER by mi.recorderid,mv.channel,dbo.FNAgetcontractMonth(mv.FROM_date) '


			EXEC (@sql)

	END
END

