

IF EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[spa_get_rec_activity_report]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_get_rec_activity_report]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[spa_get_rec_activity_report]            
	 @as_of_date varchar(20),            
	 @subsidiary_id varchar(MAX),             		
	 @strategy_id varchar(MAX) = NULL,             
	 @book_id varchar(MAX) = NULL, 
	 @subbook_id VARCHAR(MAX) = NULL,            
	 @report_type int = null,  --assignment_type              
	 @summary_option char(1) = 's',  --'s' summary, 't' trader, 'g' generator,'h' generator/credit source group,'i' generator/credit source by group, 'c' counterparty, 'o' Env Product & Vintage,'v' Trader & Vintage,'z' Counterparty & Vintage,'y' Generator BY Year 'b' year activity, 'x' Tier Type
	 @compliance_year int =null,            
	 @assigned_state INT = null,      --jurisdiciton      
	 @curve_id int = NULL,            
	 @generator_id int = null,            
	 @uom_id int = null,            
	 @convert_assignment_type_id int = null,            
	 @deal_id_from int = null,             
	 @deal_id_to int = null,            
	 @gis_cert_number varchar(250)= null,            
	 @gis_cert_number_to varchar(250)= null,            
	 @gen_date_from varchar(20) = null,            
	 @gen_date_to varchar(20) = null,             
	 @deal_date_from varchar(20) = null,             
	 @deal_date_to varchar(20) = null,             
	 @technology int = null,             
	 @buy_sell_flag varchar(1) = null,             
	 @status_id varchar(1)  = null,   --'a' for active, 'e' for expired, 's' for surrendered            
	 @gis_id int = null,             
	 @counterparty_id int = null,            
	 @deal_type int = null,            
	 @to_be_assigned_type int = null,            
	 @deal_sub_type int = null,
	 @generation_state int=null,
	 @include_inventory char(1)='n',    
	  --These are for drill down            
	 @drill_Counterparty varchar(100)=null,             
	 @drill_Technology varchar(100)=null,             
	 @drill_DealDate varchar(100)=null,             
	 @drill_BuySell varchar(100)=null,             
	 @drill_State varchar(100)=null,             
	 @drill_oblication varchar(100)=null,             
	 @drill_UOM varchar(100) = null,            
	 @drill_trader varchar(100) = null,             
	 @drill_Generator varchar(100) = null,            
	 @drill_Assignment varchar(100) = null,            
	 @drill_Expiration varchar(100) = null,            	 
	 -- For target report            
	 @Target_report CHAR(1)='n',     -- 't' means transactions report       
	 @Plot CHAR(1)='n',            
	 @included_banked varchar(1) = 'n',    
	 @program_scope varchar(50)=null,    
	 @program_type char(1)='b', --- 'a' -> Compliance, 'b' -> cap&trade  
	 @round_value VARCHAR(1)='0', 	 
	 @udf_group1 INT=NULL,
	 @udf_group2 INT=NULL,
	 @udf_group3 INT=NULL,		
	 @tier_type INT=NULL,
	 @include_expired CHAR(1)='n',
	 @expiration_from  varchar(20)=NULL,
	 @expiration_to  varchar(20)=NULL,
	 @source_sub_book_id varchar(100) = NULL,
	 
	 @drill_tier_type varchar(100) = NULL,
	 @drill_env_product varchar(100) = NULL,
	 @is_from_tier_and_expiration VARCHAR(1) = 'n',
	 @to_be_assign_state INT = NULL,  --to be assigned jurisdiction
	 @is_generator_group CHAR(1) = NULL, -- for source/credit generator group
	 @drill_state_without_assigned_state varchar(50) = NULL, 
	 @drill_from_activity  CHAR (1) = NULL,
	 
	 @batch_process_id varchar(50)=NULL,        
	 @batch_report_param varchar(1000)=NULL,            
	--@apply_paging int=0,  --'1'=enable, '0'=disable
	@apply_paging CHAR(1) = 'n',
	@page_size int =NULL,
	@page_no int=NULL
	
	
 AS  
    
IF @drill_tier_type IS NOT NULL 
BEGIN
	SET @drill_Expiration = YEAR(@drill_Expiration)	
END
SET  @is_from_tier_and_expiration = isnull(@is_from_tier_and_expiration, 'n')
--SET @round_value=0
--print @summary_option

--print  @convert_uom_id
--print @Target_report
--print @Plot
--print @included_banked
--print @sub_entity_id
--print @summary_option
--print @as_of_date
 
BEGIN            
SET NOCOUNT ON            
--         
Declare @assignment_type int        

DECLARE @assigned_state_jurisdiction INT

DECLARE @sub_entity_id varchar(MAX)             		
DECLARE @strategy_entity_id varchar(MAX)             
DECLARE @book_entity_id varchar(MAX)
DECLARE @enable_paging INT 
DECLARE @convert_uom_id INT

SET @sub_entity_id = @subsidiary_id
SET @strategy_entity_id = @strategy_id
SET @book_entity_id = @book_id

IF @assigned_state IS NOT NULL 
BEGIN
	SET @assigned_state_jurisdiction = @assigned_state
END

IF @to_be_assign_state IS NOT NULL 
BEGIN
	SET @assigned_state_jurisdiction = @to_be_assign_state
END

IF @apply_paging IS NOT NULL 
BEGIN
	SET @enable_paging = CASE WHEN @apply_paging = 'y' THEN 1 ELSE 0 END 
END

IF @uom_id IS NOT NULL 
BEGIN
	SET @convert_uom_id = @uom_id
END

--If @summary_option='b'
--	set @as_of_date='2999-12-31'
--***********************************************      
-- declare  @include_inventory char(1)
-- set @include_inventory='n'
--to id = 3 mmbtu            
/*
--uncomment these to test locally            
 declare @deal_sub_type int           
 declare  @as_of_date varchar(20)            
 declare  @sub_entity_id varchar(100)            
 declare  @strategy_entity_id varchar(100)            
 declare  @book_entity_id varchar(100)            
 declare  @report_type int            
 declare  @summary_option char(1)            
 declare  @compliance_year int            
 declare  @assigned_state int            
 declare  @included_banked varchar(1)            
 declare  @gis_cert_number varchar(250)            
 declare  @gis_cert_number_to varchar(250)            
 declare  @deal_id_from int             
 declare  @deal_id_to int             
 declare  @generator_id int            
 declare  @convert_uom_id int            
 declare  @convert_assignment_type_id int             
 declare  @curve_id int            
 declare  @curve_name varchar(100)            
--             
-- ---new input optional parameters            
 declare  @gen_date_from varchar(20)            
 declare  @gen_date_to varchar(20)            
 declare  @deal_date_from varchar(20)            
 declare  @deal_date_to varchar(20)            
 declare  @technology int            
 declare  @buy_sell_flag varchar(1)            

 declare @status_id varchar(1)   --'a' for active, 'e' for expired, 's' for surrendered            
 declare  @gis_id int            
 declare  @counterparty_id int            
 DECLARE  @to_be_assigned_type int             
 DECLARE @deal_type int             
 --Declare  @assignment_type int            
DECLARE  @drill_Counterparty varchar(100)            
DECLARE  @drill_Technology varchar(100)            
DECLARE  @drill_DealDate varchar(100)            
DECLARE  @drill_BuySell varchar(100)            
DECLARE  @drill_State varchar(100)            
DECLARE  @drill_oblication varchar(100)            
DECLARE  @drill_UOM varchar(100)            
DECLARE  @drill_trader varchar(100)            
DECLARE  @drill_Generator varchar(100)            
DECLARE  @drill_Assignment varchar(100)            
DECLARE  @drill_Expiration varchar(100)            
DECLARE  @Target_report CHAR(1)            
DECLARE  @Plot CHAR(1)            
DECLARE @batch_process_id varchar(50)        
DECLARE @batch_report_param varchar(500)        

            
set @assignment_type = null            
set @Target_report='t'            
set @Plot='n'            
--             
set @as_of_date = '2006-10-22'            
set @sub_entity_id = '135'            
set @strategy_entity_id = NULL
set @book_entity_id = '158'
set @report_type = null            
--set @summary_option = 's'            
set @summary_option = 's'            
set @compliance_year = null            
set @assigned_state = null            
--set @include_banked = 'y'            
            
set @gis_cert_number = null            
set @gis_cert_number_to = null             
set @deal_id_from = null            
set @deal_id_to = null            
set @generator_id = NULL            
set @convert_uom_id = 24            
set @convert_assignment_type_id = null            
set @curve_id = null            
set @curve_name = null            
set @gen_date_from = null            
set @gen_date_to = null            
set @deal_date_from = null            
set @deal_date_to = null            
set @technology = null            
set @buy_sell_flag = null            
set @status_id = null   --NULL for all, 'a' for active, 'e' for expired, 's' for surrendered            
set @gis_id = null            
set @counterparty_id = null            
--***********check for status and expiration after wards....            
-- drop table #tempAsset            
-- drop table #gen_eligibility            
drop table #ssbm            
drop table #conversion            
drop table #bonus            
drop table #temp_duration            
drop table #temp_assign
-- ---==========end of testdata            
-- declare @asset_type_id int            
-- set @asset_type_id = 402            
*/
            
Declare @Sql_Select varchar(MAX)            
Declare @Sql_Select3 varchar(MAX)            
Declare @Sql_Select1 varchar(MAX)            
Declare @Sql_Select2 varchar(MAX)            
Declare @Sql_SelectS varchar(MAX)            
Declare @Sql_SelectD varchar(MAX)            
DECLARE @Sql_expiration_date VARCHAR(2000)            
            
DECLARE @Sql_expiration VARCHAR(MAX)            
DECLARE @Sql_assignment VARCHAR(MAX)            
DECLARE @Sql_activity VARCHAR(MAX)            
DECLARE @Sql_assignment_target VARCHAR(MAX)            
DECLARE @Sql_compliance VARCHAR(MAX)            
Declare @Sql_Where varchar(MAX)            
declare @ph_tbl varchar(MAX)            
declare @process_id_dn varchar(50)            
declare @conv_tbl varchar(MAX)            
            
Declare @term_where_clause varchar(MAX)            
DECLARE @include_forecast varchar(1)             
DECLARE @to_be_assigned_type_code varchar(50)            
DECLARE @deal_type_id VARCHAR(50)
            



--////////////////////////////Paging_Batch///////////////////////////////////////////
--print	'@batch_process_id:'+@batch_process_id 
--print	'@batch_report_param:'+	@batch_report_param

declare @str_batch_table varchar(max),@str_get_row_number VARCHAR(100)
declare @temptablename varchar(128),@user_login_id varchar(50),@flag CHAR(1)
DECLARE @is_batch bit
declare @maturity_date varchar(50)
set @maturity_date = cast(@compliance_year as varchar) + '-12-01'
set @str_batch_table=''
SET @str_get_row_number=''

declare @sql_stmt varchar(MAX)

IF @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL
	SET @is_batch = 1
ELSE
	SET @is_batch = 0
	
IF (@is_batch = 1 OR @enable_paging = 1)
begin
	IF (@batch_process_id IS NULL)
		SET @batch_process_id = REPLACE(NEWID(), '-', '_')
		
	SET @user_login_id = dbo.FNADBUser()	
	SET @temptablename = dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
	--PRINT('@temptablename' + @temptablename)
	SET @str_batch_table=', ROWID=IDENTITY(int,1,1) INTO ' + @temptablename
--	SET @str_get_row_number=', ROWID=IDENTITY(int,1,1)'
	IF @enable_paging = 1
	BEGIN
		
		IF @page_size IS not NULL
		begin
			declare @row_to int,@row_from int
			set @row_to=@page_no * @page_size
			if @page_no > 1 
				set @row_from =((@page_no-1) * @page_size)+1
			else
				set @row_from =@page_no
			set @sql_stmt=''
			--	select @temptablename
			--select * from adiha_process.sys.columns where [object_id]=object_id(@temptablename) and [name]<>'ROWID' ORDER BY column_id

			select @sql_stmt=@sql_stmt+',['+[name]+']' from adiha_process.sys.columns where [object_id]=object_id(@temptablename) and [name]<>'ROWID' ORDER BY column_id
			SET @sql_stmt=SUBSTRING(@sql_stmt,2,LEN(@sql_stmt))
			
			set @sql_stmt='select '+@sql_stmt +'
				  from '+ @temptablename   +' 
				  where rowid between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) 
				 
			--print(@sql_stmt)		
			exec(@sql_stmt)
			return
		END --else @page_size IS not NULL
	END --enable_paging = 1
		
end

--////////////////////////////End_Batch///////////////////////////////////////////

set @assignment_type=@report_type            
            
set @to_be_assigned_type_code = NULL            

if @to_be_assigned_type IS NOT NULL            
	select @to_be_assigned_type_code = code from static_data_value where value_id = @to_be_assigned_type            
            
            

	IF @program_type='a'
		set @deal_type_id='400 ' 
	ELSE IF @target_report='y' AND @program_type='b'
		set @deal_type_id='400,406' 
	ELSE
		set @deal_type_id='400 ' 
            
--declare @report_identifier int            
--*****************For batch processing********************************        
  /*      
DECLARE @str_batch_table varchar(max)        
SET @str_batch_table=''        
IF @batch_process_id is not null        
 SELECT @str_batch_table=dbo.FNABatchProcess('s',@batch_process_id,@batch_report_param,NULL,NULL,NULL)         
 */           
            
            
--IF @gis_cert_number_to IS NULL AND @gis_cert_number IS NOT NULL            
-- set @gis_cert_number_to = @gis_cert_number            

--IF @gis_cert_number_to IS NOT NULL AND @gis_cert_number IS NULL            
-- set @gis_cert_number = @gis_cert_number_to            

IF @deal_id_from IS NOT NULL AND @deal_id_to IS NULL            
 set @deal_id_to = @deal_id_from            

IF @deal_id_from IS NULL AND @deal_id_to IS NOT NULL            
 set @deal_id_from = @deal_id_to          
  
IF @gen_date_to IS NULL            
 SET @gen_date_to = '9999-01-01'

IF @gen_date_from IS NULL 
 SET @gen_date_from = '1900-01-01'

IF @deal_date_from IS NOT NULL AND @deal_date_to IS NULL            
 SET @deal_date_to = @deal_date_from            

IF @deal_date_from IS NULL AND @deal_date_to IS NOT NULL            
 SET @deal_date_from = @deal_date_to            
            
IF @expiration_from IS NOT NULL AND @expiration_to IS NULL            
 SET @expiration_to = @expiration_from            

IF @expiration_from IS NULL AND @expiration_to IS NOT NULL            
 SET @expiration_from = @expiration_to            


--========Asset            
--******************************************************            
--CREATE source book map table and build index            
--*********************************************************            
SET @sql_Where = ''            
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

SET @Sql_Select=            
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
IF @sub_entity_id IS NOT NULL            
  SET @Sql_Where = @Sql_Where + ' AND stra.parent_entity_id IN  ( ' + @sub_entity_id + ') '             
IF @strategy_entity_id IS NOT NULL            
  SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + @strategy_entity_id + ' ))'            
IF @book_entity_id IS NOT NULL            
  SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book_entity_id + ')) '            
--IF @source_sub_book_id IS NOT NULL            
--  SET @Sql_Where = @Sql_Where + ' AND (ssbm.book_deal_type_map_id IN(' + CAST(@source_sub_book_id AS VARCHAR) + ')) '            
IF @subbook_id IS NOT NULL            
  SET @Sql_Where = @Sql_Where + ' AND (ssbm.book_deal_type_map_id IN(' + CAST(@subbook_id AS VARCHAR) + ')) '
  
SET @Sql_Select=@Sql_Select+@Sql_Where        
   --print @sql_select
EXEC (@Sql_Select)            
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
            
