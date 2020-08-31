IF OBJECT_ID('[UC_template_id_state_value_id_tier_id]') IS NULL
BEGIN
	ALTER TABLE [dbo].[eligibility_mapping_template_detail] 
	WITH NOCHECK 
	ADD CONSTRAINT [UC_template_id_state_value_id_tier_id] 
	UNIQUE(template_id, state_value_id, tier_id)
END
