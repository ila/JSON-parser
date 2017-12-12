;;;; Battiston Ilaria 816339
;;;; Di Gennaro Luca 820612

;;;; json-parsing.l

;; aggiornato al 5/12/17

;; defparameter

(defun json-parse (JSONstring object)
  (if (not (stringp JSONstring) (error "Not a string!"))
      json-obj (???)))

;; funziona
;; potrebbero non esserci parentesi graffe
(defun string-to-list (JSONstring)
  (if (= (length JSONstring) 0)
      nil
    (cons (char JSONstring 0) (string-to-list (subseq JSONstring 1)))))

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
	(T (insert charlist))))



(defun json-obj (JSONlist)
  ...
  (append (list ("json-obj")) '(parsedlist)))


(defun is-value (value)
  (cond ((numberp value) T)
	((stringp value) T)
	;; ((json-obj value) T)
	(T (error "Not a JSON value!"))))
