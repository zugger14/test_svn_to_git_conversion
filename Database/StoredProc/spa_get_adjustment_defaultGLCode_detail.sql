IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_adjustment_defaultGLCode_detail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_adjustment_defaultGLCode_detail]
 

GO

Create PROCEDURE [dbo].[spa_get_adjustment_defaultGLCode_detail]
	@flag char(1), -- 'c' - dispaly in the combo box
	@detail_id int=NULL,
	@default_gl_id int=NULL,
	@debit_gl_number int=NULL,
	@credit_gl_number int=NULL,		
	@debit_volume_multiplier int=NULL,
	@credit_volume_multiplier int=NULL,
	@debit_remark varchar(100)=NULL,
	@credit_remark varchar(100)=NULL,
	@uom_id int =NULL,
	@term_start datetime=NULL,
	@term_end datetime=NULL,
	@debit_gl_number_minus INT=NULL,
	@credit_gl_number_minus INT=NULL,
	@netting_debit_gl_number INT=NULL,
	@netting_credit_gl_number INT=NULL,
	@netting_debit_gl_number_minus INT=NULL,
	@netting_credit_gl_number_minus INT=NULL
as 
SET NOCOUNT on
DECLARE @sqlstmt VARCHAR(8000)
IF @flag='s'
BEGIN

SET @sqlstmt='
	select 
	detail_id as ID,
	dbo.fnadateformat(adj.term_start) as [Term Start],
	dbo.fnadateformat(adj.term_end) as [Term End],
	gl.gl_account_number + '' ('' + gl.gl_account_name +'')'' as [Dr GL No (+ve)],
	gl1.gl_account_number + '' ('' + gl1.gl_account_name +'')'' as [Cr GL No (+ve)],
	adj.debit_gl_number [Debit GL Number],
	adj.credit_gl_number [Credit GL Number],
	gl2.gl_account_number + '' ('' + gl2.gl_account_name +'')'' as [Dr GL No (-ve)],
	gl3.gl_account_number + '' ('' + gl3.gl_account_name +'')'' as [Cr GL No (-ve)],
	adj.debit_gl_number_minus [Debit GL Number Minus],
	adj.credit_gl_number_minus [Credit GL Number Minus],
	debit_volume_multiplier [Dr Vol Mul],credit_volume_multiplier [Cr Vol Mul],
	debit_remark [Debit Remark],credit_remark [Credit Remark],
	su.uom_name [UOM],
	su.source_uom_id [Uom ID]
	from adjustment_default_gl_codes_detail adj 
	left join gl_system_mapping gl on gl.gl_number_id=adj.debit_gl_number
	left join gl_system_mapping gl1 on gl1.gl_number_id=adj.credit_gl_number
	left join gl_system_mapping gl2 on gl2.gl_number_id=adj.debit_gl_number_minus
	left join gl_system_mapping gl3 on gl3.gl_number_id=adj.credit_gl_number_minus
	left join source_uom su on su.source_uom_id=adj.uom_id
	where 1=1 '
	+case when @default_gl_id is not null then ' AND default_gl_id='+cast(@default_gl_id as varchar) else '' end
	

EXEC(@sqlstmt) 
END
ELSE IF @flag='a'
BEGIN

