IF OBJECT_ID('dbo.calc_line_item_formula_value') IS NOT NULL
    DROP TABLE dbo.calc_line_item_formula_value
GO

CREATE TABLE calc_line_item_formula_value
(
	counterparty_id          INT,
	contract_id              INT,
	prod_date                DATETIME,
	as_of_date               DATETIME,
	invoice_line_item_id     INT,
	formula_id               INT,
	source_id                INT,
	nested_id                INT,
	contract_value           FLOAT,
	process_id               VARCHAR(255)
)
