IF EXISTS (SELECT 1 FROM maintain_field_deal WHERE default_label = 'Settlement Volume' AND farrms_field_id = 'settlement_vol_type')
Begin
UPDATE maintain_field_deal
SET field_size = 180 
WHERE 
default_label = 'Settlement Volume'
AND field_type = 'd'
AND farrms_field_id = 'settlement_vol_type'
END
ELSE PRINT 'deal_field dos not exists'

IF EXISTS (SELECT 1 FROM maintain_field_deal WHERE default_label = 'Counterparty Trader' AND farrms_field_id = 'counterparty_trader')
Begin
UPDATE maintain_field_deal
SET field_size = 180 
WHERE 
default_label = 'Counterparty Trader'
AND field_type = 'd'
AND farrms_field_id = 'counterparty_trader'
END 
ELSE PRINT 'deal_field dos not exists'
