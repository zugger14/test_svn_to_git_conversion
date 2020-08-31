/**********************************************************
* The  data in the function_ids 302,311,312 are not  required.  .
* It is  change with the  341,352,387 function_ids

**********************************************************/


delete application_functions where function_id= 302
delete application_functions where function_id= 311
delete application_functions where function_id= 312




insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 314,'Maintain Loss Factor','Maintain Loss Factor',NULL,NULL,NULL,'windowMaintainLossFactor',NULL,NULL,'farrms_admin','1/26/2009 2:48:54 PM','farrms_admin','1/26/2009 2:48:54 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 315,'Add Maintain Loss Factor','Add Maintain Loss Factor',314,NULL,NULL,'windowMaintainLossFactor',NULL,NULL,'farrms_admin','1/26/2009 2:48:54 PM','farrms_admin','1/26/2009 2:48:54 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 316,'Update Maintain Loss Factor','Update Maintain Loss Factor',314,NULL,NULL,'windowMaintainLossFactor',NULL,NULL,'farrms_admin','1/26/2009 2:48:54 PM','farrms_admin','1/26/2009 2:48:54 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 317,'Delete Maintain Loss Factor','Delete Maintain Loss Factor',314,NULL,NULL,'windowMaintainLossFactor',NULL,NULL,'farrms_admin','1/26/2009 2:48:54 PM','farrms_admin','1/26/2009 2:48:54 PM',NULL) 

 insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 318,'Setup Delivery Path','Setup Delivery Path',NULL,NULL,NULL,'windowSetupDeliveryPath',NULL,NULL,'farrms_admin','1/26/2009 2:50:19 PM','farrms_admin','1/26/2009 2:50:19 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 319,'Add Setup Delivery Path','Add Setup Delivery Path',318,NULL,NULL,'windowSetupDeliveryPath',NULL,NULL,'farrms_admin','1/26/2009 2:50:19 PM','farrms_admin','1/26/2009 2:50:19 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 320,'Update Setup Delivery Path','Update Setup Delivery Path',318,NULL,NULL,'windowSetupDeliveryPath',NULL,NULL,'farrms_admin','1/26/2009 2:50:19 PM','farrms_admin','1/26/2009 2:50:19 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 321,'Delete Setup Delivery Path','Delete Setup Delivery Path',318,NULL,NULL,'windowSetupDeliveryPath',NULL,NULL,'farrms_admin','1/26/2009 2:50:19 PM','farrms_admin','1/26/2009 2:50:19 PM',NULL) 
 

insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 322,'Maintain Transactions Blotter','Maintain Transactions Blotter',NULL,NULL,NULL,'windowMaintainDealsBlotter',NULL,NULL,'farrms_admin','1/26/2009 2:57:27 PM','farrms_admin','1/26/2009 2:57:27 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 323,'Insert Maintain Transactions Blotter','Insert Maintain Transactions Blotter',322,NULL,NULL,'windowMaintainDealsBlotter',NULL,NULL,'farrms_admin','1/26/2009 2:57:27 PM','farrms_admin','1/26/2009 2:57:27 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 324,'Update Maintain Transactions Blotter','Update Maintain Transactions Blotter',322,NULL,NULL,'windowMaintainDealsBlotter',NULL,NULL,'farrms_admin','1/26/2009 2:57:27 PM','farrms_admin','1/26/2009 2:57:27 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 325,'Copy Maintain Transactions Blotter','Copy Maintain Transactions Blotter',322,NULL,NULL,'windowMaintainDealsBlotter',NULL,NULL,'farrms_admin','1/26/2009 2:57:27 PM','farrms_admin','1/26/2009 2:57:27 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 326,'Delete Maintain Transactions Blotter','Delete Maintain Transactions Blotter',322,NULL,NULL,'windowMaintainDealsBlotter',NULL,NULL,'farrms_admin','1/26/2009 2:57:27 PM','farrms_admin','1/26/2009 2:57:27 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 327,'Close Maintain Transactions Blotter','Close Maintain Transactions Blotter',322,NULL,NULL,'windowMaintainDealsBlotter',NULL,NULL,'farrms_admin','1/26/2009 2:57:27 PM','farrms_admin','1/26/2009 2:57:27 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 328,'Transfer Maintain Transactions Blotter','Transfer Maintain Transactions Blotter',322,NULL,NULL,'windowMaintainDealsBlotter',NULL,NULL,'farrms_admin','1/26/2009 2:57:27 PM','farrms_admin','1/26/2009 2:57:27 PM',NULL) 

insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 329,' Deal Blotter','Deal Blotter',323,NULL,NULL,'windowMaintainDealInsertBlotter',NULL,NULL,'farrms_admin','1/26/2009 2:57:27 PM','farrms_admin','1/26/2009 2:57:27 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 330,'Insert Deal Blotter','Insert Deal Blotter',329,NULL,NULL,'windowMaintainDealInsertBlotter',NULL,NULL,'farrms_admin','1/26/2009 2:57:27 PM','farrms_admin','1/26/2009 2:57:27 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 331,'Delete Deal Blotter','Delete Deal Blotter',329,NULL,NULL,'windowMaintainDealInsertBlotter',NULL,NULL,'farrms_admin','1/26/2009 2:57:27 PM','farrms_admin','1/26/2009 2:57:27 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 332,'Detail Deal Blotter','Detail Deal Blotter',329,NULL,NULL,'windowMaintainDealInsertBlotter',NULL,NULL,'farrms_admin','1/26/2009 2:57:27 PM','farrms_admin','1/26/2009 2:57:27 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 333,'Save Deal Blotter','Save Deal Blotter',329,NULL,NULL,'windowMaintainDealInsertBlotter',NULL,NULL,'farrms_admin','1/26/2009 2:57:27 PM','farrms_admin','1/26/2009 2:57:27 PM',NULL)

insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 335,'Run Options Report','Run Options Report',NULL,NULL,NULL,'windowRunOptionsReport',NULL,NULL,'farrms_admin','1/26/2009 3:00:32 PM','farrms_admin','1/26/2009 3:00:32 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 336,'Run Options Greeks Report','Run Options Greeks Report',NULL,NULL,NULL,'windowRunOptionsGreeksReport',NULL,NULL,'farrms_admin','1/26/2009 3:01:23 PM','farrms_admin','1/26/2009 3:01:23 PM',NULL) 

insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 337,'Transaction Audit Log Report','Transaction Audit Log Report',NULL,NULL,NULL,'windowTransactionAuditLog',NULL,NULL,'farrms_admin','1/26/2009 3:03:04 PM','farrms_admin','1/26/2009 5:32:07 PM',NULL) 
 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 338,'Run Unconfirmed Exception Report','Run Unconfirmed Exception Report',NULL,NULL,NULL,'windowUnconfirmedExeptionReport',NULL,NULL,'farrms_admin','1/26/2009 3:05:20 PM','farrms_admin','1/26/2009 3:05:20 PM',NULL) 

insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 339,'Run VaR Calculations','Run VaR Calculations',NULL,NULL,NULL,'VaRMeasurementCriteriaDetailReport',NULL,NULL,'farrms_admin','1/26/2009 3:08:49 PM','farrms_admin','1/26/2009 3:08:49 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 340,'Run VaR Report','Run VaR Report',NULL,NULL,NULL,'windowVaRreport',NULL,NULL,'farrms_admin','1/26/2009 3:09:38 PM','farrms_admin','1/26/2009 3:09:38 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 341,'Run Limits Report','Run Limits Report',NULL,NULL,NULL,'windowLimitsReport',NULL,NULL,'farrms_admin','1/26/2009 3:10:52 PM','farrms_admin','1/26/2009 3:10:52 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 342,'Run Implied Volatility Calculations','Run Implied Volatility Calculations',NULL,NULL,NULL,'windowCalImpVolatility',NULL,NULL,'farrms_admin','1/26/2009 3:12:14 PM','farrms_admin','1/26/2009 3:12:14 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 343,'Run Implied Volatility Report','Run Implied Volatility Report',NULL,NULL,NULL,'windowReportImpVol',NULL,NULL,'farrms_admin','1/26/2009 3:12:40 PM','farrms_admin','1/26/2009 3:12:40 PM',NULL) 

insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 344,'Run Fixed/MTM Exposure Report','Run Fixed/MTM Exposure Report',NULL,NULL,NULL,'windowRunFixdMtmExposureReport',NULL,NULL,'farrms_admin','1/26/2009 3:18:02 PM','farrms_admin','1/26/2009 3:18:02 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 345,'Run Exposure Concentration Report','Run Exposure Concentration Report',NULL,NULL,NULL,'windowRunConcExposureReport',NULL,NULL,'farrms_admin','1/26/2009 3:20:19 PM','farrms_admin','1/26/2009 3:20:19 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 346,'Run Credit Reserve Report','Run Credit Reserve Report',NULL,NULL,NULL,'windowCrRunReserveReport',NULL,NULL,'farrms_admin','1/26/2009 3:20:40 PM','farrms_admin','1/26/2009 3:20:40 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 347,'Run Aged A/R Report','Run Aged A/R Report',NULL,NULL,NULL,'windowAgedARReport',NULL,NULL,'farrms_admin','1/26/2009 3:25:51 PM','farrms_admin','1/26/2009 3:25:51 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 348,'Run Credit Exposure Report','Run Credit Exposure Report',NULL,NULL,NULL,'windowRunCreditExposureReport',NULL,NULL,'farrms_admin','1/26/2009 3:27:34 PM','farrms_admin','1/26/2009 3:27:34 PM',NULL)
 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 349,'Run Settlement Process','Run Settlement Process',NULL,NULL,NULL,'windowMaintainInvoice',NULL,NULL,'farrms_admin','1/26/2009 3:34:51 PM','farrms_admin','1/26/2009 3:34:51 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 350,'Run Inventory Calc','Run Inventory Calc',NULL,NULL,NULL,'windowRunInventoryCalc',NULL,NULL,'farrms_admin','1/26/2009 3:35:50 PM','farrms_admin','1/26/2009 3:35:50 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 351,'Run Settlement Report','Run Settlement Report',NULL,NULL,NULL,'windowBrokerFeeReport',NULL,NULL,'farrms_admin','1/26/2009 3:36:30 PM','farrms_admin','1/26/2009 3:36:30 PM',NULL) 

insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 352,'Maintain VaR Measurement Criteria','Maintain VaR Measurement Criteria',NULL,NULL,NULL,'VaRMeasurementCriteriaDetail',NULL,NULL,'farrms_admin','1/26/2009 3:06:37 PM','farrms_admin','1/26/2009 3:06:37 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 353,'Insert Maintain VaR Measurement Criteria','Insert Maintain VaR Measurement Criteria',352,NULL,NULL,'VaRMeasurementCriteriaDetail',NULL,NULL,'farrms_admin','1/26/2009 3:06:37 PM','farrms_admin','1/26/2009 3:06:37 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 354,'Update Maintain VaR Measurement Criteria','Update Maintain VaR Measurement Criteria',352,NULL,NULL,'VaRMeasurementCriteriaDetail',NULL,NULL,'farrms_admin','1/26/2009 3:06:37 PM','farrms_admin','1/26/2009 3:06:37 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 355,'Delete Maintain VaR Measurement Criteria','Delete Maintain VaR Measurement Criteria',352,NULL,NULL,'VaRMeasurementCriteriaDetail',NULL,NULL,'farrms_admin','1/26/2009 3:06:37 PM','farrms_admin','1/26/2009 3:06:37 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 356,'Copy Maintain VaR Measurement Criteria','Copy Maintain VaR Measurement Criteria',352,NULL,NULL,'VaRMeasurementCriteriaDetail',NULL,NULL,'farrms_admin','1/26/2009 3:06:37 PM','farrms_admin','1/26/2009 3:06:37 PM',NULL) 

insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 357,' VaR Measurement Criteria Detail','VaR Measurement Criteria Detail',353,NULL,NULL,'VaRMeasurementCriteriaDetailIU',NULL,NULL,'farrms_admin','1/26/2009 3:06:37 PM','farrms_admin','1/26/2009 3:06:37 PM',NULL) 
 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 358,'Insert VaR Measurement Criteria Detail','Insert VaR Measurement Criteria Detail',357,NULL,NULL,'VaRMeasurementCriteriaDetailIU',NULL,NULL,'farrms_admin','1/26/2009 3:06:37 PM','farrms_admin','1/26/2009 3:06:37 PM',NULL) 

insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 359,'Update VaR Measurement Criteria Detail','Update VaR Measurement Criteria Detail',357,NULL,NULL,'VaRMeasurementCriteriaDetailIU',NULL,NULL,'farrms_admin','1/26/2009 3:06:37 PM','farrms_admin','1/26/2009 3:06:37 PM',NULL) 

insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 360,'Delete VaR Measurement Criteria Detail','Delete VaR Measurement Criteria Detail',357,NULL,NULL,'VaRMeasurementCriteriaDetailIU',NULL,NULL,'farrms_admin','1/26/2009 3:06:37 PM','farrms_admin','1/26/2009 3:06:37 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 361,' VaR Criteria Book IU',' VaR Criteria Book IU',358,NULL,NULL,'VaRCriteriaBookIU',NULL,NULL,'farrms_admin','1/26/2009 3:06:37 PM','farrms_admin','1/26/2009 3:06:37 PM',NULL) 

insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 362,'Maintain Limits','Maintain Limits',NULL,NULL,NULL,'LimitTrackingScreen',NULL,NULL,'farrms_admin','1/26/2009 3:08:25 PM','farrms_admin','1/26/2009 3:08:25 PM',NULL) 

insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 363,'Insert Maintain Limits','Insert Maintain Limits',362,NULL,NULL,'LimitTrackingScreen',NULL,NULL,'farrms_admin','1/26/2009 3:08:25 PM','farrms_admin','1/26/2009 3:08:25 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 364,'Update Maintain Limits','Update Maintain Limits',362,NULL,NULL,'LimitTrackingScreen',NULL,NULL,'farrms_admin','1/26/2009 3:08:25 PM','farrms_admin','1/26/2009 3:08:25 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 365,'Delete Maintain Limits','Delete Maintain Limits',362,NULL,NULL,'LimitTrackingScreen',NULL,NULL,'farrms_admin','1/26/2009 3:08:25 PM','farrms_admin','1/26/2009 3:08:25 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 366,'Limit Tracking ScreenIU','Limit Tracking ScreenIU',363,NULL,NULL,'LimitTrackingScreenIU',NULL,NULL,'farrms_admin','1/26/2009 3:08:25 PM','farrms_admin','1/26/2009 3:08:25 PM',NULL)
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 367,'Insert Limit Tracking ScreenIU','Insert Limit Tracking ScreenIU',363,NULL,NULL,'LimitTrackingScreenIU',NULL,NULL,'farrms_admin','1/26/2009 3:08:25 PM','farrms_admin','1/26/2009 3:08:25 PM',NULL)
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 368,'Update Limit Tracking ScreenIU','Update Limit Tracking ScreenIU',363,NULL,NULL,'LimitTrackingScreenIU',NULL,NULL,'farrms_admin','1/26/2009 3:08:25 PM','farrms_admin','1/26/2009 3:08:25 PM',NULL)
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 369,'Delete Limit Tracking ScreenIU','Delete Limit Tracking ScreenIU',363,NULL,NULL,'LimitTrackingScreenIU',NULL,NULL,'farrms_admin','1/26/2009 3:08:25 PM','farrms_admin','1/26/2009 3:08:25 PM',NULL)
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 370,'Limit Tracking BookIU','Limit Tracking BookIU',367,NULL,NULL,'LimitTrackingBookIU',NULL,NULL,'farrms_admin','1/26/2009 3:08:25 PM','farrms_admin','1/26/2009 3:08:25 PM',NULL)
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 371,'Limit Tracking CurveIU','Limit Tracking CurveIU',367,NULL,NULL,'LimitTrackingCurveIU',NULL,NULL,'farrms_admin','1/26/2009 3:08:25 PM','farrms_admin','1/26/2009 3:08:25 PM',NULL)

insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 372,'Export Credit Data Report','Export Credit Data Report',NULL,NULL,NULL,'windowExportCreditData',NULL,NULL,'farrms_admin','1/26/2009 3:17:25 PM','farrms_admin','1/26/2009 3:17:25 PM',NULL) 
 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 373,'Settlement Calculation History','Settlement Calculation History',NULL,NULL,NULL,'windowMaintainInvoiceHistory',NULL,NULL,'farrms_admin','1/26/2009 3:37:12 PM','farrms_admin','1/26/2009 3:37:12 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 374,'Insert Settlement Calculation History','Insert Settlement Calculation History',373,NULL,NULL,'windowMaintainInvoiceHistory',NULL,NULL,'farrms_admin','1/26/2009 3:37:12 PM','farrms_admin','1/26/2009 3:37:12 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 375,'Update Settlement Calculation History','Update Settlement Calculation History',373,NULL,NULL,'windowMaintainInvoiceHistory',NULL,NULL,'farrms_admin','1/26/2009 3:37:12 PM','farrms_admin','1/26/2009 3:37:12 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 376,'Delete Settlement Calculation History','Delete Settlement Calculation History',373,NULL,NULL,'windowMaintainInvoiceHistory',NULL,NULL,'farrms_admin','1/26/2009 3:37:12 PM','farrms_admin','1/26/2009 3:37:12 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 377,'Detail Settlement Calculation History','Detail Settlement Calculation History',373,NULL,NULL,'windowMaintainInvoiceHistory',NULL,NULL,'farrms_admin','1/26/2009 3:37:12 PM','farrms_admin','1/26/2009 3:37:12 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 378,'Detail Settlement Calculation History IU','Detail Settlement Calculation HistoryIU',377,NULL,NULL,'windowMaintainInvoiceReconcile',NULL,NULL,'farrms_admin','1/26/2009 3:37:12 PM','farrms_admin','1/26/2009 3:37:12 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 379,'Insert Settlement Calculation History IU',' Settlement Calculation HistoryIU',374,NULL,NULL,'windowMaintainInvoiceIU',NULL,NULL,'farrms_admin','1/26/2009 3:37:12 PM','farrms_admin','1/26/2009 3:37:12 PM',NULL) 

insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 380,'Delete Settlement Calculation History shadow',' Delete Settlement Calculation History shadow',376,NULL,NULL,'windowMaintainInvoiceDelete',NULL,NULL,'farrms_admin','1/26/2009 3:37:12 PM','farrms_admin','1/26/2009 3:37:12 PM',NULL) 

insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 381,'Post JE Report','Post JE Report',NULL,NULL,NULL,'windowPostJEReport',NULL,NULL,'farrms_admin','1/26/2009 3:37:54 PM','farrms_admin','1/26/2009 3:37:54 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 382,'Post JE Report for Post','Post JE Report for Post',381,NULL,NULL,'windowPostJEReport',NULL,NULL,'farrms_admin','1/26/2009 3:37:54 PM','farrms_admin','1/26/2009 3:37:54 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 383,'Delete Post JE Report','Delete Post JE Report',381,NULL,NULL,'windowPostJEReport',NULL,NULL,'farrms_admin','1/26/2009 3:37:54 PM','farrms_admin','1/26/2009 3:37:54 PM',NULL) 

insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 384,'Apply Cash','Apply Cash',NULL,NULL,NULL,'windowApplyCash',NULL,NULL,'farrms_admin','1/26/2009 3:40:31 PM','farrms_admin','1/26/2009 3:40:31 PM',NULL) 

insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 385,' Save Apply Cash','Save Apply Cash',384,NULL,NULL,'windowApplyCash',NULL,NULL,'farrms_admin','1/26/2009 3:40:31 PM','farrms_admin','1/26/2009 3:40:31 PM',NULL) 

insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 386,' Delete Apply Cash','Delete Apply Cash',384,NULL,NULL,'windowApplyCash',NULL,NULL,'farrms_admin','1/26/2009 3:40:31 PM','farrms_admin','1/26/2009 3:40:31 PM',NULL) 

insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 387,'Reconcile Cash Entries for Derivatives','Reconcile Cash Entries for Derivatives',NULL,NULL,NULL,'windowReconcileCashEntriesDerivatives',NULL,NULL,'farrms_admin','1/26/2009 3:40:02 PM','farrms_admin','1/26/2009 3:40:02 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 388,'Save Reconcile Cash Entries for Derivatives','Save Reconcile Cash Entries for Derivatives',387,NULL,NULL,'windowReconcileCashEntriesDerivatives',NULL,NULL,'farrms_admin','1/26/2009 3:40:02 PM','farrms_admin','1/26/2009 3:40:02 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 389,'Delete Reconcile Cash Entries for Derivatives','Delete Reconcile Cash Entries for Derivatives',387,NULL,NULL,'windowReconcileCashEntriesDerivatives',NULL,NULL,'farrms_admin','1/26/2009 3:40:02 PM','farrms_admin','1/26/2009 3:40:02 PM',NULL) 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 390,'Maintain Counterparty','Maintain Counterparty',NULL,NULL,NULL,'windowMaintainDefinationArg',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)
 insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 391,'Detail Maintain Counterparty','Detail Maintain Counterparty',390,NULL,NULL,'windowMaintainDefinationArg',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)
 insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 392,'Insert Maintain Counterparty','Insert Maintain Counterparty',390,NULL,NULL,'windowMaintainDefinationArg',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)
 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 393,'Update Maintain Counterparty','Update Maintain Counterparty',390,NULL,NULL,'windowMaintainDefinationArg',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)
 insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 394,'Credit info Maintain Counterparty','Credit info Maintain Counterparty ',390,NULL,NULL,'windowMaintainDefinationArg',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)
 insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 395,'Counterparty Credit info','Counterparty Credit info ',394,NULL,NULL,'windowCounterpartyCreditFile',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)
 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 396,' Enhance info Maintain Counterparty IU',' Enhance info Maintain Counterparty IU',395,NULL,NULL,'windowCounterpartyCreditFile',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)
 insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 397,'Insert Enhance info Maintain Counterparty IU','Insert Enhance info Maintain Counterparty IU',395,NULL,NULL,'windowCounterpartyCreditFileEnhanceIU',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)
 insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 398,'Update Enhance Maintain Counterparty IU','Update  Enhanceinfo Maintain Counterparty IU',395,NULL,NULL,'windowCounterpartyCreditFileEnhanceIU',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)
 insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 399,'Delete Enhance info Maintain Counterparty IU','Delete Enhance info Maintain Counterparty IU',395,NULL,NULL,'windowCounterpartyCreditFileEnhanceIU',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)
 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 400,' block trading Maintain Counterparty IU','block trading Maintain Counterparty IU',395,NULL,NULL,'windowCounterpartyCreditFile',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 401,'Insert block trading Maintain Counterparty IU','Insert block trading Maintain Counterparty IU',400,NULL,NULL,'windowCounterpartyBlockTradingIU',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)
 insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 402,'Update block trading Maintain Counterparty IU','Update  block trading Maintain Counterparty IU',400,NULL,NULL,'windowCounterpartyBlockTradingIU',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)
 insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 403,'Delete block trading Maintain Counterparty IU','Deleteblock trading Maintain Counterparty IU',400,NULL,NULL,'windowCounterpartyBlockTradingIU',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)
 


insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values (404,' Maintain Counterparty ','Maintain Counterparty',390,NULL,NULL,'windowMaintainDefinationCon',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)
 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 405,'Insert payment Counterparty ','Insert payment Counterparty',404,NULL,NULL,'windowCounterpartyBankInfo',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)
 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 406,'Update payment Counterparty','Update payment Counterparty',404,NULL,NULL,'windowCounterpartyBankInfo',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)
 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 407,'Delete payment Counterparty','Delete payment Counterparty',404,NULL,NULL,'windowCounterpartyBankInfo',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)
 

insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 408,'Insert contract Counterparty ','Insert contract Counterparty',404,NULL,NULL,'windowMaintainRecContract',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)
 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values (409,'Update contract Counterparty','Update contract Counterparty',404,NULL,NULL,'windowMaintainRecContract',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)
 
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 410,'Delete contract Counterparty','Delete contract Counterparty',404,NULL,NULL,'windowMaintainRecContract',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)
 

insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 411,'Run Hourly Position report','Run Hourly Position report',NULL,NULL,NULL,'windowSettlementProductionReport',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)

insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 412,'Maintain Defination Major Location','Maintain Defination Major Location',140,NULL,NULL,'windowMaintainDefinationMajor_Location',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 413,'Maintain Defination Minor Location','Maintain Defination Minor Location',140,NULL,NULL,'windowMaintainDefinationMinor_Location',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 414,' Detail Maintain Defination','Detail Maintain Defination',NULL,NULL,NULL,'windowMinorLocDetail',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 415,'Major Loc Detail','Major Loc Detail',414,NULL,NULL,'windowMajorLocDetail',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)
insert application_functions( function_id,function_name,function_desc,func_ref_id,requires_at,document_path,function_call,function_parameter,module_type,create_user,create_ts,update_user,update_ts,process_map_id)
values ( 416,'Minor Loc Detail','Minor Loc Detail',414,NULL,NULL,'windowMinorLocDetail',NULL,NULL,'farrms_admin','1/26/2009 3:15:29 PM','farrms_admin','1/26/2009 3:15:29 PM',NULL)

