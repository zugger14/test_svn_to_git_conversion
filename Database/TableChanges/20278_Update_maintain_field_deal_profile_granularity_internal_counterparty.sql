UPDATE mfd 
SET sql_string = 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 978'
FROM maintain_field_deal mfd WHERE mfd.farrms_field_id = 'profile_granularity'
GO

UPDATE mfd
SET    mfd.field_size = 180
FROM   maintain_field_deal mfd
WHERE  mfd.farrms_field_id = 'internal_counterparty'
GO