/****** Object:  StoredProcedure [dbo].[spa_inventory_account_type_group]    Script Date: 10/06/2009 12:40:17 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_inventory_account_type_group]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_inventory_account_type_group]
/****** Object:  StoredProcedure [dbo].[spa_inventory_account_type_group]    Script Date: 10/06/2009 12:40:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_inventory_account_type_group]
	@flag char(1) , -- i : insert, u : update, d : delete ,a : select
	@group_id int=NULL,
	@group_name varchar(100) = null,
	@inventory_calc_type_id INT=NULL,
	@account_type_value_id INT=NULL
AS
BEGIN

DECLARE @sql VARCHAR(8000)

	IF @flag='s'
	BEGIN
		SET @sql='SELECT 
					group_id [ID],
					account_type_value_id [AccountTypeID],
					group_name [Group Name],
					sd1.code AS [Account Type]
				FROM
					inventory_account_type_group ict
					LEFT JOIN static_data_value sd ON ict.inventory_calc_type_id=sd.value_id
					LEFT JOIN static_data_value sd1 ON ict.account_type_value_id=sd1.value_id
				WHERE 1=1'
				+ CASE WHEN  @group_id IS NOT NULL THEN ' AND group_id='+CAST(@group_id AS VARCHAR) ELSE '' END
		EXEC(@sql)
	END
	ELSE IF @flag = 'i'
	BEGIN		
		

		INSERT INTO inventory_account_type_group
		(
			group_name,
			inventory_calc_type_id,
			account_type_value_id									
		)
			select 
				@group_name,
				@inventory_calc_type_id,
				@account_type_value_id

		If @@ERROR <> 0
			BEGIN 
				Exec spa_ErrorHandler @@ERROR, "Insert Inventory Account Group.", 
						"spa_inventory_account_type_group", "DB Error", 
						"Failed inserting data.", ''
				RETURN
			END

				ELSE Exec spa_ErrorHandler 0, 'Insert Inventory Account Group.', 
						'spa_inventory_account_type_group', 'Success', 
						'Data inserted Successfully .',''

	END
	ELSE IF @flag = 'u'
	BEGIN
		UPDATE inventory_account_type_group
		SET
			group_name=@group_name,
			inventory_calc_type_id=@inventory_calc_type_id,
			account_type_value_id=@account_type_value_id
		WHERE
			group_id=@group_id

		If @@ERROR <> 0
			BEGIN 
				Exec spa_ErrorHandler @@ERROR, "Update Inventory Account Group.", 
						"spa_inventory_account_type_group", "DB Error", 
						"Failed updating data.", ''
				RETURN
			END

				ELSE Exec spa_ErrorHandler 0, 'Update Inventory Account Group.', 
						'spa_inventory_account_type_group', 'Success', 
						'Data updated Successfully .',''

	END
	ELSE IF @flag = 'd'
	BEGIN		

		DELETE FROM  inventory_account_type_group WHERE group_id=@group_id

		If @@ERROR <> 0
			BEGIN 
				Exec spa_ErrorHandler @@ERROR, "Delete Inventory Account Group.", 
						"spa_inventory_account_type_group", "DB Error", 
						"Failed deleting data.", '',''
				RETURN
			END

				ELSE Exec spa_ErrorHandler 0, 'Delete Inventory Account Group.', 
						'spa_inventory_account_type_group', 'Success', 
						'Data deleted Successfully .',''

	END
	
	ELSE IF @flag = 'a'
	BEGIN		
		SELECT
			group_id,
			group_name,
			inventory_calc_type_id,
			account_type_value_id
		FROM
			inventory_account_type_group 
		WHERE group_id=@group_id
					
	END
	IF @flag='c'
	BEGIN
		SET @sql='SELECT 
					group_id [ID],
					group_name [Group Name]
				FROM
					inventory_account_type_group ict
					LEFT JOIN static_data_value sd ON ict.inventory_calc_type_id=sd.value_id
					LEFT JOIN static_data_value sd1 ON ict.account_type_value_id=sd1.value_id
				WHERE 1=1'
				+ CASE WHEN  @group_id IS NOT NULL THEN ' AND group_id='+CAST(@group_id AS VARCHAR) ELSE '' END
		EXEC(@sql)
	END
END