/*
Vishwas Khanal
Dated: 02.04.2010
Defect Id : 1559
*/
if not exists(select 'x' from information_schema.columns where table_name = 'process_risk_controls_activities' and column_name = 'source_id')
alter table process_risk_controls_activities add  source_id varchar(10)