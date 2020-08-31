IF OBJECT_ID(N'[dbo].[spa_netting_parent_groups]', N'P') IS NOT NULL
    DROP PROC [dbo].[spa_netting_parent_groups]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET CONCAT_NULL_YIELDS_NULL ON
GO



--This procedure returns all netting groups
CREATE PROC [dbo].[spa_netting_parent_groups] 		
	@flag							CHAR,
	@netting_parent_group_id		INT = NULL,
	@netting_parent_group_name		VARCHAR(100) = NULL,
	@active							VARCHAR(1) = NULL,
	@active_gain_loss				VARCHAR(1) = NULL,
	@legal_entity					INT = NULL,
	@counterparty_id				INT = NULL,
	@subsidiary_ids					VARCHAR(1000) = NULL,
	@del_net_parent_grp_id			VARCHAR(1000) = NULL
AS 
SET NOCOUNT ON

IF @flag = 'l'
BEGIN
    SELECT netting_parent_group_id [Netting Parent Group ID],
           netting_parent_group_name [Netting Parent Group Name],
           CASE ACTIVE
                WHEN 'y' THEN 'Yes'
                ELSE 'No'
           END                      AS [Active],
           Legal_entity_name + CASE 
                                    WHEN ssd.source_system_name = 'farrms' THEN 
                                         ''
                                    ELSE '.' + ssd.source_system_name
                               END     Entity,
           ngp.legal_entity
    FROM   NETTING_GROUP_PARENT ngp
           LEFT OUTER JOIN source_legal_entity sle
                ON  ngp.legal_entity = sle.source_legal_entity_id
           LEFT OUTER JOIN source_system_description ssd
                ON  ssd.source_system_id = sle.source_system_id
END
ELSE 
IF @flag = 's'
BEGIN
    SELECT ngp.netting_parent_group_id [Netting Parent Group ID],
           netting_parent_group_name [Netting Parent Group Name],
           CASE ACTIVE
                WHEN 'y' THEN 'Yes'
                ELSE 'No'
           END                      AS [Active],
           Legal_entity_name + CASE 
                                    WHEN ssd.source_system_name = 'farrms' THEN 
                                         ''
                                    ELSE '.' + ssd.source_system_name
                               END     Entity
    FROM   netting_group_parent ngp
           LEFT OUTER JOIN source_legal_entity sle
                ON  ngp.legal_entity = sle.source_legal_entity_id
           LEFT OUTER JOIN source_system_description ssd
                ON  ssd.source_system_id = sle.source_system_id
    WHERE  ACTIVE = 'y'
           --INNER JOIN netting_group ng ON ng.netting_parent_group_id = ngp.netting_parent_group_id
           --INNER JOIN netting_group_detail ngd ON ngd.netting_group_id = ng.netting_group_id
           --AND ngd.source_counterparty_id = @counterparty_id
END
ELSE 
IF @flag = 'i'
BEGIN
    INSERT INTO NETTING_GROUP_PARENT
      (
        netting_parent_group_name,
        ACTIVE,
        active_gain_loss,
        legal_entity
      )
    VALUES
      (
        @netting_parent_group_name,
        @active,
        @active_gain_loss,
        @legal_entity
      )
    
    DECLARE @parent_group_id INT
    SET @parent_group_id = SCOPE_IDENTITY() 
    
    
    IF @subsidiary_ids IS NOT NULL
    BEGIN
        SET @parent_group_id = SCOPE_IDENTITY() 
        
        INSERT INTO netting_group_parent_subsidiary
          (
            netting_parent_group_id,
            fas_subsidiary_id
          )
        SELECT @parent_group_id,
               item
        FROM   dbo.SplitCommaSeperatedValues(@subsidiary_ids) scsv
    END
    
    DECLARE @recommend_netting_parent_group_id VARCHAR(20)
    SELECT @recommend_netting_parent_group_id = SCOPE_IDENTITY()
	
	SET @recommend_netting_parent_group_id = @recommend_netting_parent_group_id + '_0_0'

    
    IF @@ERROR <> 0
        EXEC spa_ErrorHandler @@ERROR,
             'Netting Parent Group',
             'spa_netting_parent_groups',
             'DB Error',
             'Failed to Insert Netting Parent Group.',
             ''
    ELSE
        EXEC spa_ErrorHandler 0,
             'Netting Parent Group',
             'spa_netting_parent_groups',
             'Success',
             'Changes have been saved successfully.',
             @parent_group_id 
