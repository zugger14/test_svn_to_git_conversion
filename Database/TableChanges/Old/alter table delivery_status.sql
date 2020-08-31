IF NOT EXISTS(SELECT 'X' FROM information_schema.columns where table_name = 'delivery_status' and column_name='deal_transport_detail_id')
ALTER TABLE delivery_status ADD deal_transport_detail_id INT

GO
update a
set a.deal_transport_detail_id=b.deal_transport_deatail_id
from 
	delivery_status a join(select deal_transport_id,min(deal_transport_deatail_id) deal_transport_deatail_id from deal_transport_detail group by deal_transport_id) b
	on a.deal_transport_id=b.deal_transport_id


select * from static_data_value where type_id=1650
update static_data_value set code='Actual',description='Actual' where value_id=1650