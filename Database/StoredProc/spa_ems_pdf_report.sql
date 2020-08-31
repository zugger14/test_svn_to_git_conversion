IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ems_pdf_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ems_pdf_report]
GO 

create PROCEDURE [dbo].[spa_ems_pdf_report]
	@as_of_date varchar(20),            
	@sub_entity_id varchar(100)=null,
	@strategy_entity_id varchar(100),
	@reporting_year INT,
	@columncode varchar(20), -- @report_section use Schedule.Section.Part.Item format. For example., "I.2.A" for aggregated report
	@process_id varchar(50),
	@report_type varchar(1) = 'r', -- 'b' only show base period, 'r' only show reporting period, 'a' show both base and reporting
	@prod_month_from DATETIME = null,  --null
	@prod_month_to DATETIME  = null,  --null,
	@base_year_from int=null,
	@base_year_to int=null,
	@table_name varchar(100)=null,		
	@book_entity_id varchar(100)=null,	
	@forecast char(1)='r', 
	-- drill down
	@drill_down_level int=null,
	@report_year_level int=NULL,--1 year1, 2 year2, 3 year3,4 year4 5 base year 6 reporting year
	@source varchar(100)=NULL,
	@group1 varchar(100)=NULL,
	@group2 varchar(100)=NULL,
	@group3 varchar(100)=NULL,
	@gas varchar(100)=NULL,
	@generator varchar(100)=NULL,
	@year int=null,
	@term_start datetime=NULL,
	@emissions_reductions char(1)=null,
	@deminimis char(1)='n',
	@use_process_id varchar(50)='RERUN'		

AS 
SET NOCOUNT ON 
---Addendum A1
if @columncode='A.1.A.1'
	select col1 c1, col2 c2, col3 c3,null c4,null c5,null c6,null c7,null c8, null c9 from ems_tmp_detail where columncode like 'A.1.A.1%' 
else if @columncode='A.1.B.1'
	select col1 c1, col2 c2, null c3,null c4,null c5 from ems_tmp_detail where columncode like 'A.1.B.1%'
else if @columncode='A.1.B.2'
	select col1 c1, col2 c2, null c3,null c4,null c5 from ems_tmp_detail where columncode like 'A.1.B.2%'
else if @columncode='A.1.B.3'
	select col1 c1, col2 c2, null c3,null c4,null c5 from ems_tmp_detail where columncode like 'A.1.B.3%'
else if @columncode='A.1.C.1'
	select col1 c1, col2 c2, col3 c3,'metric tons' c4,null c5 from ems_tmp_detail where columncode like 'A.1.C.1%'

--Addendum A2
else if @columncode='A.2.A.1'
	select col1 c1, col2 c2, col3 c3,null c4,null c5,null c6,null c7,null c8, null c9 from ems_tmp_detail where columncode like 'A.2.A.1%'
else if @columncode='A.2.B.1'
	select col1 c1, col2 c2, null c3,null c4,null c5 from ems_tmp_detail where columncode like 'A.2.B.1%'
else if @columncode='A.2.C.1'
	select col1 c1, col2 c2, col3 c3,'metric tons' c4,null c5 from ems_tmp_detail where columncode like 'A.2.C.1%'

--Addendum A3
else if @columncode='A.3.A.1'
	select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.3.A.1%'
else if @columncode='A.3.B.1'
	select col1 c1, col2 c2, col3 c3,'metric tons' c4,null c5 from ems_tmp_detail where columncode like 'A.3.B.1%'

--Addendum A4
else if @columncode='A.4.B.1'
	select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.4.B.1%'
else if @columncode='A.4.C.1'
	select col1 c1, col2 c2,'metric tons' c3,null c4 from ems_tmp_detail where columncode like 'A.4.C.1%'

--Addendum A5
else if @columncode='A.5.A.2'
	select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.5.A.2%'
else if @columncode='A.5.B.1'
	select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.5.B.1%'
else if @columncode='A.5.C.1'
	select col1 c1, col2 c2, 'metric tons' c3,null c4 from ems_tmp_detail where columncode like 'A.5.C.1%'

