
/**
Script table changes for performance tuning

*/


if OBJECT_ID('vwHourly_position_AllFilter') is not null
drop view vwHourly_position_AllFilter

if OBJECT_ID('vwHourly_position_AllFilter_profile') is not null
drop view vwHourly_position_AllFilter_profile

if OBJECT_ID('vwHourly_position_AllFilter_breakdown') is not null
drop view vwHourly_position_AllFilter_breakdown

if OBJECT_ID('vwHourly_position_AllFilter_financial') is not null
drop view vwHourly_position_AllFilter_financial

if OBJECT_ID('vwPosition_deal') is not null
drop view vwPosition_deal

if OBJECT_ID('vwPosition_profile') is not null
drop view vwPosition_profile

if OBJECT_ID('vwPosition_breakdown') is not null
drop view vwPosition_breakdown



if exists(select 1 from sys.indexes where [name]='indx_report_hourly_position_deal_deal_id')
drop index indx_report_hourly_position_deal_deal_id on report_hourly_position_deal

if exists(select 1 from sys.indexes where [name]='IX_PT_report_hourly_position_deal_term_start_expiration_date')
drop index IX_PT_report_hourly_position_deal_term_start_expiration_date on report_hourly_position_deal


if exists(select 1 from sys.indexes where [name]='indx_position_report_group_map_001')
drop index indx_position_report_group_map_001 on delta_report_hourly_position_financial

if exists(select 1 from sys.indexes where [name]='indx_report_hourly_position_deal_deal_id')
drop index indx_report_hourly_position_deal_deal_id on dbo.report_hourly_position_deal

if  exists(select 1 from sys.indexes where [name]='IX_PT_report_hourly_position_deal_term_start_expiration_date')
drop index IX_PT_report_hourly_position_deal_term_start_expiration_date on report_hourly_position_deal

if  exists(select 1 from sys.indexes where [name]='indx_report_hourly_position_profile')
drop index indx_report_hourly_position_profile on report_hourly_position_profile

if  exists(select 1 from sys.indexes where [name]='indx_report_hourly_position_profile_deal_id')
drop index indx_report_hourly_position_profile_deal_id on report_hourly_position_profile

if  exists(select 1 from sys.indexes where [name]='indx_report_hourly_position_breakdown_deal_date')
drop index indx_report_hourly_position_breakdown_deal_date on report_hourly_position_breakdown

if  exists(select 1 from sys.indexes where [name]='unique_indx_report_hourly_position_breakdown')
drop index unique_indx_report_hourly_position_breakdown on report_hourly_position_breakdown

if  exists(select 1 from sys.indexes where [name]='indx_delta_report_hourly_position_id')
drop index indx_delta_report_hourly_position_id on delta_report_hourly_position

if  exists(select 1 from sys.indexes where [name]='indx_delta_report_hourly_position_financial')
drop index indx_delta_report_hourly_position_financial on delta_report_hourly_position_financial

if  exists(select 1 from sys.indexes where [name]='indx_delta_report_hourly_position_breakdown')
drop index indx_delta_report_hourly_position_breakdown on delta_report_hourly_position_breakdown




