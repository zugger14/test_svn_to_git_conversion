------------------------------- Module Administration Start --------------------------------------------------------------
--main menu
update application_functions set document_path = 'Common/Main Menu.htm' where function_id = 10000000
update application_functions set document_path = 'Common/Main Menu RecTracker.htm' where function_id = 14000000
update application_functions set document_path = 'Common/Main Menu Settlement Tracker.htm' where function_id = 15000000
update application_functions set document_path = 'Common/Schedule and Delivery Post Detail.htm' where function_id = 10161220


--Setup
update application_functions set document_path = 'Administration/Setup/configure interface timeout parameter.htm' where function_id = 10101800
update application_functions set document_path = 'Administration/Setup/Maintain Deal Template.htm' where function_id =10101400 
update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101100
update application_functions set document_path = 'Administration/Setup/Maintain Netting Asset-Liab Groups.htm' where function_id =10101500
update application_functions set document_path = 'Administration/Setup/Maintain Source Generator.htm' where function_id =10161500
update application_functions set document_path = 'Administration/Setup/Maintain Static Data.htm' where function_id =10101000
update application_functions set document_path = 'Administration/Setup/Map GL Codes.htm' where function_id =10101300
update application_functions set document_path = 'Administration/Setup/Map GL Codes.htm' where function_id =10101310
update application_functions set document_path = 'Administration/Setup/Setup Book Structure.htm' where function_id =10101200
update application_functions set document_path = 'Administration/Setup/Define Contract Components GL Codes.htm' where function_id =10231300
update application_functions set document_path = 'Administration/Setup/Define Meter ID.htm' where function_id =10221500
update application_functions set document_path = 'Administration/Setup/Setup Default GL Code for Contract Components.htm' where function_id =10231400
update application_functions set document_path = 'Administration/Setup/Setup Emissions Source-Sink Type.htm' where function_id =12101000
update application_functions set document_path = 'Administration/Setup/Setup Price Curves.htm' where function_id =10102600
update application_functions set document_path = 'Administration/Setup/Setup Price Curves.htm' where function_id =10102610
update application_functions set document_path = 'Administration/Setup/Setup Price Curves.htm' where function_id =10102612
update application_functions set document_path = 'Administration/Setup/Setup Price Curves.htm' where function_id =10102614
update application_functions set document_path = 'Administration/Setup/Setup Price Curves.htm' where function_id =10102616
update application_functions set document_path = 'Administration/Setup/Setup Location.htm' where function_id =10102500
update application_functions set document_path = 'Administration/Setup/Setup Location.htm' where function_id =10102510
update application_functions set document_path = 'Administration/Setup/Setup Profile.htm' where function_id =10102800
update application_functions set document_path = 'Administration/Setup/Setup Profile.htm' where function_id =10102810
update application_functions set document_path = 'Common/Manage Documents.htm' where function_id = 10102900
update application_functions set document_path = 'Common/Manage Documents.htm' where function_id = 10102910
update application_functions set document_path = 'Common/Manage Documents.htm' where function_id = 10102912
update application_functions set document_path = 'Administration/Setup/Maintain Deal Template.htm' where function_id = 10101416
update application_functions set document_path = 'Administration/Setup/Term Mapping.htm' where function_id = 10103100
UPDATE application_functions
SET    document_path = 'Administration/Setup/Archive Data.htm'
WHERE  function_id = 10102700

UPDATE application_functions
SET    document_path = 'Administration/Setup/Define Deal Status Privilege.htm'
WHERE  function_id = 10104000

UPDATE application_functions
SET    document_path = 'Administration/Setup/Define Deal Status Privilege.htm'
WHERE  function_id = 10104010

UPDATE application_functions
SET    document_path = 'Administration/Setup/Formula Builder.htm'
WHERE  function_id = 10102400

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Contract Components GL Codes.htm'
WHERE  function_id = 10103300

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Contract Components GL Codes.htm'
WHERE  function_id = 10103310

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Contract Components GL Codes.htm'
WHERE  function_id = 10103312


UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Field Templates.htm'
WHERE  function_id = 10104200

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Field Templates.htm'
WHERE  function_id = 10104222

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Hedge Deferral Rules.htm'
WHERE  function_id = 10103500


UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Source Generator.htm'
WHERE  function_id = 10103800


UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain UDF Template.htm'
WHERE  function_id = 10104100

UPDATE application_functions
SET    document_path = 'Administration/Setup/Remove Data.htm'
WHERE  function_id = 10103600

UPDATE application_functions
SET    document_path = 'Administration/Setup/Setup Deal Status and Confirmation Rule.htm'
WHERE  function_id = 10103900

UPDATE application_functions
SET    document_path = 'Administration/Setup/Setup Default GL Code for Contract Components.htm'
WHERE  function_id = 10103400

UPDATE application_functions
SET    document_path = 'Administration/Setup/Setup Logical Trade Lock.htm'
WHERE  function_id = 10101900

UPDATE application_functions
SET    document_path = 'Administration/Setup/Setup Tenor Bucket.htm'
WHERE  function_id = 10102000

UPDATE application_functions
SET    document_path = 'Administration/Setup/View Scheduled Job.htm'
WHERE  function_id = 10101600

UPDATE application_functions
SET    document_path = 'Administration/Setup/Setup As Of Date.htm'
WHERE  function_id = 10102200


UPDATE application_functions
SET    document_path = 'Administration/Setup/Define Meter IDs.htm'
WHERE  function_id = 10103000

UPDATE application_functions
SET    document_path = 'Administration/Setup/Define Meter IDs.htm'
WHERE  function_id = 10103010

UPDATE application_functions
SET    document_path = 'Administration/Setup/Setup Default GL Code for Contract Components.htm'
WHERE  function_id = 10103410

UPDATE application_functions
SET    document_path = 'Administration/Setup/Setup Logical Trade Lock.htm'
WHERE  function_id = 10101910

UPDATE application_functions
SET    document_path = 'Administration/Setup/Setup As Of Date.htm'
WHERE  function_id = 10102210

UPDATE application_functions
SET    document_path = 'Administration/Setup/Term Mapping.htm'
WHERE  function_id = 10103110

UPDATE application_functions
SET    document_path = 'Administration/Setup/Term Mapping.htm'
WHERE  function_id = 10103120

UPDATE application_functions
SET    document_path = 'Administration/Setup/Pratos Mapping.htm'
WHERE  function_id = 10103200

UPDATE application_functions
SET    document_path = 'Administration/Setup/Pratos Mapping.htm'
WHERE  function_id = 10103210

UPDATE application_functions
SET    document_path = 'Administration/Setup/Short Term Forecast Mapping.htm'
WHERE  function_id = 13171000

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Hedge Deferral Rules.htm'
WHERE  function_id = 10231913

update application_functions 
set document_path = 'Administration/Setup/Maintain Hedge Deferral Rules.htm' 
where function_id =10231910


UPDATE application_functions
SET    document_path = 'Administration/Setup/Setup Tenor Bucket.htm'
WHERE  function_id = 10102010

UPDATE application_functions
SET    document_path = 'Administration/Setup/Setup Tenor Bucket.htm'
WHERE  function_id = 10102012

UPDATE application_functions
SET    document_path = 'Administration/Setup/Setup Deal Status and Confirmation Rule.htm'
WHERE  function_id = 10103910

UPDATE application_functions
SET    document_path = 'Administration/Setup/Setup Deal Status and Confirmation Rule.htm'
WHERE  function_id = 10103912

UPDATE application_functions
SET    document_path = 'Administration/Setup/Setup Deal Status and Confirmation Rule.htm'
WHERE  function_id = 10103914

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Field Templates.htm'
WHERE  function_id = 10104210

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Field Templates.htm'
WHERE  function_id = 10104213

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Field Templates.htm'
WHERE  function_id = 10104215

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Field Templates.htm'
WHERE  function_id = 10104216

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain UDF Template.htm'
WHERE  function_id = 10104110

UPDATE application_functions
SET    document_path = 'Administration/Setup/Define Deal Status Privilege.htm'
WHERE  function_id = 10104011

UPDATE application_functions
SET    document_path = 'Administration/Setup/Define Meter IDs.htm'
WHERE  function_id = 10103012

