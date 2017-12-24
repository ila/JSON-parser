;;;; Battiston Ilaria 816339
;;;; Di Gennaro Luca 820612

;;;; json-parsing.l

;; aggiornato al 24/12/17

;; defparameter charlist di prova
;; (defparameter x '(#\" #\a #\b #\c #\" #\: #\" #\c #\d #\e #\" #\, #\" #\f #\" #\: #\" #\g #\"))
;; defparameter jsonstring di prova
;; (defparameter jsonstring "{\"abc\" : \"cde\", \"f\" : \"g\"}")
;; (defparameter x (string-to-list "1, 2, 3, [a, b, c]"))
;; (defparameter x "{\"name\" : \"Zaphod\",\"heads\" : [[\"Head1\"], [\"Head2\"]]}")
;; (defparameter x (string-to-list "\"nomi\" : [1, 2, 3]"))
;; (defparameter x "{\"nome\" : {\"abc\" : \"def\"}}")
;; (json-obj ("nome" "Arthur") ("cognome" "Dent"))

;; to-do:
;; capire come gestire gli spazi, mettere optional i parametri di parse-members
;; just because, array, get, I/O
;; parse-values
;; format per levare il maiuscolo non serve a una sega

;; modifiche: fatto array (manca il caso obj) vanno aggiunti po' di casi di errori
;; tipo se scrivo greawc4w NON è un oggetto jason e deve capirlo (senza apici, ...)


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
(defun remove-last(l)
    (reverse (cdr (reverse l))))



;; inverto il json-parse
;; NB: con equal ci vuole il char, concatenate la stringa
;; NON FUNZIONA NEMMENO A PAGARLA - 
;;1) EH GRAZIE CHE NON FUNZIONA CHECKA LE PARENTESI E USA LISPWORKS CHE TE LE COLORA
;;2) comunque ti ho fixato le parentesi del cond prego
;;3) non siamo in prolog, jsonstring non la passi come parametro ma la devi creare e tornare te con la funzione
;;4) ho commentato tutto perchè dà warning ovunque
#|(defun revert-obj (jsonobj jsonstring)
  (cond ((and (null jsonobj) (eq (char jsonstring 0) #\{))
	 (concatenate 'string (string-right-trim ", " jsonstring) "}"))	
        ((null jsonobj) nil)
	((not (list jsonobj))
	 (error "Not a valid object!"))
;	((= (car jsonobj) 'json-array)
;	 (concatenate 'string jsonstring (revert-array ((cdr jsonobj) ""))))
	((= (car jsonobj) 'json-obj)
	 (revert-obj ((cdr jsonobj) (concatenate 'string jsonstring "{"))))
	(T (revert-obj ((cdr jsonobj) (concatenate 'string (car (car jsonobj)) " : " (cdr (car jsonobj)) ", "))))))|#


;; json-load
(defun json-load (filename)
  (json-parse (load-string filename)))

(defun load-string (filename)
  (with-open-file (in filename
         :if-does-not-exist :error)
    (let ((json (make-string (file-length in))))
      (read-sequence json in)
      json)))
		       
		     
