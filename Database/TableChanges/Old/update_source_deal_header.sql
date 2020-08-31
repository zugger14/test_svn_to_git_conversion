/******************************************************************
* Created By :Mukesh SIngh
* Created Date :08-01-2009
* Purpose : To insert the values of deal_locked 'n' instead of NULL
*
*******************************************************************/
update source_deal_header
set 
deal_locked='n'
where 
deal_locked is NULL

select deal_locked from source_deal_header