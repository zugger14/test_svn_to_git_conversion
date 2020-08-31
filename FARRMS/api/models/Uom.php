<?php

class Uom {
    public static function find() {
        global $app_user_name;
        $query = "EXEC spa_mobile_deal 'o', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }

    public static function findOne($uom_id) {
        global $app_user_name;
        $uom_id = (int)$uom_id;
        $query = "EXEC spa_mobile_deal 'o', @uom = $uom_id, @runtime_user = '$app_user_name'";
        return DB::query($query);
    }
}
