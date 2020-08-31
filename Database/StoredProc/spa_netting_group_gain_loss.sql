IF OBJECT_ID(N'spa_netting_group_gain_loss', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_netting_group_gain_loss]
GO 

CREATE PROCEDURE [dbo].[spa_netting_group_gain_loss]   
	@flag CHAR,
	@netting_group_id INT,
	@source_deal_header_id INT = NULL				
AS 

IF @flag = 's'
BEGIN
SELECT netting_group_gain_loss.netting_group_id GroupID,
 netting_group.netting_group_name AS GroupName,
	--NETTING_GROUP_PARENT.netting_parent_group_name AS [Netting Parent Group Name],  
           	--netting_group_gain_loss.netting_group_detail_id AS  [Netting Parent Group ID],
	dbo.FNAHyperLinkText(10131000, cast(source_deal_header.source_deal_header_id as varchar) + ' (SourceID: ' + source_deal_header.deal_id + ')', source_deal_header.source_deal_header_id) AS [Deal]

FROM         netting_group_gain_loss INNER JOIN
                   netting_group ON netting_group_gain_loss.netting_group_id = netting_group.netting_group_id  INNER JOIN
	source_deal_header ON source_deal_header.source_deal_header_id=netting_group_gain_loss.source_deal_header_id
                   WHERE   netting_group_gain_loss.netting_group_id = @netting_group_id
END

ELSE IF @flag = 'i'
 BEGIN
 	INSERT INTO netting_group_gain_loss (netting_group_id,source_deal_header_id)
 	values (@netting_group_id,
 		@source_deal_header_id) 
 	
 
 	If @@ERROR <> 0
 		Exec spa_ErrorHandler @@ERROR, 'Netting Group Detail', 
 				'spa_netting_group_gain_loss', 'DB Error', 
 				'Failed to insert netting group detail.', ''
 	else
 		Exec spa_ErrorHandler 0, 'Netting Group Detail', 
 				'spa_netting_group_gain_loss', 'Success', 
 				'Netting group detail inserted.', ''
 
 END
 
 ELSE IF @flag = 'd'
 BEGIN
 	DELETE netting_group_gain_loss where netting_group_id = @netting_group_id
 
 	If @@ERROR <> 0
 		Exec spa_ErrorHandler @@ERROR, 'Netting Group Detail', 
 				'spa_netting_group_gain_loss', 'DB Error', 
 				'Failed to delete netting group detail.', ''
 	else
 		Exec spa_ErrorHandler 0, 'Netting Group Detail', 
 				'spa_netting_group_gain_loss', 'Success', 
 				'Netting group detail deleted.', ''
 	
 END




