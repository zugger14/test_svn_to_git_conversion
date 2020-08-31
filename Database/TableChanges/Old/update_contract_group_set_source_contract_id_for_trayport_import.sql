/*
* Trayport uses EFET contract to map for its deals. And Trayport import logic requires its source_contract_id (aplhanumeric) to be NOT NULL for its contract_group.
* This script updates the column to copy contract_name.
*/

UPDATE contract_group SET source_contract_id = contract_name WHERE contract_name = 'EFET' AND source_system_id = 2