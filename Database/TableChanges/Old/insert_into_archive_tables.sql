-- run the script for creating archive_tables first
insert into archive_tables(tbl_name,datefield) values ('mv90_data','from_date')
insert into archive_tables(tbl_name,datefield) values ('mv90_data_mins','prod_date')
insert into archive_tables(tbl_name,datefield) values ('mv90_data_hour','prod_date')