--Addendum A6
else if @columncode='A.6.A.1' --no data in database
	select null c1, null c2, null c3,null c4 from ems_tmp_detail where columncode like 'A.6.A.1%'
else if @columncode='A.6.B.1' --no data in database
	select null c1, null c2, null c3,null c4 from ems_tmp_detail where columncode like 'A.6.B.1%'
else if @columncode='A.6.B.2'
	select col1 c1, null c2, null c3,null c4,null c5,null c6,null c7 from ems_tmp_detail where columncode like 'A.6.B.2%'
else if @columncode='A.6.B.3'
	select col1 c1, null c2, null c3,null c4,null c5,null c6,null c7 from ems_tmp_detail where columncode like 'A.6.B.3%'
else if @columncode='A.6.B.4'
	select col1 c1, null c2, null c3,null c4,null c5,null c6,null c7 from ems_tmp_detail where columncode like 'A.6.B.4%'
else if @columncode='A.6.B.5'
	select col1 c1, null c2, null c3,null c4,null c5,null c6,null c7 from ems_tmp_detail where columncode like 'A.6.B.5%'
else if @columncode='A.6.C.1'
	select col1 c1, col2 c2, col3 c3,null c4,null c5,null c6,null c7 from ems_tmp_detail where columncode like 'A.6.C.1%'
else if @columncode='A.6.C.2'
	select col1 c1, COL2 c2, null c3,null c4,null c5,null c6,null c7, null c8 from ems_tmp_detail where columncode like 'A.6.C.2%'
else if @columncode='A.6.C.3'
	select col1 c1, COL2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.6.C.3%'
else if @columncode='A.6.C.4'
	select col1 c1, COL2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.6.C.4%'
else if @columncode='A.6.C.5'
	select col1 c1, COL2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.6.C.5%'
else if @columncode='A.6.C.6'
	select col1 c1, COL2 c2, col3 c3,null c4, null c5, null c6, null c7 from ems_tmp_detail where columncode like 'A.6.C.6%'
else if @columncode='A.6.D.1'
	select col1 c1, COL2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.6.D.1%'


--Addendum A7
else if @columncode='A.7.A.1'
	select null c1, null c2, null c3,null c4 from ems_tmp_detail where columncode like 'A.7.A.1%'--no data--
else if @columncode='A.7.B.1'
	select null c1, null c2, null c3,null c4,null c5 from ems_tmp_detail where columncode like 'A.7.B.1%'--no data--
else if @columncode='A.7.B.2'
	select col1 c1, null c2, null c3,null c4,null c5,null c6,null c7,null c8 from ems_tmp_detail where columncode like 'A.7.B.2%'
else if @columncode='A.7.B.3'
	select col1 c1, null c2, null c3,null c4,null c5,null c6,null c7,null c8 from ems_tmp_detail where columncode like 'A.7.B.3%'
else if @columncode='A.7.B.4'
	select col1 c1, null c2, null c3,null c4,null c5,null c6,null c7,null c8 from ems_tmp_detail where columncode like 'A.7.B.4%'
else if @columncode='A.7.B.5'
	select col1 c1, null c2, null c3,null c4,null c5,null c6,null c7,null c8 from ems_tmp_detail where columncode like 'A.7.B.5%'
else if @columncode='A.7.C.1'
	select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.7.C.1%'
else if @columncode='A.7.C.2'
	select col1 c1, col2 c2, null c3,null c4,null c5,null c6,null c7,null c8 from ems_tmp_detail where columncode like 'A.7.C.2%'
else if @columncode='A.7.C.3'
	select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.7.C.3%'
else if @columncode='A.7.C.4'
	select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.7.C.4%'
else if @columncode='A.7.C.5'
	select col1 c1, col2 c2, col3 c3,null c4,null c5,null c6 from ems_tmp_detail where columncode like 'A.7.C.5%'
else if @columncode='A.7.D.1'
	select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.7.D.1%'

