<?php
/** 
* This is a sample configuration file. In order to use it, please make a copy of it and rename as 'farrms.client.config.ini.php'.
* Client specific configurations are defined in this config file.
* @copyright Pioneer Solutions
*/
# FARRMS server root directory.
$farrms_root = 'trm';

# FARRMS client root directory.
# Possible Values: trmclient | recclient | emsclient | fasclient | setclient.
# May vary as per requirement (e.g. trmclient_de).
$farrms_client_dir = 'recclient';

# Local path to the FARRMS application files.
$rootdir = 'E:\\farrms_applications\\TRMTracker_Release\\FARRMS\\';

# Server name or IP address of the database server.
# Example: DB02\INSTANCE2012
$db_servername = 'sg-d-sql02.farrms.us,2033';

# Name of the database the application uses.
# Example: TRMTracker
# In case of $CLOUD_MODE = 1, it will be adiha_cloud
$database_name = 'TRMTracker_Release';

# Type of the module.
# Possible Values: rec | ems | fas | trm | set. One of the usages of this value is to load client menu structure.
# In non-cloud mode menu structure depends on this value. Value set in connection->saas_module_type is ignored.
# In cloud mode this value is used only if saas_module_type in connection_string table of respective client database is NULL or blank. If defined then this variable is replaced by value defined in client database.
$module_type = 'rec';

# Default time zone for the application. Values are defined under column TIMEZONE_NAME_FOR_PHP in table time_zones.
# Should use application server timezone.
$DEFAULT_TIMEZONE = 'Asia/Kathmandu';

# Toggles debug mode, which displays additional debugging messages application wise (eg. F8).
# Possible Values: 0 = Debug Mode Off | 1 = Debug Mode On
# Development Value: 1
# Production Value: 0
$DEBUG_MODE = 1;


# Overwrites php.ini setting.
# Possible Values: 0 = Suppress php error | 1 = Display php error
# Development Value: 1
# Production Value: 0
$display_error = 1;

# Error reporting level. Uncommenting can flood messages, so use it with caution only for debugging purpose. Overwrite php.ini setting.
# Default Value: E_ALL & ~E_NOTICE & ~E_STRICT & ~E_DEPRECATED
# Development Value: E_ALL.
# Production Value: E_COMPILE_ERROR|E_RECOVERABLE_ERROR|E_ERROR|E_CORE_ERROR
# http://php.net/error-reporting
$error_reporting = E_ALL;

# Configures the retention period (in days) of the temporary files present in temp_Note folder in the application server.
$TEMP_FILE_RETENTION_DAYS = 7;

# Shared path for shared_docs folder, used for multiple purpose like batch report export, document/invoice upload
$SHARED_DOC_PATH = "\\\\APP01\\shared_docs_TRMTracker_Trunk"; 

/* 
To Configure Sub Book show/hide feature while loading book structure
1 = Show Sub Book in Book Structure/ Hide Sub Book Grid 
0 = Hide Sub Book in Book Structure/ Show Sub Book Grid 
*/
$SHOW_SUBBOOK_IN_BS = 1;

/*
To support data caching feature configure below variables.
1. $ENABLE_DATA_CACHING = 1 to cache data in Cache server. Default is 0. Cache server can be memcache.redis,files etc supported by phpfastcache.
2. Possible values for $CACHE_DRIVER are 'Files', 'redis', 'couchdb' etc. Any driver supported by phpfastcache. Default is 'Files'.  
3. Configure $CACHE_SERVER only if $CACHE_DRIVER is not 'Files'. Its value is hostname or IP of cache server. Default is webserver itself. 127.0.0.1
4. Configure $CACHE_PORT only if $CACHE_DRIVER is not 'Files'. Set $CACHE_PORT = 0 for default port. 11211 (default memcache port), 6379 (default redis port).
5. $CACHE_SESSION_EXPIRY Max time to live in seconds. Default is 5days ie 432000
 */
$ENABLE_DATA_CACHING = 1;
$CACHE_DRIVER = 'Files';
//$CACHE_SERVER = '127.0.0.1';
//$CACHE_PORT = 0;
//$CACHE_SESSION_EXPIRY = 432000;

/*
To configure application mode
1 = Cloud mode
0 = Normal mode
*/
$CLOUD_MODE = 0;

# To support Multi Subnet Failover - n - No - y - Yes
$SUPPORT_MULTI_SUBNET_FAILOVER = 'n';

# Primary cloud db name which contains information about all SaaS clients like contract expiry etc. 
# Should be defined in trmcloud client config file
# Note that db defined should be on same server as adiha_cloud else it can cause several errors
if (!defined('PRIMARY_CLOUD_DB')) {
	define('PRIMARY_CLOUD_DB', 'TRMTracker_Release');
}

# One Time Password (OTP) expiry time in minutes.
if (!defined('OTP_EXPIRY_TIME')) {
	define('OTP_EXPIRY_TIME', 3);
}

/* Azure Active Directory Configurations */

# Enable Magium Active Directory integration
# Possible values: 0 - Disabled
#                  1 - Enabled
$AAD_ENABLED = 0;

# Client ID after configuring application in Azure Active Directory
$AAD_CLIENT_ID = '139559b4-3783-42bd-acfb-5e0a997c436f';

# Client secret key of that application in Azure Active Directory
$AAD_CLIENT_SECRET = 'BGSBbs/2w1mAK0sTRVg:ypQFRSZK0[Z:';

# Azure Active Directory ID if using particular Azure instance
# Possible values: <common or directory ID>
#   'common'                               - Accounts in any organizational directory (Any Azure AD directory - Multitenant)
#   '26236c44-cc96-4f9a-87fd-9d18fa009a5d' - Accounts in a particular organizational directory (Single tenant)
#   ''                                     - Accounts in any organizational directory including personal Microsoft accounts (e.g. Skype, hotmail etc.)
$AAD_TENANT_ID = '26236c44-cc96-4f9a-87fd-9d18fa009a5d';

# Microsoft Graph API URI which is used to validate azure access token
$MICROSOFT_GRAPH_URI = 'https://graph.microsoft.com/v1.0/me';

?>