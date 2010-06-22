#lang scheme

(require (planet schematics/schemeunit:3))

(require (lib "url.ss" "net")
         (file "core.ss")
         (file "util.ss"))

(define betty (xmlrpc-server (string->url "http://betty.userland.com/RPC2")))

(define get-state-name (betty "examples.getStateName"))

(define/provide-test-suite core-tests
  
  (test-case "Round-trip call works"
    (with-timeout 
     "Round-trip times out." RPC-TIMEOUT
     (check string=? (get-state-name 40) "South Carolina"))
    (with-timeout
     "Round-trip times out." RPC-TIMEOUT
     (check string=? (get-state-name 42) "Tennessee")))
  
  (test-case "xmlrpc-server accepts host port and path"
    (let* ((betty (xmlrpc-server "betty.userland.com" 80 "RPC2"))
           (get-state-name (betty "examples.getStateName")))
      (with-timeout 
       "Server accepts host/port/path times out." RPC-TIMEOUT
       (check string=? (get-state-name 40) "South Carolina"))
      (with-timeout 
       "Server accepts host/port/path times out." RPC-TIMEOUT
       (check string=? (get-state-name 42) "Tennessee")))))