UPDATE application_functions
SET    document_path = 'Administration/Setup/Define Meter IDs.htm'
WHERE  function_id = 10103014

UPDATE application_functions
SET    document_path = 'Administration/Setup/Define Meter IDs.htm'
WHERE  function_id = 10103015

UPDATE application_functions
SET    document_path ='Administration/Setup/Define Meter IDs.htm'
WHERE  function_id = 10103013

UPDATE application_functions
SET    document_path = 'Administration/Setup/Short Term Forecast Mapping.htm'
WHERE  function_id = 13171001

UPDATE application_functions
SET    document_path = 'Administration/Setup/Short Term Forecast Mapping.htm'
WHERE  function_id = 13171101

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Static Data.htm'
WHERE  function_id = 10101025

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Static Data.htm'
WHERE  function_id = 10101026

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Static Data.htm'
WHERE  function_id = 10101028

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Static Data.htm'
WHERE  function_id = 10101029

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Static Data.htm'
WHERE  function_id = 10101037

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Static Data.htm'
WHERE  function_id = 10101038

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Static Data.htm'
WHERE  function_id = 10101032

UPDATE application_functions
SET    document_path = 'Administration/Setup/Short Term Forecast Mapping.htm'
WHERE  function_id = 13171011


UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Definition.htm'
WHERE  function_id = 10101120

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Definition.htm'
WHERE  function_id = 10101123

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Definition.htm'
WHERE  function_id = 10101125

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Definition.htm'
WHERE  function_id = 10101161

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Definition.htm'
WHERE  function_id = 10101162

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Definition.htm'
WHERE  function_id = 10101147

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Definition.htm'
WHERE  function_id = 10101180

UPDATE application_functions
SET    document_path = 'Administration/Setup/Pratos Mapping.htm'
WHERE  function_id = 10103220

UPDATE application_functions
SET    document_path = 'Administration/Setup/Pratos Mapping.htm'
WHERE  function_id = 10103240

UPDATE application_functions
SET    document_path = 'Administration/Setup/Pratos Mapping.htm'
WHERE  function_id = 10103230

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Hedge Deferral Rules.htm'
WHERE  function_id = 10231917


UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Definition.htm'
WHERE  function_id = 10101175

UPDATE application_functions
SET    document_path = 'Administration/Setup/Setup Emissions Source-Sink Type.htm'
WHERE  function_id = 10102300


UPDATE application_functions
SET    document_path = 'Administration/Setup/Setup Emissions Source-Sink Type.htm'
WHERE  function_id = 10102310

UPDATE application_functions
SET    document_path = 'Administration/Setup/Setup Contract Price.htm'
WHERE  function_id = 10104400

UPDATE application_functions
SET    document_path = 'Administration/Setup/Setup Contract Price.htm'
WHERE  function_id = 10104410

UPDATE application_functions
SET    document_path = 'Administration/Setup/Setup Contract Component Mapping.htm'
WHERE  function_id = 10104300

UPDATE application_functions
SET    document_path = 'Administration/Setup/Setup Contract Component Mapping.htm'
WHERE  function_id = 10104310

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Static Data.htm'
WHERE  function_id = 15130100

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Static Data.htm'
WHERE  function_id = 15190100

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Static Data.htm'
WHERE  function_id = 10101034

UPDATE application_functions
SET    document_path = 'Administration/Setup/Maintain Static Data.htm'
WHERE  function_id = 10101035

UPDATE application_functions SET    document_path = 'Administration/Setup/Generic Mapping.htm' WHERE  function_id = 13102000
UPDATE application_functions SET    document_path = 'Administration/Setup/Generic Mapping.htm' WHERE  function_id = 13102010
UPDATE application_functions SET    document_path = 'Administration/Setup/Maintain Source Generator.htm' WHERE  function_id = 10103810
UPDATE application_functions SET    document_path = 'Administration/Setup/Maintain Settlement Netting Group.htm' WHERE  function_id = 10104600
UPDATE application_functions SET    document_path = 'Administration/Setup/Maintain Settlement Netting Group.htm' WHERE  function_id = 10104610
UPDATE application_functions SET    document_path = 'Administration/Setup/Maintain Settlement Netting Group.htm' WHERE  function_id = 10104612



UPDATE application_functions SET    document_path = 'Administration/Setup/Data Import-Export.htm' WHERE  function_id = 10104800
UPDATE application_functions SET    document_path = 'Administration/Setup/Data Import-Export.htm' WHERE  function_id = 10104813
UPDATE application_functions SET    document_path = 'Administration/Setup/Data Import-Export.htm' WHERE  function_id = 10104810
UPDATE application_functions SET    document_path = 'Administration/Setup/Data Import-Export.htm' WHERE  function_id = 10104814
UPDATE application_functions SET    document_path = 'Administration/Setup/Data Import-Export.htm' WHERE  function_id = 10104815
UPDATE application_functions SET    document_path = 'Administration/Setup/Data Import-Export.htm' WHERE  function_id = 10104817
UPDATE application_functions SET    document_path = 'Administration/Setup/Data Import-Export.htm' WHERE  function_id = 10104818
UPDATE application_functions SET    document_path = 'Administration/Setup/Data Import-Export.htm' WHERE  function_id = 10104816
UPDATE application_functions SET    document_path = 'Administration/Setup/Data Import-Export.htm' WHERE  function_id = 10104819

UPDATE application_functions SET    document_path = 'Administration/Setup/Lock As of Date.htm' WHERE  function_id = 10104610




--Users and Roles
update application_functions set document_path = 'Administration/Users and Roles/Maintain Roles.htm' where function_id =10111100
update application_functions set document_path = 'Administration/Users and Roles/Maintain Users.htm' where function_id =10111000
update application_functions set document_path = 'Administration/Users and Roles/Maintain Work Flow.htm' where function_id =10111200
update application_functions set document_path = 'Administration/Users and Roles/Run Privilege Report.htm' where function_id =10111300
update application_functions set document_path = 'Administration/Users and Roles/Run System Access Log Report.htm' where function_id =10111400
update application_functions set document_path = 'Administration/Users and Roles/Maintain Reports.htm' where function_id =10111500
update application_functions set document_path = 'Administration/Users and Roles/Maintain Reports.htm' where function_id =10111510
update application_functions set document_path = 'Administration/Users and Roles/Maintain Reports.htm' where function_id =10111511

--Compliance Management
update application_functions set document_path = 'Administration/Compliance Management/Approve Compliance Activities.htm' where function_id =10121100
update application_functions set document_path = 'Administration/Compliance Management/Perform Compliance Activities.htm' where function_id =10121200
update application_functions set document_path = 'Administration/Compliance Management/Maintain Compliance Standards.htm' where function_id = 10121300
update application_functions set document_path = 'Administration/Compliance Management/Maintain Compliance Standards.htm' where function_id = 10121310
update application_functions set document_path = 'Administration/Compliance Management/Maintain Compliance Standards.htm' where function_id = 10121312
update application_functions set document_path = 'Administration/Compliance Management/Maintain Compliance Standards.htm' where function_id = 10121314
update application_functions set document_path = 'Administration/Compliance Management/Maintain Compliance Standards.htm' where function_id = 10121313
update application_functions set document_path = 'Administration/Compliance Management/Maintain Compliance Standards.htm' where function_id = 10121323

