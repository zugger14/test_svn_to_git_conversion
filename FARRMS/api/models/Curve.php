<?php

class Curve {
    public static function find() {
        global $app_user_name;
        $query = "EXEC spa_mobile_deal 'v', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }

    public static function findOne($curve_id) {
        global $app_user_name;
        $curve_id = (int)$curve_id;
        $query = "EXEC spa_mobile_deal 'v', @curve_id = '$curve_id', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }
}
