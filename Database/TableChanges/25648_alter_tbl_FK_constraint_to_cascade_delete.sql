ALTER TABLE deal_position_break_down
DROP CONSTRAINT FK_deal_position_break_down_source_deal_detail;

ALTER TABLE deal_position_break_down
ADD CONSTRAINT FK_deal_position_break_down_source_deal_detail
FOREIGN KEY (source_deal_detail_id)
REFERENCES source_deal_detail (source_deal_detail_id)
ON DELETE CASCADE;
 
GO