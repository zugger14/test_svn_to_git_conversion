IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header_template' AND COLUMN_NAME = 'trader_id')
BEGIN
	ALTER TABLE source_deal_header_template ADD trader_id INT NULL
END
GO 
/****** Object:  StoredProcedure [dbo].[spa_template_deal_field_format]    Script Date: 12/06/2011 23:36:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_template_deal_field_format]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_template_deal_field_format]
GO

/****** Object:  StoredProcedure [dbo].[spa_sourcedealheader]    Script Date: 12/06/2011 23:36:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_sourcedealheader]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_sourcedealheader]
GO

/****** Object:  StoredProcedure [dbo].[spa_source_deal_header_template]    Script Date: 12/06/2011 23:36:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_source_deal_header_template]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_source_deal_header_template]
GO

/****** Object:  StoredProcedure [dbo].[spa_blotter_deal]    Script Date: 12/06/2011 23:36:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_blotter_deal]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_blotter_deal]
GO

/****** Object:  StoredProcedure [dbo].[spa_template_deal_field_format]    Script Date: 12/06/2011 23:36:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



--spa_template_deal_field_format 'd',1  
--exec spa_template_deal_field_format 'f',2,NULL,67,'-1'
--exec spa_template_deal_field_format 'p',1,NULL
--exec spa_template_deal_field_format 'm',NULL,NULL,102,NULL
CREATE PROC [dbo].[spa_template_deal_field_format]  
@flag CHAR(1),  
@template_id INT,
@group_id INT = NULL ,
@deal_template_id INT=NULL,
@call_window INT=NULL  ---- if 1 then Call from Deal Template window 
AS  

DECLARE @sql VARCHAR(8000)
IF @call_window IS NULL
SET @call_window=-1

IF @flag = 'g'  
BEGIN  
	  
	SELECT field_group_id, group_name,REPLACE(group_name,' ','')+'_'+CAST(field_group_id AS VARCHAR) ID FROM maintain_field_template_group WHERE field_template_id=@template_id  
	ORDER BY seq_no   

END  
 
IF @flag = 'f'   -- Source Deal Header
BEGIN   
	--- call from Template window then return only those fields which are in Deal Templates
	IF @call_window=1 
	BEGIN 
		SELECT column_name INTO #temp_header FROM INFORMATION_SCHEMA.Columns where TABLE_NAME = 'source_deal_header_template' 
	END
	
	set @sql = 'select * from ( SELECT lower(f.farrms_field_id) farrms_field_id ,field_group_id,
		ISNULL(d.field_caption,f.default_label) default_label
		  ,ISNULL(f.field_type,''t'') field_type
		  ,f.[data_type]
		  ,f.[default_validation]
		  ,f.[header_detail]
		  ,f.[system_required]
		  ,f.[sql_string]
		  ,f.[field_size]
		  ,case when '+cast(@call_window as varchar) +'=1 then ''n'' else  COALESCE(d.is_disable,f.[is_disable],''n'') end is_disable
		  ,f.window_function_id
		  ,''s'' udf_or_system
		  ,case when isNULL(d.hide_control,''n'')=''y'' then d.seq_no+ 100 else d.seq_no end seq_no 
		  ,isNULL(d.hide_control,''n'') hide_control
		  ,d.default_value
		  ,cast(f.field_id as varchar) field_id
	FROM maintain_field_template_detail d JOIN maintain_field_deal f ON d.field_id=f.field_id'   
	IF @call_window=1
	begin 
		set @sql = @sql + '	join #temp_header t on case when t.column_name=''buy_sell_flag'' then ''header_buy_sell_flag'' else t.column_name end  =f.farrms_field_id '
	end 
	set @sql = @sql + '	WHERE field_group_id is not null and f.header_detail=''h'' AND ISNULL(d.udf_or_system,''s'')=''s''  AND d.field_template_id = ' + cast(@template_id AS VARCHAR)  

	IF @group_id IS NOT NULL
		set @sql = @sql + ' AND d.field_group_id = ' + cast(@group_id AS VARCHAR)
		
	set @sql = @sql + '	
	UNION ALL 	
	SELECT ''UDF___''+CAST(udf_template_id AS VARCHAR) udf_template_id,field_group_id,
	ISNULL(mftd.field_caption,udf_temp.Field_label) default_label
	,isnull(udf_temp.field_type,''t'') field_type
	,udf_temp.[data_type]
	,NULL [default_validation]
	,''h'' header_detail
	,udf_temp.is_required [system_required]
	,udf_temp.[sql_string]
	,udf_temp.[field_size]
	,isNull(mftd.is_disable,''n'')  
	,NULL window_function_id
	,''u'' udf_or_system
	,case when isNULL(mftd.hide_control,''n'')=''y'' then mftd.seq_no+ 100 else mftd.seq_no end seq_no 
	,isNULL(mftd.hide_control,''n'') hide_control
	, mftd.default_value
	,''u--''+cast(mftd.field_id as varchar) field_id
	FROM  user_defined_deal_fields_template udf_temp
	JOIN maintain_field_template_detail mftd 
	on udf_temp.udf_user_field_id=mftd.field_id and udf_temp.template_id='+cast(@deal_template_id as varchar) +'
	AND mftd.field_template_id =' + cast(@template_id AS VARCHAR) +'
	AND ISNULL(mftd.udf_or_system,''s'')=''u'' 
	WHERE field_group_id is not null and  udf_temp.udf_type=''h'''
	
	IF @group_id IS NOT NULL
		set @sql = @sql + ' AND mftd.field_group_id = ' + cast(@group_id AS VARCHAR)
		
	set @sql = @sql + ') a ORDER BY field_group_id,ISNULL(a.seq_no,10000),default_label' 
	print(@sql)
	EXEC(@sql)
  
END   
IF @flag = 'd'   --- Source Deal Detail
BEGIN   
	IF @call_window=1 
	BEGIN 
		SELECT column_name INTO #temp_detail FROM INFORMATION_SCHEMA.Columns where TABLE_NAME = 'source_deal_detail_template' 
	END
	set @sql = ' select * from ('
	
	IF @call_window=1
	begin 
		set @sql = @sql + '
	SELECT ''template_detail_id'' farrms_field_id,null field_group_id,''ID'' default_label
		  ,''t'' field_type
		  ,null [data_type]
		  ,null [default_validation]
		  ,''d'' [header_detail]
		  ,NULL [system_required]
		  ,NULL [sql_string]
		  ,NULL [field_size]
		  ,''y'' [is_disable]
		  ,null window_function_id
		  ,''s'' udf_or_system
		  ,-1 seq_no 
		  , ''n'' hide_control
		 Union all  
		   '
	END 	  
	set @sql = @sql + '
	SELECT lower(f.farrms_field_id) farrms_field_id,field_group_id,ISNULL(d.field_caption,f.default_label) default_label
		  ,ISNULL(f.field_type,''t'') field_type
		  ,f.[data_type]
		  ,f.[default_validation]
		  ,f.[header_detail]
		  ,f.[system_required]
		  ,f.[sql_string]
		  ,f.[field_size]
		  ,COALESCE(d.is_disable,f.[is_disable],''n'') is_disable
		  ,f.window_function_id
		  ,''s'' udf_or_system
		  ,d.seq_no
		  ,isNULL(d.hide_control,''n'') hide_control
	FROM maintain_field_template_detail d JOIN maintain_field_deal f ON d.field_id=f.field_id  '
	IF @call_window=1
	begin 
		set @sql = @sql + '	join #temp_detail t on t.column_name=f.farrms_field_id '
	end  
	set @sql = @sql + ' WHERE f.header_detail=''d'' AND d.field_template_id = ' + cast(@template_id AS VARCHAR)  
	
	set @sql = @sql + '
		UNION ALL 	
	SELECT ''UDF___''+CAST(udf_template_id AS VARCHAR) udf_template_id,field_group_id,
	ISNULL(mftd.field_caption,udf_temp.Field_label) default_label
	,isnUll(udf_temp.field_type,''t'') field_type
	,udf_temp.[data_type]
	,NULL [default_validation]
	,''d'' header_detail
	,udf_temp.is_required [system_required]
	,udf_temp.[sql_string]
	,udf_temp.[field_size]
	,isNUll(mftd.is_disable,''n'')  
	,NULL window_function_id
	,''u'' udf_or_system
	,mftd.seq_no
	,''n'' hide_control
	FROM user_defined_deal_fields_template udf_temp
	JOIN maintain_field_template_detail mftd 
	ON mftd.field_id = udf_temp.udf_user_field_id  and udf_temp.template_id='+cast(@deal_template_id as varchar) +'
	AND mftd.field_template_id =' + cast(@template_id AS VARCHAR) +'
	AND ISNULL(mftd.udf_or_system,''s'')=''u'' 
	WHERE udf_temp.udf_type=''d'''
	
	set @sql = @sql + ')l ORDER BY ISNULL(l.seq_no,10000),default_label' 
	
	exec(@sql)
  
END 
IF @flag = 'e'
BEGIN
	
	SELECT lower(mfd.farrms_field_id) farrms_field_id,field_group_id,ISNULL(mftd.field_caption,mfd.default_label) default_label
	,ISNULL(mfd.field_type,'t') field_type
	,mfd.[data_type]
	,mfd.[default_validation]
	,mfd.[header_detail]
	,mfd.[system_required]
	,mfd.[sql_string]
	,mfd.[field_size]
	,mfd.[is_disable]
	,mfd.window_function_id
	FROM maintain_field_template_detail mftd INNER JOIN maintain_field_deal mfd ON mftd.field_id = mfd.field_id
		WHERE mfd.header_detail='h' AND mftd.field_template_id = @template_id  AND mftd.field_group_id <> @group_id

END

IF @flag = 'b' -- template properties Header
BEGIN
	SELECT * FROM (
	SELECT lower(mfd.farrms_field_id) farrms_field_id,
	ISNULL(field_group_id,-1) field_group_id,ISNULL(mftd.field_caption,mfd.default_label) default_label
	,mftd.seq_no
	,ISNULL(mfd.field_type,'t') field_type
	,mfd.[data_type]
	,mftd.[validation_id]
	,mfd.[header_detail]
	,mfd.[system_required]
	,mfd.[sql_string]
	,mfd.[field_size]
	,mfd.[is_disable] system_is_disable
	,mfd.window_function_id
	,field_template_detail_id
	,'s' udf_or_system
	,mftd.is_disable 
	,mftd.insert_required
	,isNULL(mftd.hide_control,'n') hide_control
	,mftd.default_value 
	,mftd.min_value
	,mftd.max_value
	FROM maintain_field_deal mfd LEFT outer JOIN maintain_field_template_detail mftd 
	ON mftd.field_id = mfd.field_id 
	AND mftd.field_template_id = @template_id 
	AND ISNULL(mftd.udf_or_system,'s')='s' 
	WHERE mfd.header_detail='h' 
	UNION ALL 	
	SELECT 'UDF___'+CAST(udf_template_id AS VARCHAR) udf_template_id,ISNULL(field_group_id,-1) field_group_id,
	ISNULL(mftd.field_caption,udf_temp.Field_label) default_label
	,mftd.seq_no
	,ISNULL(udf_temp.field_type,'t') field_type
	,udf_temp.[data_type]
	,mftd.[validation_id]
	,udf_temp.udf_type
	,udf_temp.is_required [system_required]
	,udf_temp.[sql_string]
	,udf_temp.[field_size]
	,NULL system_is_disable
	,NULL window_function_id
	,ISNULL(field_template_detail_id,-1)  field_template_detail_id
	,'u' udf_or_system
	,mftd.is_disable 
	,mftd.insert_required
	,isNULL(mftd.hide_control,'n') hide_control
	,mftd.default_value 
	,mftd.min_value
	,mftd.max_value
	FROM user_defined_fields_template udf_temp
	LEFT outer JOIN maintain_field_template_detail mftd 
	ON mftd.field_id = udf_temp.udf_template_id 
	AND mftd.field_template_id = @template_id 
	AND ISNULL(mftd.udf_or_system,'s')='u' 
	WHERE udf_temp.udf_type='h' 
	) l 
	ORDER BY field_group_id,ISNULL(l.seq_no,10000),default_label
	
END
IF @flag = 'p' -- template properties detail
BEGIN
	SELECT * FROM (
	SELECT lower(mfd.farrms_field_id) farrms_field_id,
	ISNULL(field_group_id,-1) field_group_id,ISNULL(mftd.field_caption,mfd.default_label) default_label
	,mftd.seq_no
	,mfd.[system_required]
	,mfd.[data_type]
	,mfd.[is_disable] system_is_disable
	,mftd.is_disable 
	,mftd.insert_required
	,mftd.default_value
	,mftd.min_value
	,mftd.max_value
	,mftd.validation_id	
	,ISNULL(field_template_detail_id,-1) field_template_detail_id
	,'s' udf_or_system
	,mfd.[sql_string]
	,mfd.[field_size]
	,isNULL(mftd.hide_control,'n') hide_control
	FROM maintain_field_deal mfd LEFT outer JOIN maintain_field_template_detail mftd 
	ON mftd.field_id = mfd.field_id AND mftd.field_template_id = @template_id 
	AND ISNULL(mftd.udf_or_system,'s')='s'
	WHERE mfd.header_detail='d' 
	
	UNION ALL 	
	SELECT 'UDF___'+CAST(udf_template_id AS VARCHAR) udf_template_id,ISNULL(field_group_id,-1) field_group_id,
	ISNULL(mftd.field_caption,udf_temp.Field_label) default_label
	,mftd.seq_no
	,udf_temp.is_required
	,udf_temp.[data_type]
	,NULL system_is_disable
	,mftd.is_disable 
	,mftd.insert_required
	,ISNULL(mftd.default_value,udf_temp.default_value)  default_value
	,mftd.min_value
	,mftd.max_value
	,NULL [default_validation]
	,ISNULL(field_template_detail_id,-1)  field_template_detail_id
	,'u' udf_or_system
	,udf_temp.[sql_string]
	,udf_temp.[field_size]
	,isNULL(mftd.hide_control,'n') hide_control
	FROM user_defined_fields_template udf_temp
	LEFT outer JOIN maintain_field_template_detail mftd 
	ON mftd.field_id = udf_temp.udf_template_id 
	AND mftd.field_template_id = @template_id 
	AND ISNULL(mftd.udf_or_system,'s')='u' 
	WHERE udf_temp.udf_type='d' 
	)l 
	ORDER BY ISNULL(l.seq_no,10000),default_label

END

IF @flag = 'm' -- Blotter Inter
BEGIN

	SELECT @template_id=field_template_id FROM dbo.source_deal_header_template WHERE template_id=@deal_template_id 

 --ROW_NUMBER() OVER(ORDER BY header_detail DESC,field_group_id,ISNULL(l.seq_no,10000)) row_id,
	SELECT * FROM (
	SELECT lower(mfd.farrms_field_id) farrms_field_id,
	ISNULL(field_group_id,-1) field_group_id,ISNULL(mftd.field_caption,mfd.default_label) default_label
	,mftd.seq_no
	,ISNULL(mfd.field_type,'t') field_type
	,mfd.[data_type]
	,mftd.[validation_id]
	,mfd.[header_detail]
	,mfd.[system_required]
	,mfd.[sql_string]
	,mfd.[field_size]
	,mfd.[is_disable] system_is_disable
	,mfd.window_function_id
	,field_template_detail_id
	,'s' udf_or_system
	,mftd.is_disable 
	,mftd.insert_required
	,isNULL(mftd.hide_control,'n') hide_control
	,mftd.default_value 
	,mftd.min_value
	,mftd.max_value
	,CAST(mftd.field_id AS VARCHAR) field_id
	FROM maintain_field_deal mfd JOIN maintain_field_template_detail mftd 
	ON mftd.field_id = mfd.field_id 
	AND mftd.field_template_id = @template_id 
	AND ISNULL(mftd.udf_or_system,'s')='s' 
	WHERE  mfd.farrms_field_id NOT IN ('source_deal_header_id','source_deal_detail_id','create_user','create_ts','update_user','update_ts','template_id')
	AND ISNULL(mftd.insert_required,'n')='y'
	UNION ALL 	
	SELECT 'UDF___'+CAST(udf_template_id AS VARCHAR) udf_template_id,ISNULL(field_group_id,-1) field_group_id,
	ISNULL(mftd.field_caption,udf_temp.Field_label) default_label
	,mftd.seq_no
	,ISNULL(udf_temp.field_type,'t') field_type
	,udf_temp.[data_type]
	,mftd.[validation_id]
	,udf_temp.udf_type
	,udf_temp.is_required [system_required]
	,udf_temp.[sql_string]
	,udf_temp.[field_size]
	,NULL system_is_disable
	,NULL window_function_id
	,ISNULL(field_template_detail_id,-1)  field_template_detail_id
	,'u' udf_or_system
	,mftd.is_disable 
	,mftd.insert_required
	,isNULL(mftd.hide_control,'n') hide_control
	,mftd.default_value 
	,mftd.min_value
	,mftd.max_value
	,'u--'+CAST(udf_temp.udf_template_id AS VARCHAR) 
	FROM user_defined_fields_template udf_temp
	JOIN maintain_field_template_detail mftd 
	ON mftd.field_id = udf_temp.udf_template_id 
	AND mftd.field_template_id = @template_id 
	AND ISNULL(mftd.udf_or_system,'s')='u' 
	WHERE ISNULL(mftd.insert_required,'n')='y'
	) l 
	ORDER BY header_detail DESC,field_group_id,ISNULL(l.seq_no,10000)
	
END


GO

/****** Object:  StoredProcedure [dbo].[spa_sourcedealheader]    Script Date: 12/06/2011 23:36:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROC [dbo].[spa_sourcedealheader]
@flag CHAR(1),
@book_deal_type_map_id VARCHAR(200) = NULL, 
@deal_id_from INT = NULL, 
@deal_id_to INT = NULL, 
@deal_date_from VARCHAR(10) = NULL, 
@deal_date_to VARCHAR(10) = NULL,
@source_deal_header_id VARCHAR(MAX) = NULL,
@source_system_id INT = NULL,
@deal_id VARCHAR(50) = NULL,
@deal_date VARCHAR(50) = NULL,
@ext_deal_id VARCHAR(50) = NULL,
@physical_financial_flag CHAR(1) = NULL,
@structured_deal_id VARCHAR(50) = NULL,
@counterparty_id INT = NULL,
@entire_term_start VARCHAR(10) = NULL,
@entire_term_end VARCHAR(10) = NULL,
@source_deal_type_id INT = NULL,
@deal_sub_type_type_id INT = NULL,
@option_flag CHAR(1) = NULL,
@option_type CHAR(1) = NULL,
@option_excercise_type CHAR(1) = NULL,
@source_system_book_id1 INT = NULL,
@source_system_book_id2 INT = NULL,
@source_system_book_id3 INT = NULL,
@source_system_book_id4 INT = NULL,
@description1 VARCHAR(100) = NULL,
@description2 VARCHAR(100) = NULL,
@description3 VARCHAR(100) = NULL,
@deal_category_value_id INT = NULL,
@trader_id INT = NULL,
@internal_deal_type_value_id INT = NULL,
@internal_deal_subtype_value_id INT = NULL,
@book_id VARCHAR(MAX) = NULL,
@template_id INT = NULL,
@process_id VARCHAR(100) = NULL,
@header_buy_sell_flag VARCHAR(1) = NULL,
@broker_id INT = NULL,
--Added the following for REC deals
@generator_id INT = NULL ,
@gis_cert_number VARCHAR(250) = NULL ,
@gis_value_id INT = NULL ,
@gis_cert_date VARCHAR(10) = NULL ,
@gen_cert_number VARCHAR(250) = NULL ,
@gen_cert_date VARCHAR(10) = NULL ,
@status_value_id INT = NULL,
@status_date DATETIME = NULL ,
@assignment_type_value_id INT = NULL ,
@compliance_year INT = NULL ,
@state_value_id INT = NULL ,
@assigned_date DATETIME = NULL ,
@assigned_by VARCHAR(50) = NULL, 
@gis_cert_number_to VARCHAR(250) = NULL,
@generation_source VARCHAR(250) = NULL,
@aggregate_environment CHAR(1) = 'n',
@aggregate_envrionment_comment VARCHAR(250) = NULL,
@rec_price FLOAT = NULL,
@rec_formula_id INT = NULL,
@rolling_avg CHAR(1) = NULL,
@sort_by CHAR(1) = 'l',
@certificate_from FLOAT = NULL,
@certificate_to FLOAT = NULL,
@certificate_date VARCHAR(20) = NULL,
@contract_id INT = NULL,
@legal_entity INT = NULL,
@bifurcate_leg INT = NULL,
@refrence VARCHAR(500) = NULL,
@source_commodity INT = NULL,
@source_internal_portfolio INT = NULL,
@source_product INT = NULL,
@source_internal_desk INT = NULL,
@deal_locked CHAR(1) = NULL,
@block_type INT = NULL,
@block_define_id INT = NULL,
@granularity_id INT = NULL,
@pricing INT = NULL,
@description4 VARCHAR(100) = NULL,
@update_date_from DATETIME = NULL,
@update_date_to DATETIME = NULL,
@update_by VARCHAR(50) = NULL,
@confirm_type VARCHAR(10) = NULL,
@created_date_from DATETIME = NULL,
@created_date_to DATETIME = NULL,
@unit_fixed_flag CHAR(1) = NULL,
@broker_unit_fees FLOAT = NULL,
@broker_fixed_cost FLOAT = NULL,
@broker_currency_id INT = NULL,
@deal_status INT = NULL,
@option_settlement_date DATETIME = NULL,
@signed_off_flag CHAR(1) = NULL,
@signed_off_by CHAR(1) = NULL,
@broker VARCHAR(100) = NULL,
@blotter CHAR(1) = NULL,
@index_group INT = NULL,
@location INT = NULL,
@index INT = NULL,
@commodity INT = NULL,
@udf_template_id_list VARCHAR(MAX) = NULL,
@udf_value_list VARCHAR(MAX) = NULL,
@user_action VARCHAR(100) = NULL,
@comments VARCHAR(1000) = NULL,
---- Added for multiple selection in of book_id
@sub_entity_id VARCHAR(100) = NULL,
@strategy_entity_id VARCHAR(100) = NULL,
@book_entity_id VARCHAR(100) = NULL,
@deleted_deal VARCHAR(1) = 'n',
@refrence_deal VARCHAR(500) = NULL


AS

--select @confirm_type '@confirm_type'
--select @sort_by,@aggregate_envrionment_comment
--return
SET NOCOUNT ON
DECLARE @sql_Select                  VARCHAR(MAX)
DECLARE @sql                         VARCHAR(MAX)
DECLARE @copy_source_deal_header_id  INT
DECLARE @starategy_id                VARCHAR(1000)
DECLARE @sub_id                      INT
DECLARE @temp_count                  INT
DECLARE @temp_count1                 INT
DECLARE @tempheadertable             VARCHAR(100)
DECLARE @tempdetailtable             VARCHAR(100)
DECLARE @user_login_id               VARCHAR(100)
DECLARE @SPOT_DEAL                   INT
DECLARE @sign_off_date_field VARCHAR(50),@time_zone_from INT,@time_zone_to int
        --DECLARE @source_deal_header VARCHAR(50),@source_deal_detail VARCHAR(50)




IF @book_entity_id IS NULL
    SET @book_entity_id = @book_id

SET @SPOT_DEAL = 1
SET @user_login_id = dbo.FNADBUser()

IF @update_date_to IS NOT NULL
BEGIN
    SET @update_date_to = DATEADD(dd, DATEDIFF(dd, 0, @update_date_to) + 1, 0)
END

--CREATE TABLE #source_system (source_system_id INT) 

SELECT * into #tmp_source_deal_header_id FROM  SplitCommaSeperatedValues(@source_deal_header_id)

SELECT @time_zone_from= var_value  FROM adiha_default_codes_values  
	 WHERE  (instance_no = 1) AND (default_code_id = 36) AND (seq_no = 1)  
  
SELECT @time_zone_to=timezone_id from application_users where user_login_id=@user_login_id
DECLARE @group1 VARCHAR(100),@group2 VARCHAR(100),@group3 VARCHAR(100),@group4 VARCHAR(100)

DECLARE @Sql_Where_S   VARCHAR(5000)
DECLARE @Sql_Select_S  VARCHAR(5000)

CREATE TABLE #books ( fas_book_id int,book_deal_type_map_id INT,source_system_book_id1 int,source_system_book_id2 INT,source_system_book_id3 INT,source_system_book_id4  int,fas_deal_type_value_id int) 
--SET @sql_Select=

--	'INSERT INTO  #source_system

--	SELECT distinct fs.source_system_id FROM portfolio_hierarchy book (nolock) INNER JOIN

--	Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id LEFT OUTER JOIN            

--			source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id         
--			LEFT OUTER JOIN fas_strategy fs ON fs.fas_strategy_id=stra.entity_id
--	WHERE (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401) '
--	+CASE WHEN  @sub_id IS NOT NULL THEN  ' AND stra.parent_entity_id IN  ( ' + CAST(@sub_entity_id AS VARCHAR) + ') '  ELSE '' END
--	+CASE WHEN  @starategy_id IS NOT NULL THEN  ' AND stra.entity_id IN  ( ' +  CAST(@strategy_entity_id AS VARCHAR) + ') '  ELSE '' END
--	+CASE WHEN  @book_id IS NOT NULL THEN  ' AND book.entity_id IN  ( ' +  CAST(@book_id AS VARCHAR) + ') '  ELSE '' END
--	+CASE WHEN @book_deal_type_map_id IS NOT NULL THEN 'AND ssbm.book_deal_type_map_id IN  ( ' + @book_deal_type_map_id + ') ' ELSE '' END 

--EXEC (@sql_Select)

SET @Sql_Select_S = '
	INSERT INTO #books
	SELECT  distinct ssbm.fas_book_id,ssbm.book_deal_type_map_id fas_book_id,source_system_book_id1,
		source_system_book_id2,source_system_book_id3,source_system_book_id4,ssbm.fas_deal_type_value_id FROM portfolio_hierarchy book (nolock) INNER JOIN
	Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id LEFT OUTER JOIN            
	source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id         
	WHERE  1 = 1'   

SET @Sql_Where_S=''
/*
IF @deal_id_from IS NOT NULL
	OR @deal_id_to IS NOT NULL
	OR @deal_id IS NOT NULL 
BEGIN
    SET @sub_entity_id = NULL
    SET @strategy_entity_id = NULL
    SET @book_entity_id = NULL
END */
      
