/*
   Sunday, December 14, 20084:25:22 PM
   User: sa
   Server: BSUBBA\INSTANCE1
   Database: TRMTracker2_1
   Application: 
*/

/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
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
CREATE TABLE dbo.limit_tracking
	(
	id int NOT NULL IDENTITY (1, 1),
	limit_name varchar(500) NULL,
	limit_for varchar(1) NULL,
	trader_id int NULL,
	sub_id varchar(100) NULL,
	strategy_id varchar(100) NULL,
	book_id varchar(100) NULL,
	limit_type int NULL,
	curve_id int NULL,
	limit_value float(53) NULL,
	tenor_limit_value int NULL
	)  ON [PRIMARY]
GO
COMMIT
