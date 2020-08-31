IF OBJECT_ID(N'spa_Netted_Journal_Entry_Report', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_Netted_Journal_Entry_Report]
GO 

--@discount_option - takes two values 'd' or 'u', corresponding to 'discounted', 'undiscounted' 
--@summary_option - takes 'd', 's' corresponding to 'detail' , 'summary' report

-- EXEC spa_Netted_Journal_Entry_Report '1/31/2003', 'd', 's', 1
-- DROP PROC spa_Netted_Journal_Entry_Report
--===========================================================================================
create PROC [dbo].[spa_Netted_Journal_Entry_Report] 
	@as_of_date varchar(50), 
	@discount_option char(1), 
	@summary_option char(1),
	@netting_group_parent_id int=NULL,
	@round_value char(1) = '0',
	@export_type int = null

AS
SET NOCOUNT ON 
DECLARE @sql_stmt varchar(5000)


If @summary_option = 'd'
	SET @sql_stmt = 'select 	netting_parent_group_name As ParentGroupName, netting_group_name As GroupName,'
Else
	SET @sql_stmt = 'select 	netting_parent_group_name As ParentGroupName,'

SET @sql_stmt = @sql_stmt + ' gl_number As GLNumber,
		gl_account_name As AccountName,
		round(sum(debit_amount), ' + @round_value + ') As Debit,
		round(sum(credit_amount), ' + @round_value +') As Credit
	from ' + dbo.FNAGetProcessTableName(@as_of_date, 'report_netted_gl_entry') + ' report_netted_gl_entry '
 
SET @sql_stmt = @sql_stmt + ' where discount_option = ''' + @discount_option + 
		''' and as_of_date = ''' + @as_of_date + ''''

IF @netting_group_parent_id IS NOT NULL 
	SET @sql_stmt = @sql_stmt + ' AND netting_parent_group_id = ' + cast(@netting_group_parent_id as varchar)
Else
	SET @sql_stmt = @sql_stmt + ' AND netting_parent_group_id IS NULL ' 

If @summary_option = 's' 
	SET @sql_stmt = @sql_stmt + ' group by netting_parent_group_name, gl_number, gl_account_name'
Else
	SET @sql_stmt = @sql_stmt + ' group by netting_parent_group_name, netting_group_name, gl_number, gl_account_name'

EXEC(@sql_stmt)