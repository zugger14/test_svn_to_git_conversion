IF OBJECT_ID(N'[dbo].[spa_Netting_Group_Parent_Subsidiary]', N'P') IS NOT NULL
    DROP PROC [dbo].[spa_Netting_Group_Parent_Subsidiary]
GO

CREATE PROC [dbo].[spa_Netting_Group_Parent_Subsidiary]
@flag CHAR(1) ,
@netting_parent_group_id VARCHAR(100) = NULL,
@fas_subsidiary_id VARCHAR(100) = NULL

AS

BEGIN
	IF @flag = 's'
	BEGIN
	    SELECT entity_name
	    FROM   netting_group_parent_subsidiary ngps
	           INNER JOIN portfolio_hierarchy ph
	                ON  ngps.fas_subsidiary_id = ph.entity_id
	END
	ELSE 
	IF @flag = 'i'
	BEGIN
	    IF NOT EXISTS (
	           SELECT 'X'
	           FROM   netting_group_parent_subsidiary
	           WHERE  netting_parent_group_id = @netting_parent_group_id
	                  AND fas_subsidiary_id 
	                      IN (SELECT item
	                          FROM   dbo.[SplitCommaSeperatedValues](@fas_subsidiary_id))
	       )
	    BEGIN
	        INSERT INTO netting_group_parent_subsidiary
	          (
	            netting_parent_group_id,
	            fas_subsidiary_id
	          )
	        SELECT @netting_parent_group_id col1,
	               item col2
	        FROM   dbo.[SplitCommaSeperatedValues](@fas_subsidiary_id)
	        
	        
	        IF @@ERROR <> 0
	            EXEC spa_ErrorHandler @@ERROR,
	                 "Netting Parent Group Subsidiary",
	                 "spa_Netting_Group_Parent_Subsidiary",
	                 "DB Error",
	                 "Failed to insert netting parent group Subsidiary.",
	                 ''
	        ELSE
	            EXEC spa_ErrorHandler 0,
	                 "Netting Parent Group Subsidiary",
	                 "spa_Netting_Group_Parent_Subsidiary",
	                 "Success",
	                 "Netting parent group Subsidiary inserted.",
	                 @netting_parent_group_id
	        
	        RETURN
	    END
	    ELSE
	    BEGIN
	        EXEC spa_ErrorHandler -1,
	             "Netting Parent Group Subsidiary",
	             "spa_Netting_Group_Parent_Subsidiary",
	             "DB Error",
	             "One or more selected subsidiaries are already inserted.",
	             ''
	        
	        RETURN
	    END
	END
	
	IF @flag = 'a'
	BEGIN
	    SELECT ngps.fas_subsidiary_id,
	           ngps.netting_parent_group_id ,
	           ph.entity_name [Subsidiary]
	    FROM   netting_group_parent_subsidiary ngps
	           INNER JOIN portfolio_hierarchy ph
	                ON  ngps.fas_subsidiary_id = ph.entity_id
	    WHERE  ngps.netting_parent_group_id = @netting_parent_group_id
	END
	ELSE 
	IF @flag = 'd'
	BEGIN
	    DELETE 
	    FROM   netting_group_parent_subsidiary
	    WHERE  netting_parent_group_id 
	           IN (SELECT *
	               FROM   [dbo].SplitCommaSeperatedValues(@netting_parent_group_id))
	           AND fas_subsidiary_id IN (SELECT *
	                                     FROM   [dbo].SplitCommaSeperatedValues(@fas_subsidiary_id))
	    
	    IF @@ERROR <> 0
	        EXEC spa_ErrorHandler @@ERROR,
	             "Netting Parent Group Subsidiary",
	             "spa_Netting_Group_Parent_Subsidiary",
	             "DB Error",
	             "Failed to delete netting parent group Subsidiary.",
	             ''
	    ELSE
	        EXEC spa_ErrorHandler 0,
	             "Netting Parent Group Subsidiary",
	             "spa_Netting_Group_Parent_Subsidiary",
	             "Success",
	             "Netting parent group Subsidiary deleted.",
	             ''
	END
	IF @flag = 'g'
	BEGIN
	    SELECT 
	           ngps.netting_parent_group_id,
	           ngps.fas_subsidiary_id subsidiary
	    FROM   netting_group_parent_subsidiary ngps
			INNER JOIN portfolio_hierarchy ph
				ON ngps.fas_subsidiary_id = ph.entity_id
					AND	ph.entity_type_value_id = 525 
					AND ph.entity_id <> -1           
	    WHERE  ngps.netting_parent_group_id = @netting_parent_group_id
		ORDER BY ph.entity_name 
	END
END



