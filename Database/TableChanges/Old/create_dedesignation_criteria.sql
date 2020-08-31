IF object_id('dedesignation_criteria') IS  null
--drop table dbo.dedesignation_criteria
--go
CREATE TABLE dbo.dedesignation_criteria (
dedesignation_criteria_id INT identity(1,1)
,fas_sub_id INT
,fas_stra_id INT
,fas_book_id INT
,run_date DATETIME
,curve_id INT
,term_start DATETIME
,term_end DATETIME
,term_match_criteria varchar(1)
,dedesignate_date DATETIME
,dedesignate_volume numeric(30,10)
,uom_id INT
,dedesignate_frequency varchar(1)
,sort_order varchar(1)
,dedesignate_type INT
,dedesignate_look_in varchar(1)
,volume_split varchar(1)
,create_user varchar(50)
,create_ts datetime
)

IF object_id('dedesignation_criteria_result') IS  null
--drop table dedesignation_criteria_result

--go

CREATE TABLE dbo.dedesignation_criteria_result 
(
row_id int identity(1,1)
,dedesignation_criteria_id INT
,link_id int 
,recommended_per float
,available_per FLOAT
,effective_date DATETIME
,relationship_desc varchar(1000)
,perfect_hedge varchar(1)
,term_start DATETIME
,link_volume  numeric(30,10)
,runing_total  numeric(30,10)
,create_user varchar(50)
,create_ts datetime
)
IF object_id('hedge_capacity_report') IS  null

--drop table hedge_capacity_report

--go
create table dbo.hedge_capacity_report(
	as_of_date datetime,
	fas_sub_id int,
	fas_str_id int,
	fas_book_id int,
	curve_id int,
	fas_sub varchar(250),
	fas_str varchar(250),
	fas_book varchar(250),
	IndexName varchar(250),
	term_start datetime,
	vol_frequency varchar(50),
	vol_uom varchar(100),
	net_asset_vol numeric(38,20),
	net_item_vol numeric(38,20),
	net_available_vol numeric(38,20),
	over_hedge varchar(3),
	create_ts datetime,create_user varchar(50)
)