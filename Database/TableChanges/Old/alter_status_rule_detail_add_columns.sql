
IF COL_LENGTH('status_rule_detail','open_deal_confirmation') IS NULL 
ALTER TABLE status_rule_detail ADD open_deal_confirmation CHAR(1)


IF COL_LENGTH('status_rule_detail','open_deal_ticket') IS NULL 
ALTER TABLE status_rule_detail ADD open_deal_ticket CHAR(1)

IF COL_LENGTH('status_rule_detail','send_trader_notification') IS NULL 
ALTER TABLE status_rule_detail ADD send_trader_notification CHAR(1)