;;;; Battiston Ilaria 816339
;;;; Di Gennaro Luca 820612

;; (defparameter x (json-parse "{\"abc\" : \"cde\", \"f\" : \"g\"}"))
;; (defparameter x (json-parse "{\"name\" : \"Zaphod\",\"heads\" : [[\"Head1\"], [\"Head2\"]]}"))
;; (defparameter x (json-parse ("{\"nome\" : {\"abc\" : \"def\"}}"))


;; piccoli bugs da sistemare: testare un po' di casi limite,
;; aggiungere exception handling, sistemare l'indentazione
;; aggiungere commenti fatti decentemente lol
;; vedere che cazzo combina il load con il tab

;; NB: se passo (defparameter z (json-parse "{\"a\": [1, 2], \"b\": [\"c\" : [4, 5, [6, 7]]]}"))
;; restituisce (JSON-OBJ ("a" (JSON-ARRAY 1 2)) ("b" (JSON-ARRAY "c")))
;; che non va bene, dovrebbe dare errore perchè ci sono : nell'array

;; il json-load sembra funzionare, non ho idea perchè si rompa con la stringa di Bianca
;; da' questo Error: No integer present in "-" from 0 to 1, parse-integer expected one.
;; probabilmente perchè hai gestito i numeri negativi in modo strano e rompe tutto
;; niente escape nei file, funziona senza


;;;; json-parsing.l


;;in json-parse prendo la stringa, la trasformo in charlist,
;; la faccio pulire e la passo a json-parse-charlist
(defun json-parse (JSONString)
  (if (not (stringp JSONString)) (error "Not a string!")
    (json-parse-charlist (clean-charlist
			  (string-to-list JSONString)))))


;; in json-parse-charlist prendo la charlist pulita e la parso 
(defun json-parse-charlist (charlist)
  (cond ((and (eq (car charlist) #\{) (eq (car (last charlist)) #\}))
         (cons 'json-obj (parse-members (remove-braces charlist) nil 0 0))) 
        ((and (eq (car charlist) #\[) (eq (car (last charlist)) #\])) 
         (cons 'json-array (parse-array (remove-braces charlist) nil 0 0))) 
        (T (error "Syntax error! ")))) ; se non è tra {} errore o non è array
  

;; aggiunto contatore per parentesi
;; se ho una virgola dentro un sotto oggetto non deve splittarla
;; nOpen = open parenthesis number, nClosed = closed parenthesis number
(defun parse-members (tokenlist accumulator nOpen nClosed)
  (cond ((and (null tokenlist)(null accumulator)) nil)
        ((null tokenlist) (list (parse-pair accumulator)))
        ((and (eq (car tokenlist) #\,) (= nOpen nClosed))
	 (cons (parse-pair accumulator)
	       (parse-members (cdr tokenlist) nil nOpen nClosed)))
        ((or (eq (car tokenlist) #\{) (eq (car tokenlist) #\[)) 
	 (parse-members (cdr tokenlist)
			(cons-end (car tokenlist) accumulator)
			(incf nOpen) nClosed))
        ((or (eq (car tokenlist) #\}) (eq (car tokenlist) #\])) 
	 (parse-members (cdr tokenlist)
			(cons-end (car tokenlist) accumulator)
			nOpen (incf nClosed)))
        (T (parse-members (cdr tokenlist)
			  (cons-end (car tokenlist) accumulator)
			  nOpen nClosed))))

	 
(defun parse-pair (tokenlist)
  (cond ((null tokenlist) nil)
        ((not (stringp (car tokenlist))) (error "Attribute not a string!"))
	((not (eq (cadr tokenlist) #\:)) (error "Syntax error")) 
        (T (list (car tokenlist) (parse-value (cdr (cdr tokenlist)))))))


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


;; parse-array
(defun parse-array (tokenlist accumulator nOpen nClosed)
  (cond ((and (null tokenlist)(null accumulator)) nil)
        ((null tokenlist) (list (parse-value accumulator)))
        ((and (eq (car tokenlist) #\,) (= nOpen nClosed))
	 (cons (parse-value accumulator)
	       (parse-array (cdr tokenlist) nil nOpen nClosed)))
        ((or (eq (car tokenlist) #\{) (eq (car tokenlist) #\[)) 
	 (parse-array (cdr tokenlist)
		      (cons-end (car tokenlist) accumulator)
		      (incf nOpen) nClosed))
        ((or (eq (car tokenlist) #\}) (eq (car tokenlist) #\])) 
	 (parse-array (cdr tokenlist)
		      (cons-end (car tokenlist) accumulator)
		      nOpen (incf nClosed)))
        (T (parse-array (cdr tokenlist)
			(cons-end (car tokenlist) accumulator)
			nOpen nClosed))))
	

(defun string-to-list (JSONString)
  (if (= (length JSONString) 0) nil
    (cons (char JSONString 0)
	  (string-to-list (subseq JSONString 1)))))


(defun list-to-string (charlist)
  (if (null charlist) nil
    (concatenate 'string
		 (string (car charlist))
		 (list-to-string (cdr charlist)))))


;; HELP NON SO COME INDENTARLA
(defun clean-charlist (charlist) 
   (remove #\Return (remove #\Tab (remove #\Newline (remove #\Space (compact-numbers 
                    (compact-substrings (substitute #\" #\' charlist) nil 0) nil))))))


(defun remove-braces (charlist)
  (cdr (remove-last charlist)))


;;(" a b c " : " c d e " , " f " : " g h ") --> ("abc" : "cde" , "f" : "gh")
(defun compact-substrings (charlist accumulator counter)
  (cond ((and (null charlist) (null accumulator)) nil)
        ((null charlist) (cons (list-to-string accumulator) nil))
        ((eq (car charlist) #\")
	 (compact-substrings (cdr charlist) accumulator (+ 1 counter)))
        ((= counter 0)
	 (cons (car charlist)
	       (compact-substrings (cdr charlist)
				   accumulator
				   counter)))
        ((= counter 1)
	 (compact-substrings (cdr charlist)
			     (cons-end (car charlist) accumulator)
			     counter))
        ((= counter 2)
	 (cons (list-to-string accumulator)
	       (compact-substrings charlist nil 0)))        
        ((eq (car charlist) #\")
	 (compact-substrings (cdr charlist)
			     (cons-end (car charlist) accumulator)
			     (+ 1 counter)))
        (T (error "Error!"))))


(defun compact-numbers (charlist accumulator)
  (cond ((and (null charlist) (null accumulator)) nil)
        ((null charlist) (cons (string-to-number
				(list-to-string accumulator))
			       nil))
        ((and (or (eq (car charlist) #\,)
		  (eq (car charlist) #\})
		  (eq (car charlist) #\]))
	      (not (null accumulator))) 
         (cons (string-to-number
		(list-to-string accumulator))
	       (compact-numbers charlist nil)))
        ((stringp (car charlist))
	 (cons (car charlist)
	       (compact-numbers (cdr charlist) accumulator))) 
        ((or (and (> (char-int (car charlist)) 47)
		  (< (char-int (car charlist)) 58)) 
	     (eq (car charlist) #\.) 
	     (eq (car charlist) #\-)) 
         (compact-numbers (cdr charlist)
			  (cons-end (car charlist) accumulator)))
        (T (cons (car charlist)
		 (compact-numbers (cdr charlist) accumulator)))))


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


;; remove last element from list
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
	 (if (numberp field)
	     (get-depth (search-array (cdr obj) field) fields)
	   (get-depth (car (cdr (assoc field (rest obj) :test #'equal)))
		      fields)))
        (T (pprint "Error!"))))


(defun search-array (obj position)
  (cond ((null obj) nil)
	((= 0 position) (car obj))
	(T (search-array (cdr obj) (- position 1)))))


(defun get-depth (obj fields)
  (cond ((null obj) nil)
	((= (length fields) 1) (json-get obj fields))
	((stringp (car fields))
	 (json-get (car (cdr
			 (assoc (car fields) (rest obj) :test #'equal)))
		   (cdr fields)))
	(T (get-depth (search-array (cdr obj) (car fields)) (cdr fields)))))
	

(defun revert-obj (jsonobj jsonstring)
  (cond ((and (null jsonobj) (eq (char jsonstring 0) #\{))
	 (car (list (concatenate 'string
				 (string-right-trim
				  ", " jsonstring) "}"))))	
        ((null jsonobj) nil)
	((eq (car jsonobj) 'json-array)
	 (revert-array jsonobj ""))
	((eq (car jsonobj) 'json-obj)
	 (revert-obj (cdr jsonobj)
		     (concatenate 'string jsonstring "{")))
	((ignore-errors (eq (car (car (cdr (car jsonobj)))) 'json-obj))
	 (revert-obj (cdr jsonobj)
		     (concatenate 'string jsonstring
				  "\"" (car (car jsonobj)) "\"" " : "
				  (revert-obj (car (cdr (car jsonobj))) "")
				  ", ")))
	((ignore-errors (eq (car (car (cdr (car jsonobj)))) 'json-array))
	(revert-obj (cdr jsonobj)
		    (concatenate 'string jsonstring
				 "\"" (car (car jsonobj)) "\"" " : "
				 (revert-array (car (cdr (car jsonobj))) "")
				 ", ")))
	(T (if (numberp (car (cdr (car jsonobj))))
	       (revert-obj (cdr jsonobj)
			   (concatenate 'string jsonstring
					"\"" (car (car jsonobj)) "\"" " : "
					(write-to-string (car (cdr (car jsonobj))))
					", "))
	     (revert-obj (cdr jsonobj)
			 (concatenate 'string jsonstring
				      "\"" (car (car jsonobj)) "\"" " : "
				      "\"" (car (cdr (car jsonobj))) "\""
				      ", "))))))


(defun revert-array (jsonarray jsonstring)
  (cond ((and (null jsonarray) (eq (char jsonstring 0) #\[))
	 (car (list (concatenate 'string
				 (string-right-trim ", " jsonstring) "]"))))
	((null jsonarray) nil)
	((eq (car jsonarray) 'json-array)
	 (revert-array (cdr jsonarray) (concatenate 'string jsonstring "[")))
	((ignore-errors (eq (car (car jsonarray)) 'json-obj))
	 (revert-array (cdr jsonarray)
		       (concatenate 'string jsonstring
				    (revert-obj (car jsonarray) "") ", ")))
	((ignore-errors (eq (car (car jsonarray)) 'json-array))
	 (revert-array (cdr jsonarray)
		       (concatenate 'string jsonstring
				    (revert-array (car jsonarray) "") ", ")))
	(T (if (numberp (car jsonarray))
	       (revert-array (cdr jsonarray)
			     (concatenate 'string jsonstring
					  (write-to-string (car jsonarray))
					  ", "))
	     (revert-array (cdr jsonarray)
			   (concatenate 'string jsonstring
					"\"" (car jsonarray) "\"" ", "))))))



;; json-load
(defun json-load (filename)
  (json-parse (load-string filename)))

(defun load-string (filename)
  (with-open-file (in filename
         :if-does-not-exist :error)
    (let ((json (make-string (file-length in))))
      (read-sequence json in)
      json)))


;; json-write
(defun json-write (jsonobj filename)
  (with-open-file (out filename
		       :direction :output
		       :if-exists :supersede
		       :if-does-not-exist :create)
		  (format out (revert-obj jsonobj ""))))
		       