---Addendum 8
else if @columncode='A.8.A.1'
	select null c1, null c2, null c3,null c4 from ems_tmp_detail where columncode like 'A.8.A.1%'--no data--
else if @columncode='A.8.B.1'
	select col1 c1, col2 c2, null c3,null c4,null c5,null c6, null c7 from ems_tmp_detail where columncode like 'A.8.B.1%'
else if @columncode='A.8.B.2'
	select col1 c1, col2 c2, null c3,'yes/no' c4,null c5,null c6 ,null c7, null c8 from ems_tmp_detail where columncode like 'A.8.B.2%'
else if @columncode='A.8.B.3'
		select col1 c1, col2 c2, null c3,'yes/no' c4,null c5,null c6 ,null c7, null c8 from ems_tmp_detail where columncode like 'A.8.B.3%'
else if @columncode='A.8.C.1'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.8.C.1%'
else if @columncode='A.8.D.1'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.8.D.1%'

--Addendum A9

else if @columncode='A.9.B.1'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.9.B.1%'
else if @columncode='A.9.C.1'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.9.C.1%'
else if @columncode='A.9.D.1'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.9.D.1%'

--Addendum A10
else if @columncode='A.10.A.1'
		select null c1, null c2, null c3,null c4 from ems_tmp_detail where columncode like 'A.10.A.1%'
else if @columncode='A.10.B.1'
		select col1 c1, null c2, null c3,null c4, null c5, null c6, null c7 from ems_tmp_detail where columncode like 'A.10.B.1%'
else if @columncode='A.10.B.2'
		select col1 c1, null c2, null c3,null c4, null c5, null c6, null c7 from ems_tmp_detail where columncode like 'A.10.B.2%'
else if @columncode='A.10.B.3'
		select col1 c1, null c2, null c3,null c4, null c5, null c6, null c7 from ems_tmp_detail where columncode like 'A.10.B.3%'
else if @columncode='A.10.B.4'
		select col1 c1, null c2, null c3,null c4, null c5, null c6, null c7 from ems_tmp_detail where columncode like 'A.10.B.4%'
else if @columncode='A.10.B.5'
		select null c1, null c2, null c3,null c4, null c5, null c6, null c7 from ems_tmp_detail where columncode like 'A.10.B.5%'
else if @columncode='A.10.C.1'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.10.C.1%'
else if @columncode='A.10.C.2'
		select col1 c1, col2 c2, null c3,null c4, null c5, null c6, null c7, null c8 from ems_tmp_detail where columncode like 'A.10.C.2%'
else if @columncode='A.10.C.3'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.10.C.3%'
else if @columncode='A.10.C.4'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.10.C.4%'
else if @columncode='A.10.C.5'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.10.C.5%'
else if @columncode='A.10.C.6'
		select col1 c1, col2 c2, col3 c3,null c4, null c5, null c6 from ems_tmp_detail where columncode like 'A.10.C.6%'
else if @columncode='A.10.D.1'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.10.D.1%'

--Addendum A11
else if @columncode='A.11.A.1'
		select null c1, null c2, null c3,null c4 from ems_tmp_detail where columncode like 'A.11.A.1%'
else if @columncode='A.11.B.1'
		select null c1, null c2, null c3 from ems_tmp_detail where columncode like 'A.11.B.1%'
else if @columncode='A.11.B.2'
		select col1 c1, null c2, null c3,null c4, null c5, null c6, null c7 from ems_tmp_detail where columncode like 'A.11.B.2%'
else if @columncode='A.11.B.3'
		select col1 c1, null c2, null c3,null c4, null c5, null c6, null c7 from ems_tmp_detail where columncode like 'A.11.B.3%'
else if @columncode='A.11.B.4'
		select col1 c1, null c2, null c3,null c4, null c5, null c6, null c7 from ems_tmp_detail where columncode like 'A.11.B.4%'
else if @columncode='A.11.B.5'
		select col1 c1, null c2, null c3,null c4, null c5, null c6, null c7 from ems_tmp_detail where columncode like 'A.11.B.5%'
