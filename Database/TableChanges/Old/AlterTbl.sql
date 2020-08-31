ALTER TABLE source_deal_detail ADD location_id int

ALTER TABLE mv90_data_hour add RecID int identity(1,1), source_deal_header_id int

ALTER TABLE mv90_data_mins add RecID int identity(1,1), source_deal_header_id int
