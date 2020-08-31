IF OBJECT_ID(N'spa_getinternaldealtype', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_getinternaldealtype]
GO 

CREATE PROCEDURE [dbo].[spa_getinternaldealtype]
	@flag NCHAR(1),
	@sub_type NCHAR(1) = 'n'
AS 

IF @flag = 's'
BEGIN
    IF @sub_type = 'n'
    BEGIN
        SELECT internal_deal_type_subtype_id,
               internal_deal_type_subtype_type
        FROM   internal_deal_type_subtype_types
        WHERE type_subtype_flag IS NULL 
    END
    ELSE
    BEGIN
        SELECT internal_deal_type_subtype_id,
               internal_deal_type_subtype_type
        FROM   internal_deal_type_subtype_types
        WHERE type_subtype_flag = 'y'
    END
END


IF @@ERROR <> 0
    EXEC spa_ErrorHandler @@ERROR,
         'Deal Type',
         'spa_getinternaldealtype',
         'DB Error',
         'Failed to select Internal deal type.',
         ''