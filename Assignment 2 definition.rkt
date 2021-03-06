#lang racket

;;Scheme Request for Implementation
(require srfi/1) ;; This srfi works with pairs and lists
(require srfi/13) ;; This srfi works with String Libraries
(require srfi/48) ;; Intermediate Format Strings

(define (assq-ref assqlist id)
  (cdr (assq id assqlist)))

(define (assv-ref assqlist id)
  (cdr (assv id assqlist)))

(define (command) ;; To execute the function
  (let* ((input (read-line)) ;; Allows user input
         (string-tokens (string-tokenize input)) ;; converting an entire string into a list of strings
         (tokens (map string->symbol string-tokens)) ;; map strings into a list
         (cmd (car tokens))) ;; Read the first string token
    (cond
      ;; explain the commands
      ((eq? cmd 'help)
       (format #t "Usage:\nsearch <term>\nquit\n"))
      ;; break the loop
      ((eq? cmd 'quit)
       (exit ))
      ;; do something
      ((eq? cmd 'search)
       (format #t "Searching for ~a ...\n" (cadr tokens)))
      ;; handle unknown input
      (else
       (format #t "Huh ?\n"))))
  (command)) ;; To execute the command

;; The numbers (1 2 7 8) are the id for the responses function
(define responses
  '((1 "Hello how are you")
    (2 "Want me to cheer you up?")
    (3 "Do you want to watch a movie?")
    (4 "What genre would you like to watch?")
    (5 "Do you not like movies?")
    (6 "Good choice, want me to look for films?")
    (7 "Shall I recommend a gory film for you?")
    (8 "Shall I recommend a non-gory scary film for you?")))
  

;; The numbers (1 2 7 8) are the id for the decisiontable funciton
(define decisiontable
  '((1 ((not) 2) ((fine) 3) ((okay) 3) ((good) 3) ((not really) 2) ((no) 2) ((bad) 2))
    (2 ((yes) 4) ((no) 0) ((not) 0) ((not really) 0) ((please) 4))
    (3 ((yes) 4) ((no) 5) ((not) 5) ((not really) 5) ((please) 4))
    (4 ((horror) 7) ((animated) 6))
    (5 ((not really) 2) ((no) 2) ((i do) 3) ((yes) 3) ((not today) 0))
    (6 ((yes) non-gory) ((no) 4))
    (7 ((yes) gory) ((ok) gory) ((no) 0))
    (8 ((yes) non-gory) ((ok) gory) ((no) 0))))

;; Returns a string based on the given id
(define (get-response id)
  (car (assq-ref responses id))) ;; provides the string associated with the number you provide

;; Generates a keyword list based on the id given
(define (get-keywords id)
  (let ((keys (assq-ref decisiontable id))) ;; lets the assq-ref of the id we choose in decision table hold into 'keys'
    (map
     (λ (key) (car key)) keys))) ;; maps the car of the keys into key. The car of ((comedy) 20) is (comedy).


;; A wrapper function which allows us to supply an id and list of tokens
;; Returns the matching id
(define (lookup id tokens)
  (let* ((record (assv-ref decisiontable id)) ;; Let the record hold the tokens in decisiontable with a id you provide
         (keylist (get-keywords id)) ;; keylist holds the keywords from given id
         ;; holds the index largest number from list-of-lengths into index
         (index (index-of-largest-number (list-of-lengths keylist tokens)))) 
    (if index
        ;; lists the cadr of the id of the decisiontable and its index given.
        (cadr (list-ref record index))
        #f)))

;; Returning the position of the largest value in our list
(define (index-of-largest-number list-of-numbers)
  (let ((n (car (sort list-of-numbers >))))
    (if (zero? n)
        #f
        (list-index (λ (x) (eq? x n)) list-of-numbers))))

;; Accepts a keyword list and does a match against a list of tokens
;; Outputs the list in the form: (0 0 0 2 0)
(define (list-of-lengths keylist tokens)
  (map
   (λ (x)
     (let ((set (lset-intersection eq? tokens x)))
       ;; apply some weighting to the result
       (* (/ (length set) (length x)) (length set))))
   keylist))

(define (recommend initial-id)
   (let loop ((id initial-id))
      (format #t "~a \n > " (get-response id))
      (let* ((input (read-line))
               (string-tokens (string-tokenize input))
               (tokens (map string->symbol string-tokens)))
         (let ((response (lookup id tokens)))
            (cond ((eq? #f response)
                    (format #t "huh? I didn't understand that! ")
                    (loop id))
                   ((eq? 'gory response )
                    (format #t "Searching for gory horror films ....\n ")
                    (exit ))
                   ((eq? 'non-gory response )
                    (format #t "Searching for non-gory scary films ....\n ")
                    (exit ))
                   ((zero? response )
                    (format #t "Okay bye 👋 ...\n")
                    (exit))
                   (else
                     (loop response)))))))
