IF  OBJECT_ID('FK_deal_detail_hour_source_deal_detail') is NOT NULL
begin
	alter table deal_detail_hour drop constraint FK_deal_detail_hour_source_deal_detail
	alter table deal_detail_hour drop column source_deal_detail_id,block_type,block_define_id
	ALTER TABLE deal_detail_hour ADD Hr25 FLOAT
end
