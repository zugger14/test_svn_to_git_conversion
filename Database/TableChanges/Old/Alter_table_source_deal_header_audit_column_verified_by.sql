/*
Author : Narendra Shrestha
Dated  : 02.25.2010
Desc   : Created a script for the table source_deal_header_audit as this alter script was not found in other project but the column existed.
*/

ALTER TABLE source_deal_header_audit
ADD [verified_by] [varchar](50) , [verified_date] [datetime] NULL
