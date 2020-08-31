/****** Object:  StoredProcedure [dbo].[spa_run_emissions_intensity_report_paging]    Script Date: 06/25/2009 16:24:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_run_emissions_intensity_report_paging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_run_emissions_intensity_report_paging]
GO 
/****** Object:  StoredProcedure [dbo].[spa_get_rec_activity_report_paging]    Script Date: 06/25/2009 15:13:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROC [dbo].[spa_run_emissions_intensity_report_paging]
	@flag char(1)='s', -- 's' summary,'d' detail
	@report_type char(1)='1', -- 1->Emissions,2->Intensity,3->Rate,4->Net Mwh
	@group_by char(1)='1', -- 1->Operating Compnay, 2->Business Units, 3->States, 4->Source/Sinks
	@sub_entity_id varchar(100)=null,
	@strategy_entity_id varchar(500)=null,
	@fas_book_id varchar(500)=null,
	@as_of_date datetime=null,
	@term_start datetime=null,
	@term_end datetime=null,
	@technology int=null,
	@fuel_value_id int=null,
	@ems_book_id varchar(200)=null,
	@curve_id int=null,
	@convert_uom_id int=null,
	@show_co2e char(1)='n',
	@technology_sub_type int=null,
	@fuel_type int=null,
	@source_sink_type int=null,
	@reduction_type int = NULL, 
	@reduction_sub_type int = NULL, 	   
	@udf_source_sink_group int=null,
	@udf_group1 int=null,
	@udf_group2 int=null,
	@udf_group3 int=null,
	@frequency int=null,
	@protocol int=null,
	@include_hypothetical CHAR(1)='n',
	@drill_criteria VARCHAR(100)=NULL,
	@drill_group CHAR(1)=NULL,
	@round_value CHAR(1)='0',
	@process_id varchar(200)=NULL, 
	@page_size int =NULL,
	@page_no int=NULL 


 AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE @user_login_id varchar(50),@tempTable varchar(300),@col_names varchar(100), @all_col_names varchar(1000)

	set @user_login_id=dbo.FNADBUser()

	if @process_id is NULL
	Begin
		set @flag='i'
		set @process_id=REPLACE(newid(),'-','_')
	End
	set @tempTable=dbo.FNAProcessTableName('paging_temp_emissions_inventory_Report', @user_login_id,@process_id)
	declare @sqlStmt varchar(5000)
	
	
	if @flag='i'
	begin

		set @sqlStmt=' 
		exec  spa_run_emissions_intensity_report s, '+ 
		dbo.FNASingleQuote(@report_type) +','+ 
		dbo.FNASingleQuote(@group_by) +','+ 
		dbo.FNASingleQuote(@sub_entity_id) +','+ 
		dbo.FNASingleQuote(@strategy_entity_id) +','+ 
		dbo.FNASingleQuote(@fas_book_id) +',' +
		dbo.FNASingleQuote(@as_of_date) +',' +
		dbo.FNASingleQuote(@term_start) +',' +
		dbo.FNASingleQuote(@term_end)+',' +
		dbo.FNASingleQuote(@technology) + ',' +	
		dbo.FNASingleQuote(@fuel_value_id) +','+ 
		dbo.FNASingleQuote(@ems_book_id) +','+ 
		dbo.FNASingleQuote(@curve_id) +','+ 
		dbo.FNASingleQuote(@convert_uom_id) +','+ 
		dbo.FNASingleQuote(@show_co2e) +',' +
		dbo.FNASingleQuote(@technology_sub_type) +',' +
		dbo.FNASingleQuote(@fuel_type) +',' +
		dbo.FNASingleQuote(@source_sink_type)+',' +
		dbo.FNASingleQuote(@reduction_type) + ',' +
		dbo.FNASingleQuote(@reduction_sub_type) + ',' +
		dbo.FNASingleQuote(@udf_source_sink_group) +','+ 
		dbo.FNASingleQuote(@udf_group1) +','+ 
		dbo.FNASingleQuote(@udf_group2) +','+ 
		dbo.FNASingleQuote(@udf_group3) +','+ 
		dbo.FNASingleQuote(@frequency) +',' +
		dbo.FNASingleQuote(@protocol) +',' +
		dbo.FNASingleQuote(@include_hypothetical) +',' +
		dbo.FNASingleQuote(@drill_criteria)+',' +
		dbo.FNASingleQuote(@drill_group) + ',' +
		dbo.FNASingleQuote(@round_value) + ',' +
		dbo.FNASingleQuote(@tempTable) +','+ 
		dbo.FNASingleQuote(@process_id)
		
		EXEC spa_print @sqlStmt
		exec(@sqlStmt)	
		exec('Alter table '+@tempTable+' add SNO int identity(1,1)')
		exec spa_print 'MAIN CALLLED'

	--	set @sqlStmt='select count(*) TotalRow,'''+@process_id +''' process_id  from '+ @tempTable
	
	--	exec(@sqlStmt)
	end
	else
	begin
		declare @row_to int,@row_from int
		set @row_to=@page_no * @page_size
		if @page_no > 1 
		set @row_from =((@page_no-1) * @page_size)+1
		else
		set @row_from =@page_no

		set @all_col_names=''

		DECLARE cur_col cursor for
		SELECT     c.name AS Expr1
		FROM         adiha_process.dbo.sysobjects o INNER JOIN
					  adiha_process.dbo.syscolumns c ON o.id = c.id AND o.xtype = 'U'
		WHERE     (o.name like '%'+@process_id+'%')
		
		open cur_col
		fetch next from cur_col into @col_names

		while @@fetch_status=0
		begin
			if @all_col_names=''
				set @all_col_names='['+@col_names+']'
			else
				set @all_col_names=@all_col_names+','+'['+@col_names+']'
			
			fetch next from cur_col into @col_names
		end
		close cur_col
		deallocate cur_col

		set @all_col_names=REVERSE(substring(REVERSE(@all_col_names),charindex(',',REVERSE(@all_col_names))+1,len(@all_col_names)))


		set @sqlStmt='select '+@all_col_names+' from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) 
						+' and '+ cast(@row_to as varchar)+ ' order by sno asc'
		EXEC spa_print @sqlStmt
		exec(@sqlStmt)

	end

END



