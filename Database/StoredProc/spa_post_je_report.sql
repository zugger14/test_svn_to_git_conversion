
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go
IF OBJECT_ID(N'[dbo].[spa_post_je_report]', N'P') IS NOT NULL
drop  proc [dbo].[spa_post_je_report]
go

create  proc [dbo].[spa_post_je_report]
	@flag char(1), -- u - not posted f-> posted
	@prod_date_from datetime = NULL,
	@prod_date_to datetime = NULL,
	@sub_id varchar(100)=NULL,
	@counterparty_id NVARCHAR(1000)=NULL,
	@id varchar(100)=null


AS
SET NOCOUNT ON 
DECLARE @sql varchar(5000)

if @prod_date_from is not null and @prod_date_to is null
set @prod_date_to=@prod_date_from
if @prod_date_from is null and @prod_date_to is not null
set @prod_date_from=@prod_date_to



 
If @flag = 'u' or @flag='f'
BEGIN
		--******************************************************            
		--CREATE source book map table and build index            
		--*********************************************************            
		SET @sql = ''            
		CREATE TABLE #ssbm(            
		 source_system_book_id1 int,            
		 source_system_book_id2 int,            
		 source_system_book_id3 int,            
		 source_system_book_id4 int,            
		 fas_deal_type_value_id int,            
		 book_deal_type_map_id int,            
		 fas_book_id int,            
		 stra_book_id int,            
		 sub_entity_id int            
		)            
		----------------------------------            
		SET @sql=            
		'INSERT INTO #ssbm            
		SELECT            
		 source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,fas_deal_type_value_id,            
		  book_deal_type_map_id,book.entity_id fas_book_id,book.parent_entity_id stra_book_id, stra.parent_entity_id sub_entity_id             
		FROM            
		 source_system_book_map ssbm             
		INNER JOIN            
		 portfolio_hierarchy book (nolock)             
		ON             
		  ssbm.fas_book_id = book.entity_id             
		INNER JOIN            
		 Portfolio_hierarchy stra (nolock)            
		 ON            
		  book.parent_entity_id = stra.entity_id             
		            
		WHERE 1=1 '            
		IF @sub_id IS NOT NULL            
		  SET @sql = @sql + ' AND stra.parent_entity_id IN  ( ' + cast (@sub_id as varchar)+ ') '             

		   
		EXEC (@sql)            
		--------------------------------------------------------------            
		CREATE  INDEX [IX_PH1] ON [#ssbm]([source_system_book_id1])                  
		CREATE  INDEX [IX_PH2] ON [#ssbm]([source_system_book_id2])                  
		CREATE  INDEX [IX_PH3] ON [#ssbm]([source_system_book_id3])                  
		CREATE  INDEX [IX_PH4] ON [#ssbm]([source_system_book_id4])                  
		CREATE  INDEX [IX_PH5] ON [#ssbm]([fas_deal_type_value_id])                  
		CREATE  INDEX [IX_PH6] ON [#ssbm]([fas_book_id])                  
		CREATE  INDEX [IX_PH7] ON [#ssbm]([stra_book_id])                  
		CREATE  INDEX [IX_PH8] ON [#ssbm]([sub_entity_id])                  
		            
		--******************************************************            
		--End of source book map table and build index            
		--*********************************************************            


		create table #temp_counterparty
		(
			counterparty_id int,
			counterparty_name varchar(100) COLLATE DATABASE_DEFAULT,
			generator_id int,
			legal_entity_value_id int,
			contract_id int
		)

		insert into #temp_counterparty(counterparty_id,counterparty_name,generator_id,legal_entity_value_id,contract_id)
		select source_counterparty_id,counterparty_name,max(generator_id),max(legal_entity_value_id),contract_id
		from
		(
		select 
			source_counterparty_id,counterparty_name,rg.generator_id,rg.legal_entity_value_id,cg.contract_id
		from 
			source_counterparty sc 
			inner join rec_generator rg on sc.source_counterparty_id=isnull(rg.ppa_Counterparty_id,'')
			inner join contract_group cg on cg.contract_id=rg.ppa_Contract_id
			where isnull(term_end,'9999-01-01')>=dbo.FNAGetContractMonth(@prod_date_from)
		) a
		group by 
			source_counterparty_id,counterparty_name,contract_id


		set @sql=
		  ' select 
					tc.counterparty_id as [Counterparty ID],
					tc.counterparty_name as [Counterparty],
					dbo.FNADateFormat(civ.of_date) [As of Date],	
					dbo.FNADateFormat(civ.prod_date) [Production Month]	
					'+case when  @flag='f' then ',dbo.FNADateFormat(cmb.update_ts) as [Posted Date]' else '' end +'	 
					'+case when @flag='f' then ',cmb.id as [ID]' else '' end +' 	 
			from  
				 #temp_counterparty tc
				 inner join 
				 (select counterparty_id,prod_date,max(as_of_date) as of_date,max(finalized) finalized from calc_invoice_volume_variance group by counterparty_id,prod_date) civ
				 on tc.counterparty_id=civ.counterparty_id
				 left join post_je_report cmb on cmb.counterparty_id=tc.counterparty_id and cmb.prod_date=civ.prod_date
				 	  	
				 
			where 1=1
			and isnull(civ.finalized,''n'')=''y''	
			'
			+ case when @flag='f' then ' and cmb.counterparty_id is not null' 
				   when @flag='u' then ' and cmb.counterparty_id is		null' 
			  else '' end 	 	 
			+case when @counterparty_id is not null then ' and tc.counterparty_id in('+@counterparty_id+')' else '' end		
			+case when @prod_date_from is not null then ' and civ.prod_date between dbo.fnagetcontractmonth('''+cast(@prod_date_from as varchar)+''') and dbo.fnagetcontractmonth('''+cast(@prod_date_to as varchar)+''')' else '' end		
			+case when @sub_id is not null then 	' AND tc.legal_entity_value_id='+cast(@sub_id as varchar) else '' end

			+' order by tc.counterparty_name,civ.prod_date'
			EXEC spa_print @sql
			exec(@sql)


end
Else if @flag = 'i'
begin
set @sql=
	' insert into post_je_report
		(prod_date,sub_id,counterparty_id)
	select dbo.fnagetcontractmonth('''+cast(@prod_date_from as varchar)+'''),'+cast(@sub_id as varchar)+' 
		   ,source_counterparty_id	  
		from 
			source_counterparty
	where
		source_counterparty_id in('+@counterparty_id+')'
    EXEC spa_print @sql
	exec(@sql)

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Post JE Report', 
				'spa_post_je_report', 'DB Error', 
				'Failed to insert a JE Report.', ''
	else
		Exec spa_ErrorHandler 0, 'Post JE Report', 
				'spa_post_je_report', 'Success', 
				'Succeded to insert JE Report.', ''
end 
Else if @flag = 'd'
begin


--	delete from post_je_report
--	where prod_date = dbo.fnagetcontractmonth(@prod_date_from)
--	and sub_id=@sub_id and counterparty_id=@counterparty_id

set @sql=
	'delete from post_je_report
	where [id] in('+@id+')'
exec(@sql)

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Post JE Report', 
				'spa_post_je_report', 'DB Error', 
				'Failed to delete a JE Report.', ''
	else
		Exec spa_ErrorHandler 0, 'Post JE Report', 
				'spa_post_je_report', 'Success', 
				'Succeded to delete a JE Report.', ''

end 

--Check Close Book or not
--If @flag = 'c'
--begin
--	if exists (select as_of_date from post_je_report where as_of_date >=
--			dbo.FNAGetContractMonth(@as_of_date) and sub_id=@sub_id)
--		select 'Posted' Status
--	else
--		select 'Not Posted' Status
--
--end
--






















