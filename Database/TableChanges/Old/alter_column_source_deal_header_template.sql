if not exists (select 'x' from information_schema.columns where table_name='source_deal_header_template' 
	and column_name='block_type'
)
begin
	ALTER TABLE source_deal_header_template ADD block_type	int
end 

if not exists (select 'x' from information_schema.columns where table_name='source_deal_header_template' 
	and column_name='block_define_id'
)
begin
	ALTER TABLE source_deal_header_template ADD block_define_id	int
end 

if not exists (select 'x' from information_schema.columns where table_name='source_deal_header_template' 
	and column_name='granularity_id'
)
begin
	ALTER TABLE source_deal_header_template ADD granularity_id	int
end 

if not exists (select 'x' from information_schema.columns where table_name='source_deal_header_template' 
	and column_name='Pricing'
)
begin
	ALTER TABLE source_deal_header_template ADD Pricing	int
end 

