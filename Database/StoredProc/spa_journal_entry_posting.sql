IF OBJECT_ID(N'spa_journal_entry_posting', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_journal_entry_posting]
GO 

CREATE PROCEDURE [dbo].[spa_journal_entry_posting]
	@flag CHAR(1),
	@flag2 CHAR(1) = NULL,
	@journal_entry_posting_id INT = NULL ,
	@as_of_date VARCHAR(50) = NULL,
	@gl_number_id INT = NULL,
	@debit_amount FLOAT = NULL,
	@credit_amount FLOAT = NULL,
	@posted_flag VARCHAR(1) = NULL,
	@entry_type VARCHAR(1) = NULL,
	@description_field VARCHAR(500) = NULL,
	@posting_group_id INT = NULL,
	@output_table_name VARCHAR(500) = NULL
AS
BEGIN
	DECLARE @exp_sql_stat VARCHAR(8000)
	
	IF @flag = 's'
	BEGIN
	    IF @flag2 IS NULL
	    BEGIN
	        SET @exp_sql_stat = 'select 
						gl.gl_account_number [GL Number], gl.gl_account_name  [Account Name], 
						
						 round(jp.debit_amount,2) Debit,round( jp.credit_amount,2) Credit, jp.Description_field Description
						from journal_entry_posting jp
						left outer join gl_system_mapping gl
						on gl.gl_number_id=jp.gl_number_id where jp.as_of_date='''+ @as_of_date +''''
				
				if @posting_group_id is not null
					set @exp_sql_stat=@exp_sql_stat +'and  jp.posting_group_id='+cast(@posting_group_id as varchar(10))
				exec(@exp_sql_stat)
			end
			if @flag2 is not null
			Begin
				set @exp_sql_stat='
				select 
				case when jp.posting_group_id is null then ''Not prepared''
				when jp.posted_flag=''n'' then ''Not Posted'' 
				when jp.posted_flag=''v'' then ''Void'' else ''Posted'' end as Status,
				jg.group_name [Group],
				gl.gl_account_number [Account Code], 
				gl.gl_account_name [Account Name], round(jp.debit_amount,2) Debit,round( jp.credit_amount,2) Credit
				from journal_entry_posting_groups jg  left outer join journal_entry_posting jp
				on jg.posting_group_id=jp.posting_group_id and  jp.as_of_date='''+ @as_of_date +''' 
				left outer join gl_system_mapping gl
				on gl.gl_number_id=jp.gl_number_id'
				 if @flag2='n' 
					--set @exp_sql_stat=@exp_sql_stat + ' where jp.posted_flag is null'
					exec spa_journal_exception_sys_generate 'n',@as_of_date,@posting_group_id,@output_table_name
				else if @flag2='p'
					set @exp_sql_stat=@exp_sql_stat + ' where jp.posted_flag =''n'''		
					
				else if @flag2='a'	
					--set @exp_sql_stat=@exp_sql_stat + ' where ( jp.posted_flag =''n''  or jp.posted_flag is null)'			
					exec spa_journal_exception_sys_generate 'a',@as_of_date,@posting_group_id,@output_table_name
				else if @flag2='v'
					set @exp_sql_stat=@exp_sql_stat + ' where jp.posted_flag =''v'''	

				if @posting_group_id is not null
					set @exp_sql_stat=@exp_sql_stat +' and jg.posting_group_id='+cast(@posting_group_id as varchar(10))
				if @flag2 = 'p' or @flag2 ='v' 
					exec(@exp_sql_stat)
			end
	end
	else if @flag='p'
	begin
		update journal_entry_posting
		set posted_flag='y'
		where as_of_date= @as_of_date and posting_group_id=@posting_group_id 
		and posted_flag='n'

		declare @count_row int
		--select @count_row=count(*) from journal_entry_posting where posted_flag='n' and as_of_date=@as_of_date	
		select  @count_row=count(*) 
		from journal_entry_posting_groups jg  left outer join journal_entry_posting jp
		on jg.posting_group_id=jp.posting_group_id and  jp.as_of_date= @as_of_date
		left outer join gl_system_mapping gl
		on gl.gl_number_id=jp.gl_number_id
		where ( jp.posted_flag ='n'  or jp.posted_flag is null)
		If @@ERROR <> 0

				Exec spa_ErrorHandler @@ERROR, 'Journal Entry Posting  table', 
		
						'spa_journal_entry_posting', 'DB Error', 
		
						'Failed updating record.',''
		
		
				Else

					Exec spa_ErrorHandler 0, 'Journal Entry Posting  table', 
			
							'spa_journal_entry_posting', 'Success', 
			
							 'Updated Post',@count_row
	end
end





