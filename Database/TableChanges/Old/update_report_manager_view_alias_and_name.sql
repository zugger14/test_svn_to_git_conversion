--Update view name
UPDATE data_source
SET [name] = 'Deal Settlement View'
WHERE [name]='deal_settlement_view'

UPDATE data_source
SET [name] = 'Deal Header View'
WHERE [name]='Deal_Header_View'

UPDATE data_source
SET [name] = 'Deal Detail View'
WHERE [name]='Deal_Detail_View'

UPDATE data_source
SET [name] = 'Delta Monthly Position'
WHERE [name]='delta_monthly_position'

UPDATE data_source
SET [name] = 'Delta Hourly Position'
WHERE [name]='delta hourly positin'

UPDATE data_source
SET [name] = 'Position View Hourly'
WHERE [name]='Position_View_Hourly'

UPDATE data_source
SET [name] = 'Position View Daily'
WHERE [name]='Position_View_Daily'

UPDATE data_source
SET [name] = 'Position View Monthly'
WHERE [name]='Position_View_Monthly'

UPDATE data_source
SET [name] = 'UDF View'
WHERE [name]='UDF_View'

UPDATE data_source
SET [name] = 'Settlement View',
[alias] = 'STV'
WHERE [name]='Settlement_View'

UPDATE data_source
set name ='User Roles Privileges View' 
where name ='User_Roles_Privileges'

--Update view alias
UPDATE data_source SET alias = 'DDV' WHERE alias LIKE 'deal_detail_view'
UPDATE data_source SET alias = 'DHV' WHERE alias LIKE 'Deal_Header_View'
UPDATE data_source SET alias = 'MTMV' WHERE alias LIKE 'MTM_V'

UPDATE report_dataset SET alias = 'DDV' WHERE alias LIKE 'deal_detail_view%'
UPDATE report_dataset SET alias = 'DHV' WHERE alias LIKE 'Deal_Header_View%'
UPDATE report_dataset SET alias = 'STV' WHERE alias LIKE 'Settlement_View%'
UPDATE report_dataset SET alias = 'MTMV' WHERE alias LIKE 'MTM_V'

 

