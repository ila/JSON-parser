;;;; Battiston Ilaria 816339
;;;; Di Gennaro Luca 820612

;;;; json-parsing.l

;; aggiornato al 25/12/17

;; defparameter charlist di prova
;; (defparameter x '(#\" #\a #\b #\c #\" #\: #\" #\c #\d #\e #\" #\, #\" #\f #\" #\: #\" #\g #\"))
;; defparameter jsonstring di prova
;; (defparameter jsonstring "{\"abc\" : \"cde\", \"f\" : \"g\"}")
;; (defparameter x (string-to-list "1, 2, 3, [a, b, c]"))
;; (defparameter x "{\"name\" : \"Zaphod\",\"heads\" : [[\"Head1\"], [\"Head2\"]]}")
;; (defparameter x (string-to-list "\"nomi\" : [1, 2, 3]"))
;; (defparameter x "{\"nome\" : {\"abc\" : \"def\"}}")
;; (json-obj ("nome" "Arthur") ("cognome" "Dent"))


;; a cosa serve remove braces?
;; che differenza c'è tra return e newline?
;; se hai problemi con il parsing dei numeri lmk, io mi concentro sul write che è DOLORE NEL CULO
;; comunque bravo funziona tutto, pure il caso con apici <3 gg senpan
;; il get funziona, pure con la lista di "cose"
;; IL REVERT NON VA ci sono vicina ma non vaaa


;;ho diviso parse in due perchè dobbiamo pulire la stringa prima di checkarla
;;in json-parse prendo la stringa, la trasformo in charlist, la faccio pulire e la passo a json-parse-charlist
(defun json-parse (JSONString)
  (if (not (stringp JSONString)) (error "Not a string!")
      (json-parse-charlist (clean-charlist (string-to-list JSONString)))))

;; in json-parse-charlist prendo la charlist pulita e la parso 
(defun json-parse-charlist (charlist)
  (cond ((and (eq (car charlist) #\{) (eq (car (last charlist)) #\}))
         (cons 'json-obj (parse-members (remove-braces charlist) nil 0 0))) 
        ((and (eq (car charlist) #\[) (eq (car (last charlist)) #\])) 
         (cons 'json-array (parse-array (remove-braces charlist) nil 0 0))) 
        (T (error "Syntax error! ")))) ; se non inizia per { e finisce per } errore o non è array
  


;; funziona ma non funziona con array negli oggetti perchè " non sono 4
;; ho provato a spostare la roba tra [] in accumulator e chiamare parse array su quello, 
;; ma 4 some reasons non va

;;prova parse-members ricorsivo
;; aggiunto contatore per parentesi : se ho una virgola dentro le parentesi di un sotto oggetto non deve splittarla
;; nOpen = open parenthesis number, nClosed = closed parenthesis number 
(defun parse-members (tokenlist accumulator nOpen nClosed)
  (cond ((and (null tokenlist)(null accumulator)) nil)
        ((null tokenlist) (list (parse-pair accumulator)))
        ((and (eq (car tokenlist) #\,) (= nOpen nClosed))
	 (cons (parse-pair accumulator) (parse-members (cdr tokenlist) nil nOpen nClosed)))
        ((or (eq (car tokenlist) #\{) (eq (car tokenlist) #\[)) 
	 (parse-members (cdr tokenlist) (cons-end (car tokenlist) accumulator) (incf nOpen) nClosed))
        ((or (eq (car tokenlist) #\}) (eq (car tokenlist) #\])) 
	 (parse-members (cdr tokenlist) (cons-end (car tokenlist) accumulator) nOpen (incf nClosed)))
        (T
	 (parse-members (cdr tokenlist) (cons-end (car tokenlist) accumulator) nOpen nClosed))))

	 

;;funziona ma dobbiamo prima checkare i value/attribute prima di ritornarli
(defun parse-pair (tokenlist)
  (cond ((null tokenlist) nil)
        ((not (stringp (car tokenlist))) (error "Attribute not a string!"))
	((not (eq (cadr tokenlist) #\:)) (error "Syntax error")) 
        (T (list (car tokenlist) (parse-value (cdr (cdr tokenlist)))))))


;; value (da testare)
(defun parse-value (value)
  (cond ((and (eq (first value) #\{) (eq (car (last value)) #\}))
         (cons
          'json-obj 
          (parse-members (remove-braces value) nil 0 0)))
        ((and (eq (first value) #\[) (eq (car (last value)) #\]))
         (cons
          'json-array 
          (parse-array (remove-braces value) nil 0 0)))
        ((stringp (car value)) (car value))
        ((numberp (car value)) (car value))
	(T (error "Not a valid value!"))))
  
;;risolto io
(defun parse-array (tokenlist accumulator nOpen nClosed)
  (cond ((and (null tokenlist)(null accumulator)) nil)
        ((null tokenlist) (list (parse-value accumulator)))
        ((and (eq (car tokenlist) #\,) (= nOpen nClosed))
	 (cons (parse-value accumulator) (parse-array (cdr tokenlist) nil nOpen nClosed)))
        ((or (eq (car tokenlist) #\{) (eq (car tokenlist) #\[)) 
	 (parse-array (cdr tokenlist) (cons-end (car tokenlist) accumulator) (incf nOpen) nClosed))
        ((or (eq (car tokenlist) #\}) (eq (car tokenlist) #\])) 
	 (parse-array (cdr tokenlist) (cons-end (car tokenlist) accumulator) nOpen (incf nClosed)))
        (T
	 (parse-array (cdr tokenlist) (cons-end (car tokenlist) accumulator) nOpen nClosed))))
	

;; funziona
(defun string-to-list (JSONString)
  (if (= (length JSONString) 0)
      nil
    (cons (char JSONString 0) (string-to-list (subseq JSONString 1)))))


;;funziona
(defun list-to-string (charlist)
  (if (null charlist) 
      nil
    (concatenate 'string (string (car charlist)) (list-to-string (cdr charlist)))))

(defun clean-charlist (charlist) 
   (remove #\Return (remove #\Tab (remove #\Newline (remove #\Space (compact-numbers 
                    (compact-substrings (substitute #\" #\' charlist) nil 0) nil))))))

(defun remove-braces (charlist)
  (cdr (remove-last charlist)))

;;(" a b c " : " c d e " , " f " : " g h ") --> ("abc" : "cde" , "f" : "gh")
(defun compact-substrings (charlist accumulator counter)
  (cond ((and (null charlist)(null accumulator)) nil)
        ((null charlist) (cons (list-to-string accumulator) nil))
        ((eq (car charlist) #\")
	 (compact-substrings (cdr charlist) accumulator (+ 1 counter)))
        ((= counter 0) (cons (car charlist) (compact-substrings (cdr charlist) accumulator counter)))
        ((= counter 1) (compact-substrings (cdr charlist) (cons-end (car charlist) accumulator) counter))
        ((= counter 2) (cons (list-to-string accumulator) (compact-substrings charlist nil 0)))        
        ((eq (car charlist) #\")
	 (compact-substrings (cdr charlist) (cons-end (car charlist) accumulator) (+ 1 counter)))
        (T
	 (error "err"))))

;; ("numero" : 1 . 2 3 4 5) --> ("numero" : 1.2345) WIP numeri 0 -> 48 ..... 9 ->57
(defun compact-numbers (charlist accumulator)
  (cond ((and (null charlist)(null accumulator)) nil)
        ((null charlist) (cons (string-to-number (list-to-string accumulator)) nil))
        ((and (or (eq (car charlist) #\,) (eq (car charlist) #\}) (eq (car charlist) #\])) (not (null accumulator))) 
         (cons (string-to-number (list-to-string accumulator)) (compact-numbers charlist nil)))
        ((stringp (car charlist)) (cons (car charlist) (compact-numbers (cdr charlist) accumulator))) 
        ((or 
          (and (> (char-int (car charlist)) 47) (< (char-int (car charlist)) 58)) 
          (eq (car charlist) #\.) 
          (eq (car charlist) #\-)) 
         (compact-numbers (cdr charlist) (cons-end (car charlist) accumulator)))
        (T (cons (car charlist) (compact-numbers (cdr charlist) accumulator)))))

;;"1.234" --->1.234 
;;"123" ---> 123  
(defun string-to-number (string)
  (if (null (search "." string))
      (parse-integer string)
    (parse-float string)))

;; cons-end 
(defun cons-end (element l)
  (if (null l)
      (list element)
    (cons (first l) (cons-end element (rest l)))))

;; remove last elem from list
(defun remove-last (l)
    (reverse (cdr (reverse l))))



;; json-get
(defun json-get (obj field &rest fields)
  (cond ((null obj) nil)
	((and (eq 'json-array (first obj))
	      (null fields))
	 (if (listp field)
	     (search-array (rest obj) (car field))
	   (search-array (rest obj) field)))
	((and (eq 'json-obj (first obj)) ;; oggetti negli oggetti
	      (null fields)
	      (listp field))
	 (json-get obj (car field)))
	((and (eq 'json-obj (first obj))
	      (null fields))
	 (car (cdr (assoc field (rest obj) :test #'equal))))
	((not (null fields))
	 (get-depth (car (cdr (assoc field (rest obj) :test #'equal))) fields))
        (T (pprint "Error!"))))


(defun search-array (obj position)
  (cond ((null obj) nil)
	((= 0 position) (car obj))
	(T (search-array (cdr obj) (- position 1)))))


(defun get-depth (obj fields)
  (cond ((null obj) nil)
	((= (length fields) 1) (json-get obj fields))
	(T (get-depth (search-array (cdr obj) (car fields)) (cdr fields)))))
	

;; buggatissimo
(defun revert-obj (jsonobj jsonstring)
  (cond ((and (null jsonobj) (eq (char jsonstring 0) #\{))
	 (concatenate 'string (string-right-trim ", " jsonstring) "}"))	
        ((null jsonobj) nil)
	((not (list jsonobj))
	 (error "Not a valid object!"))
	((eq (car jsonobj) 'json-array)
	 (concatenate 'string jsonstring (revert-array (cdr jsonobj) "")))
	((eq (car jsonobj) 'json-obj)
	 (revert-obj (cdr jsonobj) (concatenate 'string jsonstring "{")))
	((eq (car (cdr (car jsonobj))) 'json-array)
	 (revert-obj (cdr jsonobj)
		     (concatenate 'string (car (car jsonobj)) " : " (revert-array (cdr (cdr (car jsonobj))) ""))))
	((eq (car (cdr (car jsonobj))) 'json-obj) ;; non entra qui
	 (revert-obj (cdr jsonobj)
		     (concatenate 'string (car (car jsonobj)) " : " (revert-obj (cdr (cdr (car jsonobj))) ""))))
	(T (revert-obj (cdr jsonobj) (concatenate 'string (car (car jsonobj)) " : " (car (cdr (car jsonobj))) ", ")))))

(defun revert-array (jsonarray jsonstring)
  (cond ((and (null jsonarray) (eq (char jsonstring 0) #\[))
	 (concatenate 'string (string-right-trim ", " jsonstring) "]"))
	((eq (car jsonarray) 'json-array)
	 (concatenate 'string jsonstring (revert-array (cdr jsonarray) "")))
	((eq (car jsonarray) 'json-obj)
	 (revert-obj (cdr jsonarray) (concatenate 'string jsonstring "[")))
	(T (revert-array (cdr jsonarray) (concatenate 'string (car jsonarray) ", ")))))



;; json-load
(defun json-load (filename)
  (json-parse (load-string filename)))

(defun load-string (filename)
  (with-open-file (in filename
         :if-does-not-exist :error)
    (let ((json (make-string (file-length in))))
      (read-sequence json in)
      json)))
		       
		     
