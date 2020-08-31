<?php

class DealTemplateController extends REST {
    public function index() {
        $results = DealTemplate::find();
        $this->response($this->json($results));
    }

    public function get($templateId) {
        $results = DealTemplate::findOne($templateId);
        $this->response($this->json($results[0]), 200);
    }
    
}
