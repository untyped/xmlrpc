#lang scheme

(require scheme/runtime-path
         (planet untyped/autoplanet:1))

(define-runtime-path dev-path
  "planetdev")

(remove-hard-links)

; There are no dependencies on Untyped packages in this project.

; If we ever want to add any, the syntax would be:
; (install-local "owner" "unlib.plt" 3 99 (build-path dev-path "unlib"))
