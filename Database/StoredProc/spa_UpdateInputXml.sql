IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_UpdateInputXml]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_UpdateInputXml]
GO 

create PROCEDURE [dbo].[spa_UpdateInputXml]
@xmlValue TEXT=null
AS

DECLARE @sql VARCHAR(8000)
Declare @user_login_id varchar(100),@process_id varchar(100)

--set @user_login_id=dbo.FNADBUser()

--	select * into #temp_insert_table from ems_gen_default where 1=2
		
DECLARE @idoc int
DECLARE @doc varchar(1000)

exec sp_xml_preparedocument @idoc OUTPUT, @xmlValue

-----------------------------------------------------------------
SELECT * into #ztbl_xmlvalue
FROM   OPENXML (@idoc, '/Root/PSRecordset',2)
         WITH ( generator_id  varchar(10)    '@generator_id',
               input_type_id  varchar(10)    '@input_type_id',
               char1  int    '@char1',
               char2  varchar(10)    '@char2',
               char3  varchar(10)    '@char3',
               char4  varchar(10)    '@char4',
               char5  varchar(10)    '@char5',
               char6  varchar(10)    '@char6',
               char7  varchar(10)    '@char7',
               char8  varchar(10)    '@char8',
               char9  varchar(10)    '@char9',
               char10  varchar(10)    '@char10'
	)

	delete ems_gen_default
	where generator_id in (select generator_id from #ztbl_xmlvalue)
	
	set @sql='INSERT INTO ems_gen_default
		(generator_id,
		input_type_id,
		char1,
		char2,
		char3,
		char4,
		char5,
		char6,
		char7,
		char8,
		char9,
		char10
		)
	 select 
		generator_id,
		input_type_id,
		CASE WHEN ISNUMERIC(char1)=0 THEN NULL ELSE char1 END ,
		CASE WHEN ISNUMERIC(char2)=0 THEN NULL ELSE char2 END ,
		CASE WHEN ISNUMERIC(char3)=0 THEN NULL ELSE char3 END ,
		CASE WHEN ISNUMERIC(char4)=0 THEN NULL ELSE char4 END ,
		CASE WHEN ISNUMERIC(char5)=0 THEN NULL ELSE char5 END ,
		CASE WHEN ISNUMERIC(char6)=0 THEN NULL ELSE char6 END ,
		CASE WHEN ISNUMERIC(char7)=0 THEN NULL ELSE char7 END ,
		CASE WHEN ISNUMERIC(char8)=0 THEN NULL ELSE char8 END ,
		CASE WHEN ISNUMERIC(char9)=0 THEN NULL ELSE char9 END ,
		CASE WHEN ISNUMERIC(char10)=0 THEN NULL ELSE char10 END 
		from #ztbl_xmlvalue '
	EXEC(@sql) 

------------END to create TEMP Table

If @@ERROR <> 0
		Begin	
			Exec spa_ErrorHandler @@ERROR, 'Source Deal Detail Temp Table', 
				'spa_getXml', 'DB Error', 
				'Failed Inserting record.', 'Failed Inserting Record'
			
		End
		Else
		Begin
			Exec spa_ErrorHandler 0, 'Source Deal Detail Temp Table', 
			'spa_getXml', 'Success', 
			'', ''
				
		End





