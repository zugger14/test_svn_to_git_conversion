
/****** Object:  StoredProcedure [dbo].[spa_import_edrXML_inventory_as_job]    Script Date: 03/25/2009 16:59:16 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_import_edrXML_inventory_as_job]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_import_edrXML_inventory_as_job]
GO

/****** Object:  StoredProcedure [dbo].[spa_import_edrXML_inventory_as_job]    Script Date: 03/25/2009 16:59:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_import_edrXML_inventory_as_job] 
	@user_id varchar(50)=null, 
	@table_name varchar(100)=null,
	@process_id varchar(100)=null
	
AS
 

declare @job_name varchar(50)
--declare @process_id varchar(50)
declare @spa varchar(1000)

if @process_id is null 
	set @process_id = REPLACE(newid(),'-','_')
SET @job_name = 'Import_EDR' + @process_id
--SET @db_name = db_name()


if @table_name is null 
	set @table_name='edr_as_imported'
else if @table_name = 'NULL'
	set @table_name='edr_as_imported'

set @spa = 'spa_import_edrXML_inventory ''' + @user_id + ''',''' + @table_name + ''','''+@process_id+''''

--print @job_name
--print @spa
--print @user_id

--return


EXEC spa_run_sp_as_job @job_name, @spa, 'ImportEDRFile', @user_id 

Exec spa_ErrorHandler 0, 'Import EDR File', 
			'Import GIS RECS', 'Status', 
			'Import of EDR File has been scheduled and will complete shortly.', 
			'Please check/refresh your message board.'










