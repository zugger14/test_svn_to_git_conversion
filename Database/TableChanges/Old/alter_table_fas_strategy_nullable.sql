ALTER TABLE fas_strategy
ALTER COLUMN fx_hedge_flag char NULL

ALTER TABLE fas_strategy
ALTER COLUMN gl_grouping_value_id INT NULL

ALTER TABLE fas_strategy
ALTER COLUMN no_links char NULL

ALTER TABLE fas_strategy
ALTER COLUMN mes_cfv_value_id int NULL

ALTER TABLE fas_strategy
ALTER COLUMN mes_cfv_values_value_id int NULL

ALTER TABLE fas_strategy
ALTER COLUMN mismatch_tenor_value_id int NULL

ALTER TABLE fas_strategy
ALTER COLUMN strip_trans_value_id int NULL

ALTER TABLE fas_strategy
ALTER COLUMN asset_liab_calc_value_id int NULL

ALTER TABLE fas_strategy
ALTER COLUMN test_range_from float NULL

ALTER TABLE fas_strategy
ALTER COLUMN test_range_to float NULL

ALTER TABLE fas_strategy
ALTER COLUMN include_unlinked_hedges CHAR  NULL

ALTER TABLE fas_strategy
ALTER COLUMN include_unlinked_items CHAR NULL

ALTER TABLE fas_strategy
ALTER COLUMN subentity_name VARCHAR  (250)

ALTER TABLE fas_strategy
ALTER COLUMN subentity_desc VARCHAR  (1000)

ALTER TABLE fas_strategy
ALTER COLUMN relationship_to_entity VARCHAR (1000)

ALTER TABLE fas_strategy
ALTER COLUMN oci_rollout_approach_value_id int NULL






















