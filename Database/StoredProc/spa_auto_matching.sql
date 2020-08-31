IF OBJECT_ID(N'[dbo].[spa_auto_matching]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_auto_matching]
GO




--exec [spa_auto_matching]
-- select * from source_deal_detail where source_deal_header_id=130029
--select b.entity_name,st.entity_name,su.entity_name from portfolio_hierarchy b inner join portfolio_hierarchy st on b.parent_entity_id=st.entity_id 
--inner join portfolio_hierarchy su on st.parent_entity_id=su.entity_id where b.entity_id=219
--exec spa_auto_matching null,NULL,'15','2008-01-28','2010-01-28','f','o',22,'i','s','n','farrms_admin'
--spa_auto_matching_job '36',null,null,'2008-01-28','2010-01-28','f','o',22,'i','s','n','farrms_admin','0F4351D8_7EF1_4F53_AC7C_908DEA1A8789'


create proc [dbo].[spa_auto_matching] 
	@sub_id varchar(1000)=null	,
	@str_id varchar(1000)=null,
	@book_id varchar(1000)=null,
	@as_of_date_from varchar(20)=null,
	@as_of_date_to varchar(20)=null,
	@FIFO_LIFO VARCHAR(1)=NULL,
--	@b_s_match_option VARCHAR(1)=NULL, --Hedege same and opposite direction s or o
	@slicing_first VARCHAR(1)='h', --h:first slicing hedge, i:first slicing item
	@perform_dicing VARCHAR(1)='y', 
	@curve_id int =null,
	@h_or_i varchar(1)=null,
	@buy_sell varchar(1)=null,
	@call_for_report varchar(1)=null,
	@slice_option VARCHAR(1)='m', --m=multi;h=hedge one, i=item one
	@user_name varchar(100)=NULL,
	@includeExtenal VARCHAR(1) = NULL,
	@externalizationmatch VARCHAR(1) = NULL,
	@book_map_ids VARCHAR(MAX)=null,
	@deal_dt_option VARCHAR(1) = NULL,
	@apply_limit VARCHAR(1) = NULL,@limit_bucketing VARCHAR(3)=null --uk, de
AS
DECLARE @spa varchar(500)
DECLARE @job_name varchar(100)
DECLARE @process_id varchar(50)
declare @par varchar(1000)
SET @process_id = REPLACE(newid(),'-','_')
SET @job_name = 'matching_' + @process_id
if @user_name is null
	set @user_name=dbo.FNADBuser()
If @sub_id IS NULL 
	SET @par = 'null'
else
	SET @par = ''''+@sub_id+''''
If @str_id IS NULL 
	SET @par = @par+',null'
else
	SET @par =@par+','''+ @str_id+''''

If @book_id IS NULL 
	SET @par = @par+',null'
else
	SET @par = @par+','''+@book_id+''''

If @as_of_date_from IS NULL 
	SET @par = @par+',null'
else
	SET @par = @par+','''+@as_of_date_from+''''

If @as_of_date_to IS NULL 
	SET @par = @par+',null'
else
	SET @par = @par+','''+@as_of_date_to+''''
If @FIFO_LIFO IS NULL 
	SET @par = @par+',null'
else
	SET @par = @par+','''+@FIFO_LIFO+''''

--If @b_s_match_option IS NULL 
--	SET @par = @par+',null'
--else
--	SET @par = @par+','''+@b_s_match_option+''''


If @slicing_first IS NULL 
	SET @par = @par+',''h'''
else
	SET @par = @par+','''+@slicing_first+''''

If @perform_dicing IS NULL 
	SET @par = @par+',''n'''
else
	SET @par = @par+','''+@perform_dicing+''''

If @curve_id IS NULL 
	SET @par = @par+',null'
else
	SET @par = @par+','+cast(@curve_id as varchar)

If @h_or_i IS NULL 
	SET @par = @par+',null'
else
	SET @par = @par+','''+@h_or_i+''''

If @buy_sell IS NULL 
	SET @par = @par+',null'
else
	SET @par = @par+','''+@buy_sell+''''


SET @par = @par+',''n'''
If @slice_option IS NULL 
	SET @par = @par+',''m'''
else
	SET @par = @par+','''+@slice_option+''''

SET @par = @par+',''' +@user_name+ ''''


If @includeExtenal IS NULL 
	SET @par = @par+',null'
else
	SET @par = @par+','''+@includeExtenal+''''
	
If @externalizationmatch IS NULL 
	SET @par = @par+',null'
else
	SET @par = @par+','''+@externalizationmatch+''''	
	
SET @par = @par+','''+@process_id + ''''

IF @book_map_ids IS NULL 
	SET @par = @par + ', NULL'
ELSE
	SET @par = @par + ', ''' + @book_map_ids + ''''	

IF @deal_dt_option IS NULL 
	SET @par = @par + ', NULL'
ELSE
	SET @par = @par + ', ''' + @deal_dt_option + ''''	


If @apply_limit IS NULL 
	SET @par = @par+',''n'''
else
	SET @par = @par+','''+@apply_limit+''''
	
If @limit_bucketing IS NULL 
	SET @par = @par+',NULL'
else
	SET @par = @par+','''+@limit_bucketing+''''


SET @spa = 'spa_auto_matching_job ' + @par

--PRINT @spa
--return
EXEC spa_run_sp_as_job @job_name, @spa, 'Auto Matching',@user_name

EXEC spa_ErrorHandler 0, 'Auto Match', 
			'Process run', 'Status', 
			'Automatic matching of hedges and hedged item process has been run and will complete shortly.','Please check/refresh your message board.'








