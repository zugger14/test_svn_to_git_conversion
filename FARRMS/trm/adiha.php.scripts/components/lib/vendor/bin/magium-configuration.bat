@ECHO OFF
setlocal DISABLEDELAYEDEXPANSION
SET BIN_TARGET=%~dp0/../magium/configuration-manager/bin/magium-configuration
php "%BIN_TARGET%" %*