SET @sqlstmt='
	select 
	detail_id as ID,
	dbo.fnadateformat(adj.term_start) as [Term Start],
	gl.gl_account_number + '' ('' + gl.gl_account_name +'')'' as [Dr GL No (+ve)],
	gl1.gl_account_number + '' ('' + gl1.gl_account_name +'')'' as [Cr GL No (+ve)],
	adj.debit_gl_number,
	adj.credit_gl_number,
	debit_volume_multiplier [Dr Vol Mul],credit_volume_multiplier [Cr Vol Mul],
	debit_remark [Debit Remark],credit_remark [Credit Remark],
	su.uom_name [UOM],
	su.source_uom_id [Uom ID],
	dbo.fnadateformat(adj.term_end) as [Term End],
	gl2.gl_account_number + '' ('' + gl2.gl_account_name +'')'' as [Dr GL No (-ve)],
	gl3.gl_account_number + '' ('' + gl3.gl_account_name +'')'' as [Cr GL No (-ve)],
	adj.debit_gl_number_minus,
	adj.credit_gl_number_minus
	from adjustment_default_gl_codes_detail adj 
	left join gl_system_mapping gl on gl.gl_number_id=adj.debit_gl_number
	left join gl_system_mapping gl1 on gl1.gl_number_id=adj.credit_gl_number
	left join gl_system_mapping gl2 on gl2.gl_number_id=adj.debit_gl_number_minus
	left join gl_system_mapping gl3 on gl3.gl_number_id=adj.credit_gl_number_minus
	left join source_uom su on su.source_uom_id=adj.uom_id
	
	where 1=1 '
	+case when @detail_id is not null then ' AND detail_id='+cast(@detail_id as varchar) else '' end
	

EXEC(@sqlstmt) 
END

else if @flag='i'
BEGIN
if exists(select * from adjustment_default_gl_codes_detail where default_gl_id=@default_gl_id and
		  ((@term_start between term_start and term_end) or	 (@term_end between term_start and term_end)))
begin
	Select 'Error' ErrorCode, 'Adjustment default gl code' Module, 'spa_get_adjustment_defaultGLCode', 'Invalid State' Status,   
		  ('Term Start and Term End has already been defined.')  Message,   
		  'Please select different term dates.' Recommendation    
	return	   
end
insert into 
	adjustment_default_gl_codes_detail
(
	default_gl_id,
	debit_gl_number,
	credit_gl_number,
	debit_volume_multiplier,
	credit_volume_multiplier,
	debit_remark,
	credit_remark,
	uom_id,
	term_Start,
	term_end,
	debit_gl_number_minus,
	credit_gl_number_minus,
	netting_debit_gl_number,
	netting_credit_gl_number,
	netting_debit_gl_number_minus,
	netting_credit_gl_number_minus

)
SELECT 
	@default_gl_id,
	@debit_gl_number,
	@credit_gl_number,
	@debit_volume_multiplier,
	@credit_volume_multiplier,
	@debit_remark,
	@credit_remark,
	@uom_id,
	@term_Start,
	@term_end,
	@debit_gl_number_minus,
	@credit_gl_number_minus,
	@netting_debit_gl_number,
	@netting_credit_gl_number,
	@netting_debit_gl_number_minus,
	@netting_credit_gl_number_minus


	If @@ERROR <> 0
		Begin
		Exec spa_ErrorHandler @@ERROR, 'Adjustment default gl code', 
		'spa_get_adjustment_defaultGLCode', 'DB Error', 
		'Failed updating record.', ''
		End
	Else
	Begin
		Exec spa_ErrorHandler 0, 'Adjustment default gl code', 

		'spa_get_adjustment_defaultGLCode', 'Success', 
		'Record successfully updated.', ''
	End

END
ELSE IF @flag='u'
BEGIN
update adjustment_default_gl_codes_detail	
set 
	debit_gl_number=@debit_gl_number,
	credit_gl_number=@credit_gl_number,
	debit_volume_multiplier=@debit_volume_multiplier,
	credit_volume_multiplier=@credit_volume_multiplier,
	debit_remark=@debit_remark,
	credit_remark=@credit_remark,
	uom_id=@uom_id,
	term_start=@term_start,
	term_end=@term_end,
	debit_gl_number_minus=@debit_gl_number_minus,
	credit_gl_number_minus=@credit_gl_number_minus,
	netting_debit_gl_number = @netting_debit_gl_number,
	netting_credit_gl_number = @netting_credit_gl_number,
	netting_debit_gl_number_minus = @netting_debit_gl_number_minus,
	netting_credit_gl_number_minus = @netting_credit_gl_number_minus

