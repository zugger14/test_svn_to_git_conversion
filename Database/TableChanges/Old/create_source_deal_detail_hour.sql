IF OBJECT_ID('source_deal_detail_hour') IS NOT NULL
DROP TABLE dbo.source_deal_detail_hour



CREATE TABLE dbo.source_deal_detail_hour (
	source_deal_detail_id INT,
	term_date DATETIME,
	hr INT,
	is_dst BIT,
	volume numeric(38,20),
	price FLOAT,
	formula_id INT,
	create_ts datetime,
	create_usr varchar(30),
	update_ts datetime,
	update_usr varchar(30)
)

CREATE UNIQUE CLUSTERED INDEX ucindx_source_deal_detail_hour ON dbo.source_deal_detail_hour(source_deal_detail_id, term_date, hr, is_dst)
