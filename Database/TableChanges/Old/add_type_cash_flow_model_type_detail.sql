IF NOT EXISTS(SELECT  * FROM    sys.tables syst
INNER JOIN sys.columns sysc ON sysc.[object_id] = syst.[object_id]
WHERE syst.NAME = 'cash_flow_model_type_detail' and
sysc.NAME = 'type')
ALTER TABLE cash_flow_model_type_detail ADD type CHAR(1)

