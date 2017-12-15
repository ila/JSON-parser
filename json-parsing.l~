;;;; Battiston Ilaria 816339
;;;; Di Gennaro Luca 820612

;;;; json-parsing.l

;; aggiornato al 5/12/17

;; defparameter

(defun json-parse (JSONString)
  (cond ((not (stringp JSONString)) (error "Not a string!")) ; se non è una stringa errore
        ((or 
          (not (eq (char JSONString 0) #\{)) 
          (not (eq (char JSONString (- (length JSONString) 1)) #\})))
	 ((or
	   (not (eq (char JSONString 0) #\[)) 
          (not (eq (char JSONString (- (length JSONString) 1)) #\])))
         (error "Not a JSON object! ")) ; se non inizia per { e finisce per } errore o non è array
        (T (cons 
            "json-obj" ;; l'ho messo come stringa perchè non so come cazzo farlo scrivere altrimenti
            (parse-members (clean-charlist (string-to-list (string-trim "{}" JSONString))) nil 0)))))

  
;; wip not working yet ((#\" #\a #\b c " : " c d e ") ("
;; se trova ' deve pushare "
(defun parse-members (charlist temp counter)
  (cond ((null charlist) nil)
        ((and
	  (eq (car charlist) #\,)
	  (= counter 4))
	 (cons (list temp) (parse-members (cdr charlist) (list nil) 0)))
        ((eq (car charlist) #\")
	 (parse-members (cdr charlist) (cons-end (car charlist) temp) (+ 1 counter)))
        (T
	 (parse-members (cdr charlist) (cons-end (car charlist) temp) counter))))


;; funziona
;; potrebbero non esserci parentesi graffe - risolto dal json-parse
(defun string-to-list (JSONString)
  (if (= (length JSONString) 0)
      nil
    (cons (char JSONString 0) (string-to-list (subseq JSONString 1)))))

;;funziona
(defun list-to-string (charlist)
  (if (null charlist) 
      nil
    (concatenate 'string (string (car charlist)) (list-to-string (cdr charlist)))))

(defun insert (charlist)
  (cond ((null charlist) nil)
	((equal (car charlist) #\,) (cons (list nil) (parse charlist)))
	(T (cons (car charlist) (parse (cdr charlist))))))

(defun parse (charlist)
  (cond ((null charlist) nil)
	((eq (car charlist) ":")
	 (insert (list " " (cdr charlist))))
	((eq (car charlist) ",")
	 (cons nil (parse (cdr charlist))))
	((eq (car charlist) "'")
	 (insert (list "\"" (cdr charlist))))
	(T (insert charlist))))



(defun json-obj (JSONlist)
  ...
  (append (list ("json-obj")) '(parsedlist)))


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
