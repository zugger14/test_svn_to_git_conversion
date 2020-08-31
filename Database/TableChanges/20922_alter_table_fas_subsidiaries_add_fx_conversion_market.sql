--source_deal_header
IF COL_LENGTH('fas_subsidiaries', 'fx_conversion_market') IS NULL
BEGIN
    ALTER TABLE fas_subsidiaries ADD fx_conversion_market INT
END
GO