else if @columncode='A.11.B.6'
		select null c1, null c2, null c3,null c4, null c5, null c6, null c7 from ems_tmp_detail where columncode like 'A.11.B.6%'
else if @columncode='A.11.C.1'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.11.C.1%'
else if @columncode='A.11.C.2'
		select col1 c1, col2 c2, null c3,null c4, null c5, null c6, null c7, null c8 from ems_tmp_detail where columncode like 'A.11.C.2%'
else if @columncode='A.11.C.3'
		select col1 c1, col2 c2, col3 c3, null c4 from ems_tmp_detail where columncode like 'A.11.C.3%'
else if @columncode='A.11.C.4'
		select col1 c1, col2 c2, col3 c3, null c4 from ems_tmp_detail where columncode like 'A.11.C.4%'
else if @columncode='A.11.C.5'
		select col1 c1, col2 c2, col3 c3, null c4 from ems_tmp_detail where columncode like 'A.11.C.5%'
else if @columncode='A.11.C.6'
		select col1 c1, col2 c2, col3 c3, null c4, null c5, null c6 from ems_tmp_detail where columncode like 'A.11.C.6%'
else if @columncode='A.11.D.1'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.11.D.1%'

--Addendum A12
else if @columncode='A.12.A.1'
		select null c1, null c2, null c3,null c4 from ems_tmp_detail where columncode like 'A.12.A.1%'
else if @columncode='A.12.B.1'
		select col1 c1, col2 c2, null c3,null c4, null c5, null c6, null c7, null c8 from ems_tmp_detail where columncode like 'A.12.B.1%'
else if @columncode='A.12.B.2'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.12.B.2%'
else if @columncode='A.12.C.1'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.12.C.1%'
else if @columncode='A.12.D.1'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.12.D.1%'

--Addendum A13
else if @columncode='A.13.B.1'
		select col1 c1, null c2, null c3,null c4, null c5 from ems_tmp_detail where columncode like 'A.13.B.1%'
else if @columncode='A.13.C.1'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.13.C.1%'

--Addendum A14
else if @columncode='A.14.A.1'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.14.A.1%'
else if @columncode='A.14.A.2'
		select col1 c1, col2 c2, null c3,null c4 from ems_tmp_detail where columncode like 'A.14.A.2%'
else if @columncode='A.14.A.3'
		select col1 c1, col2 c2, null c3 from ems_tmp_detail where columncode like 'A.14.A.3%'
else if @columncode='A.14.A.4'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.14.A.4%'
else if @columncode='A.14.A.1'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.14.A.1%'
else if @columncode='A.14.B.1.a'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.14.B.1.a%'
else if @columncode='A.14.B.1.b'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.14.B.1.b%'
else if @columncode='A.14.B.2.a'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.14.B.2.a%'
else if @columncode='A.14.B.2.b'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.14.B.2.b%'
else if @columncode='A.14.B.2.c'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.14.B.2.c%'
else if @columncode='A.14.B.2.d'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.14.B.2.d%'
else if @columncode='A.14.B.3'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.14.B.3%'
else if @columncode='A.14.C.1'
		select col1 c1, col2 c2, col3 c3,null c4 from ems_tmp_detail where columncode like 'A.14.C.1%'

--Addendum A15
else if @columncode='A.15.B.1'
		select col1 c1, null c2, null c3,null c4 from ems_tmp_detail where columncode like 'A.15.B.1%'
else if @columncode='A.15.B.3'
		select col1 c1, col2 c2, col3 c3,null c4, null c5, null c6 from ems_tmp_detail where columncode like 'A.15.B.3%'
else if @columncode='A.15.C.1'
		select col1 c1, null c2, null c3,null c4 from ems_tmp_detail where columncode like 'A.15.C.1%'

--Addendum A16
else if @columncode='A.16.A.1'
		select null c1, null c2, null c3,null c4 from ems_tmp_detail where columncode like 'A.16.A.1%'
else if @columncode='A.16.B.1'
		select null c1, null c2, null c3,null c4 from ems_tmp_detail where columncode like 'A.16.B.1%'
