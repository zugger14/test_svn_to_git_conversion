IF OBJECT_ID(N'spa_source_brokers_maintain', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_source_brokers_maintain]
GO 

CREATE PROCEDURE [dbo].[spa_source_brokers_maintain]
	@flag AS CHAR(1),					
	@source_broker_id INT = NULL,				
	@source_system_id INT = NULL,
	@broker_id VARCHAR(50) = NULL,
	@broker_name VARCHAR(100) = NULL,
	@broker_desc VARCHAR(500) = NULL,
	@user_name VARCHAR(50) = NULL
AS 
DECLARE @Sql_Select VARCHAR(5000)

if @flag='i'
BEGIN
	declare @cont1 varchar(100)
	select @cont1= count(*) from source_brokers where broker_id =@broker_id AND source_system_id=@source_system_id
	if (@cont1>0)
	BEGIN
		SELECT 'Error', 'Can not insert duplicate ID :'+@broker_id, 
			'spa_application_security_role', 'DB Error', 
			'Can not insert duplicate ID :'+@broker_id, ''
		RETURN
	END
INSERT INTO source_brokers
		(
		source_system_id,
		broker_id,
		broker_name,
		broker_desc,
		create_user,
		create_ts,
		update_user,
		update_ts
		)
	values
		(				
		@source_system_id,
		@broker_id,		
		@broker_name,
		@broker_desc,
		@user_name,
		getdate(),
		@user_name,
		getdate()
		)

		if @@Error <> 0
		Exec spa_ErrorHandler @@Error, 'MaintainDefination', 
				'spa_source_brokers_maintain', 'DB Error', 
				'Failed to insert defination value.', ''
		Else
		Exec spa_ErrorHandler 0, 'MaintainDefination', 
				'spa_source_brokers_maintain', 'Success', 
				'Defination data value inserted.', ''
end

else if @flag='a' 
begin
	select source_brokers.source_broker_id, source_system_description.source_system_name,
	source_brokers.broker_id, source_brokers.broker_name, 
	source_brokers.broker_desc from source_brokers inner join source_system_description on
	source_system_description.source_system_id = source_brokers.source_system_id where source_broker_id=@source_broker_id
	

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Source_brokers table', 
				'spa_source_brokers_maintain', 'DB Error', 
				'Failed to select maintain defiantion detail record of Item type.', ''
	Else
		Exec spa_ErrorHandler 0, 'Source_brokers table', 
				'spa_source_brokers_maintain', 'Success', 
				'Source_brokers detail record of Item Type successfully selected.', ''
end

else if @flag='s' 
begin
	set @Sql_Select='select source_brokers.source_broker_id AS [Source Broker ID]
	,broker_name + CASE WHEN source_brokers.source_system_id=2 THEN '''' ELSE ''.'' +  source_system_description.source_system_name END as Name,
	 source_brokers.broker_desc as Description, 
	 source_system_description.source_system_name as System from source_brokers 
	 inner join source_system_description on
		source_system_description.source_system_id = source_brokers.source_system_id'
	if @source_system_id is not null 
		set @Sql_Select=@Sql_Select +  ' where source_brokers.source_system_id='+convert(varchar(20),@source_system_id)+''
	exec(@SQL_select)
end

Else if @flag = 'u'
begin
		declare @cont varchar(100)
	select @cont= count(*) from source_brokers where broker_id =@broker_id AND source_system_id=@source_system_id AND source_broker_id <> @source_broker_id
	if (@cont>0)
	BEGIN
		SELECT 'Error', 'Can not update duplicate ID :'+@broker_id, 
			'spa_application_security_role', 'DB Error', 
			'Can not update duplicate ID :'+@broker_id, ''
		RETURN
	END
	update source_brokers set source_system_id = @source_system_id, broker_id=@broker_id, broker_name = @broker_name, broker_desc = @broker_desc, 
	update_user=@user_name, update_ts=getdate()
	where source_broker_id = @source_broker_id

	if @@Error <> 0
		Exec spa_ErrorHandler @@Error, 'MaintainDefination', 
				'spa_source_brokers_maintain', 'DB Error', 
				'Failed to update defination value.', ''
		Else
		Exec spa_ErrorHandler 0, 'MaintainDefination', 
				'spa_source_brokers_maintain', 'Success', 
				'Defination data value updated.', ''
end

Else if @flag = 'd'
begin
	delete from source_brokers
	Where 	source_broker_id=@source_broker_id

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "MaintainDefination", 
				"spa_source_brokers_maintain", "DB Error", 
				"Delete of Maintain Defination Data failed.", ''
	Else
		Exec spa_ErrorHandler 0, 'MaintainDefination', 
				'spa_source_brokers_maintain', 'Success', 
				'Maintain Defination Data sucessfully deleted', ''
end






