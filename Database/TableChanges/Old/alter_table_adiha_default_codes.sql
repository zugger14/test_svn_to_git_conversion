/********************************************************
* Modified By :Mukesh Singh
* Modified date :03-April-2009
* Purpose : To fixe the issues of Helpdesk defect id # 541
*********************************************************/
update adiha_default_codes
set
code_def='Location of Automated Forecasted Transactions'
where default_code_id=12

update adiha_default_codes
set
code_def='Finalization of Automated Forecasted Transactions'
where default_code_id=18

update adiha_default_codes
set
code_def='Over Hedge Capacity Exception  Rule During Generation'
where default_code_id=19

update adiha_default_codes
set
code_def='Weighted Average Cost of Inventory As of Date'
where default_code_id=21

update adiha_default_codes
set
code_def='Weighted Average Cost of Inventory Group By'
where default_code_id=22

update adiha_default_codes
set
code_def='Show Outstanding Control Activities'
where default_code_id=24


