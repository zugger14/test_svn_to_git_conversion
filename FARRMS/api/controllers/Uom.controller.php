<?php

class UomController extends REST {
    public function index() {
        $results = Uom::find();
        $this->response($this->json($results), 200);
    }

    public function get($templateId) {
        $results = Uom::findOne($templateId);
        $this->response($this->json($results[0]), 200);
    }
}
