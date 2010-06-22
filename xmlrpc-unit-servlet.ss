#lang scheme

(require web-server/sig
         unitsig
         "server-core.ss")

;; SYNTAX: handle-xmlrpc-requests
;; Expands to the servlet^ unit/sig that handles incoming 
;; XML-RPC requests. Pushes down the necessity of 
;; passing in the initial-request.
(define-syntax handle-xmlrpc-requests 
  (lambda (stx)
    (syntax-case stx ()
      [(_)
       #`(unit/sig ()
           (import servlet^)
           (handle-xmlrpc-servlet-request* initial-request))])))

; Provides ---------------------------------------

(provide (all-from-out unitsig web-server/sig)
         add-handler
         handle-xmlrpc-requests)

