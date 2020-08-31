alter table save_confirm_status add date datetime
alter table save_confirm_status add trader varchar(100)
alter table save_confirm_status add trade_date datetime	
alter table save_confirm_status add trade_type varchar(50)
alter table save_confirm_status add type varchar(30)
alter table save_confirm_status add commodity varchar(30)
alter table save_confirm_status add start_date datetime
alter table save_confirm_status add end_date datetime

alter table save_confirm_status add quantity varchar(100)
alter table save_confirm_status add total_quantity varchar(100)
alter table save_confirm_status add price_index varchar(30)
alter table save_confirm_status add pricing_date varchar(100)
alter table save_confirm_status add fixed_price varchar(100)
alter table save_confirm_status add service_type varchar(30)
alter table save_confirm_status add payment_frequency varchar(30)
alter table save_confirm_status add settle_rules varchar(30)

alter table save_confirm_status add holiday_calendar varchar(30)
alter table save_confirm_status add external_trade_id varchar(30)
alter table save_confirm_status add book varchar(30)
alter table save_confirm_status add comments varchar(100)

alter table save_confirm_status add counterparty_name varchar(30)

alter table save_confirm_status add counterparty_address varchar(100)
alter table save_confirm_status add counterparty_phone_no varchar(30)
alter table save_confirm_status add counterparty_mailing_address varchar(30)
alter table save_confirm_status add counterparty_fax_email varchar(30)
alter table save_confirm_status add trade_confirmation_status varchar(30)

alter table save_confirm_status add trade_confirmation_comment varchar(100)
alter table save_confirm_status add nearby_month varchar(30)
alter table save_confirm_status add roll_convention varchar(30)
alter table save_confirm_status add trader_phone varchar(30)
alter table save_confirm_status add trader_fax varchar(30)

alter table save_confirm_status add trader_email varchar(30)
alter table save_confirm_status add payment_dates varchar(100)
alter table save_confirm_status add system_trade_id varchar(30)
alter table save_confirm_status add input_by varchar(30)
alter table save_confirm_status add premium_settlement_date varchar(30)

alter table save_confirm_status add strike_price numeric(20,2)
alter table save_confirm_status add premium numeric(20,2)
alter table save_confirm_status add total_premium varchar(30)
alter table save_confirm_status add input_date datetime
alter table save_confirm_status add verified_by_name varchar(30)

alter table save_confirm_status add verified_date datetime
alter table save_confirm_status add user_login_id varchar(30)
alter table save_confirm_status add location_name varchar(30)
alter table save_confirm_status add broker_name varchar(30)
alter table save_confirm_status add is_confirm char(1)