else if @columncode='A.16.C.1'
		select null c1, null c2, col2 c3,null c4 from ems_tmp_detail where columncode like 'A.16.C.1%'

----------------------------------------------- Schedule I ---------------------------------------------------------


--section 1 not in database

-- Section 2
if @columncode='I.2.A.1'
		select col1 c1, col2 c2, col3 c3,null c4, null c5, null c6, null c7, null c8, null c9, null c10, null c11 from ems_tmp_detail where columncode like 'I.2.A.1%'
else if @columncode='I.2.B.1.a'
		select col1 c1, col2 c2, null c3,null c4, null c5, null c6, null c7, null c8, null c9, null c10, null c11 from ems_tmp_detail where columncode like 'I.2.B.1.a%'
else if @columncode='I.2.B.1.b'
		select col1 c1, col2 c2, null c3,null c4, null c5, null c6, null c7, null c8, null c9, null c10, null c11 from ems_tmp_detail where columncode like 'I.2.B.1.b%'
else if @columncode='I.2.B.1.c'
		select col1 c1, col2 c2, null c3,null c4, null c5, null c6, null c7, null c8, null c9, null c10, null c11 from ems_tmp_detail where columncode like 'I.2.B.1.c%'
else if @columncode='I.2.B.1.d'
		select col1 c1, col2 c2, null c3,null c4, null c5, null c6, null c7, null c8, null c9, null c10, null c11 from ems_tmp_detail where columncode like 'I.2.B.1.d%'
else if @columncode='I.2.B.1.e'
		select col1 c1, col2 c2, null c3,null c4, null c5, null c6, null c7, null c8, null c9, null c10, null c11 from ems_tmp_detail where columncode like 'I.2.B.1.e%'
else if @columncode='I.2.B.1.f'
		select col1 c1, col2 c2, 'metric tons' c3,null c4, null c5, null c6, null c7, null c8, null c9 from ems_tmp_detail where columncode like 'I.2.B.1.f%'
else if @columncode='I.2.B.2.a'
		select col1 c1, null c2, null c3,null c4, null c5, null c6, null c7, null c8, null c9 from ems_tmp_detail where columncode like 'I.2.B.2.a%'
else if @columncode='I.2.B.2.b'
		select col1 c1, col2 c2, null c3,null c4, null c5, null c6, null c7, null c8, null c9, null c10, null c11 from ems_tmp_detail where columncode like 'I.2.B.2.b%'
else if @columncode='I.2.B.2.c'
		select col1 c1, col2 c2, null c3,null c4, null c5, null c6, null c7, null c8, null c9, null c10, null c11 from ems_tmp_detail where columncode like 'I.2.B.2.c%'
else if @columncode='I.2.B.3'
		select col1 c1, col2 c2, null c3,null c4, null c5, null c6, null c7, null c8, null c9, null c10, null c11 from ems_tmp_detail where columncode like 'I.2.B.3%'
else if @columncode='I.2.B.4.a'
		select col1 c1, col2 c2, null c3,null c4, null c5, null c6, null c7, null c8, null c9 from ems_tmp_detail where columncode like 'I.2.B.4.a%'
else if @columncode='I.2.B.4.b.i'
		select col1 c1, col2 c2, null c3,null c4, null c5, null c6, null c7, null c8 from ems_tmp_detail where columncode like 'I.2.B.4.b.i.%'
else if @columncode='I.2.B.4.b.ii'
		select col1 c1, col2 c2, null c3,null c4, null c5, null c6, null c7 from ems_tmp_detail where columncode like 'I.2.B.4.b.ii.%'
else if @columncode='I.2.B.4.c'
		select col1 c1, null c2, null c3,null c4, null c5, null c6, null c7, null c8 from ems_tmp_detail where columncode like 'I.2.B.4.c%'
else if @columncode='I.2.B.4.d'
		select col1 c1, null c2, null c3,null c4, null c5, null c6, null c7, null c8, null c9, null c10, null c11 from ems_tmp_detail where columncode like 'I.2.B.4.d%'
