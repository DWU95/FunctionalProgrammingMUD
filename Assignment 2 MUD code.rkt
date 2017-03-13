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

;; Describe the room 'descriptions' within as association list
(define descriptions
  '((1 "You are in the lobby.")
    (2 "You are in the hallway.")
    (3 "You are in a swamp.")))

;; Define some actions which will include into our decisiontable structure
(define look
  '(((directions) look) ((look) look) ((examine room) look)))

(define quit
  '(((exit game) quit) ((quit game) quit) ((exit) quit) ((quit) quit)))

;; Quasiquote is used to apply special properties
;; Unquote-splicing is used because we need to remove the extra list that would be generated had we just used unquote
(define actions
  `(,@look ,@quit))

(define decisiontable
  `((1 ((north) 2) ((north west) 3) ,@actions)
    (2 ((south) 1) ,@actions)
    (3 ,@actions)))

;; This function examines the data for a single room and looks for direction entries, e.g ((north) 2)
;; It does this by checking for a number at the second position of each list
;; The outputted result is not user friendly at the moment. The list needs to be converted back into strings
(define (get-directions id)
  ;; List decisiontable assigns the id of the decisiontable searched to record
   (let ((record (assq id decisiontable)))
      (let* ((result (filter (λ (n) (number? (second n))) (cdr record)))
             (n (length result)))
        ;; Conditions to check the directions
        (cond ((= 0 n)
               (printf "You appear to have entered a room with no exits. \n"))
              ((= 1 n)
               (printf "You can see an exit to the ~a.\n" (slist->string (caar result))))
              (else
               (let* ((losym (map (λ (x) (car x)) result))
                      (lostr (map (λ (x) (slist->string x)) losym)))
                 (printf "You can see exits to the ~a.\n" (string-join lostr " and "))))))))
         ;;(for-each (λ (direction) (printf "~a" (first direction))) result))
      ;;(printf "\n")))

;; Maps the paramter to the list of atoms then joins it
(define (slist->string l)
  (string-join (map symbol->string l)))

(define responses
  '((1 "Hello how are you")
    (2 "Want me to cheer you up?")
    (3 "Do you want to watch a movie?")
    (4 "What genre would you like to watch?")
    (5 "Do you not like movies?")
    (6 "Good choice, want me to look for films?")
    (7 "Shall I recommend a gory film for you?")
    (8 "Shall I recommend a non-gory scary film for you?")))

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

(define (startgame initial-id)
  (let loop ((id initial-id) (description #t))
    (if description
        (printf "~a\n> " (get-response id))
        (printf "> "))
    (let* ((input (read-line))
           (string-tokens (string-tokenize input))
           (tokens (map string->symbol strings-token)))
      (let ((response (lookup id tokens )))
        (cond ((number? response)
               (loop response #t))
              ((eq? #f response)
               (format #t "Huh? I didn't understand that!\n")
               (loop if #f))
               ((eq? reponse 'look)
                (get-directions id)
                (loop id #f))
               ((eq? reponse 'quit )
                (format #t "So Long\n")
                (exit)))))))


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