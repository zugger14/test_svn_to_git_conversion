
DECLARE @field_template_id INT 
DECLARE [add_lock_deal_detail] CURSOR FORWARD_ONLY READ_ONLY 
FOR
    SELECT field_template_id
    FROM   maintain_field_template
    WHERE  field_template_id NOT IN (SELECT mftd.field_template_id
                                     FROM   maintain_field_template_detail mftd
                                     WHERE  mftd.field_id = 132
                                            AND mftd.udf_or_system = 's')   


OPEN [add_lock_deal_detail]
FETCH NEXT FROM [add_lock_deal_detail] INTO @field_template_id

WHILE @@FETCH_STATUS = 0
BEGIN
	--ROW OPERATION HERE
	EXEC spa_maintain_field_properties 'i', NULL, @field_template_id, NULL, 'lock_deal_detail', NULL 
	, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
	, NULL, NULL, NULL, NULL	
	
	FETCH NEXT FROM [add_lock_deal_detail] INTO @field_template_id
END 

CLOSE [add_lock_deal_detail]
DEALLOCATE [add_lock_deal_detail]  


DECLARE [add_status] CURSOR FORWARD_ONLY READ_ONLY 
FOR
    SELECT field_template_id
    FROM   maintain_field_template
    WHERE  field_template_id NOT IN (SELECT mftd.field_template_id
                                     FROM   maintain_field_template_detail mftd
                                     WHERE  mftd.field_id = 133
                                            AND mftd.udf_or_system = 's')   


OPEN [add_status]
FETCH NEXT FROM [add_status] INTO @field_template_id

WHILE @@FETCH_STATUS = 0
BEGIN
	--ROW OPERATION HERE
	EXEC spa_maintain_field_properties 'i', NULL, @field_template_id, NULL, 'status', NULL 
	, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
	, NULL, NULL, NULL, NULL	
	
	FETCH NEXT FROM [add_status] INTO @field_template_id
END 

CLOSE [add_status]
DEALLOCATE [add_status]  
