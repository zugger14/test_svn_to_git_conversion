--source_price_curve_def

-- select * from source_deal_header
update source_deal_header set block_define_id=NULL 
where ISNULL(block_define_id,292037) not in(select value_id from static_data_value)



--select * from source_price_curve_def
----update source_price_curve_def set block_define_id=NULL 
--where ISNULL(block_define_id,292037) not in(select value_id from static_data_value)


delete  from hour_block_term
--update source_deal_header set block_define_id=NULL 
where ISNULL(block_define_id,292037) not in(select value_id from static_data_value)

--select * from source_deal_header_template
update source_deal_header_template set block_define_id=NULL 
where ISNULL(block_define_id,292037) not in(select value_id from static_data_value)

--exec [dbo].spa_generate_hour_block_term null,2000,2030
--EXEC [dbo].[spa_update_deal_total_volume] null,'DDDFRRfffRE',5, NULL,'farrms_admin'

IF  NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_deal_header_static_data_value1]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_deal_header]'))
	ALTER TABLE [dbo].[source_deal_header] ADD  CONSTRAINT [FK_source_deal_header_static_data_value1] FOREIGN KEY([block_define_id])
	REFERENCES [dbo].[static_data_value] ([value_id])

GO

IF  NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_price_curve_def_static_data_value5]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_price_curve_def]'))
	ALTER TABLE [dbo].source_price_curve_def ADD  CONSTRAINT FK_source_price_curve_def_static_data_value5 FOREIGN KEY([block_define_id])
	REFERENCES [dbo].[static_data_value] ([value_id])

GO

IF  NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_price_curve_def_static_data_value6]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_deal_header_template]'))
	ALTER TABLE [dbo].source_deal_header_template ADD  CONSTRAINT FK_source_price_curve_def_static_data_value6 FOREIGN KEY([block_define_id])
	REFERENCES [dbo].[static_data_value] ([value_id])

GO

