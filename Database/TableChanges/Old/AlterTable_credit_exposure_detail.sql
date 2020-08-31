/******************************************
Alter Table credit_exposure_detail
*******************************************/

ALTER TABLE credit_exposure_detail
	ADD 
		risk_rating_id INT,
		debt_rating_id INT,
		industry_type1_id INT,
		industry_type2_id INT,
		sic_code_id INT,
		counterparty_type_id INT
