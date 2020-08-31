
IF OBJECT_ID(N'spa_Netted_Journal_Entry_Report_Reverse', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_Netted_Journal_Entry_Report_Reverse]
GO 

--exec spa_Netted_Journal_Entry_Report_Reverse '2004-12-31', 'd', 's', '10', 'y',NULL,NULL,'2', NULL
--exec spa_Netted_Journal_Entry_Report_Reverse '2004-12-31', 'd', 's', '10', 'p',NULL,NULL,'2', NULL
-- exec spa_Netted_Journal_Entry_Report_Reverse '2004-12-31', 'd', 's', '10', 'n',NULL,NULL,'2', NULL


--@discount_option - takes two values 'd' or 'u', corresponding to 'discounted', 'undiscounted' 
--@summary_option - takes 'd', 's' corresponding to 'detail' , 'summary' report

-- EXEC spa_Netted_Journal_Entry_Report '1/31/2003', 'd', 's', 1
-- EXEC spa_Netted_Journal_Entry_Report '1/31/2003', 'd', 'd', 1
-- EXEC spa_Netted_Journal_Entry_Report_Reverse '1/31/2003', 'd', 'd', 1, n
-- DROP PROC spa_Netted_Journal_Entry_Report_Reverse
-- select * from gl_system_mapping
--===========================================================================================
CREATE PROC [dbo].[spa_Netted_Journal_Entry_Report_Reverse] 	
	@as_of_date VARCHAR(50), 
	@discount_option CHAR(1), 
	@summary_option CHAR(1),
	@netting_group_parent_id INT = NULL,
	@reverse_entries VARCHAR(1) = 'n',
	@output_table_name VARCHAR(300) = NULL,
	@return_value VARCHAR(50) = NULL,
	@round_value CHAR(1) = '0',
	@export_type INT = NULL,
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL
AS
SET NOCOUNT ON 

--------------------------------------TEST -------------------------------------
--DECLARE @as_of_date varchar(50) 
--DECLARE @discount_option char(1) 
--DECLARE @summary_option char(1)
--DECLARE @netting_group_parent_id int
--DECLARE @reverse_entries varchar(1)
--DECLARE @output_table_name varchar(150)
--DECLARE @return_value varchar(50)
--DECLARE @round_value char(1)
--DECLARE @export_type int 
--
--SET @as_of_date = '2004-12-31'
--SET @discount_option = 'u'
--SET @summary_option = 's'
--SET @netting_group_parent_id = 10 
--SET @reverse_entries = 'n'
--SET @output_table_name = NULL
--SET @round_value = '2'
--SET @export_type = 1376
--
--
--drop table #current_entries_summary
--drop table #prior_entries_summary
--drop table #current_entries_detail
--drop table #prior_entries_detail
--drop table #drcr_one
--------------------------------------END TEST -------------------------------------


/*******************************************1st Paging Batch START**********************************************/
 
DECLARE @str_batch_table VARCHAR (8000)
 
DECLARE @user_login_id VARCHAR (50)
 
DECLARE @sql_paging VARCHAR (8000)
 
DECLARE @is_batch BIT
 
SET @str_batch_table = ''
 
SET @user_login_id = dbo.FNADBUser() 
 
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 
 
IF @is_batch = 1
 
BEGIN
 
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
 
END
 
/*******************************************1st Paging Batch END**********************************************/

DECLARE @period_entry varchar(1)
set @period_entry = 'y' -- always net debit and credit for same gl code

--temp solution
--set @period_entry = 'y'

If @reverse_entries = 'p'
BEGIN
   set @reverse_entries = 'y'
   set @period_entry = 'y'
END
--declare @user_login_id varchar(30)
declare @process_id varchar(50)
Declare @tmp_process_table varchar(200)

SET @process_id = REPLACE(newid(),'-','_')
set @user_login_id=dbo.FNADBUser()
SET @tmp_process_table = dbo.FNAProcessTableName('tmp_process_table', @user_login_id, @process_id)


Create TABLE #prior_entries_summary
(
ParentGroupName varchar(100),
GLNumber varchar(150),
AccountName varchar(250) COLLATE DATABASE_DEFAULT,
Debit float,
Credit float,
)

