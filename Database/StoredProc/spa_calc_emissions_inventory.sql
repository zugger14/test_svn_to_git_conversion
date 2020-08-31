
IF OBJECT_ID(N'[dbo].[spa_calc_emissions_inventory]', N'P') IS NOT NULL
   DROP PROCEDURE [dbo].[spa_calc_emissions_inventory]
GO

CREATE PROCEDURE [dbo].[spa_calc_emissions_inventory]
	@as_of_date varchar(100)=NULL,
	@term_start varchar(100)=NULL,
	@term_end varchar(100)=NULL,
	@sub_entity_id varchar(100)=NULL,
	@strategy_entity_id varchar(100)=NULL ,
	@book_entity_id varchar(100)=NULL  ,
	@generator_id varchar(1000)=NULL,
	@series_type int=NULL,
	@process_table varchar(100)=null,
	@user_id varchar(100)=null
AS
 

declare @job_name varchar(50)
declare @process_id varchar(50)
declare @spa varchar(1000)


if @user_id is null
	set @user_id=dbo.FNADBUser()

SET @process_id = REPLACE(newid(),'-','_')
SET @job_name = 'REC_' + @process_id

If @sub_entity_id IS NULL
	SET @sub_entity_id = ''
If @strategy_entity_id IS NULL
	SET @strategy_entity_id  = ''
If @book_entity_id IS NULL
	SET @book_entity_id = ''
If @generator_id IS NULL
	SET @generator_id =''
if @process_table is null
	set @process_table =''



set @spa = 'spa_calc_emissions_inventory_job 	''' +case when @as_of_date is null then 'NULL' else @as_of_date end+''',''' +cast(@term_start as varchar)+ ''',''' +cast(@term_end as varchar)+ ''',''' 
		+@sub_entity_id+ ''',''' + @strategy_entity_id+ ''',''' + @book_entity_id+ ''',''' +@generator_id+''',''b'',''r'','''+cast(@series_type as varchar) + ''','''+ @job_name + ''','''+@process_table+''','''+@user_id+''''



EXEC spa_run_sp_as_job @job_name, @spa, 'EmissionsInventory', @user_id 
						

Exec spa_ErrorHandler 0, 'EmissionsInventory', 
			'Emissions Inventory', 'Status', 
			'Emissions Inventory calculation has been scheduled and will complete shortly.', 
			'Please check/refresh your message board.'