update application_functions set document_path = 'Administration/Compliance Management/Maintain Compliance Groups.htm' where function_id = 10121000
update application_functions set document_path = 'Administration/Compliance Management/Maintain Compliance Groups.htm' where function_id = 10121010
update application_functions set document_path = 'Administration/Compliance Management/Maintain Compliance Groups.htm' where function_id = 10121012
update application_functions set document_path = 'Administration/Compliance Management/Change Owners.htm' where function_id = 10121500
update application_functions set document_path = 'Administration/Compliance Management/Activity Process Map.htm' where function_id = 10121400
update application_functions set document_path = 'Administration/Compliance Management/Reports/View Compliance Activities.htm' where function_id = 10121600
update application_functions set document_path = 'Administration/Compliance Management/Reports/View Status On Compliance Activities.htm' where function_id =10121700
update application_functions set document_path = 'Administration/Compliance Management/Reports/Run Compliance Activity Audit Report.htm' where function_id = 10121800
update application_functions set document_path = 'Administration/Compliance Management/Reports/View Compliance Calendar.htm' where function_id = 10122200
update application_functions set document_path = 'Administration/Compliance Management/Reports/Run Compliance Trend Report.htm' where function_id = 10121900
update application_functions set document_path = 'Administration/Compliance Management/Reports/Run Compliance Graph Report.htm' where function_id = 10122000
update application_functions set document_path = 'Administration/Compliance Management/Reports/Run Compliance Status Graph Report.htm' where function_id = 10122100 
update application_functions set document_path = 'Administration/Compliance Management/Reports/Run Compliance Due Date Voilation Report.htm' where function_id = 10122400
update application_functions set document_path = 'Administration/Compliance Management/Maintain Alerts.htm' where function_id = 10122500
update application_functions set document_path = 'Administration/Compliance Management/Maintain Alerts.htm' where function_id = 10122510
update application_functions set document_path = 'Administration/Compliance Management/Maintain Alerts.htm' where function_id = 10122518
update application_functions set document_path = 'Administration/Compliance Management/Maintain Alerts.htm' where function_id = 10122519
update application_functions set document_path = 'Administration/Compliance Management/Maintain Alerts.htm' where function_id = 10122501
update application_functions set document_path = 'Administration/Compliance Management/Maintain Alerts.htm' where function_id = 10122503
update application_functions set document_path = 'Administration/Compliance Management/Maintain Alerts.htm' where function_id = 10122517
update application_functions set document_path = 'Administration/Compliance Management/Maintain Alerts.htm' where function_id = 10122504
update application_functions set document_path = 'Administration/Compliance Management/Maintain Alerts.htm' where function_id = 10122505
update application_functions set document_path = 'Administration/Compliance Management/Maintain Alerts.htm' where function_id = 10122506
update application_functions set document_path = 'Administration/Compliance Management/Maintain Alerts.htm' where function_id = 10122514
update application_functions set document_path = 'Administration/Compliance Management/Maintain Alerts.htm' where function_id = 10122512

update application_functions set document_path = 'Common/Maintain Compliance Activities.htm' where function_id = 10121014
update application_functions set document_path = 'Common/Maintain Compliance Activities.htm' where function_id = 10121015
update application_functions set document_path = 'Common/Maintain Compliance Activities.htm' where function_id = 10121017
update application_functions set document_path = 'Common/Maintain Compliance Activities.htm' where function_id = 10121018
update application_functions set document_path = 'Common/Maintain Compliance Activities.htm' where function_id = 10121020
update application_functions set document_path = 'Common/Maintain Compliance Activities.htm' where function_id = 10121022

UPDATE application_functions
SET    document_path = 'Administration/Compliance Management/Activity Process Map.htm'
WHERE  function_id = 10121416

UPDATE application_functions
SET    document_path = 'Common/Maintain Compliance Activities.htm'
WHERE  function_id = 10121417

UPDATE application_functions
SET    document_path = 'Administration/Compliance Management/Activity Process Map.htm'
WHERE  function_id = 10121412

UPDATE application_functions
SET    document_path = 'Administration/Compliance Management/Activity Process Map.htm'
WHERE  function_id = 10121418


-- Child
update application_functions set document_path = 'Administration/Setup/Maintain Static Data.htm' where function_id =10101010
update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101130
update application_functions set document_path = 'Administration/Setup/Setup Book Structure.htm' where function_id =10101210
update application_functions set document_path = 'Administration/Setup/Setup Book Structure.htm' where function_id =10101213
update application_functions set document_path = 'Administration/Setup/Setup Book Structure.htm' where function_id =10101215
update application_functions set document_path = 'Administration/Setup/Setup Book Structure.htm' where function_id =10101216
update application_functions set document_path = 'Administration/Setup/Setup Book Structure.htm' where function_id =10101217
update application_functions set document_path = 'Administration/Setup/Setup Book Structure.htm' where function_id =10101212

update application_functions set document_path ='Administration/Setup/Maintain Deal Template.htm' where function_id=10101410
update application_functions set document_path ='Administration/Setup/Maintain Deal Template.htm' where function_id=10101414

update application_functions set document_path ='Administration/Setup/Define Meter ID.htm' where function_id=10221510
update application_functions set document_path ='Administration/Setup/Define Meter ID.htm' where function_id=10221512
update application_functions set document_path ='Administration/Setup/Define Meter ID.htm' where function_id=10221517
update application_functions set document_path ='Administration/Setup/Define Meter ID.htm' where function_id=10221513
update application_functions set document_path ='Administration/Setup/Define Contract Components GL Codes.htm' where function_id= 10231310
update application_functions set document_path ='Administration/Setup/Define Contract Components GL Codes.htm' where function_id= 10231312
update application_functions set document_path ='Administration/Setup/Setup Default GL Code for Contract Components.htm' where function_id=10231410
update application_functions set document_path ='Administration/Users and Roles/Maintain Users.htm' WHERE function_id=10111010
update application_functions set document_path ='Administration/Users and Roles/Maintain Users.htm' WHERE function_id=10111014
update application_functions set document_path ='Administration/Users and Roles/Maintain Users.htm' WHERE function_id=10111110
update application_functions set document_path ='Administration/Users and Roles/Maintain Users.htm' WHERE function_id=10111013
update application_functions set document_path ='Administration/Users and Roles/Maintain Roles.htm' WHERE function_id=10111112
update application_functions set document_path ='Administration/Users and Roles/Maintain Roles.htm' WHERE function_id=10111111
update application_functions set document_path ='Administration/Users and Roles/Maintain Roles.htm' WHERE function_id=10111113
update application_functions set document_path ='Administration/Users and Roles/Maintain Work Flow.htm' where function_id=10111210
update application_functions set document_path ='Administration/Users and Roles/Maintain Work Flow.htm' where function_id=10111211
update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101131
update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101133
update application_functions set document_path ='Administration/Setup/Maintain UDF Template.htm' where function_id = 10101412
update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101143
update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101136
update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101137
update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101139
update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101142
update application_functions set document_path = 'Administration/Setup/Maintain Netting Asset-Liab Groups.htm' where function_id =10101510
update application_functions set document_path = 'Administration/Setup/Maintain Netting Asset-Liab Groups.htm' where function_id =10101512
update application_functions set document_path = 'Administration/Setup/Maintain Netting Asset-Liab Groups.htm' where function_id =10101514
update application_functions set document_path = 'Administration/Setup/Maintain Source Generator.htm' where function_id =10161510
update application_functions set document_path = 'Administration/Setup/setup emission source sink types.htm' where function_id =12101010
update application_functions set document_path = 'Administration/Setup/configure interface timeout parameter.htm' where function_id=10101800
update application_functions set document_path = 'Administration/Setup/configure interface timeout parameter.htm' where function_id=10101700
update application_functions set document_path = 'Administration/Setup/Setup User Defined Fields.htm' where function_id = 10104700
update application_functions set document_path = 'Administration/Setup/Setup User Defined Fields.htm' where function_id = 10104712
------------------------------- Module Administration End---------------------------------------------------------------------------------------------------



------------------------------- Module Back Office Start ----------------------------------------------------------------
--Accounting
--Accrual
update application_functions set document_path = 'Back Office/Accounting/Accrual/Run Journal Entry Report.htm' where function_id =10235400
update application_functions set document_path = 'Back Office/Accounting/Accrual/run EQR report.html' where function_id =10231800
update application_functions set document_path = 'Back Office/Accounting/Accrual/run revenue report.html' where function_id =10231600
update application_functions set document_path = 'Back Office/Accounting/Accrual/curve value report.htm' where function_id =10231500

--Derivative/Deal Capture
update application_functions set document_path = 'Back Office/Accounting/Derivative/Deal Capture/Run Import Audit Report.htm' where function_id =10232800
--update application_functions set document_path = 'Back Office/Accounting/Derivative/Deal Capture/import data.htm' where function_id =10131300