--******************************************************            
--CREATE Conversion table and build index            
--*********************************************************            
-- CREATE TABLE #Conversion(            
--  from_source_uom_id int,            
--  to_source_uom_id int,            
--  state_value_id int,            
--  assignment_type_value_id int,            
--  curve_id int,        
--  conversion_factor FLOAT,            
--  uom_label VARCHAR(100) COLLATE DATABASE_DEFAULT ,
--  curve_label VARCHAR(100) COLLATE DATABASE_DEFAULT 
-- )           
-- 
-- IF @convert_uom_id IS NOT NULL
-- BEGIN
-- 	INSERT INTO             
-- 	 #Conversion            
-- 	SELECT DISTINCT            
-- 	 COALESCE(conv1.from_source_uom_id, conv2.from_source_uom_id, conv3.from_source_uom_id,conv4.from_source_uom_id,            
-- 	   conv5.from_source_uom_id) from_source_uom_id,            
-- 	 COALESCE(conv1.to_source_uom_id, conv2.to_source_uom_id, conv3.to_source_uom_id,conv4.to_source_uom_id,            
-- 	   conv5.to_source_uom_id) to_source_uom_id,            
-- 	 COALESCE(conv1.state_value_id, conv2.state_value_id, conv3.state_value_id,conv4.state_value_id,            
-- 	   conv5.state_value_id) state_value_id,            
-- 	 COALESCE(conv1.assignment_type_value_id, conv2.assignment_type_value_id, conv3.assignment_type_value_id,            
-- 	   conv4.assignment_type_value_id,conv5.assignment_type_value_id) assignment_type_value_id,            
-- 	 COALESCE(conv1.curve_id, conv2.curve_id, conv3.curve_id,            
-- 	   conv4.curve_id,conv5.curve_id) curve_id,            
-- 	 COALESCE(conv1.conversion_factor, conv2.conversion_factor, conv3.conversion_factor,            
-- 	   conv4.conversion_factor,conv5.conversion_factor) conversion_factor,            
-- 	 COALESCE(conv1.uom_label, conv2.uom_label, conv3.uom_label,            
-- 	   conv4.uom_label,conv5.uom_label) uom_label,            
-- 	 COALESCE(conv1.curve_label, conv2.curve_label, conv3.curve_label,            
-- 	   conv4.curve_label,conv5.curve_label) curve_label            
-- 	from             
-- 	(            
-- 	--State, Curve, Assignment               
-- 	select  state_value_id, assignment_type_value_id, curve_id, from_source_uom_id, to_source_uom_id, conversion_factor, uom_label, curve_label            
-- 	  from rec_volume_unit_conversion            
-- 	where  to_source_uom_id = @convert_uom_id and            
-- 	 (@assignment_type  IS NOT NULL and assignment_type_value_id is not null and assignment_type_value_id = @assignment_type) AND            
-- 	 curve_id is not null and state_value_id is not null) conv1 --on            
-- 	--conv1.from_source_uom_id = rvuc.from_source_uom_id and conv1.to_source_uom_id = rvuc.to_source_uom_id             
-- 	full outer join             
-- 	(            
-- 	--State, Curve            
-- 	select  state_value_id, mis.value_id assignment_type_value_id, curve_id, from_source_uom_id, to_source_uom_id, conversion_factor, uom_label, curve_label            
-- 	from rec_volume_unit_conversion inner join            
-- 	(select value_id, @convert_uom_id conv_id from static_data_value where type_id = 10013) mis ON             
-- 	 mis.conv_id = to_source_uom_id            
-- 	where  to_source_uom_id = @convert_uom_id and            
-- 	 assignment_type_value_id is null AND            
-- 	 curve_id is not null and state_value_id is not null) conv2 on            
-- 	conv2.from_source_uom_id = conv1.from_source_uom_id and conv2.to_source_uom_id = conv1.to_source_uom_id            
-- 	and conv2.state_value_id = conv1.state_value_id and conv2.assignment_type_value_id = conv1.assignment_type_value_id and            
-- 	conv2.curve_id = conv1.curve_id            
-- 	             
-- 	full outer join            
-- 	(            
-- 	--Curve, Assignment            
-- 	select  mis2.value_id state_value_id, assignment_type_value_id, curve_id, from_source_uom_id, to_source_uom_id, conversion_factor, uom_label, curve_label             
-- 	from rec_volume_unit_conversion  inner join            
-- 	(select value_id, @convert_uom_id conv_id from static_data_value where type_id = 10002) mis2 ON             
-- 	 mis2.conv_id = to_source_uom_id            
-- 	where  to_source_uom_id = @convert_uom_id and            
-- 	 (@assignment_type  IS NOT NULL and assignment_type_value_id is not null and assignment_type_value_id = @assignment_type) AND            
-- 	 curve_id is not null and state_value_id is null) conv3 on             
-- 	conv3.from_source_uom_id = conv2.from_source_uom_id and conv3.to_source_uom_id = conv2.to_source_uom_id            
-- 	and conv3.state_value_id = conv2.state_value_id and conv3.assignment_type_value_id = conv2.assignment_type_value_id and            
-- 	conv3.curve_id = conv2.curve_id            
-- 	            
-- 	full outer join            
-- 	(            
-- 	--Curve    
-- 	select  mis2.value_id state_value_id, mis.value_id assignment_type_value_id, curve_id, from_source_uom_id, to_source_uom_id, conversion_factor, uom_label, curve_label             
-- 	from rec_volume_unit_conversion inner join            
-- 	(select value_id, @convert_uom_id conv_id from static_data_value where type_id = 10013) mis ON             
-- 	 mis.conv_id = to_source_uom_id inner join            
-- 	(select value_id, @convert_uom_id conv_id from static_data_value where type_id = 10002) mis2 ON             
-- 	 mis2.conv_id = to_source_uom_id            
-- 	where  to_source_uom_id = @convert_uom_id and            
-- 	 assignment_type_value_id IS NULL AND            
-- 	 curve_id is not null and state_value_id is null            
-- 	) conv4 on             
-- 	conv4.from_source_uom_id = conv3.from_source_uom_id and conv4.to_source_uom_id = conv3.to_source_uom_id            
-- 	and conv4.state_value_id = conv3.state_value_id and conv4.assignment_type_value_id = conv3.assignment_type_value_id and            
-- 	conv4.curve_id = conv3.curve_id            
-- 	            
-- 	full outer join            
-- 	(            
-- 	--ONLY uom            
-- 	select  mis2.value_id state_value_id, mis.value_id assignment_type_value_id,             
-- 	 mis3.source_curve_def_id curve_id, from_source_uom_id, to_source_uom_id, conversion_factor, uom_label, curve_label             
-- 	from rec_volume_unit_conversion inner join            
-- 	(select value_id, @convert_uom_id conv_id from static_data_value where type_id = 10013) mis ON             
-- 	 mis.conv_id = to_source_uom_id inner join            
-- 	(select value_id, @convert_uom_id conv_id from static_data_value where type_id = 10002) mis2 ON             
-- 	 mis2.conv_id = to_source_uom_id  inner join            
-- 	(select source_curve_def_id,  @convert_uom_id conv_id from source_price_curve_def) mis3 ON            
-- 	 mis3.conv_id = to_source_uom_id             
-- 	where  to_source_uom_id = @convert_uom_id and            
-- 	 assignment_type_value_id IS NULL AND            
-- 	 curve_id is null and state_value_id is null )conv5 on             
-- 	conv5.from_source_uom_id = conv4.from_source_uom_id and conv5.to_source_uom_id = conv4.to_source_uom_id            
-- 	and conv5.state_value_id = conv4.state_value_id and conv5.assignment_type_value_id = conv4.assignment_type_value_id and            
-- 	conv5.curve_id = conv4.curve_id            
-- -- UNION          
-- -- 	(            
-- -- 	--ONLY uom            
-- -- 	select distinct from_source_uom_id, to_source_uom_id, NULL state_value_id, mis.value_id assignment_type_value_id,             
-- -- 	 mis3.source_curve_def_id curve_id,  conversion_factor, uom_label, curve_label             
-- -- 	from rec_volume_unit_conversion inner join            
-- -- 	(select value_id, @convert_uom_id conv_id from static_data_value where type_id = 10013) mis ON             
-- -- 	 mis.conv_id = to_source_uom_id inner join            
-- -- 	(select source_curve_def_id,  @convert_uom_id conv_id from source_price_curve_def) mis3 ON            
-- -- 	 mis3.conv_id = to_source_uom_id             
-- -- 	where  to_source_uom_id = @convert_uom_id and
-- -- 	 state_value_id is null )
-- END
-- ------------------------------------------------------------            
-- CREATE  INDEX [IX_Conversion1] ON [#COnversion]([from_source_uom_id])                  
-- CREATE  INDEX [IX_Conversion2] ON [#COnversion]([to_source_uom_id])                  
-- CREATE  INDEX [IX_Conversion3] ON [#COnversion]([state_value_id])                  
-- CREATE  INDEX [IX_Conversion4] ON [#COnversion]([assignment_type_value_id])                  
-- CREATE  INDEX [IX_Conversion5] ON [#COnversion]([curve_id])                  
-- --------------------------------------------------------------------            
--******************************************************            
--END of Conversion table             
--*********************************************************            

--select * from #conversion
--******************************************************            
--CREATE Bonus table and build index            
--*********************************************************            



CREATE TABLE #bonus(            
 state_value_id int,            
 technology int,            
 assignment_type_value_id int,            
 from_date datetime,            
 to_date datetime,            
 gen_code_value int,            
 bonus_per Float,
 curve_id INT	            
)            
            
INSERT INTO #bonus            
select  COALESCE(bS.state_value_id, bA.state_value_id) state_value_id,            
 COALESCE(bS.technology, bA.technology) technology,            
 COALESCE(bS.assignment_type_value_id, bA.assignment_type_value_id) assignment_type_value_id,            
 COALESCE(bS.from_date, bA.from_date) from_date,            
 COALESCE(bS.to_date, bA.to_date) to_date,            
 COALESCE(bS.gen_code_value, bA.gen_code_value) gen_code_value,            
 COALESCE(bS.bonus_per, bA.bonus_per) bonus_per ,
 COALESCE(bS.curve_id, bA.curve_id) curve_id         
from            
(select state_value_id, technology, isnull(assignment_type_value_id, 5149) assignment_type_value_id, from_date, to_date,             
gen_code_value, bonus_per,curve_id            
from state_properties_bonus where gen_code_value is not null            
) bS            
full outer join            
(            
select state_value_id, technology, assignment_type_value_id, from_date, to_date,             
state.value_id as gen_code_value, bonus_per,curve_id            
from            
(select state_value_id, technology, isnull(assignment_type_value_id, 5149) assignment_type_value_id, from_date, to_date,             
 bonus_per, 1 as link_id,curve_id            
from state_properties_bonus where gen_code_value is  null) bonus inner join            
(select value_id, 1 as link_id from static_data_value where type_id = 10016) state            
on state.link_id = bonus.link_id            
) bA on bA.state_value_id = bs.state_value_id and bA.technology = bS.technology and            
bA.assignment_type_value_id = bS.assignment_type_value_id and            
bA.from_date = bs.from_date and bA.to_date = bs.to_date       
and bA.curve_id=bA.curve_id     
--------------------------------------------------------------            
CREATE  INDEX [IX_bonus1] ON [#bonus](state_value_id)                  
CREATE  INDEX [IX_bonus2] ON [#bonus]([technology])                  
CREATE  INDEX [IX_bonus3] ON [#bonus]([assignment_type_value_id])                  
CREATE  INDEX [IX_bonus4] ON [#bonus]([from_date])                  
CREATE  INDEX [IX_bonus5] ON [#bonus]([to_date])                  
CREATE  INDEX [IX_bonus6] ON [#bonus]([gen_code_value])                  
--------------------------------------------------------------            


            
--*********************************************************            
create table #temp_duration_1            
	(state_value_id int,            
	technology int,            
	assignment_type_value_id int,            
	duration int,            
	offset_duration int,            
	gen_code_value int,             
	banking_period_frequency int,
	not_expire CHAR(1) COLLATE DATABASE_DEFAULT ,
	curve_id int
)            
            
--******************************************************            
--duration            
--*********************************************************            
            
insert into #temp_duration_1            
select  COALESCE(bS.state_value_id, bA.state_value_id) state_value_id,            
 COALESCE(bS.technology, bA.technology) technology,            
 COALESCE(bS.assignment_type_value_id, bA.assignment_type_value_id) assignment_type_value_id,            
 COALESCE(bS.duration, bA.duration) duration,            
 COALESCE(bS.offset_duration, bA.offset_duration) offset_duration,            
 COALESCE(bS.gen_code_value, bA.gen_code_value) gen_code_value,            
 COALESCE(bS.banking_period_frequency, bA.banking_period_frequency) banking_period_frequency,
 COALESCE(bS.not_expire, bA.not_expire) not_expire,           
 COALESCE(bS.curve_id, bA.curve_id) curve_id           
from            
(select state_value_id, technology, isnull(assignment_type_value_id, 5149) assignment_type_value_id, duration, offset_duration,             
gen_code_value, banking_period_frequency,not_expire,curve_id           
from state_properties_duration where gen_code_value is not null            
) bS            
full outer join            
(            
select state_value_id, technology, isnull(assignment_type_value_id, 5149) assignment_type_value_id, duration, offset_duration,             
state.value_id as gen_code_value, banking_period_frequency,not_expire,curve_id            
from            
(select state_value_id, technology, isnull(assignment_type_value_id, 5149) assignment_type_value_id, duration, offset_duration,             
gen_code_value, banking_period_frequency, 1 as link_id,not_expire,curve_id            
from state_properties_duration where gen_code_value is  null) duration inner join            
(select value_id, 1 as link_id from static_data_value where type_id = 10016) state            
on state.link_id = duration.link_id            
) bA on 
bA.state_value_id = bs.state_value_id and bA.technology = bS.technology
AND bA.assignment_type_value_id = bS.assignment_type_value_id             
            


-- technology which are null
select  
	COALESCE(bS.state_value_id, bA.state_value_id) state_value_id,            
	 COALESCE(bS.technology, bA.technology) technology,            
	 COALESCE(bS.assignment_type_value_id, bA.assignment_type_value_id) assignment_type_value_id,            
	 COALESCE(bS.duration, bA.duration) duration,            
	 COALESCE(bS.offset_duration, bA.offset_duration) offset_duration,            
	 COALESCE(bS.gen_code_value, bA.gen_code_value) gen_code_value,            
	 COALESCE(bS.banking_period_frequency, bA.banking_period_frequency) banking_period_frequency,
	 COALESCE(bS.not_expire, bA.not_expire) not_expire,           
	 COALESCE(bS.curve_id, bA.curve_id) curve_id   
	into #temp_duration
	from            
	(select state_value_id, technology, isnull(assignment_type_value_id, 5149) assignment_type_value_id, duration, offset_duration,             
	gen_code_value, banking_period_frequency,not_expire,curve_id           
	from #temp_duration_1 where technology is not null            
	) bS            
	FULL outer join            
	(            
	select state_value_id, tech.value_id technology, isnull(assignment_type_value_id, 5149) assignment_type_value_id, duration, offset_duration,             
	 gen_code_value, banking_period_frequency,not_expire,curve_id            
	from            
	(select state_value_id, technology, isnull(assignment_type_value_id, 5149) assignment_type_value_id, duration, offset_duration,             
	gen_code_value, banking_period_frequency, 1 as link_id,not_expire,curve_id            
	from #temp_duration_1 where technology is  null) duration inner join            
	(select value_id, 1 as link_id from static_data_value where type_id = 10009) tech            
	on tech.link_id = duration.link_id            
	) bA on 
	bA.state_value_id = bs.state_value_id 
	AND bA.gen_code_value = bS.gen_code_value
	AND bA.curve_id = bS.curve_id
	AND bA.assignment_type_value_id = bS.assignment_type_value_id   
	AND bA.not_expire=bS.not_expire


CREATE  INDEX [IX_duration1] ON [#temp_duration](state_value_id)                  
CREATE  INDEX [IX_duration2] ON [#temp_duration]([technology])                  
CREATE  INDEX [IX_duration3] ON [#temp_duration]([assignment_type_value_id])                  
CREATE  INDEX [IX_duration4] ON [#temp_duration]([gen_code_value])                  
                  




--******************************************************            
--End of duration            
--*********************************************************     

DECLARE @jurisdiction VARCHAR(20)
SELECT  @jurisdiction = code from static_data_value where value_id = @assigned_state_jurisdiction

SET @sql_expiration_date=' 
dbo.fnastddate(
dbo.FNADEALRECExpirationState (sdh.source_deal_header_id,sdh.contract_expiration_date,sdh.assignment_type_value_id, isnull(' + isnull(cast(@assigned_state_jurisdiction AS VARCHAR(20)), 'NULL') + ', state.value_id)))'
--case  
--
-- WHEN (buy_sell_flag = ''s'' and status_value_id<>5180) THEN        
-- dbo.FNADateFormat(dbo.FNALastDayInDate(cast(ISNULL(sp.calendar_to_month,12) as varchar) + ''/01/'' +         
-- case when (buy_sell_flag = ''s'' and status_value_id<>5180 and sdh.assignment_type_value_id IS NULL) then cast(year(deal_date) as varchar)         
-- else cast(sdh.compliance_year as varchar) end))        
--when (COALESCE(td.banking_period_frequency,             
--  sp.banking_period_frequency, 706) = 703) then             
--  dbo.FNADateFormat(dbo.FNALastDayInDate(              
--   dateadd(mm,             
--    case when(ISNULL(rg1.gen_offset_technology,''n'') = ''n'') then             
--     COALESCE(td.duration, sp.duration, 0)                 
--     else            
--     COALESCE(td.offset_duration, sp.offset_duration, 0)             
--      end,            
--      sdh.term_start)            
--     ))            
--            
--   else  --default is yearly            
--    dbo.FNADateFormat(dbo.FNALastDayInDate(               
--      cast((year(sdh.term_start) +             
--      case when(ISNULL(rg1.gen_offset_technology,''n'') = ''n'') then             
--       COALESCE(td.duration, sp.duration, 0)                   
--      else             
--       COALESCE(td.offset_duration, sp.offset_duration, 0)            
--      end             
--      - 1) as varchar)             
--      + ''-'' + cast(isnull(sp.calendar_to_month, 12) as varchar) + ''-01''            
--     ))            
--            
--   end'            
            
            
SET @Sql_Select=            
'SELECT  
distinct sdh.source_deal_id,
ISNULL(pspcd.curve_name, ''-1'') AS ERROR,  -- this column is required to correct issues caused due to null pspcd.curve_name
ssbm.fas_book_id,        
 sdh.source_deal_header_id,             
 --sdh.deal_id,  
 sdh.structured_deal_id,               
 dbo.FNADateFormat(sdh.deal_date) deal_date,            
 sdh.term_start AS gen_date,        
 sdh.deal_volume,    
          
    case   when (sdh.buy_sell_flag = ''s'' and ''' + @Target_report + ''' in(''t'',''y'')) then -1
	when ((sdh.buy_sell_flag = ''s'' and (sdh.assignment_type_value_id is null ))  OR ssbm.fas_deal_type_value_id not in(400,406))  then -1 
	
	else 1 end * sdh.deal_volume * isnull(COALESCE(conv1.conversion_factor,conv5.conversion_factor,conv2.conversion_factor,conv3.conversion_factor,conv4.conversion_factor), 1) * isnull(df.decay_per, 1) AS Volume,            
 case when ''' + @Target_report + ''' = ''t'' then 0 else
 case when ssbm.fas_deal_type_value_id=400 then ISNULL(spbAll.bonus_per,0) * ISNULL(sdh.deal_volume,0)         
 else 0 end end*  case   when (sdh.buy_sell_flag = ''s'' and ''' + @Target_report + ''' in(''y'')) then -1 else 1 END AS bonus,            
 COALESCE(conv1.uom_label,conv5.uom_label,conv2.uom_label,conv3.uom_label,conv4.uom_label,suom_to.uom_name, suom.uom_name) as UOM,'            
            
SET @Sql_assignment='
  sdh.compliance_year,
 case  

 when ''' + @Target_report + ''' = ''n'' and sdh.buy_sell_flag = ''s'' and status_value_id = 5180 then ''Banked''		
  when ''' + @Target_report + ''' = ''t''and sdh.buy_sell_flag = ''s'' and status_value_id = 5180 then ''Adjustment - Sell''		
  when (sdh.buy_sell_flag = ''s'' and sdh.assignment_type_value_id is null) then ''Sell'' else  isnull(at.code, case when sdh.contract_expiration_date>convert(datetime, ''' + @as_of_date + ''', 102) then ''Forward'' else CASE WHEN ''' + @Target_report + '''=''n'' THEN ''Banked'' ELSE ''Buy'' END END)  end +               
  case 
 when td.not_expire=''y'' then ''''	
  when(isnull(at.value_id, 5149) = 5149 and             
 ( CASE WHEN (sdh.buy_sell_flag = ''s'' OR             
  (sdh.assignment_type_value_id IS NOT NULL AND             
  sdh.compliance_year IS NOT NULL) ) THEN            
  dbo.FNADateFormat(dbo.FNALastDayInDate(cast(ISNULL(sp.calendar_to_month,12) as varchar) + ''/01/'' +             
  case when (sdh.buy_sell_flag = ''s'') then cast(year(sdh.deal_date) as varchar) else cast(sdh.compliance_year as varchar) end            
  ))            
  ELSE'+            
  @sql_expiration_date+'                
  END) < convert(datetime, ''' + @as_of_date + ''', 102)) and ''' + @Target_report + ''' <> ''t'' 
		and rg1.generator_id is not null then '' - Expired''                         
          else ''''  end +               
  case when (isnull(at.value_id, 5149) = 5149 and ' + isnull('''' + @to_be_assigned_type_code + '''', 'null') + ' is not null)               
   then '' to '' + ''' + isnull(@to_be_assigned_type_code, '') + '''' + ' else '''' end  as Assignment,'               
            
 SET @Sql_assignment_target =' case when (ssbm.fas_deal_type_value_id = 406)  then ''Projected''      
  when (ssbm.fas_deal_type_value_id = 408)  then ''Emissions''  	       
  when (sdh.buy_sell_flag = ''s'' and sdh.assignment_type_value_id is null and ssbm.fas_deal_type_value_id = 400) then ''Sell''             
  else isnull(at.code, case when ''' + @Target_report + ''' = ''t'' then ''Buy''  else case when sdh.contract_expiration_date>convert(datetime, ''' + @as_of_date + ''', 102) then ''Forward'' else ''Banked'' end end) end Assignment,'            
             
SET  @sql_compliance='             
case when rg1.generator_id is null then '''' else CASE when ((at.code is null) and ssbm.fas_deal_type_value_id IN (400,405)) THEN            
  cast(year('+@sql_expiration_date+') as varchar)            
 ELSE            
  COALESCE(cast(sdh.compliance_year as varchar),CAST(YEAR(sdh.term_start) AS VARCHAR), '''')             
 END end compliance_year,'              
            
 SET @Sql_expiration=            
 'case when td.not_expire=''y'' then ''''	
	   when rg1.generator_id is null then '''' 
	   else isnull(gc3.contract_expiration_date, ISNULL(
--	   CASE WHEN ((sdh.buy_sell_flag = ''s'' and status_value_id<>5180) OR (sdh.assignment_type_value_id IS NOT NULL AND sdh.compliance_year IS NOT NULL) ) THEN
--	   dbo.FNADateFormat(dbo.FNALastDayInDate(cast(ISNULL(sp.calendar_to_month,12) as varchar) + ''/01/'' +             
--	   case when (sdh.buy_sell_flag = ''s'' and status_value_id<>5180) then cast(year(sdh.deal_date) as varchar) else cast(sdh.compliance_year as varchar) end  ))            
--  ELSE '+            
 + @sql_expiration_date+              
  '  , sdh.contract_expiration_date)) end as expiration_date,'            
            
If @Target_report='y'            
 set @Sql_Select=@Sql_Select+@Sql_assignment_target+@Sql_compliance+@Sql_expiration            
else            
 set @Sql_Select=@Sql_Select+@Sql_assignment+@Sql_expiration            
 
-- select   state_value_id,assignment_type_value_id,curve_id,conversion_factor,from_source_uom_id,to_source_uom_id
-- from #conversion where assignment_type_value_id=5149 and curve_id=96 and state_value_id is null

SET @Sql_Select=@Sql_Select+             
 CASE  
     WHEN (@summary_option = 'e' OR @summary_option = 'x') THEN '''' + isnull(cast(@jurisdiction AS VARCHAR(20)), '') + ''' assigned_state,' 
     ELSE 'isnull(state.code, '''') assigned_state,'
 END
 + '            
 state.value_id State,            
 COALESCE(spcd.curve_name,Conv1.curve_label,Conv5.curve_label,Conv2.curve_label,Conv3.curve_label,Conv4.curve_label, ISNULL(pspcd.curve_name, ''-1'')) as curve_name,            
 sdh.gis_cert_number,            
 sdh.generator_id,            	
 rg1.name Generator,            
 tech.code Technology,            
 isnull(sdh.assignment_type_value_id, 5149) assignment_type_value_id,            
 sdh.buy_sell_flag,            
 sdh.assigned_date,            
 st.trader_id,            
 st.trader_name,            
 sdh.fixed_price,            
 sdh.counterparty_id,            
 sc.counterparty_name,            
 sdt.source_deal_type_name,            
 sdh.deal_detail_description he,        
 case  when (ssbm.fas_deal_type_value_id = 406) then ''Projected''             
  when (ssbm.fas_deal_type_value_id = 405) then ''Target''
  when (ssbm.fas_deal_type_value_id = 408) then ''Inventory''               
 else ''Actual'' end target_actual,      
 sdh.term_start term_start,
 sdh.ext_deal_id,
 ssbm.fas_deal_type_value_id,
 sdh.total_volume,
 sdh.option_flag,
 sdh.option_type,
 sdh.option_excercise_type,
 sdh.strike_price,
 cur.currency_name,
 sdh.leg,
 sdh.term_end ,
 sdh.status_value_id,
 --sd_tier.code [tier_type], 
  CASE 
      WHEN sdh.assignment_type_value_id = 5146 THEN sdv6.code       
      ELSE COALESCE((SELECT distinct sdv3.code),(SELECT distinct sdv4.code),(SELECT distinct sdv5.code))
  END as tier_type,
  gen_state.code [Gen State]	,
 COALESCE(conv1.conversion_factor,conv5.conversion_factor,conv2.conversion_factor,conv3.conversion_factor,conv4.conversion_factor,1)  conversion_factor,  
 sc.is_jurisdiction [isJurisdiction],
 sdh.source_curve_def_id,
 sdh.deal_volume_frequency,
 sdh.multiplier,
 gc3.gis_certificate_number_from [certificate_from],
 gc3.gis_certificate_number_to [certificate_to]	
FROM            
(            
 '

SET @Sql_Select1='                        
 select sdh.source_deal_header_id structured_deal_id,        
	 max(sdd.source_deal_detail_id) source_deal_header_id,
	 max(sdh.source_deal_header_id) source_deal_id,             
	 max(sdd.buy_sell_flag) buy_sell_flag,             
	 max(sdh.trader_id) trader_id, max(sdh.counterparty_id) counterparty_id,            
	 max(sdh.source_deal_type_id) source_deal_type_id,            
	 max(sdh.deal_date) deal_date,             
	 max(sdh.generator_id) generator_id, sdh.assignment_type_value_id, sdh.status_value_id,              
	 sdh.assigned_date, sdh.compliance_year, rg.source_curve_def_id,  sdd.term_start,                        
	 max(sdd.deal_detail_description) deal_detail_description, max(sdd.fixed_price) fixed_price,            
	 sum(case when  (''' + @Target_report + ''' in(''t'',''y'')) then sdd.deal_volume
			  when sdd.buy_sell_flag=''s'' and sdh.assignment_type_value_id is not null then sdd.deal_volume      
			  else sdd.volume_left end ) deal_volume , NULL gis_cert_number, max(sdh.state_value_id) state_value_id,            
	 NULL gis_value_id , max(sdd.deal_volume_uom_id) as deal_volume_uom_id,            
	 max(sdh.source_system_book_id1) source_system_book_id1,            
	 max(sdh.source_system_book_id2) source_system_book_id2,   
	 max(sdh.source_system_book_id3) source_system_book_id3,   
	 max(sdh.source_system_book_id4) source_system_book_id4,            
	 max(sdd.contract_expiration_date) contract_expiration_date,
	 max(sdh.ext_deal_id) ext_deal_id,
	 max(sdd.deal_volume) total_volume,      
	 max(sdh.option_flag) option_flag,
	 max(sdh.option_type) option_type,
	 max(sdh.option_excercise_type) option_excercise_type,
	 max(sdd.option_strike_price) strike_price,       
	 max(fixed_price_currency_id) as currency_id,
	 max(sdd.leg) leg,       
	 max(sdd.term_end) term_end ,
	 max(sdd.deal_volume_frequency) as deal_volume_frequency,
	 max(sdd.multiplier) as multiplier
  from                
 source_deal_header sdh 
 INNER JOIN source_deal_detail sdd on sdd.source_deal_header_id = sdh.source_deal_header_id 
 INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id   '
 
IF (@report_type IS NOT NULL OR @assigned_state IS NOT NULL) AND @summary_option IN ('x', 'e')
BEGIN
	SET @Sql_Select1 = @Sql_Select1 + ' LEFT JOIN assignment_audit aa ON aa.source_deal_header_id = sdd.source_deal_detail_id' 	 	
END 

IF (@to_be_assigned_type IS NOT NULL OR @to_be_assign_state IS NOT NULL) AND @summary_option IN ('x', 'e')
BEGIN
	SET @Sql_Select1 = @Sql_Select1 + ' LEFT JOIN assignment_audit aau ON aau.source_deal_header_id = sdd.source_deal_detail_id '
END

SET @Sql_Select1 = @Sql_Select1 + ' WHERE 1=1 '

IF (@to_be_assigned_type IS NOT NULL OR @to_be_assign_state IS NOT NULL) AND @summary_option IN ('x', 'e')
BEGIN
	SET @Sql_Select1 = @Sql_Select1 + ' AND sdh.assignment_type_value_id IS NULL '
END

SET @Sql_Select1=@Sql_Select1+'  
	and (case when ((''' + @Target_report + ''' in(''t'',''y'')) OR (sdd.buy_sell_flag=''s'' and sdh.assignment_type_value_id is not null)) then sdd.deal_volume      
 else sdd.volume_left end) <> 0'     
 
IF ((@assigned_state IS NOT NULL  OR  @to_be_assign_state IS NOT NULL) AND (@summary_option != 'x' AND @summary_option != 'e' AND @summary_option != 'd')) 
BEGIN 
	SET @Sql_Select1 = @Sql_Select1 + ' AND isnull(sdh.state_value_id, rg.state_value_id) = ' + cast(@assigned_state_jurisdiction AS VARCHAR(50))	
END 
--ELSE IF (@to_be_assign_state IS NOT NULL AND (@summary_option != 'x' AND @summary_option != 'e' AND @summary_option != 'd'))
--BEGIN
--	SET @Sql_Select1 = @Sql_Select1 + ' AND rg.state_value_id = ' + cast(@assigned_state_jurisdiction AS VARCHAR(50))
--END

IF (@summary_option = 'x' OR @summary_option = 'e' OR @is_from_tier_and_expiration = 'y')
BEGIN
	SET @Sql_Select1 = @Sql_Select1 + '	AND isnull(sdh.state_value_id ,-1 )= cASE 
						WHEN sdh.assignment_type_value_id IS NOT NULL  THEN ' +
            			isnull(cast(@assigned_state_jurisdiction AS VARCHAR(50)), '') + '
            			ELSE isnull(sdh.state_value_id ,-1 )
						END '
END

--- Added to not show Sell transactions in target Report
--+' AND (''' + @Target_report + ''' <> ''y'' OR(''' + @Target_report + ''' = ''y'' AND ((sdd.buy_sell_flag=''s'' and (sdh.assignment_type_value_id is not null AND sdh.assignment_type_value_id<>5173)) OR sdd.buy_sell_flag=''b'')))'	       
        
 SET @Sql_Where = ''            
-- IF @gis_cert_number IS NOT NULL AND @gis_cert_number = 'NA'              
-- BEGIN              
--  set @gis_cert_number = NULL --allow other filters to work              
--  SET @sql_Select = @sql_Select + ' AND sdh.gis_cert_number IS NULL '               
-- END              
IF (@drill_Assignment = 'Sell')
BEGIN
	SET @sql_Select1 = @sql_Select1 + ' AND sdh.header_buy_sell_flag = ''s'''
END              

IF (@drill_Assignment = 'buy')
BEGIN
	SET @sql_Select1 = @sql_Select1 + ' AND sdh.header_buy_sell_flag = ''b'''
END 
              
IF (@deal_id_from IS NOT NULL)              
BEGIN              
              
IF (@deal_id_from IS NOT NULL)               
 SET @sql_Select1 = @sql_Select1 + ' AND sdh.source_deal_header_id BETWEEN ' + CAST(@deal_id_from As varchar)  + ' AND ' + CAST(@deal_id_to AS varchar)               
              
              
END              
ELSE              
BEGIN              
 SET @sql_Select1 = @sql_Select1 + '               
      AND(sdh.status_value_id IS NULL or sdh.status_value_id not in(5170, 5179))              
    '               
              
              
--only for activity report            
 IF @deal_date_from IS NOT NULL              
  set @sql_Select1 = @sql_Select1 + ' AND (sdh.deal_date between CONVERT(DATETIME, ''' + @deal_date_from  + ' ' + CONVERT(VARCHAR(8),GETDATE(),108) + ''', 102) AND              
     CONVERT(DATETIME, ''' + @deal_date_to  + ' ' + CONVERT(VARCHAR(8),GETDATE(),108) + ''', 102)) '              
              
 IF @gen_date_from IS NOT NULL              
  set @sql_Select1 = @sql_Select1 + ' AND (sdd.term_start between CONVERT(DATETIME, ''' + @gen_date_from + ''', 102) AND              
     CONVERT(DATETIME, ''' + @gen_date_to + ''', 102)) '              
              
 IF @buy_sell_flag IS NOT NULL              
  --set @sql_Select1 = @sql_Select1 + ' AND (sdh.assignment_type_value_id is null and sdd.buy_sell_flag = ''' + @buy_sell_flag + ''')'              
  set @sql_Select1 = @sql_Select1 + ' AND (sdd.buy_sell_flag = ''' + @buy_sell_flag + ''')'                          
           
 IF @counterparty_id IS NOT NULL              
  SET @sql_Select1 = @sql_Select1 + ' AND sdh.counterparty_id = ' + CAST(@counterparty_id as varchar)               
            
 IF @deal_type IS NOT NULL              
  SET @Sql_Where = @Sql_Where + ' AND sdh.source_deal_type_id = ' + CAST(@deal_type as varchar)               
         
IF @deal_sub_type IS NOT NULL              
  SET @Sql_Where = @Sql_Where + ' AND sdh.deal_sub_type_type_id = ' + CAST(@deal_sub_type as varchar)               
            
-----------------------------------            
            
IF @generator_id IS NOT NULL              
  SET @Sql_Where = @Sql_Where + ' AND sdh.generator_id = ' + CAST(@generator_id as varchar)               
              
 IF @curve_id IS NOT NULL              
  SET @Sql_Where = @Sql_Where + ' AND sdd.rg.source_curve_def_id = ' + cast(@curve_id as varchar)                            
            


IF @report_type IS NOT NULL  and @Target_report IN ('n', 't')
   SET @Sql_Where = @Sql_Where + ' AND isnull(sdh.assignment_type_value_id, 5149) = ' + CAST(@report_type as varchar)               
--  SET @Sql_Where = @Sql_Where + ' AND case when(buy_sell_flag = ''s'') then -1 else isnull(sdh.assignment_type_value_id, 5149) end = ' + CAST(@report_type as varchar)               
          
 
--############### New added for position report
-- For Position report only show buy and sell, no assignments
IF @Target_report='n'
	 SET @Sql_Where = @Sql_Where + ' AND(sdh.assignment_type_value_id IS NULL)'

END     

set @sql_select1 =@sql_select1+@sql_where            

set @sql_select3=
' group by sdh.source_deal_header_id, sdd.source_deal_detail_id, sdh.assignment_type_value_id,             
   sdh.status_value_id, sdh.assigned_date, sdh.compliance_year, rg.source_curve_def_id, sdd.term_start                    
)sdh            
'            


            
set @sql_select2 =            
'            
INNER JOIN #ssbm ssbm            
ON sdh.source_system_book_id1=ssbm.source_system_book_id1             
AND sdh.source_system_book_id2=ssbm.source_system_book_id2             
AND sdh.source_system_book_id3=ssbm.source_system_book_id3             
AND sdh.source_system_book_id4=ssbm.source_system_book_id4             
LEFT OUTER JOIN               
source_price_curve_def spcd ON sdh.source_curve_def_id = spcd.source_curve_def_id  
LEFT OUTER JOIN source_price_curve_def pspcd ON ISNULL(spcd.proxy_source_curve_def_id ,-1)= ISNULL(pspcd.source_curve_def_id,-1)                    
LEFT outer join rec_generator rg1 on rg1.generator_id = sdh.generator_id 
LEFT outer join static_data_value at on at.value_id = sdh.assignment_type_value_id   
LEFT OUTER join state_properties sp on sp.state_value_id = rg1.state_value_id
LEFT OUTER join static_data_value state on state.value_id = ISNULL(sdh.state_value_id,rg1.state_value_id)
LEFT OUTER JOIN static_data_value gen_state ON gen_state.value_id=rg1.gen_state_value_id
LEFT OUTER join static_data_value tech on tech.value_id = rg1.technology
LEFT OUTER join source_traders st on st.source_trader_id = sdh.trader_id               
LEFT OUTER join source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id               
LEFT OUTER join source_deal_type sdt on sdt.source_deal_type_id = sdh.source_deal_type_id            
LEFT OUTER JOIN source_uom suom on suom.source_uom_id = sdh.deal_volume_uom_id
            

LEFT OUTER JOIN rec_volume_unit_conversion Conv1 ON            
 conv1.from_source_uom_id  = sdh.deal_volume_uom_id             
 AND conv1.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'            
 And conv1.state_value_id = COALESCE(sp.state_value_id,sdh.state_value_id)
 AND conv1.assignment_type_value_id = isnull(at.value_id, 5149)
 AND conv1.curve_id = sdh.source_curve_def_id                          
 AND conv1.to_curve_id IS NULL	

LEFT OUTER JOIN rec_volume_unit_conversion Conv2 ON            
 conv2.from_source_uom_id = sdh.deal_volume_uom_id             
 AND conv2.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'            
 And conv2.state_value_id IS NULL
 AND conv2.assignment_type_value_id = isnull(at.value_id, 5149)
 AND conv2.curve_id = sdh.source_curve_def_id    
 AND conv2.to_curve_id IS NULL

LEFT OUTER JOIN rec_volume_unit_conversion Conv3 ON            
conv3.from_source_uom_id =  sdh.deal_volume_uom_id             
 AND conv3.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'            
 And conv3.state_value_id IS NULL
 AND conv3.assignment_type_value_id IS NULL
 AND conv3.curve_id = sdh.source_curve_def_id  
 AND conv3.to_curve_id IS NULL
      
LEFT OUTER JOIN rec_volume_unit_conversion Conv4 ON            
 conv4.from_source_uom_id = sdh.deal_volume_uom_id
 AND conv4.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'            
 And conv4.state_value_id IS NULL
 AND conv4.assignment_type_value_id IS NULL
 AND conv4.curve_id IS NULL
 AND conv4.to_curve_id IS NULL

LEFT OUTER JOIN rec_volume_unit_conversion Conv5 ON            
 conv5.from_source_uom_id  = sdh.deal_volume_uom_id             
 AND conv5.to_source_uom_id = '+ISNULL(CAST(@convert_uom_id as varchar),'NULL')+'            
 And conv5.state_value_id = COALESCE(sp.state_value_id,sdh.state_value_id)
 AND conv5.assignment_type_value_id is null
 AND conv5.curve_id = sdh.source_curve_def_id  
 AND conv5.to_curve_id IS NULL
 
LEFT JOIN source_uom suom_to ON suom_to.source_uom_id=COALESCE(Conv1.to_source_uom_id,Conv5.to_source_uom_id,Conv2.to_source_uom_id,Conv3.to_source_uom_id,Conv4.to_source_uom_id)

LEFT OUTER JOIN #bonus spbAll ON            
 spbAll.state_value_id = sp.state_value_id and             
 spbAll.technology = rg1.technology and 
spbAll.assignment_type_value_id = isnull('+ISNULL(cast(@to_be_assigned_type as varchar),'NULL')+', at.value_id) AND
           
--   ( (sdh.buy_sell_flag = ''s'' AND spbAll.assignment_type_value_id = 5173) OR            
--  ('+ISNULL(cast(@to_be_assigned_type as varchar),'NULL')+' IS NOT NULL AND spbAll.assignment_type_value_id ='+ISNULL(cast(@to_be_assigned_type as varchar),'NULL')+') OR            
--  ('+ISNULL(cast(@to_be_assigned_type as varchar),'NULL')+' IS NULL AND spbAll.assignment_type_value_id = at.value_id) OR            
--  (spbAll.assignment_type_value_id = 5149)            
--  )AND            
 sdh.term_start between spbAll.from_date and spbAll.to_date and            
 spbAll.gen_code_value = rg1.gen_state_value_id    
 AND (spbAll.curve_id IS NULL OR spbAll.curve_id=sdh.source_curve_def_id)              
 left outer join            
   #temp_duration td             
  on td.state_value_id = sp.state_value_id and            
  (td.technology is null or td.technology = rg1.technology) and            
  td.assignment_type_value_id = coalesce('+ISNULL(cast(@to_be_assigned_type as varchar),'NULL')+' ,'+ISNULL(cast(@report_type as varchar),'NULL')+', 5149) and            
  td.gen_code_value = rg1.gen_state_value_id         
  and (td.curve_id IS NULL OR td.curve_id=sdh.source_curve_def_id)
 	    
 left outer join decaying_factor df on df.state_value_id=sp.state_value_id
 AND (df.technology=rg1.technology OR df.technology IS NULL)
 AND (df.assignment_type_value_id=ISNULL(sdh.assignment_type_value_id,5149) OR df.assignment_type_value_id IS NULL)	
 AND (df.gen_code_value=rg1.gen_state_value_id OR df.gen_code_value IS NULL)
 AND df.curve_id = sdh.source_curve_def_id and df.year = year(''' + @as_of_date + ''')                
 and df.gen_year=year(sdh.term_start)    
 left outer join gis_certificate gc on    
 gc.source_deal_header_id=sdh.source_deal_header_id
 AND gc.state_value_id = sdh.state_value_id        
 left outer join source_currency cur on cur.source_currency_id=sdh.currency_id
 --Left outer join rec_generator_assignment rga on rg1.generator_id=rga.generator_id
 --and ((sdh.term_start between rga.term_start and rga.term_end) OR (sdh.term_end between rga.term_start and rga.term_end))	
 --LEFT OUTER JOIN static_data_value sd_tier ON sd_tier.value_id=rg1.tier_type
LEFT JOIN gis_Certificate gc3 ON gc3.source_deal_header_id =  sdh.source_deal_header_id ' + 
CASE WHEN (@is_from_tier_and_expiration = 'y' OR @summary_option = 'e' OR @summary_option = 'x') 
	THEN ' AND (gc3.state_value_id = ' + ISNULL(cast(@assigned_state_jurisdiction AS VARCHAR(20)), '''''')  + ' OR gc3.state_value_id IS NULL) ' 
ELSE '' END 
+ ' LEFT JOIN (select * from static_data_value WHERE [type_id] = 15000) sdv3 ON  sdv3.value_id = gc3.tier_type
LEFT join rec_generator rg4 ON rg4.generator_id = sdh.generator_id
LEFT JOIN (select * from static_data_value WHERE [type_id] = 15000) sdv4 ON sdv4.value_id = rg4.tier_type 
LEFT JOIN source_deal_detail sdd5 ON sdd5.source_deal_header_id = sdh.structured_deal_id
LEFT JOIN rec_generator rg5 ON rg5.generator_id = sdh.generator_id
LEFT JOIN rec_gen_eligibility rge5 ON rge5.state_value_id = ' + ISNULL(cast(@assigned_state_jurisdiction AS VARCHAR(20)), '''''') + ' 
AND YEAR(sdd5.term_start) BETWEEN  ISNULL(rge5.from_year, ''1900'') AND isnull(rge5.to_year, ''9999'')
--AND sdd5.term_start >= CASE 
--					WHEN rge5.from_year IS NULL THEN NULL
--					WHEN rge5.to_year IS NULL THEN rge5.from_year
--					ELSE rge5.from_year
--					END
--AND  sdd5.term_start <= CASE 
--					WHEN rge5.from_year is null THEN  rge5.to_year
--					WHEN  rge5.to_year is null THEN NULL
--					ELSE  rge5.to_year 
--					END 
AND rg5.technology = ISNULL(rge5.technology, rg5.technology) 
AND rg5.classification_value_id = ISNULL(rge5.technology_sub_type, rg5.classification_value_id) 
AND rg5.gen_state_value_id = ISNULL(rge5.gen_state_value_id, rg5.gen_state_value_id)

LEFT JOIN  (select * from static_data_value WHERE [type_id] = 15000) sdv5 ON sdv5.value_id = rge5.tier_type

left join assignment_audit asau on asau.source_deal_header_id = sdh.source_deal_header_id
LEFT JOIN  (select * from static_data_value WHERE [type_id] = 15000) sdv6 ON sdv6.value_id = asau.tier
' +
CASE
WHEN @report_type IS NOT NULL THEN ' AND rge5.assignment_type = '+ isnull(cast(@report_type AS VARCHAR(20)), '''''') 
else ''
END
+
'
WHERE 1=1 '+

case when @include_inventory='n' and isnull(@assignment_type,5149)=5149 then 
' AND (ISNULL(NULL,rg1.exclude_inventory) is null or ISNULL(NULL,rg1.exclude_inventory)=''n'') ' 
when @include_inventory='n' and isnull(@assignment_type,5149)<>5149 then
''
else 
' AND (ISNULL(NULL,rg1.exclude_inventory)=''y'') ' end          
+ case  when @Target_report='y' and @program_type='a' THEN       
		' AND (( ssbm.fas_deal_type_value_id in('+@deal_type_id+') AND  sdh.deal_date  <= CONVERT(DATETIME, ''' + @as_of_date+ ' ' + CONVERT(VARCHAR(8),GETDATE(),108) + ''', 102)) OR (ssbm.fas_deal_type_value_id in(406) AND  YEAR(sdh.term_start)  >= YEAR(CONVERT(DATETIME, ''' + @as_of_date + ' ' + CONVERT(VARCHAR(8),GETDATE(),108) + ''', 102) OR (ssbm.fas_deal_type_value_id in(408) AND  YEAR(sdh.term_start)>= YEAR(CONVERT(DATETIME, ''' + @as_of_date + ' ' + CONVERT(VARCHAR(8),GETDATE(),108) + ''', 102)))) OR ssbm.fas_deal_type_value_id  IN (405))'              
		when @Target_report='y'   and @program_type='b' THEN        
		' AND (( ssbm.fas_deal_type_value_id in('+@deal_type_id+') AND  sdh.deal_date  <= CONVERT(DATETIME, ''' + @as_of_date+ + ' ' + CONVERT(VARCHAR(8),GETDATE(),108) + ''', 102)) 
			OR (ssbm.fas_deal_type_value_id in(405)) -- target
			OR (ssbm.fas_deal_type_value_id in(406) AND  YEAR(sdh.term_start)  >= YEAR(CONVERT(DATETIME, ''' + @as_of_date + ' ' + CONVERT(VARCHAR(8),GETDATE(),108) + ''', 102))) OR (ssbm.fas_deal_type_value_id in(408) AND  YEAR(sdh.term_start)>= YEAR(CONVERT(DATETIME, ''' + @as_of_date + ' ' + CONVERT(VARCHAR(8),GETDATE(),108) + ''', 102))))'              
		else        
		' AND sdh.deal_date  <= CONVERT(DATETIME, ''' + @as_of_date + ' ' + CONVERT(VARCHAR(8),GETDATE(),108) + ''', 102) and ssbm.fas_deal_type_value_id in('+@deal_type_id+') '        
	end            
        
-- if @assignment_type is not NULL
--	SET @sql_select2 = @sql_select2+' AND sdh.assignment_type_value_id= ' + cast(@assignment_type as varchar) 
 
 
 IF @assigned_state IS NOT NULL              
  SET @sql_select2 = @sql_select2 --+' AND (state.value_id IN(' + cast(@assigned_state as varchar)+ ')) '              

  IF @generation_state IS NOT NULL              
   SET @sql_select2 = @sql_select2+' AND (rg1.gen_state_value_id IN(' + cast(@generation_state as varchar)+ ')) '              

 IF @gis_id IS NOT NULL              
   SET @sql_Select2 = @sql_Select2 + ' AND rg1.gis_value_id = ' + CAST(@gis_id as varchar)               
           
            
set @Sql_Where=''            
 IF @technology IS NOT NULL              
  SET @Sql_Where =  ' AND rg1.technology = ' + cast(@technology as varchar)              
    
 --IF (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) 
 --  SET @Sql_Where = @sql_where + 'AND (gc.certificate_number_from_int >= '+CAST(@gis_cert_number  AS VARCHAR)+' AND gc.certificate_number_to_int <= '+CAST(@gis_cert_number_to  AS VARCHAR)+')'
   
SET @Sql_Where = @sql_where + CASE WHEN (@gis_cert_number IS NOT NULL) THEN ' AND gc3.certificate_number_from_int>=' + CAST(@gis_cert_number  AS VARCHAR) + '' ELSE '' END 
SET @Sql_Where = @sql_where + CASE WHEN (@gis_cert_number_to IS NOT NULL) THEN ' AND gc3.certificate_number_to_int<=' + CAST(@gis_cert_number_to  AS VARCHAR) + '' ELSE '' END
 
    
 -- SET @Sql_Where = @Sql_Where +' AND ( '+ @gis_cert_number + ' BETWEEN gc.certificate_number_from_int AND gc.certificate_number_to_int  
	--OR '+ @gis_cert_number_to + ' BETWEEN  gc.certificate_number_from_int AND gc.certificate_number_to_int)'    

	     
------------ for target report            
 IF @include_forecast = 'n'           
  SET @Sql_Where = @Sql_Where + ' AND ssbm.fas_deal_type_value_id IN (400,405) '            
            

--	IF @report_type IS NOT NULL   and @Target_report='y'         
--		begin   
--			
--		  SET @Sql_Where = @Sql_Where + ' AND ((case when (buy_sell_flag = ''s'' and  ssbm.fas_deal_type_value_id IN (400, 405) )             
--		   then -1 else isnull(sdh.assignment_type_value_id, 5149) end = 5149 ' +            
--		' AND ''' + isnull(@included_banked, 'n') + ''' = ''y'') OR ' +            
--		   ' (case when (buy_sell_flag = ''s'' and sdh.assignment_type_value_id is null and ssbm.fas_deal_type_value_id = 400)             
--		   then -1 else isnull(sdh.assignment_type_value_id, 5149) end = ' + cast(@report_type as varchar) + '))'            
--		end             
		
		if @Target_report='y'  
		  SET  @Sql_Where = @Sql_Where +         
			' AND ((''' + isnull(@included_banked, 'n') + ''' = ''y'') OR (''' + isnull(@included_banked, 'n') + ''' = ''n'' 
			  AND isnull(sdh.assignment_type_value_id, 5149)  <> 5149)) 
			 '
	
SET @Sql_Where=  @Sql_Where+ CASE WHEN @udf_group1 IS NOT NULL THEN ' AND rg1.udf_group1='+CAST(@udf_group1 AS VARCHAR) ELSE '' END
			 + CASE WHEN @udf_group2 IS NOT NULL THEN ' AND rg1.udf_group2='+CAST(@udf_group2 AS VARCHAR) ELSE '' END
			 + CASE WHEN @udf_group3 IS NOT NULL THEN ' AND rg1.udf_group3='+CAST(@udf_group3 AS VARCHAR) ELSE '' END
			 + CASE WHEN @tier_type IS NOT NULL THEN ' AND rg1.tier_type='+CAST(@tier_type AS VARCHAR) ELSE '' END 

---- select the programscope
IF @program_scope is not null 
	SET @Sql_Where = @Sql_Where + ' AND spcd.program_scope_value_id in('+@program_scope+')' 

IF @expiration_from IS NOT NULL
	SET @Sql_Where=@Sql_Where +' AND ('+@sql_expiration_date+' BETWEEN CONVERT(DATETIME, ''' + @expiration_from + ''', 102) AND CONVERT(DATETIME, ''' + @expiration_to + ''', 102))'

SET @sql_select2=@sql_select2+@Sql_Where            
            

--########## populate temp table to generatr certificate number
-- only for drill down
--if @summary_option = 'd' 
--BEGIN
-- 	create table #temp_assign(assignment_id int identity,
-- 		source_deal_header_id int,
-- 		source_deal_header_id_from int,
-- 		assigned_volume float
-- 	)

-- 	
-- 	EXEC('
-- 	insert into #temp_assign
-- 	select au.source_deal_header_id,source_deal_header_id_from,assigned_volume
-- 		from ('+
-- 	@sql_select+@sql_select1+@sql_select3+@sql_select2
-- 	+') sdh
-- 	inner join
-- 	assignment_audit au on au.source_deal_header_id=sdh.source_deal_header_id
-- 	
-- 	')
-- 	
-- 	EXEC('
-- 	insert into #temp_assign
-- 	select gis.source_deal_header_id,gis.source_deal_header_id,-1
-- 		from ('+
-- 	@sql_select+@sql_select1+@sql_select3+@sql_select2
-- 	+') sdh
-- 	inner join
-- 	gis_certificate gis on gis.source_deal_header_id=sdh.source_deal_header_id
-- 	')
--END

select assignment_id,source_deal_header_id,source_deal_header_id_from,assigned_volume,cert_from,cert_to
into #temp_assign from assignment_audit where assigned_volume > 0

insert into #temp_assign(source_deal_header_id,source_deal_header_id_from ,assigned_volume,cert_from,cert_to)
select source_deal_header_id,source_deal_header_id,-1,certificate_number_from_int,certificate_number_to_int from gis_certificate
WHERE source_deal_header_id not IN(select source_deal_header_id FROM #temp_assign)
--**********************************

IF @Target_report='n' or @target_report='t'            
	BEGIN            

	            
	if @summary_option = 's' --Grouping by Technology, Assignment, State, Renewable Obligation              
	BEGIN             
	SET @Sql_SelectS=            
	 ' select  
	   Technology,               
	   -- dbo.FNAHyperLinkText(14100100, assigned_state, cast(State as varchar)) Jurisdiction,
	 -- dbo.FNATRMWinHyperlink(''i'',14100100, assigned_state, cast(State as varchar),DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT,DEFAULT,DEFAULT) Jurisdiction,
	 
	 ''<span style="cursor: pointer;" onclick="parent.parent.parent.TRMWinHyperlink(14100100,''+cast(State as varchar)+'')"><font color="#0000ff"><u>''+assigned_state+''</u></font></span>'' Jurisdiction,
	                
	    --assigned_state State,              
	   Assignment,               
	   curve_name [Env Product],'               
	   
	if @target_report!='t' 
		SET @Sql_SelectS=@Sql_SelectS+  ' dbo.FNADateFormat(expiration_date) Expiration, '
	 else
 		SET @Sql_SelectS=@Sql_SelectS+  ' dbo.FNADateFormat(sdh.deal_date) [Deal Date],' 	         
	 

	SET @Sql_SelectS=@Sql_SelectS+ '  sum(Volume * ISNULL(sdh.multiplier, 1)) Volume, '

	if @target_report!='t' 
		SET @Sql_SelectS=@Sql_SelectS+' ROUND(sum(bonus),' +@round_value + ') Bonus,ROUND(sum((Volume * ISNULL(sdh.multiplier, 1))+ bonus),' +@round_value + ') [Total Volume], '
	-- else 
	-- 	SET @Sql_SelectS=@Sql_SelectS+' sum(bonus) Bonus, '
		
	SET @Sql_SelectS=@Sql_SelectS+'UOM '            
	
	SET @Sql_SelectS = @Sql_SelectS + 'into #temp_select '  
	
	SET @Sql_SelectD='            
	)sdh where  isnull('+ISNULL(CAST(@compliance_year as varchar),'NULL')+', 1) = case when ('+ISNULL(CAST(@compliance_year as varchar),'NULL')+' is null) then 1 else              
		   sdh.compliance_year end '            

	IF @status_id IS NOT NULL            
	 SET  @Sql_SelectD=@Sql_SelectD+' AND '''+CAST(@status_id AS VARCHAR)+'''=            
			case when(assignment_type_value_id = 5149 and expiration_date < convert(datetime,'''+@as_of_date+''', 102)) then ''e''              
	 when(assignment_type_value_id NOT IN (5149) and assigned_date <= convert(datetime,'''+@as_of_date+''', 102)) then ''s''              
				 else ''a''               
			end '                 
	if @target_report!='t'                        
		SET  @Sql_SelectD=@Sql_SelectD+' group by Technology, assigned_state, State, Assignment, assignment_type_value_id, curve_name,  expiration_date, UOM              
		 order by Technology,  expiration_date, Assignment, assigned_state'            
	else
		SET  @Sql_SelectD=@Sql_SelectD+' group by Technology, assigned_state, State, Assignment, assignment_type_value_id, curve_name,  sdh.deal_date, UOM              
		 order by Technology, sdh.deal_date, Assignment, assigned_state'            

	END              
	            
	if @summary_option = 'g'  --Grouping by Generator, Technology, Assignment, State, Renewable Obligation              
	BEGIN              

	 --Get Eligibility concatenated by ','              
	             
	SET @Sql_SelectS='   
	 select  	
	  ''<span style="cursor: pointer;" onclick="parent.parent.parent.TRMWinHyperlink(12101700,''+cast(sdh.generator_id as varchar)+'')"><font color="#0000ff"><u>''+Generator+''</u></font></span>''  [Generator/Credit Source],  	                            
	  --Generator,               
	  Technology,               
	  Assignment,                 
	  ''<span style="cursor: pointer;" onclick="parent.parent.parent.TRMWinHyperlink(14100100,''+cast(State as varchar)+'')"><font color="#0000ff"><u>''+assigned_state+''</u></font></span>'' Jurisdiction,             
	  curve_name [Env Product],'               

	if @target_report!='t' 
		SET @Sql_SelectS=@Sql_SelectS+  ' dbo.FNADateFormat(expiration_date) Expiration, '
	else
 		SET @Sql_SelectS=@Sql_SelectS+  ' dbo.FNADateFormat(sdh.deal_date) [Deal Date],' 	         

		SET @Sql_SelectS=@Sql_SelectS+' round(sum(Volume),' +@round_value + ') Volume,'

	if @target_report!='t' 
		SET @Sql_SelectS=@Sql_SelectS+' ROUND(sum(bonus),' +@round_value + ') Bonus,'

	SET @Sql_SelectS=@Sql_SelectS+' round(sum(Volume + bonus),' +@round_value + ') [Total Volume],              
	  UOM into #temp_select '            
	            
	           
	SET @Sql_SelectD=')sdh             
	 where  isnull('+ISNULL(CAST(@compliance_year as varchar),'NULL')+', 1) = case when ('+ISNULL(CAST(@compliance_year as varchar),'NULL')+' is null) then 1 else              
		  sdh.compliance_year end '             
	IF @status_id IS NOT NULL            
	 SET  @Sql_SelectD=@Sql_SelectD+' AND '''+CAST(@status_id AS VARCHAR)+'''=            
			case when(assignment_type_value_id = 5149 and expiration_date < convert(datetime,'''+@as_of_date+''', 102)) then ''e''              
				  when(assignment_type_value_id NOT IN (5149) and assigned_date <= convert(datetime,'''+ @as_of_date+''', 102)) then ''s''              
				 else ''a''               
			end '            
	            
	if @target_report!='t'                        
		SET  @Sql_SelectD=@Sql_SelectD+' group by Generator, sdh.generator_id, Technology, Assignment, assigned_state, State,  curve_name, expiration_date, UOM              
		 order by Generator, Technology, Assignment, State, expiration_date '   
	else
		SET  @Sql_SelectD=@Sql_SelectD+' group by Generator, sdh.generator_id, Technology, Assignment, assigned_state, State,  curve_name, deal_date, UOM              
		 order by Generator, Technology, Assignment, State, deal_date '   

	              
	END              

	if @summary_option = 'y'  --Generator BY Year
	BEGIN              
	        
	SET @Sql_SelectS='              
	 select  
	 ''<span style="cursor: pointer;" onclick="parent.parent.parent.TRMWinHyperlink(12101700,''+cast(sdh.generator_id as varchar)+'')"><font color="#0000ff"><u>''+Generator+''</u></font></span>''  [Generator/Credit Source],               
	  Technology,               
	  Assignment,               
	    ''<span style="cursor: pointer;" onclick="parent.parent.parent.TRMWinHyperlink(14100100,''+cast(State as varchar)+'')"><font color="#0000ff"><u>''+assigned_state+''</u></font></span>'' Jurisdiction,             
	  curve_name [Env Product],'               

	if @target_report!='t' 
		SET @Sql_SelectS=@Sql_SelectS+  ' year(sdh.term_start) [Vintage Year], '
	else
 		SET @Sql_SelectS=@Sql_SelectS+  ' year(sdh.term_start) [Vintage Year],' 	         

		SET @Sql_SelectS=@Sql_SelectS+' round(sum(Volume),' +@round_value + ') Volume,'

	if @target_report!='t' 
		SET @Sql_SelectS=@Sql_SelectS+' ROUND(sum(bonus),' +@round_value + ') Bonus,'

	SET @Sql_SelectS=@Sql_SelectS+' round(sum(Volume + bonus),' +@round_value + ') [Total Volume],              
	  UOM INTO #temp_select '            
	            
	           
	SET @Sql_SelectD=')sdh             
	 where  isnull('+ISNULL(CAST(@compliance_year as varchar),'NULL')+', 1) = case when ('+ISNULL(CAST(@compliance_year as varchar),'NULL')+' is null) then 1 else              
		  sdh.compliance_year end '             
	IF @status_id IS NOT NULL            
	 SET  @Sql_SelectD=@Sql_SelectD+' AND '''+CAST(@status_id AS VARCHAR)+'''=            
			case when(assignment_type_value_id = 5149 and expiration_date < convert(datetime,'''+@as_of_date+''', 102)) then ''e''              
				  when(assignment_type_value_id NOT IN (5149) and assigned_date <= convert(datetime,'''+ @as_of_date+''', 102)) then ''s''              
				 else ''a''               
			end '            
	            
	if @target_report!='t'                        
		SET  @Sql_SelectD=@Sql_SelectD+' group by Generator, sdh.generator_id, Technology, Assignment, assigned_state, State,  curve_name, year(sdh.term_start), UOM              
		 order by Generator, Technology, Assignment, State, year(term_start) '   
	else
		SET  @Sql_SelectD=@Sql_SelectD+' group by Generator, sdh.generator_id, Technology, Assignment, assigned_state, State,  curve_name, year(sdh.term_start), UOM              
		 order by Generator, Technology, Assignment, State, year(sdh.term_start) '   

	              
	END              

	if @summary_option='b'  -- Yearly Acitivity
	BEGIN              
	        
	SET @Sql_SelectS='              
	 select  
	  case when isnull(assignment_type_value_id,5173)=5173 or sdh.compliance_year is null then YEAR(sdh.term_start) else sdh.compliance_year end
		 as [Activity Year],
	  curve_name [Env Product], 
	  Assignment,               
	  assigned_state Jurisdiction,                      
	   round(sum(Volume),' +@round_value + ') Volume,
	   ROUND(sum(bonus),' +@round_value + ') Bonus,
	   round(sum(Volume + bonus),' +@round_value + ') [Total Volume],              
	  UOM '            
	SET @Sql_SelectS = @Sql_SelectS + 'into #temp_select '                
	SET @Sql_SelectD=')sdh             
	 where  isnull('+ISNULL(CAST(@compliance_year as varchar),'NULL')+', 1) = case when ('+ISNULL(CAST(@compliance_year as varchar),'NULL')+' is null) then 1 else              
		  case when isnull(assignment_type_value_id,5173)=5173 or sdh.compliance_year is null then  YEAR(sdh.term_start) else sdh.compliance_year end end '             
	            
	 set @Sql_SelectD=@Sql_SelectD+' group by 
		 case when isnull(assignment_type_value_id,5173)=5173 or sdh.compliance_year is null then  YEAR(sdh.term_start) else sdh.compliance_year end, 
		 Assignment, assigned_state, State,UOM, curve_name              
		 order by 
		 case when isnull(assignment_type_value_id,5173)=5173 or sdh.compliance_year is null then  YEAR(sdh.term_start) else sdh.compliance_year end,curve_name,
		 Assignment,assigned_state '   
	              
	END              

	if @summary_option='e'  -- Group By Expiration
	BEGIN              
	        
	SET @Sql_SelectS='              
	 select  
	  
	 dbo.FNADateFormat(expiration_date) as [Expiration],
	  curve_name [Env Product], 
	  Assignment,               
	  assigned_state Jurisdictions,                      
	  --'''+ isnull(cast(@jurisdiction AS VARCHAR(20)), '') + ''' Jurisdiction,
	   round(sum(Volume),' +@round_value + ') Volume,
	   ROUND(sum(bonus),' +@round_value + ') Bonus,
	   round(sum(Volume + bonus),' +@round_value + ') [Total Volume],              
	  UOM into #temp_select '            
	                
	SET @Sql_SelectD=')sdh             
	 where  isnull('+ISNULL(CAST(@compliance_year as varchar),'NULL')+', 1) = case when ('+ISNULL(CAST(@compliance_year as varchar),'NULL')+' is null) then 1 else              
		  case when isnull(assignment_type_value_id,5173)=5173 or sdh.compliance_year is null then  YEAR(sdh.deal_date) else sdh.compliance_year end end '             
	            
	 set @Sql_SelectD=@Sql_SelectD+' group by 
		 expiration_date, 
		 Assignment, 
		 assigned_state, 
		-- State,
		 UOM, 
		 curve_name              
		 order by 
		 expiration_date,curve_name,
		 Assignment,assigned_state '   
	              
	END  
	            
	if @summary_option = 'h'  -- Generator/Credit Source Group
	BEGIN              

	SET @Sql_SelectS='              
	 select  
	 ''<span style="cursor: pointer;" onclick="parent.parent.parent.TRMWinHyperlink(12101700,''+cast(sdh.generator_id as varchar)+'')"><font color="#0000ff"><u>''+Generator+''</u></font></span>''  [Generator/Credit Source],          
	  --Generator,               
	  sdh.Technology,               
	  Assignment,               
	   ''<span style="cursor: pointer;" onclick="parent.parent.parent.TRMWinHyperlink(14100100,''+cast(State as varchar)+'')"><font color="#0000ff"><u>''+assigned_state+''</u></font></span>'' Jurisdiction,             
	  curve_name [Env Product],'               

	if @target_report!='t' 
		SET @Sql_SelectS=@Sql_SelectS+  ' dbo.FNADateFormat(expiration_date) Expiration, '
	else
 		SET @Sql_SelectS=@Sql_SelectS+  ' dbo.FNADateFormat(sdh.deal_date) [Deal Date],' 	         

		SET @Sql_SelectS=@Sql_SelectS+' ROUND(sum(Volume),' +@round_value + ') Volume,'

	if @target_report!='t' 
		SET @Sql_SelectS=@Sql_SelectS+' ROUND(sum(bonus),' +@round_value + ') Bonus,'

	SET @Sql_SelectS=@Sql_SelectS+' round(sum(Volume + bonus),' +@round_value + ') [Total Volume],              
	  sdh.UOM into #temp_select '            
	            
	            
	SET @Sql_SelectD=')sdh             
	LEFT join rec_generator rg on sdh.generator_id=rg.generator_id
	left join rec_generator_group rgg on rg.generator_group_name = rgg.generator_group_id
	 where  isnull('+ISNULL(CAST(@compliance_year as varchar),'NULL')+', 1) = case when ('+ISNULL(CAST(@compliance_year as varchar),'NULL')+' is null) then 1 else              
		  sdh.compliance_year end '             
	IF @status_id IS NOT NULL            
	 SET  @Sql_SelectD=@Sql_SelectD+' AND '''+CAST(@status_id AS VARCHAR)+'''=            
			case when(assignment_type_value_id = 5149 and expiration_date < convert(datetime,'''+@as_of_date+''', 102)) then ''e''              
				  when(assignment_type_value_id NOT IN (5149) and assigned_date <= convert(datetime,'''+ @as_of_date+''', 102)) then ''s''              
				 else ''a''               
			end '            
	            
	if @target_report!='t' 
		SET  @Sql_SelectD=@Sql_SelectD+' group by sdh.generator,rgg.generator_group_name, sdh.generator_id, sdh.Technology, Assignment, assigned_state, State,  curve_name, expiration_date, sdh.UOM              
		 order by rgg.generator_group_name, sdh.Technology, Assignment, State, expiration_date '   
	else
		SET  @Sql_SelectD=@Sql_SelectD+' group by sdh.generator,rgg.generator_group_name, sdh.generator_id, sdh.Technology, Assignment, assigned_state, State,  curve_name, deal_date, sdh.UOM              
		 order by rgg.generator_group_name, sdh.Technology, Assignment, State, deal_date '   
	              
	END              
	            
	if @summary_option = 'i'  -- Generator/Credit Source By Group
	BEGIN              

	SET @Sql_SelectS='       
	 select  
	  isnull(rgg.generator_group_name,sdh.generator) [Generator/Credit Source Group], 
	  ''<span style="cursor: pointer;" onclick="parent.parent.parent.TRMWinHyperlink(12101700,''+cast(sdh.generator_id as varchar)+'')"><font color="#0000ff"><u>''+Generator+''</u></font></span>''  [Generator/Credit Source],            
	  --Generator,               
	  sdh.Technology,               
	  Assignment,               
	    ''<span style="cursor: pointer;" onclick="parent.parent.parent.TRMWinHyperlink(14100100,''+cast(State as varchar)+'')"><font color="#0000ff"><u>''+assigned_state+''</u></font></span>'' Jurisdiction,              
	  curve_name [Env Product],'               

	if @target_report!='t' 
		SET @Sql_SelectS=@Sql_SelectS+  ' dbo.FNADateFormat(expiration_date) Expiration, '
	else
 		SET @Sql_SelectS=@Sql_SelectS+  ' dbo.FNADateFormat(sdh.deal_date) [Deal Date],' 	         

		SET @Sql_SelectS=@Sql_SelectS+' round(sum(Volume),' +@round_value + ') Volume,'

	if @target_report!='t' 
		SET @Sql_SelectS=@Sql_SelectS+' ROUND(sum(bonus) ,' +@round_value + ') Bonus,'
	              
	SET @Sql_SelectS=@Sql_SelectS+' round(sum(Volume + bonus),' +@round_value + ') [Total Volume],              
	  sdh.UOM '            
	
	SET @Sql_SelectS = @Sql_SelectS + 'into #temp_select ' 
	            
	SET @Sql_SelectD=')sdh             
	LEFT join rec_generator rg on sdh.generator_id=rg.generator_id
	left join rec_generator_group rgg on rg.generator_group_name = rgg.generator_group_id
	 where  isnull('+ISNULL(CAST(@compliance_year as varchar),'NULL')+', 1) = case when ('+ISNULL(CAST(@compliance_year as varchar),'NULL')+' is null) then 1 else              
		  sdh.compliance_year end '             
	IF @status_id IS NOT NULL            
	 SET  @Sql_SelectD=@Sql_SelectD+' AND '''+CAST(@status_id AS VARCHAR)+'''=            
			case when(assignment_type_value_id = 5149 and expiration_date < convert(datetime,'''+@as_of_date+''', 102)) then ''e''              
				  when(assignment_type_value_id NOT IN (5149) and assigned_date <= convert(datetime,'''+ @as_of_date+''', 102)) then ''s''              
				 else ''a''               
			end '            

	if @target_report!='t'             
		SET  @Sql_SelectD=@Sql_SelectD+' group by sdh.Generator,rgg.generator_group_name, sdh.generator_id, sdh.Technology, Assignment, assigned_state, State,  curve_name, expiration_date,sdh.UOM              
		 order by Generator, sdh.Technology, Assignment, State, expiration_date '   
	else
		SET  @Sql_SelectD=@Sql_SelectD+' group by sdh.Generator,rgg.generator_group_name, sdh.generator_id, sdh.Technology, Assignment, assigned_state, State,  curve_name, deal_date, sdh.UOM              
		 order by Generator, sdh.Technology, Assignment, State, deal_date '   
		              
	END              

	if @summary_option = 't'--Grouping by Technology, Assignment, State, Renewable Obligation              
	BEGIN            
	SET @Sql_SelectS='              
	 select  
	  trader_name Trader, Technology, counterparty_name Counterparty, dbo.FNADateFormat(deal_date) DealDate,              
	  case when(buy_sell_flag = ''b'') then ''Buy'' else ''Sell'' end BuySell,               
	    ''<span style="cursor: pointer;" onclick="parent.parent.parent.TRMWinHyperlink(14100100,''+cast(State as varchar)+'')"><font color="#0000ff"><u>''+assigned_state+''</u></font></span>'' Jurisdiction,             
	  --assigned_state State,              
	  curve_name [Env Product],               
	  --dbo.FNADateFormat(expiration_date) Expiration,              
	  round(sum(Volume),' +@round_value + ') Volume, '
	if @target_report!='t' 
	SET @Sql_SelectS=@Sql_SelectS+ ' ROUND(sum(bonus),' +@round_value + ') Bonus, '

	SET @Sql_SelectS=@Sql_SelectS+ ' round(sum(Volume + bonus),' +@round_value + ') [Total Volume],              
	  UOM ,
	 
	 abs(round(abs(sum(case when ((buy_sell_flag = ''s'' ) OR fas_deal_type_value_id <> 400) 
	   then 1 else -1 end * fixed_price * volume))/case when sum(Volume)=0 then 1 else nullif(sum(volume),0) end,2)) Price  
	 ,              
	  sum(case when ((buy_sell_flag = ''s'' ) OR fas_deal_type_value_id <> 400) 
	   then 1 else -1 end * abs(fixed_price) * abs(volume)) [Settlement (+Rec/-Pay)] INTO #temp_select 
	 '            
	            
	SET @Sql_SelectD=')sdh              
	 where  isnull('+ISNULL(CAST(@compliance_year as varchar),'NULL')+', 1) = case when ('+ISNULL(CAST(@compliance_year as varchar),'NULL')+' is null) then 1 else              
		  sdh.compliance_year end '             
	IF @status_id IS NOT NULL            
	 SET  @Sql_SelectD=@Sql_SelectD+' AND '''+CAST(@status_id AS VARCHAR)+'''=            
			case when(assignment_type_value_id = 5149 and expiration_date < convert(datetime,'''+@as_of_date+''', 102)) then ''e''              
				  when(assignment_type_value_id NOT IN (5149) and assigned_date <= convert(datetime,'''+ @as_of_date+''', 102)) then ''s''              
				 else ''a''               
			end'                  
	SET  @Sql_SelectD=@Sql_SelectD+' group by trader_name, Technology, counterparty_name, deal_date, buy_sell_flag, assigned_state, State, curve_name, UOM              
	 order by trader_name, Technology, counterparty_name, deal_date, buy_sell_flag, assigned_state             
	'            
	END            
	            
	if @summary_option = 'c' --Grouping by Technology, Assignment, State, Renewable Obligation              
	BEGIN            
	SET @Sql_SelectS='              
	 select  counterparty_name Counterparty, Technology, dbo.FNADateFormat(deal_date) DealDate,              
	  case when(buy_sell_flag = ''b'') then ''Buy'' else ''Sell'' end BuySell,               
	    ''<span style="cursor: pointer;" onclick="parent.parent.parent.TRMWinHyperlink(14100100,''+cast(State as varchar)+'')"><font color="#0000ff"><u>''+assigned_state+''</u></font></span>'' Jurisdiction,              
	  --assigned_state State,              
	  curve_name [Env Product],               
	  --dbo.FNADateFormat(expiration_date) Expiration,              
	  ISNULL(round(sum(Volume),' + @round_value + '), 0) Volume,               
	  UOM,              
	 --avg(fixed_price) Price,              
	  abs(round(abs(sum(case when ((buy_sell_flag = ''s'' ) OR fas_deal_type_value_id <> 400) 
	  then 1 else -1 end * fixed_price * volume))/nullif(sum(Volume),0),2)) Price,  

	  sum(case when ((buy_sell_flag = ''s'') OR fas_deal_type_value_id <> 400)  
	   then 1 else -1 end * abs(fixed_price) * abs(volume)) [Settlement (+Rec/-Pay)] 
	 '   
	 
	SET @Sql_SelectS = @Sql_SelectS + 'into #temp_select '          
	SET @Sql_Selectd=')sdh              
	 where  isnull('+ISNULL(CAST(@compliance_year as varchar),'NULL')+', 1) = case when ('+ISNULL(CAST(@compliance_year as varchar),'NULL')+' is null) then 1 else              
		 sdh.compliance_year end'              
	IF @status_id IS NOT NULL            
	 SET  @Sql_SelectD=@Sql_SelectD+' AND '''+CAST(@status_id AS VARCHAR)+'''=            
			case when(assignment_type_value_id = 5149 and expiration_date < convert(datetime,'''+@as_of_date+''', 102)) then ''e''              
				  when(assignment_type_value_id NOT IN (5149) and assigned_date <= convert(datetime,'''+@as_of_date+''', 102)) then ''s''              
				 else ''a''               
			end'                  
	            
	SET  @Sql_SelectD=@Sql_SelectD+'  group by counterparty_name, Technology, deal_date, buy_sell_flag, assigned_state, State, curve_name, UOM              
	 order by counterparty_name, Technology, deal_date, buy_sell_flag, assigned_state '               
	      
	END            
	            
	if @summary_option = 'd'--Grouping by Technology, Assignment, State, Renewable Obligation              
	BEGIN     
	  
	-- case  when assign.assigned_volume=-1 then 
	--  dbo.FNACertificateRule(cr.cert_rule,rg.generator_id,gis.certificate_number_from_int+sdh.total_volume-sdh.volume,gis.gis_cert_date) 
	-- 
	--  else  
	--  dbo.FNACertificateRule(cr.cert_rule,rg.generator_id,ISNULL((select sum(assigned_volume) from #temp_assign where assignment_id<=assign.assignment_id      
	--  and source_deal_header_id_from=assign.source_deal_header_id_from)+gis.certificate_number_from_int-assign.assigned_volume,
	--  ISNULL(assign1.assigned_volume+gis.certificate_number_from_int,gis.certificate_number_from_int)),gis.gis_cert_date) 
	-- end
	-- as CertIDFrom,
  
	SET @Sql_SelectS='    
	  select   
	 distinct 
	 dbo.FNAHyperLinkText(10131010, sdh.source_deal_id,sdh.source_deal_id) [ID],
	 sdh.certificate_from as [Cert ID From],
	 sdh.certificate_to as [Cert ID TO],
	 --dbo.FNACertificateRule(cr.cert_rule,rg.generator_ID,assign.cert_from ,gis.gis_cert_date) +''&nbsp;'' as CertIDFrom,
	--  dbo.FNACertificateRule(cr.cert_rule,rg.[ID],assign.cert_from ,sdh.term_start) +''&nbsp;'' as CertIDFrom,
	-- dbo.FNACertificateRule(cr.cert_rule,rg.generator_ID,assign.cert_to ,gis.gis_cert_date)  +''&nbsp;'' as  CertIDT0,
	-- dbo.FNACertificateRule(cr.cert_rule,rg.[ID],assign.cert_to ,sdh.term_start)  +''&nbsp;'' as  CertIDT0,

	  dbo.FNADateFormat(sdh.deal_date) DealDate,          
	  dbo.FNADateFormat(sdh.gen_date) Vintage,          
	  ISNULL(sdh.ext_deal_id,sdh.source_deal_header_id) [Detail ID],           
	  case when status_value_id=5180 and buy_sell_flag=''s'' then ''Adjustment - Sell'' else sdh.assignment end as Assignment,
     --sdh.assignment_type_value_id,          
	  dbo.FNADateFormat(sdh.assigned_date) AssignedDate,          
	  dbo.FNADateFormat(sdh.expiration_date) Expiration, 
	  CASE 
	      WHEN ''' + @is_from_tier_and_expiration + ''' = ''y'' THEN dbo.FNAHyperLinkText(10101012, ''' + ISNULL(@jurisdiction, '''''') + ''', ' + ISNULL(cast(@assigned_state_jurisdiction AS VARCHAR (20)), '''''') + ')        

	      ELSE 	dbo.FNAHyperLinkText(10101012, sdh.assigned_state, cast(sdh.State as varchar))            

	  END  Jurisdiction,
	  sdh.curve_name [Env Product],          
	  sdh.Generator [Generator/Credit Source],          
	  sdh.Technology,          
	  sdh.buy_sell_flag BuySell,          
	  sdh.trader_name Trader,           
	  sdh.counterparty_name Counterparty,           
	  sdh.fixed_price Price,           
	  --sdh.volume volume,          
	CASE when assign.assigned_volume=-1 or assign.assigned_volume is null  then sdh.volume * isnull(sdh.multiplier, 1) else	
	assign.assigned_volume * isnull(sdh.multiplier, 1) *  case   when (buy_sell_flag = ''s'' and ''' + @Target_report + ''' = ''t'') then -1 else 1 end  end volume,          
	sdh.bonus Bonus,          
	CASE when assign.assigned_volume=-1 or assign.assigned_volume is null then sdh.volume * isnull(sdh.multiplier, 1) else	
	assign.assigned_volume * isnull(sdh.multiplier, 1) * case when (buy_sell_flag = ''s'' and ''' + @Target_report + ''' = ''t'') then -1 else 1 end end  + sdh.bonus TotalVolume,          
	  sdh.UOM into #temp_select   
	 '        
	SET @Sql_SelectD=')sdh    
	LEFT JOIN        
		#temp_assign assign        
	ON        
		sdh.source_deal_header_id=assign.source_deal_header_id 
	LEFT JOIN Gis_certificate gis on        
		gis.source_deal_header_id=assign.source_deal_header_id_from       
	LEFT join rec_generator rg on        
		sdh.generator_id=rg.generator_id 
	LEFT JOIN 
		rec_generator_group rgg on rg.generator_group_name = rgg.generator_group_id         
	LEFT JOIN        
		certificate_rule cr on rg.gis_value_id=cr.gis_id      
	LEFT JOIN    

	(SELECT source_deal_header_id_from,sum(assigned_volume) assigned_volume from       
	#temp_assign group by source_deal_header_id_from) assign1      
	on assign1.source_deal_header_id_from=sdh.source_deal_header_id 
	         
	where isnull('+ISNULL(CAST(@compliance_year as varchar),'NULL')+', 1) = case when ('+ISNULL(CAST(@compliance_year as varchar),'NULL')+' is null) then 1 else          
		  sdh.compliance_year end  ' + case when @status_id is null then '' else        
			' and '''+ISNULL(CAST(@status_id AS VARCHAR),'a')+''' = 
	--	case when ('''+ISNULL(CAST(@status_id AS VARCHAR),'a')+''' ='''+ISNULL(CAST(@status_id AS VARCHAR),'a')+''') then ''a'' else          
			case when(sdh.assignment_type_value_id = 5149 and sdh.expiration_date < convert(datetime,'''+@as_of_date+''', 102)) then ''e''          
				  when(sdh.assignment_type_value_id NOT IN (5149) and sdh.assigned_date <= convert(datetime,'''+@as_of_date+''', 102)) then ''s''          
				 else ''a''           
			end              
	--         end          
	  '        end 
	   + case when (@drill_Counterparty is null) then '' else ' and sdh.counterparty_name  = ''' + @drill_Counterparty + ''''end          
	   + case when (@drill_DealDate is null) then ''   
 				when (len(ltrim(rtrim(@drill_DealDate)))=4 AND @drill_from_activity = 'y') then 
 					' AND case when isnull(assignment_type_value_id,5173)=5173 or sdh.compliance_year is null then YEAR(sdh.term_start) else sdh.compliance_year end = '''+@drill_DealDate+''' ' 
 				when (len(ltrim(rtrim(@drill_DealDate)))=4 AND @drill_from_activity IS NULL)  THEN	' AND  YEAR(sdh.term_start)= '''+@drill_DealDate+'''' 
				when isdate(@drill_DealDate)=0 then ' and dbo.FNAContractMonthFormat(sdh.term_start)= '''+@drill_DealDate+'''' 
				WHEN @summary_option IN('o','v','z') THEN ' AND sdh.term_start= '''+@drill_DealDate+''''
				ELSE ' and dbo.fnadateformat(sdh.deal_date) = dbo.fnadateformat('''+@drill_DealDate+''')' 
	     end          
	   + case when (@drill_BuySell is null) then '' else ' and case when sdh.buy_sell_flag=''b'' then ''buy'' else ''sell'' end = ''' + @drill_BuySell + ''''end          
	   + case when (@drill_oblication is null or @drill_oblication='') then '' else ' and sdh.curve_name  = ''' + @drill_oblication + ''''end          
	   + case when (@drill_trader is null) then '' else CASE WHEN @drill_Generator IS NULL then ' and sdh.trader_name  = ''' + @drill_trader + '''' ELSE '' END end          
	   + case when (@drill_Generator IS NULL) then ''
	     WHEN @drill_Generator = '' THEN ' AND sdh.generator IS NULL '
		 else ' and '+
			CASE 
				WHEN @drill_trader='zzz' then 'isnull(rg.generator_group_name,sdh.generator)' 
				WHEN @is_generator_group = 'y' then 'isnull(rgg.generator_group_name, sdh.generator)'
				else 'sdh.generator' 
			END + '  = ''' + @drill_Generator + ''''
		END          
	   + case when (@drill_Expiration is not null and @Target_report='n') then 
	   case when len(ltrim(rtrim(@drill_Expiration)))=4 then ' and year(sdh.term_start)='+@drill_Expiration+'' else 'and dbo.FNADateFormat(sdh.expiration_date) = dbo.FNADateFormat(''' + @drill_Expiration + ''')' end else '' end          
	   + case when (@drill_Expiration is not null and @Target_report='t') then 
		case when len(ltrim(rtrim(@drill_Expiration)))=4 then ' and year(sdh.term_start)= '''+@drill_Expiration+'''' else ' and dbo.FNADateFormat(sdh.expiration_date) = dbo.FNADateFormat(''' + @drill_Expiration + ''')' end else '' end          
	   + case when @drill_Technology is null then '' 
		 WHEN @drill_Technology ='' THEN ' and sdh.technology IS NULL '
		else ' and sdh.technology  = ''' + @drill_Technology + ''''end          
	   + CASE 
			WHEN (@to_be_assign_state IS NOT NULL AND @is_from_tier_and_expiration = 'y') then '' 
			else (case when (@drill_State is null or @drill_State='') then '' else ' and sdh.assigned_state  = ''' + @drill_State + ''''END) 
	     END
	   + CASE 
	        WHEN @drill_state_without_assigned_state is  null THEN ''
	        ELSE ' and sdh.state  = ''' + @drill_state_without_assigned_state + ''''
	    END             
	   + case when (@drill_UOM is null) then '' else ' and sdh.UOM  = ''' + @drill_UOM + ''''end          
	--  + case when (@drill_Assignment is null) then '' else ' and sdh.assignment = ''' + @drill_Assignment + '''' end
		--+ CASE WHEN @summary_from_drill = 'x' 
		--		THEN case when (@drill_tier_type is NULL) then ' and sdh.tier_type IS NULL ' else ' and sdh.tier_type  = ''' + @drill_tier_type + ''''END
		--		ELSE ''
		--   END
	  + case when (@drill_tier_type is NULL) then '' else ' and sdh.tier_type  = ''' + @drill_tier_type + ''''end+  --and sdh.tier_type IS NULL
	   + case when (@drill_env_product is null) then '' else ' and sdh.curve_name  = ''' + @drill_env_product + ''''end+
	 
	        
	' order by   dbo.FNADateFormat(sdh.deal_date) '        
	   
	END 
	    
	--	print @drill_Generator  
	      
	if @summary_option = 'o' --obligation and vintage      
	BEGIN      
	SET @Sql_SelectS='       
	  select        
	  curve_name [Env Product],               
	  dbo.FNATermGrouping(term_start,deal_volume_frequency) Term,              
	  round(sum(Volume),' +@round_value + ') Volume, '

	if @target_report!='t' 
		SET @Sql_SelectS=@Sql_SelectS+' ROUND(sum(bonus),' +@round_value + ') Bonus,'
	              
	SET @Sql_SelectS=@Sql_SelectS+' ROUND(sum(Volume + bonus),' +@round_value + ') [Total Volume],              
	  UOM '            
	            
	SET @Sql_SelectS = @Sql_SelectS + 'into #temp_select '              
	SET @Sql_SelectD=')sdh             
	 where  isnull('+ISNULL(CAST(@compliance_year as varchar),'NULL')+', 1) = case when ('+ISNULL(CAST(@compliance_year as varchar),'NULL')+' is null) then 1 else              
		  sdh.compliance_year end '             
	IF @status_id IS NOT NULL            
	 SET  @Sql_SelectD=@Sql_SelectD+' AND '''+CAST(@status_id AS VARCHAR)+'''=            
			case when(assignment_type_value_id = 5149 and expiration_date < convert(datetime,'''+@as_of_date+''', 102)) then ''e''              
				  when(assignment_type_value_id NOT IN (5149) and assigned_date <= convert(datetime,'''+ @as_of_date+''', 102)) then ''s''              
				 else ''a''               
			end '            
	            
	SET  @Sql_SelectD=@Sql_SelectD+' group by curve_name, dbo.FNATermGrouping(term_start,deal_volume_frequency), UOM              
	 order by  curve_name, dbo.FNATermGrouping(term_start,deal_volume_frequency)'             
	              
	END          
	      
	if @summary_option = 'v' -- trader and vintage      
	BEGIN      
	SET @Sql_SelectS='              
	 select        
	  trader_name Trader,       
	  curve_name [Env Product],               
	  dbo.FNATermGrouping(term_start,deal_volume_frequency) Term,                  
	  round(sum(Volume),' +@round_value + ') Volume,'
	if @target_report!='t' 
		SET @Sql_SelectS=@Sql_SelectS+' ROUND(sum(bonus),' +@round_value + ') Bonus,'
	              
	SET @Sql_SelectS=@Sql_SelectS+' round(sum(Volume + bonus),' +@round_value + ') [Total Volume],              
	  UOM,              
	  abs(round(abs(sum(case when ((buy_sell_flag = ''s'' ) OR fas_deal_type_value_id <> 400) 
	   then 1 else -1 end * abs(fixed_price) * abs(volume)))/case when sum(Volume)=0 then 1 else sum(volume) end,2)) Price , 
	  sum(case when ((buy_sell_flag = ''s'') OR fas_deal_type_value_id <> 400)  
			then 1 else -1 end * abs(fixed_price) * abs(volume)) [Settlement (+Rec/-Pay)] 
	 '            
	SET @Sql_SelectS = @Sql_SelectS + 'into #temp_select '           
	SET @Sql_SelectD=')sdh              
	 where  isnull('+ISNULL(CAST(@compliance_year as varchar),'NULL')+', 1) = case when ('+ISNULL(CAST(@compliance_year as varchar),'NULL')+' is null) then 1 else sdh.compliance_year end '             
	IF @status_id IS NOT NULL            
	 SET  @Sql_SelectD=@Sql_SelectD+' AND '''+CAST(@status_id AS VARCHAR)+'''=            
			case when(assignment_type_value_id = 5149 and expiration_date < convert(datetime,'''+@as_of_date+''', 102)) then ''e''              
				  when(assignment_type_value_id NOT IN (5149) and assigned_date <= convert(datetime,'''+ @as_of_date+''', 102)) then ''s''              
				 else ''a''               
			end'                  
	SET  @Sql_SelectD=@Sql_SelectD+' group by trader_name,dbo.FNATermGrouping(term_start,deal_volume_frequency),curve_name,UOM              
	 order by trader_name,curve_name, dbo.FNATermGrouping(term_start,deal_volume_frequency)
	'            
	END            
	      
	if @summary_option = 'z' -- Counterparty and vintage      
	BEGIN      
	SET @Sql_SelectS='              
	 select  counterparty_name Counterparty,       
	  --Technology, dbo.FNADateFormat(deal_date) DealDate,              
	--   case when(buy_sell_flag = ''b'') then ''Buy'' else ''Sell'' end BuySell,               
	--   dbo.FNAHyperLinkText(10101012, assigned_state, cast(State as varchar)) State,               
	  --assigned_state State,              
	  curve_name [Env Product],               
	  dbo.FNATermGrouping(term_start,deal_volume_frequency) Term,                  
	  --dbo.FNADateFormat(expiration_date) Expiration,              
	  ROUND(sum(Volume),' +@round_value + ') Volume,               
	  UOM,              
	  abs(round(abs(sum(case when ((buy_sell_flag = ''s'' ) OR fas_deal_type_value_id <> 400) 
	   then 1 else -1 end * fixed_price * volume))/nullif(sum(Volume),0),2)) Price,  
	  sum(case when ((buy_sell_flag = ''s'') OR fas_deal_type_value_id <> 400)  then 1 else -1 end * abs(fixed_price) * abs(volume)) [Settlement (+Rec/-Pay)] 
	 '         
	SET @Sql_SelectS = @Sql_SelectS + 'into #temp_select '    
	SET @Sql_Selectd=')sdh              
	 where  isnull('+ISNULL(CAST(@compliance_year as varchar),'NULL')+', 1) = case when ('+ISNULL(CAST(@compliance_year as varchar),'NULL')+' is null) then 1 else              
		 sdh.compliance_year end'              
	IF @status_id IS NOT NULL            
	 SET  @Sql_SelectD=@Sql_SelectD+' AND '''+CAST(@status_id AS VARCHAR)+'''=            
			case when(assignment_type_value_id = 5149 and expiration_date < convert(datetime,'''+@as_of_date+''', 102)) then ''e''              
				  when(assignment_type_value_id NOT IN (5149) and assigned_date <= convert(datetime,'''+@as_of_date+''', 102)) then ''s''              
				 else ''a''               
			end'                  
	            
	SET  @Sql_SelectD=@Sql_SelectD+'  group by counterparty_name, curve_name, UOM,dbo.FNATermGrouping(term_start,deal_volume_frequency)              
	 order by counterparty_name, curve_name, dbo.FNATermGrouping(term_start,deal_volume_frequency)'               
	              
	END            
	      
	if @summary_option = 'p' -- Deal option Deals
	BEGIN      
	SET @Sql_SelectS='              
	 select  
		dbo.FNAHyperLinkText(10131010, sdh.source_deal_id,sdh.source_deal_id) [ID],
	  -- dbo.FNAEmissionHyperlink(2,10131010, cast(sdh.source_deal_id as varchar), cast(sdh.source_deal_id as varchar),NULL) [ID],   
	   counterparty_name Counterparty,       
	   dbo.FNADateFormat(term_start)[term Start],
	   dbo.FNADateFormat(term_end)[term End],               
	   leg,
	   case buy_sell_flag when ''b'' then ''Buy'' else ''Sell'' end as [Buy/Sell],
	   sdh.curve_name [Env Product],          
	   case  option_type when ''c'' then ''Call'' when ''p'' then ''Put'' end as Type,
	   case  option_excercise_type when ''a'' then ''American'' when ''e'' then ''European'' end as [Excercise Type],	
	   round(Volume,' +@round_value + ') Volume,
	   UOM,
	   dbo.FNARemoveTrailingZeroes(fixed_price) as Premium,
	   strike_price as Strike,
	   currency_name as Currency into #temp_select
	 '            
	SET @Sql_Selectd=')sdh               
	 --where isnull(option_flag,''n'')=''y''
	  '

	SET  @Sql_SelectD=@Sql_SelectD+' order by counterparty_name,term_start,term_end '               
	              
	END            

	if @summary_option = 'a' -- Assigned Group
	BEGIN      
	SET @Sql_SelectS=            
	 ' select  
	   Assignment,               
	   Technology,               
	   curve_name [Env Product],  
	   CASE 
	      WHEN ''' + @is_from_tier_and_expiration + ''' = ''y'' THEN dbo.FNAHyperLinkText(10101012, ''' + ISNULL(@jurisdiction, '''''') + ''', ' + ISNULL(cast(@assigned_state_jurisdiction AS VARCHAR (20)), '''''') + ')        

	      ELSE 	  ''<span style="cursor: pointer;" onclick="parent.parent.parent.TRMWinHyperlink(14100100,''+cast(State as varchar)+'')"><font color="#0000ff"><u>''+assigned_state+''</u></font></span>''                 

	  END              
	  [Jurisdiction], '              
	   
	if @target_report!='t' 
		SET @Sql_SelectS=@Sql_SelectS+  ' dbo.FNADateFormat(expiration_date) Expiration, '
	 else
 		SET @Sql_SelectS=@Sql_SelectS+  ' dbo.FNADateFormat(sdh.deal_date) [Deal Date],' 	         
	 

	SET @Sql_SelectS=@Sql_SelectS+ '  ROUND(sum(Volume),' +@round_value + ') Volume, '
	if @target_report!='t' 
		SET @Sql_SelectS=@Sql_SelectS+' ROUND(sum(bonus),' +@round_value + ') Bonus, '

	SET @Sql_SelectS=@Sql_SelectS+' ROUND(sum(Volume + bonus),' +@round_value + ') [Total Volume],              
	   UOM '            
	
	SET @Sql_SelectS = @Sql_SelectS + 'into #temp_select ' 
	SET @Sql_SelectD='            
	)sdh where  isnull('+ISNULL(CAST(@compliance_year as varchar),'NULL')+', 1) = case when ('+ISNULL(CAST(@compliance_year as varchar),'NULL')+' is null) then 1 else              
		   sdh.compliance_year end '            
	IF @status_id IS NOT NULL            
	 SET  @Sql_SelectD=@Sql_SelectD+' AND '''+CAST(@status_id AS VARCHAR)+'''=            
			case when(assignment_type_value_id = 5149 and expiration_date < convert(datetime,'''+@as_of_date+''', 102)) then ''e''              
	 when(assignment_type_value_id NOT IN (5149) and assigned_date <= convert(datetime,'''+@as_of_date+''', 102)) then ''s''              
				 else ''a''               
			end '                 
	if @target_report!='t'                        
		SET  @Sql_SelectD=@Sql_SelectD+' group by Assignment, assignment_type_value_id,Technology, assigned_state, State,  curve_name,  dbo.FNADateFormat(expiration_date), UOM              
		 order by Assignment,Technology,  dbo.FNADateFormat(expiration_date),  assigned_state'            
	else
		SET  @Sql_SelectD=@Sql_SelectD+' group by  assignment_type_value_id, Technology, assigned_state, State, Assignment,curve_name,  dbo.FNADateFormat(sdh.deal_date), UOM              
		 order by Assignment,Technology,  dbo.FNADateFormat(sdh.deal_date),  assigned_state'            

	END              
	-----------------------------------------------------
	if @summary_option = 'x'			--Tier type
	BEGIN     
		SET @Sql_SelectS = 'select sdh.[tier_type] [Tier Type],             
						Technology,               
						Assignment,     						 
						''<span style="cursor: pointer;" onclick="parent.parent.parent.TRMWinHyperlink(14100100,'+cast(@assigned_state_jurisdiction AS VARCHAR)+')"><font color="#0000ff"><u>''+assigned_state+''</u></font></span>'' Jurisdiction,         
						--dbo.FNAHyperLinkText(14100100, ''' + @jurisdiction + ''', ' + isNULL(cast(@assigned_state_jurisdiction AS VARCHAR (20)), '''''') + ') as [Jurisdiction],     
						curve_name [Env Product],'   

		if @target_report!='t' 
			SET @Sql_SelectS=@Sql_SelectS+  ' dbo.FNADateFormat(expiration_date) Expiration, '
		else
 			SET @Sql_SelectS=@Sql_SelectS+  ' YEAR(term_start) [Vintage],' 	         

			SET @Sql_SelectS=@Sql_SelectS+' round(sum(Volume),' +@round_value + ') Volume,'

		if @target_report!='t' 
			SET @Sql_SelectS=@Sql_SelectS+' ROUND(sum(bonus),' +@round_value + ') Bonus,'

		SET @Sql_SelectS=@Sql_SelectS+' round(sum(Volume + bonus),' +@round_value + ') [Total Volume],              
		  UOM into #temp_select '             
		            
		           
		SET @Sql_SelectD=')sdh             
		 where  isnull('+ISNULL(CAST(@compliance_year as varchar),'NULL')+', 1) = case when ('+ISNULL(CAST(@compliance_year as varchar),'NULL')+' is null) then 1 else              
			  sdh.compliance_year end '             
		IF @status_id IS NOT NULL            
		 SET  @Sql_SelectD=@Sql_SelectD+' AND '''+CAST(@status_id AS VARCHAR)+'''=            
				case when(assignment_type_value_id = 5149 and expiration_date < convert(datetime,'''+@as_of_date+''', 102)) then ''e''              
					  when(assignment_type_value_id NOT IN (5149) and assigned_date <= convert(datetime,'''+ @as_of_date+''', 102)) then ''s''              
					 else ''a''               
				end '            
		          
		if @target_report!='t'                        
			SET  @Sql_SelectD=@Sql_SelectD+' group by tier_type, Technology, Assignment, assigned_state, State,  curve_name, expiration_date, UOM               
			 order by  Technology, Assignment, State, expiration_date '   
		else
			SET  @Sql_SelectD=@Sql_SelectD+' group by YEAR(term_start), tier_type, Technology, Assignment, --assigned_state, State, 
			                                 curve_name,  UOM              
												order by  tier_type, Technology, Assignment , YEAR(term_start)--State '   

	               
	END              
--------------------

END            
          
--********* For Target Report*****************            
ELSE            
BEGIN            
	            
	if @plot = 'y'             
	BEGIN            
	            
		SET @Sql_SelectS='              
		 select  compliance_year [Year],             
		 abs(sum(case  when (assignment = ''Projected'') then volume else 0 end)) * 100000 as Forecast,            
		 abs(sum(case when (assignment IN (''RPS Compliance'', ''Windsource'', ''CO2 Target'') AND            
		 target_actual = ''Target'') then             
		   volume else 0  end)) * 100000 as Requirement,            
		  abs(sum(case when (assignment in(''Banked'',''Forward'')) then volume else 0  end)) * 100000 as Inventory,            
		  abs(sum(case when (assignment = ''Sold'') then  volume else 0  end)) * 100000 as Sold,            
		  abs(sum(case when (assignment IN (''RPS Compliance'', ''Windsource'', ''CO2 Target'') AND            
			target_actual = ''Actual'') then             
		   volume else 0  end)) * 100000 as Assigned            
		 '            
		SET @Sql_SelectD=')sdh  group by compliance_year--, assignment, target_actual'            
	            
	END            
	else if @summary_option = 's' OR  @summary_option = 'e'  OR  @summary_option = 't' OR  @summary_option = 'l' OR  @summary_option = 'x'          
	BEGIN            
		SET @Sql_SelectS='              
		 select '
		 +CASE WHEN @summary_option = 'x' THEN 'generator_id,' ELSE '' END
		 +CASE WHEN @summary_option IN('s','x') THEN '
			 sub.entity_name Sub,isnull(curve_name, '''') [Env Product],MAX(Technology) Technology,'  
		 WHEN @summary_option = 'e' THEN 
			 'isnull(curve_name, '''') [Env Product],sub.entity_name Sub,MAX(Technology) Technology,'  
		 WHEN @summary_option = 't' THEN 
			 'isnull(tier_type, '''') [Tier Type],sub.entity_name Sub,MAX(Technology) Technology,'  
		 WHEN @summary_option = 'l' THEN 
			 'isnull(Technology, '''') [Technology],sub.entity_name Sub,isnull(MAX(tier_type), '''') [Tier Type],'  
		 END+
		 ' 
		 CASE WHEN ta.fas_deal_type_value_id = 405 THEN ''Target'' WHEN assignment IN (''Forward'',''Projected'') THEN ''Banked'' ELSE Assignment END as Assignment, 
		 CASE WHEN ta.fas_deal_type_value_id = 405 THEN target_actual WHEN assignment IN (''Forward'') THEN ''Forward'' ELSE target_actual END AS Type, 
		  ''<span style="cursor: pointer;" onclick="parent.parent.parent.TRMWinHyperlink(14100100,''+cast(State as varchar)+'')"><font color="#0000ff"><u>''+assigned_state+''</u></font></span>'' Jurisdiction,                                  
		 CASE WHEN assignment IN (''Banked'',''Forward'',''Sell'') THEN YEAR(term_start) ELSE compliance_year END [Vintage],    
		 round(sum(volume * isnull(ta.multiplier, 1)),' +@round_value + ') [Volume],             
		 ROUND(sum(bonus),' +@round_value + ') [Bonus],             
		 ROUND(sum((volume * isnull(ta.multiplier, 1)) + bonus),' +@round_value + ') [Total Volume (+Long, -Short)],            
		 ta.uom UOM,
		 ta.expiration_date,
		 ta.[isJurisdiction],
		 ta.curve_id,
		 (ta.fixed_price)fixed_price     
		  '             
		SET @Sql_SelectD=')ta LEFT join            
		 portfolio_hierarchy book on book.entity_id = ta.fas_book_id LEFT join            
		 portfolio_hierarchy stra on stra.entity_id = book.parent_entity_id LEFT join            
		 portfolio_hierarchy sub on sub.entity_id = stra.parent_entity_id             
		 where (compliance_year >= isnull(cast('+ISNULL(CAST(@compliance_year as varchar),'NULL')+' as varchar), compliance_year)            
		  OR (assignment in(''Banked'',''Forward'',''Sell'') AND (isnull('+ISNULL(CAST(@report_type as varchar),'NULL')+', 5149) = 5149 AND '''+ISNULL(CAST(@included_banked as varchar),'NULL')+''' = ''y'')             
		 AND cast(compliance_year as int) >= isnull('+ISNULL(CAST(@compliance_year as varchar),'NULL')+', compliance_year)))'  
		 --+CASE WHEN @include_expired='n' THEN ' AND (ISNULL(NULLIF(expiration_date,''''),''9999-01-01'')>convert(datetime, ''' + @as_of_date + ''', 102))' ELSE '' END+       
		 +' group by sub.entity_name,ta.fas_deal_type_value_id,' 
					  +CASE WHEN @summary_option = 'x' THEN 'generator_id,' ELSE '' END
					  +CASE WHEN @summary_option IN('t') THEN 'tier_type,' 
							WHEN @summary_option IN('l') THEN 'Technology,' ELSE   'curve_name,' END+
		 'assigned_state,state,  
		 CASE WHEN assignment IN (''Banked'',''Forward'',''Sell'') THEN YEAR(term_start) ELSE compliance_year END, 
		 assignment, target_actual,ta.uom, ta.expiration_date,ta.[isJurisdiction], ta.curve_id,ta.fixed_price               
		 order by '
			+CASE WHEN @summary_option IN('s','x') THEN 
				'sub.entity_name,curve_name,'
			WHEN @summary_option = 'e' THEN 
				 'curve_name,sub.entity_name,'
			WHEN @summary_option = 'l' THEN 
				 'Technology,sub.entity_name,'
			ELSE 'tier_type,sub.entity_name,' END+
		'assignment,assigned_state,target_actual desc, 
		CASE WHEN assignment IN (''Banked'',''Forward'',''Sell'') THEN YEAR(term_start) ELSE compliance_year END

			'            
	END             
	else            
	Begin 
		--print 'Bagrawal *****************/'           
		SET @Sql_SelectS='            
		 select sub.entity_name Sub,
		 stra.entity_name Strategy,book.entity_name Book,      
		 isnull(curve_name, '''') [Env Product],   
		 ISNULL(ta.tier_type,'''')[Tier Type],   
		 ISNULL(ta.technology,'''') AS [Technology],
		 CASE WHEN ta.fas_deal_type_value_id = 405 THEN ''Target'' WHEN assignment IN (''Forward'',''Projected'') THEN ''Banked'' ELSE Assignment END as Assignment, 
		 CASE WHEN assignment IN (''Forward'') THEN ''Forward'' ELSE target_actual END AS Type,
		   ''<span style="cursor: pointer;" onclick="parent.parent.parent.TRMWinHyperlink(14100100,''+cast(State as varchar)+'')"><font color="#0000ff"><u>''+assigned_state+''</u></font></span>''  [Assigned/Default Jurisdiction],   
		 [Gen State],	              
		 CASE WHEN assignment IN (''Banked'',''Forward'') THEN YEAR(term_start) ELSE ta.compliance_year END [Compliance/Expiration Year],    
		 dbo.FNADateformat(term_start) AS [Vintage],                
		 dbo.FNACertificateRule(cr.cert_rule,rg.[ID],assign.cert_from,ta.term_start)  +''&nbsp;'' as CertIDFrom,
		 dbo.FNACertificateRule(cr.cert_rule,rg.[ID],assign.cert_to,ta.term_start)  +''&nbsp;'' CertIDT0,
		 dbo.FNAHyperLinkText(10131010, ta.source_deal_id,ta.source_deal_id)  [Original RefID],          
		 round(volume * isnull(ta.multiplier,1),' +@round_value + ') [Volume],             
		 ROUND(bonus,' +@round_value + ') [Bonus],           
		 ((volume*isnull(ta.multiplier,1)) + bonus) [Total Volume (+Long, -Short)],            
		 ta.uom UOM,conversion_factor'            
		            
		SET @Sql_SelectD=')ta LEFT join            
		 portfolio_hierarchy book on book.entity_id = ta.fas_book_id LEFT join            
		 portfolio_hierarchy stra on stra.entity_id = book.parent_entity_id LEFT join            
		 portfolio_hierarchy sub on sub.entity_id = stra.parent_entity_id             
		LEFT JOIN        
			#temp_assign assign        
		ON        
			ta.source_deal_header_id=assign.source_deal_header_id 
		LEFT JOIN Gis_certificate gis on        
			gis.source_deal_header_id=assign.source_deal_header_id_from       
		LEFT join rec_generator rg on        
			ta.generator_id=rg.generator_id         
		LEFT JOIN        
			certificate_rule cr on rg.gis_value_id=cr.gis_id      
		LEFT JOIN    
		(SELECT source_deal_header_id_from,sum(assigned_volume) assigned_volume from       

		assignment_audit group by source_deal_header_id_from) assign1      
		on assign1.source_deal_header_id_from=ta.source_deal_header_id 
		      
			  where 1=1
		 --where (compliance_year >= isnull(cast('+ISNULL(CAST(@compliance_year as varchar),'NULL')+' as varchar), compliance_year)            
		  AND (assignment in(''Banked'',''Forward'') AND (isnull('+ISNULL(CAST(@report_type as varchar),'NULL')+', 5149) = 5149 AND '''+ISNULL(CAST(@included_banked as varchar),'NULL')+''' = ''y'')             
		 OR cast(compliance_year as int) >= isnull('+ISNULL(CAST(@compliance_year as varchar),'NULL')+', compliance_year))   ' 
		  --+CASE WHEN @include_expired='n' THEN ' AND (ISNULL(NULLIF(expiration_date,''''),''9999-01-01'')>convert(datetime, ''' + @as_of_date + ''', 102))' ELSE '' END+       
		+' order by sub.entity_name, stra.entity_name, book.entity_name,curve_name,assignment, target_actual desc, assigned_state, term_start desc             
		  '            
	END            
END            

 --CREATE TABLE #temp_select (
 --	[ID] VARCHAR (50) COLLATE DATABASE_DEFAULT ,
 --	[Cert ID From] VARCHAR(50) COLLATE DATABASE_DEFAULT ,
 --	[Cert ID TO] VARCHAR(50) COLLATE DATABASE_DEFAULT ,
 --	[Deal Date] DATETIME,
 --	Vintage DATETIME,
 --	[Detail ID] INT,
 --	Assignment VARCHAR(50) COLLATE DATABASE_DEFAULT ,
 --	[assigned date] DATETIME,
 --	Expiration DATETIME,
 --	Jurisdiction VARCHAR(50) COLLATE DATABASE_DEFAULT ,
 --	 [Env Product] VARCHAR (50) COLLATE DATABASE_DEFAULT ,
 --	 [Generator/Credit Source] VARCHAR (50) COLLATE DATABASE_DEFAULT ,
 --	 Technology VARCHAR(50) COLLATE DATABASE_DEFAULT ,
 --	 [Buy Sell] VARCHAR(50) COLLATE DATABASE_DEFAULT ,
 --	 Trader VARCHAR(50) COLLATE DATABASE_DEFAULT ,
 --	 Counterparty VARCHAR(50) COLLATE DATABASE_DEFAULT ,
 --	 Price INT,
 --	 volume INT,
 --	Bonus INT,
 --	TotalVolume INT,
 --	UOM VARCHAR(50) COLLATE DATABASE_DEFAULT 
 --	)

 --print (@Sql_SelectS)    
 --print @str_batch_table
 --print ' from( '        
 --PRINT @sql_select            
 --PRINT @sql_select1            
 --PRINT @sql_select3           
 --PRINT @sql_select2            
 --PRINT @Sql_SelectD    
 
--IF OBJECT_ID('ssbm') IS NOT null
--BEGIN
--	DROP TABLE ssbm
--	DROP TABLE bonus
--	DROP TABLE temp_duration
--	DROP TABLE temp_assign 
--END
--SELECT * INTO ssbm FROM #ssbm
--SELECT * INTO bonus FROM #bonus
--SELECT * INTO temp_duration FROM #temp_duration
--SELECT * INTO temp_assign FROM #temp_assign

declare @final_sql VARCHAR(MAX)
SET @final_sql  = ' IF OBJECT_ID(''tempdb..#temp_select'') IS NOT NULL   
					Begin
						SELECT * '+ @str_batch_table + ' FROM #temp_select ts WHERE 1=1' +
					 CASE 
						 WHEN @drill_Assignment is not null  THEN ' and ts.assignment = ''' + @drill_Assignment + ''''
						 ELSE ''
					 END +		
					' END'

 --PRINT @final_sql
  
 EXEC(@Sql_SelectS+ ' from( '+@sql_select+@sql_select1+@sql_select3+@sql_select2+@Sql_SelectD + @final_sql )   
 

  
--*****************FOR BATCH PROCESSING**********************************            
/*IF  @batch_process_id is not null        
BEGIN      
exec spa_print '@str_batch_table'  
 SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)   
       exec spa_print @str_batch_table
 EXEC(@str_batch_table)        
 declare @report_name varchar(100)        

 if @Target_report='t'        
  set @report_name='Transactions Report'        
 else if @Target_report='n'        
  set @report_name='Position Report'        
 else        
  set @report_name='Traget Report'        
        
 SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_get_rec_activity_report',@report_name)         
 EXEC spa_print @str_batch_table
 EXEC(@str_batch_table)        
     EXEC spa_print 'finsh spa_get_rec_activity_report'
    
END        
*/


if @is_batch = 1
begin
	--PRINT ('@str_batch_table')  
	 SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)   
		   --PRINT (@str_batch_table)
	 EXEC(@str_batch_table)                   
	        
	 SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_get_rec_activity_report','Run Inventory Position Report')         
	 --PRINT @str_batch_table
	 EXEC(@str_batch_table)        
	--PRINT 'finsh Run Inventory Position Report'
	return
END

IF @enable_paging = 1
BEGIN
		IF @page_size IS NULL
		BEGIN
			set @sql_stmt='select count(*) TotalRow,'''+@batch_process_id +''' process_id  from '+ @temptablename
			--print @sql_stmt
			exec(@sql_stmt)
		end
END 
--********************************************************************        
END
GO
