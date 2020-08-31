
if object_id('spa_export_table_scripter') is not null
drop proc dbo.spa_export_table_scripter
go

create proc dbo.spa_export_table_scripter @tbl_name	 varchar(250) -- ='source_price_curve_def'
	,@filter varchar(max)=null --' where source_curve_def_id in(1415)'  --- the alias name for source_table is always src
	,@is_result_output varchar(1)='y'
	,@primary_key_column1 varchar(100) --='curve_id'
	,@primary_key_column2 varchar(100)=null
	,@primary_key_column3 varchar(100)=null
	,@master_table_name  varchar(250)  =null --the name should provide for child table's script is generating 
	,@join_column_name_master   varchar(250)  =null --foreign key for child table from master table
	,@join_column_name_child   varchar(250)  =null --foreign key for child table from master table
	,@primary_key_column1_master varchar(100)=null --'curve_id'
	,@primary_key_column2_master varchar(100)=null
	,@primary_key_column3_master varchar(100)=null
	,@export_lebel int=0
	,@temp_unique_id VARCHAR(50) = NULL
	
as


/*


declare @tbl_name	 varchar(250)  ='formula_nested'
	,@filter varchar(max)=null
	,@is_result_output varchar(1)='y'
	,@primary_key_column1 varchar(100)='formula_name'
	,@primary_key_column2 varchar(100)=null
	,@primary_key_column3 varchar(100)=null
	,@master_table_name  varchar(250)  =null --the name should provide for child table's script is generating 
	,@join_column_name_master   varchar(250)  =null --foreign key for child table from master table
	,@join_column_name_child   varchar(250)  =null --foreign key for child table from master table
	,@primary_key_column1_master varchar(100)=null --'curve_id'
	,@primary_key_column2_master varchar(100)=null
	,@primary_key_column3_master varchar(100)=null
	,@export_lebel int=2 -- both export and sync; 1 export only; 2 sync only
--declare @tbl_name	 varchar(250)  ='contract_group_detail'
--	,@filter varchar(max)=null
--	,@is_result_output varchar(1)='y'
--	,@primary_key_column1 varchar(100)='contract_id'
--	,@primary_key_column2 varchar(100)='invoice_line_item_id'
--	,@primary_key_column3 varchar(100)=null
--	,@master_table_name  varchar(250)  ='contract_group' --the name should provide for child table's script is generating 
--	,@join_column_name_master   varchar(250)  ='contract_id' --foreign key for child table from master table
--	,@join_column_name_child   varchar(250)  ='contract_id' --foreign key for child table from master table
--	,@primary_key_column1_master varchar(100)='source_contract_id' --'curve_id'
--	,@primary_key_column2_master varchar(100)=null
--	,@primary_key_column3_master varchar(100)=null

--*/

if OBJECT_ID('tempdb..#query_result') is null
create table #query_result (rowid int identity(1,1),query_result varchar(max) COLLATE DATABASE_DEFAULT )

--truncate table #query_result

declare @null_values	 varchar(1000)
declare @sp_parameters	 varchar(max)
declare @list_columns	 varchar(max)
declare @list_parameters	 varchar(max)
declare @list_update_col	 varchar(max)	,@identity_col varchar(150),@master_identity_col varchar(150)
declare @st varchar(max)
--declare @temp_tbl_name VARCHAR(250) = @tbl_name + ISNULL(@temp_unique_id, '')
declare @temp_tbl_name VARCHAR(250) = @tbl_name + CASE WHEN @temp_unique_id IS NOT NULL THEN '_' + @temp_unique_id ELSE '' END
DECLARE @temp_master_table_name VARCHAR(250) = @master_table_name + CASE WHEN @temp_unique_id IS NOT NULL THEN '_' + @temp_unique_id ELSE '' END
select @identity_col=col.name from   sys.columns col where col.is_identity=1   and object_id=OBJECT_ID(@tbl_name)