--Derivative/Accounting Strategy
update application_functions set document_path = 'Back Office/Accounting/Derivative/Accouting Strategy/Manage Documents.htm' where function_id =10232200
update application_functions set document_path = 'Back Office/Accounting/Derivative/Accouting Strategy/Run Setup hedging Relationship type report.htm' where function_id =10233900
update application_functions set document_path = 'Back Office/Accounting/Derivative/Accouting Strategy/Setup Hedging Relationship Types.htm' where function_id =10232000

--Derivative/Hedge Effectiveness Test
update application_functions set document_path = 'Back Office/Accounting/Derivative/Hedge Effectiveness Test/Run Assessment.htm' where function_id =10232300
update application_functions set document_path = 'Back Office/Accounting/Derivative/Hedge Effectiveness Test/Run Assessment Trend Graph.htm' where function_id =10232500
update application_functions set document_path = 'Back Office/Accounting/Derivative/Hedge Effectiveness Test/Run What-If Effective Analysis.htm' where function_id =10232600
update application_functions set document_path = 'Back Office/Accounting/Derivative/Hedge Effectiveness Test/View Assessment Result.htm' where function_id =10232400

--Derivative/Ongoing Assessment
update application_functions set document_path = 'Back Office/Accounting/Derivative/Ongoing Assessment/Close Accounting Period.htm' where function_id =10233600
update application_functions set document_path = 'Back Office/Accounting/Derivative/Ongoing Assessment/Measurement Report.htm' where function_id =10234900
--update application_functions set document_path = 'Back Office/Accounting/Derivative/Ongoing Assessment/Run MTM.htm' where function_id =10181000
update application_functions set document_path = 'Back Office/Accounting/Derivative/Ongoing Assessment/Run What If Measurement Analysis.htm' where function_id =10233200

--Derivative/Reporting
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/AOCI Report.htm' where function_id =10235200
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Report Writer.htm' where function_id =10201000
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run Assessment Report.htm' where function_id =10235800
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run De-designation Values Report.htm' where function_id =10235300
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run Measurement.htm' where function_id =10233400
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run Masurement Trend Graph.htm' where function_id =10235000
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run Netted Journal Entry report.htm' where function_id =10235500
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run Period Change Values Report.htm' where function_id =10235100

--Derivative/Reporting/Run Exception Report
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run Exception Report/Create Hedge Item Matching Report.htm' where function_id =10236700
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run Exception Report/Run Available Hedge Capacity Exception Report.htm' where function_id =10236400
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run Exception Report/Run Fail Assessment Values Report.htm' where function_id =10236200
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run Exception Report/Run Missing Assessment Values Report.htm' where function_id =10236100
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run Exception Report/Run Not Mapped Deal Report.htm' where function_id =10236500
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run Exception Report/Run Tagging Audit Report.htm' where function_id =10236600
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run Exception Report/Run Unapproved Hedge Relationship Exception Report.htm' where function_id =10236300

--Derivative/Reporting/Run Disclosure Report
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run Disclosure Report/Run Accounting Disclosure Report.htm' where function_id =10235600
update application_functions set document_path = 'Back Office/Accounting/Derivative/Reporting/Run Disclosure Report/Run Fair Value Disclosure Report.htm' where function_id =10235700



--Derivative/Tansaction Processing
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/Automate Matching of Hedges.htm' where function_id =10234400
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/Automation of Forcasted Transaction.htm' where function_id =10234300
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/Bifurcation of Embedded Derivative.htm' where function_id =10234800
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/De-designation of a Hedge by FIFO LIFO.htm' where function_id =10233800
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/Designation of a Hedge.htm' where function_id =10233700
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/First Day Gain Loss Treatment-Derivative.htm' where function_id =10234600
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/hedge relationship report.htm' where function_id =10233900
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/Life Cycle of Hedges.htm' where function_id =10234200
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/Maintain Transactions Tagging.htm' where function_id =10238000
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/reclassify a hedge de-designation01.htm' where function_id =10234000
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/View Outstanding Automation Results.htm' where function_id =10234500

update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/Amortize Locked AOCI.htm' where function_id =10234100

--Inventory
update application_functions set document_path = 'Back Office/Accounting/Inventory/Maintain Inventory GL Account.htm' where function_id =10231000
update application_functions set document_path = 'Back Office/Accounting/Inventory/Maintain Inventory GL Account.htm' where function_id =10231010
update application_functions set document_path = 'Back Office/Accounting/Inventory/Maintain Inventory GL Account.htm' where function_id =10231012
update application_functions set document_path = 'Back Office/Accounting/Accrual/Run Accrual Journal Entry Report.htm' where function_id =10231100
update application_functions set document_path = 'Back Office/Accounting/Inventory/Run Wght Avg Inventory Cost Report.htm' where function_id =10231200
update application_functions set document_path = 'Back Office/Accounting/Inventory/Maintain Inventory GL Account.htm' where function_id =10231010
update application_functions set document_path = 'Back Office/Accounting/Inventory/Run Roll Forward Inventory Report.htm' where function_id =10236900
update application_functions set document_path = 'Back Office/Accounting/Inventory/Maintain Manual Journal Entries.htm' where function_id =10237000
update application_functions set document_path = 'Back Office/Accounting/Inventory/Maintain Manual Journal Entries.htm' where function_id =10237010
update application_functions set document_path = 'Back Office/Accounting/Inventory/Maintain Manual Journal Entries.htm' where function_id =10237012

update application_functions set document_path = 'Back Office/Accounting/Inventory/Maintain Inventory Cost Override.htm' where function_id =10237100


--Contract Administration
update application_functions set document_path = 'Back Office/Contract Administration/Maintain Settlement Rules.htm' where function_id =10211000
update application_functions set document_path = 'Back Office/Contract Administration/Contract Component Templates.htm' where function_id = 10211100
update application_functions set document_path = 'Back Office/Contract Administration/Contract Component Templates.htm' where function_id = 10211110
update application_functions set document_path = 'Back Office/Contract Administration/Contract Component Templates.htm' where function_id = 10211112
update application_functions set document_path = 'Back Office/Contract Administration/Maintain Contract.htm' where function_id = 10211200
update application_functions set document_path = 'Back Office/Contract Administration/Maintain Contract.htm' where function_id = 10211210

update application_functions set document_path = 'Common/Nested Formula.htm' where function_id =10211015
update application_functions set document_path = 'Common/Nested Formula.htm' where function_id =10211016

UPDATE application_functions
SET    document_path ='Common/Formula Editor.htm'
WHERE  function_id = 10211018

UPDATE application_functions
SET    document_path ='Back Office/Contract Administration/Contract Component Templates.htm'
WHERE  function_id = 10211110

UPDATE application_functions SET    document_path ='Back Office/Contract Administration/Maintain Settlement Rules.htm' WHERE  function_id = 10211013



--Settlement and Billing
update application_functions set document_path = 'Back Office/Settlement and Billing/Run Contract Settlement.htm' where function_id =10221000
update application_functions set document_path = 'Back Office/Settlement and Billing/Run Contract Settlement.htm' where function_id =10221316
update application_functions set document_path = 'Back Office/Settlement and Billing/Run Settlement Report.htm' where function_id =10182100
update application_functions set document_path = 'Back Office/Settlement and Billing/Settlement Calculation History.htm' where function_id =10221300
update application_functions set document_path = 'Back Office/Settlement and Billing/Settlement Calculation History.htm' where function_id =10221311
update application_functions set document_path = 'Back Office/Settlement and Billing/Run Settlement Production report.htm' where function_id =10221800
update application_functions set document_path = 'Back Office/Settlement and Billing/Settlement Adjustments.htm' where function_id=10221600
update application_functions set document_path = 'Back Office/Settlement and Billing/Run Deal Settlement.htm' where function_id=10222300
update application_functions set document_path = 'Back Office/Settlement and Billing/Run Settlement Report.htm' where function_id=10221900
update application_functions set document_path = 'Back Office/Settlement and Billing/Run Meter Data Report.htm' where function_id=10222400
update application_functions set document_path = 'Back Office/Settlement and Billing/Run Contract Settlement Report.htm' where function_id=10221200
update application_functions set document_path = 'Back Office/Settlement and Billing/Run Contract Settlement.htm' where function_id =10221312
update application_functions set document_path = 'Back Office/Settlement and Billing/SAP Settlement Export.htm' where function_id =10222000
update application_functions set document_path = 'Back Office/Settlement and Billing/Post JE Report.htm' where function_id =10221400
update application_functions set document_path = 'Back Office/Settlement and Billing/Send Invoice-Remittance.htm' where function_id = 10222500
update application_functions set document_path = 'Back Office/Settlement and Billing/Market Variance Report.htm' where function_id = 10221700
update application_functions set document_path = 'Back Office/Settlement and Billing/SAP Settlement Export.htm' where function_id = 10222010
update application_functions set document_path = 'Back Office/Settlement and Billing/Send Invoice-Remittance.htm' where function_id = 10222500

