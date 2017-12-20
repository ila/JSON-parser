;;;; Battiston Ilaria 816339
;;;; Di Gennaro Luca 820612

;;;; json-parsing.l

;; aggiornato al 17/12/17

;; OOOOOOO MANCA LA FUNZIONE CHE RIMUOVE SPACE TAB E NEWLINE MI AMMAZZO

;; defparameter charlist di prova
;; (defparameter x '(#\" #\a #\b #\c #\" #\: #\" #\c #\d #\e #\" #\, #\" #\f #\" #\: #\" #\g #\"))
;; defparameter jsonstring di prova
;; (defparameter jsonstring "{\"abc\" : \"cde\", \"f\" : \"g\"}")
;; (defparameter x (string-to-list "1, 2, 3, [a, b, c]"))
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


(defun json-parse (JSONString)
  (cond ((not (stringp JSONString)) (error "Not a string!")) ; se non è una stringa errore
        ((and (eq (char JSONString 0) #\{) (eq (char JSONString (- (length JSONString) 1)) #\}))
         (cons
          'json-obj ;; l'ho messo come stringa perchè non so come cazzo farlo scrivere altrimenti
          (parse-members (clean-charlist (string-to-list JSONString)) nil))) 
        ((and (eq (char JSONString 0) #\[) (eq (char JSONString (- (length JSONString) 1)) #\])) 
         (cons
          'json-obj ;; l'ho messo come stringa perchè non so come cazzo farlo scrivere altrimenti
          (parse-array (clean-charlist (string-to-list JSONString)) nil 0))) 
        (T (error "Syntax error! ")))) ; se non inizia per { e finisce per } errore o non è array
  

;; funziona ma non funziona con array negli oggetti perchè " non sono 4
;; ho provato a spostare la roba tra [] in accumulator e chiamare parse array su quello, 
;; ma 4 some reasons non va


;;prova parse-members ricorsivo
(defun parse-members (tokenlist accumulator)
  (cond ((null tokenlist) (list (parse-pair accumulator)))
        ((eq (car tokenlist) #\,)
	 (cons (parse-pair accumulator) (parse-members (cdr tokenlist) nil)))
        (T
	 (parse-members (cdr tokenlist) (cons-end (car tokenlist) accumulator)))))

	 

;;funziona ma dobbiamo prima checkare i value/attribute prima di ritornarli
(defun parse-pair (tokenlist)
  (cond ((not (stringp (car tokenlist))) (error "Attribute not a string!"))
	((not (eq (cadr tokenlist) #\:)) (error "Syntax error")) 
        (T (list (car tokenlist) (is-value (cdr (cdr tokenlist)))))))


;; value (da testare)
(defun is-value (value)
  (cond ((stringp (car value)) (car value))
	((and (eq (first value) #\{) (eq (car (last value)) #\}))
         (cons
          'json-obj 
          (parse-members (clean-charlist value) nil)))
        ((not (null (parse-integer (car value) :junk-allowed t))) (car value))
	(T (error "Not a valid value!"))))
  
;; (parse-integer stringa :junk-allowed t)
;; per passare da "123" a 123
;; da' nil quando passo stringhe non numeriche
;; Dige: si ma i numeri sono convertiti in caratteri, non stringhe, quindi li dobbiamo raggruppare prima in una stringa
;; at least, e poi dovremmo pure usare parse-float, oltre che integer

;; bugs: stampa un nil di troppo alla fine, not sure a cosa servano secchiellino e counter
;; ma funziona con gli array uno dentro l'altro! :D
(defun parse-array (array secchiellino counter)
  (cond ((and (null array) (= counter 1))
	 (error "Unbalanced parenthesis!"))
	((null array) nil)
	((eq (car array) #\[)
	 (list (append (list 'json-array) (parse-array (cdr array) secchiellino 0))))
	((eq (car array) #\])
	  (list (parse-array (cdr array) () 0)))
	((eq (car array) #\,)
	 (parse-array (cons #\Space (cdr array)) secchiellino counter))
	(T (append (list (car array)) (parse-array (cdr array) secchiellino counter)))))
	

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
  (remove-last (cdr (remove #\Space (compact-substrings (substitute #\" #\' charlist) nil 0)))))

;;(" a b c " : " c d e " , " f " : " g h ") --> ("abc" : "cde" , "f" : "gh")
(defun compact-substrings (charlist accumulator counter)
  (cond ((null charlist) (cons (list-to-string accumulator) nil))
        ((eq (car charlist) #\")
	 (compact-substrings (cdr charlist) accumulator (+ 1 counter)))
        ((= counter 0) (cons (car charlist) (compact-substrings (cdr charlist) accumulator counter)))
        ((= counter 1) (compact-substrings (cdr charlist) (cons-end (car charlist) accumulator) counter))
        ((= counter 2) (cons (list-to-string accumulator) (compact-substrings charlist nil 0)))        
        ((eq (car charlist) #\")
	 (compact-substrings (cdr charlist) (cons-end (car charlist) accumulator) (+ 1 counter)))
        (T
	 (error "err"))))

;; ("numero" : 1 . 2 3 4 5) --> ("numero" : "1.2345") WIP
;;(defun compact-numbers (charlist accumulator counter)
;;  )

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
		       
		     