else if @columncode='I.2.B.4.e'
		select col1 c1, null c2, null c3,null c4 from ems_tmp_detail where columncode like 'I.2.B.4.e%'
else if @columncode='I.2.B.4.f'
		select col1 c1, null c2, null c3 from ems_tmp_detail where columncode like 'I.2.B.4.f%'
else if @columncode='I.2.B.4.g'
		select col1 c1, col2 c2, null c3,null c4, null c5, null c6, null c7, null c8, null c9 from ems_tmp_detail where columncode like 'I.2.B.4.g%'
else if @columncode='I.2.B.4.h'
		select col1 c1, col2 c2, null c3,null c4, null c5 from ems_tmp_detail where columncode like 'I.2.B.4.h%'
else if @columncode='I.2.B.5'
		select null c1, null c2, null c3,null c4, null c5, null c6, null c7 from ems_tmp_detail where columncode like 'I.2.B.5%'
else if @columncode='I.2.C'
		select col1 c1, col2 c2, col3 c3,null c4, null c5, null c6, null c7, null c8, null c9 from ems_tmp_detail where columncode like 'I.2.C%'
else if @columncode='I.2.B.D.1'
		select col1 c1, col2 c2, null c3,null c4, null c5, null c6, null c7 from ems_tmp_detail where columncode like 'I.2.D.1%'
else if @columncode='I.2.B.D.2'
		select col1 c1, col2 c2, null c3,null c4, null c5, null c6, null c7 from ems_tmp_detail where columncode like 'I.2.D.2%'

--Section 3
else if @columncode='I.3.A.1'
		select null c1, null c2, null c3,null c4, null c5, null c6, null c7 from ems_tmp_detail where columncode like 'I.3.A.1%'
else if @columncode='I.3.B.1'
		select null c1, null c2, null c3,null c4, null c5, null c6, null c7 from ems_tmp_detail where columncode like 'I.3.B.1%'


----------------- Schedule II --------------

------------------------------ Schedule III -----------------------

else if @columncode='III.1.A.1'
	select col1 c1, col2 c2, null c3,null c4, null c5 from ems_tmp_detail where columncode like 'III.1.A.1%'
else if @columncode='III.1.B.1'
	select col1 c1, col2 c2, null c3,null c4, null c5 from ems_tmp_detail where columncode like 'III.1.B.1%'
else if @columncode='III.2.A.1'
	select col1 c1, col2 c2, null c3,null c4, null c5 from ems_tmp_detail where columncode like 'III.2.A.1%'
else if @columncode='III.2.B.1'
	select col1 c1, col2 c2, null c3,null c4, null c5 from ems_tmp_detail where columncode like 'III.2.B.1%'

------------------------------- Schedule IV -------------------------------------

else if @columncode='IV.1.3.B'
	select null c1, col2 c2, null c3,null c4, null c5 from ems_tmp_detail where columncode like 'IV.1.3.B%'


----------------------------- Addendum B ---------------------------

else if @columncode='A.B.A.1'
	select col1 c1, col2 c2, col3 c3, null c4, null c5, null c6, null c7, null c8, null c9, null c10  from ems_tmp_detail where columncode like 'A.B.A.1%'
else if @columncode='A.B.B.1.a'
	select col1 c1, col2 c2, null c3, null c4, null c5, null c6, null c7, null c8, null c9, null c10  from ems_tmp_detail where columncode like 'A.B.B.1.a%'
else if @columncode='A.B.B.1.b'
	select col1 c1, col2 c2, null c3, null c4, null c5, null c6, null c7, null c8, null c9, null c10  from ems_tmp_detail where columncode like 'A.B.B.1.b%'
else if @columncode='A.B.B.1.c'
	select col1 c1, col2 c2, null c3, null c4, null c5, null c6, null c7, null c8, null c9, null c10  from ems_tmp_detail where columncode like 'A.B.B.1.c%'
else if @columncode='A.B.B.1.d'
	select col1 c1, col2 c2, null c3, null c4, null c5, null c6, null c7, null c8, null c9, null c10  from ems_tmp_detail where columncode like 'A.B.B.1.d%'
