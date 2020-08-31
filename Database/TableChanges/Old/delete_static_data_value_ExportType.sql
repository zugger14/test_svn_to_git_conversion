/************************************************************
-- Author:		sbantawa@pioneersolutionglobals.com
-- Create date:	18th May, 2012
-- Description:	Deleting unnnecessary export type for FASTracker_RWE_DE
************************************************************/

IF EXISTS (SELECT 1 FROM dbo.static_data_value sdv WHERE  sdv.value_id = 1376)
    DELETE dbo.static_data_value WHERE  value_id = 1376
 
IF EXISTS (SELECT 1 FROM dbo.static_data_value sdv WHERE  sdv.value_id = 1375)
    DELETE dbo.static_data_value WHERE  value_id = 1375