CREATE TABLE #prior_entries_detail
(
ParentGroupName varchar(100) COLLATE DATABASE_DEFAULT,
GroupName varchar(100) COLLATE DATABASE_DEFAULT,
GLNumber varchar(150) COLLATE DATABASE_DEFAULT,
AccountName varchar(250) COLLATE DATABASE_DEFAULT,
Debit float,
Credit float,
)

CREATE TABLE #current_entries_summary
(
ParentGroupName varchar(100) COLLATE DATABASE_DEFAULT,
GLNumber varchar(150) COLLATE DATABASE_DEFAULT,
AccountName varchar(250) COLLATE DATABASE_DEFAULT,
Debit float,
Credit float,
)

CREATE TABLE #current_entries_detail
(
ParentGroupName varchar(100) COLLATE DATABASE_DEFAULT,
GroupName varchar(100) COLLATE DATABASE_DEFAULT,
GLNumber varchar(150) COLLATE DATABASE_DEFAULT,
AccountName varchar(250) COLLATE DATABASE_DEFAULT,
Debit float,
Credit float,
)

DECLARE @prior_as_of_date varchar(20)


set @prior_as_of_date  = NULL
If @reverse_entries ='y'
BEGIN 
--	create table #max_date (as_of_date datetime)
--	declare @st_where varchar(100)
--	set @st_where ='as_of_date<'''+@as_of_date+''''
--	insert into #max_date (as_of_date) exec  spa_get_Script_ProcessTableFunc 'max','as_of_date','report_measurement_values',@st_where
--	select @prior_as_of_date = dbo.FNAGetSQLStandardDate(max(as_of_date)) from #max_date
--	select @prior_as_of_date  = dbo.FNAGetSQLStandardDate(max(as_of_date)) from report_measurement_values where as_of_date <  @as_of_date 
		
	select @prior_as_of_date = dbo.FNAGetSQLStandardDate(max(as_of_date)) from measurement_run_dates where as_of_date < @as_of_date 
	
		

	If @summary_option = 's'
		INSERT #prior_entries_summary
		EXEC 	spa_Netted_Journal_Entry_Report @prior_as_of_date,  @discount_option, 
				@summary_option,@netting_group_parent_id,@round_value, @export_type
	Else
		INSERT #prior_entries_detail
		EXEC 	spa_Netted_Journal_Entry_Report @prior_as_of_date,  @discount_option, 
				@summary_option,@netting_group_parent_id,@round_value, @export_type
		 
-- 	EXEC spa_Create_MTM_Journal_Entry_Report_Reverse dbo.FNAGetSQLStandardDate(@prior_as_of_date), @sub_entity_id, 
-- 	@strategy_entity_id, @book_entity_id, @discount_option, @settlement_option, @report_type, @summary_option, 0 
END		

If @summary_option = 's'
	INSERT #current_entries_summary
	EXEC 	spa_Netted_Journal_Entry_Report @as_of_date,  @discount_option, 
			@summary_option,@netting_group_parent_id,@round_value, @export_type
Else
	INSERT #current_entries_detail
	EXEC 	spa_Netted_Journal_Entry_Report @as_of_date,  @discount_option, 
			@summary_option,@netting_group_parent_id,@round_value, @export_type


DECLARE @sql_stmt varchar(8000)

if @export_type is null
	set @export_type = -1


If @export_type = 1375
BEGIN
	set @sql_stmt = ' 
		SELECT 	1 [Connector],
				case when (Debit > 0) then 40 
					 when (Credit >= 0) then 50 
				else -111 end [Bksl],
				GLNumber [Rek],		
				Debit As [Debit],
				Credit  As [Credit],
				case when (Debit > 0) then Debit
					 when (Credit >= 0) then -1 * Credit 
				else 0 end [Bedrag],
				isnull(AccountName + '' per '' + cast(month(''' + @as_of_date + ''') as varchar) + ''.'' + 
							substring(cast(year(''' + @as_of_date + ''') as varchar), 3, 2), '''') [Postekst],
				isnull(gl_account_desc1, '''') [Profitc.],
				isnull(gl_account_desc2, '''') [Product] into '+@tmp_process_table+' 

	FROM 	(
		SELECT 	ParentGroupName,
			GLNumber,
			AccountName,

		CASE WHEN  (''' + @period_entry + '''  = ''n'') then
			sum(Debit)
		ELSE
			CASE WHEN(sum(Debit) >= sum(Credit)) THEN sum(Debit) - Sum(Credit)
			ELSE	0
			END
		END As [Debit],
		CASE WHEN  (''' + @period_entry + '''  = ''n'') then
			sum(Credit)
		ELSE
			CASE WHEN(sum(Debit) >= sum(Credit)) THEN 0
			ELSE	sum(Credit) - Sum(Debit)
			END
		END
		 As [Credit]
		FROM (SELECT 	ParentGroupName,GLNumber,
			AccountName,
			Credit As [Debit],
			Debit As [Credit] from #prior_entries_summary
		UNION
		SELECT 	ParentGroupName,
			GLNumber,
			AccountName,
			Debit,
			Credit
		FROM #current_entries_summary
		) entries 
	GROUP BY ParentGroupName, GLNumber, AccountName) xx LEFT OUTER JOIN
	gl_system_mapping g ON g.gl_account_number = xx.GLNumber AND	
						g.gl_account_name = xx.AccountName
--	(select g.* from 
--		(select gl_account_number, max(gl_number_id) gl_number_id from gl_system_mapping group by gl_account_number) mg inner join
--		gl_system_mapping g on mg.gl_number_id = g.gl_number_id) gsm ON gsm.gl_account_number = xx.GLNumber
	where Debit <> Credit
	'
	--PRINT @sql_stmt
END
Else If @export_type = 1376
BEGIN
--  exec spa_Netted_Journal_Entry_Report_Reverse '2004-12-31', 'd', 's', '9', 'n',NULL,NULL,'2', '1375'

	set @sql_stmt = ' 
		SELECT 	8110 [Bedrijfs- nummer],
				replace(dbo.FNADateFormat(''' + @as_of_date + '''), ''-'', ''.'')  [Document datum],
				replace(dbo.FNADateFormat(getdate()), ''-'', ''.'') [Boek- datum],
				''TR'' [Document  soort],
				''EUR'' [Valuta],
				'''' [Referentie],
				'''' [Referentie1],
				case when (Debit > 0) then 40 
					 when (Credit >= 0) then 50 
				else -111 end [D/C],
				GLNumber [Rekening- nummer],		
				Debit + Credit As [Bedrag],
				'''' [BTW code],
				'''' [BTW bedrag],
				'''' [Kosten- plaats],
				isnull(gl_account_desc1, '''') [Profit- center],
				'''' [Toe- wijzing],
				'''' [Interne Order],
				'''' [Bank zakenpartner],
				'''' [Niet gebruiken],
				isnull(gl_account_name, '''') [Positie tekst],
				'''' [Hoeveelhden],
				'''' [Eenheid],
				'''' [Business area],
				'''' [Bedrijfsnummer item],
				'''' [Betaal- conditie],
				'''' [Referentie veld 1],
				'''' [Referentie veld 2],
				'''' [Referentie veld 3],
				'''' [Netwerk plannummer],
				'''' [Operatie nummer]	,
				'''' [WBS element],
				'''' [Verbruiksmaand Delivery period],
				'''' [Afrekengroep Billing group],
				'''' [Verrekenpartij Billing partner],
				isnull(gl_account_desc2, '''') [Flow code],
				'''' [Betaal- weg],
				'''' [Partner- maatsch],
				'''' [Artikel] 
 into '+@tmp_process_table+'  
	FROM 	(
		SELECT 	ParentGroupName,
			GLNumber,
			AccountName,

		CASE WHEN  (''' + @period_entry + '''  = ''n'') then
			sum(Debit)
		ELSE
			CASE WHEN(sum(Debit) >= sum(Credit)) THEN sum(Debit) - Sum(Credit)
			ELSE	0
			END
		END As [Debit],
		CASE WHEN  (''' + @period_entry + '''  = ''n'') then
			sum(Credit)
		ELSE
			CASE WHEN(sum(Debit) >= sum(Credit)) THEN 0
			ELSE	sum(Credit) - Sum(Debit)
			END
		END
		 As [Credit]
		FROM (SELECT 	ParentGroupName,GLNumber,
			AccountName,
			Credit As [Debit],
			Debit As [Credit] from #prior_entries_summary
		UNION
		SELECT 	ParentGroupName,
			GLNumber,
			AccountName,
			Debit,
			Credit
		FROM #current_entries_summary
		) entries 
	GROUP BY ParentGroupName, GLNumber, AccountName) xx LEFT OUTER JOIN
	gl_system_mapping g ON g.gl_account_number = xx.GLNumber AND	
						g.gl_account_name = xx.AccountName
--	(select g.* from 
--		(select gl_account_number, max(gl_number_id) gl_number_id from gl_system_mapping group by gl_account_number) mg inner join
--		gl_system_mapping g on mg.gl_number_id = g.gl_number_id) gsm ON gsm.gl_account_number = xx.GLNumber
	where Debit <> Credit
	'

	--PRINT @sql_stmt
END

Else If @summary_option = 's'
BEGIN
	set @sql_stmt = ' 
	SELECT 	ParentGroupName as [Parent Group Name],
		GLNumber as [GL Number],
		AccountName as [Account Name],
		Debit As [Debit],
		Credit  As [Credit] 
	into '+@tmp_process_table+' 
	FROM 	(
		SELECT 	ParentGroupName,
			GLNumber,
			AccountName,

		CASE WHEN  (''' + @period_entry + '''  = ''n'') then
			sum(Debit)
		ELSE
			CASE WHEN(sum(Debit) >= sum(Credit)) THEN sum(Debit) - Sum(Credit)
			ELSE	0
			END
		END As [Debit],
		CASE WHEN  (''' + @period_entry + '''  = ''n'') then
			sum(Credit)
		ELSE
			CASE WHEN(sum(Debit) >= sum(Credit)) THEN 0
			ELSE	sum(Credit) - Sum(Debit)
			END
		END
		 As [Credit]
		FROM (SELECT 	ParentGroupName,GLNumber,
			AccountName,
			Credit As [Debit],
			Debit As [Credit] from #prior_entries_summary
		UNION
		SELECT 	ParentGroupName as [Parent Group Name] ,
			GLNumber as [GL Number],
			AccountName as [Account Name],
			Debit,
			Credit
		FROM #current_entries_summary
		) entries
	GROUP BY ParentGroupName, GLNumber, AccountName) xx
	where Debit <> Credit'
END
Else
BEGIN
	set @sql_stmt = ' 
	SELECT 	ParentGroupName as [Parent Group Name], GroupName as [Group Name],
		GLNumber as [GL Number],
		AccountName as [Account Name],
		Debit  As [Debit],
		Credit As [Credit] 
 into '+@tmp_process_table+'  
	FROM 	(
		SELECT 	ParentGroupName, GroupName,
			GLNumber,
			AccountName,
					CASE WHEN  (''' + @period_entry + '''  = ''n'') then
			sum(Debit)
		ELSE
			CASE WHEN(sum(Debit) >= sum(Credit)) THEN sum(Debit) - Sum(Credit)
			ELSE	0
			END
		END As [Debit],
		CASE WHEN  (''' + @period_entry + ''' = ''n'') then
			sum(Credit)
		ELSE
			CASE WHEN(sum(Debit) >= sum(Credit)) THEN 0
			ELSE	sum(Credit) - Sum(Debit)
			END
		END
		 As [Credit]
		FROM (select ParentGroupName,GroupName,GLNumber,
			AccountName,
			Credit As [Debit],
			Debit As [Credit] from #prior_entries_detail
		UNION
		SELECT 	ParentGroupName as [Parent Group Name], GroupName as [Group Name],
			GLNumber as [GL Number],
			AccountName as [Account Name],
			Debit,
			Credit
		FROM #current_entries_detail
		) entries	
	GROUP BY ParentGroupName, GroupName, GLNumber, AccountName) xx
	where Debit <> Credit'
END

exec(@sql_stmt)

--exec('select * from '+@tmp_process_table)
declare @dif float
If @export_type is null or @export_type <> 1376
begin 
	create table #dr_cr(Dr_amt float,Cr_amt float)
	exec('insert into #dr_cr select sum(debit) db,sum(credit) cr from '+@tmp_process_table)
	select @dif=Dr_amt-cr_amt from #dr_cr
	if @dif > 0 and @dif < 0.99
		set @sql_stmt='update top (1) '+@tmp_process_table+'  set debit=debit-'+cast(@dif as varchar)+' where debit >'+cast(@dif as varchar)
	else if @dif > -0.99 and @dif < 0 
		set @sql_stmt='update top (1) '+@tmp_process_table+'  set credit=credit+'+cast(@dif as varchar)+' where credit > -1*'+cast(@dif as varchar)
	else 
		set @sql_stmt= ''

	if @sql_stmt <> ''
		exec(@sql_stmt)

end
else if @export_type = 1376
begin
	create table #drcr_one(amt float)
	set @sql_stmt='insert into #drcr_one select sum(case when [D/C]=40 then 1 else -1 end * bedrag) db from '+@tmp_process_table
	exec(@sql_stmt)
	select @dif=amt from #drcr_one
	if @dif > 0 and @dif < 0.99
		set @sql_stmt='update top (1) '+@tmp_process_table+'  set bedrag=bedrag+'+cast(@dif as varchar)+' where bedrag >'+cast(@dif as varchar)+ ' and [D/C]=40'
	else if @dif > -0.99 and @dif < 0 
		set @sql_stmt='update top (1) '+@tmp_process_table+'  set bedrag=bedrag+'+cast(@dif as varchar)+' where bedrag >'+cast(@dif as varchar)+ ' and [D/C]=50'
	else 
		set @sql_stmt= ''

	if @sql_stmt <> ''
		exec(@sql_stmt)

end
set @sql_stmt='select * ' + @str_batch_table + ' from '+@tmp_process_table


--print @sql_stmt
if @output_table_name is null
	exec (@sql_stmt)
ELSE IF @output_table_name = 'fas_net_jr_entry_temp_table'
BEGIN
	SET @output_table_name = dbo.FNAProcessTableName('journal_entry_posting', dbo.FNADBUser(), @output_table_name)
	EXEC ('INSERT INTO ' + @output_table_name + '(parent_group_name, group_name, gl_number, account_name, debit, credit) ' + @sql_stmt)
END
else
begin	
	set @output_table_name=dbo.FNAProcessTableName('journal_entry_posting', dbo.FNADBUser(),@output_table_name)
	exec('delete '+@output_table_name +' where entry_type=''s''')
	exec ('INSERT INTO ' + @output_table_name   + '(description_field,gl_number,account_name,debit_amount,credit_amount) ' + @sql_stmt)
	if @return_value is null
	begin
	If @@Error <> 0
		Exec spa_ErrorHandler @@Error, 'spa_Netted_Journal_entry_report_reverse', 
				'spa_Netted_Journal_entry_report_reverse', 'DB Error', 
				'Failed to Updated Temp Table.', ''
		Else
		Exec spa_ErrorHandler 0, 'spa_Netted_Journal_entry_report_reverse', 
				'spa_Netted_Journal_entry_report_reverse', 'Success', 
				'Updated Temp Table.', ''
	end
end

/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board
 
IF @is_batch = 1
 
BEGIN
 
	SELECT @str_batch_table = dbo.FNABatchProcess ('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
 
	EXEC (@str_batch_table)
 
	SELECT @str_batch_table = dbo.FNABatchProcess ('c', @batch_process_id, @batch_report_param, 
				   GETDATE(), 'spa_Netted_Journal_Entry_Report_Reverse', 'Netted Journal Entry Report') --TODO: modify sp and report name
 
	EXEC (@str_batch_table)
 
	RETURN
 
END
 /*******************************************2nd Paging Batch END**********************************************/






