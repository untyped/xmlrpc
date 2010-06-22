#lang scheme

;; (struct)
(define-struct (exn:xmlrpc exn) () #:transparent)

;; (struct integer)
(define-struct (exn:xmlrpc:fault exn:xmlrpc) (code) #:transparent)

(define-syntax raise-exn:xmlrpc
  (syntax-rules ()
    ((_ message)
     (raise
      (make-exn:xmlrpc
       (string->immutable-string message)
       (current-continuation-marks))))))

; Provides ---------------------------------------

(provide (all-defined-out))