--Treasury
update application_functions set document_path = 'Back Office/Treasury/Reconcile Cash Entries for Derivatives.htm' where function_id =10241000
update application_functions set document_path = 'Back Office/Treasury/Apply Cash.htm' where function_id =10241100



--Child
update application_functions set document_path = 'Back Office/Settlement and Billing/Run Contract Settlement.htm' where function_id =10221312
update application_functions set document_path = 'Back Office/Contract Administration/Maintain Settlement Rules.htm' where function_id =10211010

----update application_functions set document_path = 'Back Office/Settlement and Billing/Run Contract Settlement.htm' where function_id =10221010
--update application_functions set document_path = 'Back Office/Settlement and Billing/Run Contract Settlement.htm' where function_id =10221011
--update application_functions set document_path = 'Back Office/Settlement and Billing/Run Contract Settlement.htm' where function_id =10221019
--update application_functions set document_path = 'Back Office/Settlement and Billing/Run Contract Settlement.htm' where function_id =10221013
--update application_functions set document_path = 'Back Office/Settlement and Billing/Run Contract Settlement.htm' where function_id =10221014
--update application_functions set document_path = 'Back Office/Settlement and Billing/Run Contract Settlement.htm' where function_id =10221018

update application_functions set document_path = 'Back Office/Accounting/Inventory/Run Inventory Calc.htm' where function_id =10221100
update application_functions set document_path = 'Back Office/Accounting/Derivative/Accouting Strategy/Manage Documents.htm' where function_id =10232210
update application_functions set document_path = 'Back Office/Accounting/Derivative/Accouting Strategy/Manage Documents.htm' where function_id =10232212
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/Designation of a Hedge.htm' where function_id =10233710
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/Designation of a Hedge.htm' where function_id =10233711
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/Designation of a Hedge.htm' where function_id =10233715
update application_functions set document_path = 'Back Office/Accounting/Derivative/Tansaction Processing/Designation of a Hedge.htm' where function_id =10233713
update application_functions set document_path = 'Back Office/Accounting/Derivative/Hedge Effectiveness Test/Run What-If Effective Analysis.htm' where function_id =10232610
update application_functions set document_path = 'Back Office/Contract Administration/Maintain Transportation Contract.htm' where function_id = 10162700
update application_functions set document_path = 'Back Office/Contract Administration/Maintain Transportation Contract.htm' where function_id = 10162710


-- Invoice Reconciliation 10221000 
update application_functions set document_path = 'Common/Invoice Reconciliation.htm' where function_id =10221010
update application_functions set document_path = 'Common/Invoice Reconciliation.htm' where function_id =10221011
update application_functions set document_path = 'Common/Invoice Reconciliation.htm' where function_id =10221013
update application_functions set document_path = 'Common/Invoice Reconciliation.htm' where function_id =10221014
update application_functions set document_path = 'Common/Invoice Reconciliation.htm' where function_id =10221016
update application_functions set document_path = 'Common/Invoice Reconciliation.htm' where function_id =10221018
update application_functions set document_path = 'Common/Invoice Reconciliation.htm' where function_id =10221019
update application_functions set document_path = 'Common/Invoice Reconciliation.htm' where function_id =10221020
update application_functions set document_path = 'Common/Invoice Reconciliation.htm' where function_id =10221023

------------------------------- Module Back Office End ------------------------------------------------------------------------------------



------------------------------- Module Enviromental Inventory Start -------------------------------------------------------------------------------------

--Environmental Inventory

--Renewable Source
UPDATE application_functions
SET    document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Multiple Source Sink Unit Map.htm'
WHERE  function_id = 12101200

UPDATE application_functions
SET    document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Multiple Source Sink Unit Map.htm'
WHERE  function_id = 12101210

UPDATE application_functions
SET    document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain REC Assignment Priority.htm'
WHERE  function_id = 12103200

UPDATE application_functions
SET    document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain REC Assignment Priority.htm'
WHERE  function_id = 12103210

UPDATE application_functions
SET    document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain REC Assignment Priority.htm'
WHERE  function_id = 12103212

UPDATE application_functions
SET    document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain REC Assignment Priority.htm'
WHERE  function_id = 12103214

--Allowance Credit Assignment

update application_functions set document_path = 'Environmental Inventory/Allowance Credit Assignment/Assign transactions.htm' where function_id =12121300
update application_functions set document_path = 'Environmental Inventory/Allowance Credit Assignment/Assign transactions.htm' where function_id =12121311

update application_functions set document_path = 'Environmental Inventory/Allowance Credit Assignment/Lifecycle of Transactions.htm' where function_id =12121500
update application_functions set document_path = 'Environmental Inventory/Allowance Credit Assignment/Maintain Emissions Profile Credit Requirements.htm' where function_id =12121000
update application_functions set document_path = 'Environmental Inventory/Allowance Credit Assignment/UnAssign transactions.htm' where function_id =12121400
update application_functions set document_path = 'Environmental Inventory/Allowance Credit Assignment/Maintain Target Emissions.htm' where function_id =12121100
update application_functions set document_path = 'Environmental Inventory/Allowance Credit Assignment/Finalize Committed REC.htm' where function_id =12121600
--Inventory and Compliance Reporting
update application_functions set document_path = 'Environmental Inventory/Inventory and Compliance Reporting/Run Allowance Reconciliation Report.htm' where function_id =12131700
update application_functions set document_path = 'Environmental Inventory/Inventory and Compliance Reporting/Run Exposure Report.htm' where function_id =12131400
update application_functions set document_path = 'Environmental Inventory/Inventory and Compliance Reporting/Run Generator Info Report.htm' where function_id =12132000 
update application_functions set document_path = 'Environmental Inventory/Inventory and Compliance Reporting/Run Market Value Report.htm' where function_id =12131500
update application_functions set document_path = 'Environmental Inventory/Inventory and Compliance Reporting/Run Inventory Position Report.htm' where function_id =12131100
update application_functions set document_path = 'Environmental Inventory/Inventory and Compliance Reporting/run target report.htm' where function_id =12131000
update application_functions set document_path = 'Environmental Inventory/Inventory and Compliance Reporting/Run Transactions Report.htm' where function_id =12131200
update application_functions set document_path = 'Environmental Inventory/Inventory and Compliance Reporting/Purchase Power Renewable Report.htm' where function_id =12132200
update application_functions set document_path = 'Environmental Inventory/Inventory and Compliance Reporting/Run REC Production Report.htm' where function_id =12131800
update application_functions set document_path = 'Environmental Inventory/Inventory and Compliance Reporting/Run Compliance Report.htm' where function_id =12131300
update application_functions set document_path = 'Environmental Inventory/Inventory and Compliance Reporting/Run Gen Credit Source Allocation Report.htm' where function_id =12132100
update application_functions set document_path = 'Environmental Inventory/Inventory and Compliance Reporting/Run Generator Report.htm' where function_id =12131900
update application_functions set document_path = 'Environmental Inventory/Inventory and Compliance Reporting/Allowance Transfer Form.htm' where function_id =12131600


--Models and Activity
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Emissions Sources Sinks Detail.htm' where function_id =12101600
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Emissions Sources Sinks.htm' where function_id =12101500
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Renewable Sources.htm' where function_id =12101700
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Define Emissions Source Model.htm' where function_id =12101400
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Input Characteristics.htm' where function_id =12101100
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Input Output.htm' where function_id =12101313
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Decaying Factor.htm' where function_id =12101900
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Input Output.htm' where function_id =12101300
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Setup User Defined Source Sink Group.htm' where function_id =12101800
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Emission Input Output Data.htm' where function_id =12112100
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Emission Input Output Data.htm' where function_id =12102000
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Emissions Sources Sinks Detail.htm' where function_id =12101512
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Renewable Sources.htm' where function_id =12101517
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Emissions Sources Sinks Detail.htm' where function_id =12101616
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Emissions Sources Sinks.htm' where function_id =12101516


