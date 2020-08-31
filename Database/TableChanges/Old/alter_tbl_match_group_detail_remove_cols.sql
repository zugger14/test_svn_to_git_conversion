IF COL_LENGTH('match_group_detail','last_edited_by') IS NOT NULL
BEGIN
	ALTER TABLE match_group_detail DROP COLUMN last_edited_by		
END 

IF COL_LENGTH('match_group_detail','comments') IS NOT NULL
BEGIN
	ALTER TABLE match_group_detail DROP COLUMN comments		
END 


IF COL_LENGTH('match_group_detail','last_edited_on') IS NOT NULL
BEGIN
	ALTER TABLE match_group_detail DROP COLUMN last_edited_on		
END

IF COL_LENGTH('match_group_detail','scheduler') IS NOT NULL
BEGIN
	ALTER TABLE match_group_detail DROP COLUMN scheduler		
END

IF COL_LENGTH('match_group_detail','location') IS NOT NULL
BEGIN
	ALTER TABLE match_group_detail DROP COLUMN location		
END

IF COL_LENGTH('match_group_detail','status') IS NOT NULL
BEGIN
	ALTER TABLE match_group_detail DROP COLUMN status		
END

IF COL_LENGTH('match_group_detail','scheduled_from') IS NOT NULL
BEGIN
	ALTER TABLE match_group_detail DROP COLUMN scheduled_from		
END

IF COL_LENGTH('match_group_detail','scheduled_to') IS NOT NULL
BEGIN
	ALTER TABLE match_group_detail DROP COLUMN scheduled_to		
END

IF COL_LENGTH('match_group_detail','match_number') IS NOT NULL
BEGIN
	ALTER TABLE match_group_detail DROP COLUMN match_number		
END

IF COL_LENGTH('match_group_detail','pipeline_cycle') IS NOT NULL
BEGIN
	ALTER TABLE match_group_detail DROP COLUMN pipeline_cycle		
END

IF COL_LENGTH('match_group_detail','consignee') IS NOT NULL
BEGIN
	ALTER TABLE match_group_detail DROP COLUMN consignee		
END

IF COL_LENGTH('match_group_detail','carrier') IS NOT NULL
BEGIN
	ALTER TABLE match_group_detail DROP COLUMN carrier		
END

IF COL_LENGTH('match_group_detail','po_number') IS NOT NULL
BEGIN
	ALTER TABLE match_group_detail DROP COLUMN po_number		
END

IF COL_LENGTH('match_group_detail','container') IS NOT NULL
BEGIN
	ALTER TABLE match_group_detail DROP COLUMN container		
END

IF COL_LENGTH('match_group_detail','commodity_origin_id') IS NOT NULL
BEGIN
	ALTER TABLE match_group_detail DROP COLUMN commodity_origin_id		
END

IF COL_LENGTH('match_group_detail','commodity_form_id') IS NOT NULL
BEGIN
	ALTER TABLE match_group_detail DROP COLUMN commodity_form_id		
END

IF COL_LENGTH('match_group_detail','commodity_form_attribute1') IS NOT NULL
BEGIN
	ALTER TABLE match_group_detail DROP COLUMN commodity_form_attribute1		
END

IF COL_LENGTH('match_group_detail','commodity_form_attribute2') IS NOT NULL
BEGIN
	ALTER TABLE match_group_detail DROP COLUMN commodity_form_attribute2		
END

IF COL_LENGTH('match_group_detail','commodity_form_attribute3') IS NOT NULL
BEGIN
	ALTER TABLE match_group_detail DROP COLUMN commodity_form_attribute3		
END

IF COL_LENGTH('match_group_detail','commodity_form_attribute4') IS NOT NULL
BEGIN
	ALTER TABLE match_group_detail DROP COLUMN commodity_form_attribute4		
END

IF COL_LENGTH('match_group_detail','commodity_form_attribute5') IS NOT NULL
BEGIN
	ALTER TABLE match_group_detail DROP COLUMN commodity_form_attribute5		
END

IF COL_LENGTH('match_group_detail','organic') IS NOT NULL
BEGIN
	ALTER TABLE match_group_detail DROP COLUMN organic		
END

IF COL_LENGTH('match_group_detail', 'match_group_header_id') IS NULL
BEGIN
    ALTER TABLE match_group_detail ADD match_group_header_id INT
END
GO
IF COL_LENGTH('match_group_detail', 'match_group_shipment_id') IS NULL
BEGIN
    ALTER TABLE match_group_detail ADD match_group_shipment_id INT
END
GO



IF COL_LENGTH('match_group_detail', 'match_group_id') IS NOT NULL
BEGIN
    ALTER TABLE match_group_detail DROP COLUMN match_group_id 
END
GO

IF COL_LENGTH('match_group_detail', 'bookout_match') IS NOT NULL
BEGIN
    ALTER TABLE match_group_detail DROP COLUMN bookout_match 
END
GO

IF COL_LENGTH('match_group_detail', 'split_id') IS NOT NULL
BEGIN
    ALTER TABLE match_group_detail DROP COLUMN split_id 
END
GO


IF COL_LENGTH('match_group_detail', 'line_up') IS NOT NULL
BEGIN
    ALTER TABLE match_group_detail DROP COLUMN line_up 
END
GO



IF COL_LENGTH('match_group_detail', 'estimated_movement_date') IS NOT NULL
BEGIN
    ALTER TABLE match_group_detail DROP COLUMN estimated_movement_date 
END
GO



IF COL_LENGTH('match_group_detail', 'shipment_name') IS NOT NULL
BEGIN
    ALTER TABLE match_group_detail DROP COLUMN shipment_name 
END
GO
 