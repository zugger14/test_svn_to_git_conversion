<?php

class Contract {
    public static function find() {
        global $app_user_name;
        $query = "EXEC spa_mobile_deal 'e', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }

    public static function findOne($contract_id) {
        global $app_user_name;
        $contract_id = (int)$contract_id;
        $query = "EXEC spa_mobile_deal 'e', @contract = $contract_id, @runtime_user = '$app_user_name'";
        return DB::query($query);
    }
    
    public static function findDependentContract($deal_template_id, $counterparty_id) {
        global $app_user_name;
        $counterparty_id = (int)$counterparty_id;
        $deal_template_id = (int)$deal_template_id;
        $query = "EXEC spa_mobile_deal 'e', @deal_template_id = $deal_template_id, @counterparty_id = $counterparty_id, @runtime_user = '$app_user_name'";
        return DB::query($query);
    }
}