--Inventory and Reductions
update application_functions set document_path = 'Environmental Inventory/Inventory and Reductions/Benchmark Emissions input output data.htm' where function_id =12111500
update application_functions set document_path = 'Environmental Inventory/Inventory and Reductions/control chart.htm' where function_id =12111600
update application_functions set document_path = 'Environmental Inventory/Inventory and Reductions/exp ems inv reduction data.htm' where function_id =12111200
update application_functions set document_path = 'Environmental Inventory/Inventory and Reductions/Run Emission Inventory Calc.htm' where function_id =12111000
update application_functions set document_path = 'Environmental Inventory/Inventory and Reductions/Run Emissions Tracking report.htm' where function_id =12111400
update application_functions set document_path = 'Environmental Inventory/Inventory and Reductions/run ems inv report.htm' where function_id =12111300
update application_functions set document_path = 'Environmental Inventory/Inventory and Reductions/Archive Data.htm' where function_id =12112100

--Child
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Emission Input Output Data.htm' where function_id =12101510
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Renewable Sources.htm' where function_id =12101710
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Renewable Sources.htm' where function_id =12101720
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Renewable Sources.htm' where function_id =12101721
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Emissions Sources Sinks.htm' where function_id =12101511
update application_functions set document_path = 'Environmental Inventory/Allowance Credit Assignment/Reconcile Certificates.htm' where function_id =12121211
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Input Characteristics.htm' where function_id =12101110
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Input Characteristics.htm' where function_id =12101112
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Input Output.htm' where function_id =12101310
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Input Output.htm' where function_id =12101312
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Input Output.htm' where function_id =12101315
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Define Emissions Source Model.htm' where function_id =12101410
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Define Emissions Source Model.htm' where function_id =12101411
update application_functions set document_path = 'Common/Define Emission Types.htm' where function_id =12101413
update application_functions set document_path = 'Common/Define Emission Types.htm' where function_id =12101415
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Emissions Sources Sinks Detail.htm' where function_id =12101610
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Emissions Sources Sinks Detail.htm' where function_id =12101513
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Decaying Factor.htm' where function_id =12101910
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Emission Input Output Data.htm' where function_id =12102015
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Emission Input Output Data.htm' where function_id =12102010
update application_functions set document_path = 'Environmental Inventory/Allowance Credit Assignment/Maintain Emissions Profile Credit Requirements.htm' where function_id =12121010
update application_functions set document_path = 'Environmental Inventory/Allowance Credit Assignment/Maintain Target Emissions.htm' where function_id =12121110
update application_functions set document_path = 'Environmental Inventory/Allowance Credit Assignment/reconcile recs with gis.htm' where function_id =12121200
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Emissions Sources Sinks Detail.htm' where function_id =12101612
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Setup User Defined Source Sink Group.htm' where function_id =12101810
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Input Activity Data.htm' where function_id =12102100
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Setup Wizard.htm' where function_id =12102200
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Setup Wizard.htm' where function_id =12102210
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Setup Wizard.htm' where function_id =12102211

update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Reports/Run Source Sink Info Report.htm' where function_id =12102300
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Reports/Run Exceptions Report.htm' where function_id =12102400
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Reports/Emissions Source Model Report.htm' where function_id =12102500
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Emissions Vendor Setup Wizard/Maintain Company Type.htm' where function_id =12102600
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Emissions Vendor Setup Wizard/Maintain Company Type.htm' where function_id =12102610
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Emissions Vendor Setup Wizard/Maintain Source Sink Category.htm' where function_id =12102700
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Emissions Vendor Setup Wizard/Maintain Company Type Template.htm' where function_id =12103000
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Emissions Vendor Setup Wizard/Maintain Company Type Template.htm' where function_id =12103010
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Emissions Vendor Setup Wizard/Maintain Company Type Template.htm' where function_id =12103012
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Emissions Vendor Setup Wizard/Company Type Source Model.htm' where function_id =12102800
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Emissions Vendor Setup Wizard/Company Source Sink Template.htm' where function_id =12102900
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Emissions Vendor Setup Wizard/Company Source Sink Template.htm' where function_id =12102910
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Limits.htm' where function_id =12103100
update application_functions set document_path = 'Environmental Inventory/Renewable Sources_Models and Activity/Maintain Limits.htm' where function_id =12103110

------------------------------- Module Enviromental Inventory End ----------------------------------------------------------------------------------------------------

------------------------------- Module Front Office Start-------------------------------------------------------------------------------------
--Front Office--Deal Capture

update application_functions set document_path = 'Front Office/Deal Capture/Import Data.htm' where function_id =10131300
update application_functions set document_path = 'Front Office/Deal Capture/Import EPA Allowance Data.htm' where function_id =10232700
update application_functions set document_path = 'Front Office/Deal Capture/Maintain Environmental Transactions.htm' where function_id =10131200
update application_functions set document_path = 'Front Office/Deal Capture/maintain transaction Blotter.htm' where function_id =10131100
update application_functions set document_path = 'Front Office/Deal Capture/Maintain Transactions.htm' where function_id =10131000
update application_functions set document_path = 'Front Office/Deal Capture/Transfer Book Position.htm' where function_id =10131600
update application_functions set document_path = 'Front Office/Deal Capture/Maintain Transactions.htm' where function_id =10234710
update application_functions set document_path = 'Front Office/Deal Capture/Maintain Transactions.htm' where function_id =10131019
update application_functions set document_path = 'Front Office/Deal Capture/Maintain Environmental Transactions.htm' where function_id = 10131215
update application_functions set document_path = 'Front Office/Deal Capture/Maintain Deal Transfer.htm' where function_id =10234700

--Position Reporting
update application_functions set document_path = 'Front Office/Position Reporting/Run Options Report.htm' where function_id =10141100
update application_functions set document_path = 'Front Office/Position Reporting/Run Index Position Report.htm' where function_id =10141000
update application_functions set document_path = 'Front Office/Position Reporting/Run Transactions Report.htm' where function_id =10141400
update application_functions set document_path = 'Front Office/Position Reporting/Run Options Greeks Report.htm' where function_id =10141200
update application_functions set document_path = 'Front Office/Position Reporting/Run Hourly Position Report.htm' where function_id =10141300
update application_functions set document_path = 'Front Office/Position Reporting/Run Hourly Position Report.htm' where function_id =10141310
update application_functions set document_path = 'Front Office/Position Reporting/Run Load Forecast Report.htm' where function_id =10141900
update application_functions set document_path = 'Front Office/Position Reporting/Run FX Exposure Report.htm' where function_id =10142100
update application_functions set document_path = 'Front Office/Position Reporting/Run Position Explain Report.htm' where function_id =10142200
update application_functions set document_path = 'Front Office/Position Reporting/Run Trader Position Report.htm' where function_id =10141700
update application_functions set document_path = 'Front Office/Position Reporting/Run Power Bidding and Nomination Report.htm' where function_id =10142300
update application_functions set document_path = 'Front Office/Position Reporting/Run Power Bidding and Nomination Report.htm' where function_id =10142320

