/***********************************************************************************
* Modified By :Mukesh Singh
* Modified Date :20-Jan-209
* Purpose : To add fields in source_major_location and source_minor_location tables
*
***********************************************************************************/

ALTER table source_major_location ADD location_type int, region int,[owner] varchar(100)
ALTER table source_minor_location ADD location_type int