WHERE
	detail_id=@detail_id

	If @@ERROR <> 0
		Begin
		Exec spa_ErrorHandler @@ERROR, 'Adjustment default gl code', 
		'spa_get_adjustment_defaultGLCode', 'DB Error', 
		'Failed updating record.', ''
		End
	Else
	Begin
		Exec spa_ErrorHandler 0, 'Adjustment default gl code', 

		'spa_get_adjustment_defaultGLCode', 'Success', 
		'Record successfully updated.', ''
	End



END
ELSE IF @flag='d'
BEGIN
	DELETE from adjustment_default_gl_codes_detail where 
	detail_id=@detail_id

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
ELSE IF @flag = 'g'
BEGIN

	SELECT 
		detail_id ,
		default_gl_id,
	    dbo.FNAGetSQLStandardDate(adj.term_start) AS term_start,
	    dbo.FNAGetSQLStandardDate(adj.term_end) AS term_end,
		debit_gl_number,
		credit_gl_number,
		netting_debit_gl_number,
		netting_credit_gl_number,
		debit_gl_number_minus,
		credit_gl_number_minus,		
		netting_debit_gl_number_minus,
		netting_credit_gl_number_minus,
		debit_volume_multiplier,
	    credit_volume_multiplier,
	    debit_remark,
	    credit_remark,
		uom_id

	FROM adjustment_default_gl_codes_detail adj
	WHERE adj.default_gl_id = @default_gl_id 
	

	
	/*
	SELECT detail_id ,
			default_gl_id,
	       dbo.fnadateformat(adj.term_start) AS term_start,
	       dbo.fnadateformat(adj.term_end) AS term_end,
	       gl.gl_account_number + ' (' + gl.gl_account_name + ')' AS   dr_gl,
	       gl1.gl_account_number + ' (' + gl1.gl_account_name + ')' AS cr_gl,
	       gl4.gl_account_number + ' (' + gl4.gl_account_name + ')' AS net_dr_gl,
	       gl5.gl_account_number + ' (' + gl5.gl_account_name + ')' AS net_cr_gl,
	       
	       --adj.debit_gl_number [Debit GL Number],
	       --adj.credit_gl_number [Credit GL Number],
	       
	       gl2.gl_account_number + ' (' + gl2.gl_account_name + ')' AS dr_gl_neg,
	       gl3.gl_account_number + ' (' + gl3.gl_account_name + ')' AS cr_gl_neg,
	       gl6.gl_account_number + ' (' + gl6.gl_account_name + ')' AS net_dr_gl_neg,
	       gl7.gl_account_number + ' (' + gl7.gl_account_name + ')' AS net_cr_gl_neg,
	       --adj.debit_gl_number_minus [Debit GL Number Minus],
	       --adj.credit_gl_number_minus [Credit GL Number Minus],
	       debit_volume_multiplier,
	       credit_volume_multiplier,
	       debit_remark,
	       credit_remark,
	       su.uom_name
	FROM   adjustment_default_gl_codes_detail adj
	       LEFT JOIN gl_system_mapping gl
	            ON  gl.gl_number_id = adj.debit_gl_number
	       LEFT JOIN gl_system_mapping gl1
	            ON  gl1.gl_number_id = adj.credit_gl_number
	       LEFT JOIN gl_system_mapping gl2
	            ON  gl2.gl_number_id = adj.debit_gl_number_minus
	       LEFT JOIN gl_system_mapping gl3
	            ON  gl3.gl_number_id = adj.credit_gl_number_minus
			LEFT JOIN gl_system_mapping gl4
	            ON  gl4.gl_number_id = adj.netting_debit_gl_number
	       LEFT JOIN gl_system_mapping gl5
	            ON  gl5.gl_number_id = adj.netting_credit_gl_number
	       LEFT JOIN gl_system_mapping gl6
	            ON  gl6.gl_number_id = adj.netting_debit_gl_number_minus
	       LEFT JOIN gl_system_mapping gl7
	            ON  gl7.gl_number_id = adj.netting_credit_gl_number_minus
	                 
	       LEFT JOIN source_uom su
	            ON  su.source_uom_id = adj.uom_id
	WHERE adj.default_gl_id = @default_gl_id */
END



