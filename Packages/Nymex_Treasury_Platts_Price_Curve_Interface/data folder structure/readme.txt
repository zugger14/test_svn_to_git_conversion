Setup Nymex:

Do not delete this. This is the the new setup done on 29Sep2016. 


The folder structure that should be maintained for LADWP nymex platts treasury import 
 
1. The Import package must be placed in the sub folder defined in the ssis_configurations table i.e. \NymexTreasuryPlattsPriceCurve\Package\. This folder reside in FARRMS_SPTFiles folder for which
Readonly permission is enough.

2. The main data folder(\FARRMS_DataSrc\NymexTreasuryPlattsPriceCurve\Data) should have read and write permission for service account. This FARRMS_DataSrc folder must be in local folder of database server and cannot be in network shared path since the 'Batch' folder contains .bat files for running php script for nymex and treasury. 

3. The Pricecurves folder that contains the following files 
     Error     : contains error files
     Processed : contains Processed files
     Schema    : contains Schema files
     Temp      : contains file type information
     Status.txt: contains Status of each import
All these folders must have full read and write permissions for service account.
There folder are configurable from ssis_configurations table.

4. The database server requires PHP installation particularly for running Nymex and Treasury php script that downloads the required import files.