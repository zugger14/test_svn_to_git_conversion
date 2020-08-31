IF COL_LENGTH('source_deal_delta_value', 'leg') IS NULL
BEGIN
   ALTER TABLE source_deal_delta_value ADD leg INT NULL
END