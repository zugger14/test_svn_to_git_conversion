/*
   Thursday, March 26, 20099:29:10 AM
   Created by : Bikash Subba
   Objective  : Drop column from_location_id, to_location_id.
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
ALTER TABLE dbo.delivery_path
	DROP CONSTRAINT fk_from_location_id
GO
ALTER TABLE dbo.delivery_path
	DROP CONSTRAINT fk_to_location_id
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.delivery_path
	DROP COLUMN from_location_id, to_location_id
GO
COMMIT