if @master_table_name is not null
select @master_identity_col=col.name from   sys.columns col where col.is_identity=1   and object_id=OBJECT_ID(@master_table_name)



select @sp_parameters=isnull(@sp_parameters+',','') +quotename(col.name) +' ' 
	+case when typ.name in ('int','float','tinyint','datetime','bit','bigint','binary','date','smallint') then  typ.name
	   when typ.name in ('varchar','nvarchar','char') then  typ.name +'('+	case when cast(col.max_length as varchar)='-1' then 'max' else cast(col.max_length as varchar) end +') COLLATE DATABASE_DEFAULT'
	   when typ.name in ('numeric') then  typ.name +'('+	cast(col.[precision] as varchar) +','+cast(col.scale as varchar)  +')'
end	+ ' ' + case when typ.name IN ('varchar', 'nvarchar', 'char')  then  '' else '' end 			  
from sys.columns col inner join sys.types 	typ on col.system_type_id=typ.system_type_id where object_id=OBJECT_ID(@tbl_name)
	and  typ.name in ('int','float','tinyint','datetime','bit','bigint','binary','date','smallint','varchar','nvarchar','char','numeric' )
	and col.name not in ('create_user','create_ts','update_user','update_ts')
order by column_id 
 --select   @sp_parameters


insert into #query_result (query_result)
select 'print(''--==============================START '+@tbl_name+'============================='')'

