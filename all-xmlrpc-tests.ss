#lang scheme

(require (planet schematics/schemeunit:3))

(require "serialise-test.ss"
         "protocol-test.ss"
         "core-test.ss")

(define/provide-test-suite all-xmlrpc-tests
  serialise-tests
  protocol-tests
  core-tests
  )
