/****** Object:  StoredProcedure [dbo].[spa_generator_info_report]    Script Date: 06/14/2009 22:45:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_generator_info_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_generator_info_report]
/****** Object:  StoredProcedure [dbo].[spa_generator_info_report]    Script Date: 06/14/2009 22:45:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_generator_info_report]                   
 @sub_entity_id varchar(100),     
 @strategy_entity_id varchar(100),     
 @book_entity_id varchar(100),             		
 @generator_id int = null,            
 @technology int = null,             
 @generation_state int=null,
 @jurisdiction int=null,
 @generator_group varchar(100)=null	,
 @fuel_type int=null

AS 
SET NOCOUNT ON            
BEGIN


--###########################################
declare @sql_Where varchar(1000)
DECLARE @Sql_Select varchar(8000)

------------------------------------------
-------------------------------------------
SET @sql_Where = ''            
CREATE TABLE #ssbm(                      
 fas_book_id int,            
 stra_book_id int,            
 sub_entity_id int            
)            

CREATE  INDEX [IX_PH6] ON [#ssbm]([fas_book_id])                  
CREATE  INDEX [IX_PH7] ON [#ssbm]([stra_book_id])                  
CREATE  INDEX [IX_PH8] ON [#ssbm]([sub_entity_id])                  

----------------------------------            
SET @Sql_Select=            
'INSERT INTO #ssbm            
SELECT                      
  book.entity_id fas_book_id,book.parent_entity_id stra_book_id, stra.parent_entity_id sub_entity_id             
FROM            
 portfolio_hierarchy book (nolock)             
INNER JOIN            
 Portfolio_hierarchy stra (nolock)            
 ON            
  book.parent_entity_id = stra.entity_id               
WHERE 1=1 '            
IF @sub_entity_id IS NOT NULL            
  SET @Sql_Where = @Sql_Where + ' AND stra.parent_entity_id IN  ( ' + CAST(@sub_entity_id AS VARCHAR) + ') '             
 IF @strategy_entity_id IS NOT NULL            
  SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + CAST(@strategy_entity_id AS VARCHAR) + ' ))'            
  IF @book_entity_id IS NOT NULL            
   SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book_entity_id + ')) '            
SET @Sql_Select=@Sql_Select+@Sql_Where            

exec(@Sql_Select)

----#########3

set @Sql_Select='
select 
	dbo.FNAEmissionHyperlink(3,12101510,rg.name,rg.generator_id,''''''s'''''') as [Source],
	rg.id as [Facility ID],
	RG.[ID2] AS	Unit,
	ISNULL(rg.f_county+'','','''')+ISNULL(rg.city_value_id+'','','''')+ISNULL(state.code,'''') as [Generation State],
	technology.code as [Technology],
	classification.code as [Technology Sub Type],
	fuel.code as [Fuel Type],
	rg.tot_units as [Number of Units],
	rg.nameplate_capacity as [Total Capacity]
from 
	rec_generator rg 
	inner join #ssbm on rg.fas_book_id=#ssbm.fas_book_id
	left join source_counterparty sc on sc.source_counterparty_id=rg.ppa_counterparty_id
	left join static_data_value type_of_entity on type_of_entity.value_id=sc.type_of_entity
	left join static_data_value gis on gis.value_id=rg.gis_value_id
	left join static_data_value classification on classification.value_id=rg.classification_value_id
	left join static_data_value technology on technology.value_id=rg.technology
	left join static_data_value fuel on fuel.value_id=rg.fuel_value_id
	left join static_data_value state on state.value_id=rg.gen_state_value_id
	left join certificate_rule cr on cr.gis_id=rg.gis_value_id
	left join static_data_value report_type on report_type.value_id=cr.reporting_type
where
	1=1 '
	+ case when @sub_entity_id is not null then ' and rg.legal_entity_value_id in('+@sub_entity_id+')' end
	+ case when @generator_id is not null then ' and rg.generator_id='+cast(@generator_id as varchar) else '' end
	+ case when @technology is not null then ' and rg.technology='+cast(@technology as varchar) else '' end
	+ case when @generation_state is not null then ' and rg.gen_state_value_id='+cast(@generation_state as varchar) else '' end
	+ case when @jurisdiction is not null then ' and rg.state_value_id='+cast(@jurisdiction as varchar) else '' end	 
	+ case when @generator_group is not null then ' and rg.generator_group_name='''+@generator_group+'''' else '' end 
	+ case when @fuel_type is not null then ' and rg.fuel_value_id='+cast(@fuel_type as varchar) else '' end+
	+ 'and generator_type=''e'''+
' 
order by rg.name '
--PRINT @Sql_Select
EXEC(@Sql_Select)
END 












