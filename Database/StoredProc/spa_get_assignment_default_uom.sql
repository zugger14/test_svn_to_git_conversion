IF OBJECT_ID(N'[dbo].[spa_get_assignment_default_uom]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_assignment_default_uom]
GO 

--exec spa_get_assignment_default_uom 5146, 5118

CREATE PROCEDURE [dbo].[spa_get_assignment_default_uom] 
	@assignment_type_value_id int,
	@state_value_id int = null
AS

DECLARE @uom_label1 varchar(100)
DECLARE @uom_labe12 varchar(100)

SELECT     @uom_label1  = uom_label
FROM         rec_assignment_default_uom
WHERE     (assignment_type_value_id = @assignment_type_value_id) AND (state_value_id IS NULL)

SELECT     @uom_labe12 = uom_label
FROM         rec_assignment_default_uom
WHERE     (assignment_type_value_id = @assignment_type_value_id) AND (state_value_id = @state_value_id)


Select 'Volume in ' + isnull(@uom_labe12, @uom_label1) uom





