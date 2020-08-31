IF OBJECT_ID(N'[dbo].[spa_get_deal_disable_gui_group]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_deal_disable_gui_group]
GO 

CREATE PROCEDURE [dbo].[spa_get_deal_disable_gui_group]
as

select source_deal_type_id deal_id from source_deal_type where disable_gui_groups='y'

