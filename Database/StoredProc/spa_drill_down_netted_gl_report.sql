IF OBJECT_ID(N'spa_drill_down_netted_gl_report', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_drill_down_netted_gl_report]
 GO 
--

CREATE procedure [dbo].[spa_drill_down_netted_gl_report]
		@as_of_date varchar(20), 
		@drill_netting_parent_group_id int = NULL,
		@drill_discount_option varchar(1) = NULL,
		@drill_gl_number varchar(5000) = NULL,
		@drill_counterparty_id INT=null,
		@batch_process_id varchar(50)=NULL,	
		@batch_report_param varchar(1000)=NULL
as
SET NOCOUNT ON 


-----------------------test criteria
--DECLARE	@as_of_date varchar(20), 
--		@drill_netting_parent_group_id int, @drill_discount_option varchar(1),
--		@drill_gl_number varchar(2000), @temp_table_name varchar(100),
--		@batch_process_id varchar(50),	@batch_report_param varchar(1000)
--
--SET		@as_of_date = '2004-12-31'
--SET		@drill_netting_parent_group_id = 10
--SET		@drill_discount_option = 'u'
--SET		@drill_gl_number = '''1-10-20-20'', ''1-10-20-19'''
--SET		@temp_table_name =null
--SET		@batch_process_id =NULL	
--SET		@batch_report_param =NULL

-----------------------end of test criteria


DECLARE @process_id varchar(50)
DECLARE @user_login_id varchar(50)
DECLARE @drill_tbl_output varchar(128) ,@sub_id VARCHAR(max)

set @process_id = REPLACE(newid(),'-','_')
set @user_login_id = dbo.FNADBUser()

SET @drill_tbl_output = dbo.FNAProcessTableName('drill_net_gl', @user_login_id, @process_id)

declare @str_batch_table varchar(max)
SET @str_batch_table=''        
IF @batch_process_id is not null        
	 SELECT @str_batch_table=dbo.FNABatchProcess('s',@batch_process_id,@batch_report_param,NULL,NULL,NULL)         

SET @sub_id=NULL

--select n.fas_subsidiary_id  FROM  netting_group_parent_subsidiary  n
--inner join  fas_subsidiaries s on n.fas_subsidiary_id=isnull(s.fas_subsidiary_id,n.fas_subsidiary_id) AND s.fas_subsidiary_id <> -1 
--and n.netting_parent_group_id=19


select @sub_id=isnull(@sub_id+',','') +cast(fas_subsidiary_id AS VARCHAR) FROM  netting_group_parent_subsidiary where netting_parent_group_id=@drill_netting_parent_group_id

IF ISNULL(@sub_id,'')='' 
BEGIN
	SET @sub_id=NULL
	select @sub_id=isnull(@sub_id+',','') +cast(fas_subsidiary_id AS VARCHAR) FROM  fas_subsidiaries WHERE fas_subsidiary_id <> -1 
end
--SELECT @sub_id
EXEC spa_Calc_Netting_Measurement @process_id, @sub_id,@as_of_date, 0, @user_login_id, @drill_tbl_output, @drill_netting_parent_group_id, @drill_discount_option, @drill_gl_number,@drill_counterparty_id

EXEC ('select [id] [ID], link_deal_flag [Link Deal Flag], deal_ref_id [Deal Reference ID],term_month [Term Month], Netting_Parent_Group_ID [Netting Parent Group ID], 
Netting_Parent_Group_Name [Netting Parent Group Name], Netting_Group_Name [Netting Group Name], gl_account_number [GL Account Number],
 gl_account_name [GL Account Name], deal_mtm [Deal MTM],Debit_Amount [Debit Amount],Credit_Amount [Credit Amount],
hedge_asset_test [Hedge Asset Test], short_term_test [Short Term Test],counterparty_name [Counterparty Name], netting_counterparty_name [Netting Counterparty Name],
counterparty_type [Counterparty Type],source_deal_type_name [Source Deal Type Name],source_deal_sub_type_name [Source Deal Sub Type Name],
curve_name [Curve Name], commodity_name [Commodity Name],legal_entity_name [Legal Entity Name], agreement_name [Agreement Name],
GL_Number_ID [GL Number ID], netting_counterparty_id [Netting Counterparty ID] ' + @str_batch_table + ' FROM ' + @drill_tbl_output)

declare @deleteStmt varchar(500)
SET @deleteStmt = dbo.FNAProcessDeleteTableSql(@drill_tbl_output)
exec (@deleteStmt)

--*****************FOR BATCH PROCESSING**********************************            
IF  @batch_process_id is not null        
BEGIN        
	SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)         
	EXEC(@str_batch_table)        
	declare @report_name varchar(100)
	set @report_name='Drill down Netted GL Report'
	SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_drill_down_netted_gl_report',@report_name)         
	EXEC(@str_batch_table)        
    
END    













