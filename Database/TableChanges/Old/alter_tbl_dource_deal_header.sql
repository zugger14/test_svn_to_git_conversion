

IF  EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header' AND COLUMN_NAME = 'deal_status')
	BEGIN
		ALTER TABLE source_deal_header drop column deal_status  
	END

ALTER TABLE source_deal_header ADD deal_status int 



ALTER TABLE [dbo].[source_deal_header]  WITH NOCHECK ADD  CONSTRAINT [FK_source_deal_header1_static_data_value1]
 FOREIGN KEY(deal_status) REFERENCES [dbo].[static_data_value] ([value_id])





 











