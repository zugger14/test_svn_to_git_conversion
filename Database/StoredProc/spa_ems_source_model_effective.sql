/****** Object:  StoredProcedure [dbo].[spa_ems_source_model_effective]    Script Date: 07/21/2009 11:16:35 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ems_source_model_effective]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ems_source_model_effective]
go

create PROCEDURE [dbo].[spa_ems_source_model_effective]
@flag char(1),
@id int=null,
@generator_id int=null,
@ems_source_model_id int=null,
@effective_date datetime=NULL


AS
BEGIN
	DECLARE @sql varchar(8000)
	DECLARE @id_new INT
	declare @msg_err varchar(2000) 
	Begin try


	IF @flag='s'
				BEGIN
					SET @sql='select  ems2.id,dbo.FNAEmissionHyperlink(2,12101400,ems.ems_source_model_name,ems.ems_source_model_id,NULL)[Source Model Name],ems2.generator_id,ems2.ems_source_model_id,ems.ems_source_model_id,dbo.FNADateformat(ems2.effective_date)[Effective Date],dbo.FNADateformat(ems2.end_date)[End Date]
						from ems_source_model ems 
							inner join  ems_source_model_effective  ems2  on ems.ems_source_model_id=ems2.ems_source_model_id
						where generator_id='+cast (@generator_id as varchar)+
						' order by ems2.effective_date '
					
					exec (@sql)
				END

	ELSE IF @flag='i'
		BEGIN
--			IF EXISTS (SELECT 1 FROM ems_source_model_effective WHERE  effective_date = @effective_date)
--			BEGIN
--			Exec spa_ErrorHandler -1, 'Cannot insert duplicate Effective Date.', 
--					'spa_ems_source_model_effective', 'DB Error', 
--					'Cannot insert duplicate Effective Date.', ''
--					return
--			END

			IF ISNULL(@effective_date,'')='' and EXISTS (SELECT 1 FROM ems_source_model_effective WHERE generator_id=@generator_id and effective_date IS NULL)
			BEGIN
			Exec spa_ErrorHandler -1, 'Please insert ''Effective Date''.', 
					'spa_ems_source_model_effective', 'DB Error', 
					'Please insert ''Effective Date''.', ''
					return
			END
			
			INSERT INTO ems_source_model_effective(generator_id,ems_source_model_id,effective_date)
			(SELECT @generator_id,@ems_source_model_id,@effective_date)
			
			set @id_new = SCOPE_IDENTITY()

			EXEC spa_update_end_date_core @flag,@effective_date , @generator_id 

			
--			If @@ERROR <> 0
--				Exec spa_ErrorHandler @@ERROR, "Ems Source Model", 
--				"spa_ems_source_model_effective", "DB Error", 
--				"Error Inserting Ems Source Model Information.", ''
--			else
--				Exec spa_ErrorHandler 0, 'Ems Source Model', 
--				'spa_meter', 'Success', 
--				'Ems Source Model Information successfully inserted.',@id_new
			
		END

			ELSE IF @flag='u'
			BEGIN

				IF ISNULL(@effective_date,'')='' and EXISTS (SELECT 1 FROM ems_source_model_effective WHERE generator_id=@generator_id and effective_date IS NULL)
				BEGIN
				Exec spa_ErrorHandler -1, 'Please insert ''Effective Date''.', 
						'spa_ems_source_model_effective', 'DB Error', 
						'Please insert ''Effective Date''.', ''
						return
				END

				DECLARE @old_effective_date DATETIME
				SELECT  @old_effective_date = effective_date 
					FROM ems_source_model_effective
					WHERE id=@id
					
					
					update ems_source_model_effective
					set generator_id=@generator_id,
					ems_source_model_id=@ems_source_model_id,
					effective_date=@effective_date
					where id=@id
					
					EXEC spa_update_end_date_core @flag,@effective_date , @generator_id,@old_effective_date
					
--								
--					If @@ERROR <> 0
--					Exec spa_ErrorHandler @@ERROR, "Ems Source Model", 
--					"ems_source_model_effective", "DB Error", 
--					"Error Updating Ems Source Model Information.", ''
--					else
--					Exec spa_ErrorHandler 0, 'Ems Source Model', 
--					'spa_meter', 'Success', 
--					'Ems Source Model Information successfully Updated.',''

				END

	ELSE IF @flag='a'
	BEGIN
		
		select id,generator_id,ems_source_model_id,dbo.FNADateformat(ems_source_model_effective.effective_date)
		,dbo.FNADateformat(ems_source_model_effective.end_date)
			from ems_source_model_effective where id=@id

	END

	ELSE IF @flag='d'
	BEGIN
					SELECT @generator_id = generator_id, @effective_date = effective_date 
					FROM ems_source_model_effective
					WHERE id=@id
					
			EXEC spa_update_end_date_core @flag,@effective_date , @generator_id,@effective_date 
			
		delete from ems_source_model_effective 
			where  id=@id


--		If @@ERROR <> 0
--			Exec spa_ErrorHandler @@ERROR, "Ems Source Model", 
--			"spa_ems_source_model_effective", "DB Error", 
--			"Error Deleting Ems Source Model Information.", ''
--		else
--			Exec spa_ErrorHandler 0, 'Ems Source Model', 
--			'spa_meter', 'Success', 
--			'Ems Source Model Information successfully Deleted.',''

	END
	DECLARE @msg varchar(2000)
	SELECT @msg=''
	if @flag='i'
		SET @msg='Data Successfully Inserted.'
	ELSE if @flag='u'
		SET @msg='Data Successfully Updated.'
	ELSE if @flag='d'
		SET @msg='Data Successfully Deleted.'

	IF @msg<>''
		select 'Success', 'ems_source_model_effective', 
				'spa_ems_source_model_effective', 'Success', 
				@msg, ''
	END try
	begin catch
		DECLARE @error_number int
		SET @error_number=error_number()
		SET @msg_err=''
		--EXEC spa_print 'errr #:'+CAST( error_number() AS VARCHAR)
		EXEC spa_print '@flag=',@flag
		if @flag='i'
		BEGIN

			IF @error_number=2601
			begin
				SET @msg_err='Fail Insert Data(Found Duplicate Data).'
							select 'Error', 'ems_source_model_effective', 
					'spa_ems_source_model_effective', 'DB Error', 
					@msg_err, ''
				return
			end
			ELSE 
				SET @msg_err='Fail Insert Data.'
		END
		ELSE if @flag='u'
			SET @msg_err='Fail Update Data.'
		ELSE if @flag='d'
			SET @msg_err='Fail Delete Data.'
			
		SET @msg_err= @msg_err+ ' (' + error_message() +')'
			select 'Error', 'ems_source_model_effective', 
					'spa_ems_source_model_effective', 'DB Error', 
					@msg_err, ''


	END catch




END