else if @columncode='A.B.B.1.e'
	select col1 c1, col2 c2, null c3, null c4, null c5, null c6, null c7, null c8, null c9, null c10  from ems_tmp_detail where columncode like 'A.B.B.1.e%'
else if @columncode='A.B.B.1.f'
	select col1 c1, col2 c2, 'metric tons' c3, null c4, null c5, null c6, null c7, null c8, null c9 from ems_tmp_detail where columncode like 'A.B.B.1.f%'
else if @columncode='A.B.B.2.a'
	select col1 c1, null c2, null c3, null c4, null c5, null c6, null c7, null c8, null c9  from ems_tmp_detail where columncode like 'A.B.B.2.a%'
else if @columncode='A.B.B.2.b'
	select col1 c1, col2 c2, null c3, null c4, null c5, null c6, null c7, null c8, null c9, null c10  from ems_tmp_detail where columncode like 'A.B.B.2.b%'
else if @columncode='A.B.B.2.c'
	select col1 c1, col2 c2, null c3, null c4, null c5, null c6, null c7, null c8, null c9, null c10  from ems_tmp_detail where columncode like 'A.B.B.2.c%'
else if @columncode='A.B.B.3'
	select col1 c1, col2 c2, null c3, null c4, null c5, null c6, null c7, null c8, null c9, null c10  from ems_tmp_detail where columncode like 'A.B.B.3%'
else if @columncode='A.B.B.4.a'
	select col1 c1, col2 c2, null c3, null c4, null c5, null c6, null c7, null c8  from ems_tmp_detail where columncode like 'A.B.B.4.a%'
else if @columncode='A.B.B.4.b.i'
	select col1 c1, col2 c2, null c3, null c4, null c5, null c6, null c7 from ems_tmp_detail where columncode like 'A.B.B.4.b.i.%'
else if @columncode='A.B.B.4.b.ii'
	select col1 c1, col2 c2, null c3, null c4, null c5, null c6 from ems_tmp_detail where columncode like 'A.B.B.4.b.ii.%'
else if @columncode='A.B.B.4.c'
	select col1 c1, null c2, null c3, null c4, null c5, null c6, null c7 from ems_tmp_detail where columncode like 'A.B.B.4.c%'
else if @columncode='A.B.B.4.d'
	select col1 c1, null c2, null c3, null c4, null c5, null c6, null c7, null c8, null c9, null c10 from ems_tmp_detail where columncode like 'A.B.B.4.d%'
else if @columncode='A.B.B.4.e'
	select col1 c1, null c2, null c3, null c4 from ems_tmp_detail where columncode like 'A.B.B.4.e%'
else if @columncode='A.B.B.4.f'
	select col1 c1, null c2, null c3 from ems_tmp_detail where columncode like 'A.B.B.4.f%'
else if @columncode='A.B.B.4.g'
	select col1 c1, col2 c2, null c3, null c4, null c5, null c6, null c7, null c8 from ems_tmp_detail where columncode like 'A.B.B.4.g%'
else if @columncode='A.B.B.4.h'
	select col1 c1, col2 c2, null c3, null c4 from ems_tmp_detail where columncode like 'A.B.B.4.h%'
else if @columncode='A.B.B.5'
	select col1 c1, col2 c2, null c3, null c4, null c5, null c6, null c7 from ems_tmp_detail where columncode like 'A.B.B.5%'
else if @columncode='A.B.C'
	select col1 c1, col2 c2, col3 c3, null c4, null c5, null c6, null c7, null c8, null c9, null c10 from ems_tmp_detail where columncode like 'A.B.C%'


--------------- Addendum C -----------------
else if @columncode='A.C.A.1'
	select null c1, null c2, null c3, null c4, null c5, null c6, null c7 from ems_tmp_detail where columncode like 'A.C.A.1%'
else if @columncode='A.C.A.2'
	select col1 c1, null c2 from ems_tmp_detail where columncode like 'A.C.A.2%'