IF @sub_entity_id IS NOT NULL 
	SET @Sql_Where_S = @Sql_Where_S + ' AND stra.parent_entity_id IN  ( '
		+ @sub_entity_id + ') '         
IF @strategy_entity_id IS NOT NULL 
	SET @Sql_Where_S = @Sql_Where_S + ' AND (stra.entity_id IN('
		+ @strategy_entity_id + ' ))'        
IF @book_entity_id IS NOT NULL 
	SET @Sql_Where_S = @Sql_Where_S + ' AND (book.entity_id IN('
		+ @book_entity_id + ')) '  
		      
IF (@source_system_book_id1 IS NOT NULL)
	SET @Sql_Where_S = @Sql_Where_S +' AND ssbm.source_system_book_id1 ='+CAST(@source_system_book_id1 AS VARCHAR)

IF (@source_system_book_id2 IS NOT NULL)
	SET @Sql_Where_S = @Sql_Where_S +' AND ssbm.source_system_book_id2=  '+CAST(@source_system_book_id2 AS VARCHAR)

IF (@source_system_book_id3 IS NOT NULL)
	SET @Sql_Where_S = @Sql_Where_S +' AND ssbm.source_system_book_id3 = '+CAST(@source_system_book_id3 AS VARCHAR)

IF (@source_system_book_id4 IS NOT NULL)
	SET @Sql_Where_S = @Sql_Where_S +' AND ssbm.source_system_book_id4 = '+CAST(@source_system_book_id4 AS VARCHAR)

IF @book_deal_type_map_id IS NOT NULL
	SET @Sql_Where_S = @Sql_Where_S +' AND ssbm.book_deal_type_map_id = '+CAST(@book_deal_type_map_id AS VARCHAR)


SET @Sql_Select_S = @Sql_Select_S + @Sql_Where_S
PRINT @Sql_Select_S
EXEC (@Sql_Select_S)


--IF OBJECT_ID(N'adiha_process.dbo.audit_books', N'U') IS NOT NULL
--	DROP TABLE adiha_process.dbo.audit_books
	
--IF OBJECT_ID(N'adiha_process.dbo.audit_books', N'U') IS NULL
--BEGIN
--	CREATE TABLE adiha_process.dbo.audit_books
--	(
--		fas_book_id             INT,
--		book_deal_type_map_id   INT,
--		source_system_book_id1  INT,
--		source_system_book_id2  INT,
--		source_system_book_id3  INT,
--		source_system_book_id4  INT,
--		fas_deal_type_value_id  INT
--	)
--END
--INSERT INTO adiha_process.dbo.audit_books SELECT * FROM #books


IF EXISTS(SELECT group1,group2,group3,group4 FROM source_book_mapping_clm)
BEGIN	
	SELECT @group1=group1,@group2=group2,@group3=group3,@group4=group4 FROM source_book_mapping_clm
END
ELSE
BEGIN
	SET @group1='Group1'
	SET @group2='Group2'
	SET @group3='Group3'
	SET @group4='Group4'
 
END
--SELECT @book_id=fas_book_id FROM #books WHERE book_deal_type_map_id=@book_deal_type_map_id
--SELECT @starategy_id= parent_entity_id FROM portfolio_hierarchy WHERE entity_id IN (@book_id)
--SELECT @sub_id= parent_entity_id FROM portfolio_hierarchy WHERE entity_id=@starategy_id	


PRINT @confirm_type
PRINT @blotter


--Declare @book_id intBegin
IF @flag='f' --use in deal copy
BEGIN
	
	SELECT MAX(sdh.term_frequency) AS frequency,
	       MAX(sdd.deal_volume) AS volume,
	       [dbo].FNAGetGenericDate(MIN(sdd.term_start), @user_login_id) AS 
	       term_start,
	       [dbo].FNAGetGenericDate(MAX(sdd.term_end), @user_login_id) AS 
	       term_end
	FROM   source_deal_detail sdd
	       INNER JOIN dbo.source_deal_header sdh
	            ON  sdd.source_deal_header_id = sdh.source_deal_header_id
	            AND sdd.source_deal_header_id = ISNULL(@source_deal_header_id, sdd.source_deal_header_id)
	       LEFT JOIN dbo.source_deal_header_template t
	            ON  t.template_id = sdh.template_id
	WHERE  --		source_deal_header_id=@source_deal_header_id
	       --		and 
	       leg = CASE 
	                  WHEN @bifurcate_leg IS NOT NULL THEN @bifurcate_leg
	                  ELSE leg
	             END
END 	 
IF @flag='s'  
	BEGIN

	SET @sql_Select = 
			'
--SELECT [ID],[RefID] AS [Ref ID],[dbo].FNAGetGenericDate(deal_date, '''+@user_login_id+''') as [Deal Date],[ExtId] AS [Ext ID],[PhysicalFinancialFlag] AS [Physical/Financial Flag] ,[CptyName] AS [Counterparty],
--					[TermStart] AS [Term Start] ,[TermEnd] AS [Term End] ,[DealType] AS [Deal Type],[DealSubType] AS [Deal Sub Type], [OptionFlag] AS [Option Flag],[OptionType] AS [Option Type],[ExcerciseType] AS [Exercise Type],
--					['+ @group1 +'],['+ @group2 +']   ,['+ @group3 +'],['+ @group4 +'],[Desc1],[Desc2],[Desc3],
--					[DealCategoryValueId] AS [Deal Category],[TraderName] AS [Trader Name],[HedgeItemFlag] AS [Hedge/Item Flag],[HedgeType] AS [Hedge Type],[AssignType] AS [Assign Type],[legal_entity] AS [Legal Entity],
--					[deal_locked] AS [Deal Lock], [Pricing],[Created Date],ConfirmStatus AS [Confirm Status],[Signed Off By],[Sign Off Date] as [Signed Off Date], [Broker],[comments]
--					
--			FROM (
			SELECT  DISTINCT
					dh.source_deal_header_id AS ID,
					dh.deal_id AS [Ref ID],
					dbo.FNADateFormat(dh.deal_date) [Deal Date],
 					dh.ext_deal_id as [Ext ID],
					CASE WHEN dh.physical_financial_flag =''p'' THEN ''Physical'' ELSE ''Financial'' END	as [Physical/Financial Flag], 
					source_counterparty.counterparty_name [Counterparty],
					--[dbo].FNAGetGenericDate(dh.entire_term_start,'''+@user_login_id+''') as [Term Start], 
					--[dbo].FNAGetGenericDate(dh.entire_term_end,'''+@user_login_id+''') As [Term End], 
					dbo.FNADateFormat(dh.entire_term_start) [Entire Term Start],
					dbo.FNADateFormat(dh.entire_term_end) [Entire Term End],
					source_deal_type.source_deal_type_name As [Deal Type] , 
					source_deal_type_1.source_deal_type_name AS [Deal Sub Type],
					[dbo].FNAGetAbbreviationDef(dh.option_flag) As [Option Flag],
					[dbo].FNAGetAbbreviationDef(dh.option_type) As [Option Type], 
					[dbo].FNAGetAbbreviationDef(dh.option_excercise_type) As [Excercise Type],
					source_book.source_book_name As ['+ @group1 +'], 
					source_book_1.source_book_name AS ['+ @group2 +'],
					source_book_2.source_book_name AS ['+ @group3 +'], 
					source_book_3.source_book_name AS ['+ @group4 +'],
					dh.description1 As [Description 1], 
					dh.description2 As [Description 2],
					dh.description3 as [Description 3],
					static_data_value4.code as [Deal Category],
					source_traders.trader_name as [Trader],
					static_data_value1.code as [Hedge/Item Flag],
					static_data_value2.code as  [Hedge Type],
					CASE WHEN header_buy_sell_flag=''s'' AND assignment_type_value_id is not null THEN sdv.code else 	
							CASE WHEN header_buy_sell_flag=''s'' AND assignment_type_value_id is null THEN ''Sold'' else ''Banked'' end
					END [Assign Type],
					dh.legal_entity [Legal Entity],
				(
					CASE WHEN deal_locked = ''y'' THEN ''Yes''
					ELSE 
						CASE WHEN ISNULL(dl_specific.id, dl_generic.id) IS NOT NULL THEN
							CASE WHEN DATEADD(mi, ISNULL(dl_specific.mins, dl_generic.mins), ISNULL(dh.update_ts, dh.create_ts)) < GETDATE() THEN ''Yes'' ELSE ''No'' END
						ELSE ''No''
						END
					END
				) AS [Deal Locked] ,				
				static_data_value3.code [Pricing],
				--[dbo].FNAConvertGenericTimezone(dh.create_ts,'+ISNULL(cast(@time_zone_from AS VARCHAR), 'NULL') +','+ ISNULL(CAST(@time_zone_to AS VARCHAR), 'NULL') + ','''+@user_login_id+''',0) as [Created Date]
				dbo.FNADateTimeFormat(dh.create_ts,2) [Create TS],				
				sdv_confirm.code [Confirm Status],
				dh.verified_by [Signed Off By],
				--[dbo].FNAGetGenericDate(dh.verified_date,'''+@user_login_id+''') [Sign Off Date],
				dh.verified_date [Verified Date],
				scp.counterparty_name AS [Broker],
				t.comments [Comments]
		
			FROM   ' +CASE WHEN isnull(@deleted_deal,'n')='y' then  'delete_source_deal_header' ELSE 'source_deal_header' END +' dh '+
			
			CASE WHEN  (@deal_id_from IS  NULL or @deal_id_to IS  NULL) AND @source_deal_header_id IS NOT NULL 
					THEN ' inner join #tmp_source_deal_header_id t_dh on t_dh.item=dh.source_deal_header_id '
				 ELSE '' 
			END +
		' --INNER JOIN #source_system ss ON ss.source_system_id=dh.source_system_id
			 INNER JOIN #books ' + 
			-- CASE WHEN  @deal_id_from IS NULL AND @deal_id IS NULL THEN 	' #books ' 	ELSE ' source_system_book_map ' END +
		'
			sbmp ON dh.source_system_book_id1 = sbmp.source_system_book_id1 
			AND dh.source_system_book_id2 = sbmp.source_system_book_id2 
			AND dh.source_system_book_id3 = sbmp.source_system_book_id3 
			AND dh.source_system_book_id4 = sbmp.source_system_book_id4 			
			LEFT OUTER JOIN source_counterparty ON dh.counterparty_id = source_counterparty.source_counterparty_id 
			LEFT OUTER JOIN source_counterparty AS scp ON dh.broker_id = scp.source_counterparty_id 
			LEFT OUTER JOIN source_traders ON dh.trader_id = source_traders.source_trader_id 
			LEFT OUTER JOIN source_deal_type ON dh.source_deal_type_id = source_deal_type.source_deal_type_id 
			LEFT OUTER JOIN source_book ON dh.source_system_book_id1 = source_book.source_book_id 
			LEFT OUTER JOIN source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id 
			LEFT OUTER JOIN source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id 
			LEFT OUTER JOIN source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id 
			LEFT OUTER JOIN  portfolio_hierarchy ON portfolio_hierarchy.entity_id = sbmp.fas_book_id
			LEFT OUTER JOIN fas_strategy ON fas_strategy.fas_strategy_id=portfolio_hierarchy.parent_entity_id
			LEFT OUTER JOIN static_data_value  static_data_value1 ON sbmp.fas_deal_type_value_id=static_data_value1.value_id
			LEFT OUTER JOIN static_data_value  static_data_value2 ON fas_strategy.hedge_type_value_id=static_data_value2.value_id
			LEFT OUTER JOIN static_data_value  static_data_value3 ON static_data_value3.value_id = dh.pricing
			LEFT OUTER JOIN static_data_value  static_data_value4 ON static_data_value4.value_id = dh.deal_category_value_id
			LEFT OUTER JOIN static_data_value  static_data_value5 ON static_data_value5.value_id = dh.deal_status
			
			LEFT OUTER JOIN source_deal_type source_deal_type_1 ON dh.deal_sub_type_type_id = source_deal_type_1.source_deal_type_id 
			LEFT OUTER JOIN fas_link_detail fld ON fld.source_deal_header_id = dh.source_deal_header_id 
			LEFT OUTER JOIN static_data_value sdv ON sdv.value_id=dh.assignment_type_value_id
			LEFT OUTER JOIN rec_generator rg ON rg.generator_id=dh.generator_id ' +
			CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) OR (@gis_cert_date IS NOT NULL) OR (@location IS NOT NULL) OR (@index_group IS NOT null) OR (@index IS NOT NULL)
			THEN
				' LEFT OUTER JOIN ' +CASE WHEN isnull(@deleted_deal,'n')='y' then  'delete_source_deal_detail' ELSE 'source_deal_detail' END +' sdd ON sdd.source_deal_header_id=dh.source_deal_header_id '
			ELSE '' END +
			
			CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) OR (@gis_cert_date IS NOT NULL)
				THEN
					' LEFT OUTER JOIN gis_certificate gis ON gis.source_deal_header_id=sdd.source_deal_detail_id'
				ELSE '' END +
			CASE WHEN (@index_group IS NOT null) OR (@index IS NOT NULL)
				THEN
					' LEFT OUTER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id'
				ELSE '' END +
			CASE WHEN (@location IS NOT NULL)
				THEN
					' LEFT OUTER JOIN source_minor_location sml ON sml.source_minor_location_id=sdd.location_id'
				ELSE '' END +
			'
			
			LEFT OUTER JOIN confirm_status_recent csr ON csr.source_deal_header_id = dh.source_deal_header_id
			LEFT OUTER JOIN static_data_value sdv_confirm ON sdv_confirm.value_id = ISNULL(csr.type,17200)
			LEFT OUTER JOIN dbo.source_deal_header_template t ON t.template_id=dh.template_id  
			LEFT OUTER JOIN dbo.source_deal_detail_template dt ON dt.template_id=dh.template_id
			LEFT OUTER JOIN source_commodity sc ON sc.source_commodity_id=dt.commodity_id
			LEFT OUTER JOIN static_data_value sdv2 ON sdv2.value_id=dh.block_type
			LEFT JOIN
			(
				SELECT MAX(id) id, deal_type_id, MIN(hour * 60 + minute) mins
				FROM deal_lock_setup dls
				INNER JOIN application_role_user aru ON dls.role_id = aru.role_id
				WHERE aru.user_login_id = dbo.FNADBUser() AND deal_type_id IS NOT NULL
				GROUP BY dls.deal_type_id
			) dl_specific ON source_deal_type.source_deal_type_id = dl_specific.deal_type_id AND ISNULL(dh.deal_locked, ''n'') <> ''y''
			LEFT JOIN
			(
				SELECT MAX(id) id, deal_type_id, MIN(hour * 60 + minute) mins
				FROM deal_lock_setup dls
				INNER JOIN application_role_user aru ON dls.role_id = aru.role_id
				WHERE aru.user_login_id = dbo.FNADBUser() AND deal_type_id IS NULL
				GROUP BY dls.deal_type_id
			) dl_generic ON ISNULL(dh.deal_locked, ''n'') <> ''y''
			 WHERE   1 = 1 ' 

		
		IF  (@deal_id_from IS not NULL and @deal_id_to IS  not NULL)   
		BEGIN 
			SET @sql_Select = @sql_Select +  ' AND dh.source_deal_header_id BETWEEN ' + CAST(@deal_id_from AS VARCHAR)  + ' AND ' + CAST(@deal_id_to AS VARCHAR) 
			IF (@deal_locked = 'l' )
				SET @sql_Select = @sql_Select + ' AND dh.deal_locked = ''y'''
		
			IF (@deal_locked = 'u' )
				SET @sql_Select = @sql_Select + ' AND (dh.deal_locked = ''n'' OR dh.deal_locked IS NULL)'
		END 
		

	--IF ONE deal id is known make the other the same