--Scheduling and delivery
update application_functions set document_path = 'Front Office/Scheduling and Delivery/Maintain Loss Factor.htm' where function_id =10161000
update application_functions set document_path = 'Front Office/Scheduling and Delivery/Maintain Loss Factor.htm' where function_id =10161010
update application_functions set document_path = 'Front Office/Scheduling and Delivery/Setup Delivery Path.htm' where function_id =10161100
update application_functions set document_path = 'Front Office/Scheduling and Delivery/Setup Delivery Path.htm' where function_id =10161110
update application_functions set document_path = 'Front Office/Scheduling and Delivery/Maintain Transportation Rate Schedule.htm' where function_id =10162000
update application_functions set document_path = 'Front Office/Scheduling and Delivery/Maintain Transportation Rate Schedule.htm' where function_id =10162010
update application_functions set document_path = 'Front Office/Scheduling and Delivery/Maintain Transportation Rate Schedule.htm' where function_id =10101152
update application_functions set document_path = 'Front Office/Scheduling and Delivery/Run Gas Position Report.htm' where function_id =10161200
update application_functions set document_path = 'Front Office/Scheduling and Delivery/Run Gas Storage Position Report.htm' where function_id =10161400
update application_functions set document_path = 'Front Office/Scheduling and Delivery/Storage Assets.htm' where function_id =10162300
update application_functions set document_path = 'Front Office/Scheduling and Delivery/Run Inventory Calc.htm' where function_id =10237200
update application_functions set document_path = 'Front Office/Scheduling and Delivery/Run Roll Forward Inventory Report.htm' where function_id =10162400
update application_functions set document_path = 'Front Office/Scheduling and Delivery/Storage Assets.htm' where function_id =10162310
update application_functions set document_path = 'Front Office/Scheduling and Delivery/View Delivery Transactions.htm' where function_id =10161300
update application_functions set document_path = 'Front Office/Scheduling and Delivery/Storage Assets.htm' where function_id =10162312
update application_functions set document_path = 'Front Office/Scheduling and Delivery/Storage Assets.htm' where function_id =10162313
update application_functions set document_path = 'Front Office/Scheduling and Delivery/Storage Assets.htm' where function_id =10162314
update application_functions set document_path = 'Front Office/Scheduling and Delivery/Pipeline Imbalance Report.htm' where function_id = 10162600
update application_functions set document_path = 'Front Office/Scheduling and Delivery/Maintain Power Outage.htm' where function_id = 10161800
update application_functions set document_path = 'Front Office/Scheduling and Delivery/Run WACOG Report.htm' where function_id = 10162100
update application_functions set document_path = 'Front Office/Scheduling and Delivery/Run PNL Report.htm' where function_id = 10162200
update application_functions set document_path = 'Front Office/Scheduling and Delivery/View Delivery Transactions.htm' where function_id = 10161312
update application_functions set document_path = 'Front Office/Scheduling and Delivery/Maintain Delivery Status Detail.htm' where function_id = 10161313
update application_functions set document_path = 'Common/Schedule and Delivery Post Detail.htm' where function_id = 10161210







--Price Curve Management
update application_functions set document_path = 'Front Office/Price Curve Management/View Prices.htm' where function_id =10151000
update application_functions set document_path = 'Front Office/Price Curve Management/View Prices.htm' where function_id =10151010
update application_functions set document_path = 'Front Office/Price Curve Management/View Prices.htm' where function_id =10151011

update application_functions set document_path = 'Front Office/Price Curve Management/Import Price.htm' where function_id =10151100

--Child Screen
update application_functions set document_path = 'Front Office/Deal Capture/Maintain Transactions.htm' where function_id =10131010
update application_functions set document_path = 'Front Office/Deal Capture/Maintain Transactions.htm' where function_id =10131026
update application_functions set document_path = 'Front Office/Deal Capture/Maintain Transactions.htm' where function_id =10131011
update application_functions set document_path = 'Front Office/Deal Capture/Maintain Transactions.htm' where function_id =10131016
update application_functions set document_path = 'Front Office/Deal Capture/Maintain Transactions.htm' where function_id =10131017
update application_functions set document_path = 'Front Office/Deal Capture/Maintain Transactions.htm' where function_id =10131025
update application_functions set document_path = 'Front Office/Deal Capture/Maintain Transactions.htm' where function_id =10131014
update application_functions set document_path = 'Front Office/Deal Capture/Maintain Transactions.htm' where function_id =10131020

update application_functions set document_path = 'Front Office/Price Curve Management/View Prices.htm' where function_id =10151010
------------------------------- Module Front Office End--------------------------------------------------------------------------------------


------------------------------- Module Middle Office Start---------------------------------------------------------------
--Middle Office
--Credit Risks and Analysis

update application_functions set document_path = 'Middle Office/Credit Risk and Analysis/Calculate Credit Exposure.htm' where function_id =10191800
update application_functions set document_path = 'Middle Office/Credit Risk and Analysis/Maintain Counterparty.htm' where function_id =10191000
update application_functions set document_path = 'Middle Office/Credit Risk and Analysis/Run Exposure Concentration Report.htm' where function_id =10191500
update application_functions set document_path = 'Middle Office/Credit Risk and Analysis/Run Credit Exposure Report.htm' where function_id =10191300
update application_functions set document_path = 'Middle Office/Credit Risk and Analysis/Run Credit Reserve Report.htm' where function_id =10191600
update application_functions set document_path = 'Middle Office/Credit Risk and Analysis/Run Fixed-MTM Exposure Report.htm' where function_id =10191400
update application_functions set document_path = 'Middle Office/Credit Risk and Analysis/Run Counterparty Credit Availability Report.htm' where function_id =10191900
update application_functions set document_path = 'Middle Office/Credit Risk and Analysis/Maintain Counterparty Limit.htm' where function_id =10192000
update application_functions set document_path = 'Middle Office/Credit Risk and Analysis/Maintain Counterparty Limit.htm' where function_id =10192010
update application_functions set document_path = 'Middle Office/Credit Risk and Analysis/Run Aged A-R Report.htm' where function_id = 10191700
update application_functions set document_path = 'Middle Office/Credit Risk and Analysis/Run Credit Value Adjustment Report.htm' where function_id = 10192300
update application_functions set document_path = 'Middle Office/Credit Risk and Analysis/Calculate Credit Value Adjustment.htm' where function_id = 10192200
update application_functions set document_path = 'Middle Office/Credit Risk and Analysis/Export Credit Data Report.htm' where function_id = 10191200
update application_functions set document_path = 'Middle Office/Credit Risk and Analysis/Import Credit Data.htm' where function_id = 10191100
--Deal Verification and Confirmation
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Confirm Transactions.htm' where function_id =10171000
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Confirm Transactions.htm' where function_id =10171013
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Confirm Transactions.htm' where function_id =10171017
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Confirm Transactions.htm' where function_id =10171018
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Update Deal Status and Confirmation.htm' where function_id =10171400
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Update Deal Status and Confirmation.htm' where function_id =10171410
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Update Deal Status and Confirmation.htm' where function_id =10171411
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Update Deal Status and Confirmation.htm' where function_id =10171412
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Update Deal Status and Confirmation.htm' where function_id =10171413
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Update Deal Status and Confirmation.htm' where function_id =10171417
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Update Deal Status and Confirmation.htm' where function_id =10171418
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Update Deal Status.htm' where function_id =10171500
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Update Deal Status.htm' where function_id =10171510
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Update Deal Status.htm' where function_id =10171511
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Update Deal Status.htm' where function_id =10171512
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Update Deal Status.htm' where function_id =10171513
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Update Deal Status.htm' where function_id =10171517
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Update Deal Status.htm' where function_id =10171518
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Lock-Unlock deal.htm' where function_id =10171200
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Run Unconfirmed Exception Report.htm' where function_id =10171300
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Transaction Audit Log Report.htm' where function_id =10171100
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Send Confirmation.htm' where function_id =10171700
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Send Confirmation.htm' where function_id =10222600

--Reporting
update application_functions set document_path = 'Middle Office/Reporting/Dashboard Report Template.htm' where function_id =12111900
update application_functions set document_path = 'Middle Office/Reporting/Report Writer.htm' where function_id =10201000
update application_functions set document_path = 'Middle Office/Reporting/Run DashBoard Report.htm' where function_id=12111800
update application_functions set document_path = 'Middle Office/Reporting/Run Import Audit Report.htm' where function_id=10201400
update application_functions set document_path = 'Middle Office/Reporting/Run Static Data Audit Report.htm' where function_id=10201500
update application_functions set document_path = 'Middle Office/Reporting/Report Writer.htm' where function_id=10201012
update application_functions set document_path = 'Middle Office/Reporting/Report Writer.htm' where function_id=10201013
update application_functions set document_path = 'Middle Office/Reporting/Report Writer.htm' where function_id=10201014
update application_functions set document_path = 'Middle Office/Reporting/Report Writer.htm' where function_id=10201015
update application_functions set document_path = 'Middle Office/Reporting/Dashboard Report Template.htm' where function_id=10201200
update application_functions set document_path = 'Middle Office/Reporting/Dashboard Report Template.htm' where function_id=10201210
update application_functions set document_path = 'Middle Office/Reporting/Dashboard Report Template.htm' where function_id=10201212
update application_functions set document_path = 'Middle Office/Reporting/Dashboard Report Template.htm' where function_id=10201214
update application_functions set document_path = 'Middle Office/Reporting/Run Dashboard Report.htm' where function_id=10201100
UPDATE application_functions SET document_path = 'Middle Office/Reporting/Run Report Group.htm' WHERE function_id = 10201700

