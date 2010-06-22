#lang scheme

(require (planet schematics/schemeunit:3/text-ui))

(require "all-xmlrpc-tests.ss")

(print-struct #t)

(run-tests all-xmlrpc-tests)
