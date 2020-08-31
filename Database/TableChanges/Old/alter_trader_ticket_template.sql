
if exists(select * from sys.columns where [object_id] = object_id('trader_ticket_template'))
update trader_ticket_template set commodity_id=511 where  template_id=3
