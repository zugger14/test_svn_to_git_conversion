IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_maintain_wellhead]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_maintain_wellhead]

GO

CREATE PROC [dbo].[spa_maintain_wellhead]
@flag as CHAR(1),
@short_id as VARCHAR(20) =NULL,
@name as VARCHAR(50) =NULL,
@description as VARCHAR(50)=NULL,
@meter_number as INT =NULL,
@facility_group as VARCHAR(100)=NULL,
@gathering_contract as VARCHAR(100) =NULL,
@gathering_company as VARCHAR(100) =NULL

AS

DECLARE @sql_stmt VARCHAR(8000)

IF @flag ='s'
BEGIN
SET @sql_stmt='SELECT wd.short_id [Short ID],wd.name [Name],mi.recorderid [Meter Number],
sml.location_name [Facility Group],cg.contract_name [Gathering Contract],sc.counterparty_name [Gathering Company]
from wellhead_details wd 
LEFT OUTER JOIN source_minor_location_meter smlm ON wd.meter_number=smlm.meter_id
LEFT OUTER JOIN source_major_location sml ON wd.facility_group=sml.source_major_location_ID
LEFT OUTER JOIN meter_id mi ON mi.meter_id=smlm.meter_id
LEFT OUTER JOIN contract_group cg ON wd.gathering_contract=cg.contract_id 
LEFT OUTER JOIN source_counterparty sc ON wd.gathering_company=sc.source_counterparty_id
where 1=1 '

IF @meter_number IS NOT NULL
SET @sql_stmt= @sql_stmt +' AND wd.meter_number='+cast(@meter_number as varchar)
IF @facility_group IS NOT NULL
SET @sql_stmt= @sql_stmt +' AND wd.facility_group='+@facility_group
IF @gathering_contract IS NOT NULL
SET @sql_stmt= @sql_stmt +' AND wd.gathering_contract='+@gathering_contract

exec spa_print @sql_stmt
	
EXEC(@sql_stmt)
	
	
END 

IF @flag ='i'
BEGIN

if exists(select 'x' from wellhead_details where  short_id =@short_id )
begin
		Exec spa_ErrorHandler -1, 'Wellhead', 
				'spa_maintain_wellhead', 'DB Error', 
				'''Short ID'' must be unique.', ''

end
else
begin

	begin try
	INSERT INTO wellhead_details(name,short_id,description,meter_number,facility_group,gathering_contract,gathering_company) 
	values (@name,@short_id,@description,@meter_number,@facility_group,@gathering_contract,@gathering_company)

	if @@error=0
			Exec spa_ErrorHandler 0, 'Ownership', 
					'spa_maintain_wellhead', 'Success', 
					'Wellhead was successfully inserted.', ''
	end try
	begin catch
	
	
	if @@error=515
			Exec spa_ErrorHandler -1, 'Ownership', 
					'spa_maintain_wellhead', 'DB Error', 
					'''Short ID'' cannot be blank.', ''
	else 
			Exec spa_ErrorHandler -1, 'Ownership', 
					'spa_maintain_wellhead', 'DB Error', 
					'Error inserting wellhead.', ''
	end catch
end
	
END 

IF @flag ='u'
BEGIN


UPDATE wellhead_details set name=@name,description=@description,
meter_number =@meter_number,facility_group=@facility_group,gathering_contract=@gathering_contract,gathering_company=@gathering_company
where short_id=@short_id


	

	
	
END 

IF @flag ='a'
BEGIN

SELECT short_id,name,description,meter_number,facility_group,gathering_contract,gathering_company
from wellhead_details where short_id=@short_id


	
	
END 

IF @flag ='d'
BEGIN

begin try

	DELETE from wellhead_details where short_id=@short_id

	if @@error=0
			Exec spa_ErrorHandler 0, 'Ownership', 
					'spa_maintain_wellhead', 'Success', 
					'Wellhead was successfully deleted.', ''
end try
begin catch

--	select @@error
	declare @err int
	set @err = @@error

	if @err=547
			Exec spa_ErrorHandler -1, 'Ownership', 
					'spa_maintain_wellhead', 'DB Error', 
					'Please delete ''Ownership'' before deleting ''Wellhead Detail''.', ''
	else 
			Exec spa_ErrorHandler -1, 'Ownership', 
					'spa_maintain_wellhead', 'DB Error', 
					'Error deleting wellhead.', ''
end catch

	
END 