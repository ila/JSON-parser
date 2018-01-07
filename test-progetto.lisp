					
(load "~/desktop/programmazione/jason/json-parsing.l")         ; carica il progetto

(defparameter passed 0)   ; test passati
(defparameter failed 0)   ; test falliti
(defparameter tot 0)      ; test totali

;;; Test json-parse

;; test parse 1
(let ((a (ignore-errors (json-parse "{}")))
      ( b '(json-obj)))
  (if (equalp a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 1 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 2
(let ((a (ignore-errors (json-parse " {} ")))
      ( b '(json-obj)))
  (if (equalp  a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 2 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 3
(let ((a (ignore-errors (json-parse " { } ")))
      ( b '(json-obj)))
  (if (equalp  a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 3 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 4
(let ((a (ignore-errors (json-parse " {\"a\":\"b\" } ")))
      ( b '(json-obj ("a" "b"))))
  (if (equalp  a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 4 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 5
(let ((a (ignore-errors (json-parse " {\"a \" :\" b\" } ")))
      ( b '(json-obj ("a " " b"))))
  (if (equalp  a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 5 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 6
(let ((a (ignore-errors (json-parse " {\"a\":\"b\", \"c\":\"d\" } ")))
      ( b '(json-obj ("a" "b") ("c" "d"))))
  (if (equalp  a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 6 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 7
(let ((a (ignore-errors (json-parse " {\"a\":\"b\", \"c\":\"d\", \"e\": 2 } ")))
      ( b '(json-obj ("a" "b") ("c" "d") ("e" 2))))
  (if (equalp  a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 7 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 8
(let ((a (ignore-errors (json-parse " {\"a\":\"b\", \"c\":\"d\", \"e\": 2.74 } ")))
      ( b '(json-obj ("a" "b") ("c" "d") ("e" 2.74))))
  (if (equalp  a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 8 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 9
(let ((a (ignore-errors (json-parse " {\"a\":\"b\", \"c\":\"d\", \"e\": -2.74 } ")))
      ( b '(json-obj ("a" "b") ("c" "d") ("e" -2.74))))
  (if (equalp  a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 9 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 10
(let ((a (ignore-errors (json-parse "{\"a\":\"b\", \"c\":[1,2, 3, \"a b c\"]}")))
      ( b '(JSON-OBJ ("a" "b") ("c" (JSON-ARRAY 1 2 3 "a b c")))))
  (if (equalp  a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 10 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 11
(let ((a (ignore-errors (json-parse "[]")))
      ( b '(json-array)))
  (if (equalp  a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 11 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 12
(let ((a (ignore-errors (json-parse " [] ")))
      ( b '(json-array)))
  (if (equalp  a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 12 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 13
(let ((a (ignore-errors (json-parse " [ ] ")))
      ( b '(json-array)))
  (if (equalp  a b)
      (setq passed (1+ passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 13 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 14
(let ((a (ignore-errors (json-parse " [1, 2, 3 ] ")))
      ( b '(json-array 1 2 3)))
  (if (equalp  a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 14 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 15
(let ((a (ignore-errors (json-parse " [\"a b c\", \"d\" ] ")))
      ( b '(json-array "a b c" "d")))
  (if (equalp  a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 15 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 16
(let ((a (ignore-errors (json-parse "  [\"a b c\", 2, [3], \" d \" ]  ")))
      ( b '(json-array "a b c" 2 (json-array 3) " d ")))
  (if (equalp  a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 16 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 17
(let ((a (ignore-errors (json-parse " [[2,[3]],[[4,[5]]], 6, [\"w\"] ] ")))
      ( b '(JSON-ARRAY (JSON-ARRAY 2 (JSON-ARRAY 3))
	    (JSON-ARRAY (JSON-ARRAY 4 (JSON-ARRAY 5))) 6 (JSON-ARRAY "w"))))
  (if (equalp  a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 17 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 18
(let ((a (ignore-errors (json-parse "[\"a\", { \"ogg1\" : [\"q\", {\"ogg2\": {\"ogg3\": [1,2,[[3]]]}}, 4], \"la\":7}, 4]")))
      ( b '(JSON-ARRAY "a"
	    (JSON-OBJ
	     ("ogg1"
	      (JSON-ARRAY "q"
			  (JSON-OBJ
			   ("ogg2"
			    (JSON-OBJ
			     ("ogg3"
			      (JSON-ARRAY 1 2 (JSON-ARRAY (JSON-ARRAY 3)))))))
			  4))
	     ("la" 7))
	    4)))
  (if (equalp  a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 18 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 19
(let ((a (ignore-errors (json-parse "[{ \"oggetto1\" : [9, {\"ogg2\": {\"ogg3\": [1,2,[[3]]]}, \"a\":2}, 4], \"la\":7}, 3]")))
      ( b '(JSON-ARRAY
	    (JSON-OBJ
	     ("oggetto1"
	      (JSON-ARRAY 9
			  (JSON-OBJ
			   ("ogg2"
			    (JSON-OBJ
			     ("ogg3" (JSON-ARRAY 1 2 (JSON-ARRAY (JSON-ARRAY 3))))))
			   ("a" 2))
			  4))
	     ("la" 7))
	    3)))
  (if (equalp  a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 19 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 20
(let ((a (ignore-errors (json-parse "{\"uno\" : 1,

                  \"due\" : [ {\"due-uno\" : [[0], [1], [3]]},
                  
                            {\"due-due\" : [[4], [5], [6]]}]}")))
      ( b '(JSON-OBJ ("uno" 1)
	    ("due"
	     (JSON-ARRAY
	      (JSON-OBJ
	       ("due-uno"
		(JSON-ARRAY (JSON-ARRAY 0) (JSON-ARRAY 1) (JSON-ARRAY 3))))
	      (JSON-OBJ
	       ("due-due"
		(JSON-ARRAY (JSON-ARRAY 4) (JSON-ARRAY 5) (JSON-ARRAY 6)))))))))
  (if (equalp  a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 20 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 21
(let ((a (ignore-errors (json-parse "[ [ {\"a\" : [{\"b\":{\"c\":[[1,{\"d\":[2,[[3]]]}],[{\"e\":{\"f\":[4]}}]]},\"g\":[5,[6]]}], \"h\":2}],
                            [[\"i s p\", {\"k\": [[[7],8],9]}]] ]")))
      ( b '(JSON-ARRAY
	    (JSON-ARRAY
	     (JSON-OBJ
	      ("a"
	       (JSON-ARRAY
		(JSON-OBJ
		 ("b"
		  (JSON-OBJ
		   ("c"
		    (JSON-ARRAY
		     (JSON-ARRAY 1
				 (JSON-OBJ
				  ("d" (JSON-ARRAY 2 (JSON-ARRAY (JSON-ARRAY 3))))))
		     (JSON-ARRAY (JSON-OBJ ("e" (JSON-OBJ ("f" (JSON-ARRAY 4))))))))))
		 ("g" (JSON-ARRAY 5 (JSON-ARRAY 6))))))
	      ("h" 2)))
	    (JSON-ARRAY
	     (JSON-ARRAY "i s p"
	      (JSON-OBJ ("k" (JSON-ARRAY (JSON-ARRAY (JSON-ARRAY 7) 8) 9))))))))
  (if (equalp  a b)
      (setq passed (1+ passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 21 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 22
(let ((a (ignore-errors (json-parse "[}")))
      ( b nil))
  (if (equalp a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 22 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 23
(let ((a (ignore-errors (json-parse "{\"a\",\"b\"}")))
      ( b nil))
  (if (equalp a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 23 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 24
(let ((a (ignore-errors (json-parse "[{\"a\":2},]")))
      ( b nil))
  (if (equalp a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 24 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 25
(let ((a (ignore-errors (json-parse "{\"a\":\"b\",}")))
      ( b nil))
  (if (equalp a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 25 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 26
(let ((a (ignore-errors (json-parse "{\"a\": [1,2],\"b\":}")))
      ( b nil))
  (if (equalp a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 26 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 27
(let ((a (ignore-errors (json-parse "{a : 2}")))
      ( b nil))
  (if (equalp a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 27 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 28
(let ((a (ignore-errors (json-parse "{\"a\": b}")))
      ( b nil))
  (if (equalp a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 28 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 29
(let ((a (ignore-errors (json-parse "{1: 2}")))
      ( b nil))
  (if (equalp a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 29 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 30
(let ((a (ignore-errors (json-parse "[{ \"oggetto1\" : [9, {\"ogg2\": {\"ogg3\": [1,2,[[3]]]}, \"a\":2} 4], \"la\":7}, 3]")))
      ( b nil))
  (if (equalp a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 30 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 31
(let ((a (ignore-errors (json-parse "{ \"ogg{e}tto1\" : 3}")))
      ( b '(json-obj ("ogg{e}tto1" 3))))
  (if (equalp a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 31 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 32
(let ((a (ignore-errors (json-parse "{ \"ogg,etto1\" : 3}")))
      ( b '(json-obj ("ogg,etto1" 3))))
  (if (equalp a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 32 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 33
(let ((a (ignore-errors (json-parse "{ \" \" : 3}")))
      ( b '(json-obj (" " 3))))
  (if (equalp a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 33 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 34
(let ((a (ignore-errors (json-parse "{ \"a\"\"b\"}")))
      ( b nil))
  (if (equalp a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 34 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 35
(let ((a (ignore-errors (json-parse "{ \"a\" : \"}")))
      ( b nil))
  (if (equalp a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 35 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 36
(let ((a (ignore-errors (json-parse "{ \"a\" : \" \"}")))
      ( b '(json-obj ("a" " "))))
  (if (equalp a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 36 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 37
(let ((a (ignore-errors (json-parse "
                                     { 
                                       \"a\"
                                           :
                                             \"b\"
                                                   }
                                                     ")))
      ( b '(json-obj ("a" "b"))))
  (if (equalp a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 37 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 38
(let ((a (ignore-errors (json-parse "
                                     [ 
                                       \"a\"
                                           ,
                                             \"b\"
                                                   ]
                                                     ")))
      ( b '(json-array "a" "b")))
  (if (equalp a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 38 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 39
(let ((a (ignore-errors (json-parse "{ \"ogg[e]t:to1\" : 3}")))
      ( b '(json-obj ("ogg[e]t:to1" 3))))
  (if (equalp a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 39 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 40
(let ((a (ignore-errors (json-parse "{,}")))
      ( b nil))
  (if (equalp a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 40 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 41
(let ((a (ignore-errors (json-parse "")))
      ( b nil))
  (if (equalp a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 41 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 42
(let ((a (ignore-errors (json-parse "{ \"a \"b\"}")))
      ( b nil))
  (if (equalp a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 42 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test parse 43
(let ((a (ignore-errors (json-parse "{ \"a b\"}")))
      ( b nil))
  (if (equalp a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test parse 43 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))


;;; Test json-get

;; test get 1
(let ((a (ignore-errors (json-get (json-parse "{\"a\": [1, 2, 3]}") "a" 1)))
      ( b 2))
  (if (equalp  a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test get 1 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test get 2
(let ((a (ignore-errors (json-get (json-parse "{\"a\": [1, 2, 3], \"b c\": 4}") "b c")))
      ( b 4))
  (if (equalp  a b)
      (setq passed (1+ passed))
      (and (setq failed (1+ failed))
	   (format t "test get 2 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test get 3
(let ((a (ignore-errors (json-get (json-parse "{\"a\": \"b\"}") "a")))
      ( b "b"))
  (if (equalp  a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test get 3 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test get 4
(let ((a (ignore-errors (json-get (json-parse "{\"a\": [1,2,3]}") "a" 3)))
      ( b nil))
  (if (equalp  a b)
      (setq passed (1+ passed))
      (and (setq failed (1+ failed))
	   (format t "test get 4 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test get 5
(let ((a (ignore-errors (json-get (json-parse "{\"a\": [1,2,3]}") "b")))
      ( b nil))
  (if (equalp  a b)
      (setq passed (1+ passed))
      (and (setq failed (1+ failed))
	   (format t "test get 5 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

(defparameter g (json-parse "[ [ {\"a\" : [{\"b\":{\"c\":[[1,{\"d\":[2,[[3]]]}],[{\"e\":{\"f\":[4]}}]]},\"g\":[5,[6]]}], \"h\":2}],
                            [[\"i s p\", {\"k\": [[[7],8],9]}]] ]"))

;; test get 6
(let ((a (ignore-errors (json-get g 0 0 "a" 0 "b" "c" 0 1 "d" 1 0 0)))
      ( b 3))
  (if (equalp  a b)
      (setq passed (1+  passed))
      (and (setq failed (1+ failed))
	   (format t "test get 6 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test get 7
(let ((a (ignore-errors (json-get g 1 0 1 "k" 0 0 0)))
      ( b 7))
  (if (equalp  a b)
      (setq passed (1+ passed))
      (and (setq failed (1+ failed))
	   (format t "test get 7 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test get 8
(let ((a (ignore-errors (json-get g 0 0 "a" 0 "g" 1 0)))
      ( b 6))
  (if (equalp  a b)
      (setq passed (1+ passed))
      (and (setq failed (1+ failed))
	   (format t "test get 8 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test get 9
(let ((a (ignore-errors (json-get (json-parse "[1,2,3]") 1)))
      ( b 2))
  (if (equalp  a b)
      (setq passed (1+ passed))
      (and (setq failed (1+ failed))
	   (format t "test get 9 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test get 10
(let ((a (ignore-errors (json-get g "a" "b")))
      ( b nil))
  (if (equalp  a b)
      (setq passed (1+ passed))
      (and (setq failed (1+ failed))
	   (format t "test get 10 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test get 11
(let ((a (ignore-errors (json-get (json-parse "[1,2,3]") -1)))
      ( b nil))
  (if (equalp  a b)
      (setq passed (1+ passed))
      (and (setq failed (1+ failed))
	   (format t "test get 11 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test get 12
(let ((a (ignore-errors (json-get (json-parse "[0, [1,2,[3.14]]]") 1 2 0)))
      ( b 3.14))
  (if (equalp  a b)
      (setq passed (1+ passed))
      (and (setq failed (1+ failed))
	   (format t "test get 12 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test get 13
(let ((a (ignore-errors (json-get (json-parse "[0, [1,2,[3.14], {}]]") 1 3)))
      ( b '(json-obj)))
  (if (equalp  a b)
      (setq passed (1+ passed))
      (and (setq failed (1+ failed))
	   (format t "test get 13 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))

;; test get 14
(let ((a (ignore-errors (json-get (json-parse "[0, [1,2,[3.14], []]]") 1 3)))
      ( b '(json-array)))
  (if (equalp  a b)
      (setq passed (1+ passed))
      (and (setq failed (1+ failed))
	   (format t "test get 14 failed --> Expected: ~A Found: ~A~%" b a)))
  (setq tot (1+ tot)))


;;; Risultati
(if (= passed tot)
    (format t "~%All tests passed!")
    (format t "~%Run ~D tests: passed ~D, failed ~D" tot passed failed))
