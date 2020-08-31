IF OBJECT_ID(N'[dbo].[spa_farrms_config_setting]', N'P') IS NOT NULL
drop proc [dbo].[spa_farrms_config_setting]
go
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

CREATE proc [dbo].[spa_farrms_config_setting]
@flag char(1),
@esi_id int=null,
@source_system_id int=null,
@setting_id  int=null,
@setting_value int=null
as
IF @flag='s'	
BEGIN
	select esi_id [ID],source_system_name System,upper(sdv.Code) [Type],setting_value [Timeout in sec]
	from farrms_config_setting c join source_system_description ssd 
	on c.source_system_id=ssd.source_system_id
	join static_data_value  sdv on sdv.value_id=c.setting_id 

END

ELSE IF @flag='a'
BEGIN

	select esi_id , source_system_id,setting_id,setting_value
	from 	farrms_config_setting where esi_id=@esi_id
END

ELSE IF @flag='i'
--BEGIN
--BEGIN TRY 
--declare @ErrorNumber int,@ErrorMessage varchar(1000)
--	Insert into farrms_config_setting(source_system_id,setting_id,setting_value)
--	select @source_system_id,@setting_id,@setting_value
--END TRY	
--BEGIN CATCH
--select 
--         @ErrorNumber= ERROR_NUMBER() ,
--         @ErrorMessage =ERROR_MESSAGE();
--END CATCH
--print @ErrorNumber
--print @ErrorMessage
----select * from farrms_config_setting
----exec spa_farrms_config_setting 'i',null,null,5
--
--If @ErrorNumber = 515
--		select 'Error' , 'Timeout Setup', 
--				'spa_farrms_config_setting', 'DB Error', 
--				@ErrorMessage,'' 
--
--else If @ErrorNumber > 0
--Exec spa_ErrorHandler @ErrorNumber, 'Timeout Setup', 
--				'spa_farrms_config_setting', 'DB Error', 
--				'Can not insert duplicate interface timeout parameter','' 
--	else
--		Exec spa_ErrorHandler 0, 'Timeout Setup', 
--				'spa_farrms_config_setting', 'Success', 
--				'Timeout Setup successfully inserted.', ''
--
--
--END

BEGIN
	BEGIN TRY
		BEGIN TRAN
		
			INSERT INTO farrms_config_setting(source_system_id,setting_id,setting_value)
				SELECT @source_system_id,@setting_id,@setting_value

			EXEC spa_ErrorHandler 0, 'Timeout Setup', 
			'spa_farrms_config_setting', 'Success', 
			'Timeout Setup successfully inserted.', ''

		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
		
		DECLARE @error_num INT,@ErrorMessage VARCHAR(1000)
		SET @error_num = ERROR_NUMBER()
		SET @ErrorMessage =ERROR_MESSAGE()

		IF @error_num = 515
				SELECT 'Error' , 'Timeout Setup', 
						'spa_farrms_config_setting', 'DB Error', 
						@ErrorMessage,'' 
		ELSE 
			EXEC spa_ErrorHandler -1, 'Timeout Setup', 
				'spa_farrms_config_setting', 'DB Error', 
				'Can not insert duplicate interface timeout parameter.','' 		
	END CATCH
END

ELSE IF @flag='u'
--	update farrms_config_setting
--	set	
--	setting_id =@setting_id,
--	setting_value=@setting_value
--			
--	where esi_id=@esi_id
--
--If @@ERROR <> 0
--		Exec spa_ErrorHandler @@ERROR, "Timeout Setup", 
--		"spa_farrms_config_setting", "DB Error", 
--		"Error Timeout Setup.", ''
--	else
--		Exec spa_ErrorHandler 0, 'Timeout Setup', 
--		'spa_farrms_config_setting', 'Success', 
--		'Timeout Setup saved.',''

BEGIN
	BEGIN TRY
		BEGIN TRAN
		
			UPDATE farrms_config_setting
				SET	
					setting_id =@setting_id,
					setting_value=@setting_value

				WHERE esi_id=@esi_id

			EXEC spa_ErrorHandler 0, 'Timeout Setup', 
			'spa_farrms_config_setting', 'Success', 
			'Timeout Setup successfully updated.', ''

		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
		
		EXEC spa_ErrorHandler -1, 'Timeout Setup', 
				'spa_farrms_config_setting', 'DB Error', 
				'Can not update duplicate interface timeout parameter.','' 		
	END CATCH
END
ELSE IF @flag='d'
BEGIN


	delete from farrms_config_setting 
	where esi_id=@esi_id

	If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "Timeout Setup", 
			"spa_farrms_config_setting", "DB Error", 
			"Error Timeout Setup.", ''
		else
			Exec spa_ErrorHandler 0, 'Timeout Setup', 
			'spa_farrms_config_setting', 'Success', 
			'Timeout Setup Deleted.',''
end