END
ELSE 
IF @flag = 'u'
BEGIN
    UPDATE NETTING_GROUP_PARENT
    SET    netting_parent_group_name = @netting_parent_group_name,
           ACTIVE = @active,
           legal_entity = @legal_entity
    WHERE  netting_parent_group_id = @netting_parent_group_id
    
    IF @subsidiary_ids IS NOT NULL
    BEGIN
        INSERT INTO netting_group_parent_subsidiary
          (
            netting_parent_group_id,
            fas_subsidiary_id
          )
        SELECT @netting_parent_group_id,
               item
        FROM   dbo.SplitCommaSeperatedValues(@subsidiary_ids) scsv
               LEFT JOIN netting_group_parent_subsidiary ngps
                    ON  ngps.fas_subsidiary_id = scsv.item
                    AND ngps.netting_parent_group_id = @netting_parent_group_id
        WHERE  ngps.netting_parent_group_id IS NULL 		
        
        DELETE ngps
        FROM   netting_group_parent_subsidiary ngps
               LEFT JOIN dbo.SplitCommaSeperatedValues(@subsidiary_ids) scsv
                    ON  ngps.fas_subsidiary_id = scsv.item
        WHERE  ngps.netting_parent_group_id = @netting_parent_group_id
               AND scsv.item IS NULL
    END
    
    
    IF @@ERROR <> 0
        EXEC spa_ErrorHandler @@ERROR,
             'Netting Parent Group',
             'spa_netting_parent_groups',
             'DB Error',
             'Failed to Update Netting Parent Group.',
             ''
    ELSE
        EXEC spa_ErrorHandler 0,
             'Netting Parent Group',
             'spa_netting_parent_groups',
             'Success',
             'Changes have been saved successfully.',
             ''
END
ELSE 
IF @flag = 'd'
BEGIN
    DECLARE @ErrorNumber INT, @ErrorMessage VARCHAR(1000)

    BEGIN TRY
    	BEGIN TRANSACTION

    		DELETE ngps
    		FROM netting_group_parent_subsidiary ngps
			INNER JOIN dbo.FNASplit(@del_net_parent_grp_id, ',') di ON di.item = ngps.netting_parent_group_id
    	
    		DELETE ngp
    		FROM netting_group_parent ngp
			INNER JOIN dbo.FNASplit(@del_net_parent_grp_id, ',') di ON di.item = ngp.netting_parent_group_id
    	
    	COMMIT TRANSACTION
    END TRY	
    
    BEGIN CATCH
    	IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

    	SELECT @ErrorNumber = ERROR_NUMBER(),
    	       @ErrorMessage = ERROR_MESSAGE();
    END CATCH
    
    IF @ErrorNumber = 547
        SELECT 'Error',
               'Netting Parent Group',
               'spa_netting_parent_groups',
               'DB Error',
               'Please Delete Netting Groups First.' [message],
               ''
    ELSE 
    IF @ErrorNumber > 0
        EXEC spa_ErrorHandler @ErrorNumber,
             'Netting Parent Group',
             'spa_netting_parent_groups',
             'DB Error',
             'Fail to Delete Netting Parent Group. ',
             ''
    ELSE
        EXEC spa_ErrorHandler 0,
             'Netting Parent Group',
             'spa_netting_parent_groups',
             'Success',
             'Changes have been saved successfully.',
             ''
END
ELSE 
IF @flag = 'g'
BEGIN
    SELECT CAST(ngp.netting_parent_group_id AS VARCHAR(10)) + '_0_0' 
           parent_netting_id,
           dbo.FNAEncodeXML(ngp.netting_parent_group_name) netting_parent_group_name,
           CAST(ngp.netting_parent_group_id AS VARCHAR(10)) + '_' + CAST(ng.netting_group_id AS VARCHAR(10)) 
           + '_0' netting_id,
           dbo.FNAEncodeXML(ng.netting_group_name) netting_group_name,
           CAST(ngp.netting_parent_group_id AS VARCHAR(10)) + '_' + CAST(ng.netting_group_id AS VARCHAR(10)) 
           + '_' + CAST(ngd.netting_group_detail_id AS VARCHAR(10)) 
           netting_detail_id,
		   ISNULL(dbo.FNAEncodeXML(sc.counterparty_name), dbo.FNAEncodeXML(ng.netting_group_name))  netting_detail_name
    FROM   netting_group_parent ngp
           LEFT JOIN netting_group ng
                ON  ng.netting_parent_group_id = ngp.netting_parent_group_id
           LEFT JOIN netting_group_detail ngd
                ON  ngd.netting_group_id = ng.netting_group_id
           LEFT JOIN source_counterparty sc
                ON  sc.source_counterparty_id = ngd.source_counterparty_id
	WHERE ngp.netting_parent_group_id <> -1
END
IF @flag = 'c'
BEGIN
    SELECT ngp.netting_parent_group_id [Netting Parent Group ID],
           netting_parent_group_name [Netting Parent Group Name]
    FROM   netting_group_parent ngp
           LEFT OUTER JOIN source_legal_entity sle
                ON  ngp.legal_entity = sle.source_legal_entity_id
           LEFT OUTER JOIN source_system_description ssd
                ON  ssd.source_system_id = sle.source_system_id
    WHERE  ACTIVE = 'y'
END