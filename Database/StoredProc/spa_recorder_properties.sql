IF OBJECT_ID(N'spa_recorder_properties', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_recorder_properties]
GO
 
CREATE procedure [dbo].[spa_recorder_properties]
	@flag CHAR(1),
	@meter_id INT,
	@channel INT = NULL,
	@mult_factor INT = NULL,
	@uom INT = NULL
AS

	IF @flag='s'
	BEGIN
		SELECT rp.recorder_property_id ,
				mi.meter_id meter_id,
		       rp.channel,
		       rp.channel_description,
		       rp.mult_factor,
		       rp.uom_id
		FROM   recorder_properties rp
		INNER JOIN meter_id mi ON mi.meter_id = rp.meter_id
		WHERE  rp.meter_id = @meter_id 
	END

	ELSE IF @flag='a'
	BEGIN
		SELECT 
			meter_id,
			channel,
			mult_factor,
			uom_id
		FROM 	
			recorder_properties
		WHERE 
			meter_id=@meter_id and channel=@channel
	END

	ELSE IF @flag='i'
	BEGIN
		IF EXISTS (SELECT 1 FROM recorder_properties WHERE meter_id = @meter_id AND channel = @channel)
		BEGIN
			EXEC spa_ErrorHandler -1,
			     'The combination of Recorder ID and Channel already exists.',
			     'spa_recorder_properties',
			     'DB Error',
			     'The combination of Recorder ID and Channel already exists.',
			     ''
			RETURN
		END
		
		Insert into recorder_properties(meter_id,channel,mult_factor,uom_id)
		SELECT @meter_id,@channel,@mult_factor,@uom

		If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "Recorder Properties", 
			"spa_recorder_properties", "DB Error", 
			"Error Inserting Recoder Properties.", ''
		else
			Exec spa_ErrorHandler 0, 'Recorder Properties', 
			'spa_recorder_properties', 'Success', 
			'Recorder Properties successfully inserted.',''
			

	END

	ELSE IF @flag='u'
	BEGIN

		update	 
			recorder_properties
		set	
			channel=@channel,
			mult_factor=@mult_factor,
			uom_id=@uom
		where
			meter_id=@meter_id
			and channel=@channel


		If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "Recorder Properties", 
			"spa_recorder_properties", "DB Error", 
			"Error Updating Recoder Information.", ''
		else
			Exec spa_ErrorHandler 0, 'Recorder Properties', 
			'spa_recorder_properties', 'Success', 
			'Recoder Properties successfully updated.',''

	END
	ELSE IF @flag='d'
	BEGIN

		delete from 
			recorder_properties
		where 
			meter_id=@meter_id
			and channel=@channel

		If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "Recorder Properties", 
			"spa_recorder_properties", "DB Error", 
			"Error  Deleting Recoder Properties.", ''
		else
			Exec spa_ErrorHandler 0, 'Recorder Properties', 
			'spa_recorder_properties', 'Success', 
			'Recoder Properties Deleted Successfully.',''

	END
	ELSE IF @flag='r'
	BEGIN
	Select meter_id, channel
	from recorder_properties 
	where meter_id = @meter_id
	END