UPDATE application_functions
SET    document_path = 'Middle Office/Reporting/Maintain EOD status log.htm'
WHERE  function_id = 10201300

UPDATE application_functions
SET    document_path = 'Middle Office/Reporting/Maintain EOD status log.htm'
WHERE  function_id = 10201311
UPDATE application_functions SET document_path = 'Middle Office/Reporting/Report Group Manager.htm' WHERE function_id = 10201800
UPDATE application_functions SET document_path = 'Middle Office/Reporting/Report Group Manager.htm' WHERE function_id = 10201810
UPDATE application_functions SET document_path = 'Middle Office/Reporting/Report Group Manager.htm' WHERE function_id = 10201812
UPDATE application_functions SET document_path = 'Middle Office/Reporting/Report Group Manager.htm' WHERE function_id = 10201814
UPDATE application_functions SET document_path = 'Middle Office/Reporting/Report Manager.htm' WHERE function_id = 10201600
UPDATE application_functions SET document_path = 'Middle Office/Reporting/Report Manager.htm' WHERE function_id = 10201615
UPDATE application_functions SET document_path = 'Middle Office/Reporting/Report Manager.htm' WHERE function_id = 10201610
UPDATE application_functions SET document_path = 'Middle Office/Reporting/Report Manager.htm' WHERE function_id = 10201628
UPDATE application_functions SET document_path = 'Middle Office/Reporting/Report Manager.htm' WHERE function_id = 10201612
UPDATE application_functions SET document_path = 'Middle Office/Reporting/Report Manager_Report Page.htm' WHERE function_id = 10201617
UPDATE application_functions SET document_path = 'Middle Office/Reporting/Report Manager_Report Page.htm' WHERE function_id = 10201629
UPDATE application_functions SET document_path = 'Middle Office/Reporting/Report Manager_Report Page.htm' WHERE function_id = 10201622
UPDATE application_functions SET document_path = 'Middle Office/Reporting/Report Manager_Report Page.htm' WHERE function_id = 10201631
UPDATE application_functions SET document_path = 'Middle Office/Reporting/Run Data Import-Export Audit Report.htm' WHERE function_id = 10201900




--Valuation and Risk Analysis
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Run MTM Process.htm' where function_id=10181000
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Run MTM Report.htm' where function_id=10181100
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/View Volatility, Correlations and Expected Return.htm' where function_id=10182000
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Maintain Monte Carlo Models.htm' where function_id=10183000
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Maintain Monte Carlo Models.htm' where function_id=10183010
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Run Monte Carlo Simulation.htm' where function_id=10183100
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Run At Risk Calculation.htm' where function_id=10181500
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Run Hedge Cashflow Deferral Report.htm' where function_id=10182900
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Maintain Portfolio Group.htm' where function_id=10183200
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Maintain What-If Criteria.htm' where function_id=10183400
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Maintain What-If Criteria.htm' where function_id=10183410
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Maintain Scenario.htm' where function_id=10183300
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Maintain Scenario.htm' where function_id=10183310
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Run What-If Analysis Report.htm' where function_id=10183500
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Run At Risk Report.htm' where function_id=10181600
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Maintain At Risk Measurement Criteria.htm' where function_id=10181200
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Maintain At Risk Measurement Criteria.htm' where function_id=10181210
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Maintain At Risk Measurement Criteria.htm' where function_id=10181211

update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Maintain Portfolio Group.htm' where function_id=10183210
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Maintain Portfolio Group.htm' where function_id=10183212
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Maintain Portfolio Group.htm' where function_id=10183213
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Maintain What-If Criteria.htm' where function_id=10183412
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Maintain What-If Criteria.htm' where function_id=10183413
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Calculate Volatility, Correlation and Expected Return.htm' where function_id=10181400
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Run MTM Report.htm' where function_id=10234910
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Maintain Limits.htm' where function_id = 10181300
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Maintain Limits.htm' where function_id = 10181310
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Run Limits Report.htm' where function_id = 10181700
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Run Implied Volatility Calculation.htm' where function_id = 10181800
update application_functions set document_path = 'Middle Office/Valuation and Risk Analysis/Run Implied Volatility Report.htm' where function_id = 10181900

UPDATE application_functions
SET    document_path = 'Middle Office/Valuation and Risk Analysis/Financial Model.htm'
WHERE  function_id = 10182300

UPDATE application_functions
SET    document_path = 'Middle Office/Valuation and Risk Analysis/Financial Model.htm'
WHERE  function_id = 10182312

UPDATE application_functions
SET    document_path = 'Middle Office/Valuation and Risk Analysis/Financial Model.htm'
WHERE  function_id = 10182310

UPDATE application_functions
SET    document_path = 'Middle Office/Valuation and Risk Analysis/Calculate Financial Model.htm'
WHERE  function_id = 10182600

UPDATE application_functions
SET    document_path = 'Middle Office/Valuation and Risk Analysis/Financial Model Report.htm'
WHERE  function_id = 10182400

UPDATE application_functions
SET    document_path = 'Middle Office/Valuation and Risk Analysis/Financial Model.htm'
WHERE  function_id = 10182314



--Credit Risks and Analysis Child
update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101115
update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101122
update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101116
update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101118
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Confirm Transactions.htm' where function_id =10171010
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Confirm Transactions.htm' where function_id =10171011
update application_functions set document_path = 'Middle Office/Deal Verification and Confirmation/Confirm Transactions.htm' where function_id =10171016
update application_functions set document_path = 'Middle Office/Reporting/Dashboard Report Template.htm' where function_id =12111910
update application_functions set document_path = 'Middle Office/Reporting/Dashboard Report Template.htm' where function_id =12111912
update application_functions set document_path = 'Middle Office/Reporting/Report Writer.htm' where function_id =10201010
------------------------------- Module Middle Office End--------------------------------------------


------------------------------- Bookmark section start --------------------------------------------
--Maintain Staic Data
--Maitain Static Data Detail
--update application_functions set document_path = 'Administration/Setup/Maintain Static Data.htm' where function_id =10121412

update application_functions set document_path = 'Administration/Setup/Maintain Static Data.htm' where function_id =10101023

update application_functions set document_path = 'Administration/Setup/Maintain Static Data.htm' where function_id =10101030

update application_functions set document_path = 'Administration/Setup/Maintain Static Data.htm' where function_id =10101012

update application_functions set document_path = 'Administration/Setup/Maintain Static Data.htm' where function_id =10101013

update application_functions set document_path = 'Administration/Setup/Maintain Static Data.htm' where function_id =10101015

update application_functions set document_path = 'Administration/Setup/Maintain Static Data.htm' where function_id =10101017 

update application_functions set document_path = 'Administration/Setup/Maintain Static Data.htm' where function_id =10101019

update application_functions set document_path = 'Administration/Setup/Maintain Static Data.htm' where function_id =10101031

update application_functions set document_path = 'Administration/Setup/Maintain Static Data.htm' where function_id =10101024  
 

--Holiday Calendar
update application_functions set document_path = 'Administration/Setup/Maintain Static Data.htm' where function_id =10101021
--Eligibilty
update application_functions set document_path = 'Administration/Setup/Maintain Static Data.htm' where function_id =12101614


--Maintain Definition
update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id = 10101110

update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101111


update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101112


update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101113


--update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101115


update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101129


update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101130

update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101135


update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101138


update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101144


update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101145

update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101149

update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101177

update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id =10101151
update application_functions set document_path = 'Administration/Setup/Maintain Definition.htm' where function_id = 10181313


------------------------------- Bookmark section End --------------------------------------------



------------------------------- Module Middle Office End---------------------------------------------------------------
