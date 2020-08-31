IF COL_LENGTH('source_deal_header_template', 'bid_n_ask_price') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD bid_n_ask_price CHAR(1)
END
GO