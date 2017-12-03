;; json-parsing.l

;; aggiornato al 3/12
;; char "abc" 0 --> a potrebbe servire

;; DOBBIAMO AGGIUNGERE UN EXCEPTION HANDLER IN PROLOG

(defun json-parse (JSONstring object)
  (if (not (stringp JSONstring) (error "Not a string!"))
      json-obj (???)))
	

(defun is-value (value)
  (cond ((numberp value) T)
	((stringp value) T)
	;; ((json-obj value) T)
	(T (error "Not a JSON value!"))))
