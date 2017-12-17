;;;; Battiston Ilaria 816339
;;;; Di Gennaro Luca 820612

;;;; json-parsing.l

;; aggiornato al 17/12/17

;; defparameter charlist di prova
;; (defparameter x '(#\" #\a #\b #\c #\" #\: #\" #\c #\d #\e #\" #\, #\" #\f #\" #\: #\" #\g #\"))
;; defparameter jsonstring di prova
;; (defparameter jsonstring "{\"abc\" : \"cde\", \"f\" : \"g\"}")
;; (defparameter x (string-to-list "1, 2, 3, [a, b, c]"))
;; (defparameter x (string-to-list "\"nomi\" : [1, 2, 3]"))

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
          (parse-members (clean-charlist (string-to-list (string-trim "{}" JSONString))) nil 0))) 
        ((and (eq (char JSONString 0) #\[) (eq (char JSONString (- (length JSONString) 1)) #\])) 
         (cons
          'json-obj ;; l'ho messo come stringa perchè non so come cazzo farlo scrivere altrimenti
          (parse-array (clean-charlist (string-to-list (string-trim "[]" JSONString))) nil 0))) 
        (T (error "Syntax error! ")))) ; se non inizia per { e finisce per } errore o non è array
  

;; funziona ma non funziona con array negli oggetti perchè " non sono 4
;; ho provato a spostare la roba tra [] in secchiellino e chiamare parse array su quello,
;; ma 4 some reasons non va
(defun parse-members (charlist secchiellino counter)
  (cond ((= counter 5) (error "Format not supported!"))
	((null charlist) (list secchiellino))
        ((and
	  (eq (car charlist) #\,)
	  (= counter 4))
	 (cons secchiellino (parse-members (cdr charlist) nil 0)))
        ((eq (car charlist) #\")
	 (parse-members (cdr charlist) (cons-end (car charlist) secchiellino) (+ 1 counter)))
	;((and
	  ;(eq (car charlist) #\[)
	  ;(= counter 2))
	 ;(parse-members (cdr charlist) (cons-end (second charlist) secchiellino) counter))
	;((eq (car charlist) #\])
	 ;(cons (parse-array secchiellino () 0) (parse-members (cdr charlist) nil 0)))
        (T
	 (parse-members (cdr charlist) (cons-end (car charlist) secchiellino) counter))))


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
  (substitute #\" #\' (remove #\Space charlist)))



;(defun json-obj (JSONlist)
 ; ...
  ;(append (list ("json-obj")) '(parsedlist)))


(defun is-value (value)
  (cond ((numberp value) T)
	((stringp value) T)
	;; ((json-obj value) T)
	(T (error "Not a JSON value!"))))

;; cons-end 
(defun cons-end (element l)
  (if (null l)
      (list element)
    (cons (first l) (cons-end element (rest l)))))
