;; Battiston Ilaria 816339
;; Di Gennaro Luca 820612

;; json-parsing.l

;; aggiornato al 5/12/17

(defun json-parse (JSONstring object)
  (if (not (stringp JSONstring) (error "Not a string!"))
      json-obj (???)))

;; funziona
(defun string-to-list (JSONstring)
  (if (= (length JSONstring) 0)
      nil
    (cons (char JSONstring 0) (string-to-list (subseq JSONstring 1)))))


	

(defun is-value (value)
  (cond ((numberp value) T)
	((stringp value) T)
	;; ((json-obj value) T)
	(T (error "Not a JSON value!"))))
