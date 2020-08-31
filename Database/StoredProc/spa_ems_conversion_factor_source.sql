IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ems_conversion_factor_source]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ems_conversion_factor_source]
GO 

CREATE PROCEDURE [dbo].[spa_ems_conversion_factor_source]  	
					@flag as char(1),
					@ems_conversion_factor_source_id int=NULL,
					@generator_id as int=NULL,
					@source as int =NULL,
					@effective_date as varchar(250)=NULL				
					

AS

SET NOCOUNT ON

DECLARE @errorCode Int

If @flag = 's' 
Begin


	Declare @selectStr Varchar(5000)
	BEGIN
		Set @selectStr = 'select ecfc.ems_conversion_factor_source_id ConversionFactorID, ecfc.generator_id Generator,ecfc.source Source,sdv.code [Conversion Source],dbo.FNADateFormat(ecfc.effective_date) EffectiveDate	
							from ems_conversion_factor_source ecfc
							join static_data_value sdv on  ecfc.source=sdv.value_id'
		
	END
	exec(@selectStr)

--	exec spa_print @selectStr

	Set @errorCode = @@ERROR
	If @errorCode <> 0 
		Exec spa_ErrorHandler @errorCode, 'Ems Conversion Factor', 
				'spa_ems_conversion_factor_source', 'DB Error', 
				'Select of all Ems Conversion Factor Failed.', ''
	End
else If @flag = 'a' 
Begin


	Declare @selectStr1 Varchar(5000)

	Set @selectStr1 = 'select ems_conversion_factor_source_id , generator_id ,source , dbo.FNADateFormat(effective_date) from ems_conversion_factor_source 
						where ems_conversion_factor_source_id='+cast(@ems_conversion_factor_source_id as varchar)
	exec(@selectStr1)
--	exec spa_print @selectStr
	Set @errorCode = @@ERROR
	If @errorCode <> 0 
		
		Exec spa_ErrorHandler @errorCode, 'Ems Conversion Factor', 
				'spa_ems_conversion_factor_source', 'DB Error', 
				'Select of all Ems Conversion Factor Failed.', ''
	End

Else If @flag='i'
Begin
	insert into ems_conversion_factor_source (generator_id,source,effective_date)
	values (@generator_id,@source,@effective_date)


	Set @errorCode = @@ERROR
	If @errorCode <> 0
		Exec spa_ErrorHandler @errorCode, 'Ems Conversion Factor', 
				'spa_ems_conversion_factor_source', 'DB Error', 
				'Failed to insert Ems Conversion Factor.', ''
	Else
		Exec spa_ErrorHandler 0, 'Ems Conversion Factor', 
				'spa_ems_conversion_factor_source', 'Success', 
				'Ems Conversion Factor inserted.', ''
	End

Else If @flag = 'u'
Begin
	Update ems_conversion_factor_source
	set 
	 generator_id = @generator_id,
	 source = @source,
	 effective_date=@effective_date
	where ems_conversion_factor_source_id = @ems_conversion_factor_source_id

	Set @errorCode = @@ERROR
	If @errorCode <> 0
	BEGIN
		
		Exec spa_ErrorHandler @errorCode, 'Ems Conversion Factor', 
				'spa_ems_conversion_factor_source', 'DB Error', 
				'Failed to update Ems Conversion Factor.', ''
		Return
	END
	Else
	BEGIN
		
		Exec spa_ErrorHandler 0, 'Ems Conversion Factor', 
				'spa_ems_conversion_factor_source', 'Success', 
				'Ems Conversion Factor updated.', ''
		Return
	END
	End

Else If @flag='d'
Begin

	Delete ems_conversion_factor_source 
	where ems_conversion_factor_source_id = @ems_conversion_factor_source_id

	Set @errorCode = @@ERROR
	If @errorCode <> 0
	BEGIN
		Exec spa_ErrorHandler @errorCode, 'Ems Conversion Factor', 
				'spa_ems_conversion_factor_source', 'DB Error', 
				'Failed to delete Ems Conversion Factor.', ''
		Return
	END
	Else
	BEGIN
		Exec spa_ErrorHandler 0, 'Ems Conversion Factor', 
				'spa_ems_conversion_factor_source', 'Success', 
				'Ems Conversion Factor deleted.', ''
		Return
	END

End