select @list_columns=isnull(@list_columns+',','') +quotename(col.name)	,
	@null_values=isnull(@null_values+',','')+'NULL',
	@list_parameters=	isnull(@list_parameters+'+'',''+','''(''+') 
	+'ISNULL('+
	case when typ.name in ('int','float','tinyint','bit','bigint','binary','smallint','numeric') then 'cast(src.'+quotename(col.name)+ ' as varchar(50))'
			when typ.name in ('datetime','date') then '''''''''+cast(src.'+quotename(col.name)+ ' as varchar(50))+'+''''''''''
			when typ.name in ('varchar','nvarchar','char') then '''''''''+'	+case when col.name in ('formula','formula_html','formula_sql','sql_string', 'sql_statement') and @tbl_name in ('formula_editor','formula_editor_sql','user_defined_fields_template', 'alert_sql')  then 'replace(' else '' end +case when col.max_length<10 and col.max_length>0 then 'cast(src.'+quotename(col.name) +' as varchar(10))'
				when  col.max_length<0 then 'cast(src.'+quotename(col.name) +' as varchar(max))' else 'src.'+quotename(col.name)  end 	
					+case when col.name in ('formula','formula_html','formula_sql','sql_string', 'sql_statement') and @tbl_name in ('formula_editor','formula_editor_sql','user_defined_fields_template','alert_sql') then ','''''''','''''''''''')' else '' end +'+'''''''''
	end	+',''NULL'')'  	
from sys.columns col inner join sys.types 	typ on col.system_type_id=typ.system_type_id where object_id=OBJECT_ID(@tbl_name)
	and  typ.name in ('int','float','tinyint','datetime','bit','bigint','binary','date','smallint','varchar','nvarchar','char','numeric' )
	and col.name not in ('create_user','create_ts','update_user','update_ts')
	--and col.is_identity<>1
order by column_id 


export_lebel:
	if isnull(@export_lebel,0) not in (0,1) goto sync_lebel
	insert into #query_result (query_result)
	select 
	'
	if object_id(''tempdb..#' + @temp_tbl_name + ''') is null 
	
	CREATE TABLE #'+@temp_tbl_name+
	 '
	 (
	 '
	 +@sp_parameters+',new_recid int,old_recid int
	 )
	 ELSE
	 TRUNCATE TABLE #' + @temp_tbl_name + ';'
	

	insert into #query_result (query_result)
	select 'INSERT INTO #'+@temp_tbl_name+'(
	 '+@list_columns+',old_recid
	 )
	 VALUES
	 '
	if @tbl_name='formula_editor'	
		set @list_parameters=replace(@list_parameters,'src.[formula_html]','null')	
	 
	 
	 
	set @st='
		 insert into #query_result (query_result)
		 select '+
		 @list_parameters+'+'',''+cast(src.'
		 +quotename(
		 case when @master_table_name is null then @identity_col else 
				 case when @join_column_name_child=@primary_key_column1 ---
							or @join_column_name_child=isnull(@primary_key_column2,'') 
							or @join_column_name_child=isnull(@primary_key_column3,'')
				then @join_column_name_child else @identity_col end
		end)+ ' as varchar(50))'
		 +'+''),''
		FROM '+ quotename(@tbl_name)+ ' src ' + case when isnull(@filter,'')='' then '' else @filter end

	
	
	EXEC spa_print @st
	exec(@st)


	insert into #query_result (query_result)
	select 
	'('+ @null_values+',null);
	delete #'+@temp_tbl_name+' where '+@identity_col+' is null;
	update #'+@temp_tbl_name+' set '+@primary_key_column1+'=''FARRMS1_ ''+cast('+@identity_col+' as varchar(30))  where isnull(' +@primary_key_column1 + ','''')='''' ;
	' 
	+case when isnull(@primary_key_column2,'')='' then '' 
		else
			'update #'+@temp_tbl_name+' set '+@primary_key_column2+'=''FARRMS2_ ''+cast('+@identity_col+' as varchar(30))  where isnull(' +@primary_key_column2 + ','''')='''' ;
			'
		end
	+case when isnull(@primary_key_column3,'')='' then '' 
		else
			'update #'+@temp_tbl_name+' set '+@primary_key_column3+'=''FARRMS3_ ''+cast('+@identity_col+' as varchar(30))  where isnull(' +@primary_key_column3 + ','''')='''' ;
			'
		end


sync_lebel:


	if isnull(@export_lebel,0) not in (0,2) goto end_lebel
	select
		@list_update_col=  isnull(@list_update_col+',','') +quotename(col.name)+  '=src.'+quotename(col.name)
	from sys.columns col inner join sys.types 	typ on col.system_type_id=typ.system_type_id where object_id=OBJECT_ID(@tbl_name)
		and  typ.name in ('int','float','tinyint','datetime','bit','bigint','binary','date','smallint','varchar','nvarchar','char','numeric' )
		and col.name not in ('create_user','create_ts','update_user','update_ts')
		and col.is_identity<>1
		and not (col.name=@primary_key_column1 or col.name=isnull(@primary_key_column2,'')  or col.name=isnull(@primary_key_column3,''))
	order by column_id 

	declare @output_qry varchar(1000),@unique_join_output varchar(1000),@unique_join varchar(max)
	declare @unique_join_output_master varchar(1000),@unique_join_master varchar(max)

	select @output_qry=' OUTPUT ''u'','''+@tbl_name+''',inserted.'+@identity_col
		+','+isnull('inserted.'+@primary_key_column1,'NULL')
		+','+isnull('inserted.'+@primary_key_column2,'NULL')
		+','+isnull('inserted.'+@primary_key_column3,'NULL')
		+' INTO #old_new_id(tran_type,table_name,new_id,unique_key1,unique_key2,unique_key3)
	'

	select @unique_join= ' ON src.'+ @primary_key_column1 +'=dst.'+@primary_key_column1
		+ case when @primary_key_column2 is null then '' else ' AND src.'+@primary_key_column2+'=dst.'+@primary_key_column2 end
		+ case when @primary_key_column3 is null then '' else ' AND src.'+@primary_key_column3+'=dst.'+@primary_key_column3 end
 

	select @unique_join_output= ' ON src.'+ @primary_key_column1 +'=dst.unique_key1'
		+ case when @primary_key_column2 is null then '' else ' AND src.'+@primary_key_column2+'=dst.unique_key2' end
		+ case when @primary_key_column3 is null then '' else ' AND src.'+@primary_key_column3+'=dst.unique_key3' end
		+' AND dst.table_name='''+@tbl_name+''''

	if @master_table_name is null ----Case for master table
	begin

		insert into #query_result (query_result)
		SELECT 'UPDATE dbo.'+@tbl_name+' SET '+  @list_update_col+'
		  '+ @output_qry
			+ 'FROM #' +@temp_tbl_name+' src INNER JOIN '+@tbl_name+' dst '
			+@unique_join+';'
	
	
		insert into #query_result (query_result)
		SELECT 'insert into '+@tbl_name+'
		('
		+
		replace(@list_columns,quotename(@identity_col)+',','')
		+'
		)
		'+ replace(@output_qry,'''u''','''i''')+'
		SELECT 
		'+replace(replace(@list_columns,quotename(@identity_col)+',',''),'[','src.[')
		+  '
		FROM #' +@temp_tbl_name+' src LEFT JOIN '+@tbl_name+' dst '+@unique_join+'
		WHERE dst.'+quotename(@identity_col)+' IS NULL;'

		insert into #query_result (query_result)
		SELECT 'UPDATE #'+@temp_tbl_name+' SET new_recid =dst.new_id 
		FROM #' +@temp_tbl_name+' src INNER JOIN #old_new_id dst '+@unique_join_output+'
		;'


	end 
	else ----Case for child table
	begin

		--select @unique_join= ' AND src_c.' +@primary_key_column1 +'=dst_c.'+@primary_key_column1
		--+ case when @primary_key_column2 is null then '' else ' AND src_c.' +@primary_key_column2 +'=dst_c.'+@primary_key_column2 end
		--+ case when @primary_key_column3 is null then '' else ' AND src_c.' +@primary_key_column3 +'=dst_c.'+@primary_key_column3 end

		
			
		select @unique_join= ' AND '+ 
			case when @join_column_name_child=@primary_key_column1 then 
				case when @join_column_name_master=@master_identity_col then 'src.new_recid' else 'src_c.'+@primary_key_column1 end 
			else 'src_c.' +@primary_key_column1 end +'=dst_c.'+@primary_key_column1
			+ 
			case when @primary_key_column2 is null then '' 
			else ' AND '+
					case when @join_column_name_child=isnull(@primary_key_column2,'') then 
						case when @join_column_name_master=@master_identity_col then 'src.new_recid' else 'src_c.'+@primary_key_column2 end
					else 'src_c.' +@primary_key_column2 end
					+'=dst_c.'+@primary_key_column2 
			end
			+ case when @primary_key_column3 is null then '' 
			else ' AND '+
				case when @join_column_name_child=isnull(@primary_key_column3,'') then 
					case when @join_column_name_master=@master_identity_col then 'src.new_recid' else 'src_c.'+@primary_key_column3 end
				else 'src_c.' +@primary_key_column3 end
				+'=dst_c.'+@primary_key_column3 
			end		
		select @unique_join_master= ' ON src.'+ @primary_key_column1_master +'=dst.'+@primary_key_column1_master
			+ case when @primary_key_column2_master is null then '' else ' AND src.'+@primary_key_column2_master+'=dst.'+@primary_key_column2_master end
			+ case when @primary_key_column3_master is null then '' else ' AND src.'+@primary_key_column3_master+'=dst.'+@primary_key_column3_master end
 

		select @unique_join_output_master= ' WHERE src_c.'+ @primary_key_column1_master +'=dst_c.unique_key1'
			+ case when @primary_key_column2_master is null then '' else ' AND src_c.'+@primary_key_column2_master+'=dst_c.unique_key2' end
			+ case when @primary_key_column3_master is null then '' else ' AND src_c.'+@primary_key_column3_master+'=dst_c.unique_key3' end
			+' AND dst_c.table_name='''+@tbl_name+''''

		
		select @unique_join_output= ' ON src.'+ CASE WHEN @join_column_name_child=@primary_key_column1 THEN 'old_recid' ELSE  @primary_key_column1 END +'=dst.unique_key1'
			+ case when @primary_key_column2 is null then '' else ' AND src.'+CASE WHEN @join_column_name_child=@primary_key_column2 THEN 'old_recid' ELSE  @primary_key_column2 END+'=dst.unique_key2' end
			+ case when @primary_key_column3 is null then '' else ' AND src.'+CASE WHEN @join_column_name_child=@primary_key_column3 THEN 'old_recid' ELSE  @primary_key_column3 END+'=dst.unique_key3' end
			+' AND dst.table_name='''+@tbl_name+''''


		insert into #query_result (query_result)
		SELECT 'UPDATE dbo.'+@tbl_name+' SET '+  replace(replace(@list_update_col,'src.','src_c.'),'src_c.'+QUOTENAME(@join_column_name_child),'dst.'+QUOTENAME(@join_column_name_master))+'
		  '+ @output_qry
			+ ' FROM #' + @temp_master_table_name + ' src INNER JOIN '+@master_table_name+' dst ' +@unique_join_master+'
			INNER JOIN #' +@temp_tbl_name+' src_c ON src_c.'+@join_column_name_child+'=src.' + @join_column_name_master+'
			INNER JOIN ' +@tbl_name+' dst_c ON dst_c.'+@join_column_name_child+'=dst.' +@join_column_name_master
			+@unique_join+';'
	

		insert into #query_result (query_result)
		SELECT 'insert into '+@tbl_name+'
		('
		+
		replace(@list_columns,quotename(@identity_col)+',','')
		+'
		)
		'+ replace(@output_qry,'''u''','''i''')+'
		SELECT 
		'+replace(
			replace(replace(@list_columns,quotename(@identity_col)+',',''),'[','src_c.['),'src_c.['+
			case when @join_column_name_child=@primary_key_column1 ---
						or @join_column_name_child=isnull(@primary_key_column2,'') 
						or @join_column_name_child=isnull(@primary_key_column3,'')
				then @join_column_name_child else 'aaaaaabbbccc' end
	
		,'src.['+case when @join_column_name_child=@primary_key_column1 ---
						or @join_column_name_child=isnull(@primary_key_column2,'') 
						or @join_column_name_child=isnull(@primary_key_column3,'')
				then 'new_recid' else 'aaaaaabbbccc' end
		)
		+  '
		FROM #' + @temp_master_table_name + ' src INNER JOIN '+@master_table_name+' dst '+@unique_join_master+' 
			INNER JOIN #' +@temp_tbl_name+' src_c ON src_c.'+@join_column_name_child+'=src.' +  @join_column_name_master +'	
			LEFT JOIN ' +@tbl_name+' dst_c ON dst_c.'+@join_column_name_child+'=dst.' +@join_column_name_master
			+@unique_join
			+'
		WHERE dst_c.'+quotename(@join_column_name_child)+' IS NULL;'

		insert into #query_result (query_result)
		SELECT 'UPDATE #'+@temp_tbl_name+' SET new_recid =dst_c.'+quotename(@identity_col)+' 
			FROM #' + @temp_master_table_name + ' src INNER JOIN '+@master_table_name+' dst ' +@unique_join_master+'
			INNER JOIN #' +@temp_tbl_name+' src_c ON src_c.'+@join_column_name_child+'=src.' + @join_column_name_master +'	
			INNER JOIN ' +@tbl_name+' dst_c ON dst_c.'+@join_column_name_child+'=dst.' +@join_column_name_master+'
			'+@unique_join+';'

	end


end_lebel:

insert into #query_result (query_result)
select 'print(''--==============================END '+@tbl_name+'============================='')'

if @is_result_output='y'
	select * from #query_result order by 1

