-- Insert Static_data Type to define Calendar
insert into static_data_type(type_id,type_name,internal,description)
select 10017,'Calendar',0,'Calendar'
GO
--- Alter Table Source_price_curve_def to Add two more fields
Alter table source_price_curve_def
	ADD risk_bucket_id INT,exp_calendar_id INT
GO
ALTER TABLE [dbo].[source_price_curve_def]  WITH CHECK ADD  CONSTRAINT [FK_source_price_curve_def_static_data_value2] FOREIGN KEY([exp_calendar_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[source_price_curve_def]  WITH CHECK ADD  CONSTRAINT [FK_source_price_curve_def_source_price_curve_def3] FOREIGN KEY([risk_bucket_id])
REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id])
GO
