;;;; Battiston Ilaria 816339
;;;; Di Gennaro Luca 820612

;;;; json-parsing.l

;; aggiornato al 5/12/17

;; defparameter charlist di prova
;; (defparameter x '(#\" #\a #\b #\c #\" #\: #\" #\c #\d #\e #\" #\, #\" #\f #\" #\: #\" #\g #\"))
;; defparameter jsonstring di prova
;; (defparameter jsonstring "{\"abc\" : \"cde\", \"f\" : \"g\"}")

;; to-do:
;; capire come gestire gli spazi, mettere optional i parametri di parse-members
;; just because, array, get, I/O
;; parse-values
;; format per levare il maiuscolo non serve a una sega
;; parse chiama parsemembers se trova graffe, array se trova quadre

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
        (T (error "Not a JSON object! ")))) ; se non inizia per { e finisce per } errore o non è array
  

;; funziona
(defun parse-members (charlist pisellino counter)
  (cond ((null charlist) (list secchiellino))
        ((and
	  (eq (car charlist) #\,)
	  (= counter 4))
	 (cons secchiellino (parse-members (cdr charlist) nil 0)))
        ((eq (car charlist) #\")
	 (parse-members (cdr charlist) (cons-end (car charlist) secchiellino) (+ 1 counter)))
        (T
	 (parse-members (cdr charlist) (cons-end (car charlist) secchiellino) counter))))


;; array come lista
;; non va lol
(defun parse-array (array secchiellino)
  (cond ((null array) nil)
	((eq (car array) #\,)
	 (cons #\Space (parse-array (cdr array) secchiellino)))
	(T (parse-array (cdr array) secchiellino))))
	

	

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
