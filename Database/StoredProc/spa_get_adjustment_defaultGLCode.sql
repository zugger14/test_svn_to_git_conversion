/****** Object:  StoredProcedure [dbo].[spa_get_adjustment_defaultGLCode]    Script Date: 09/14/2009 17:20:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_adjustment_defaultGLCode]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_adjustment_defaultGLCode]
/****** Object:  StoredProcedure [dbo].[spa_get_adjustment_defaultGLCode]    Script Date: 09/14/2009 17:20:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_get_adjustment_defaultGLCode]
	@flag char(1), -- 'c' - dispaly in the combo box
	@default_gl_id int=NULL,
	@fas_subsidiary_id int=NULL,
	@adjustment_type_id int=NULL,
	@type varchar(10)=NULL,
	@debit_gl_number int=NULL,
	@credit_gl_number int=NULL,
	@debit_volume_multiplier int=NULL,
	@credit_volume_multiplier int=NULL,
	@debit_remark varchar(100)=NULL,
	@credit_remark varchar(100)=NULL,
	@uom_id int =NULL,
	@estimated_actual char(1)=null,
	@debit_gl_number_minus INT=NULL,
	@credit_gl_number_minus INT=NULL,
    @netting_debit_gl_number INT=NULL,
	@netting_credit_gl_number INT=NULL,
    @netting_debit_gl_number_minus INT=NULL,
	@netting_credit_gl_number_minus INT=NULL


as 
set nocount on
DECLARE @sqlstmt VARCHAR(8000)
IF @flag='s'
BEGIN

SET @sqlstmt='
	select default_gl_id as [GL ID],
		sd.code [GL Group Type],
		gl.gl_account_number + '' ('' + gl.gl_account_name +'')'' as [Dr GL No(+ve)],
		gl1.gl_account_number + '' ('' + gl1.gl_account_name +'')'' as [Cr GL No(+ve)],
		gl2.gl_account_number + '' ('' + gl2.gl_account_name +'')'' as [Dr GL No(-ve)],
		gl3.gl_account_number + '' ('' + gl3.gl_account_name +'')'' as [Cr GL No(-ve)],        
		--adj.debit_gl_number,
		--adj.credit_gl_number,
		debit_volume_multiplier [Dr Vol Mul],credit_volume_multiplier [Cr Vol Mul],
		debit_remark [Debit Remark],credit_remark [Credit Remark],
		adj.fas_subsidiary_id [Sub ID],
		su.uom_name [UOM],
		su.source_uom_id [Uom ID],
		case when estimated_actual=''a'' then ''Actual'' when estimated_actual=''e'' then ''Estimated'' end as [Estimated/Actual],
        gl4.gl_account_number + '' ('' + gl4.gl_account_name +'')'' as [Netting Dr GL No(+ve)],
		gl5.gl_account_number + '' ('' + gl5.gl_account_name +'')'' as [Netting Cr GL No(+ve)],
		gl6.gl_account_number + '' ('' + gl6.gl_account_name +'')'' as [Netting Dr GL No(-ve)],
		gl7.gl_account_number + '' ('' + gl7.gl_account_name +'')'' as [Netting Cr GL No(-ve)]
	from 
		adjustment_default_gl_codes adj  join
		static_data_value sd on adj.adjustment_type_id=sd.value_id
		left join gl_system_mapping gl on gl.gl_number_id=adj.debit_gl_number
		left join gl_system_mapping gl1 on gl1.gl_number_id=adj.credit_gl_number
		left join gl_system_mapping gl2 on gl2.gl_number_id=adj.debit_gl_number_minus
		left join gl_system_mapping gl3 on gl3.gl_number_id=adj.credit_gl_number_minus        
        left join gl_system_mapping gl4 on gl4.gl_number_id=adj.netting_debit_gl_number
		left join gl_system_mapping gl5 on gl5.gl_number_id=adj.netting_credit_gl_number
		left join gl_system_mapping gl6 on gl6.gl_number_id=adj.netting_debit_gl_number_minus
		left join gl_system_mapping gl7 on gl7.gl_number_id=adj.netting_credit_gl_number_minus
        
		left join source_uom su on su.source_uom_id=adj.uom_id
	where 1=1 '
	+case when @default_gl_id is not null then ' AND default_gl_id='+cast(@default_gl_id as varchar) else '' end
	+case when @fas_subsidiary_id is not null then ' AND adj.fas_subsidiary_id='+cast(@fas_subsidiary_id as varchar) else '' END
EXEC(@sqlstmt) 
END
ELSE IF @flag='a'
BEGIN

SET @sqlstmt='
	select default_gl_id as GLID,
		sd.code [GL Group Type],
		gl.gl_account_number + '' ('' + gl.gl_account_name +'')'' as [Dr GL No(+ve)],
		gl1.gl_account_number + '' ('' + gl1.gl_account_name +'')'' as [Cr GL No(+ve)],
		adj.debit_gl_number,
		adj.credit_gl_number,
		debit_volume_multiplier [Dr Vol Mul],credit_volume_multiplier [Cr Vol Mul],
		debit_remark [Debit Remark],credit_remark [Credit Remark],
		adj.fas_subsidiary_id [Sub ID],
		su.uom_name [UOM],
		su.source_uom_id [Uom ID],
		case when estimated_actual=''a'' then ''Actual'' when estimated_actual=''e'' then ''Estimated'' when estimated_actual=''c'' then ''Cash Applied'' end as [Estimated/Actual],
		gl2.gl_account_number + '' ('' + gl2.gl_account_name +'')'' as [Dr GL No(-ve)],
		gl3.gl_account_number + '' ('' + gl3.gl_account_name +'')'' as [Cr GL No(-ve)],        
		adj.debit_gl_number_minus,
		adj.credit_gl_number_minus,
        gl4.gl_account_number + '' ('' + gl4.gl_account_name +'')'' as [Netting Dr GL No(+ve)],
		gl5.gl_account_number + '' ('' + gl5.gl_account_name +'')'' as [Netting Cr GL No(+ve)],
		gl6.gl_account_number + '' ('' + gl6.gl_account_name +'')'' as [Netting Dr GL No(-ve)],
		gl7.gl_account_number + '' ('' + gl7.gl_account_name +'')'' as [Netting Cr GL No(-ve)],
        adj.netting_debit_gl_number,
		adj.netting_credit_gl_number,
        adj.netting_debit_gl_number_minus,
		adj.netting_credit_gl_number_minus

	from 
		adjustment_default_gl_codes adj  join
		static_data_value sd on adj.adjustment_type_id=sd.value_id
		left join gl_system_mapping gl on gl.gl_number_id=adj.debit_gl_number
		left join gl_system_mapping gl1 on gl1.gl_number_id=adj.credit_gl_number
		left join gl_system_mapping gl2 on gl2.gl_number_id=adj.debit_gl_number_minus
		left join gl_system_mapping gl3 on gl3.gl_number_id=adj.credit_gl_number_minus
        left join gl_system_mapping gl4 on gl4.gl_number_id=adj.netting_debit_gl_number
		left join gl_system_mapping gl5 on gl5.gl_number_id=adj.netting_credit_gl_number
		left join gl_system_mapping gl6 on gl6.gl_number_id=adj.netting_debit_gl_number_minus
		left join gl_system_mapping gl7 on gl7.gl_number_id=adj.netting_credit_gl_number_minus
		left join source_uom su on su.source_uom_id=adj.uom_id
	where 1=1 '
	+case when @default_gl_id is not null then ' AND default_gl_id='+cast(@default_gl_id as varchar) else '' end
	+case when @fas_subsidiary_id is not null then ' AND adj.fas_subsidiary_id='+cast(@fas_subsidiary_id as varchar) else '' end
EXEC(@sqlstmt) 
END
else if @flag='i'
BEGIN
	IF @adjustment_type_id IS NULL 
	BEGIN 
		Exec spa_ErrorHandler -1, 'Adjustment default gl code', 
			'spa_get_adjustment_defaultGLCode', 'DB Error', 
			'Please select Account Type.', ''
		RETURN 
	END 
	BEGIN TRY
	BEGIN TRAN
		
			insert into 
				adjustment_default_gl_codes
			(
				fas_subsidiary_id,
				adjustment_type_id,
				type,
				debit_gl_number,
				credit_gl_number,
				debit_volume_multiplier,
				credit_volume_multiplier,
				debit_remark,
				credit_remark,
				uom_id,
				estimated_actual,
				debit_gl_number_minus,
				credit_gl_number_minus,
                netting_debit_gl_number,
                netting_credit_gl_number,
                netting_debit_gl_number_minus,
                netting_credit_gl_number_minus
			)
			SELECT 
				@fas_subsidiary_id,
				@adjustment_type_id,
				@type,
				@debit_gl_number,
				@credit_gl_number,
				@debit_volume_multiplier,
				@credit_volume_multiplier,
				@debit_remark,
				@credit_remark,
				@uom_id,
				@estimated_actual,
				@debit_gl_number_minus,
				@credit_gl_number_minus,
                @netting_debit_gl_number,
				@netting_credit_gl_number,
                @netting_debit_gl_number_minus,
				@netting_credit_gl_number_minus
				
			--	SELECT @@error
				COMMIT TRAN 
				
				
		Exec spa_ErrorHandler 0, 'Adjustment default gl code', 

		'spa_get_adjustment_defaultGLCode', 'Success', 
		'Record successfully updated.', ''
			
	END TRY 
	BEGIN CATCH
		ROLLBACK TRAN 
		IF ERROR_NUMBER() = 2627
		Begin
			Exec spa_ErrorHandler -1, 'Adjustment default gl code', 
			'spa_get_adjustment_defaultGLCode', 'DB Error', 
			'The combination of Subsidiary,Account Type and Estimated/Actual must be unique.', ''
		End
		ELSE If ERROR_NUMBER() <> 0
		Begin
			Exec spa_ErrorHandler @@ERROR, 'Adjustment default gl code', 
			'spa_get_adjustment_defaultGLCode', 'DB Error', 
			'Failed updating record.', ''
		End
	END CATCH
	 

END
ELSE IF @flag='u'
BEGIN
BEGIN TRY
	BEGIN TRAN

	UPDATE adjustment_default_gl_codes
	SET    fas_subsidiary_id                  = @fas_subsidiary_id,
		   adjustment_type_id                 = @adjustment_type_id,
		   TYPE                               = @type,
		   debit_gl_number                    = @debit_gl_number,
		   credit_gl_number                   = @credit_gl_number,
		   debit_volume_multiplier            = @debit_volume_multiplier,
		   credit_volume_multiplier           = @credit_volume_multiplier,
		   debit_remark                       = @debit_remark,
		   credit_remark                      = @credit_remark,
		   uom_id                             = @uom_id,
		   estimated_actual                   = @estimated_actual,
		   debit_gl_number_minus              = @debit_gl_number_minus,
		   credit_gl_number_minus             = @credit_gl_number_minus,
		   netting_debit_gl_number            = @netting_debit_gl_number,
		   netting_credit_gl_number           = @netting_credit_gl_number,
		   netting_debit_gl_number_minus      = @netting_debit_gl_number_minus,
		   netting_credit_gl_number_minus     = @netting_credit_gl_number_minus
	WHERE
		default_gl_id = @default_gl_id

	COMMIT TRAN 
	EXEC spa_ErrorHandler 0,
		 'Adjustment default gl code',
		 'spa_get_adjustment_defaultGLCode',
		 'Success',
		 'Record successfully updated.',
		 ''

	END TRY 
	BEGIN CATCH
		ROLLBACK TRAN 
		
		IF ERROR_NUMBER() = 2627
		BEGIN
		    EXEC spa_ErrorHandler -1,
		         'Adjustment default gl code',
		         'spa_get_adjustment_defaultGLCode',
		         'DB Error',
		         'The combination of Subsidiary,Account Type and Estimated/Actual must be unique.',
		         ''
		END
		ELSE IF ERROR_NUMBER() <> 0
		     BEGIN
		         EXEC spa_ErrorHandler @@ERROR,
		              'Adjustment default gl code',
		              'spa_get_adjustment_defaultGLCode',
		              'DB Error',
		              'Failed updating record.',
		              ''
		     END
	END CATCH
	END

ELSE IF @flag='d'
BEGIN
	DELETE from adjustment_default_gl_codes where 
	default_gl_id=@default_gl_id

	If @@ERROR <> 0
		Begin
		Exec spa_ErrorHandler @@ERROR, 'Adjustment default gl code', 
		'spa_get_adjustment_defaultGLCode', 'DB Error', 
		'Failed deleting record.', ''
		End
	Else
	Begin
		Exec spa_ErrorHandler 0, 'Adjustment default gl code', 

		'spa_get_adjustment_defaultGLCode', 'Success', 
		'Record successfully deleted.', ''
	End
END
ELSE IF @flag='c' --- display in the combo box
BEGIN
SET @sqlstmt='
	select default_gl_id as GLID,
	sd.code+case when estimated_actual=''a'' then + '' -> Actual'' when  estimated_actual=''e'' then '' ->Estimated'' when  estimated_actual=''c'' then '' ->Cash Applied'' ELSE '''' END [Adj Type]
	from adjustment_default_gl_codes adj  join
	static_data_value sd on adj.adjustment_type_id=sd.value_id
	where 1=1 '
	+case when @fas_subsidiary_id is not null then ' AND (adj.fas_subsidiary_id='+cast(@fas_subsidiary_id as varchar) + ' OR adj.fas_subsidiary_id IS NULL)' else '' end
	+case when @estimated_actual is not null then ' AND (estimated_actual='''+cast(@estimated_actual as varchar)+''' OR estimated_actual IS NULL) ' else '' END
EXEC(@sqlstmt) 
END
ELSE IF @flag = 'f'
BEGIN
	SELECT default_gl_id, 
		sdv.code,
		--ph.entity_name,		 
		CASE adgc.estimated_actual 
			WHEN 'a' THEN 'Actual'
			WHEN 'e' THEN 'Estimate'
			WHEN 'c' THEN 'Cash Applied'
		END 
		estimated_actual,
		gl.gl_account_name + ' (' + gl.gl_account_number +')' as [drglnopos],
		gl1.gl_account_name + ' (' + gl1.gl_account_number +')' as [crglnopos],  
		gl4.gl_account_name + ' (' + gl4.gl_account_number +')' as [netdrglnopos],
		gl5.gl_account_name + ' (' + gl5.gl_account_number +')' as [netcrglnopos],  
		gl2.gl_account_name + ' (' + gl2.gl_account_number +')' as [drglnoneg],
		gl3.gl_account_name + ' (' + gl3.gl_account_number +')' as [crglnoneg],   
		gl6.gl_account_name + ' (' + gl6.gl_account_number +')' as [netdrglnoneg],
		gl7.gl_account_name + ' (' + gl7.gl_account_number +')' as [netcrglnoneg],     
		su.uom_name
	FROM adjustment_default_gl_codes adgc
		--LEFT JOIN portfolio_hierarchy ph
		--	ON adgc.fas_subsidiary_id = ph.entity_id
		--	AND hierarchy_level = 2
		LEFT JOIN static_data_value sdv 
			ON	sdv.value_id = adjustment_type_id
			AND type_id = 10015
		left join gl_system_mapping gl on gl.gl_number_id=adgc.debit_gl_number
		left join gl_system_mapping gl1 on gl1.gl_number_id=adgc.credit_gl_number
		left join gl_system_mapping gl2 on gl2.gl_number_id=adgc.debit_gl_number_minus
		left join gl_system_mapping gl3 on gl3.gl_number_id=adgc.credit_gl_number_minus
        left join gl_system_mapping gl4 on gl4.gl_number_id=adgc.netting_debit_gl_number
		left join gl_system_mapping gl5 on gl5.gl_number_id=adgc.netting_credit_gl_number
		left join gl_system_mapping gl6 on gl6.gl_number_id=adgc.netting_debit_gl_number_minus
		left join gl_system_mapping gl7 on gl7.gl_number_id=adgc.netting_credit_gl_number_minus
		left join source_uom su on su.source_uom_id=adgc.uom_id


	
END










