IF OBJECT_ID(N'spa_journal_entry_posting_temp', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_journal_entry_posting_temp]
GO 

--spa_journal_entry_posting_temp 'c','2004-08-30',NULL,NULL,NULL,NULL,3
--spa_journal_entry_posting_temp 's',NULL,NULL,NULL,NULL,NULL,NULL,'975F2711_D621_4D0B_B4D5_658D272305D1',NULL,NULL,'a'

--EXEC spa_journal_entry_posting_temp
--	'2004-08-30', '1', NULL, NULL, 'd', 'f', 'a', 's','p',null, '975F2711_D621_4D0B_B4D5_658D272305D1'

--spa_journal_entry_posting_temp 'p','2004-08-30',NULL,NULL,NULL,NULL,3,'6AC11D71_05EB_4D9F_956D_AAF997404CD3'

--exec spa_journal_entry_posting_temp '2004-08-30', 'd', 's', NULL, 'p' ,'5A6448B5_0009_41FB_8CDB_F722EFBB63DB'


CREATE PROCEDURE [dbo].[spa_journal_entry_posting_temp]
	@flag CHAR(1),
	@as_of_date VARCHAR(50) = NULL,
	@gl_number VARCHAR(250) = NULL,
	@debit_amount FLOAT = NULL,
	@credit_amount FLOAT = NULL,
	@account_name VARCHAR(1000) = NULL,
	@posting_group_id INT = NULL,
	@process_id VARCHAR(500) = NULL,
	@sno INT = NULL,
	@description_field VARCHAR(1000) = NULL,
	@entry_type CHAR(1) = NULL,
	@title_name VARCHAR(5000) = NULL,
	@reverse_type CHAR(1) = NULL
AS
BEGIN
	declare @exp_sql_stat varchar(8000),@user_login_id varchar(50),@tempposttable varchar(200)
	declare @msg varchar(500)
	set @user_login_id=dbo.FNADBUser()
	if @process_id is NULL
	Begin
		set @process_id=REPLACE(newid(),'-','_')
			
	End
	set @tempposttable=dbo.FNAProcessTableName('journal_entry_posting', @user_login_id,@process_id)
	--select for grid
	if @flag='s'
	begin
		set @exp_sql_stat='select sno, 
			gl_number [Account No] , account_name [Account Name], 
			round(debit_amount,2) Debit, round(credit_amount,2) Credit,description_field [Description],
			case entry_type when ''s'' then ''System'' 
			when ''r'' then ''Reverse Entry'' else ''Adj. Entry'' end [Entry Type]
			from  ' + @tempposttable 
			if @entry_type='a'
				set @exp_sql_stat=@exp_sql_stat +' where entry_type in(''a'',''r'')'
			if @entry_type='s'
				set @exp_sql_stat=@exp_sql_stat +' where entry_type =''s'''	
			exec(@exp_sql_stat)			
	end
	else if @flag='r'
	begin
		if @reverse_type =  'p'
		begin
			set @exp_sql_stat='select 
				gl_number [Account No] , account_name [Account Name], 
				case when ( sum(round(debit_amount,2)) - sum(round(credit_amount,2))) > 0 then  sum(round(debit_amount,2)) - sum(round(credit_amount,2)) else 0 end Debit,
