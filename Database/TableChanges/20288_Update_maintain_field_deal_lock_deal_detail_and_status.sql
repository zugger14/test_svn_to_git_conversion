UPDATE maintain_field_deal
SET    system_required     = NULL
WHERE farrms_field_id = 'lock_deal_detail' AND system_required IS NOT NULL

UPDATE maintain_field_deal
SET    system_required     = NULL
WHERE farrms_field_id = 'status' AND system_required IS NOT NULL

UPDATE maintain_field_deal
SET    system_required     = NULL
WHERE farrms_field_id = 'curve_id' AND system_required IS NOT NULL

UPDATE maintain_field_deal
SET    system_required     = NULL
WHERE farrms_field_id = 'fixed_price_currency_id' AND system_required IS NOT NULL