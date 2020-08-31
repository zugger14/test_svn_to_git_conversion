/*
   Wednesday, December 14, 20084:10:55 PM
   Generator:Bikash Subba
*/

/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_var_measurement_criteria_detail_portfolio_hierarchy]') AND parent_object_id = OBJECT_ID(N'[dbo].[var_measurement_criteria_detail]'))
ALTER TABLE [dbo].[var_measurement_criteria_detail] DROP CONSTRAINT [FK_var_measurement_criteria_detail_portfolio_hierarchy]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_var_measurement_criteria_detail_source_book]') AND parent_object_id = OBJECT_ID(N'[dbo].[var_measurement_criteria_detail]'))
ALTER TABLE [dbo].[var_measurement_criteria_detail] DROP CONSTRAINT [FK_var_measurement_criteria_detail_source_book]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_var_measurement_criteria_detail_source_book1]') AND parent_object_id = OBJECT_ID(N'[dbo].[var_measurement_criteria_detail]'))
ALTER TABLE [dbo].[var_measurement_criteria_detail] DROP CONSTRAINT [FK_var_measurement_criteria_detail_source_book1]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_var_measurement_criteria_detail_source_book2]') AND parent_object_id = OBJECT_ID(N'[dbo].[var_measurement_criteria_detail]'))
ALTER TABLE [dbo].[var_measurement_criteria_detail] DROP CONSTRAINT [FK_var_measurement_criteria_detail_source_book2]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_var_measurement_criteria_detail_source_book3]') AND parent_object_id = OBJECT_ID(N'[dbo].[var_measurement_criteria_detail]'))
ALTER TABLE [dbo].[var_measurement_criteria_detail] DROP CONSTRAINT [FK_var_measurement_criteria_detail_source_book3]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_var_measurement_criteria_detail_source_traders]') AND parent_object_id = OBJECT_ID(N'[dbo].[var_measurement_criteria_detail]'))
ALTER TABLE [dbo].[var_measurement_criteria_detail] DROP CONSTRAINT [FK_var_measurement_criteria_detail_source_traders]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_var_measurement_criteria_detail_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[var_measurement_criteria_detail]'))
ALTER TABLE [dbo].[var_measurement_criteria_detail] DROP CONSTRAINT [FK_var_measurement_criteria_detail_static_data_value]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_var_measurement_criteria_detail_static_data_value2]') AND parent_object_id = OBJECT_ID(N'[dbo].[var_measurement_criteria_detail]'))
ALTER TABLE [dbo].[var_measurement_criteria_detail] DROP CONSTRAINT [FK_var_measurement_criteria_detail_static_data_value2]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_var_measurement_criteria_detail_static_data_value3]') AND parent_object_id = OBJECT_ID(N'[dbo].[var_measurement_criteria_detail]'))
ALTER TABLE [dbo].[var_measurement_criteria_detail] DROP CONSTRAINT [FK_var_measurement_criteria_detail_static_data_value3]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_var_measurement_criteria_detail_static_data_value4]') AND parent_object_id = OBJECT_ID(N'[dbo].[var_measurement_criteria_detail]'))
ALTER TABLE [dbo].[var_measurement_criteria_detail] DROP CONSTRAINT [FK_var_measurement_criteria_detail_static_data_value4]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_var_measurement_criteria_detail_static_data_value5]') AND parent_object_id = OBJECT_ID(N'[dbo].[var_measurement_criteria_detail]'))
ALTER TABLE [dbo].[var_measurement_criteria_detail] DROP CONSTRAINT [FK_var_measurement_criteria_detail_static_data_value5]
GO

/****** Object:  Table [dbo].[var_measurement_criteria_detail]    Script Date: 12/17/2008 11:27:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[var_measurement_criteria_detail]') AND type in (N'U'))
DROP TABLE [dbo].[var_measurement_criteria_detail]

Go

BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
COMMIT
BEGIN TRANSACTION
GO
COMMIT
BEGIN TRANSACTION
GO
COMMIT
BEGIN TRANSACTION
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE var_measurement_criteria_detail(
	id int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	name varchar(200),
	what_if varchar(1),
	category int,
	source_system_book_id1 int,
	source_system_book_id2 int,
	source_system_book_id3 int,
	source_system_book_id4 int,
	role int,
	trader int,
	use_values int,
	include_hypothetical_transactions varchar(1),
	include_options_delta varchar(1),
	include_options_gamma varchar(1),
	include_options_notional varchar(1),
	market_credit_correlation float,
	var_approach int,
	start_date datetime,
	simulation_days int,
	confidence_interval int,
	holding_period int,
	price_curve_source int,
	daily_return_data_series int,
	data_points int,
	active varchar(1)

)

	
GO
ALTER TABLE dbo.var_measurement_criteria_detail ADD CONSTRAINT
	FK_var_measurement_criteria_detail_source_book FOREIGN KEY
	(
	source_system_book_id1
	) REFERENCES dbo.source_book
	(
	source_book_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.var_measurement_criteria_detail ADD CONSTRAINT
	FK_var_measurement_criteria_detail_source_book1 FOREIGN KEY
	(
	source_system_book_id2
	) REFERENCES dbo.source_book
	(
	source_book_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.var_measurement_criteria_detail ADD CONSTRAINT
	FK_var_measurement_criteria_detail_source_book2 FOREIGN KEY
	(
	source_system_book_id3
	) REFERENCES dbo.source_book
	(
	source_book_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.var_measurement_criteria_detail ADD CONSTRAINT
	FK_var_measurement_criteria_detail_source_book3 FOREIGN KEY
	(
	source_system_book_id4
	) REFERENCES dbo.source_book
	(
	source_book_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.var_measurement_criteria_detail ADD CONSTRAINT
	FK_var_measurement_criteria_detail_source_traders FOREIGN KEY
	(
	trader
	) REFERENCES dbo.source_traders
	(
	source_trader_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.var_measurement_criteria_detail ADD CONSTRAINT
	FK_var_measurement_criteria_detail_static_data_value FOREIGN KEY
	(
	use_values
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO

ALTER TABLE dbo.var_measurement_criteria_detail ADD CONSTRAINT
	FK_var_measurement_criteria_detail_static_data_value2 FOREIGN KEY
	(
	var_approach
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.var_measurement_criteria_detail ADD CONSTRAINT
	FK_var_measurement_criteria_detail_static_data_value3 FOREIGN KEY
	(
	price_curve_source
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.var_measurement_criteria_detail ADD CONSTRAINT
	FK_var_measurement_criteria_detail_static_data_value4 FOREIGN KEY
	(
	daily_return_data_series
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.var_measurement_criteria_detail ADD CONSTRAINT
	FK_var_measurement_criteria_detail_static_data_value5 FOREIGN KEY
	(
	confidence_interval
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
