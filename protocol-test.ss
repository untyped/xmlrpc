#lang scheme

(require (planet schematics/schemeunit:3))

(require net/url
         "protocol.ss"
         "base.ss"
         "util.ss")

(define body-string
  "<?xml version=\"1.0\"?>
<methodCall>
    <methodName>fooBar</methodName>
    <params>
        <param>
            <value>
                <int>1</int>
            </value>
        </param>
        <param>
            <value>
                <double>2.0</double>
            </value>
        </param>
        <param>
            <value>
                <string>3</string>
            </value>
        </param>
    </params>
</methodCall>")

(define generic-headers
  "HTTP/1.1 200 OK\r\nContent-Type:text/xml\r\n\r\n")

(define fault-response-string
  "<?xml version=\"1.0\"?>
<methodResponse>
   <fault>
      <value>
         <struct>
            <member>
               <name>faultCode</name>
               <value><int>4</int></value>
               </member>
            <member>
               <name>faultString</name>
               <value><string>Too many parameters.</string></value>
               </member>
            </struct>
         </value>
      </fault>
   </methodResponse>")

(define successful-response-string
  "<?xml version=\"1.0\"?>
<methodResponse>
  <params>
    <param>
      <value><string>Hello!</string></value>
    </param>
  </params>
</methodResponse>")


(define/provide-test-suite protocol-tests
  
  (test-case "Method call encoded correctly"
    (check-equal? (encode-xmlrpc-call "fooBar" 1 2.0 "3")
                  '(methodCall
                    (methodName "fooBar")
                    (params
                     (param (value (int "1")))
                     (param (value (double "2.0")))
                     (param (value (string "3")))))))
  
  (test-case "Method call written correctly"
    (let ((op (open-output-string)))
      (write-xmlrpc-call
       (encode-xmlrpc-call "fooBar" 1 2.0 "3") op)
      (check-equal?
       (get-output-string op)
       body-string)))
  
  (test-case "Response with bad HTTP code raises exn"
    (check-exn
        exn:xmlrpc?
      (lambda ()
        (read-xmlrpc-response
         (open-input-string "HTTP/1.0 500 Dead\r\n")))))
  
  (test-case "Empty response raises exn"
    (check-exn
        exn:xmlrpc?
      (lambda ()
        (read-xmlrpc-response
         (open-input-string "")))))
  
  (test-case "Fault response is parsed correctly and raises exn"
    (let ((resp
           (read-xmlrpc-response
            (open-input-string
             (string-append generic-headers
                            fault-response-string)))))
      (check-equal?
       '(*TOP*
         (*PI* xml "version=\"1.0\"")
         (methodResponse
          (fault
           (value
            (struct
                (member (name "faultCode")
                        (value (int "4")))
              (member (name "faultString")
                      (value (string "Too many parameters."))))))))
       resp)))
  
  (test-case "Successful response is parsed correctly"
    (let ((resp
           (read-xmlrpc-response
            (open-input-string
             (string-append generic-headers
                            successful-response-string)))))
      (check-equal?
       '(*TOP*
         (*PI* xml "version=\"1.0\"")
         (methodResponse
          (params
           (param
            (value (string "Hello!"))))))
       resp)))
  
  (test-case "Successful response decoded correctly"
    (check-equal?
     (decode-xmlrpc-response
      (open-input-string
       (string-append generic-headers
                      successful-response-string)))
     "Hello!"))
  
  (test-case "Fault response decoded correctly"
    (check-exn
        (lambda (exn)
          (and (exn:xmlrpc:fault? exn)
               (check = (exn:xmlrpc:fault-code exn) 4)
               (check string=?
                      (exn-message exn)
                      "Too many parameters.")))
      (lambda ()
        (decode-xmlrpc-response
         (open-input-string
          (string-append generic-headers
                         fault-response-string))))))
  
  (test-case "Round-trip XML-RPC call is successful"
    (with-timeout 
     "XML-RPC call timed out." RPC-TIMEOUT
     (check
      string=?
      (decode-xmlrpc-response
       (make-xmlrpc-call
        (string->url "http://betty.userland.com/RPC2")
        (encode-xmlrpc-call "examples.getStateName" 40)))
      "South Carolina")))
  
  (test-case "Round-trip XML-RPC with invalid response handled ok"
    ;; betty returns the just <value></value> on this call
    (with-timeout
     "XML-RPC invalid call timed out." RPC-TIMEOUT
     (check
      string=?
      (decode-xmlrpc-response
       (make-xmlrpc-call
        (string->url "http://betty.userland.com/RPC2")
        (encode-xmlrpc-call "examples.getStateName" 60)))
      "")))
  
  ;; Server-side tests
  (test-case "decode-xmlrpc-call parses call correctly."
    (check
     (lambda (a b)
       (and (equal? (rpc-call-name a)
                    (rpc-call-name b))
            (equal? (rpc-call-args a)
                    (rpc-call-args b))))
     (decode-xmlrpc-call body-string)
     (make-rpc-call 'fooBar (list 1 2.0 "3"))
     )))
