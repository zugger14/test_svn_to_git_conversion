/******************************************************************************
* Modified By : Mukesh Singh
* Modified Date :30-Jan-2009
* Purpose : To replace 'Time Zone' with 'US Time Zone' column name time_zone int
*
********************************************************************************/


/*****************************************************************************************************************************************
* Modified Table static_data_value columns 'code' and  'decsription' to varchar 500 it was 250 before and was throwing error while inserting large string
Decsription
*****************************************************************************************************************************************/

alter table static_data_value alter column description varchar (500)
alter table static_data_value alter column code varchar (500)

-- To delete the existing data in the table static_data_value to insert the new data as some data was missing thee due to column lengths
delete static_data_value where type_id = 1700


update static_data_type 
set
type_name = 'Time Zone'
where 
type_id=1400

/**********************************************************
* Inserted 'Time zone' in internal type_id = 1700
***********************************************************/

insert into static_data_type(type_id,type_name,internal,description) values(1700,'Time Zone',1,'Time Zone')



set identity_insert static_data_value on
insert into static_data_value(value_id,type_id,code,description) values(1700,1700,'(GMT-10:00)Hawaii','(GMT-10:00)Hawaii')
insert into static_data_value(value_id,type_id,code,description) values(1701,1700,'(GMT-09:00)Alaska','(GMT-09:00)Alaska')
insert into static_data_value(value_id,type_id,code,description) values(1702,1700,'(GMT-08:00)Pacific Time(US & Canada)','(GMT-08:00)Pacific Time(US & Canada)')
insert into static_data_value(value_id,type_id,code,description) values(1703,1700,'(GMT-08:00)Tijuana, Baja California','(GMT-08:00)Tijuana, Baja California')
insert into static_data_value(value_id,type_id,code,description) values(1704,1700,'(GMT-07:00) Arizona','(GMT-07:00) Arizona')
insert into static_data_value(value_id,type_id,code,description) values(1705,1700,'(GMT-07:00) Chihuahua, La Paz, Mazatlan –New','(GMT-07:00) Chihuahua, La Paz, Mazatlan –New')
insert into static_data_value(value_id,type_id,code,description) values(1706,1700,'(GMT-06:00) Central Time(US & Canada)','(GMT-06:00) Central Time(US & Canada)')
insert into static_data_value(value_id,type_id,code,description) values(1707,1700,'(GMT-06:00) Guadalajara,Mexico City,Monterrey –Old','(GMT-06:00) Guadalajara,Mexico City,Monterrey –Old')
insert into static_data_value(value_id,type_id,code,description) values(1708,1700,'(GMT-06:00) Saskatchewan','((GMT-06:00) Saskatchewan')
insert into static_data_value(value_id,type_id,code,description) values(1709,1700,'(GMT-05:00) Bogota,Lima,Quito,Rio Branco','(GMT-05:00) Bogota,Lima,Quito,Rio Branco')
insert into static_data_value(value_id,type_id,code,description) values(1710,1700,'(GMT-05:00) Eastern Time(US & Canada)','(GMT-05:00) Eastern Time(US & Canada)')
insert into static_data_value(value_id,type_id,code,description) values(1711,1700,'(GMT-05:00) Indiana (East)','(GMT-05:00) Indiana (East)')
insert into static_data_value(value_id,type_id,code,description) values(1712,1700,'(GMT-04:30) Caracas','(GMT-04:30) Caracas')
insert into static_data_value(value_id,type_id,code,description) values(1713,1700,'(GMT-04:00) Atlantic Time(Canada)','(GMT-04:00) Atlantic Time(Canada)')
insert into static_data_value(value_id,type_id,code,description) values(1714,1700,'(GMT-04:00) La Paz','(GMT-04:00) La Paz')
insert into static_data_value(value_id,type_id,code,description) values(1715,1700,'(GMT-04:00) Manaus','(GMT-04:00) Manaus')
insert into static_data_value(value_id,type_id,code,description) values(1716,1700,'(GMT-04:00) Santiago','(GMT-04:00) Santiago')
insert into static_data_value(value_id,type_id,code,description) values(1717,1700,'(GMT-04:00) Newfoundland','(GMT-04:00) Newfoundland')
insert into static_data_value(value_id,type_id,code,description) values(1718,1700,'(GMT-04:00) Brasilia','(GMT-04:00) Brasilia')
insert into static_data_value(value_id,type_id,code,description) values(1719,1700,'(GMT-03:00) Buenos Aries','(GMT-03:00) Buenos Aries')
insert into static_data_value(value_id,type_id,code,description) values(1720,1700,'(GMT-03:00) Georgetown','(GMT-03:00) Georgetown')
insert into static_data_value(value_id,type_id,code,description) values(1721,1700,'(GMT-03:00) Greenland','(GMT-03:00) Greenland')
insert into static_data_value(value_id,type_id,code,description) values(1722,1700,'(GMT-03:00) Montevideo','(GMT-03:00) Montevideo')
insert into static_data_value(value_id,type_id,code,description) values(1723,1700,'(GMT-02:00) Mid-Atlantic','(GMT-02:00) Mid-Atlantic')
insert into static_data_value(value_id,type_id,code,description) values(1724,1700,'(GMT-01:00) Azores','(GMT-01:00) Azores')
insert into static_data_value(value_id,type_id,code,description) values(1725,1700,'(GMT-01:00) Cape Verde Is.','(GMT-01:00) Cape Verde Is.')
insert into static_data_value(value_id,type_id,code,description) values(1726,1700,'(GMT) Casablanca','(GMT) Casablanca')
insert into static_data_value(value_id,type_id,code,description) values(1727,1700,'(GMT) Greenwich Mean Time:Dublin,Edinburgh,Liston,London','(GMT) Greenwich Mean Time:Dublin,Edinburgh,Liston,London')
insert into static_data_value(value_id,type_id,code,description) values(1728,1700,'(GMT) Monrovai,Reykjavik','(GMT) Monrovai,Reykjavik')
insert into static_data_value(value_id,type_id,code,description) values(1729,1700,'(GMT+01:00) Amsterdam, Berlin,Bern,Rome,Stockholm,Vienna','(GMT+01:00) Amsterdam,Berlin,Bern,Rome,Stockholm,Vienna')
insert into static_data_value(value_id,type_id,code,description) values(1730,1700,'(GMT+01:00) Belgrade, Bratislava, Budapest,Ljubljana,Prague','(GMT+01:00) Belgrade,Bratislava,Budapest,Ljubljana,Prague')
insert into static_data_value(value_id,type_id,code,description) values(1731,1700,'(GMT+01:00) Brussels,Copenhagen,Madrid,Paris','(GMT+01:00) Brussels,Copenhagen,Madrid,Paris')
insert into static_data_value(value_id,type_id,code,description) values(1732,1700,'(GMT+01:00) Sarajevo,Skooje,Warsaw,Zagreb','(GMT+01:00) Sarajevo,Skooje,Warsaw,Zagreb')
insert into static_data_value(value_id,type_id,code,description) values(1733,1700,'(GMT+01:00) West Central Africa','(GMT+01:00) West Central Africa')
insert into static_data_value(value_id,type_id,code,description) values(1734,1700,'(GMT+02:00) Amman','(GMT+02:00) Amman')
insert into static_data_value(value_id,type_id,code,description) values(1735,1700,'(GMT+02:00) Athens,Bucharest,Istanbul','(GMT+02:00) Athens,Bucharest,Istanbul')
insert into static_data_value(value_id,type_id,code,description) values(1736,1700,'(GMT+02:00) Beirut','(GMT+02:00) Beirut')
insert into static_data_value(value_id,type_id,code,description) values(1737,1700,'(GMT+02:00) Cairo','(GMT+02:00) Cairo')
insert into static_data_value(value_id,type_id,code,description) values(1738,1700,'(GMT+02:00) Harare, Pretoria','(GMT+02:00) Harare, Pretoria')
insert into static_data_value(value_id,type_id,code,description) values(1739,1700,'(GMT+02:00) Helsinki,Kyiv,Riga,Sofia,Talinn,Vilnuis','(GMT+02:00) Helsinki,Kyiv,Riga,Sofia,Talinn,Vilnuis')
insert into static_data_value(value_id,type_id,code,description) values(1740,1700,'(GMT+02:00) Jerusalem','(GMT+02:00) Jerusalem')
insert into static_data_value(value_id,type_id,code,description) values(1741,1700,'(GMT+02:00) Minsk','(GMT+02:00) Minsk')
insert into static_data_value(value_id,type_id,code,description) values(1742,1700,'(GMT+02:00) Windhoek','(GMT+02:00) Windhoek')
insert into static_data_value(value_id,type_id,code,description) values(1743,1700,'(GMT+03:00) Baghdad','(GMT+03:00) Baghdad')
insert into static_data_value(value_id,type_id,code,description) values(1744,1700,'(GMT+03:00) Kuwait,Riyadh','(GMT+03:00) Kuwait,Riyadh')
insert into static_data_value(value_id,type_id,code,description) values(1745,1700,'(GMT+03:00) Moscow,St. Petersburgh,Volgograd','(GMT+03:00) Moscow,St.Petersburgh,Volgograd')
insert into static_data_value(value_id,type_id,code,description) values(1746,1700,'(GMT+03:00) Nairobi','(GMT+03:00) Nairobi')
insert into static_data_value(value_id,type_id,code,description) values(1747,1700,'(GMT+03:00) Tbillisi','(GMT+03:00) Tbillisi')
insert into static_data_value(value_id,type_id,code,description) values(1748,1700,'(GMT+03:00) Tehran','(GMT+03:00) Tehran')
insert into static_data_value(value_id,type_id,code,description) values(1749,1700,'(GMT+04:00) Abu Dhabi,Muscat','(GMT+04:00) Abu Dhabi,Muscat')
insert into static_data_value(value_id,type_id,code,description) values(1750,1700,'(GMT+04:00) Bakhu','(GMT+04:00) Bakhu')
insert into static_data_value(value_id,type_id,code,description) values(1751,1700,'(GMT+04:00) Caucasus Standard Time','(GMT+04:00) Caucasus Standard Time')
insert into static_data_value(value_id,type_id,code,description) values(1752,1700,'(GMT+04:00) Yerevan','(GMT+04:00) Yerevan')
insert into static_data_value(value_id,type_id,code,description) values(1753,1700,'(GMT+04:30) Kabul','(GMT+04:30) Kabul')
insert into static_data_value(value_id,type_id,code,description) values(1754,1700,'(GMT+05:00) Ekaterinburg','(GMT+05:00) Ekaterinburg')
insert into static_data_value(value_id,type_id,code,description) values(1755,1700,'(GMT+05:00) Islamabad,Karachi','(GMT+05:00) Islamabad,Karachi')
insert into static_data_value(value_id,type_id,code,description) values(1756,1700,'(GMT+05:00) Tashkent','(GMT+05:00) Tashkent')
insert into static_data_value(value_id,type_id,code,description) values(1757,1700,'(GMT+05:30) Chennai,Kolkata,Mumbai,New Delhi','(GMT+05:30) Chennai,Kolkata,Mumbai,New Delhi')
insert into static_data_value(value_id,type_id,code,description) values(1758,1700,'(GMT+05:30) Sri Jayawardenepura','(GMT+05:30) Sri Jayawardenepura')
insert into static_data_value(value_id,type_id,code,description) values(1759,1700,'(GMT+05:45) Kathmandu','(GMT+05:45) Kathmandu')
insert into static_data_value(value_id,type_id,code,description) values(1760,1700,'(GMT+06:00) Almaty,Novosibirsk','(GMT+06:00) Almaty,Novosibirsk')
insert into static_data_value(value_id,type_id,code,description) values(1761,1700,'(GMT+06:00) Astana,Dhaka','(GMT+06:00) Astana,Dhaka')
insert into static_data_value(value_id,type_id,code,description) values(1762,1700,'(GMT+06:30) Yangon (Rangoon)','(GMT+06:30) Yangon (Rangoon)')
insert into static_data_value(value_id,type_id,code,description) values(1763,1700,'(GMT+07:00) Bangkok,Hanoi,Jakarta','(GMT+07:00) Bangkok,Hanoi,Jakarta')
insert into static_data_value(value_id,type_id,code,description) values(1764,1700,'(GMT+07:00) Krasnoyarsk','(GMT+07:00) Krasnoyarsk')
insert into static_data_value(value_id,type_id,code,description) values(1765,1700,'(GMT+08:00) Beijing,Chonging,Hong Kong,Urumqi','(GMT+08:00) Beijing,Chonging,Hong Kong,Urumqi')
insert into static_data_value(value_id,type_id,code,description) values(1766,1700,'(GMT+08:00) Irkutsk,Ulaan Bataar','(GMT+08:00) Irkutsk,Ulaan Bataar')
insert into static_data_value(value_id,type_id,code,description) values(1767,1700,'(GMT+08:00) Kuala Lumpur,Singapore','(GMT+08:00) Kuala Lumpur,Singapore')
insert into static_data_value(value_id,type_id,code,description) values(1768,1700,'(GMT+08:00) Perth','(GMT+08:00) Perth')
insert into static_data_value(value_id,type_id,code,description) values(1769,1700,'(GMT+08:00) Taipei','(GMT+08:00) Taipei')
insert into static_data_value(value_id,type_id,code,description) values(1770,1700,'(GMT+09:00) Osaka,Sapporo,Tokyo','(GMT+09:00) Osaka,Sapporo,Tokyo')
insert into static_data_value(value_id,type_id,code,description) values(1771,1700,'(GMT+09:00) Seoul','(GMT+09:00) Seoul')
insert into static_data_value(value_id,type_id,code,description) values(1772,1700,'(GMT+09:30) Adelaide','(GMT+09:30) Adelaide')
insert into static_data_value(value_id,type_id,code,description) values(1773,1700,'(GMT+09:30) Darwin','(GMT+09:30) Darwin')
insert into static_data_value(value_id,type_id,code,description) values(1774,1700,'(GMT+10:00) Brisbane','(GMT+10:00) Brisbane')
insert into static_data_value(value_id,type_id,code,description) values(1775,1700,'(GMT+10:00) Canberra,Melbourne,Sydney','(GMT+10:00) Canberra,Melbourne,Sydney')
insert into static_data_value(value_id,type_id,code,description) values(1776,1700,'(GMT+10:00) Guam,Port Moresby','(GMT+10:00) Guam,Port Moresby')
insert into static_data_value(value_id,type_id,code,description) values(1777,1700,'(GMT+10:00) Hobart','(GMT+10:00) Hobart')
insert into static_data_value(value_id,type_id,code,description) values(1778,1700,'(GMT+10:00) Vladivostok','(GMT+10:00) Vladivostok')
insert into static_data_value(value_id,type_id,code,description) values(1779,1700,'(GMT+11:00) Magadan, Solomon Is,New Caledonia','(GMT+11:00) Magadan,Solomon Is,New Caledonia')
insert into static_data_value(value_id,type_id,code,description) values(1780,1700,'(GMT+12:00) Auckland,Wellington','(GMT+12:00) Auckland,Wellington')
insert into static_data_value(value_id,type_id,code,description) values(1781,1700,'(GMT+12:00) Fiji,Kamchatka,Marshall Is.','(GMT+12:00) Fiji,Kamchatka,Marshall Is.')
insert into static_data_value(value_id,type_id,code,description) values(1782,1700,'(GMT+13:00) Nuku’alofa','(GMT+13:00) Nuku’alofa')
insert into static_data_value(value_id,type_id,code,description) values(1783,1700,'(GMT-06:00) Central America','(GMT-06:00) Central America')
insert into static_data_value(value_id,type_id,code,description) values(1784,1700,'(GMT-06:00) Guadalajara,Mexico City, Monterrey –New','(GMT-06:00) Guadalajara,Mexico City, Monterrey –New')
insert into static_data_value(value_id,type_id,code,description) values(1785,1700,'(GMT-07:00) Chihuahua, La Paz, Mazatlan –Old','(GMT-07:00) Chihuahua, La Paz, Mazatlan –Old')
insert into static_data_value(value_id,type_id,code,description) values(1786,1700,'(GMT-07:00) Mountain Time (US & Canada)','(GMT-07:00) Mountain Time (US & Canada)')

set identity_insert static_data_value off

select * from static_data_value where type_id = 1700