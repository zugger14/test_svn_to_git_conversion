IF NOT EXISTS (SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'description4' AND default_label = 'Description 4')
BEGIN
  INSERT INTO maintain_field_deal
  SELECT 149, 'description4', 'Description 4', 't', 'varchar', NULL, 'h', NULL, NULL, 180, NULL, NULL, 'y', NULL, 'n', 'i', 'n'
END