/*





if OBJECT_ID('report_hourly_position_deal') is not null
drop view report_hourly_position_deal

if OBJECT_ID('report_hourly_position_profile') is not null
drop view report_hourly_position_profile

if OBJECT_ID('report_hourly_position_breakdown') is not null
drop view report_hourly_position_breakdown


if OBJECT_ID('report_hourly_position_fixed') is not null
drop view report_hourly_position_fixed

if OBJECT_ID('report_hourly_position_financial') is not null
drop view report_hourly_position_financial

if OBJECT_ID('delta_report_hourly_position_financial') is not null
drop view delta_report_hourly_position_financial

if OBJECT_ID('delta_report_hourly_position') is not null
drop view delta_report_hourly_position


if OBJECT_ID('delta_report_hourly_position_breakdown') is not null
drop view delta_report_hourly_position_breakdown




source_deal_detail_position

drop table report_hourly_position_deal_main
drop table report_hourly_position_profile_main
drop table report_hourly_position_breakdown_main
drop table report_hourly_position_fixed_main
drop table report_hourly_position_financial_main
drop table delta_report_hourly_position_financial_main
drop table delta_report_hourly_position_main
drop table delta_report_hourly_position_breakdown_main


ALTER TABLE source_deal_detail_position ADD
   CONSTRAINT FK_EmailContact_Email  
       FOREIGN KEY (EmailId)
      REFERENCES Email (Id)
      ON DELETE CASCADE



if not exists(SELECT * FROM sys.objects  WHERE TYPE = 'f' AND NAME = 'FK_source_minor_location_static_data_value')
BEGIN 


ALTER TABLE source_deal_detail_position  ADD CONSTRAINT FK_source_deal_detail_id FOREIGN KEY (source_deal_detail_id) REFERENCES dbo.source_deal_detail(source_deal_detail_id)  ON DELETE CASCADE



ALTER TABLE report_hourly_position_deal_main DROP CONSTRAINT FK_report_hourly_position_deal_main_001
ALTER TABLE report_hourly_position_profile_main DROP CONSTRAINT FK_report_hourly_position_profile_main_001
ALTER TABLE report_hourly_position_breakdown_main DROP CONSTRAINT FK_report_hourly_position_breakdown_main_001
ALTER TABLE report_hourly_position_fixed_main DROP CONSTRAINT FK_report_hourly_position_fixed_main_001
ALTER TABLE report_hourly_position_financial_main DROP CONSTRAINT FK_report_hourly_position_financial_main_001
ALTER TABLE delta_report_hourly_position_financial_main DROP CONSTRAINT FK_delta_report_hourly_position_financial_main_001
ALTER TABLE delta_report_hourly_position_main DROP CONSTRAINT FK_delta_report_hourly_position_main_001
ALTER TABLE delta_report_hourly_position_breakdown_main DROP CONSTRAINT FK_delta_report_hourly_position_breakdown_main_001

ALTER TABLE report_hourly_position_deal_main DROP CONSTRAINT FK_report_hourly_position_deal_main_002
ALTER TABLE report_hourly_position_profile_main DROP CONSTRAINT FK_report_hourly_position_profile_main_002
ALTER TABLE report_hourly_position_breakdown_main DROP CONSTRAINT FK_report_hourly_position_breakdown_main_002
ALTER TABLE report_hourly_position_fixed_main DROP CONSTRAINT FK_report_hourly_position_fixed_main_002
ALTER TABLE report_hourly_position_financial_main DROP CONSTRAINT FK_report_hourly_position_financial_main_002
ALTER TABLE delta_report_hourly_position_financial_main DROP CONSTRAINT FK_delta_report_hourly_position_financial_main_002
ALTER TABLE delta_report_hourly_position_main DROP CONSTRAINT FK_delta_report_hourly_position_main_002
ALTER TABLE delta_report_hourly_position_breakdown_main DROP CONSTRAINT FK_delta_report_hourly_position_breakdown_main_002

--------------------------------------------------------------------------------------------------------------------------------------------

ALTER TABLE report_hourly_position_deal_main ADD CONSTRAINT FK_report_hourly_position_deal_main_001 FOREIGN KEY (source_deal_detail_id) REFERENCES dbo.source_deal_detail(source_deal_detail_id)  ON DELETE CASCADE
ALTER TABLE report_hourly_position_profile_main ADD CONSTRAINT FK_report_hourly_position_profile_main_001 FOREIGN KEY (source_deal_detail_id) REFERENCES dbo.source_deal_detail(source_deal_detail_id)  ON DELETE CASCADE
ALTER TABLE report_hourly_position_breakdown_main ADD CONSTRAINT FK_report_hourly_position_breakdown_main_001 FOREIGN KEY (source_deal_detail_id) REFERENCES dbo.source_deal_detail(source_deal_detail_id)  ON DELETE CASCADE
ALTER TABLE report_hourly_position_fixed_main ADD CONSTRAINT FK_report_hourly_position_fixed_main_001 FOREIGN KEY (source_deal_detail_id) REFERENCES dbo.source_deal_detail(source_deal_detail_id)  ON DELETE CASCADE
ALTER TABLE report_hourly_position_financial_main ADD CONSTRAINT FK_report_hourly_position_financial_main_001 FOREIGN KEY (source_deal_detail_id) REFERENCES dbo.source_deal_detail(source_deal_detail_id)  ON DELETE CASCADE
ALTER TABLE delta_report_hourly_position_financial_main ADD CONSTRAINT FK_delta_report_hourly_position_financial_main_001 FOREIGN KEY (source_deal_detail_id) REFERENCES dbo.source_deal_detail(source_deal_detail_id)  ON DELETE CASCADE
ALTER TABLE delta_report_hourly_position_main ADD CONSTRAINT FK_delta_report_hourly_position_main_001 FOREIGN KEY (source_deal_detail_id) REFERENCES dbo.source_deal_detail(source_deal_detail_id)  ON DELETE CASCADE
ALTER TABLE delta_report_hourly_position_breakdown_main ADD CONSTRAINT FK_delta_report_hourly_position_breakdown_main_001 FOREIGN KEY (source_deal_detail_id) REFERENCES dbo.source_deal_detail(source_deal_detail_id)  ON DELETE CASCADE

ALTER TABLE report_hourly_position_deal_main ADD CONSTRAINT FK_report_hourly_position_deal_main_002 FOREIGN KEY (source_deal_header_id) REFERENCES dbo.source_deal_header(source_deal_header_id)  ON DELETE CASCADE
ALTER TABLE report_hourly_position_profile_main ADD CONSTRAINT FK_report_hourly_position_profile_main_002 FOREIGN KEY (source_deal_header_id) REFERENCES dbo.source_deal_header(source_deal_header_id)  ON DELETE CASCADE
ALTER TABLE report_hourly_position_breakdown_main ADD CONSTRAINT FK_report_hourly_position_breakdown_main_002 FOREIGN KEY (source_deal_header_id) REFERENCES dbo.source_deal_header(source_deal_header_id)  ON DELETE CASCADE
ALTER TABLE report_hourly_position_fixed_main ADD CONSTRAINT FK_report_hourly_position_fixed_main_002 FOREIGN KEY (source_deal_header_id) REFERENCES dbo.source_deal_header(source_deal_header_id)  ON DELETE CASCADE
ALTER TABLE report_hourly_position_financial_main ADD CONSTRAINT FK_report_hourly_position_financial_main_002 FOREIGN KEY (source_deal_header_id) REFERENCES dbo.source_deal_header(source_deal_header_id)  ON DELETE CASCADE
ALTER TABLE delta_report_hourly_position_financial_main ADD CONSTRAINT FK_delta_report_hourly_position_financial_main_002 FOREIGN KEY (source_deal_header_id) REFERENCES dbo.source_deal_header(source_deal_header_id)  ON DELETE CASCADE
ALTER TABLE delta_report_hourly_position_main ADD CONSTRAINT FK_delta_report_hourly_position_main_002 FOREIGN KEY (source_deal_header_id) REFERENCES dbo.source_deal_header(source_deal_header_id)  ON DELETE CASCADE
ALTER TABLE delta_report_hourly_position_breakdown_main ADD CONSTRAINT FK_delta_report_hourly_position_breakdown_main_002 FOREIGN KEY (source_deal_header_id) REFERENCES dbo.source_deal_header(source_deal_header_id)  ON DELETE CASCADE




ALTER TABLE EmailContact ADD
   CONSTRAINT FK_EmailContact_Email  
       FOREIGN KEY (EmailId)
      REFERENCES Email (Id)
      ON DELETE CASCADE


END





*/