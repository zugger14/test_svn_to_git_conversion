IF OBJECT_ID('[dbo].[TRGUPD_compute_product_name_insert]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_compute_product_name_insert]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_compute_product_name_insert]
ON [dbo].[counterparty_products]
FOR INSERT
AS
    UPDATE counterparty_products
       SET product_computed_name = RTRIM(LTRIM(ISNULL(sdv.code,'') + ' ' + 
			CASE
				WHEN cp.is_organic = 'y' THEN 'Organic '
				ELSE ''
			END  + 
			ISNULL(ctf.commodity_form_name,'') + ' ' + 
			ISNULL(sc.commodity_name,'') + ' ' + 
			ISNULL(caf.commodity_form_name,'') + ' ' + 
			ISNULL(caf2.commodity_form_name,'') + ' ' + 
			ISNULL(caf3.commodity_form_name,'') + ' ' + 
			ISNULL(caf4.commodity_form_name,'') + ' ' + 
			ISNULL(caf5.commodity_form_name,'')
			)) 
    FROM counterparty_products cp
	LEFT JOIN source_commodity sc ON sc.source_commodity_id = cp.commodity_id
	LEFT JOIN commodity_origin co ON co.commodity_origin_id = cp.commodity_origin_id
	LEFT JOIN static_data_value sdv ON sdv.value_id = co.origin
	LEFT JOIN commodity_form cf ON cf.commodity_form_id = cp.commodity_form_id
	LEFT JOIN commodity_type_form ctf ON ctf.commodity_type_form_id = cf.form
	LEFT JOIN commodity_form_attribute1 cfa1 ON cfa1.commodity_form_attribute1_id = cp.commodity_form_attribute1
	LEFT JOIN commodity_attribute_form caf on caf.commodity_attribute_form_id = cfa1.attribute_form_id
	LEFT JOIN commodity_form_attribute2 cfa2 ON cfa2.commodity_form_attribute2_id = cp.commodity_form_attribute2
	LEFT JOIN commodity_attribute_form caf2 on caf2.commodity_attribute_form_id = cfa2.attribute_form_id
	LEFT JOIN commodity_form_attribute3 cfa3 ON cfa3.commodity_form_attribute3_id = cp.commodity_form_attribute3
	LEFT JOIN commodity_attribute_form caf3 on caf3.commodity_attribute_form_id = cfa3.attribute_form_id
	LEFT JOIN commodity_form_attribute4 cfa4 ON cfa4.commodity_form_attribute4_id = cp.commodity_form_attribute4
	LEFT JOIN commodity_attribute_form caf4 on caf4.commodity_attribute_form_id = cfa4.attribute_form_id
	LEFT JOIN commodity_form_attribute5 cfa5 ON cfa5.commodity_form_attribute5_id = cp.commodity_form_attribute5
	LEFT JOIN commodity_attribute_form caf5 on caf5.commodity_attribute_form_id = cfa5.attribute_form_id
      INNER JOIN INSERTED i ON cp.counterparty_product_id = i.counterparty_product_id
GO

IF OBJECT_ID('[dbo].[TRGUPD_compute_product_name_update]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_compute_product_name_update]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_compute_product_name_update]
ON [dbo].[counterparty_products]
FOR UPDATE
AS	
	IF @@ROWCOUNT = 0
        RETURN
	ELSE IF TRIGGER_NESTLEVEL() > 1
		RETURN

    UPDATE counterparty_products
       SET product_computed_name = RTRIM(LTRIM(ISNULL(sdv.code,'') + ' ' + 
			CASE
				WHEN cp.is_organic = 'y' THEN 'Organic '
				ELSE ''
			END  + 
			ISNULL(ctf.commodity_form_name,'') + ' ' + 
			ISNULL(sc.commodity_name,'') + ' ' + 
			ISNULL(caf.commodity_form_name,'') + ' ' + 
			ISNULL(caf2.commodity_form_name,'') + ' ' + 
			ISNULL(caf3.commodity_form_name,'') + ' ' + 
			ISNULL(caf4.commodity_form_name,'') + ' ' + 
			ISNULL(caf5.commodity_form_name,'')
			))
    FROM counterparty_products cp
	LEFT JOIN source_commodity sc ON sc.source_commodity_id = cp.commodity_id
	LEFT JOIN commodity_origin co ON co.commodity_origin_id = cp.commodity_origin_id
	LEFT JOIN static_data_value sdv ON sdv.value_id = co.origin
	LEFT JOIN commodity_form cf ON cf.commodity_form_id = cp.commodity_form_id
	LEFT JOIN commodity_type_form ctf ON ctf.commodity_type_form_id = cf.form
	LEFT JOIN commodity_form_attribute1 cfa1 ON cfa1.commodity_form_attribute1_id = cp.commodity_form_attribute1
	LEFT JOIN commodity_attribute_form caf on caf.commodity_attribute_form_id = cfa1.attribute_form_id
	LEFT JOIN commodity_form_attribute2 cfa2 ON cfa2.commodity_form_attribute2_id = cp.commodity_form_attribute2
	LEFT JOIN commodity_attribute_form caf2 on caf2.commodity_attribute_form_id = cfa2.attribute_form_id
	LEFT JOIN commodity_form_attribute3 cfa3 ON cfa3.commodity_form_attribute3_id = cp.commodity_form_attribute3
	LEFT JOIN commodity_attribute_form caf3 on caf3.commodity_attribute_form_id = cfa3.attribute_form_id
	LEFT JOIN commodity_form_attribute4 cfa4 ON cfa4.commodity_form_attribute4_id = cp.commodity_form_attribute4
	LEFT JOIN commodity_attribute_form caf4 on caf4.commodity_attribute_form_id = cfa4.attribute_form_id
	LEFT JOIN commodity_form_attribute5 cfa5 ON cfa5.commodity_form_attribute5_id = cp.commodity_form_attribute5
	LEFT JOIN commodity_attribute_form caf5 on caf5.commodity_attribute_form_id = cfa5.attribute_form_id
      INNER JOIN DELETED u ON cp.counterparty_product_id = u.counterparty_product_id
GO