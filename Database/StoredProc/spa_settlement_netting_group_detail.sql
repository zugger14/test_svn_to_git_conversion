/****** Object:  StoredProcedure [dbo].[spa_settlement_netting_group_detail]    Script Date: 11/17/2012 10:56:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_settlement_netting_group_detail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_settlement_netting_group_detail]
GO

/****** Object:  StoredProcedure [dbo].[spa_settlement_netting_group_detail]    Script Date: 11/17/2012 10:56:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spa_settlement_netting_group_detail]
@flag varchar(1),
@netting_group_detail_id int=null,
@netting_group_id varchar(100)=null ,
@contract_detail_id int =null
as

declare @sql_stmt varchar(1000)
if @flag ='s'
Begin

	set @sql_stmt ='
	SELECT 
		netting_group_detail_id [Netting Group Detail ID],
		netting_group_id [Group ID],
		cgd.id [ID],
		cg.contract_name [Contract Name],
		sdv.code [Code],
		sdv.description [Description],
		contract_detail_id [Contract Detail ID]
		
	FROM 
		contract_group_detail  cgd 
		JOIN static_data_value sdv ON cgd.invoice_line_item_id = sdv.value_id
		JOIN contract_group cg ON cgd.contract_id  = cg.contract_id
		JOIN settlement_netting_group_detail sng ON sng.contract_detail_id = cgd.id
	where 1=1'
	+CASE WHEN @netting_group_id IS NOT NULL
	THEN 'AND sng.netting_group_id='+cast(@netting_group_id as varchar) ELSE '' END


exec spa_print @sql_stmt
--print 'Test';
exec(@sql_stmt)
--print 'Test11';
END

Else if @flag ='a'
Begin

--	set @sql_stmt = 'select netting_group_detail_id,netting_group_id ,contract_detail_id 
--	from settlement_netting_group_detail where netting_group_detail_id='+ cast(@netting_group_detail_id as varchar)

set @sql_stmt ='SELECT netting_group_detail_id,netting_group_id,contract_detail_id,cg.contract_name
FROM 
contract_group_detail  cgd 
JOIN static_data_value sdv
ON 
cgd.invoice_line_item_id = sdv.value_id
JOIN contract_group cg 
ON 
cgd.contract_id  = cg.contract_id
JOIN settlement_netting_group_detail sng
ON 
sng.contract_detail_id = cgd.id
where netting_group_detail_id='+ cast(@netting_group_detail_id as varchar)


EXEC spa_print @sql_stmt
exec(@sql_stmt)

END

Else if @flag='i'

Begin
	insert into settlement_netting_group_detail(netting_group_id,contract_detail_id)
	values(@netting_group_id,@contract_detail_id)

If @@ERROR <> 0
	begin
		Exec spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
				"spa_company_type_template", "DB Error", 
				"Insert of spa_company_type_template  failed.", ''
		return
	end

		else Exec spa_ErrorHandler 0, 'Settlement Netting Group', 
				'spa_settlement_netting_group_detail', 'Success', 
				'spa_settlement_netting_group_detail  successfully inserted.', ''

End
Else if @flag='u'

Begin

update settlement_netting_group_detail set 
											
	netting_group_id = cast(@netting_group_id as int),
	contract_detail_id = cast(@contract_detail_id as int)
											
where netting_group_detail_id=@netting_group_detail_id

If @@ERROR <> 0
	begin
		Exec spa_ErrorHandler @@ERROR, 'Settlement Netting Group Detail', 
				'spa_settlement_netting_group_detail", "DB Error', 
				'Update of spa_settlement_netting_group_detail  failed.', ''
		return
	end

		else Exec spa_ErrorHandler 0, 'Settlement Netting Group Detail', 
				'spa_settlement_netting_group_detail', 'Success', 
				'spa_settlement_netting_group_detail  successfully updated.', ''


End
Else if @flag='d'
Begin
		delete from settlement_netting_group_detail where netting_group_detail_id=@netting_group_detail_id
		
If @@ERROR <> 0
	begin
		Exec spa_ErrorHandler @@ERROR, 'Settlement Netting Group Detail', 
				'spa_settlement_netting_group_detail", "DB Error', 
				'Update of spa_settlement_netting_group_detail  failed.', ''
		return
	end

		else Exec spa_ErrorHandler 0, 'Settlement Netting Group Detail', 
				'spa_settlement_netting_group_detail', 'Success', 
				'spa_settlement_netting_group_detail  successfully updated.', ''


End













GO


