IF COL_LENGTH('source_deal_delta_value_whatif', 'leg') IS NULL
BEGIN
   ALTER TABLE source_deal_delta_value_whatif ADD leg INT NULL
END