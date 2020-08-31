ALTER TABLE contract_group ADD 	energy_type char(1),
		area_engineer varchar(100),
		metering_contract varchar(50),
		miso_queue_number varchar(50),
		substation_name varchar(100),
		project_county varchar(50),
		voltage varchar(50),
		time_zone int ,
		contract_service_agreement_id varchar(50),
		contract_charge_type_id int ,
		billing_from_date int ,
		billing_to_date int ,		 
		contract_report_template int ,
		Subledger_code varchar(20),
		UD_Contract_id varchar(50),
		extension_provision_description varchar(100),
		term_name varchar(50),
		increment_name varchar(50),
		ferct_tarrif_reference varchar(50),
		point_of_delivery_control_area varchar(100),
		point_of_delivery_specific_location varchar(100),
		contract_affiliate varchar(1),
		point_of_receipt_control_area varchar(100),
		point_of_receipt_specific_location varchar(100),
		no_meterdata varchar(1),
		billing_start_month int,
		increment_period int 	
Go
ALTER TABLE dbo.rec_generator ADD CONSTRAINT
	FK_rec_generator_contract_group FOREIGN KEY
	(
	ppa_contract_id
	) REFERENCES dbo.contract_group
	(
	contract_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
Go

/*Alter table contract_group_detail*/
ALTER TABLE contract_group_detail ADD 
inventory_item CHAR(1),
class_name varchar(100),
increment_peaking_name varchar(150),
product_type_name varchar(150),
rate_description varchar(150),
units_for_rate varchar(50),
begin_date datetime,
end_date datetime,
default_gl_id_estimates int,
eqr_product_name int,
group_by int,
alias varchar(100),
hideInInvoice varchar(1),
int_begin_month int,
int_end_month int,
volume_granularity int

Go
