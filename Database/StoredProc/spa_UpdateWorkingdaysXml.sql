/****** Object:  StoredProcedure [dbo].[spa_UpdateWorkingdaysXml]    Script Date: 07/06/2009 19:25:45 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_UpdateWorkingdaysXml]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_UpdateWorkingdaysXml]
/****** Object:  StoredProcedure [dbo].[spa_UpdateWorkingdaysXml]    Script Date: 07/06/2009 19:25:52 ******/

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go




CREATE procedure [dbo].[spa_UpdateWorkingdaysXml]
@flag char(1),
@xmlValue TEXT
AS
DECLARE @sqlStmt VARCHAR(MAX)
--Declare @tempdetailtable varchar(100)
Declare @user_login_id varchar(100),@process_id varchar(50)

set @user_login_id=dbo.FNADBUser()
--select @process_id

set @process_id=REPLACE(newid(),'-','_')

--set @tempdetailtable=dbo.FNAProcessTableName('hourly_process', @user_login_id,@process_id)
--drop table temp_db

create table #temp_db( 
	[block_value_id] int ,
	[weekday]  int,	
	[day_val]  int
) ON [PRIMARY]
	
	
--	exec(@sqlStmt)

DECLARE @idoc int
DECLARE @doc varchar(1000)

exec sp_xml_preparedocument @idoc OUTPUT, @xmlValue

-----------------------------------------------------------------
SELECT * into #ztbl_xmlvalue
FROM   OPENXML (@idoc, '/Root/PSRecordset',2)
         WITH (	      
		 block_value_id  varchar(255)    '@block_value_id',
		 weekday  varchar(255)    '@weekday',
		 day_val  int    '@edit_grid1'
      
)

--SELECT * from  #ztbl_xmlvalue
	set @sqlStmt='INSERT INTO #temp_db
	 select [block_value_id] ,[weekday],day_val
	from #ztbl_xmlvalue'
	exec(@sqlStmt) 
if @flag='u'	
begin
	update working_days
	set  val=day_val		
	from working_days h join #ztbl_xmlvalue t
	on h.block_value_id=t.block_value_id and h.weekday=t.weekday 
end
else
begin
		--select * from #ztbl_xmlvalue
	insert into working_days(block_value_id ,weekday,val) select [block_value_id] ,[weekday],day_val   
	from #ztbl_xmlvalue
end

	if @@error<>0
		Begin	
			Exec spa_ErrorHandler @@ERROR, 'Source Deal Detail', 
				'spa_getXml', 'DB Error', 
				'Failed Inserting record.', 'Failed Inserting Record'
			
		End
		Else
		Begin
			Exec spa_ErrorHandler 0, 'Source Deal Detail', 
			'spa_getXml', 'Success', 
			'Source deal  detail record successfully updated.', ''
			
		End

--DROP TABLE #ztbl_xmlvalue
drop table #temp_db




