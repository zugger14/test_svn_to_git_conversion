IF OBJECT_ID('source_deal_cva') IS NOT NULL
    DROP TABLE dbo.source_deal_cva
 
CREATE TABLE dbo.source_deal_cva
(
	rowid                   INT IDENTITY(1, 1),
	as_of_date              DATETIME,
	Source_Counterparty_ID  INT,
	source_deal_header_id   INT,
	term_start              DATETIME,
	rating_id               INT,
	curve_source_value_id   INT,
	exposure_to_us          FLOAT,
	exposure_to_them        FLOAT,
	cva                     FLOAT,
	dva                     FLOAT,
	create_ts               DATETIME,
	create_user             VARCHAR(30)
)

IF OBJECT_ID('source_deal_cva_simulation') IS NOT NULL
    DROP TABLE dbo.source_deal_cva_simulation

CREATE TABLE dbo.source_deal_cva_simulation
(
	rowid                   INT IDENTITY(1, 1),
	run_date                DATETIME,
	as_of_date              DATETIME,
	Source_Counterparty_ID  INT,
	source_deal_header_id   INT,
	term_start              DATETIME,
	rating_id               INT,
	curve_source_value_id   INT,
	exposure_to_us          FLOAT,
	exposure_to_them        FLOAT,
	cva                     FLOAT,
	dva                     FLOAT,
	create_ts               DATETIME,
	create_user             VARCHAR(30)
)