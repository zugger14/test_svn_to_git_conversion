IF OBJECT_ID(N'spa_journal_entry_posting_groups', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_journal_entry_posting_groups]
GO

--spa_journal_entry_posting_groups 's',NULL,NULL,'j'

CREATE PROCEDURE [dbo].[spa_journal_entry_posting_groups]
	@flag VARCHAR(2),
	@posting_group_id INT = NULL ,
	@group_name VARCHAR(500) = NULL,
	@netting_report_option CHAR(1) = NULL,
	@fas_sub_id VARCHAR(100) = NULL,
	@fas_strategy_id VARCHAR(100) = NULL,
	@fas_book_id VARCHAR(100) = NULL,
	@reverse_type CHAR(1) = NULL,
	@hedge_type CHAR(1) = NULL,
	@tenor_option CHAR(1) = NULL,
	@link_id VARCHAR(100) = NULL,
	@discounted_option CHAR(1) = NULL,
	@netting_parent_group CHAR(10) = NULL
AS
BEGIN
	DECLARE @sql_stat VARCHAR(8000)

	IF @flag = 'a'
	BEGIN
		SELECT *
		FROM   journal_entry_posting_groups
		WHERE  posting_group_id = CAST(@posting_group_id AS VARCHAR(10))
	END
	ELSE 
	IF @flag = 's'
	BEGIN
	    SET @sql_stat = 'select posting_group_id as [Posting Group ID], 
		group_name as [Group Name],
		Case netting_report_option When '+'''j'''+ ' Then '+'''Journal Entry Report'''+' Else '+'''Netted Journal Entry Report'''+' End as [Netting Report Option],
		fas_sub_id as [Subsidiary ID], 
		fas_strategy_id as [Strategy ID], 
		fas_book_id as [Book ID],  
		Case reverse_type When '+'''y'''+' Then '+'''Cumulative entry'''+' When '+'''p'''+' Then '+'''Period entry'''+' Else '+'''None'''+'  End as [Reverse Type], 
		Case hedge_type  When '+'''a'''+' Then '+'''All'''+' When '+'''c'''+' Then '+'''Cash Flow'''+' When '+'''f'''+' Then '+'''Fair Value'''+' Else '+'''MTM'''+' End as [Hedge Type],
		Case tenor_option When '+'''s'''+' Then '+'''Show Settlement Values Only'''+' When '+'''c'''+' Then '+'''Show Current and Forward Months Only'''+' When '+'''f'''+' Then '+'''Show Forward Month Only'''+' Else '+'''Show All'''+' End as [Tenor Option],
		link_id as [Link ID], 
             		Case discounted_option When '+'''d''' + ' Then ' + '''Show Present Value'''+' Else '+'''Show Future Value''' + 'End as [Discounted Option], 
		netting_parent_group as [Netting Parent Group] from journal_entry_posting_groups'
		if @netting_report_option is not null
			set @sql_stat= @sql_stat +' where netting_report_option='''+ @netting_report_option +''''
		exec(@sql_stat)
	end
	else if @flag='i'
	begin
		insert into journal_entry_posting_groups 
		(
		group_name,
		netting_report_option,
		fas_sub_id,
		fas_strategy_id,
		fas_book_id,
		reverse_type,
		hedge_type,
		tenor_option,
		link_id,
		discounted_option,
		netting_parent_group
		)
		values
		(
		@group_name,
		@netting_report_option,
		@fas_sub_id,
		@fas_strategy_id,
		@fas_book_id,
		@reverse_type,
		@hedge_type,
		@tenor_option,
		@link_id,
		@discounted_option,
		@netting_parent_group
		)

		If @@Error <> 0
		Exec spa_ErrorHandler @@Error, 'journal_entry_posting_groups', 
				'spa_journal_entry_posting_groups', 'DB Error', 
				'Failed to insert value.', ''
		Else
		Exec spa_ErrorHandler 0, 'journal_entry_posting_groups', 
				'spa_journal_entry_posting_groups', 'Success', 
				'Value inserted.', ''
		
	end
	else if @flag='u'
	begin
		update journal_entry_posting_groups set 
		group_name=@group_name,
		netting_report_option=@netting_report_option,
		fas_sub_id=@fas_sub_id,
		fas_strategy_id=@fas_strategy_id,
		fas_book_id=@fas_book_id,
		reverse_type=@reverse_type,
		hedge_type=@hedge_type,
		tenor_option=@tenor_option,
		link_id=@link_id,
		discounted_option=@discounted_option,

		netting_parent_group=@netting_parent_group
		where posting_group_id=@posting_group_id


		If @@Error <> 0
		Exec spa_ErrorHandler @@Error, 'journal_entry_posting_groups', 
				'spa_journal_entry_posting_groups', 'DB Error', 
				'Failed to update value.', ''
		Else
		Exec spa_ErrorHandler 0, 'journal_entry_posting_groups', 
				'spa_journal_entry_posting_groups', 'Success', 
				'Value updated.', ''
	end	
	else if @flag='d'
	begin
		
		set @sql_stat='delete journal_entry_posting_groups where posting_group_id='+ cast( @posting_group_id as varchar(10))
		exec(@sql_stat)

		If @@Error <> 0
		Exec spa_ErrorHandler @@Error, 'journal_entry_posting_groups', 
				'spa_journal_entry_posting_groups', 'DB Error', 
				'Failed to delete value.', ''
		Else
		Exec spa_ErrorHandler 0, 'journal_entry_posting_groups', 
				'spa_journal_entry_posting_groups', 'Success', 
				'Value deleted.', ''
	end 
end




