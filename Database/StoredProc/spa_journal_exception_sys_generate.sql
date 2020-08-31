IF OBJECT_ID(N'spa_journal_exception_sys_generate', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_journal_exception_sys_generate]
GO 

CREATE PROCEDURE [dbo].[spa_journal_exception_sys_generate]
	@flag2 CHAR(1),
	@as_of_date  VARCHAR(50),
	@posting_group_id INT = NULL,
	@output_table_name VARCHAR(500) = NULL
AS
BEGIN

--print 'here'''

declare @exp_sql_stat varchar(8000), @entity_id int, @report_option char(1), @sub_id varchar(50), @strategy_id varchar(100), @book_id varchar(200), @reverse_type varchar(1), @hedge_type varchar(1), 
	@tenor_option varchar(1), @link_id varchar(100), @discounted_option varchar(1), @netting_parent_group int, @user_login_id varchar(50), @process_id varchar(500), @tempposttable varchar(5000), @return_value varchar(50)
	
	set @process_id=REPLACE(newid(),'-','_')		
	set @user_login_id=dbo.FNADBUser()
	set @tempposttable=dbo.FNAProcessTableName('journal_entry_posting', @user_login_id,@process_id)
	set @exp_sql_stat='create table '+ @tempposttable +'(
			sno int identity,
			description_field varchar(500),
			gl_number  varchar(250),
			account_name varchar(1000),
			debit_amount money,
			credit_amount money,
			entry_type varchar(50))'
	--print(@exp_sql_stat)
	exec(@exp_sql_stat)
	--print @tempposttable
	--return
	if @posting_group_id is not null 
	begin
		
		DECLARE journal_cursor_1 CURSOR FOR 
		select jg.posting_group_id, jg.netting_report_option, jg.fas_sub_id, jg.fas_strategy_id, jg.fas_book_id,jg.reverse_type, jg.hedge_type, jg.tenor_option , jg.netting_parent_group
		, jg.link_id, jg.discounted_option from journal_entry_posting_groups jg  left outer join journal_entry_posting jp
		on jg.posting_group_id=jp.posting_group_id and  jp.as_of_date= @as_of_date 
		left outer join gl_system_mapping gl on gl.gl_number_id=jp.gl_number_id where jp.posted_flag is null and  jg.posting_group_id=@posting_group_id
	end
	else
	begin
	DECLARE journal_cursor_1 CURSOR FOR 
	
		select jg.posting_group_id, jg.netting_report_option, jg.fas_sub_id, jg.fas_strategy_id, jg.fas_book_id,jg.reverse_type, jg.hedge_type, jg.tenor_option , jg.netting_parent_group
		, jg.link_id, jg.discounted_option from journal_entry_posting_groups jg  left outer join journal_entry_posting jp
		on jg.posting_group_id=jp.posting_group_id and  jp.as_of_date= @as_of_date 
		left outer join gl_system_mapping gl on gl.gl_number_id=jp.gl_number_id where jp.posted_flag is null
	end
	OPEN journal_cursor_1			
	FETCH NEXT FROM journal_cursor_1
	INTO  @entity_id, @report_option, @sub_id, @strategy_id, @book_id, @reverse_type, @hedge_type, @tenor_option, @netting_parent_group, @link_id, @discounted_option
	WHILE @@FETCH_STATUS = 0
	Begin	
-- 			EXEC spa_print  'spa_Create_MTM_Journal_Entry_Report_Reverse '''+ isnull(@as_of_date, 'NULL') +''','''+ isnull(@sub_id,  'null') +''','''+ isnull(@strategy_id, 'null') +''','''+ 
-- 				isnull(@book_id, 'null') +''','''+ isnull(@discounted_option, 'null') +''',''f'',''c'',''s'','''+ isnull(@reverse_type, 'null') +''',''NULL'','''+ isnull(@process_id, 'null') +''', ''ok'''

		if @report_option='j' 
		begin		
