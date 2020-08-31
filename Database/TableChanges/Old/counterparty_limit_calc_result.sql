ALTER TABLE calc_formula_value ADD 	counterparty_limit_id INT



if object_id('dbo.counterparty_limit_calc_result') is not null
drop table dbo.counterparty_limit_calc_result
go

CREATE TABLE dbo.counterparty_limit_calc_result(
rowid INT IDENTITY(1,1),
as_of_date DATETIME,
counterparty_limit_id int,
counterparty_id INT,
internal_rating INT,
limit_type INT ,
buck_id INT,
purchase_sales char(1),
credit_available float
)