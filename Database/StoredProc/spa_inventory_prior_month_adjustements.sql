IF OBJECT_ID(N'spa_inventory_prior_month_adjustements', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_inventory_prior_month_adjustements]
 GO 




CREATE PROCEDURE [dbo].[spa_inventory_prior_month_adjustements]
	@flag CHAR(1),
	@contract_month VARCHAR(50) = NULL,
	@deal_id VARCHAR(50) = NULL,
	@counterparty_id INT = NULL,
	@original_volume FLOAT = NULL,
	@change_volume_to FLOAT = NULL,
	@original_price FLOAT = NULL,
	@change_price_to FLOAT = NULL,
	@process_status VARCHAR(50) = NULL,
	@comment VARCHAR(250) = NULL
AS
IF @flag = 's'
    SELECT dbo.FNADateFormat(contract_month) as ProductionMonth ,deal_id FeederDealID, original_volume Volume, change_volume_to [Change Volume To],
	original_price Price ,change_price_to [Change Price To], 
	Case when (isnull(process_status,'o') ='c') then 'Processed' else 'Outstanding' end Status,
	comment Comment,a.user_l_name + ', ' + a.user_f_name + ' ' + isnull(a.user_m_name, '') UpdateBy,i.update_ts UpdateTs  from 
	inventory_prior_month_adjustements i join application_users a 
	on i.update_user=a.user_login_id
	where contract_month=@contract_month and counterparty_id = @counterparty_id
	

if @flag='a'
	select dbo.FNADateFormat(contract_month) contract_month  ,deal_id, counterparty_id, original_volume, change_volume_to,original_price,change_price_to, 
	comment,process_status  from inventory_prior_month_adjustements
	where contract_month=@contract_month and deal_id=@deal_id 
else if @flag='i'
begin
	insert inventory_prior_month_adjustements(
	contract_month,
	deal_id,
	counterparty_id,
	original_volume,
	change_volume_to,
	original_price,
	change_price_to,
	comment)
	values(
	@contract_month,
	@deal_id,
	@counterparty_id,
	@original_volume,
	@change_volume_to,
	@original_price,
	@change_price_to,
	@comment
)
	If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "Inventory Prior", 
						"spa_inventory_prior_month_adjustements", "DB Error", 
					"Error on updating Inventory Prior.", ''
	else
				Exec spa_ErrorHandler 0, 'Inventory Prior', 
						'spa_inventory_prior_month_adjustements', 'Success', 
						'Inventory Prior successfully Inserted.',''
end
else if @flag='u'
begin
	update  inventory_prior_month_adjustements
	set change_volume_to=@change_volume_to,
	change_price_to=@change_price_to,
	process_status=NULL,
	comment=@comment
	where contract_month=@contract_month and deal_id=@deal_id 

	If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "Inventory Prior", 
						"spa_inventory_prior_month_adjustements", "DB Error", 
					"Error on updating Inventory Prior.", ''
	else
				Exec spa_ErrorHandler 0, 'Inventory Prior', 
						'spa_inventory_prior_month_adjustements', 'Success', 
						'Inventory Prior successfully updated.',''
end