case when ( sum(round(credit_amount,2)) - sum(round(debit_amount,2))) > 0 then  sum(round(credit_amount,2)) - sum(round(debit_amount,2)) else 0 end Credit

				from  ' + @tempposttable 
				if @entry_type is not null
					set @exp_sql_stat=@exp_sql_stat +' where entry_type='''+ @entry_type +''''
	
				set @exp_sql_stat=@exp_sql_stat +' group by gl_number,account_name,entry_type'
				set @exp_sql_stat=@exp_sql_stat +' having sum(round(debit_amount,2)) <> sum(round(credit_amount,2)) order by entry_type desc'
		end
		else
		begin
				set @exp_sql_stat='select 
				gl_number [Account No] , account_name [Account Name], 
				sum(round(debit_amount,2)) Debit, sum(round(credit_amount,2)) Credit
				from  ' + @tempposttable 
				if @entry_type is not null
					set @exp_sql_stat=@exp_sql_stat +' where entry_type='''+ @entry_type +''''
	
				set @exp_sql_stat=@exp_sql_stat +' group by gl_number,account_name,entry_type'
				set @exp_sql_stat=@exp_sql_stat +' having sum(round(debit_amount,2)) <> sum(round(credit_amount,2)) order by entry_type desc'
		end
		
			exec(@exp_sql_stat)			
			
	end
	--Reverse 
	else if @flag='v'
	begin
			set @exp_sql_stat='insert '+@tempposttable +' select gl.gl_account_number , gl.gl_account_name, 
						jp.credit_amount , jp.debit_amount,jp.description_field,posted_flag,entry_type
						from journal_entry_posting jp
						left outer join gl_system_mapping gl
					        on gl.gl_number_id=jp.gl_number_id
					        where jp.posting_group_id='+cast(@posting_group_id as varchar(10)) +'
						and posted_flag=''y''
						and as_of_date='''+ @as_of_date +''''
			exec(@exp_sql_stat)		
			If @@ERROR <> 0
			
					Exec spa_ErrorHandler @@ERROR, 'Journal Entry Posting  table', 
					
									'spa_journal_entry_posting_temp', 'DB Error', 
					
									'Failed updating record.',@process_id
					
					
			Else
			
					Exec spa_ErrorHandler 0, 'Journal Entry Posting  table', 
						
						'spa_journal_entry_posting_temp', 'Success', 
						
						 'Calculating Debit and Credit',@process_id	
	end
	else if @flag='n'
	begin
		declare @debit_amt float,@credit_amt float
		declare @error_msg varchar(1000)
			set @exp_sql_stat='
			select sum(round(debit_amount,0)) as debit_amount, sum(round(credit_amount,0)) as credit_amount into ##temp_post from  ' + @tempposttable 	
			exec(@exp_sql_stat)
			select @debit_amt=debit_amount,@credit_amt=credit_amount from ##temp_post
			drop table ##temp_post
--			if @debit_amt = @credit_amt 
--			select @debit_amt, @credit_amt
			if abs(@debit_amt - @credit_amt) <= 1 
			begin
				set @msg='Success'
				set @error_msg='Success'
			end
			else
			begin
				set @msg='Error'
				set @error_msg='Debit and Credit are not equal !!<br> Total Debit :  '+ cast(@debit_amt as varchar(50)) + ' <br>Total Credit :'+ cast(@credit_amt as varchar(50)) +'<br> Total Difference : '+  cast((@debit_amt-@credit_amt) as varchar(50)) 
				--set @error_msg='Error'
			end
			
			If @@ERROR <> 0

				Exec spa_ErrorHandler @@ERROR, 'Journal Entry Posting  table', 
		
						'spa_journal_entry_posting_temp', 'DB Error', 
		
						'Failed updating record.',@process_id
		
		
				Else
					Select @msg As ErrorCode, 'Journal Entry Posting  table' As Module, 
										'spa_journal_entry_posting_temp' AS Area , 'Application Error' AS status,
								@error_msg AS Message, @process_id AS Recommendation
		
	end 
	-- Copy only adjustment to temp table
	else if @flag='c'
	begin
			set @exp_sql_stat='create table '+ @tempposttable +'(
				sno int identity,
				gl_number  varchar(250),
				account_name varchar(1000) ,
				debit_amount money,
				credit_amount money,
				description_field varchar(1000),
				posted_flag char(1) DEFAULT  ''n'',
				entry_type char(1) DEFAULT ''s'')'
			exec(@exp_sql_stat)

			set @exp_sql_stat='insert '+@tempposttable +' select gl.gl_account_number , gl.gl_account_name, 
						jp.debit_amount , jp.credit_amount,jp.description_field,posted_flag,entry_type
						from journal_entry_posting jp
						left outer join gl_system_mapping gl
						on gl.gl_number_id=jp.gl_number_id
					        where jp.posting_group_id='+cast(@posting_group_id as varchar(10)) +'
						and posted_flag<>''v''
						and as_of_date='''+ @as_of_date +''''
			exec(@exp_sql_stat)
			declare @countrow int,@posted_flag char(1),@group_name varchar(500),@close_date datetime
		
			--select @posted_flag= posted_flag from journal_entry_posting where posting_group_id=@posting_group_id and as_of_date=@as_of_date
			
			select @group_name= jg.group_name,@posted_flag=jp.posted_flag from journal_entry_posting  jp
				right outer join  journal_entry_posting_groups jg
				on jp.posting_group_id=jg.posting_group_id  and jp.as_of_date=@as_of_date
				where jg.posting_group_id=@posting_group_id 
			select 	@close_date=max(as_of_date) from close_measurement_books	

			set @msg='NULL'
		
			if @posted_flag is null
				set @msg='NOTPREPARED'
			else if @posted_flag='n' 
				set @msg='NOTPOSTED'
			else if @posted_flag='y'
				set @msg='POSTED'		
			if @as_of_date <=@close_date
				set @msg='CLOSED'		
			If @@ERROR <> 0

				Exec spa_ErrorHandler @@ERROR, 'Journal Entry Posting  table', 
		
						'spa_journal_entry_posting_temp', 'DB Error', 
		
						'Failed updating record.',@process_id
		
		
				Else

					Exec spa_ErrorHandler 0, 'Journal Entry Posting  table', 
			
							@group_name, 'Success', 
			
							@msg ,@process_id
	end
	else if @flag='i'
	begin
		set @exp_sql_stat='insert '+ @tempposttable +'(
		posted_flag,entry_type)
		values(''n'',''a'')'
		exec(@exp_sql_stat)
		If @@ERROR <> 0
	
					Exec spa_ErrorHandler @@ERROR, 'Journal Entry Posting  table', 
			
							'spa_journal_entry_posting_temp', 'DB Error', 
			
							'Failed updating record.',@process_id
			
			
					Else
	
						Exec spa_ErrorHandler 0, 'Journal Entry Posting  table', 
				
								'spa_journal_entry_posting_temp', 'Success', 
				
								'Journal Entry Posting  record successfully updated.',@process_id

	end 
	else if @flag='u'
	begin
		set @exp_sql_stat='update '+ @tempposttable +'
		set gl_number='''+ @gl_number +''',
		account_name='''+ @account_name  +''',
		debit_amount='+ cast(isNuLL(@debit_amount,0.00) as varchar(50))+',
		credit_amount='+ cast(isNuLL(@credit_amount,0.00) as varchar(50)) +',
		description_field='''+isNULL(@description_field,'')+'''
		where sno='+ cast(@sno as varchar(20))	

		
		exec(@exp_sql_stat)
		
		If @@ERROR <> 0

				Exec spa_ErrorHandler @@ERROR, 'Journal Entry Posting  table', 
		
						'spa_journal_entry_posting_temp', 'DB Error', 
		
						'Failed updating record.',@process_id
		
		
				Else

					Exec spa_ErrorHandler 0, 'Journal Entry Posting  table', 
			
							'spa_journal_entry_posting_temp', 'Success', 
			
							'Journal Entry Posting  record successfully updated.',@process_id

	end
	else if @flag='d'
	begin
		set @exp_sql_stat='delete '+ @tempposttable +'
			where sno='+ cast(@sno as varchar(20))	
		exec(@exp_sql_stat)
		If @@ERROR <> 0

				Exec spa_ErrorHandler @@ERROR, 'Journal Entry Posting  table', 
		
						'spa_journal_entry_posting_temp', 'DB Error', 
		
						'Failed updating record.',@process_id
		
		
				Else

					Exec spa_ErrorHandler 0, 'Journal Entry Posting  table', 
			
							'spa_journal_entry_posting_temp', 'Success', 
			
							'Journal Entry Posting  record successfully updated.',@process_id

	end	
	--Prepared Entries Trans entries from Temp table tp Journal_Entry_posting table
	else if @flag='p'
	begin
		begin transaction
		
		
		if @reverse_type =  'p'
		begin
			set @exp_sql_stat='
			select 
			'''+@as_of_date+''',
			gsm.gl_number_id,
			case when ( sum(round(debit_amount,2)) - sum(round(credit_amount,2))) > 0 then  sum(round(debit_amount,2)) - sum(round(credit_amount,2)) else 0 end Debit,
			case when ( sum(round(credit_amount,2)) - sum(round(debit_amount,2))) > 0 then  sum(round(credit_amount,2)) - sum(round(debit_amount,2)) else 0 end Credit,
			''n'',
			entry_type,
			'+cast(@posting_group_id as varchar(20))+' from '+ @tempposttable 
		end
		else 
		begin
			set @exp_sql_stat='
			select 
			'''+@as_of_date+''',
			gsm.gl_number_id,
			sum(round(debit_amount,2)) debit_amount, sum(round(credit_amount,2)) credit_amount,
			''n'',
			entry_type,
			'+cast(@posting_group_id as varchar(20))+' from '+ @tempposttable
		end
			set @exp_sql_stat=@exp_sql_stat + ' 
			res INNER JOIN
			 gl_system_mapping gsm on gsm.gl_account_number = res.gl_number
			group by gl_number_id,entry_type
			 having sum(round(debit_amount,2)) <> sum(round(credit_amount,2)) order by entry_type desc'
			
			
		--exec(@exp_sql_stat)
		declare @row_count int
		--set @row_count=@@RowCount
		--set @row_count=0
			update journal_entry_posting
			set posted_flag='v'
			where posting_group_id=@posting_group_id
			and as_of_date= @as_of_date
			
			set @exp_sql_stat='
				insert journal_entry_posting(
				as_of_date,
				gl_number_id,
				debit_amount,
				credit_amount,
				posted_flag,
				entry_type,
				posting_group_id)' + @exp_sql_stat
				exec(@exp_sql_stat)
				set @row_count=@@RowCount
				if @row_count=0
				begin
					set @msg='1'		
					rollback	transaction
				end
				else
				begin
					set @msg='0'		
					commit tran
				end
				
			
		
		If @@ERROR <> 0
						Exec spa_ErrorHandler @@ERROR, 'Journal Entry Posting  table', 
								'spa_journal_entry_posting_temp', 'DB Error', 
				
								'Failed updating record.',@process_id



						Else	
								Exec spa_ErrorHandler 0, 'Journal Entry Posting  table', 
						
										'spa_journal_entry_posting_temp', @msg, 
						
										 'Updated Journal Entry',@process_id

	end
end




