/*
create insert trigger for counterparty_products to store data on master_view_counterparty_products.

*/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[TRGINS_counterparty_products_master_view]', N'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGINS_counterparty_products_master_view]
GO

CREATE TRIGGER [dbo].[TRGINS_counterparty_products_master_view]
ON [dbo].[counterparty_products]
AFTER INSERT, UPDATE
AS
	IF @@ROWCOUNT = 0
        RETURN
	if exists (select 1 from deleted) 
		and exists (select top 1 1 from master_view_counterparty_products m 
					inner join inserted i on i.counterparty_product_id = m.counterparty_product_id)  
		
		--update trigger
	begin
	
		update mvcp
		set mvcp.commodity	= commodity.commodity_name
			, mvcp.origin	= origin_sdv.code
			, mvcp.form		= form.commodity_form_description
			, mvcp.attr1	= att1_form.commodity_form_name
			, mvcp.attr2	= att2_form.commodity_form_name
			, mvcp.attr3	= att3_form.commodity_form_name
			, mvcp.attr4	= att4_form.commodity_form_name
			, mvcp.attr5	= att5_form.commodity_form_name
			, mvcp.trader	= trader.trader

		from master_view_counterparty_products mvcp
		inner join inserted cp on cp.counterparty_product_id = mvcp.counterparty_product_id
		
		inner join source_commodity commodity on commodity.source_commodity_id = cp.commodity_id
		left join commodity_origin origin on origin.commodity_origin_id = cp.commodity_origin_id
		left join static_data_value origin_sdv on origin_sdv.value_id = origin.origin
		left join commodity_form cf on cf.commodity_form_id = cp.commodity_form_id
		left join commodity_type_form form on form.commodity_type_form_id = cf.form
		left join commodity_form_attribute1 att1 on att1.commodity_form_attribute1_id = cp.commodity_form_attribute1
		left join commodity_attribute_form att1_form on att1_form.commodity_attribute_form_id = att1.attribute_form_id
		left join commodity_form_attribute2 att2 on att2.commodity_form_attribute2_id = cp.commodity_form_attribute2
		left join commodity_attribute_form att2_form on att2_form.commodity_attribute_form_id = att2.attribute_form_id
		left join commodity_form_attribute3 att3 on att3.commodity_form_attribute3_id = cp.commodity_form_attribute3
		left join commodity_attribute_form att3_form on att3_form.commodity_attribute_form_id = att3.attribute_form_id
		left join commodity_form_attribute4 att4 on att4.commodity_form_attribute4_id = cp.commodity_form_attribute4
		left join commodity_attribute_form att4_form on att4_form.commodity_attribute_form_id = att4.attribute_form_id
		left join commodity_form_attribute5 att5 on att5.commodity_form_attribute5_id = cp.commodity_form_attribute5
		left join commodity_attribute_form att5_form on att5_form.commodity_attribute_form_id = att5.attribute_form_id
		outer apply (
			select cc.name trader from counterparty_contacts cc inner join dbo.SplitCommaSeperatedValues(cp.trader_id) scsv on scsv.item = cc.counterparty_contact_id
		) trader
	end
	else
	begin
	
		 
		INSERT into dbo.master_view_counterparty_products (counterparty_product_id,counterparty_id,counterparty_name,commodity,origin,form,attr1,attr2,attr3,attr4,attr5,trader)
		select cp.counterparty_product_id, cp.counterparty_id, sc.counterparty_name,
		commodity.commodity_name [commodity],origin_sdv.code origin,form.commodity_form_description [form]
		,att1_form.commodity_form_name [attr1],att2_form.commodity_form_name [attr2],att3_form.commodity_form_name [attr3],att4_form.commodity_form_name [attr4]
		,att5_form.commodity_form_name [attr5],trader.trader [trader]

		from inserted cp
		inner join source_counterparty sc on sc.source_counterparty_id = cp.counterparty_id
		inner join source_commodity commodity on commodity.source_commodity_id = cp.commodity_id
		left join commodity_origin origin on origin.commodity_origin_id = cp.commodity_origin_id
		left join static_data_value origin_sdv on origin_sdv.value_id = origin.origin
		left join commodity_form cf on cf.commodity_form_id = cp.commodity_form_id
		left join commodity_type_form form on form.commodity_type_form_id = cf.form
		left join commodity_form_attribute1 att1 on att1.commodity_form_attribute1_id = cp.commodity_form_attribute1
		left join commodity_attribute_form att1_form on att1_form.commodity_attribute_form_id = att1.attribute_form_id
		left join commodity_form_attribute2 att2 on att2.commodity_form_attribute2_id = cp.commodity_form_attribute2
		left join commodity_attribute_form att2_form on att2_form.commodity_attribute_form_id = att2.attribute_form_id
		left join commodity_form_attribute3 att3 on att3.commodity_form_attribute3_id = cp.commodity_form_attribute3
		left join commodity_attribute_form att3_form on att3_form.commodity_attribute_form_id = att3.attribute_form_id
		left join commodity_form_attribute4 att4 on att4.commodity_form_attribute4_id = cp.commodity_form_attribute4
		left join commodity_attribute_form att4_form on att4_form.commodity_attribute_form_id = att4.attribute_form_id
		left join commodity_form_attribute5 att5 on att5.commodity_form_attribute5_id = cp.commodity_form_attribute5
		left join commodity_attribute_form att5_form on att5_form.commodity_attribute_form_id = att5.attribute_form_id
		outer apply (
			select cc.name trader from counterparty_contacts cc inner join dbo.SplitCommaSeperatedValues(cp.trader_id) scsv on scsv.item = cc.counterparty_contact_id
		) trader
	end

GO