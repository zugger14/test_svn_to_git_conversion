
SET IDENTITY_INSERT dbo.netting_group_parent ON

IF NOT EXISTS ( SELECT 1  FROM   netting_group_parent WHERE netting_parent_group_id = -1)
BEGIN
	INSERT INTO netting_group_parent
      (
        netting_parent_group_id,
        netting_parent_group_name,
        active
      )
    VALUES(
    	-1,
         'Settlement Netting Group',
         'y'
        )
END
ELSE
BEGIN
    UPDATE netting_group_parent
    SET    netting_parent_group_name = 'Settlement Netting Group',
			active = 'y'
    WHERE  netting_parent_group_id = -1
END

SET IDENTITY_INSERT dbo.netting_group_parent OFF
GO

 