/*
		IF (@created_date_from IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dbo.FNAConvertTZAwareDateFormat(dh.create_ts,1)>='''+CONVERT(VARCHAR(10),@created_date_from,120) +''''
			
			--SET @sql_Select = @sql_Select +' AND convert(varchar(10),dh.create_ts,120)>='''+convert(varchar(10),@created_date_from,120) +''''

		IF (@created_date_to IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dbo.FNAConvertTZAwareDateFormat(dh.create_ts,1) <='''+CONVERT(VARCHAR(10),@created_date_to,120) +''''

*/

		IF (@created_date_from IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.create_ts>='''+CONVERT(VARCHAR(10),[dbo].[FNAConvertTimezone](@created_date_from,1),120) +''''
			
		IF (@created_date_to IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.create_ts <'''+CONVERT(VARCHAR(10),[dbo].[FNAConvertTimezone](@created_date_to+1,1),120) +''''






			--SET @sql_Select = @sql_Select +' AND convert(varchar(10),dh.create_ts,120) <='''+convert(varchar(10),@created_date_to,120) +''''



	IF @deal_id_to IS NULL AND @deal_id_from IS NOT NULL
		SET @deal_id_to = @deal_id_from

	IF @deal_id_from IS NULL AND @deal_id_to IS NOT NULL
		SET @deal_id_from = @deal_id_to

	IF (@deal_id_from IS NOT NULL) AND (@deal_id_to IS NOT NULL) 
		SET @sql_Select = @sql_Select + ' AND dh.source_deal_header_id BETWEEN ' + CAST(@deal_id_from AS VARCHAR)  + ' AND ' + CAST(@deal_id_to AS VARCHAR) 
	ELSE IF @source_deal_header_id IS NOT NULL
		SET @sql_Select = @sql_Select + ' AND dh.source_deal_header_id IN(' + @source_deal_header_id  +')'


	IF (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL)
		SET @sql_Select = @sql_Select +' AND ('+ @gis_cert_number + ' between gis.certificate_number_from_int   
		AND  gis.certificate_number_to_int AND ' +
			@gis_cert_number_to + ' between gis.certificate_number_from_int   
		AND  gis.certificate_number_to_int)'

	IF @deal_id IS NOT NULL 
			SET @sql_Select = @sql_Select + ' AND dh.deal_id like ''' + @deal_id + '%'''

	IF @deal_id_from IS NULL AND @deal_id IS NULL --only apply deal filters if deal id not given.
	BEGIN
		
		IF ISNULL(@blotter,'n')='y'
			SET @sql_Select = @sql_Select + ' AND blotter_supported =''y'''
		

		IF @index_group IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND spcd.index_group='+CAST(@index_group AS VARCHAR)

		IF @index IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND spcd.source_curve_def_id='+CAST(@index AS VARCHAR)
		

		IF @commodity IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND sc.source_commodity_id='+CAST(@commodity AS VARCHAR)

		
		IF @block_type IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND sdv2.value_id='+CAST(@block_type AS VARCHAR)
			
		IF @location IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND sml.source_minor_location_id='+CAST(@location AS VARCHAR)
		
		IF @deal_status IS NOT NULL 
			SET @sql_Select = @sql_Select + ' AND static_data_value5.value_id ='+CAST(@deal_status AS VARCHAR) 
	IF @confirm_type IS NOT NULL  -- exceptions)
		BEGIN
		
--			if (@confirm_type = 'n')
--				SET @sql_Select = @sql_Select +' AND csr.type IS NULL OR csr.type=''n'''
--			else
				SET @sql_Select = @sql_Select +' AND csr.type IN (' + @confirm_type + ') '
		END
	
--		IF @book_deal_type_map_id IS NOT NULL 
--			SET @sql_Select = @sql_Select + ' AND sbmp.book_deal_type_map_id in( ' + @book_deal_type_map_id + ')'

		IF (@deal_date_from IS NOT NULL) AND (@deal_date_to IS NOT NULL) 
			SET @sql_Select = @sql_Select + ' AND dh.deal_date BETWEEN '''+ @deal_date_from + ''' and ''' + @deal_date_to + ''''
		
		IF (@physical_financial_flag IS NOT NULL)
			SET @sql_Select = @sql_Select + ' AND dh.physical_financial_flag='''+@physical_financial_flag+''''
		
		IF (@counterparty_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.counterparty_id='+CAST(@counterparty_id AS VARCHAR)

		IF (@entire_term_start IS NOT NULL)
			SET @sql_Select = @sql_Select+ ' AND dh.entire_term_start>='''+@entire_term_start+''''

		IF (@entire_term_end IS NOT NULL)
			SET @sql_Select = @sql_Select+ ' AND dh.entire_term_end<='''+@entire_term_end+''''

		IF (@source_deal_type_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.source_deal_type_id='+CAST(@source_deal_type_id  AS VARCHAR)

		IF (@deal_sub_type_type_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.deal_sub_type_type_id='+CAST(@deal_sub_type_type_id  AS VARCHAR)

		IF (@deal_category_value_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.deal_category_value_id='+CAST(@deal_category_value_id  AS VARCHAR)

		IF (@trader_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.trader_id='+CAST(@trader_id  AS VARCHAR)

		IF (@description1 IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.description1 like ''%'+@description1+'%'''

		IF (@description2 IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.description2 like ''%'+@description2+'%'''

		IF (@description3 IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.description3 like ''%'+@description3+'%'''

		IF (@structured_deal_id  IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.structured_deal_id like ''%'+@structured_deal_id +'%'''

		IF (@header_buy_sell_flag IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.header_buy_sell_flag='''+ @header_buy_sell_flag + ''''


		--IF (@deal_locked IS NOT NULL )
			--SET @sql_Select = @sql_Select + ' AND dh.deal_locked='''+@deal_locked+''''	
		IF (@deal_locked = 'l' )
			SET @sql_Select = @sql_Select + ' AND dh.deal_locked = ''y'''
		
		IF (@deal_locked = 'u' )
			SET @sql_Select = @sql_Select + ' AND (dh.deal_locked = ''n'' OR dh.deal_locked IS NULL)'

		IF (@update_date_from IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.update_ts>='''+CAST(@update_date_from  AS VARCHAR)+''''

		IF (@update_date_to IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.update_ts<='''+CAST(@update_date_to  AS VARCHAR)+''''

		IF (@update_by IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.update_user='''+CAST(@update_by  AS VARCHAR)+''''
	

		----====Added the following filter for REC deals
		--print 'no' 

	--if one cert is known and other not known make the same		
	IF @gis_cert_number_to IS NULL AND @gis_cert_number IS NOT NULL
		SET @gis_cert_number_to = @gis_cert_number

	IF @gis_cert_number IS NULL AND @gis_cert_number_to IS NOT NULL
		SET @gis_cert_number = @gis_cert_number_to




	IF @gis_cert_number IS NULL 
	BEGIN

		IF (@generator_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.generator_id='+CAST(@generator_id  AS VARCHAR)
		IF (@status_value_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.status_value_id='+CAST(@status_value_id  AS VARCHAR)
		IF (@status_date IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.status_date='''+ dbo.FNAGetSQLStandardDate(@status_date) + ''''
		IF (@assignment_type_value_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND isnull(dh.assignment_type_value_id, 5149) ='+CAST(@assignment_type_value_id  AS VARCHAR)
		IF (@compliance_year IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.compliance_year='+CAST(@compliance_year  AS VARCHAR)
		IF (@state_value_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.state_value_id='+CAST(@state_value_id  AS VARCHAR)
		IF (@assigned_date IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.assigned_date='''+ dbo.FNAGetSQLStandardDate(@assigned_date) + ''''
		IF (@assigned_by IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.assigned_by='''+ @assigned_by + ''''
		IF @gis_value_id IS NOT NULL
			SET @sql_Select = @sql_Select +' AND rg.gis_value_id='+ CAST(@gis_value_id AS VARCHAR)
		IF @gen_cert_date IS NOT NULL
			SET @sql_Select = @sql_Select +' AND rg.registration_date='''+ @gen_cert_date +''''
		IF @gen_cert_number IS NOT NULL
			SET @sql_Select = @sql_Select +' AND rg.gis_account_number='''+ @gen_cert_number +''''
		IF @gis_cert_date IS NOT NULL
			SET @sql_Select = @sql_Select +' AND gis.gis_cert_date='''+ @gis_cert_date +''''

	END
	
	
	SET @sign_off_date_field = CASE @signed_off_by
		WHEN 't' THEN 'verified_date'
		WHEN 'r' THEN 'risk_sign_off_date'
		WHEN 'b' THEN 'back_office_sign_off_date'
	END 
	
	IF @signed_off_flag IS NOT NULL 
	BEGIN
		IF @signed_off_flag = 'y'
			SET @sql_Select = @sql_Select + ' AND dh.' + @sign_off_date_field + ' IS NOT NULL'
		ELSE IF @signed_off_flag = 'n'
			SET @sql_Select = @sql_Select + ' AND dh.' + @sign_off_date_field + ' IS NULL'
	END

	IF @broker IS NOT NULL 
	BEGIN
		SET @sql_Select = @sql_Select + ' AND dh.broker_id = ' + @broker
	END

	END	
	IF @sort_by='l'
		SET @sql_Select = @sql_Select +' order by id desc'
	ELSE
		SET @sql_Select = @sql_Select +' order by id asc'

		PRINT @sql_Select

		EXEC(@sql_Select)
		
		/*
		If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Source Deal Header  table', 
				'spa_sourcedealheader', 'DB Error', 
				'Failed to select source deal header record.', ''
		Else

		Exec spa_ErrorHandler 0, 'Source Deal Header  table', 
				'spa_sourcedealheader', 'Success', 
				'Source deal header record successfully selected.', ''
			*/
end


IF @flag='c'  
	BEGIN
	
		SET @sql_Select = 
			'SELECT [ID],[RefID] AS [Ref ID],[dbo].FNAGetGenericDate(deal_date, '''+@user_login_id+''') as [Deal Date],[ExtId] AS [Ext ID],[PhysicalFinancialFlag] AS [Physical/Financial Flag] ,[CptyName] AS [Counterparty],
					[TermStart] AS [Term Start] ,[TermEnd] AS [Term End] ,[DealType] AS [Deal Type],[DealSubType] AS [Deal Sub Type], [OptionFlag] AS [Option Flag],[OptionType] AS [Option Type],[ExcerciseType] AS [Exercise Type],
					['+ @group1 +'],['+ @group2 +']   ,['+ @group3 +'],['+ @group4 +'],[Desc1],[Desc2],[Desc3],
					[DealCategoryValueId] AS [Deal Category],[TraderName] AS [Trader Name],[HedgeItemFlag] AS [Hedge/Item Flag],[HedgeType] AS [Hedge Type],[AssignType] AS [Assign Type],
					[legal_entity] AS [Legal Entity],
					[deal_locked] AS [Deal Lock], [Pricing],[Created Date],ConfirmStatus AS [Confirm Status],[Signed Off By],[Sign Off Date] as [Signed Off Date], [Broker], NULL as [Comments]

			FROM (SELECT	distinct dh.source_deal_header_id AS ID,dh.deal_id AS RefID,dh.deal_date,
 						  dh.ext_deal_id as ExtId,
					CASE 
					WHEN dh.physical_financial_flag =''p'' THEN ''Physical''
						ELSE ''Financial''
					END	as PhysicalFinancialFlag, 
					source_counterparty.counterparty_name CptyName,[dbo].FNAGetGenericDate(dh.entire_term_start, '''+@user_login_id+''') as TermStart, 
					[dbo].FNAGetGenericDate(dh.entire_term_end, '''+@user_login_id+''') As TermEnd, source_deal_type.source_deal_type_name As DealType, 
					source_deal_type_1.source_deal_type_name AS DealSubType,dh.option_flag As OptionFlag, dh.option_type As OptionType, 
					dh.option_excercise_type As ExcerciseType,source_book.source_book_name As ['+ @group1 +'], 
					source_book_1.source_book_name AS ['+ @group2 +'],source_book_2.source_book_name AS ['+ @group3 +'], 
					source_book_3.source_book_name AS ['+ @group4 +'],dh.description1 As Desc1, dh.description2 As Desc2,
					dh.description3 as Desc3,static_data_value4.code as DealCategoryValueId,source_traders.trader_name as TraderName,
					static_data_value1.code as HedgeItemFlag,static_data_value2.code as  HedgeType,
					CASE 
					WHEN dh.header_buy_sell_flag=''s'' AND dh.assignment_type_value_id is not null 
					THEN sdv.code else 	
					CASE 
					WHEN dh.header_buy_sell_flag=''s'' AND dh.assignment_type_value_id is null 
					THEN ''Sold'' else ''Banked'' end
					END 
				AssignType,
				dh.legal_entity,
				(
					CASE WHEN dh.deal_locked = ''y'' THEN ''Yes''
					ELSE 
						CASE WHEN ISNULL(dl_specific.id, dl_generic.id) IS NOT NULL THEN
							CASE WHEN DATEADD(mi, ISNULL(dl_specific.mins, dl_generic.mins), ISNULL(dh.update_ts, dh.create_ts)) < GETDATE() THEN ''Yes'' ELSE ''No'' END
						ELSE ''No''
						END
					END
				) AS deal_locked				
				,static_data_value3.code [Pricing] --dh.pricing
				,[dbo].FNAGetGenericDate(dh.create_ts, '''+@user_login_id+''') as [Created Date]
				,sdv_confirm.code ConfirmStatus
				,dh.verified_by [Signed Off By]
				,[dbo].FNAGetGenericDate(dh.verified_date, '''+@user_login_id+''') [Sign Off Date]
				,scp.counterparty_name AS [Broker]
			FROM       source_deal_header_audit dh 

		INNER JOIN (
			SELECT source_deal_header_id,max(audit_id) [max_audit_id] from source_deal_header_audit WHERE 1=1 GROUP BY source_deal_header_id
		) dh1 ON dh1.source_deal_header_id = dh.source_deal_header_id 
			AND dh1.max_audit_id = dh.audit_id
		 INNER JOIN #books ' +
			-- CASE WHEN  @deal_id_from IS NULL AND @deal_id IS NULL THEN 	' #books ' 	ELSE ' source_system_book_map ' END +
		'
			sbmp ON dh.source_system_book_id1 = sbmp.source_system_book_id1 
			AND dh.source_system_book_id2 = sbmp.source_system_book_id2 
			AND dh.source_system_book_id3 = sbmp.source_system_book_id3 
			AND dh.source_system_book_id4 = sbmp.source_system_book_id4 			
			LEFT OUTER JOIN source_counterparty ON dh.counterparty_id = source_counterparty.source_counterparty_id 
			LEFT OUTER JOIN source_counterparty AS scp ON dh.broker_id = scp.source_counterparty_id 
			LEFT OUTER JOIN source_traders ON dh.trader_id = source_traders.source_trader_id 
			LEFT OUTER JOIN source_deal_type ON dh.source_deal_type_id = source_deal_type.source_deal_type_id 
			LEFT OUTER JOIN source_book ON dh.source_system_book_id1 = source_book.source_book_id 
			LEFT OUTER JOIN source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id 
			LEFT OUTER JOIN source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id 
			LEFT OUTER JOIN source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id 
			LEFT OUTER JOIN  portfolio_hierarchy ON portfolio_hierarchy.entity_id = sbmp.fas_book_id
			LEFT OUTER JOIN fas_strategy ON fas_strategy.fas_strategy_id=portfolio_hierarchy.parent_entity_id
			LEFT OUTER JOIN static_data_value  static_data_value1 ON sbmp.fas_deal_type_value_id=static_data_value1.value_id
			LEFT OUTER JOIN static_data_value  static_data_value2 ON fas_strategy.hedge_type_value_id=static_data_value2.value_id
			LEFT OUTER JOIN static_data_value  static_data_value3 ON static_data_value3.value_id = dh.pricing
			LEFT OUTER JOIN static_data_value  static_data_value4 ON static_data_value4.value_id = dh.deal_category_value_id
			LEFT OUTER JOIN confirm_status_recent csr ON csr.source_deal_header_id = dh.source_deal_header_id
			LEFT OUTER JOIN static_data_value sdv_confirm ON sdv_confirm.value_id = ISNULL(csr.type,17200)
			LEFT OUTER JOIN source_deal_type source_deal_type_1 ON dh.deal_sub_type_type_id = source_deal_type_1.source_deal_type_id 
			LEFT OUTER JOIN fas_link_detail fld ON fld.source_deal_header_id = dh.source_deal_header_id 
			LEFT OUTER JOIN static_data_value sdv ON sdv.value_id=dh.assignment_type_value_id
			LEFT OUTER JOIN rec_generator rg ON rg.generator_id=dh.generator_id' +
			CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) OR (@gis_cert_date IS NOT NULL) OR (@location IS NOT NULL) OR (@index_group IS NOT null) OR (@index IS NOT NULL)
			THEN
				'LEFT OUTER JOIN source_deal_detail sdd ON sdd.source_deal_header_id=dh.source_deal_header_id '
			ELSE '' END +
			
			CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) OR (@gis_cert_date IS NOT NULL)
				THEN
					'LEFT OUTER JOIN gis_certificate gis ON gis.source_deal_header_id=sdd.source_deal_detail_id'
				ELSE '' END +
			CASE WHEN (@index_group IS NOT null) OR (@index IS NOT NULL)
				THEN
					'LEFT OUTER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id'
				ELSE '' END +
			CASE WHEN (@location IS NOT NULL)
				THEN
					'LEFT OUTER JOIN source_minor_location sml ON sml.source_minor_location_id=sdd.location_id'
				ELSE '' END +
			'
			LEFT OUTER JOIN dbo.source_deal_header_template t ON t.template_id=dh.template_id  
			LEFT OUTER JOIN dbo.source_deal_detail_template dt ON dt.template_id=dh.template_id
			LEFT OUTER JOIN source_commodity sc ON sc.source_commodity_id=dt.commodity_id
			LEFT OUTER JOIN static_data_value sdv2 ON sdv2.value_id=dh.block_type
			LEFT JOIN
			(
				SELECT MAX(id) id, deal_type_id, MIN(hour * 60 + minute) mins
				FROM deal_lock_setup dls
				INNER JOIN application_role_user aru ON dls.role_id = aru.role_id
				WHERE aru.user_login_id = dbo.FNADBUser() AND deal_type_id IS NOT NULL
				GROUP BY dls.deal_type_id
			) dl_specific ON source_deal_type.source_deal_type_id = dl_specific.deal_type_id AND ISNULL(dh.deal_locked, ''n'') <> ''y''
			LEFT JOIN
			(
				SELECT MAX(id) id, deal_type_id, MIN(hour * 60 + minute) mins
				FROM deal_lock_setup dls
				INNER JOIN application_role_user aru ON dls.role_id = aru.role_id
				WHERE aru.user_login_id = dbo.FNADBUser() AND deal_type_id IS NULL
				GROUP BY dls.deal_type_id
			) dl_generic ON ISNULL(dh.deal_locked, ''n'') <> ''y''  WHERE   1 = 1 ' 

	
		IF @user_action IS NOT NULL AND @user_action!='all'
			SET @sql_Select = @sql_Select + ' AND dh.user_action='''+@user_action+''''
	
		IF ISNULL(@blotter,'n')='y'
			SET @sql_Select = @sql_Select + ' AND blotter_supported =''y'''

		
	--IF ONE deal id is known make the other the same
/*
		IF (@created_date_from IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND convert(varchar(10),dh.create_ts,120)>='''+convert(varchar(10),@created_date_from,120) +''''
			SET @sql_Select = @sql_Select +' AND dbo.FNAConvertTZAwareDateFormat(dh.create_ts,1)>='''+CONVERT(VARCHAR(10),@created_date_from,120) +''''

		IF (@created_date_to IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND convert(varchar(10),dh.create_ts,120) <='''+convert(varchar(10),@created_date_to,120) +''''
			SET @sql_Select = @sql_Select +' AND dbo.FNAConvertTZAwareDateFormat(dh.create_ts,1) <='''+CONVERT(VARCHAR(10),@created_date_to,120) +''''
			--SET @sql_Select = @sql_Select +' AND convert(varchar(10),dh.create_ts,120) <='''+convert(varchar(10),@created_date_to,120) +''''
*/


		IF (@created_date_from IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.create_ts>='''+CONVERT(VARCHAR(10),[dbo].[FNAConvertTimezone](@created_date_from,1),120) +''''
			
		IF (@created_date_to IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.create_ts <'''+CONVERT(VARCHAR(10),[dbo].[FNAConvertTimezone](@created_date_to+1,1),120) +''''


	IF @deal_id_to IS NULL AND @deal_id_from IS NOT NULL
		SET @deal_id_to = @deal_id_from

	IF @deal_id_from IS NULL AND @deal_id_to IS NOT NULL
		SET @deal_id_from = @deal_id_to

	IF (@deal_id_from IS NOT NULL) AND (@deal_id_to IS NOT NULL) 
		SET @sql_Select = @sql_Select + ' AND dh.source_deal_header_id BETWEEN ' + CAST(@deal_id_from AS VARCHAR)  + ' AND ' + CAST(@deal_id_to AS VARCHAR) 


	IF (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL)
		SET @sql_Select = @sql_Select +' AND ('+ @gis_cert_number + ' between gis.certificate_number_from_int   
		AND  gis.certificate_number_to_int AND ' +
			@gis_cert_number_to + ' between gis.certificate_number_from_int   
		AND  gis.certificate_number_to_int)'

	IF @deal_id IS NOT NULL 
			SET @sql_Select = @sql_Select + ' AND dh.deal_id like ''' + @deal_id + '%'''

	IF @deal_id_from IS NULL AND @deal_id IS NULL --only apply deal filters if deal id not given.
	BEGIN
		IF @index_group IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND spcd.index_group='+CAST(@index_group AS VARCHAR)

		IF @index IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND spcd.source_curve_def_id='+CAST(@index AS VARCHAR)
		
		IF @location IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND sml.source_minor_location_id='+CAST(@location AS VARCHAR)

		IF @commodity IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND sc.source_commodity_id='+CAST(@commodity AS VARCHAR)

		
		IF @block_type IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND sdv2.value_id='+CAST(@block_type AS VARCHAR)
		

	IF @confirm_type IS NOT NULL  -- exceptions)
	BEGIN
		IF (@confirm_type = 'n')
			SET @sql_Select = @sql_Select +' AND csr.type IS NULL OR csr.type=''n'''
		ELSE
			SET @sql_Select = @sql_Select +' AND ISNULL(csr.type,''n'') IN (''' + @confirm_type + ''') '
	END

	
--		IF @book_deal_type_map_id IS NOT NULL 
--			SET @sql_Select = @sql_Select + ' AND sbmp.book_deal_type_map_id in( ' + @book_deal_type_map_id + ')'
--
		IF (@deal_date_from IS NOT NULL) AND (@deal_date_to IS NOT NULL) 
			SET @sql_Select = @sql_Select + ' AND dh.deal_date BETWEEN '''+ @deal_date_from + ''' and ''' + @deal_date_to + ''''
		
		IF (@physical_financial_flag IS NOT NULL)
			SET @sql_Select = @sql_Select + ' AND dh.physical_financial_flag='''+@physical_financial_flag+''''
		
		IF (@counterparty_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.counterparty_id='+CAST(@counterparty_id AS VARCHAR)

		IF (@entire_term_start IS NOT NULL)
			SET @sql_Select = @sql_Select+ ' AND dh.entire_term_start>='''+@entire_term_start+''''

		IF (@entire_term_end IS NOT NULL)
			SET @sql_Select = @sql_Select+ ' AND dh.entire_term_end<='''+@entire_term_end+''''

		IF (@source_deal_type_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.source_deal_type_id='+CAST(@source_deal_type_id  AS VARCHAR)

		IF (@deal_sub_type_type_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.deal_sub_type_type_id='+CAST(@deal_sub_type_type_id  AS VARCHAR)

		IF (@deal_category_value_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.deal_category_value_id='+CAST(@deal_category_value_id  AS VARCHAR)

		IF (@trader_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.trader_id='+CAST(@trader_id  AS VARCHAR)

		IF (@description1 IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.description1 like ''%'+@description1+'%'''

		IF (@description2 IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.description2 like ''%'+@description2+'%'''

		IF (@description3 IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.description3 like ''%'+@description3+'%'''

--		IF (@source_system_book_id1 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND source_book.source_book_id ='+CAST(@source_system_book_id1 AS VARCHAR)
--
--		IF (@source_system_book_id2 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND source_book_1.source_book_id = '+CAST(@source_system_book_id2 AS VARCHAR)
--
--		IF (@source_system_book_id3 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND source_book_2.source_book_id = '+CAST(@source_system_book_id3 AS VARCHAR)
--
--		IF (@source_system_book_id4 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND source_book_3.source_book_id = '+CAST(@source_system_book_id4 AS VARCHAR)
--
		IF (@structured_deal_id  IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.structured_deal_id like ''%'+@structured_deal_id +'%'''

		IF (@header_buy_sell_flag IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.header_buy_sell_flag='''+ @header_buy_sell_flag + ''''


		--IF (@deal_locked IS NOT NULL )
			--SET @sql_Select = @sql_Select + ' AND dh.deal_locked='''+@deal_locked+''''	
		IF (@deal_locked = 'l' )
			SET @sql_Select = @sql_Select + ' AND dh.deal_locked = ''y'''
		
		IF (@deal_locked = 'u' )
			SET @sql_Select = @sql_Select + ' AND (dh.deal_locked = ''n'' OR dh.deal_locked IS NULL)'
/*
		IF (@update_date_from IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND cast(dbo.FNAConvertTZAwareDateFormat(dh.update_ts,1) as datetime)>='''+CAST(@update_date_from  AS VARCHAR)+''''

		IF (@update_date_to IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND cast(dbo.FNAConvertTZAwareDateFormat(dh.update_ts,1) as datetime)<='''+CAST(@update_date_to  AS VARCHAR)+''''
*/

		IF (@update_date_from IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.update_ts>='''+CONVERT(VARCHAR(10),[dbo].[FNAConvertTimezone](@update_date_from,1),120) +''''
			
			--SET @sql_Select = @sql_Select +' AND convert(varchar(10),dh.create_ts,120)>='''+convert(varchar(10),@created_date_from,120) +''''

		IF (@update_date_to IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.update_ts <'''+CONVERT(VARCHAR(10),[dbo].[FNAConvertTimezone](@update_date_to+1,1),120) +''''



		IF (@update_by IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.update_user='''+CAST(@update_by  AS VARCHAR)+''''
			
		IF @deal_status IS NOT NULL 
			SET @sql_Select = @sql_Select + ' AND dh.deal_status=' + CAST(@deal_status AS VARCHAR) 
	END

		----====Added the following filter for REC deals
		--print 'no' 

	--if one cert is known and other not known make the same		
	IF @gis_cert_number_to IS NULL AND @gis_cert_number IS NOT NULL
		SET @gis_cert_number_to = @gis_cert_number

	IF @gis_cert_number IS NULL AND @gis_cert_number_to IS NOT NULL
		SET @gis_cert_number = @gis_cert_number_to



	
	IF @gis_cert_number IS NULL 
	BEGIN

		IF (@generator_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.generator_id='+CAST(@generator_id  AS VARCHAR)
		IF (@status_value_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.status_value_id='+CAST(@status_value_id  AS VARCHAR)
		IF (@status_date IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.status_date='''+ dbo.FNAGetSQLStandardDate(@status_date) + ''''
		IF (@assignment_type_value_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND isnull(dh.assignment_type_value_id, 5149) ='+CAST(@assignment_type_value_id  AS VARCHAR)
		IF (@compliance_year IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.compliance_year='+CAST(@compliance_year  AS VARCHAR)
		IF (@state_value_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.state_value_id='+CAST(@state_value_id  AS VARCHAR)
		IF (@assigned_date IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.assigned_date='''+ dbo.FNAGetSQLStandardDate(@assigned_date) + ''''
		IF (@assigned_by IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.assigned_by='''+ @assigned_by + ''''
		IF @gis_value_id IS NOT NULL
			SET @sql_Select = @sql_Select +' AND rg.gis_value_id='+ CAST(@gis_value_id AS VARCHAR)
		IF @gen_cert_date IS NOT NULL
			SET @sql_Select = @sql_Select +' AND rg.registration_date='''+ @gen_cert_date +''''
		IF @gen_cert_number IS NOT NULL
			SET @sql_Select = @sql_Select +' AND rg.gis_account_number='''+ @gen_cert_number +''''
		IF @gis_cert_date IS NOT NULL
			SET @sql_Select = @sql_Select +' AND gis.gis_cert_date='''+ @gis_cert_date +''''

	END
	
	
	SET @sign_off_date_field = CASE @signed_off_by
		WHEN 't' THEN 'verified_date'
		WHEN 'r' THEN 'risk_sign_off_date'
		WHEN 'b' THEN 'back_office_sign_off_date'
	END 
	
	IF @signed_off_flag IS NOT NULL 
	BEGIN
		IF @signed_off_flag = 'y'
			SET @sql_Select = @sql_Select + ' AND dh.' + @sign_off_date_field + ' IS NOT NULL'
		ELSE IF @signed_off_flag = 'n'
			SET @sql_Select = @sql_Select + ' AND dh.' + @sign_off_date_field + ' IS NULL'
	END

	IF @broker IS NOT NULL 
	BEGIN
		SET @sql_Select = @sql_Select + ' AND dh.broker_id = ' + @broker
	END

		
	IF @sort_by='l'
		SET @sql_Select = @sql_Select +') aa order by id desc'
	ELSE
		SET @sql_Select = @sql_Select +')bb order by id asc'

		PRINT @sql_Select

		EXEC(@sql_Select)
		--If @@ERROR <> 0

--		Exec spa_ErrorHandler @@ERROR, 'Source Deal Header  table', 

--				'spa_sourcedealheader', 'DB Error', 



--				'Failed to select source deal header record.', ''

--		Else

--		Exec spa_ErrorHandler 0, 'Source Deal Header  table', 

--				'spa_sourcedealheader', 'Success', 

--				'Source deal header record successfully selected.', ''


END


ELSE IF @flag = 'a' 
BEGIN

	
	SELECT dh.source_deal_header_id ,dh.source_system_id ,dh.deal_id, 
		dbo.FNAGetSQLStandardDate(dh.deal_date),
 		dh.ext_deal_id ,dh.physical_financial_flag, 
		dh.counterparty_id, 
		dbo.FNAGetSQLStandardDate(dh.entire_term_start), 
		dbo.FNAGetSQLStandardDate(dh.entire_term_end), dh.source_deal_type_id, 
		dh.deal_sub_type_type_id, 
		dh.option_flag, dh.option_type, dh.option_excercise_type, 
		source_book.source_book_name AS Group1, 
		source_book_1.source_book_name AS Group2, 
	        source_book_2.source_book_name AS Group3, source_book_3.source_book_name AS Group4,
		dh.description1,dh.description2,dh.description3,
		dh.deal_category_value_id,dh.trader_id, source_system_book_map.fas_book_id,portfolio_hierarchy.parent_entity_id,
		fas_strategy.hedge_type_value_id,static_data_value1.code AS HedgeItemFlag,
			static_data_value2.code AS HedgeType,source_currency.currency_name AS Currency,
		dh.internal_deal_type_value_id,dh.internal_deal_subtype_value_id,dh.template_id,source_currency.source_system_id,
		dh.header_buy_sell_flag,dh.broker_id,dh.rolling_avg,contract_id,
		source_system_book_map.book_deal_type_map_id,dh.legal_entity ,dh.block_type,dh.block_define_id,dh.granularity_id, dh.pricing
	FROM source_deal_header dh 
		INNER JOIN source_book ON dh.source_system_book_id1 = source_book.source_book_id 
		INNER JOIN source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id 
		INNER JOIN source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id 
		INNER JOIN source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id
		
		LEFT JOIN source_system_book_map ON  source_system_book_map.source_system_book_id1= source_book.source_book_id 
			AND source_system_book_map.source_system_book_id2 = source_book_1.source_book_id 
			AND source_system_book_map.source_system_book_id3 = source_book_2.source_book_id 
			AND source_system_book_map.source_system_book_id4= source_book_3.source_book_id 
		--INNER JOIN #source_system ss ON ss.source_system_id=dh.source_system_id
		LEFT JOIN  portfolio_hierarchy ON portfolio_hierarchy.entity_id = source_system_book_map.fas_book_id
		LEFT JOIN fas_strategy ON fas_strategy.fas_strategy_id=portfolio_hierarchy.parent_entity_id
		LEFT JOIN static_data_value  static_data_value1 ON source_system_book_map.fas_deal_type_value_id=static_data_value1.value_id
		LEFT JOIN static_data_value  static_data_value2 ON fas_strategy.hedge_type_value_id=static_data_value2.value_id
		LEFT  JOIN fas_subsidiaries ON fas_subsidiaries.fas_subsidiary_id=@sub_id 
		LEFT JOIN source_currency   ON fas_subsidiaries.func_cur_value_id=source_currency.source_currency_id
		WHERE dh.source_deal_header_id=@source_deal_header_id --and source_system_book_map.fas_book_id = @book_id
        --ORDER BY dh.source_deal_header_id ASC


	END


ELSE IF @flag='u'
BEGIN
	IF EXISTS(SELECT 1 FROM source_deal_header WHERE source_deal_header_id <> @source_deal_header_id AND deal_id = @deal_id)
	BEGIN
		EXEC spa_ErrorHandler -1, 'Source Deal Header  table', 
					'spa_sourcedealheader', 'DB Error', 
					'Error', 'Cannot insert duplicate ref ID.'
		
	END
	ELSE
	BEGIN
		BEGIN TRY
			
			CREATE TABLE #report_position_deals (source_deal_header_id INT)
			DECLARE @report_position_deals VARCHAR(300)
			SET @process_id=dbo.FNAGetNewID()
			SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id,@process_id)

			BEGIN TRAN
			--IF NOT EXISTS (
			--	SELECT 1 FROM source_deal_header 
			--	WHERE	source_deal_header_id = @source_deal_header_id 
			--		AND isnull(internal_desk_id,-1) = isnull(@source_internal_desk ,-1)
			--		AND isnull(block_type,-1) = isnull(@block_type,-1)
			--		AND isnull(block_define_id,-1) = isnull(@block_define_id,-1)
			--		and isnull(source_system_book_id1,-1) =isnull(@source_system_book_id1,-1)
			--		AND isnull(source_system_book_id2,-1) =isnull(@source_system_book_id2,-1)
			--		AND isnull(source_system_book_id3,-1) =isnull(@source_system_book_id3,-1)
			--		AND isnull(source_system_book_id4,-1) =isnull(@source_system_book_id4,-1)
			--		AND isnull(physical_financial_flag,-1) =isnull(@physical_financial_flag ,-1)
			--		AND isnull(deal_date,-1) =isnull(@deal_date,-1)
			--		AND isnull(counterparty_id,-1) =isnull(@counterparty_id,-1)
			--		AND isnull(deal_status,-1)=isnull(@deal_status,-1) 
			--		AND isnull(product_id,-1)=isnull(@source_product,-1)
			--)
			--BEGIN
			--	SET @sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id,action) SELECT ' + CAST(@source_deal_header_id AS VARCHAR) + ',''u'''
			--	PRINT @sql 
			--	EXEC (@sql) 
			--END
			SET @sql = 'SELECT ' + CAST(@source_deal_header_id AS VARCHAR) + ' source_deal_header_id,''u'' action into '+ @report_position_deals
				PRINT @sql 
				EXEC (@sql)
				
			SET @sql = 'INSERT INTO #report_position_deals (source_deal_header_id)
						SELECT DISTINCT source_deal_header_id FROM ' + @report_position_deals 
			PRINT @sql 
			EXEC (@sql)
			
			UPDATE source_deal_header SET
				source_system_id =@source_system_id,
				deal_id =@deal_id,
				deal_date =@deal_date,	
				ext_deal_id =@ext_deal_id,
				physical_financial_flag =@physical_financial_flag,
				structured_deal_id =@structured_deal_id,
				counterparty_id =@counterparty_id,
				entire_term_start =@entire_term_start,
				entire_term_end =@entire_term_end,
				source_deal_type_id =@source_deal_type_id,
				deal_sub_type_type_id= @deal_sub_type_type_id,
				option_flag=@option_flag,
				option_type =@option_type,
				option_excercise_type =@option_excercise_type,
				source_system_book_id1 =@source_system_book_id1,
				source_system_book_id2 =@source_system_book_id2,
				source_system_book_id3 =@source_system_book_id3,
				source_system_book_id4 =@source_system_book_id4,
				description1=@description1,
				description2=@description2,
				description3=@description3,
				deal_category_value_id=@deal_category_value_id,
				trader_id=@trader_id,
				internal_deal_type_value_id=@internal_deal_type_value_id,
				internal_deal_subtype_value_id=@internal_deal_subtype_value_id,
				header_buy_sell_flag=@header_buy_sell_flag,
				broker_id = @broker_id,
				aggregate_environment=@aggregate_environment,
				aggregate_envrionment_comment=@aggregate_envrionment_comment,
				rec_price=@rec_price,
				rec_formula_id=@rec_formula_id,
				generator_id=@generator_id, 
				generation_source=@generation_source,		
				status_value_id=@status_value_id, 
				status_date=@status_date,
				assignment_type_value_id=@assignment_type_value_id, 
				compliance_year=@compliance_year, 
				state_value_id=@state_value_id, 
				assigned_date=@assigned_date, 
				assigned_by=@assigned_by,
				rolling_avg=@rolling_avg,
				contract_id=@contract_id,
				legal_entity=@legal_entity,
				reference=@refrence, 
				commodity_id=@source_commodity,
				internal_portfolio_id=@source_internal_portfolio,
				product_id=@source_product,
				internal_desk_id=@source_internal_desk,
				update_ts=GETDATE(),
				update_user=dbo.FNADBuser(),
				block_type=@block_type,
				block_define_id=@block_define_id,
				granularity_id =@granularity_id,
				pricing=@pricing,
				unit_fixed_flag = @unit_fixed_flag,
				broker_unit_fees = @broker_unit_fees,
				broker_fixed_cost = @broker_fixed_cost,
				broker_currency_id = @broker_currency_id,
				deal_status = @deal_status,
				option_settlement_date=@option_settlement_date,
				verified_by = NULL,
				verified_date = NULL,
				risk_sign_off_by = NULL,
				risk_sign_off_date = NULL,
				back_office_sign_off_by = NULL,
				back_office_sign_off_date = NULL,
				close_reference_id = @refrence_deal
				--deal_reference_type_id = @refrence_deal
			WHERE source_deal_header_id = @source_deal_header_id
	
	PRINT '1'
--			EXEC spa_insert_update_audit @flag,@source_deal_header_id
			--exec spa_user_defined_deal_fields 'i',NULL,13682,'41|42|58','UDF_TU|291204|291203'
			IF @udf_template_id_list IS NOT NULL AND @udf_value_list IS NOT NULL
			EXEC spa_user_defined_deal_fields 'i',NULL,@source_deal_header_id,@udf_template_id_list,@udf_value_list,1
			COMMIT TRAN	
			
			--EXEC spa_update_deal_total_volume @source_deal_header_id
                DECLARE @spa VARCHAR(8000)
                DECLARE @job_name VARCHAR(100)
--		SET @process_id = REPLACE(newid(),'-','_')
		
				
		DECLARE @max_audit_id INT
				
		SELECT @max_audit_id = audit_id FROM source_deal_header_audit WHERE source_deal_header_id = @source_deal_header_id 

			PRINT '2'	
		--- Update buy sell flag of reference deals
		  UPDATE sdh
		  SET
			sdh.header_buy_sell_flag = CASE WHEN  @header_buy_sell_flag ='s' THEN 'b' ELSE 's' END
		  FROM 
			  source_deal_header sdh
		  WHERE
				close_reference_id=@source_deal_header_id	
				 AND sdh.deal_reference_type_id IN (12500,12503)	   
		   --PRINT @sql  
		   
			PRINT '3'
		----- For transferred and Offset Deals, select transferred deal is original deal is offset and vice versa.
		exec('INSERT INTO '+@report_position_deals+'(source_deal_header_id,action)
		SELECT sdh.close_reference_id,''u''
		FROM
			source_deal_header sdh 
		WHERE
			sdh.deal_reference_type_id IN (12500,12503)
			AND sdh.source_deal_header_id='+@source_deal_header_id)	
			PRINT '4'
		
		IF EXISTS (SELECT 1 FROM #report_position_deals)
		BEGIN
--			SET @spa = 'spa_update_deal_total_volume ' + CAST(@source_deal_header_id AS VARCHAR) 
			SET @spa = 'spa_update_deal_total_volume NULL,''' + CAST(@process_id AS VARCHAR(50)) + ''''
			SET @job_name = 'update_total_volume_deal_' + @process_id 
			EXEC spa_run_sp_as_job @job_name, @spa, 'update_total_volume', @user_login_id 
		END

		EXEC spa_source_deal_detail_hour 'i',@source_deal_header_id


		SET @spa = 'spa_insert_update_audit '''+@flag+''','+CAST(@source_deal_header_id AS VARCHAR)
		SET @job_name = 'spa_insert_update_audit_' + @process_id
		EXEC spa_run_sp_as_job @job_name, @spa,'spa_insert_update_audit' ,@user_login_id
		
		SET @job_name = 'spa_compliance_workflow_109_' + @process_id
		SET @spa = 'spa_compliance_workflow 109,''i'',' + CAST(@source_deal_header_id AS VARCHAR) + ',''Deal'',NULL'
		EXEC spa_run_sp_as_job @job_name, @spa,'spa_compliance_workflow_109' ,@user_login_id

		SET @job_name = 'spa_compliance_workflow_112_' + @process_id
		SET @spa = 'spa_compliance_workflow 112,''i'',' + CAST(@source_deal_header_id AS VARCHAR)
		EXEC spa_run_sp_as_job @job_name, @spa,'spa_compliance_workflow_112' ,@user_login_id
					

			EXEC spa_ErrorHandler 0, 'Source Deal Header  table', 
			'spa_sourcedealheader', 'Success', 
			'Source deal  record successfully updated.', ''
	
		
			
			
		END TRY
		BEGIN CATCH
			DECLARE @error_no INT
			SET @error_no = ERROR_NUMBER()
			
			IF @@TRANCOUNT > 0
				ROLLBACK TRAN
			
			EXEC spa_ErrorHandler @error_no, 'Source Deal Header  table', 
					'spa_sourcedealheader', 'DB Error', 
					'Failed updating record.', 'Failed Updating Record'
			
		END CATCH
	END
END	
ELSE IF @flag='l'
BEGIN
		SET @sql='
			UPDATE source_deal_header SET
				deal_locked='''+ @deal_locked +'''
				WHERE source_deal_header_id in ('+ @source_deal_header_id +')'
			EXEC(@sql) 
			EXEC spa_insert_update_audit 'u',@source_deal_header_id	
	
				IF @@ERROR <> 0
					BEGIN	
					EXEC spa_ErrorHandler @@ERROR, 'Source Deal Locked Updated', 
			
							'spa_sourcedealheader', 'DB Error', 
			
							'Failed Source Deal Locked Updated.', 'Failed Updating Record'
					END
					ELSE
					BEGIN
					EXEC spa_ErrorHandler 0, 'Source Deal Header  table', 
		
						'spa_sourcedealheader', 'Success', 
		
						'Source deal  record successfully updated.', ''
				    END

END


ELSE IF @flag='r' -- FOR REC TRANS (Update window) get all the record from source_deal_header
BEGIN
	DECLARE @enable_certificate CHAR(1)
	IF EXISTS (SELECT source_deal_header_id_from FROM assignment_audit WHERE source_deal_header_id_from IN (SELECT 
		source_deal_detail_id FROM source_deal_detail WHERE source_deal_header_id=@source_deal_header_id))
		SET @enable_certificate='n'
	ELSE
		SET @enable_certificate='y'

	SELECT 	dh.source_deal_header_id,
		deal_id,
		[dbo].FNAGetGenericDate(sdd.term_start,@user_login_id) term_start,
		[dbo].FNAGetGenericDate(sdd.term_end, @user_login_id) term_end,
		counterparty_id,
		source_deal_type_id,
		sbmp.book_deal_type_map_id,
		sb.source_book_name,
		trader_id,
		sdd.deal_volume,
		sdd.deal_volume_uom_id,
		generator_id,
		template_id,
		CASE source_deal_type_id WHEN 53 THEN rec_price  
		     WHEN 55 THEN fixed_price 
			ELSE NULL END Rec_price,
		CASE source_deal_type_id WHEN 53 THEN fixed_price  
			 WHEN 55 THEN 
			NULL ELSE fixed_price  END fixed_price,
		fixed_price_currency_id,
		header_buy_sell_flag,
		sdd.source_deal_detail_id,
		deal_volume_frequency,
		curve_id,
		certificate_number_from_int,
		certificate_number_to_int,
		@enable_certificate,
		[dbo].FNAGetGenericDate(dh.deal_date, @user_login_id) deal_date,
		[dbo].FNAGetGenericDate(gis.gis_cert_date, @user_login_id) gis_cert_date,
		sdd.settlement_volume,
		sdd.settlement_uom,
		dh.legal_entity
		FROM source_deal_header dh JOIN source_deal_detail sdd ON
		dh.source_deal_header_id=sdd.source_deal_header_id
		LEFT OUTER JOIN source_system_book_map sbmp ON dh.source_system_book_id1 = sbmp.source_system_book_id1 AND 
        	dh.source_system_book_id2 = sbmp.source_system_book_id2 AND dh.source_system_book_id3 = sbmp.source_system_book_id3 AND 
	        dh.source_system_book_id4 = sbmp.source_system_book_id4 JOIN source_book sb ON sb.source_book_id=dh.source_system_book_id1
		LEFT OUTER JOIN gis_certificate gis ON gis.source_deal_header_id=sdd.source_deal_detail_id
		WHERE dh.source_deal_header_id=@source_deal_header_id
				
END
ELSE IF @flag='b' -- FOR REC TRANS window, Update the source_deal_header table
BEGIN
	BEGIN TRAN
					
	IF EXISTS (SELECT deal_id FROM source_deal_header WHERE deal_id=@deal_id AND source_deal_header_id<>@source_deal_header_id) 
	BEGIN
			ROLLBACK TRAN
			EXEC spa_ErrorHandler 1, 'Source Deal Detail Temp Table', 
						'spa_getXml', 'DB Error', 
						'Duplicated Reference ID found, please check RefId and re-create it.','Duplicated Reference ID found, please check RefId and re-create it.'
			RETURN
	
	END

	IF @source_deal_type_id=53 
	BEGIN
		UPDATE source_deal_header 
			SET deal_id=@deal_id, 
			counterparty_id=@counterparty_id,
			trader_id=@trader_id,
			header_buy_sell_flag=@header_buy_sell_flag,
			rec_price=@rec_price,
			generator_id=@generator_id
			WHERE source_deal_header_id = @source_deal_header_id
	END
	ELSE
	BEGIN
		UPDATE source_deal_header 
			SET deal_id=@deal_id, 
			counterparty_id=@counterparty_id,
			trader_id=@trader_id,
			header_buy_sell_flag=@header_buy_sell_flag,
			generator_id=@generator_id
			WHERE source_deal_header_id = @source_deal_header_id
	END					
	
IF @certificate_from IS NOT NULL AND @certificate_to IS NOT NULL
BEGIN



	UPDATE gis_certificate
	SET  gis_certificate_number_from=dbo.FNACertificateRule(cr.cert_rule,rg.generator_id,@certificate_from,sdh.deal_date),
	  gis_certificate_number_to=dbo.FNACertificateRule(cr.cert_rule,rg.generator_id,@certificate_to,sdh.deal_date),
       	  certificate_number_from_int=@certificate_from,
	  certificate_number_to_int=@certificate_to,
	  gis_cert_date=@certificate_date
       	FROM
		source_deal_header sdh	JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id 
		INNER JOIN rec_generator rg 
		ON sdh.generator_id = RG.generator_id     
		INNER JOIN certificate_rule cr ON
		rg.gis_value_id=cr.gis_id JOIN
		gis_certificate gis ON gis.source_deal_header_id=sdd.source_deal_detail_id
	WHERE
		sdh.source_deal_header_id=@source_deal_header_id  

	IF NOT EXISTS (SELECT * FROM gis_certificate WHERE source_deal_header_id IN(SELECT source_deal_detail_id FROM 
	source_deal_detail WHERE source_deal_header_id=@source_deal_header_id))
	BEGIN
		INSERT gis_certificate(source_deal_header_id,gis_certificate_number_from,gis_certificate_number_to,certificate_number_from_int,
		certificate_number_to_int,gis_cert_date)
		SELECT sdd.source_deal_detail_id ,dbo.FNACertificateRule(cr.cert_rule,rg.generator_id,@certificate_from,sdd.term_start),
		dbo.FNACertificateRule(cr.cert_rule,rg.generator_id,@certificate_to,sdd.term_start),@certificate_from,@certificate_to, sdd.term_start 
		FROM certificate_rule cr JOIN rec_generator rg ON rg.gis_value_id=cr.gis_id  AND rg.generator_id=@generator_id
		JOIN source_deal_detail sdd ON sdd.source_deal_header_id=@source_deal_header_id
	END	
	-- UPDATE ASSIGNMENT AUDIT, IF already assigned , FROM REC UPDATE
	DECLARE @cert_total INT
	SET @cert_total=(@certificate_to-@certificate_from) + 1
	
	SELECT assignment_id,assigned_volume,(SELECT SUM(assigned_volume) FROM assignment_audit 
	WHERE source_deal_header_id_from=a.source_deal_header_id_from 
	AND assignment_id <=a.assignment_id)-assigned_volume +  @certificate_from cert_from,
	CASE WHEN assigned_volume <=@cert_total THEN assigned_volume ELSE @cert_total END + @certificate_from -1 Cert_to 
	INTO #temp_assign
	FROM assignment_audit a WHERE a.cert_from IS NULL
	AND source_deal_header_id_from=(SELECT source_deal_detail_id FROM source_deal_detail WHERE 
	source_deal_header_id=@source_deal_header_id)

	UPDATE assignment_audit
	SET cert_from=t.cert_from,
	cert_to=t.cert_to
	FROM assignment_audit a, #temp_assign t
	WHERE a.assignment_id=t.assignment_id

END

	IF @@ERROR <> 0
					BEGIN	
					EXEC spa_ErrorHandler @@ERROR, 'Source Deal Header  table', 
			
							'spa_sourcedealheader', 'DB Error', 
			
							'Failed updating record.', 'Failed Updating Record'
					ROLLBACK TRAN
					END
					ELSE
					BEGIN
					EXEC spa_ErrorHandler 0, 'Source Deal Header  table', 
		
						'spa_sourcedealheader', 'Success', 
		
						'Source deal  record successfully updated.', ''
					COMMIT TRAN	
					END
END
ELSE IF @flag='d'
BEGIN
		
	 DECLARE @delete_deals_table VARCHAR(100)
	 	
	 SET @delete_deals_table = dbo.FNAProcessTableName('delete_deals', @user_login_id,@process_id)
		
	/***************************************************Validation START*************************************************/
	
	IF @delete_deals_table IS NOT NULL
	BEGIN
	
		SET @sql_Select = 'UPDATE ddt
							SET ddt.Status=CASE WHEN fld.source_deal_header_id IS NOT NULL OR sdh.source_deal_header_id IS NOT NULL  OR sdh1.source_deal_header_id IS NOT NULL THEN  ''Error'' ELSE ''Success'' END,
								ddt.description=CASE WHEN fld.source_deal_header_id IS NOT NULL THEN ''Deal ''+CAST(fld.source_deal_header_id AS VARCHAR)+'' cannot be deleted. It is mapped to a hedging relationship.''
												   WHEN sdh.source_deal_header_id IS NOT NULL THEN ''Deal ''+CAST(sdh.source_deal_header_id AS VARCHAR)+'' cannot be deleted. Please delete the transferred/offset deal first.''
												   WHEN sdh1.source_deal_header_id IS NOT NULL THEN ''Deal ''+CAST(sdh1.source_deal_header_id AS VARCHAR)+''  deal is locked. Please unlock it to delete.''
											 ELSE '''' END	   
							FROM  '+@delete_deals_table+'	ddt 
								 INNER JOIN source_deal_header sdh2 ON sdh2.source_deal_header_id=ddt.source_deal_header_id
								 LEFT JOIN fas_link_detail fld ON ddt.source_deal_header_id = fld.source_deal_header_id
								 LEFT JOIN source_deal_header sdh ON ddt.source_deal_header_id = sdh.close_reference_id AND sdh.deal_reference_type_id =12503
								 LEFT JOIN source_deal_header sdh1 ON ddt.source_deal_header_id = sdh1.source_deal_header_id AND sdh1.deal_locked=''y'''
						 
		EXEC(@sql_Select)						 
	END
	ELSE
	BEGIN
	
	
		IF EXISTS(SELECT 1 FROM source_deal_header sdh 
						INNER JOIN fas_link_detail fld 
							ON sdh.source_deal_header_id = fld.source_deal_header_id
						INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv 
							ON sdh.source_deal_header_id = scsv.Item)
			BEGIN
				EXEC spa_ErrorHandler 
						-1																				--error no
						, 'Source Deal Header'															--module
						, 'spa_sourcedealheader'														--area
						, 'DB Error'																	--status
						,'The selected deal cannot be deleted. It is mapped to a hedging relationship.' --message
						, ''																			--recommendation
				RETURN
			END
			ELSE IF EXISTS(SELECT 1	FROM source_deal_header sdh
							INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv ON sdh.close_reference_id = scsv.Item AND sdh.deal_reference_type_id =12503)
			BEGIN
				EXEC spa_ErrorHandler 
						-1																							--error no
						, 'Source Deal Header'																		--module
						, 'spa_sourcedealheader'																	--area
						, 'DB Error'																				--status
						,'The selected deal cannot be deleted. Please delete the transferred/offset deal first.'	--message
						, ''																						--recommendation
				RETURN
			END
			ELSE IF EXISTS(SELECT 1 FROM source_deal_header sdh
							INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv ON sdh.source_deal_header_id = scsv.Item
							WHERE sdh.deal_locked='y')
			BEGIN
				
				EXEC spa_ErrorHandler 
						-1																							--error no
						, 'Source Deal Header'																		--module
						, 'spa_sourcedealheader'																	--area
						, 'DB Error'																				--status
						,'This deal is locked. Please unlock it to delete.'											--message
						, ''																						--recommendation
				RETURN
				
			END
			ELSE IF EXISTS( SELECT 1 FROM source_deal_header sdh
							INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv ON  sdh.close_reference_id = scsv.Item	
			)
			BEGIN
				EXEC spa_ErrorHandler 
						-1																							--error no
						, 'Source Deal Header'																		--module
						, 'spa_sourcedealheader'																	--area
						, 'DB Error'																				--status
						, 'The selected deal cannot be deleted. Please delete the transferred/offset deal first.'			--message
						, ''																						--recommendation
				RETURN
			END
			
	END		
	/***************************************************Validation END*************************************************/
	--ELSE
	BEGIN
		IF @delete_deals_table IS NULL
		BEGIN
		
			IF EXISTS (SELECT sdd.source_deal_header_id FROM assignment_audit a 
					INNER JOIN source_deal_detail sdd ON a.source_deal_header_id = sdd.source_deal_detail_id
					LEFT JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv_from ON scsv_from.Item = a.source_deal_header_id_from
					LEFT JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv ON scsv.Item = a.source_deal_header_id										
					WHERE assigned_volume > 0 AND assigned_by <> 'Auto assigned'
						AND (scsv_from.Item IS NOT NULL OR scsv.Item IS NOT NULL)
				)
			BEGIN
				DECLARE @url VARCHAR(5000)
				DECLARE @source_deal_header_id_from INT
				SELECT  
						@source_deal_header_id_from = MAX(sdh1.source_deal_header_id)
				FROM 
						source_deal_header sdh 
						INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id
						INNER JOIN assignment_audit assign ON assign.source_deal_header_id=sdd.source_deal_detail_id
						INNER JOIN source_deal_detail sdd1 ON assign.source_deal_header_id_from=sdd1.source_deal_detail_id 
						INNER JOIN source_deal_header sdh1 ON sdh1.source_deal_header_id=sdd1.source_deal_header_id
				WHERE 
					sdh.source_deal_header_id = @source_deal_header_id

				SET @url = '<a href="../../dev/spa_html.php?spa=exec spa_create_lifecycle_of_recs ''' 
							+ [dbo].FNAGetGenericDate(GETDATE(),@user_login_id) + ''',NULL,' 
							+ CAST(ISNULL(@source_deal_header_id_from,@source_deal_header_id) AS VARCHAR) + '">Click here...</a>'
				
				SET @url = 'Deal ID: ' + CAST(@source_deal_header_id AS VARCHAR) + ' is already assigned, Please remove all the assign deals first to delete this deal.<br> Please view this report ' + @url
				EXEC spa_ErrorHandler 
						-1							--error no
						, 'Source Deal Header'		--module
						, 'spa_sourcedealheader'	--area
						, 'DB Error'				--status
						, @url						--message
						, ''						--recommendation
				RETURN
			END
			END
		BEGIN TRY
			BEGIN TRAN

			--using LEFT JOIN here, as some deals have no entry in source_deal_detail (might be due to previous buggy deletes)
			CREATE TABLE #temp_deal_delete(source_deal_detail_id INT,source_deal_header_id INT)
			
			
			IF @delete_deals_table IS NULL
					INSERT INTO #temp_deal_delete 
						SELECT source_deal_detail_id, a.Item AS source_deal_header_id 
						FROM 
							dbo.SplitCommaSeperatedValues(@source_deal_header_id) a
							LEFT JOIN source_deal_detail sdd ON a.Item = sdd.source_deal_header_id
						UNION -- Delete offset deal also
						SELECT source_deal_detail_id, sdh.source_deal_header_id AS source_deal_header_id 
						FROM 
							dbo.SplitCommaSeperatedValues(@source_deal_header_id) a
							LEFT JOIN source_deal_header sdh On sdh.close_reference_id=a.Item AND sdh.deal_reference_type_id=12500
							LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id	
			ELSE
			BEGIN
				SET @sql_Select='
						INSERT INTO #temp_deal_delete 
						SELECT source_deal_detail_id, a.source_deal_header_id AS source_deal_header_id 
						FROM 
							'+@delete_deals_table+' a
							LEFT JOIN source_deal_detail sdd ON a.source_deal_header_id = sdd.source_deal_header_id
						UNION
						SELECT source_deal_detail_id, sdh.source_deal_header_id AS source_deal_header_id 
						FROM 
							'+@delete_deals_table+' a
							LEFT JOIN source_deal_header sdh On sdh.close_reference_id=a.source_deal_header_id AND sdh.deal_reference_type_id=12500
							LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id'
							
							
							
				EXEC(@sql_Select)
			END
			
			
			DELETE assignment_audit FROM assignment_audit a 
			INNER JOIN #temp_deal_delete d ON a.source_deal_header_id_from = d.source_deal_detail_id 
												AND assigned_volume = 0
												
			DELETE ua
			FROM assignment_audit ua
			INNER JOIN #temp_deal_delete d ON ua.source_deal_header_id = d.source_deal_detail_id
		
			DELETE unassignment_audit FROM unassignment_audit a 
			INNER JOIN #temp_deal_delete d ON a.source_deal_header_id_from = d.source_deal_detail_id 
												AND assigned_volume = 0
		
			DELETE ua
			FROM unassignment_audit ua
			INNER JOIN #temp_deal_delete d ON ua.source_deal_header_id = d.source_deal_detail_id
			
			DELETE ua
			FROM gis_certificate ua
			INNER JOIN #temp_deal_delete d ON ua.source_deal_header_id = d.source_deal_detail_id

			--udf records to respective delete table
			INSERT INTO [dbo].[delete_user_defined_deal_fields](
				 [udf_deal_id],[source_deal_header_id],[udf_template_id],
				 [udf_value],[create_user],[create_ts],[update_user],[update_ts]
				)
			SELECT udf.[udf_deal_id], udf.[source_deal_header_id], udf.[udf_template_id],
				   udf.[udf_value],dbo.FNADBUser() [create_user],GETDATE() [create_ts],[update_user],udf.[update_ts]
			FROM [dbo].[user_defined_deal_fields] udf 
			INNER JOIN (SELECT DISTINCT source_deal_header_id FROM #temp_deal_delete) d ON udf.source_deal_header_id = d.source_deal_header_id

			DELETE udf 
			FROM user_defined_deal_fields udf 
			INNER JOIN #temp_deal_delete d ON udf.source_deal_header_id = d.source_deal_header_id
			
			DELETE udf 
			FROM deal_exercise_detail udf 
			INNER JOIN #temp_deal_delete d ON udf.source_deal_detail_id = d.source_deal_detail_id
				
			DELETE udf 
			FROM deal_exercise_detail udf 
			INNER JOIN #temp_deal_delete d ON udf.exercise_deal_id = d.source_deal_detail_id
				
			DELETE udf 
			FROM confirm_status_recent udf 
			INNER JOIN #temp_deal_delete d ON udf.source_deal_header_id = d.source_deal_header_id
			
			DELETE udf 
			FROM confirm_status udf 
			INNER JOIN #temp_deal_delete d ON udf.source_deal_header_id = d.source_deal_header_id
			
			DELETE udf 
			FROM first_day_gain_loss_decision udf 
			INNER JOIN  #temp_deal_delete d ON udf.source_deal_header_id = d.source_deal_header_id

			DELETE udf 
			FROM deal_tagging_audit udf 
			INNER JOIN  #temp_deal_delete d ON udf.source_deal_header_id = d.source_deal_header_id
			
			/********************************************************************************************/
			
			--commented block as deal cannot be deleted as deal_id column has been removed from calc_invoice_volume_recorder
--			DELETE calc_invoice_volume_recorder
--			FROM calc_invoice_volume_recorder civr
--			INNER JOIN #temp_deal_delete d ON civr.deal_id = d.source_deal_detail_id
--			
--			DELETE calc_invoice_volume_recorder_arch1
--			FROM calc_invoice_volume_recorder_arch1 civr
--			INNER JOIN #temp_deal_delete d ON civr.deal_id = d.source_deal_detail_id
--			
--			DELETE calc_invoice_volume_recorder_arch2
--			FROM calc_invoice_volume_recorder_arch2 civr
--			INNER JOIN #temp_deal_delete d ON civr.deal_id = d.source_deal_detail_id
--			
--			DELETE calc_invoice_volume_variance
--			FROM calc_invoice_volume_variance civv
--			INNER JOIN #temp_deal_delete d ON civv.deal_id = d.source_deal_detail_id
--			
--			DELETE calc_invoice_volume_variance_arch1
--			FROM calc_invoice_volume_variance_arch1 civv
--			INNER JOIN #temp_deal_delete d ON civv.deal_id = d.source_deal_detail_id
--			
--			DELETE calc_invoice_volume_variance_arch2
--			FROM calc_invoice_volume_variance_arch2 civv
--			INNER JOIN #temp_deal_delete d ON civv.deal_id = d.source_deal_detail_id
			
			DELETE deal_attestation_form
			FROM deal_attestation_form daf
			INNER JOIN #temp_deal_delete d ON daf.source_deal_detail_id = d.source_deal_detail_id
			
			DELETE embedded_deal
			FROM embedded_deal ed
			INNER JOIN #temp_deal_delete d ON ed.source_deal_header_id = d.source_deal_header_id
			
			DELETE inventory_cost_override
			FROM inventory_cost_override ico
			INNER JOIN #temp_deal_delete d ON ico.source_deal_header_id = d.source_deal_header_id
			
			DELETE source_deal_detail_lagging
			FROM source_deal_detail_lagging sddlag
			INNER JOIN #temp_deal_delete d ON sddlag.source_deal_header_id = d.source_deal_header_id
			/********************************************************************************************/

		
			
			
			DECLARE @report_position_process_id VARCHAR(500)
			SET @report_position_process_id = REPLACE(newid(),'-','_')

			SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id,@report_position_process_id)
			EXEC ('CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, action CHAR(1))')
				
			print('insert into ' + @report_position_deals + '( source_deal_header_id, action) select source_deal_header_id,''d'' [action] from #temp_deal_delete ')
			exec('insert into ' + @report_position_deals + '( source_deal_header_id, action) select source_deal_header_id,''d'' [action] from #temp_deal_delete ')
			
			exec dbo.spa_maintain_transaction_job @report_position_process_id,7,null,@user_login_id
		
			
			DELETE sddh 
			FROM source_deal_detail_hour sddh INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id=sddh.source_deal_detail_id
			INNER JOIN #temp_deal_delete d ON sdd.source_deal_header_id = d.source_deal_header_id		
			
			DELETE rhpd 
			FROM report_hourly_position_deal rhpd 
			INNER JOIN #temp_deal_delete d ON rhpd.source_deal_header_id = d.source_deal_header_id
			 
			DELETE rhpf 
			FROM report_hourly_position_profile rhpf 
			INNER JOIN #temp_deal_delete d ON rhpf.source_deal_header_id = d.source_deal_header_id 
		
			DELETE rhpd 
			FROM report_hourly_position_breakdown rhpd 
			INNER JOIN #temp_deal_delete d ON rhpd.source_deal_header_id = d.source_deal_header_id 

			DELETE dpbd
			FROM deal_position_break_down dpbd 
			INNER JOIN #temp_deal_delete d ON dpbd.source_deal_header_id = d.source_deal_header_id
			 

			insert into [dbo].[delete_source_deal_header]
				([source_deal_header_id],[source_system_id],[deal_id],[deal_date]
				,[ext_deal_id],[physical_financial_flag],[structured_deal_id]
				,[counterparty_id],[entire_term_start],[entire_term_end]
				,[source_deal_type_id],[deal_sub_type_type_id],[option_flag]
				,[option_type],[option_excercise_type],[source_system_book_id1]
				,[source_system_book_id2],[source_system_book_id3],[source_system_book_id4]
				,[description1],[description2],[description3],[deal_category_value_id]
				,[trader_id],[internal_deal_type_value_id],[internal_deal_subtype_value_id]
				,[template_id],[header_buy_sell_flag],[broker_id],[generator_id],[status_value_id]
				,[status_date],[assignment_type_value_id],[compliance_year],[state_value_id]
				,[assigned_date],[assigned_by],[generation_source],[aggregate_environment]
				,[aggregate_envrionment_comment],[rec_price],[rec_formula_id],[rolling_avg]
				,[contract_id],[create_user],[create_ts],[update_user],[update_ts],[legal_entity]
				,[internal_desk_id],[product_id],[internal_portfolio_id],[commodity_id]
				,[reference],[deal_locked],[close_reference_id],[block_type],[block_define_id]
				,[granularity_id],[Pricing],[deal_reference_type_id],[unit_fixed_flag]
				,[broker_unit_fees],[broker_fixed_cost],[broker_currency_id],[deal_status]
				,[term_frequency],[option_settlement_date],[verified_by],[verified_date]
				,[risk_sign_off_by],[risk_sign_off_date],[back_office_sign_off_by]
				,[back_office_sign_off_date],[book_transfer_id],[confirm_status_type])
			SELECT 
				sdh.[source_deal_header_id],sdh.[source_system_id],sdh.[deal_id],sdh.[deal_date]
				,sdh.[ext_deal_id],sdh.[physical_financial_flag],sdh.[structured_deal_id]
				,sdh.[counterparty_id],sdh.[entire_term_start],sdh.[entire_term_end]
				,sdh.[source_deal_type_id],sdh.[deal_sub_type_type_id],sdh.[option_flag]
				,sdh.[option_type],sdh.[option_excercise_type],sdh.[source_system_book_id1]
				,sdh.[source_system_book_id2],sdh.[source_system_book_id3],sdh.[source_system_book_id4]
				,sdh.[description1],sdh.[description2],sdh.[description3],sdh.[deal_category_value_id]
				,sdh.[trader_id],sdh.[internal_deal_type_value_id],sdh.[internal_deal_subtype_value_id]
				,sdh.[template_id],sdh.[header_buy_sell_flag],sdh.[broker_id],sdh.[generator_id],sdh.[status_value_id]
				,sdh.[status_date],sdh.[assignment_type_value_id],sdh.[compliance_year],sdh.[state_value_id]
				,sdh.[assigned_date],sdh.[assigned_by],sdh.[generation_source],sdh.[aggregate_environment]
				,sdh.[aggregate_envrionment_comment],sdh.[rec_price],sdh.[rec_formula_id],sdh.[rolling_avg]
				,sdh.[contract_id],dbo.FNADBUser() [create_user],GETDATE() [create_ts],[update_user],sdh.[update_ts],sdh.[legal_entity]
				,sdh.[internal_desk_id],sdh.[product_id],sdh.[internal_portfolio_id],sdh.[commodity_id]
				,sdh.[reference],sdh.[deal_locked],sdh.[close_reference_id],sdh.[block_type],sdh.[block_define_id]
				,sdh.[granularity_id],sdh.[Pricing],sdh.[deal_reference_type_id],sdh.[unit_fixed_flag]
				,sdh.[broker_unit_fees],sdh.[broker_fixed_cost],sdh.[broker_currency_id],sdh.[deal_status]
				,sdh.[term_frequency],sdh.[option_settlement_date],sdh.[verified_by],sdh.[verified_date]
				,sdh.[risk_sign_off_by],sdh.[risk_sign_off_date],sdh.[back_office_sign_off_by]
				,sdh.[back_office_sign_off_date],sdh.[book_transfer_id],sdh.[confirm_status_type]
			  FROM [dbo].[source_deal_header] sdh 
			  INNER JOIN (SELECT DISTINCT source_deal_header_id FROM #temp_deal_delete) d ON sdh.source_deal_header_id = d.source_deal_header_id
--			INNER JOIN #temp_deal_delete d ON sdh.source_deal_header_id = d.source_deal_header_id

			insert into [dbo].[delete_source_deal_detail] (
				[source_deal_detail_id],[source_deal_header_id]
				,[term_start],[term_end],[Leg],[contract_expiration_date]
				,[fixed_float_leg],[buy_sell_flag],[curve_id],[fixed_price]
				,[fixed_price_currency_id],[option_strike_price],[deal_volume]
				,[deal_volume_frequency],[deal_volume_uom_id],[block_description]
				,[deal_detail_description],[formula_id],[volume_left],[settlement_volume]
				,[settlement_uom],[create_user],[create_ts],[update_user],[update_ts]
				,[price_adder],[price_multiplier],[settlement_date],[day_count_id]
				,[location_id],[meter_id],[physical_financial_flag],[Booked]
				,[process_deal_status],[fixed_cost],[multiplier],[adder_currency_id]
				,[fixed_cost_currency_id],[formula_currency_id],[price_adder2]
				,[price_adder_currency2],[volume_multiplier2],[total_volume]
				,[pay_opposite],[capacity])
			SELECT 
				sdd.[source_deal_detail_id],sdd.[source_deal_header_id]
				,sdd.[term_start],sdd.[term_end],sdd.[Leg],sdd.[contract_expiration_date]
				,sdd.[fixed_float_leg],sdd.[buy_sell_flag],sdd.[curve_id],sdd.[fixed_price]
				,sdd.[fixed_price_currency_id],sdd.[option_strike_price],sdd.[deal_volume]
				,sdd.[deal_volume_frequency],sdd.[deal_volume_uom_id],sdd.[block_description]
				,sdd.[deal_detail_description],sdd.[formula_id],sdd.[volume_left],sdd.[settlement_volume]
				,sdd.[settlement_uom],dbo.FNADBUser() [create_user],GETDATE() [create_ts],sdd.[update_user],sdd.[update_ts]
				,sdd.[price_adder],sdd.[price_multiplier],sdd.[settlement_date],sdd.[day_count_id]
				,sdd.[location_id],sdd.[meter_id],sdd.[physical_financial_flag],sdd.[Booked]
				,sdd.[process_deal_status],sdd.[fixed_cost],sdd.[multiplier],sdd.[adder_currency_id]
				,sdd.[fixed_cost_currency_id],sdd.[formula_currency_id],sdd.[price_adder2]
				,sdd.[price_adder_currency2],sdd.[volume_multiplier2],sdd.[total_volume]
				,sdd.[pay_opposite],sdd.[capacity]
			from [dbo].[source_deal_detail] sdd INNER JOIN #temp_deal_delete d ON sdd.source_deal_detail_id = d.source_deal_detail_id
			 
			DELETE source_deal_detail 
			from source_deal_detail sdd 
			INNER JOIN #temp_deal_delete d ON sdd.source_deal_detail_id = d.source_deal_detail_id
			
			DELETE source_deal_header 
			FROM source_deal_header sdh 
			INNER JOIN  #temp_deal_delete d ON sdh.source_deal_header_id = d.source_deal_header_id
			 
			--update table deal_voided_in_external with status 'd'
			UPDATE dvie 
			SET tran_status = 'd'
			FROM deal_voided_in_external dvie 
			INNER JOIN  #temp_deal_delete d ON dvie.source_deal_header_id = d.source_deal_header_id
			
			EXEC spa_compliance_workflow 3, 'd', @source_deal_header_id
		
			EXEC spa_insert_update_audit @flag, @source_deal_header_id, @comments

			EXEC spa_compliance_workflow 115, 'd', @source_deal_header_id
			
			COMMIT TRAN
			
			EXEC spa_ErrorHandler 0								--error no
								, 'Source Deal Header'			--module
								, 'spa_sourcedealheader'		--area
								, 'Success'						--status
								, 'Deal deleted successfully.'	--message
								, ''							--recommendation
		END TRY
		BEGIN CATCH
			PRINT 'Error while deleting deal: ' + ERROR_MESSAGE()
			SET @url = 'Error occuring while deleting deal.'
			EXEC spa_ErrorHandler 
							-1							--error no
							, 'Source Deal Header'		--module
							, 'spa_sourcedealheader'	--area
							, 'DB Error'				--status
							, @url						--message
							, ''						--recommendation	
			
			IF @@TRANCOUNT > 0	
				ROLLBACK TRAN
			
			RETURN
		END CATCH

	END

END

ELSE IF @flag='k'
	BEGIN
	
	SET FMTONLY ON	
	SELECT NULL AS [Template],
	       NULL AS [Deal ID],
	       NULL AS [Deal Date],
	       NULL AS [Buy/Sell],
	       NULL AS [Location],
	       NULL AS [Index],
	       NULL AS [TermFrequency],
	       NULL AS [TermStart],
	       NULL AS [TermEnd],
	       NULL AS [VolumeFrequency],
	       NULL AS [Volume],
	       NULL AS [UOM],
	       NULL AS [Capacity],
	       NULL AS [Price],
	       NULL AS [Fixed Cost],
	       NULL AS [Currency],
	       NULL AS [Formula],
	       NULL AS [Pay Opposite],
	       NULL AS [CptyName],
	       NULL AS [Broker],
	       NULL AS [Trader],
	       NULL AS [Contract],
	       NULL AS [Strike Price],
	       NULL AS [Price Adder],
	       NULL AS [Volume Multiplier],
	       NULL AS [Price Multiplier],
	       NULL AS [Price Adder2],
	       NULL AS [Adder Currency2],
	       NULL AS [Volume Multiplier2],
	       NULL AS [Generator],
	       NULL AS [Block Type],
	       NULL AS [Block Definition],
	       NULL AS [Granularity],
	       NULL AS [ID],
	       NULL AS [allow_edit_term],
	       NULL AS [FixedFloat],
	       NULL AS [PhysicalFinancial],
	       NULL AS [Curve Type],
	       NULL AS [Internal Desk Id]
	
	SET FMTONLY OFF	

/*	
	
	SET @sql_Select = 
			'select [Template],[Deal ID],[Deal Date],[Buy/Sell],[Location],[Index],[TermFrequency],[TermStart]
      ,[TermEnd],[VolumeFrequency],[Volume],[UOM],[Price],[Fixed Cost],[Currency],[CptyName] ,[Broker],[Trader],[Contract],
     [Strike Price],[Price Adder],[Multiplier],[Generator],[Block Type],[Block Definition],[Granularity],[ID],[allow_edit_term],
	[FixedFloat],[PhysicalFinancial],[Curve Type]        
    From (
		SELECT  
			dh.source_deal_header_id AS [ID],
			 max(dh.broker_id) AS Broker,		
            max(sdd.leg) as Leg,
            [dbo].FNAGetGenericDate(max(dh.deal_date), '''+@user_login_id+''') as [Deal Date],
			max(case when sdd.buy_sell_flag=''s'' then ''s'' else ''b'' End) as [Buy/Sell],
     		max(case when dh.physical_financial_flag =''p'' then ''Physical''
				else ''Financial''
			End)
			as PhysicalFinancialFlag,     
               max(sdd.curve_id) as [Index],          
			max(case when fixed_price is null then ''NULL'' else cast(fixed_price as varchar) end) [Price],
			max(fixed_cost) [Fixed Cost],
            max(sdd.fixed_price_currency_id) as [Currency],
            max(sdd.deal_volume) as [Volume],
            max(sdd.deal_volume_uom_id)  as [UOM],
            max(sdd.deal_volume_frequency) as [VolumeFrequency],
--            max(t.term_frequency_type) [TermFrequency],
--			NULL [TermFrequency],
			max(dh.term_frequency) [TermFrequency],
            max(dh.deal_id)[Deal ID],
            max(sdd.option_strike_price) [Strike Price],
			max(sdd.price_adder) [Price Adder],
			max(sdd.price_multiplier) [Multiplier],
            max(dh.contract_id) as [Contract],
            max(dh.template_id) as [Template],
			 max(dh.counterparty_id)  CptyName, 
			max(sdd.location_id) [Location],
			MAX(dh.generator_id) [Generator],
			MAX(dh.block_type) [Block Type],
			MAX(dh.block_define_id) [Block Definition],
			MAX(dh.granularity_id) [Granularity],
			MAX(t.allow_edit_term) [allow_edit_term],
		    [dbo].FNAGetGenericDate(min(sdd.term_start), '''+@user_login_id+''') as TermStart, 
			[dbo].FNAGetGenericDate(max(sdd.term_end), '''+@user_login_id+''') As TermEnd, max(source_deal_type.source_deal_type_name) As DealType, 
			max(source_deal_type_1.source_deal_type_name) AS DealSubType, 
		        max(dh.option_flag) As OptionFlag, max(dh.option_type) As OptionType, max(dh.option_excercise_type) As ExcersiceType,		
       
			max(dh.deal_category_value_id) as Category,max(dh.trader_id) as Trader,max(static_data_value1.code) as HedgeItemFlag,
			max(static_data_value2.code) as  HedgeType,
			max(case when header_buy_sell_flag=''s'' and assignment_type_value_id is not null then 
				sdv.code else 	
			case when header_buy_sell_flag=''s'' and assignment_type_value_id is null then
				''Sold'' else ''Banked'' end
			end) AssignType,
			max(t.physical_financial_flag) [PhysicalFinancial],	
			max(td.fixed_float_leg) [FixedFloat],
			max(td.commodity_id)[Curve Type]  
			FROM       source_deal_header dh LEFT OUTER JOIN				
		           source_system_book_map sbmp ON dh.source_system_book_id1 = sbmp.source_system_book_id1 AND 
		           dh.source_system_book_id2 = sbmp.source_system_book_id2 AND dh.source_system_book_id3 = sbmp.source_system_book_id3 AND 
		           dh.source_system_book_id4 = sbmp.source_system_book_id4 LEFT OUTER JOIN
		           source_counterparty ON dh.counterparty_id = source_counterparty.source_counterparty_id LEFT OUTER JOIN
		           source_traders ON dh.trader_id = source_traders.source_trader_id LEFT OUTER JOIN
				   source_deal_type ON dh.source_deal_type_id = source_deal_type.source_deal_type_id LEFT OUTER JOIN
		           source_book ON dh.source_system_book_id1 = source_book.source_book_id 
			LEFT OUTER JOIN source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id 
		    LEFT OUTER JOIN source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id 
		    LEFT OUTER JOIN source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id
		    INNER JOIN #source_system ss ON ss.source_system_id=dh.source_system_id
		     
			LEFT OUTER JOIN  portfolio_hierarchy ON portfolio_hierarchy.entity_id = sbmp.fas_book_id
			LEFT OUTER JOIN fas_strategy ON fas_strategy.fas_strategy_id=portfolio_hierarchy.parent_entity_id
			LEFT OUTER JOIN static_data_value  static_data_value1 ON sbmp.fas_deal_type_value_id=static_data_value1.value_id
			LEFT OUTER JOIN static_data_value  static_data_value2 ON fas_strategy.hedge_type_value_id=static_data_value2.value_id
			LEFT OUTER JOIN contract_group  cg1 ON cg1.contract_id=dh.contract_id
			left join dbo.source_deal_header_template t ON t.template_id=dh.template_id
			left join dbo.source_deal_detail_template td ON td.template_id=td.template_id	
			LEFT OUTER JOIN
		           source_deal_type source_deal_type_1 ON dh.deal_sub_type_type_id = source_deal_type_1.source_deal_type_id LEFT OUTER JOIN
			   fas_link_detail fld ON fld.source_deal_header_id = dh.source_deal_header_id 
			left outer join static_data_value sdv on sdv.value_id=dh.assignment_type_value_id
			left outer join rec_generator rg on rg.generator_id=dh.generator_id
			LEFT OUTER JOIN source_deal_detail sdd ON sdd.source_deal_header_id=dh.source_deal_header_id 
			   )'

		

--	IF @deal_id_from IS NULL AND @deal_id IS NULL --only apply deal filters if deal id not given.
--	BEGIN
--	
--		IF @book_deal_type_map_id IS NOT NULL 
--			SET @sql_Select = @sql_Select + ' AND sbmp.book_deal_type_map_id in( ' + @book_deal_type_map_id + ')'
--	END
--
--    IF @source_deal_header_id IS NOT NULL 
--			SET @sql_Select = @sql_Select + ' AND dh.source_deal_header_id in( ' + @source_deal_header_id + ')'
--	
--	IF @sort_by='l'
--		SET @sql_Select = @sql_Select +' Group BY dh.source_deal_header_id ) aa  order by [Deal Date] desc,id desc '
--	ELSE
--		SET @sql_Select = @sql_Select +' Group BY dh.source_deal_header_id )bb  order by [Deal Date] asc,id asc'

	SET FMTONLY ON	

	EXEC(@sql_Select)
	SET FMTONLY off	
*/


	END
	


ELSE IF @flag='m'
BEGIN
	
	SET @sql_Select = 
			'select [Template],[Deal ID],[Deal Date],[Buy/Sell],[Location],[Index],[TermFrequency],[TermStart]
      ,[TermEnd],[VolumeFrequency],[Volume],[UOM],[Capacity],[Price],[Fixed Cost],[Currency],[Formula],[Pay Opposite],[CptyName] ,[Broker],[Trader],[Contract],
     [Strike Price],[Price Adder],[Volume Multiplier],[Price Multiplier],[Price Adder2],[Adder Currency2],[Volume Multiplier2],[Generator],[Block Type],[Block Definition],[Granularity],[ID],[allow_edit_term]       
     ,[FixedFloat],[PhysicalFinancial],[Curve Type],[Deal Lock], [Option Flag], [LocationName], [CurveName],[InternalDeskId]
	 from (
	SELECT  
			dh.source_deal_header_id AS [ID],
			 max(dh.broker_id) AS Broker,		
            max(sdd.leg) as Leg,
            [dbo].FNAGetGenericDate(max(dh.deal_date), '''+@user_login_id+''') as [Deal Date],
			max(case when sdd.buy_sell_flag=''s'' then ''s'' else ''b'' End) as [Buy/Sell],
     		max(case when dh.physical_financial_flag =''p'' then ''Physical''
				else ''Financial''
			End)
			as PhysicalFinancialFlag,     
            max(sdd.curve_id) as [Index],
            max(sdd.capacity) as [Capacity],          
			max(case when fixed_price is null then '''' else cast(fixed_price as varchar) end) [Price],
			max(fixed_cost) [Fixed Cost],
            max(sdd.fixed_price_currency_id) as [Currency],
            sdd.formula_id as [Formula],
            MAX(upper(sdd.pay_opposite)) as [Pay Opposite],
            max(sdd.deal_volume) as [Volume],
            max(sdd.deal_volume_uom_id)  as [UOM],
            max(sdd.deal_volume_frequency) as [VolumeFrequency],
--            max(t.term_frequency_type) [TermFrequency],
--			NULL [TermFrequency],
			max(dh.term_frequency) [TermFrequency],
            max(dh.deal_id)[Deal ID],
            max(sdd.option_strike_price) [Strike Price],
			max(sdd.price_adder) [Price Adder],
			max(sdd.multiplier) [Volume Multiplier],
			max(sdd.price_multiplier) [Price Multiplier],
			max(sdd.price_adder2) [Price Adder2],
			sdd.price_adder_currency2 as [Adder Currency2],
			max(sdd.volume_multiplier2) [Volume Multiplier2],
            max(dh.contract_id) as [Contract],
            max(dh.template_id) as [Template],
			 max(dh.counterparty_id)  CptyName, 
			max(sdd.location_id) [Location],
			MAX(dh.generator_id) [Generator],
			MAX(dh.block_type) [Block Type],
			MAX(dh.block_define_id) [Block Definition],
			MAX(dh.granularity_id) [Granularity],
			MAX(t.allow_edit_term) [allow_edit_term],
		    [dbo].FNAGetGenericDate(min(sdd.term_start), '''+@user_login_id+''') as TermStart, 
			[dbo].FNAGetGenericDate(max(sdd.term_end), '''+@user_login_id+''') As TermEnd, max(source_deal_type.source_deal_type_name) As DealType, 
			max(source_deal_type_1.source_deal_type_name) AS DealSubType, 
		        max(dh.option_flag) As OptionFlag, max(dh.option_type) As OptionType, max(dh.option_excercise_type) As ExcersiceType,		
       
			max(dh.deal_category_value_id) as Category,max(dh.trader_id) as Trader,max(static_data_value1.code) as HedgeItemFlag,
			max(static_data_value2.code) as  HedgeType,
			max(case when header_buy_sell_flag=''s'' and assignment_type_value_id is not null then 
				sdv.code else 	
			case when header_buy_sell_flag=''s'' and assignment_type_value_id is null then
				''Sold'' else ''Banked'' end
			end) AssignType,
			max(t.physical_financial_flag) [PhysicalFinancial],	
			max(sdd.fixed_float_leg) [FixedFloat],
			max(td.commodity_id)[Curve Type],
			(
				CASE WHEN dh.deal_locked = ''y'' THEN ''y''
				ELSE 
					CASE WHEN dls.id IS NOT NULL THEN
						CASE WHEN DATEADD(mi, dls.hour * 60 + dls.minute, ISNULL(dh.update_ts, dh.create_ts)) < GETDATE() THEN ''y''
						ELSE ''n'' END
					ELSE ''n''
					END
				END
			)as [Deal Lock],
			dh.option_flag [Option Flag],
			case when MAX(source_Major_Location.location_name) is null then '''' else MAX(source_Major_Location.location_name) + '' -> '' end + sml.Location_Name as [LocationName],
			pcd.curve_name as [CurveName],
			MAX(t.internal_desk_id) as [InternalDeskId]
			FROM '+CASE WHEN isnull(@deleted_deal,'n')='y' then  'delete_source_deal_header' ELSE 'source_deal_header' END +' dh '+
					CASE WHEN  (@deal_id_from IS  NULL or @deal_id_to IS  NULL) AND @source_deal_header_id IS NOT NULL THEN 
							' inner join #tmp_source_deal_header_id t_dh on t_dh.item=dh.source_deal_header_id '
					ELSE '' END +
			' INNER JOIN ' +
			CASE WHEN  @deal_id_from IS NULL AND @deal_id IS NULL THEN 	' #books ' 	ELSE ' source_system_book_map ' END +
		'
			sbmp ON dh.source_system_book_id1 = sbmp.source_system_book_id1 
			AND dh.source_system_book_id2 = sbmp.source_system_book_id2 
			AND dh.source_system_book_id3 = sbmp.source_system_book_id3 
			AND dh.source_system_book_id4 = sbmp.source_system_book_id4 
			inner JOIN '+CASE WHEN isnull(@deleted_deal,'n')='y' then  'delete_source_deal_detail' ELSE 'source_deal_detail' END +' sdd ON sdd.source_deal_header_id=dh.source_deal_header_id
			LEFT OUTER JOIN source_counterparty ON dh.counterparty_id = source_counterparty.source_counterparty_id 
			LEFT OUTER JOIN source_traders ON dh.trader_id = source_traders.source_trader_id 
			LEFT OUTER JOIN source_deal_type ON dh.source_deal_type_id = source_deal_type.source_deal_type_id 
			LEFT OUTER JOIN source_book ON dh.source_system_book_id1 = source_book.source_book_id 
			LEFT OUTER JOIN source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id 
			LEFT OUTER JOIN source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id 
			LEFT OUTER JOIN source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id
		           
		    --INNER JOIN #source_system ss ON ss.source_system_id=dh.source_system_id
		    
			LEFT OUTER JOIN  portfolio_hierarchy ON portfolio_hierarchy.entity_id = sbmp.fas_book_id
			LEFT OUTER JOIN fas_strategy ON fas_strategy.fas_strategy_id=portfolio_hierarchy.parent_entity_id
			LEFT OUTER JOIN static_data_value  static_data_value1 ON sbmp.fas_deal_type_value_id=static_data_value1.value_id
			LEFT OUTER JOIN static_data_value  static_data_value2 ON fas_strategy.hedge_type_value_id=static_data_value2.value_id
			LEFT OUTER JOIN contract_group  cg1 ON cg1.contract_id=dh.contract_id
			left join dbo.source_deal_header_template t ON t.template_id=dh.template_id  
			left join dbo.source_deal_detail_template td ON td.template_id=td.template_id
			LEFT OUTER JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
			LEFT JOIN source_Major_Location ON sml.source_Major_Location_Id=source_Major_Location.source_major_location_ID
			left outer join source_price_curve_def pcd on pcd.source_curve_def_id=sdd.curve_id	
			LEFT JOIN (
				SELECT id, deal_type_id, hour, minute
				FROM deal_lock_setup dl
				INNER JOIN application_role_user aru ON dl.role_id = aru.role_id
				WHERE aru.user_login_id = dbo.FNADBUser()
			) dls ON dls.deal_type_id = source_deal_type.source_deal_type_id
						AND ISNULL(dh.deal_locked, ''n'') <> ''y''
			LEFT OUTER JOIN
		           source_deal_type source_deal_type_1 ON dh.deal_sub_type_type_id = source_deal_type_1.source_deal_type_id LEFT OUTER JOIN
			   fas_link_detail fld ON fld.source_deal_header_id = dh.source_deal_header_id 
			left outer join static_data_value sdv on sdv.value_id=dh.assignment_type_value_id
			left outer join rec_generator rg on rg.generator_id=dh.generator_id
			 ' +
			CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) OR (@gis_cert_date IS NOT NULL)
				THEN
					'LEFT OUTER JOIN gis_certificate gis ON gis.source_deal_header_id=sdd.source_deal_detail_id'
				ELSE '' END +
			CASE WHEN (@index_group IS NOT null) OR (@index IS NOT NULL)
				THEN
					'LEFT OUTER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id'
				ELSE '' END +
			'		
			   WHERE   1 = 1'


--	IF @deal_id_from IS NULL AND @deal_id IS NULL --only apply deal filters if deal id not given.
--	BEGIN
--	
--		IF @book_deal_type_map_id IS NOT NULL 
--			SET @sql_Select = @sql_Select + ' AND sbmp.book_deal_type_map_id in( ' + @book_deal_type_map_id + ')'
--	END

--    IF @source_deal_header_id IS NOT NULL 
--			SET @sql_Select = @sql_Select + ' AND dh.source_deal_header_id in( ' + @source_deal_header_id + ')'
	
	IF @sort_by='l'
		SET @sql_Select = @sql_Select +' Group BY dh.source_deal_header_id,dls.id,dls.hour,dls.minute,dh.deal_locked, dh.option_flag, dh.update_ts, dh.create_ts,sdd.formula_id,sdd.price_adder2,sdd.price_adder_currency2,sdd.volume_multiplier2,sml.Location_Name,pcd.curve_name) aa  order by [Deal Date] desc,id desc '
	ELSE
		SET @sql_Select = @sql_Select +' Group BY dh.source_deal_header_id ,dls.id,dls.hour,dls.minute,dh.deal_locked, dh.option_flag, dh.update_ts, dh.create_ts,sdd.formula_id,sdd.price_adder2,sdd.price_adder_currency2,sdd.volume_multiplier2,sml.Location_Name,pcd.curve_name)bb  order by [Deal Date] asc,id asc'

		PRINT @sql_Select
		EXEC(@sql_Select)


END
IF @flag='n'
BEGIN

	SET @sql_Select = 
			'SELECT [ID],[RefID],[dbo].FNAGetGenericDate(deal_date, '''+@user_login_id+''') as Date,[ExtId],[PhysicalFinancialFlag] ,[CptyName],
					[TermStart] ,[TermEnd] ,[DealType],[DealSubType],[OptionFlag],[OptionType],[ExcersiceType],
					['+ @group1 +'],['+ @group2 +']   ,['+ @group3 +'],['+ @group4 +'],[Desc1],[Desc2],[Desc3],
					[DealCategoryValueId],[TraderName],[HedgeItemFlag],[HedgeType],[AssignType],[legal_entity],
					[deal_locked], [Pricing] 
			FROM (SELECT  distinct 
			dbo.FNAHyperLinkText(10131000, cast(dh.source_deal_header_id as varchar), dh.source_deal_header_id) ID,							
--							dh.source_deal_header_id AS ID,
							dh.deal_id AS RefID,dh.deal_date,
 						  dh.ext_deal_id as ExtId,
					CASE 
					WHEN dh.physical_financial_flag =''p'' THEN ''Physical''
						ELSE ''Financial''
					END	as PhysicalFinancialFlag, 
					source_counterparty.counterparty_name CptyName,[dbo].FNAGetGenericDate(dh.entire_term_start, '''+@user_login_id+''') as TermStart, 
					[dbo].FNAGetGenericDate(dh.entire_term_end, '''+@user_login_id+''') As TermEnd, source_deal_type.source_deal_type_name As DealType, 
					source_deal_type_1.source_deal_type_name AS DealSubType,dh.option_flag As OptionFlag, dh.option_type As OptionType, 
					dh.option_excercise_type As ExcersiceType,source_book.source_book_name As ['+ @group1 +'], 
					source_book_1.source_book_name AS ['+ @group2 +'],source_book_2.source_book_name AS ['+ @group3 +'], 
					source_book_3.source_book_name AS ['+ @group4 +'],dh.description1 As Desc1, dh.description2 As Desc2,
					dh.description3 as Desc3,dh.deal_category_value_id as DealCategoryValueId,source_traders.trader_name as TraderName,
					static_data_value1.code as HedgeItemFlag,static_data_value2.code as  HedgeType,
					CASE 
					WHEN header_buy_sell_flag=''s'' AND assignment_type_value_id is not null 
					THEN sdv.code else 	
					CASE 
					WHEN header_buy_sell_flag=''s'' AND assignment_type_value_id is null 
					THEN ''Sold'' else ''Banked'' end
					END 
				AssignType,dh.legal_entity ,deal_locked,dh.pricing
				,dh.update_ts as [UpdateTS]
				,dh.update_user
			FROM       source_deal_header dh 
			 INNER JOIN ' +
			CASE WHEN  @deal_id_from IS NULL AND @deal_id IS NULL THEN 	' #books ' 	ELSE ' source_system_book_map ' END +
		'
			sbmp ON dh.source_system_book_id1 = sbmp.source_system_book_id1 
			AND dh.source_system_book_id2 = sbmp.source_system_book_id2 
			AND dh.source_system_book_id3 = sbmp.source_system_book_id3 
			AND dh.source_system_book_id4 = sbmp.source_system_book_id4 			
			--INNER JOIN #source_system ss ON ss.source_system_id=dh.source_system_id
			LEFT OUTER JOIN source_counterparty ON dh.counterparty_id = source_counterparty.source_counterparty_id 
			LEFT OUTER JOIN source_traders ON dh.trader_id = source_traders.source_trader_id 
			LEFT OUTER JOIN source_deal_type ON dh.source_deal_type_id = source_deal_type.source_deal_type_id 
			LEFT OUTER JOIN source_book ON dh.source_system_book_id1 = source_book.source_book_id 
			LEFT OUTER JOIN source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id 
			LEFT OUTER JOIN source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id 
			LEFT OUTER JOIN source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id 
			LEFT OUTER JOIN  portfolio_hierarchy ON portfolio_hierarchy.entity_id = sbmp.fas_book_id
			LEFT OUTER JOIN fas_strategy ON fas_strategy.fas_strategy_id=portfolio_hierarchy.parent_entity_id
			LEFT OUTER JOIN static_data_value  static_data_value1 ON sbmp.fas_deal_type_value_id=static_data_value1.value_id
			LEFT OUTER JOIN static_data_value  static_data_value2 ON fas_strategy.hedge_type_value_id=static_data_value2.value_id
		
			LEFT OUTER JOIN source_deal_type source_deal_type_1 ON dh.deal_sub_type_type_id = source_deal_type_1.source_deal_type_id 
			LEFT OUTER JOIN fas_link_detail fld ON fld.source_deal_header_id = dh.source_deal_header_id 
			LEFT OUTER JOIN static_data_value sdv ON sdv.value_id=dh.assignment_type_value_id
			LEFT OUTER JOIN rec_generator rg ON rg.generator_id=dh.generator_id
			
			' +
			CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) OR (@gis_cert_date IS NOT NULL) 
			THEN
				'LEFT OUTER JOIN source_deal_detail sdd ON sdd.source_deal_header_id=dh.source_deal_header_id '
			ELSE '' END +
			
			CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) OR (@gis_cert_date IS NOT NULL)
				THEN
					'LEFT OUTER JOIN gis_certificate gis ON gis.source_deal_header_id=sdd.source_deal_detail_id'
				ELSE '' END +
			'			
			
			   WHERE   1 = 1 '


	--IF ONE deal id is known make the other the same
	IF @deal_id_to IS NULL AND @deal_id_from IS NOT NULL
		SET @deal_id_to = @deal_id_from

	IF @deal_id_from IS NULL AND @deal_id_to IS NOT NULL
		SET @deal_id_from = @deal_id_to

	IF (@deal_id_from IS NOT NULL) AND (@deal_id_to IS NOT NULL) 
		SET @sql_Select = @sql_Select + ' AND dh.source_deal_header_id BETWEEN ' + CAST(@deal_id_from AS VARCHAR)  + ' AND ' + CAST(@deal_id_to AS VARCHAR) 


	IF (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL)
		SET @sql_Select = @sql_Select +' AND ('+ @gis_cert_number + ' between gis.certificate_number_from_int   
		AND  gis.certificate_number_to_int AND ' +
			@gis_cert_number_to + ' between gis.certificate_number_from_int   
		AND  gis.certificate_number_to_int)'

	IF @deal_id IS NOT NULL 
			SET @sql_Select = @sql_Select + ' AND dh.deal_id like ''' + @deal_id + '%'''

	IF @deal_id_from IS NULL AND @deal_id IS NULL --only apply deal filters if deal id not given.
	BEGIN
	
--		IF @book_deal_type_map_id IS NOT NULL 
--			SET @sql_Select = @sql_Select + ' AND sbmp.book_deal_type_map_id in( ' + @book_deal_type_map_id + ')'

		IF (@deal_date_from IS NOT NULL) AND (@deal_date_to IS NOT NULL) 
			SET @sql_Select = @sql_Select + ' AND dh.deal_date BETWEEN '''+ @deal_date_from + ''' and ''' + @deal_date_to + ''''
		
		IF (@physical_financial_flag IS NOT NULL)
			SET @sql_Select = @sql_Select + ' AND dh.physical_financial_flag='''+@physical_financial_flag+''''
		
		IF (@counterparty_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.counterparty_id='+CAST(@counterparty_id AS VARCHAR)

		IF (@entire_term_start IS NOT NULL)
			SET @sql_Select = @sql_Select+ ' AND dh.entire_term_start='''+@entire_term_start+''''

		IF (@entire_term_end IS NOT NULL)
			SET @sql_Select = @sql_Select+ ' AND dh.entire_term_end='''+@entire_term_end+''''

		IF (@source_deal_type_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.source_deal_type_id='+CAST(@source_deal_type_id  AS VARCHAR)

		IF (@deal_sub_type_type_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.deal_sub_type_type_id='+CAST(@deal_sub_type_type_id  AS VARCHAR)

		IF (@deal_category_value_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.deal_category_value_id='+CAST(@deal_category_value_id  AS VARCHAR)

		IF (@trader_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.trader_id='+CAST(@trader_id  AS VARCHAR)

--		IF (@description1 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND dh.description1 like ''%'+@description1+'%'''
--
--		IF (@description2 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND dh.description2 like ''%'+@description2+'%'''
--
--		IF (@description3 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND dh.description3 like ''%'+@description3+'%'''


--		IF (@description1 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND source_book.source_book_id = '+@description1
--
--		IF (@description2 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND source_book_1.source_book_id = '+@description2
--
--		IF (@description3 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND source_book_2.source_book_id = '+@description3
--
--		IF (@description4 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND source_book_3.source_book_id = '+@description4



		IF (@structured_deal_id  IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.structured_deal_id like ''%'+@structured_deal_id +'%'''

		IF (@header_buy_sell_flag IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.header_buy_sell_flag='''+ @header_buy_sell_flag + ''''


		IF (@deal_locked IS NOT NULL )
			SET @sql_Select = @sql_Select + ' AND dh.deal_locked='''+@deal_locked+''''	

		IF (@update_date_from IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.update_ts>='''+CAST(@update_date_from  AS VARCHAR)+''''

		IF (@update_date_to IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.update_ts<='''+CAST(@update_date_to  AS VARCHAR)+''''

		IF (@update_by IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.update_user='''+CAST(@update_by  AS VARCHAR)+''''

	END


		----====Added the following filter for REC deals
		--print 'no' 

	--if one cert is known and other not known make the same		
	IF @gis_cert_number_to IS NULL AND @gis_cert_number IS NOT NULL
		SET @gis_cert_number_to = @gis_cert_number

	IF @gis_cert_number IS NULL AND @gis_cert_number_to IS NOT NULL
		SET @gis_cert_number = @gis_cert_number_to
	
	IF @gis_cert_number IS NULL 
	BEGIN

		IF (@generator_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.generator_id='+CAST(@generator_id  AS VARCHAR)
		IF (@status_value_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.status_value_id='+CAST(@status_value_id  AS VARCHAR)
		IF (@status_date IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.status_date='''+ dbo.FNAGetSQLStandardDate(@status_date) + ''''
		IF (@assignment_type_value_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND isnull(dh.assignment_type_value_id, 5149) ='+CAST(@assignment_type_value_id  AS VARCHAR)
		IF (@compliance_year IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.compliance_year='+CAST(@compliance_year  AS VARCHAR)
		IF (@state_value_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.state_value_id='+CAST(@state_value_id  AS VARCHAR)
		IF (@assigned_date IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.assigned_date='''+ dbo.FNAGetSQLStandardDate(@assigned_date) + ''''
		IF (@assigned_by IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.assigned_by='''+ @assigned_by + ''''
		IF @gis_value_id IS NOT NULL
			SET @sql_Select = @sql_Select +' AND rg.gis_value_id='+ CAST(@gis_value_id AS VARCHAR)
		IF @gen_cert_date IS NOT NULL
			SET @sql_Select = @sql_Select +' AND rg.registration_date='''+ @gen_cert_date +''''
		IF @gen_cert_number IS NOT NULL
			SET @sql_Select = @sql_Select +' AND rg.gis_account_number='''+ @gen_cert_number +''''
		IF @gis_cert_date IS NOT NULL
			SET @sql_Select = @sql_Select +' AND gis.gis_cert_date='''+ @gis_cert_date +''''

	END
	IF @sort_by='l'
		SET @sql_Select = @sql_Select +') aa order by deal_date desc,id desc'
	ELSE
		SET @sql_Select = @sql_Select +')bb order by deal_date asc,id asc'

		PRINT @sql_Select

		EXEC(@sql_Select)
		--If @@ERROR <> 0

--		Exec spa_ErrorHandler @@ERROR, 'Source Deal Header  table', 

--				'spa_sourcedealheader', 'DB Error', 



--				'Failed to select source deal header record.', ''

--		Else

--		Exec spa_ErrorHandler 0, 'Source Deal Header  table', 

--				'spa_sourcedealheader', 'Success', 

--				'Source deal header record successfully selected.', ''
END
IF @flag='t'
	BEGIN
	SET @sql_Select = 
			'SELECT [ID],[RefID],[dbo].FNAGetGenericDate(deal_date, '''+@user_login_id+''') as [Deal Date],[ExtId],[PhysicalFinancialFlag] as [Physical/Financial Flag] ,
					[CptyName] as [Counterparty],
					[TermStart] ,[TermEnd] ,[DealType],[DealSubType],[OptionFlag],[OptionType],[ExcersiceType],
					['+ @group1 +'],['+ @group2 +']   ,['+ @group3 +'],['+ @group4 +'],[Desc1],[Desc2],[Desc3],
					[DealCategoryValueId] as [Deal Category],[TraderName],[HedgeItemFlag] as [Hedge/Item Flag],[HedgeType],[AssignType],[legal_entity],
					[deal_locked], [Pricing],[Created Date],ConfirmStatus,[Signed Off By],[Sign Off Date] as [Signed Off Date],[Broker],[Comments]
					

			FROM (
					SELECT  distinct dh.source_deal_header_id AS ID,dh.deal_id AS RefID,dh.deal_date,
 						  dh.ext_deal_id as ExtId,
					CASE 
					WHEN dh.physical_financial_flag =''p'' THEN ''Physical''
						ELSE ''Financial''
					END	as PhysicalFinancialFlag, 
					source_counterparty.counterparty_name CptyName,[dbo].FNAGetGenericDate(dh.entire_term_start, '''+@user_login_id+''') as TermStart, 
					[dbo].FNAGetGenericDate(dh.entire_term_end, '''+@user_login_id+''') As TermEnd, source_deal_type.source_deal_type_name As DealType, 
					source_deal_type_1.source_deal_type_name AS DealSubType,[dbo].FNAGetAbbreviationDef(dh.option_flag) As OptionFlag, [dbo].FNAGetAbbreviationDef(dh.option_type) As OptionType, 
					[dbo].FNAGetAbbreviationDef(dh.option_excercise_type) As ExcersiceType,source_book.source_book_name As ['+ @group1 +'], 
					source_book_1.source_book_name AS ['+ @group2 +'],source_book_2.source_book_name AS ['+ @group3 +'], 
					source_book_3.source_book_name AS ['+ @group4 +'],dh.description1 As Desc1, dh.description2 As Desc2,
					dh.description3 as Desc3,static_data_value3.code as DealCategoryValueId,source_traders.trader_name as TraderName,
					static_data_value1.code as HedgeItemFlag,static_data_value2.code as  HedgeType,
					CASE 
					WHEN header_buy_sell_flag=''s'' AND assignment_type_value_id is not null 
					THEN sdv.code else 	
					CASE 
					WHEN header_buy_sell_flag=''s'' AND assignment_type_value_id is null 
					THEN ''Sold'' else ''Banked'' end
					END 
				AssignType,dh.legal_entity
				,(
					CASE WHEN deal_locked = ''y'' THEN ''Yes''
					ELSE 
						CASE WHEN dls.id IS NOT NULL THEN
							CASE WHEN DATEADD(mi, dls.hour * 60 + dls.minute, ISNULL(dh.update_ts, dh.create_ts)) < GETDATE() THEN ''Yes''
							ELSE ''No'' END
						ELSE ''No''
						END
					END
				) AS deal_locked
				,dh.pricing
				,dh.update_ts as [UpdateTS]
				,dh.update_user		
				,sdv_confirm.code ConfirmStatus
				,[dbo].FNAConvertGenericTimezone(dh.create_ts,'+ISNULL(cast(@time_zone_from AS VARCHAR), 'NULL') +','+ ISNULL(CAST(@time_zone_to AS VARCHAR), 'NULL') + ','''+@user_login_id+''',0) as [Created Date]
				,dh.verified_by [Signed Off By],
				[dbo].FNAGetGenericDate(dh.verified_date,'''+ @user_login_id+''') [Sign Off Date],
				scp.counterparty_name AS [Broker],
				t.comments AS [Comments]
			FROM '
            + CASE WHEN ISNULL(@deleted_deal,'n')='y' THEN 'delete_source_deal_header' ELSE 'source_deal_header' END + ' dh ' +
			 ' INNER JOIN #books' +
			--CASE WHEN  @deal_id_from IS NULL AND @deal_id IS NULL THEN 	' #books ' 	ELSE ' source_system_book_map ' END +
			'
			sbmp ON dh.source_system_book_id1 = sbmp.source_system_book_id1 
			AND dh.source_system_book_id2 = sbmp.source_system_book_id2 
			AND dh.source_system_book_id3 = sbmp.source_system_book_id3 
			AND dh.source_system_book_id4 = sbmp.source_system_book_id4 			
			--INNER JOIN #source_system ss ON ss.source_system_id=dh.source_system_id
			LEFT OUTER JOIN source_counterparty ON dh.counterparty_id = source_counterparty.source_counterparty_id 
			LEFT OUTER JOIN source_counterparty AS scp ON dh.broker_id = scp.source_counterparty_id 
			LEFT OUTER JOIN source_traders ON dh.trader_id = source_traders.source_trader_id 
			LEFT OUTER JOIN source_deal_type ON dh.source_deal_type_id = source_deal_type.source_deal_type_id 
			LEFT OUTER JOIN source_book ON dh.source_system_book_id1 = source_book.source_book_id 
			LEFT OUTER JOIN source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id 
			LEFT OUTER JOIN source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id 
			LEFT OUTER JOIN source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id 
			LEFT OUTER JOIN  portfolio_hierarchy ON portfolio_hierarchy.entity_id = sbmp.fas_book_id
			LEFT OUTER JOIN fas_strategy ON fas_strategy.fas_strategy_id=portfolio_hierarchy.parent_entity_id
			LEFT OUTER JOIN static_data_value  static_data_value1 ON sbmp.fas_deal_type_value_id=static_data_value1.value_id
			LEFT OUTER JOIN static_data_value  static_data_value2 ON fas_strategy.hedge_type_value_id=static_data_value2.value_id
			LEFT OUTER JOIN static_data_value  static_data_value3 ON static_data_value3.value_id = dh.deal_category_value_id
			LEFT OUTER JOIN static_data_value  static_data_value4 ON static_data_value4.value_id = dh.deal_status
			LEFT OUTER JOIN source_deal_type source_deal_type_1 ON dh.deal_sub_type_type_id = source_deal_type_1.source_deal_type_id 
			LEFT OUTER JOIN fas_link_detail fld ON fld.source_deal_header_id = dh.source_deal_header_id 
			LEFT OUTER JOIN static_data_value sdv ON sdv.value_id=dh.assignment_type_value_id
			LEFT OUTER JOIN rec_generator rg ON rg.generator_id=dh.generator_id
			' +
--			CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) OR (@gis_cert_date IS NOT NULL) 
--			THEN
--				' LEFT OUTER JOIN source_deal_detail sdd ON sdd.source_deal_header_id=dh.source_deal_header_id '
--			ELSE '' END +
			CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) OR (@gis_cert_date IS NOT NULL) OR (@location IS NOT NULL) OR (@index_group IS NOT null) OR (@index IS NOT NULL)
			THEN
				'LEFT OUTER JOIN ' +CASE WHEN isnull(@deleted_deal,'n')='y' then  'delete_source_deal_detail' ELSE 'source_deal_detail' END +' sdd ON sdd.source_deal_header_id=dh.source_deal_header_id '
			ELSE '' END +
			CASE WHEN (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL) OR (@gis_cert_date IS NOT NULL)
				THEN
					' LEFT OUTER JOIN gis_certificate gis ON gis.source_deal_header_id=sdd.source_deal_detail_id'
				ELSE '' END +
			
			CASE WHEN (@index_group IS NOT null) OR (@index IS NOT NULL)
				THEN
					' LEFT OUTER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id'
				ELSE '' END +
			CASE WHEN (@location IS NOT NULL)
				THEN
					' LEFT OUTER JOIN source_minor_location sml ON sml.source_minor_location_id=sdd.location_id'
				ELSE '' END +
			'
			LEFT OUTER JOIN confirm_status_recent csr ON csr.source_deal_header_id = dh.source_deal_header_id
			LEFT OUTER JOIN static_data_value sdv_confirm ON sdv_confirm.value_id = ISNULL(csr.type,17200) 
			LEFT OUTER JOIN dbo.source_deal_header_template t ON t.template_id=dh.template_id  
			LEFT OUTER JOIN dbo.source_deal_detail_template dt ON dt.template_id=dh.template_id
			LEFT OUTER JOIN source_commodity sc ON sc.source_commodity_id=dt.commodity_id
			LEFT OUTER JOIN static_data_value sdv2 ON sdv2.value_id=dh.block_type
			LEFT JOIN (
				SELECT id, deal_type_id, hour, minute
				FROM deal_lock_setup dl
				INNER JOIN application_role_user aru ON dl.role_id = aru.role_id
				WHERE aru.user_login_id = dbo.FNADBUser()
			) dls ON dls.deal_type_id = source_deal_type.source_deal_type_id
						AND ISNULL(dh.deal_locked, ''n'') <> ''y''
		WHERE   1 = 1 '


	IF ISNULL(@blotter,'n')='y'
			SET @sql_Select = @sql_Select + ' AND blotter_supported =''y'''
			
	

	--IF ONE deal id is known make the other the same
/*
		IF (@created_date_from IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dbo.FNAConvertTZAwareDateFormat(dh.create_ts,1)>='''+CONVERT(VARCHAR(10),@created_date_from,120) +''''
			--SET @sql_Select = @sql_Select +' AND convert(varchar(10),dh.create_ts,120)>='''+convert(varchar(10),@created_date_from,120) +''''
			--dbo.FNACovertToSTDDate(dbo.FNADateTimeFormat(

		IF (@created_date_to IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dbo.FNAConvertTZAwareDateFormat(dh.create_ts,1) <='''+CONVERT(VARCHAR(10),@created_date_to,120) +''''
			--SET @sql_Select = @sql_Select +' AND convert(varchar(10),dh.create_ts,120) <='''+convert(varchar(10),@created_date_to,120) +''''
*/
		IF (@created_date_from IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.create_ts>='''+CONVERT(VARCHAR(10),[dbo].[FNAConvertTimezone](@created_date_from,1),120) +''''
			
		IF (@created_date_to IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.create_ts <'''+CONVERT(VARCHAR(10),[dbo].[FNAConvertTimezone](@created_date_to+1,1),120) +''''


	IF @deal_id_to IS NULL AND @deal_id_from IS NOT NULL
		SET @deal_id_to = @deal_id_from

	IF @deal_id_from IS NULL AND @deal_id_to IS NOT NULL
		SET @deal_id_from = @deal_id_to

	IF (@deal_id_from IS NOT NULL) AND (@deal_id_to IS NOT NULL) 
		SET @sql_Select = @sql_Select + ' AND dh.source_deal_header_id BETWEEN ' + CAST(@deal_id_from AS VARCHAR)  + ' AND ' + CAST(@deal_id_to AS VARCHAR) 

	IF (@gis_cert_number IS NOT NULL AND @gis_cert_number_to IS NOT NULL)
		SET @sql_Select = @sql_Select +' AND ('+ @gis_cert_number + ' between gis.certificate_number_from_int   
		AND  gis.certificate_number_to_int AND ' +
			@gis_cert_number_to + ' between gis.certificate_number_from_int   
		AND  gis.certificate_number_to_int)'

	IF @deal_id IS NOT NULL 
			SET @sql_Select = @sql_Select + ' AND dh.deal_id like ''' + @deal_id + '%'''

	IF @deal_id_from IS NULL AND @deal_id IS NULL --only apply deal filters if deal id not given.
	BEGIN
	
		IF @index_group IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND spcd.index_group='+CAST(@index_group AS VARCHAR)

		IF @index IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND spcd.source_curve_def_id='+CAST(@index AS VARCHAR)
		
		IF @location IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND sml.source_minor_location_id='+CAST(@location AS VARCHAR)

		IF @commodity IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND sc.source_commodity_id='+CAST(@commodity AS VARCHAR)

		
		IF @block_type IS NOT NULL
			SET @sql_Select = @sql_Select + ' AND sdv2.value_id='+CAST(@block_type AS VARCHAR)
		

	IF @confirm_type IS NOT NULL  -- exceptions)
	BEGIN
		IF (@confirm_type = 'n')
			SET @sql_Select = @sql_Select +' AND csr.type IS NULL OR csr.type=''n'''
		ELSE
			SET @sql_Select = @sql_Select +' AND ISNULL(csr.type,''n'') IN (''' + @confirm_type + ''') '
	END

		
		IF @deal_status IS NOT NULL 
			SET @sql_Select = @sql_Select + ' AND static_data_value4.value_id ='+CAST(@deal_status AS VARCHAR)
--		IF @book_deal_type_map_id IS NOT NULL 
--			SET @sql_Select = @sql_Select + ' AND sbmp.book_deal_type_map_id in( ' + @book_deal_type_map_id + ')'

		IF (@deal_date_from IS NOT NULL) AND (@deal_date_to IS NOT NULL) 
			SET @sql_Select = @sql_Select + ' AND dh.deal_date BETWEEN '''+ @deal_date_from + ''' and ''' + @deal_date_to + ''''
		
		IF (@physical_financial_flag IS NOT NULL)
			SET @sql_Select = @sql_Select + ' AND dh.physical_financial_flag='''+@physical_financial_flag+''''
		
		IF (@counterparty_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.counterparty_id='+CAST(@counterparty_id AS VARCHAR)

		IF (@entire_term_start IS NOT NULL)
			SET @sql_Select = @sql_Select+ ' AND dh.entire_term_start>='''+@entire_term_start+''''

		IF (@entire_term_end IS NOT NULL)
			SET @sql_Select = @sql_Select+ ' AND dh.entire_term_end<='''+@entire_term_end+''''

		IF (@source_deal_type_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.source_deal_type_id='+CAST(@source_deal_type_id  AS VARCHAR)

		IF (@deal_sub_type_type_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.deal_sub_type_type_id='+CAST(@deal_sub_type_type_id  AS VARCHAR)

		IF (@deal_category_value_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.deal_category_value_id='+CAST(@deal_category_value_id  AS VARCHAR)

		IF (@trader_id IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.trader_id='+CAST(@trader_id  AS VARCHAR)





-- Begin : Log Id 399
--		IF (@description1 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND dh.description1 like ''%'+@description1+'%'''
--
--		IF (@description2 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND dh.description2 like ''%'+@description2+'%'''
--
--		IF (@description3 IS NOT NULL)
--			SET @sql_Select = @sql_Select +' AND dh.description3 like ''%'+@description3+'%'''

		IF (@description1 IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND source_book.source_book_name like '''+@description1+''''

		IF (@description2 IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND source_book_1.source_book_name like '''+@description2+''''

		IF (@description3 IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND source_book_2.source_book_name like '''+@description3+''''

		IF (@description4 IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND source_book_3.source_book_name like '''+@description4+''''
-- End  : Log Id 399

		IF (@structured_deal_id  IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.structured_deal_id like ''%'+@structured_deal_id +'%'''

		IF (@header_buy_sell_flag IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.header_buy_sell_flag='''+ @header_buy_sell_flag + ''''


		IF (@deal_locked IS NOT NULL )
			SET @sql_Select = @sql_Select + ' AND dh.deal_locked='''+@deal_locked+''''	


		IF (@update_date_from IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.update_ts>='''+CAST(@update_date_from  AS VARCHAR)+''''

		IF (@update_date_to IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.update_ts<='''+CAST(@update_date_to  AS VARCHAR)+''''

		IF (@update_by IS NOT NULL)
			SET @sql_Select = @sql_Select +' AND dh.update_user='''+CAST(@update_by  AS VARCHAR)+''''
	
	
		IF @broker IS NOT NULL 
		BEGIN
			SET @sql_Select = @sql_Select + ' AND dh.broker_id = ' + @broker
		END

		----====Added the following filter for REC deals
		--print 'no' 

		--if one cert is known and other not known make the same		
		IF @gis_cert_number_to IS NULL AND @gis_cert_number IS NOT NULL
			SET @gis_cert_number_to = @gis_cert_number

		IF @gis_cert_number IS NULL AND @gis_cert_number_to IS NOT NULL
			SET @gis_cert_number = @gis_cert_number_to



		
		IF @gis_cert_number IS NULL 
		BEGIN

			IF (@generator_id IS NOT NULL)
				SET @sql_Select = @sql_Select +' AND dh.generator_id='+CAST(@generator_id  AS VARCHAR)
			IF (@status_value_id IS NOT NULL)
				SET @sql_Select = @sql_Select +' AND dh.status_value_id='+CAST(@status_value_id  AS VARCHAR)
			IF (@status_date IS NOT NULL)
				SET @sql_Select = @sql_Select +' AND dh.status_date='''+ dbo.FNAGetSQLStandardDate(@status_date) + ''''
			IF (@assignment_type_value_id IS NOT NULL)
				SET @sql_Select = @sql_Select +' AND isnull(dh.assignment_type_value_id, 5149) ='+CAST(@assignment_type_value_id  AS VARCHAR)
			IF (@compliance_year IS NOT NULL)
				SET @sql_Select = @sql_Select +' AND dh.compliance_year='+CAST(@compliance_year  AS VARCHAR)
			IF (@state_value_id IS NOT NULL)
				SET @sql_Select = @sql_Select +' AND dh.state_value_id='+CAST(@state_value_id  AS VARCHAR)
			IF (@assigned_date IS NOT NULL)
				SET @sql_Select = @sql_Select +' AND dh.assigned_date='''+ dbo.FNAGetSQLStandardDate(@assigned_date) + ''''
			IF (@assigned_by IS NOT NULL)
				SET @sql_Select = @sql_Select +' AND dh.assigned_by='''+ @assigned_by + ''''
			IF @gis_value_id IS NOT NULL
				SET @sql_Select = @sql_Select +' AND rg.gis_value_id='+ CAST(@gis_value_id AS VARCHAR)
			IF @gen_cert_date IS NOT NULL
				SET @sql_Select = @sql_Select +' AND rg.registration_date='''+ @gen_cert_date +''''
			IF @gen_cert_number IS NOT NULL
				SET @sql_Select = @sql_Select +' AND rg.gis_account_number='''+ @gen_cert_number +''''
			IF @gis_cert_date IS NOT NULL
				SET @sql_Select = @sql_Select +' AND gis.gis_cert_date='''+ @gis_cert_date +''''

		END
	
	END
	
	IF @sort_by='l'
		SET @sql_Select = @sql_Select +') aa order by id desc'
	ELSE
		SET @sql_Select = @sql_Select +')bb order by id asc'

		PRINT @sql_Select		
		EXEC(@sql_Select)
		RETURN 
		--If @@ERROR <> 0

--		Exec spa_ErrorHandler @@ERROR, 'Source Deal Header  table', 

--				'spa_sourcedealheader', 'DB Error', 



--				'Failed to select source deal header record.', ''

--		Else

--		Exec spa_ErrorHandler 0, 'Source Deal Header  table', 

--				'spa_sourcedealheader', 'Success', 

--				'Source deal header record successfully selected.', ''


END



ELSE IF @flag ='v' 
BEGIN
  DECLARE @st AS VARCHAR(MAX)

  SET @st='SELECT dh.source_deal_header_id ,dh.source_system_id ,dh.deal_id, 
		[dbo].FNAGetGenericDate(dh.deal_date, '''+@user_login_id+''') DealDate,
 		dh.ext_deal_id ,dh.physical_financial_flag, 
		dh.counterparty_id, 
		[dbo].FNAGetGenericDate(dh.entire_term_start, '''+@user_login_id+''') TermStart, 
		[dbo].FNAGetGenericDate(dh.entire_term_end, '''+@user_login_id+''') TermEnd, dh.source_deal_type_id, 
		dh.deal_sub_type_type_id, 
		dh.option_flag, dh.option_type, dh.option_excercise_type, 
		source_book.source_book_name As Group1, 
		source_book_1.source_book_name AS Group2, 
	        source_book_2.source_book_name AS Group3, source_book_3.source_book_name AS Group4,
		dh.description1,dh.description2,dh.description3,
		dh.deal_category_value_id,dh.trader_id, source_system_book_map.fas_book_id,portfolio_hierarchy.parent_entity_id,
		fas_strategy.hedge_type_value_id,static_data_value1.code as HedgeItemFlag,
			static_data_value2.code as HedgeType,source_currency.currency_name as Currency,
		dh.internal_deal_type_value_id,dh.internal_deal_subtype_value_id,dh.template_id,source_currency.source_system_id,
		dh.header_buy_sell_flag,dh.broker_id,dh.rolling_avg,contract_id,
		source_system_book_map.book_deal_type_map_id,dh.legal_entity 
		FROM       source_deal_header dh INNER JOIN
		source_book ON dh.source_system_book_id1 = source_book.source_book_id INNER JOIN
		source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id INNER JOIN
		source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id INNER JOIN
		source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id
		left join source_system_book_map on  source_system_book_map.source_system_book_id1= source_book.source_book_id 
		and source_system_book_map.source_system_book_id2= source_book_1.source_book_id 
		and source_system_book_map.source_system_book_id3= source_book_2.source_book_id 
		and source_system_book_map.source_system_book_id4= source_book_3.source_book_id 

		left join  portfolio_hierarchy ON portfolio_hierarchy.entity_id = source_system_book_map.fas_book_id
		left join fas_strategy ON fas_strategy.fas_strategy_id=portfolio_hierarchy.parent_entity_id
		left join static_data_value  static_data_value1 ON source_system_book_map.fas_deal_type_value_id=static_data_value1.value_id
		left join static_data_value  static_data_value2 ON fas_strategy.hedge_type_value_id=static_data_value2.value_id
		left  join fas_subsidiaries on fas_subsidiaries.fas_subsidiary_id='+CAST(@sub_id AS VARCHAR)+'
		left join source_currency   ON fas_subsidiaries.func_cur_value_id=source_currency.source_currency_id
       where dh.source_deal_header_id in ('+CAST(@source_deal_header_id AS VARCHAR) +')'
		 --and source_system_book_map.fas_book_id = @book_id

	PRINT @st
	EXEC(@st)
END
ELSE IF @flag='e'	-- vErified by
BEGIN

	UPDATE source_deal_header 
	SET
		verified_by = dbo.FNADBUser(),
		verified_date = GETDATE()
	WHERE source_deal_header_id = @source_deal_header_id

	IF @@ERROR <> 0
	BEGIN	
	EXEC spa_ErrorHandler @@ERROR, 'Failed Verifying the Trade Ticket', 

			'spa_sourcedealheader', 'DB Error', 

			'Failed Verifying the Trade Ticket', 'Failed Verifying the Trade Ticket'
	END
	ELSE
	BEGIN
	EXEC spa_ErrorHandler 0, 'Source Deal Header table', 

		'spa_sourcedealheader', 'Success', 

		'Trade Ticket Verified', ''
	END

END



GO

/****** Object:  StoredProcedure [dbo].[spa_source_deal_header_template]    Script Date: 12/06/2011 23:36:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





/**************************************************
* Modified By: Pawan KC 
* Modified Date :31 March 2009
* Description :Added two Parameters @rollover_to_spot,@discounting_applies as added in the table source_deal_header_template.
*				Made Necessary changes in all the blocks 's','i','u','c' in the store procedure.
****************************************************/


create proc [dbo].[spa_source_deal_header_template]
		@flag char(1),
		@template_id int = NULL,
		@template_name as VarChar(50)= NULL,
		@physical_financial_flag as char(1)=NULL,
		@term_frequency_value as char(1) =NULL,
		@term_frequency_type as char(1) =NULL,
		@option_flag as char(1)  =NULL,
		@option_type as Char(1)  =NULL,
		@option_exercise_type as char(1)  =NULL,
		@description1 varchar(50) = NULL,
		@description2 varchar(50) = NULL,
		@description3 varchar(50) = NULL,
		@buy_sell_flag char(1)  =NULL,
		@source_deal_type_id int  =NULL,
		@deal_sub_type_type_id int  =NULL,
		@is_active char(1) =NULL,
		@internal_flag char(1)=NULL,
		@internal_deal_type_value_id int=NULL,
		@internal_deal_subtype_value_id int=NULL,
		@allow_edit_term char(1)=NULL,
		@blotter_support char(1)=NULL,
		@rollover_to_spot char(1)=NULL,
		@discounting_applies char(1)=NULL,
		@term_end_flag char(1)=NULL,
		@is_public char(1) =NULL,
		@deal_status int=NULL,
		@deal_category_value_id int=NULL,
		@legal_entity int=NULL,
		@commodity_id int=NULL,
		@internal_portfolio_id int=NULL,
		@product_id int=NULL,
		@internal_desk_id int=NULL,
		@blocktypecombo int=NULL,
		@blockdefinitioncombo int=NULL,
		@granularitycombo int=NULL,
		@price int=NULL,
		@model_id int=NULL,
		@comments CHAR(1)=NULL,
		@trade_ticket_template CHAR(1) = NULL,
		@hourly_position_breakdown CHAR(1) = NULL,
		@counterparty_id INT = NULL,
		@contract_id INT = NULL,
		@fieldTemplateId INT = NULL,
		@trader_id int=NULL

AS

Declare @deal_temp_id int

SET NOCOUNT ON

if @flag='s' 
begin
	declare @sql_stmt varchar(5000)
	set @sql_stmt='select 
	a.template_id as TemplateID,
	--REPLACE(dbo.FNAHyperLinkText2(10101400,  a.template_name , a.template_id,source_deal_type.source_system_id),''openHyperLink'',''parent.openLink'') AS TemplateName,
	dbo.FNAHyperLinkText2(10101400,  a.template_name , a.template_id,source_deal_type.source_system_id) AS TemplateName,
	case when  
		a.physical_financial_flag =''p'' then ''Physical''
		else ''Financial''
	End 
	as PhysicalFinancialFlag
--	,Case when 
--		 a.term_frequency_value =''m'' then ''Monthly''
--	     when a.term_frequency_value =''h'' then ''Hourly''
--	     when a.term_frequency_value =''q'' then ''Quarterly''
--	     when a.term_frequency_value =''s'' then ''Semi-Annually''
--	     when a.term_frequency_value =''a'' then ''Annually''
--		else ''Daily''
--	End as FrequencyValue
	,Case when 
		 a.term_frequency_type =''m'' then ''Monthly''
		     when a.term_frequency_type =''q'' then ''Quarterly''
		     when a.term_frequency_type =''h'' then ''Hourly''
		     when a.term_frequency_type =''s'' then ''Semi-Annually''
		     when a.term_frequency_type =''a'' then ''Annually''
		else ''Daily''
	End as FrequencyType,
	a.option_flag as OptionFlag,
	case when a.option_type =''p'' then ''Put''
	 when a.option_type =''c'' then ''Call''
	End
	as OptionType,
	case when a.option_exercise_type =''a'' then ''American''
	when a.option_exercise_type =''e'' then ''European''
	
	End
	as ExcerciseType,
	a.description1 as Desc1,
	a.description2 as Desc2,a.Description3 as Desc3,
	case when a.buy_sell_flag =''b'' then ''Buy''
	else ''Sell''
	End
	as BuySellFlag,source_deal_type.deal_type_id as DealType,a.deal_sub_type_type_id DealSubType,
	a.is_active as Active, a.internal_flag as InternalFlag,a.internal_deal_type_value_id as InternalDealTypeID,
	a.internal_deal_subtype_value_id as InternalDealSubTypeID,
	a.blotter_supported as BlotterSupported,
	a.rollover_to_spot as [Rollover to spot],
	a.discounting_applies as [Discounting Does Not Applies],
	a .term_end_flag as [Do not show term end],
	a.is_public as [Public],
	sdv.code [Block],
	sdv2.code [Block define],
--	a.block_type as [Block],
--	a.block_define_id as [Block define],
	sdv3.code as [Granularity],
	sdv4.code as [Price],
	cfmt.model_name as [Model Name],
	CASE WHEN a.trade_ticket_template = ''t'' THEN ''Trade Ticket''
		 WHEN  a.trade_ticket_template = ''i'' THEN ''Trade Ticket Index Swap''
	END AS [Trade Ticket Template]


	
	FROM         source_deal_header_template a 
	LEFT OUTER JOIN
              source_deal_type ON a.source_deal_type_id = source_deal_type.source_deal_type_id
	LEFT OUTER JOIN
			static_data_value sdv ON a.block_type = sdv.value_id 
	LEFT OUTER JOIN
			static_data_value sdv2 ON a.block_define_id = sdv2.value_id 
	LEFT OUTER JOIN
			static_data_value sdv3 ON a.granularity_id = sdv3.value_id
	LEFT OUTER JOIN
			static_data_value sdv4 ON a.pricing = sdv4.value_id
	LEFT OUTER JOIN
			cash_flow_model_type cfmt ON a.model_id = cfmt.model_id
	where 1=1 '
--	 from source_deal_header_template 
	if @source_deal_type_id is not NULL
		set @sql_stmt=@sql_stmt +' and  a.source_deal_type_id='+cast(@source_deal_type_id as  varchar(20))
	if @deal_sub_type_type_id is not NULL
	set @sql_stmt=@sql_stmt +' and a.deal_sub_type_type_id='+cast(@deal_sub_type_type_id as  varchar(20)) 
	
	if @is_active is not NULL and @source_deal_type_id is  NULL
		set @sql_stmt=@sql_stmt +' and a.is_active='''+@is_active +''''
	if @is_active is not NULL and @source_deal_type_id is not NULL
		set @sql_stmt=@sql_stmt +' and a.is_active='''+@is_active +''''
--	if @blotter_support is not NULL 
--		set @sql_stmt=@sql_stmt +' and a.blotter_supported=''' + @blotter_support + ''''
	if @blotter_support = 'y'
		set @sql_stmt=@sql_stmt +' and a.blotter_supported=''y'''
	
--	if @is_public is not NULL 
--		set @sql_stmt=@sql_stmt +' and a.is_public=''' + @is_public + ''''

	if @is_public = 'y'
		set @sql_stmt=@sql_stmt +' and a.is_public=''y'''
	else
		set @sql_stmt=@sql_stmt +' and (a.is_public=''n'' or a.is_public is null)'

	IF @trade_ticket_template IS NOT NULL
		SET @sql_stmt = @sql_stmt + ' AND a.trade_ticket_template = ''' + @trade_ticket_template + ''''
		
	print @sql_stmt
	exec(@sql_stmt)
--	If @@error <> 0
--		Exec spa_ErrorHandler @@error, 'Source Deal Header Template', 
--				'spa_source_deal_header_template', 'DB Error', 
--				'Failed to Select the Source Deal Header Template.', ''
--	Else
--		Exec spa_ErrorHandler 0, 'Source Deal Header Template', 
--				'spa_source_deal_header_template', 'Success', 
--				'Source Deal Header Template is successfully selected.', ''


end

else if @flag='a' 
begin
	--select 	
	--	a.template_id as TemplateID, a.template_name as TemplateName,
	--	a.physical_financial_flag as PhysicalFinancialFlag, a.term_frequency_value as FrequencyValue,
	--	a.term_frequency_type as FrequencyType,
	--	a.option_flag as OptionFlag,a.option_type as OptionType,a.option_exercise_type as ExcerciseType,
	--	a.description1 as Desc1,
	--	a.description2 as Desc2,a.Description3 as Desc3,a.buy_sell_flag as BuySellFlag,a.source_deal_type_id as DealType,a.deal_sub_type_type_id DealSubType,
	--	a.is_active as Active, a.internal_flag as InternalFlag,a.internal_deal_type_value_id as InternalDealTypeID,
	--	a.internal_deal_subtype_value_id as InternalDealSubTypeID,
	--	a.template_name as internal_template_name,
	--	a.allow_edit_term, a.blotter_supported,a.rollover_to_spot,a.discounting_applies,
	--	a.term_end_flag,
	--	a.is_public,
	--	sdt.source_system_id,
	--	a.deal_status,
	--	a.deal_category_value_id,
	--	a.legal_entity,
	--	a.commodity_id,
	--	a.internal_portfolio_id,
	--	a.product_id,
	--	a.internal_desk_id,
	--	a.block_type as [Block],
	--	a.block_define_id as [Block define],
	--	a.granularity_id as [Granularity],
	--	a.Pricing as [Price],
	--	a.model_id AS [Model Id],
	--	a.comments,
	--	a.trade_ticket_template,
	--	a.hourly_position_breakdown,
	--	a.counterparty_id,
	--	a.contract_id,
	--	a.field_template_id
	--from source_deal_header_template a 
	--left join source_deal_type sdt on sdt.source_deal_type_id=a.source_deal_type_id 

	--where a.template_id=@template_id
	SELECT * FROM source_deal_header_template a where a.template_id=@template_id
	
--	If @@error <> 0
--		Exec spa_ErrorHandler @@error, 'Source Deal Header Template', 
--				'spa_source_deal_header_template', 'DB Error', 
--				'Failed to Select the Source Deal Header Template.', ''
--	Else
--		Exec spa_ErrorHandler 0, 'Source Deal Header Template', 
--				'spa_source_deal_header_template', 'Success', 
--				'Source Deal Header Template is successfully selected.', ''

end


ELSE If @flag='i'
begin

	Insert into source_deal_header_template
		( template_name, physical_financial_flag, term_frequency_value, term_frequency_type, option_flag, option_type, option_exercise_type, 
                    	 description1, description2, description3, buy_sell_flag, source_deal_type_id, 
                      deal_sub_type_type_id,is_active,internal_flag,internal_deal_type_value_id ,
		internal_deal_subtype_value_id ,allow_edit_term, blotter_supported,rollover_to_spot,discounting_applies,term_end_flag,is_public,deal_status,
		deal_category_value_id,
		legal_entity,
		commodity_id,
		internal_portfolio_id,
		product_id,
		internal_desk_id,
		block_type,
		block_define_id,
		granularity_id,
		Pricing,
		model_id,
		comments,
		trade_ticket_template,
		hourly_position_breakdown,
		counterparty_id,
		contract_id,
		field_template_id,
		trader_id		
		)
	values
		(@template_name ,
		@physical_financial_flag ,
		@term_frequency_value ,
		@term_frequency_type ,
		@option_flag ,
		@option_type ,
		@option_exercise_type ,
		@description1 ,
		@description2 ,
		@description3 ,
		@buy_sell_flag ,
		@source_deal_type_id ,
		@deal_sub_type_type_id,@is_active ,
		'n',@internal_deal_type_value_id ,
		@internal_deal_subtype_value_id,
		@allow_edit_term,
		@blotter_support,
		@rollover_to_spot,
		@discounting_applies,
		@term_end_flag,
		'n',
		@deal_status,
		@deal_category_value_id,
		@legal_entity,
		@commodity_id,
		@internal_portfolio_id,
		@product_id,
		@internal_desk_id,
		@blocktypecombo,
		@blockdefinitioncombo,
		@granularitycombo,
		@price,
		@model_id,
		@comments,
		@trade_ticket_template,
		@hourly_position_breakdown,
		@counterparty_id,
		@contract_id,
		@fieldTemplateId,
		@trader_id
		 )
	
	set @deal_temp_id=scope_identity()

	SELECT udf.* INTO #tempUDF FROM 
	maintain_field_template_detail ft
	JOIN user_defined_fields_template udf ON udf.udf_template_id=ft.field_id
	WHERE  udf_or_system='u' AND ft.field_template_id=@fieldTemplateId AND udf.udf_type='h'
	
insert into user_defined_deal_fields_template
				(	field_name,
					Field_label,
					Field_type,
					data_type,
					is_required,
					sql_string,
					udf_type,
					field_size,
					field_id,
					default_value,
					udf_group,
					udf_tabgroup,
					formula_id,
					template_id,
					udf_user_field_id
				)
			
				select	field_name,
						Field_label,
						Field_type,
						data_type,
						is_required,
						sql_string,
						udf_type,
						field_size,
						field_id,
						default_value,
						udf_group,
						udf_tabgroup,
						formula_id,
						@deal_temp_id
						,udf_template_id
						from  #tempUDF
						
				
				
	If @@error <> 0
		Exec spa_ErrorHandler @@error, 'Source Deal Header Template', 
				'spa_source_deal_header_template', 'DB Error', 
				'Failed to Insert the new Source Deal Header Template.', ''
	Else
		Exec spa_ErrorHandler 0, 'Source Deal Header Template', 
				'spa_source_deal_header_template', 'Success', 
				'New Source Deal Header Template is successfully Inserted.', @deal_temp_id

	
end

ELSE If @flag='u'
begin
	
	update source_deal_header_template
	set
		template_name = @template_name, 
		physical_financial_flag = @physical_financial_flag, 
		term_frequency_value = @term_frequency_value, 
		term_frequency_type = @term_frequency_type, 
		option_flag = @option_flag, 
		option_type = @option_type, 
		option_exercise_type = @option_exercise_type, 
		description1 = @description1, 
		description2 = @description2, 
		description3 = @description3, 
		buy_sell_flag = @buy_sell_flag, 
		source_deal_type_id = @source_deal_type_id, 
        deal_sub_type_type_id = @deal_sub_type_type_id,
	    is_active = @is_active	,
		internal_deal_type_value_id = @internal_deal_type_value_id ,
		internal_deal_subtype_value_id = @internal_deal_subtype_value_id,
		allow_edit_term = @allow_edit_term,
		blotter_supported = @blotter_support,
		rollover_to_spot = @rollover_to_spot,
		discounting_applies=@discounting_applies,
		term_end_flag = @term_end_flag,
		is_public = @is_public,
		deal_status = @deal_status,
		deal_category_value_id = @deal_category_value_id,
		legal_entity = @legal_entity,
		commodity_id = @commodity_id,
		internal_portfolio_id = @internal_portfolio_id,
		product_id = @product_id,
		internal_desk_id = @internal_desk_id,
		block_type = @blocktypecombo,
		block_define_id = @blockdefinitioncombo,
		granularity_id = @granularitycombo,
		Pricing = @price,
		model_id = @model_id,
		comments = @comments,
		trade_ticket_template = @trade_ticket_template,
		hourly_position_breakdown = @hourly_position_breakdown,
		counterparty_id = @counterparty_id,
		contract_id = @contract_id,
		field_template_id = @fieldTemplateId,
		trader_id=@trader_id
	where template_id = @template_id

	If @@error <> 0
		Exec spa_ErrorHandler @@error, 'Source Deal Header Template', 
				'spa_source_deal_header_template', 'DB Error', 
				'Failed to Update the  Source Deal Header Template.', ''
	Else
		Exec spa_ErrorHandler 0, 'Source Deal Header Template', 
				'spa_source_deal_header_template', 'Success', 
				'Source Deal Header Template is successfully Updated.', ''
	
end

else If @flag='d'

begin
	if not exists (select * from source_deal_header Where template_id = @template_id)
	begin
		Delete from source_deal_detail_template
		Where template_id
 				= @template_id
		Delete from source_deal_header_template
		Where template_id = @template_id
		Exec spa_ErrorHandler 0, 'Source Deal Header - Detail Template', 
				'spa_source_deal_header_template', 'Success', 
				'Selected Source Deal Detail Template is successfully Deleted.', ''
	end
	else
		Exec spa_ErrorHandler -1, 'The selected template cannot be deleted.', 
				'spa_source_deal_header_template', 'DB Error', 
				'Source Deal Detail Template can delete it is used', ''
		
--	update source_deal_header set
--	template_id=null
--	where template_id=@template_id

--	If @@error <> 0
--		Exec spa_ErrorHandler @@error, 'Source Deal Header Template', 
--				'spa_source_deal_header_template', 'DB Error', 
--				'Failed to Delete the selected Source Deal Header Template.', ''
--	Else
--		Exec spa_ErrorHandler 0, 'Source Deal Header Template', 
--				'spa_source_deal_header_template', 'Success', 
--				'Selected Source Deal Header Template is successfully Deleted.', ''
--


End

ELSE If @flag='c'
begin
	Begin Tran

	Insert into source_deal_header_template
		( template_name, physical_financial_flag, term_frequency_value, term_frequency_type, option_flag, option_type, option_exercise_type, 
          description1, description2, description3, buy_sell_flag, source_deal_type_id,deal_sub_type_type_id,is_active,internal_flag,
		   internal_deal_type_value_id ,internal_deal_subtype_value_id, blotter_supported,rollover_to_spot,discounting_applies,term_end_flag,is_public,deal_status,
		deal_category_value_id,
		legal_entity,
		commodity_id,
		internal_portfolio_id,
		product_id,
		internal_desk_id,
		block_type,
		block_define_id,
		granularity_id,
		Pricing,
		model_id,
		trade_ticket_template,
		hourly_position_breakdown,
		comments,
		allow_edit_term,
		field_template_id 
		)
	select 'Copy of ' + template_name ,
		physical_financial_flag ,
		term_frequency_value ,
		term_frequency_type ,
		option_flag ,
		option_type ,
		option_exercise_type ,
		description1 ,
		description2 ,
		description3 ,
		buy_sell_flag ,
		source_deal_type_id ,
		deal_sub_type_type_id,is_active ,
		'n',internal_deal_type_value_id ,
		internal_deal_subtype_value_id,
		blotter_supported,
		rollover_to_spot,
		discounting_applies,
		term_end_flag,
		'y',
		deal_status,
		deal_category_value_id,
		legal_entity,
		commodity_id,
		internal_portfolio_id,
		product_id,
		internal_desk_id,
		block_type,
		block_define_id,
		granularity_id,
		Pricing,
		model_id,
		@trade_ticket_template,
		hourly_position_breakdown,
		comments,
		allow_edit_term,
		field_template_id
	from source_deal_header_template where
	template_id=@template_id
	
	set @deal_temp_id=scope_identity()


	If @@error <> 0
		Begin
		Exec spa_ErrorHandler @@error, 'Source Deal Header Template', 
				'spa_source_deal_header_template', 'DB Error', 
				'Failed to Insert the new Source Deal Header Template.', ''
		Rollback Tran
		End
	Else
	Begin
			
		Insert into source_deal_detail_template
			(  leg, fixed_float_leg, buy_sell_flag, curve_type,curve_id, deal_volume_frequency, deal_volume_uom_id,currency_id,
						  block_description,  template_id, commodity_id,day_count, physical_financial_flag,location_id,meter_id,
						  strip_months_from,lag_months,strip_months_to,conversion_factor,pay_opposite,settlement_currency ,
		standard_yearly_volume,
		price_uom_id,
		category,
		profile_code,
		pv_party
			)
		select leg ,
			fixed_float_leg,
			buy_sell_flag ,
			curve_type,
			curve_id,
			deal_volume_frequency ,
			deal_volume_uom_id,
			currency_id,
			block_description ,
			@deal_temp_id,
			commodity_id,
			day_count,
			physical_financial_flag,
			location_id,
			meter_id,
			strip_months_from,
			lag_months,
			strip_months_to,
			conversion_factor,
			pay_opposite,
			settlement_currency ,
		standard_yearly_volume,
		price_uom_id,
		category,
		profile_code,
		pv_party
			from source_deal_detail_template where template_id=@template_id
		
			If @@error <> 0
			Begin
			Exec spa_ErrorHandler @@error, 'Source Deal Header Template', 
					'spa_source_deal_header_template', 'DB Error', 
					'Failed to Insert the new Source Deal Header Template.', ''
			Rollback Tran
			End
			Else
			Begin
				
				insert into user_defined_deal_fields_template
				(	field_name,
					Field_label,
					Field_type,
					data_type,
					is_required,
					sql_string,
					udf_type,
					sequence,
					field_size,
					field_id,
					default_value,
					book_id,
					udf_group,
					udf_tabgroup,
					formula_id,
					template_id,
					udf_user_field_id
				)
			
				select	field_name,
						Field_label,
						Field_type,
						data_type,
						is_required,
						sql_string,
						udf_type,
						sequence,
						field_size,
						field_id,
						default_value,
						book_id,
						udf_group,
						udf_tabgroup,
						formula_id,
						@deal_temp_id
						,udf_user_field_id
						from user_defined_deal_fields_template
						where template_id = @template_id
				
				If @@error <> 0
				Begin
					EXEC spa_ErrorHandler @@error , 'Source Deal Header Template', 
					'spa_source_deal_header_template', 'DB Error', 
					'Failed to Insert the new User Defined Deal Fields Template.', ''
					
					rollback tran
				end
				else
				begin
					insert into deal_transfer_mapping 
					(
						source_deal_type_id,
						source_deal_sub_type_id,
						source_book_mapping_id_from,
						source_book_mapping_id_to,
						trader_id_from,
						trader_id_to,
						counterparty_id_from,
						counterparty_id_to,
						unapprove,
						offset,
						transfer,
						transfer_pricing_option,
						formula_id,
						source_book_mapping_id_offset,
						template_id
					)
					
					select	source_deal_type_id,
							source_deal_sub_type_id,
							source_book_mapping_id_from,
							source_book_mapping_id_to,
							trader_id_from,
							trader_id_to,
							counterparty_id_from,
							counterparty_id_to,
							unapprove,
							offset,
							transfer,
							transfer_pricing_option,
							formula_id,
							source_book_mapping_id_offset,
							@deal_temp_id
							from deal_transfer_mapping 
							where template_id= @template_id
						
					If @@error <> 0
					Begin
						EXEC spa_ErrorHandler @@error , 'Source Deal Header Template', 
						'spa_source_deal_header_template', 'DB Error', 
						'Failed to Insert the deal transfer mapping.', ''
							
						rollback tran

					end
					else
					begin
				
						Exec spa_ErrorHandler 0, 'Source Deal Header Template', 
								'spa_source_deal_header_template', 'Success', 
								'New Source Deal Header Template is successfully Inserted.', @deal_temp_id
						Commit Tran
					end

				end 
			End

	End	
END





GO

/****** Object:  StoredProcedure [dbo].[spa_blotter_deal]    Script Date: 12/06/2011 23:36:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--SELECT * FROM source_deal_header_template WHERE template_id=102
--exec spa_blotter_deal 'i', '102', 5, '2012-01-01', '2012-01-31'
CREATE PROC [dbo].[spa_blotter_deal]
@flag CHAR(1),
@template_id VARCHAR(20),
@no_of_row INT,
@term_start VARCHAR(20),
@term_end VARCHAR(20),
@deal_date VARCHAR(20),
@process_id VARCHAR(150) =NULL 
AS 
--SELECT * FROM adiha_process.dbo.blotter_deal_insert_system_A8F3B44B_4979_4E6B_8EDE_FA8A742D1145
 
--DECLARE  @flag INT, @template_id VARCHAR(20), @no_of_row INT ,@process_id VARCHAR(150) ,@term_start VARCHAR(20),@term_end VARCHAR(20)
--SET @template_id=67 
--SET @no_of_row=5 
--SET  @process_id='1234'
--SET @term_start='2011-01-01'
--SET @term_end='2011-12-31'
--DROP TABLE #field_template
--DROP TABLE #template_default_value
--DROP TABLE #template_header
--DROP TABLE #template_detail 
--DROP TABLE adiha_process.dbo.blotter_deal_insert_system_1234 

DECLARE @field_template_id INT,@process_table VARCHAR(150), @sql VARCHAR(MAX),@isNew CHAR(1)
SELECT @field_template_id=field_template_id FROM dbo.source_deal_header_template WHERE template_id=@template_id 


----TRANSPOSE COLUMNS TO ROWS
CREATE TABLE #template_default_value(
sno INT IDENTITY(1,1),
clm_name VARCHAR(50),
clm_value VARCHAR(150),
header_detail CHAR(1)
)

		SELECT column_name INTO #template_header FROM INFORMATION_SCHEMA.Columns where TABLE_NAME = 'source_deal_header_template' 

		DECLARE @column_name VARCHAR(50),@value VARCHAR(150)
		DECLARE headerCur CURSOR  FORWARD_ONLY READ_ONLY FOR
		
		SELECT column_name FROM #template_header
		OPEN headerCur
		FETCH NEXT FROM headerCur into @column_name 
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @sql='
			insert #template_default_value(clm_name,clm_value,header_detail)
			SELECT  '''+@column_name+''',ltrim(rtrim('+ @column_name +')),''h'' from source_deal_header_template where template_id='+ @template_id
			EXEC(@sql)	
			FETCH NEXT FROM headerCur into @column_name 
		end
		close headerCur
		deallocate headerCur
		
		UPDATE #template_default_value SET clm_name='header_buy_sell_flag' WHERE clm_name='buy_sell_flag'
		
		SELECT column_name INTO #template_detail FROM INFORMATION_SCHEMA.Columns where TABLE_NAME = 'source_deal_detail_template' 

		
		DECLARE detailCur CURSOR  FORWARD_ONLY READ_ONLY FOR
		
		SELECT column_name FROM #template_detail
		OPEN detailCur
		FETCH NEXT FROM detailCur into @column_name 
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @sql='
			insert #template_default_value(clm_name,clm_value,header_detail)
			SELECT '''+@column_name+''','+ @column_name +',''d'' from source_deal_detail_template where template_id='+ @template_id
			PRINT @sql 
			EXEC(@sql)	
			FETCH NEXT FROM detailCur into @column_name 
		end
		close detailCur
		deallocate detailCur

		
	--	SELECT * FROM source_deal_detail_template WHERE template_id=102
----TRANSPOSE COLUMNS TO ROWS End		
		
--SET @process_table='adiha_process.dbo.blotter_deal_insert_system_A8F3B44B_4979_4E6B_8EDE_FA8A742D1145'
--SET @process_table='adiha_process.dbo.blotter_deal_insert_system_1234'


IF @process_id IS NULL 
	set @process_id=REPLACE(newid(),'-','_')   
	
IF  @process_table IS NULL 
	set @process_table=dbo.FNAProcessTableName('blotter_deal_insert', 'system',@process_id)      


	CREATE TABLE #field_template(
		farrms_field_id VARCHAR(100),
		default_label VARCHAR(100),
		field_group_id VARCHAR(50),
		seq_no INT,
		header_detail CHAR(1),
		field_id VARCHAR(50),
		field_type CHAR(1),
		default_value VARCHAR(150)
	)
	

		INSERT into #field_template(farrms_field_id,default_label,field_group_id,seq_no,header_detail,field_id,field_type)
		SELECT * FROM (
		SELECT lower(mfd.farrms_field_id) farrms_field_id,
		ISNULL(mftd.field_caption,mfd.default_label) default_label
		,field_group_id
		,seq_no
		,mfd.header_detail
		,CAST(mfd.field_id AS varchar) field_id
		,mfd.field_type 
		FROM maintain_field_deal mfd JOIN maintain_field_template_detail mftd 
		ON mftd.field_id = mfd.field_id 
		AND mftd.field_template_id = @field_template_id
		AND ISNULL(mftd.udf_or_system,'s')='s'
		WHERE  mfd.farrms_field_id NOT IN ('source_deal_header_id','source_deal_detail_id','create_user','create_ts','update_user','update_ts','template_id')
		AND ISNULL(mftd.hide_control,'n')='n' AND ISNULL(mftd.insert_required,'n')='y'
		UNION ALL 	
		SELECT 'UDF___'+CAST(udf_template_id AS VARCHAR) udf_template_id,
		ISNULL(mftd.field_caption,udf_temp.Field_label) default_label
		,field_group_id
		,seq_no
		,udf_temp.udf_type
		,'u--'+cast(udf_temp.udf_template_id as varchar)
		,udf_temp.field_type
		FROM user_defined_fields_template udf_temp
		JOIN maintain_field_template_detail mftd 
		ON mftd.field_id = udf_temp.udf_template_id 
		AND mftd.field_template_id = @field_template_id
		AND ISNULL(mftd.udf_or_system,'s')='u' 
		WHERE ISNULL(mftd.hide_control,'n')='n' AND ISNULL(mftd.insert_required,'n')='y'
		) l 
		ORDER BY header_detail DESC,field_group_id,ISNULL(l.seq_no,10000)
	

		UPDATE  #field_template SET default_value=t.clm_value 
		FROM #field_template f join #template_default_value t 
		ON f.farrms_field_id=t.clm_name AND f.header_detail=t.header_detail
	
	
		 DECLARE @field VARCHAR(5000)
		 SET @field=''
		 SELECT @field=@field+' '+header_detail+'_'+CAST(farrms_field_id AS VARCHAR)+' VARCHAR(100) ' + 
		 case when default_value is not null then ' default '''+ default_value +''',' else ',' end  FROM #field_template
		 
		 
		  if LEN(@field)>1
		  BEGIN
		   SET @field=LEFT(@field,LEN(@field)-1)
		  end 
		 
		 SET @sql=' CREATE TABLE '+ @process_table +'(
		 sno int,
		 '+@field +')'
		 PRINT @sql
		 EXEC(@sql)

  DECLARE @row INT
  SET @row=1
  WHILE @row<=@no_of_row
  BEGIN 
	   SET @sql=' insert into '+ @process_table +'(sno,h_deal_date,d_term_start,d_term_end)
		values('+ CAST(@row  AS VARCHAR)+','''+@deal_date +''','''+@term_start +''','''+@term_end +''')'
		SET @row=@row+1
		EXEC(@sql)
  END 


	declare @sql_pre varchar(max),@farrms_field_id varchar(100),@default_label varchar(500),@header_detail CHAR(1) , @field_id VARCHAR(50),@field_type CHAR(1)
		SET @sql_pre=''
		DECLARE dealCur CURSOR  FORWARD_ONLY READ_ONLY FOR
		
		SELECT farrms_field_id,default_label,header_detail,field_id,field_type from #field_template
		OPEN dealCur
		FETCH NEXT FROM dealCur into @farrms_field_id,@default_label,@header_detail,@field_id,@field_type
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @field_type='a'
			BEGIN 
				set @sql_pre=@sql_pre+' dbo.FNADateFormat('+@header_detail+'_'+ @farrms_field_id +') AS ['+@header_detail +'__'+@field_id+'__'+ @default_label +'],'						
			END 
			ELSE 
			BEGIN 
				set @sql_pre=@sql_pre+' '+@header_detail+'_'+ @farrms_field_id +' AS ['+@header_detail +'__'+@field_id+'__'+ @default_label +'],'						
			END 
			--set @sql_pre=@sql_pre+' '+@header_detail+'_'+ @farrms_field_id +' AS ['+ @default_label +'],'						
			FETCH NEXT FROM dealCur into @farrms_field_id,@default_label,@header_detail,@field_id,@field_type
		end
		close dealCur
		deallocate dealCur
		if len(@sql_pre)>1
		begin
			set @sql_pre=left(@sql_pre,len(@sql_pre)-1)
		end 
		PRINT ('SELECT '+ @sql_pre +' FROM '+ @process_table)
		exec('SELECT '+ @sql_pre +' FROM '+ @process_table)
		

GO


