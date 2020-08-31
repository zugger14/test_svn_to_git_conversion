/****** Object:  StoredProcedure [dbo].[spa_get_emissions_inventory_paging]    Script Date: 07/04/2009 19:24:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_emissions_inventory_paging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_emissions_inventory_paging]
/****** Object:  StoredProcedure [dbo].[spa_get_emissions_inventory_paging]    Script Date: 07/04/2009 19:24:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_get_emissions_inventory_paging]
	@flag char(1)='s', -- 's' SUMmary,'d' detail
	@generator_id varchar(2000)=NULL,
	@as_of_date datetime=null,
	@term_start datetime=null,
	@term_end datetime=null,
	@current_forecast char(1)=null,
	@drill_curve varchar(100)=null,
	@drill_uom varchar(100)=null,
	@drill_term varchar(100)=null,
	@drill_generator_name varchar(500)=null,
	@emisssions_reductions char(1)='e',
	@drill_forecast_type varchar(100)=null,
	@forecast_type varchar(100)=null,	
	@fas_book_id varchar(100)=null,
	@technology int=null,
	@fuel_value_id int=null,
	@generator_group_name varchar(500)=null,
	@ems_book_id varchar(200)=null,
	@sub_entity_id varchar(100)=null,
	@strategy_entity_id varchar(100)=null,
	@curve_id int=null,
	@convert_uom_id int=null,
	@show_co2e char(1)='n',
	@report_type char(1)='s', -- 's' group by source/sink - 'g' group by Gas
	@technology_sub_type int=null,
	@fuel_type int=null,
	@source_sink_type int=null,
	@reduction_type int = NULL, 
	@reduction_sub_type int = NULL, 	   
	@udf_source_sink_group int=null,
	@udf_group1 int=null,
	@udf_group2 int=null,
	@udf_group3 int=null,
	@transpose_report char(1)='n',
	@frequency int=null,
	@drill_sub varchar(100)=null,
	@drill_series_type VARCHAR(100)=null,
	@round_value CHAR(1)='0', 
	@show_base_period CHAR(1)='n',
	@process_id varchar(100)=NULL, 
	@page_size int =NULL,
	@page_no int=NULL 
AS
BEGIN


	DECLARE @user_login_id varchar(50),@tempTable varchar(300),@col_names varchar(100), @all_col_names varchar(1000)

	set @user_login_id=dbo.FNADBUser()

	if @process_id is NULL
	Begin
		set @flag='i'
		set @process_id=REPLACE(newid(),'-','_')
	End
	set @tempTable=dbo.FNAProcessTableName('batch_report', @user_login_id,@process_id)
	declare @sqlStmt varchar(5000)



if @flag='i'
begin

--		set @sqlStmt='create table '+ @tempTable+'( 
--		sno int  identity(1,1),
--		sourceSink varchar(50) ,
--		seriesType varchar(50) ,
--		emissionsType varchar(50) ,
--		term datetime ,
--		as_of_date datetime ,
--		frequency varchar(50) ,
--		inventory float ,
--		baseInventory float ,
--		reduction float ,
--		uom varchar(50) ,
--		heatContent float ,
--		heatContentUOM varchar(50) 
--
--		)'
--
--	EXEC spa_print @sqlStmt

	--exec(@sqlStmt)
	
	--set @sqlStmt=' insert  '+@tempTable+'

	set @sqlStmt=' 
	exec  spa_get_emissions_inventory s, '+ 
	dbo.FNASingleQuote(@generator_id) +','+ 
	dbo.FNASingleQuote(@as_of_date) +','+ 
	dbo.FNASingleQuote(@term_start) +','+ 
	dbo.FNASingleQuote(@term_end) +','+ 
	dbo.FNASingleQuote(@current_forecast) +',' +
	dbo.FNASingleQuote(@drill_curve) +',' +
	dbo.FNASingleQuote(@drill_uom) +',' +
	dbo.FNASingleQuote(@drill_term)+',' +
	dbo.FNASingleQuote(@drill_generator_name) + ',' +
	
	dbo.FNASingleQuote(@emisssions_reductions) +','+ 
	dbo.FNASingleQuote(@drill_forecast_type) +','+ 
	dbo.FNASingleQuote(@forecast_type) +','+ 
	dbo.FNASingleQuote(@fas_book_id) +','+ 
	dbo.FNASingleQuote(@technology) +',' +
	dbo.FNASingleQuote(@fuel_value_id) +',' +
	dbo.FNASingleQuote(@generator_group_name) +',' +
	dbo.FNASingleQuote(@ems_book_id)+',' +
	dbo.FNASingleQuote(@sub_entity_id) + ',' +
	
	dbo.FNASingleQuote(@strategy_entity_id) +','+ 
	dbo.FNASingleQuote(@curve_id) +','+ 
	dbo.FNASingleQuote(@convert_uom_id) +','+ 
	dbo.FNASingleQuote(@show_co2e) +','+ 
	dbo.FNASingleQuote(@report_type) +',' +
	dbo.FNASingleQuote(@technology_sub_type) +',' +
	dbo.FNASingleQuote(@fuel_type) +',' +
	dbo.FNASingleQuote(@source_sink_type)+',' +
	dbo.FNASingleQuote(@reduction_type) + ',' +
	dbo.FNASingleQuote(@reduction_sub_type) +','+ 
	dbo.FNASingleQuote(@udf_source_sink_group) +','+ 
	dbo.FNASingleQuote(@udf_group1) +','+ 
	dbo.FNASingleQuote(@udf_group2) +','+ 
	dbo.FNASingleQuote(@udf_group3) +',' +
	dbo.FNASingleQuote(@transpose_report) + ',' +
	dbo.FNASingleQuote(@frequency) + ',' +
	dbo.FNASingleQuote(@drill_sub) + ',' +
	dbo.FNASingleQuote(@drill_series_type) + ',' +
	dbo.FNASingleQuote(@round_value) + ',' +
	dbo.FNASingleQuote(@show_base_period) + ',' +
	dbo.FNASingleQuote(@process_id)
	
	EXEC spa_print @sqlStmt

	exec(@sqlStmt)	
	exec('Alter table '+@tempTable+' add SNO int identity(1,1)')

	set @sqlStmt='select count(*) TotalRow,'''+@process_id +''' process_id  from '+ @tempTable
	exec(@sqlStmt)
end
else
begin
	declare @row_to int,@row_from int
	set @row_to=@page_no * @page_size
	if @page_no > 1 
	set @row_from =((@page_no-1) * @page_size)+1
	else
	set @row_from =@page_no

	--########### Group Label
--	declare @group1 varchar(100),@group2 varchar(100),@group3 varchar(100),@group4 varchar(100)
--	 if exists(select group1,group2,group3,group4 from source_book_mapping_clm)
--	begin	
--		select @group1=group1,@group2=group2,@group3=group3,@group4=group4 from source_book_mapping_clm
--	end
--	else
--	begin
--		set @group1='Group1'
--		set @group2='Group2'
--		set @group3='Group3'
--		set @group4='Group4'
--	 
--	end
--######## End


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

end