--			exec spa_Create_MTM_Journal_Entry_Report_Reverse  @as_of_date , @sub_id , @strategy_id , @book_id , @discounted_option ,'f', 'c','s', @reverse_type, @link_id , @process_id, 'ok'
			exec spa_Create_MTM_Journal_Entry_Report_Reverse  @as_of_date , @sub_id , @strategy_id , @book_id , @discounted_option ,@tenor_option, @hedge_type,'s', @reverse_type, @link_id , @process_id, 'ok'
			
		end
		else if @report_option='n' 
		begin 
			exec spa_Netted_Journal_Entry_Report_Reverse @as_of_date, @discounted_option, 's', @netting_parent_group,NULL, @process_id, 'ok'
		end	
		set @exp_sql_stat='update '+ @tempposttable +' set entry_type='+cast(@entity_id as varchar)+' where entry_type is null'
		exec(@exp_sql_stat)

	FETCH NEXT FROM journal_cursor_1
	INTO  @entity_id, @report_option, @sub_id, @strategy_id, @book_id, @reverse_type, @hedge_type, @tenor_option, @netting_parent_group, @link_id, @discounted_option
	End
	
CLOSE journal_cursor_1
DEALLOCATE journal_cursor_1
	
	if @output_table_name is null
	begin
	set @exp_sql_stat='select Status,group_name [Group],gl_account_number [Account Code],gl_account_name [Account Name],Debit,Credit
		 from (	select 
			case when jp.posting_group_id is null then ''Not prepared''
			when jp.posted_flag=''n'' then ''Not Posted'' 
			when jp.posted_flag=''v'' then ''Void'' else ''Posted'' end as Status,
			jg.group_name ,
			gl.gl_account_number, 
			gl.gl_account_name, round(debit_amount,2) Debit,round( credit_amount,2) Credit
			from journal_entry_posting_groups jg  left outer join journal_entry_posting jp
			on jg.posting_group_id=jp.posting_group_id and  jp.as_of_date='''+ @as_of_date +'''
			left outer join gl_system_mapping gl
			on gl.gl_number_id=jp.gl_number_id where (jp.posted_flag =''n'')'
			--  or jp.posted_flag is null
	if @posting_group_id is not null
		set @exp_sql_stat=@exp_sql_stat +'and  jg.posting_group_id='+cast(@posting_group_id as varchar(10))
	
	set @exp_sql_stat=@exp_sql_stat +'
			union
			select ''Not prepared'',jg.group_name [Group],gl_number,account_name,debit_amount,credit_amount
			from '+@tempposttable +'  tmp
			join journal_entry_posting_groups jg 
			on tmp.entry_type=jg.posting_group_id 
			)as p1 order by group_name
		'
	end
	else
	begin
		set @exp_sql_stat='select Status,group_name [Group],gl_account_number [Account Code],gl_account_name [Account Name],Debit,Credit into '+ @output_table_name +'
		 from (	select 
			case when jp.posting_group_id is null then ''Not prepared''
			when jp.posted_flag=''n'' then ''Not Posted'' 
			when jp.posted_flag=''v'' then ''Void'' else ''Posted'' end as Status,
			jg.group_name ,
			gl.gl_account_number, 
			gl.gl_account_name, round(debit_amount,2) Debit,round( credit_amount,2) Credit
			from journal_entry_posting_groups jg  left outer join journal_entry_posting jp
			on jg.posting_group_id=jp.posting_group_id and  jp.as_of_date='''+ @as_of_date +'''
			left outer join gl_system_mapping gl
			on gl.gl_number_id=jp.gl_number_id where (jp.posted_flag =''n'' )'
			--or jp.posted_flag is null
			if @posting_group_id is not null
				set @exp_sql_stat=@exp_sql_stat +'and  jg.posting_group_id='+cast(@posting_group_id as varchar(10))
			
			set @exp_sql_stat=@exp_sql_stat +'
					union
					select ''Not prepared'',jg.group_name [Group],gl_number,account_name,debit_amount,credit_amount
					from '+@tempposttable +'  tmp
					join journal_entry_posting_groups jg 
					on tmp.entry_type=jg.posting_group_id 
					)as p1 order by group_name'
	end
	exec(@exp_sql_stat)
	
end






