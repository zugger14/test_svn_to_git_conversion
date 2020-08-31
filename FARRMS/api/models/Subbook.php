<?php

class Subbook {
    public static function find() {
        global $app_user_name;
        $query = "EXEC spa_mobile_deal 'k', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }

    public static function findOne($sub_book_id) {
        global $app_user_name;
        $sub_book_id = (int)$sub_book_id;
        $query = "EXEC spa_mobile_deal 'k', @sub_book_id = '$sub_book_id', @runtime_user = '$app_user_name'";
        return DB::query($query);
    }
}
