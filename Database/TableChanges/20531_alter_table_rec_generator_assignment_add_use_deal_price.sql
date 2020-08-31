IF COL_LENGTH('rec_generator_assignment', 'use_deal_price') IS NULL
BEGIN
    ALTER TABLE rec_generator_assignment ADD use_deal_price char NULL
END
ELSE
BEGIN
    PRINT 'use_deal_price Already Exists.'
END

