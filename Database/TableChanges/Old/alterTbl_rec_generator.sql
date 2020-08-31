/*ADD columns to the table rec_generator*/

Alter table rec_generator Add 
						exp_annual_cap_factor varchar(50),
						add_capacity_added varchar(50),
						fac_contact_person varchar(50),
						fac_address varchar(50),
						fac_phone varchar(50),
						fac_fax varchar(50),
						fac_email varchar(50)
Go

/*Modify column to allow nulls as in settlement*/

ALTER TABLE rec_generator ALTER COLUMN id varchar(250)
ALTER TABLE rec_generator ALTER COLUMN [owner] varchar(250)
ALTER TABLE rec_generator ALTER COLUMN classification_value_id int
ALTER TABLE rec_generator ALTER COLUMN technology int
ALTER TABLE rec_generator ALTER COLUMN gen_state_value_id int


							


