<?php

class SubbookController extends REST {
    public function index() {
        $results = Subbook::find();
        $this->response($this->json($results), 200);
    }

    public function get($templateId) {
        $results = Subbook::findOne($templateId);
        $this->response($this->json($results[0]), 200);
    }
}
