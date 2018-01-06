?- consult('C:/Users/Utente/Desktop/Progetto LP/jason/json-parsing.pl').
?- run_tests.

:- style_check(-singleton).

:- begin_tests(json_parse).

%------------------------------------------------------------------------------
test(oggetto_1) :- json_parse('{}', json_obj([])).
test(oggetto_2) :- json_parse('{"a":"b"}', json_obj([("a", "b")])).
test(oggetto_3) :- json_parse('{"a":"b", "c":"d"}', json_obj([("a", "b"), ("c", "d")])).
test(oggetto_4) :- json_parse('{"a":"b", "c":"d", "e":"f", "g":"h"}',
				json_obj([("a", "b"), ("c", "d"), ("e", "f"), ("g", "h")])).
test(oggetto_5) :- json_parse('{"a":1, "c":2}', json_obj([("a", 1), ("c", 2)])). 				
%------------------------------------------------------------------------------

%------------------------------------------------------------------------------
test(array_1) :- json_parse('[]', json_array([])).
test(array_2) :- json_parse('["a", "b"]', json_array(["a", "b"])).
test(array_3) :- json_parse('[1, 2, 3, 4]', json_array([1, 2, 3, 4])).
test(array_4) :- json_parse('[1, "a", 2, "b"]',
				json_array([1, "a", 2, "b"])).
%------------------------------------------------------------------------------

%------------------------------------------------------------------------------
test(oggetto_05) :- json_parse('{"a":[1,2,["b", "c"]]}', json_obj([("a", json_array([1, 2, json_array(["b", "c"])]))])).
test(oggetto_6) :- json_parse('{"a":{"b":[1,{"c":[2,[3]]}]}}',
                      json_obj([("a", json_obj([("b", json_array([1, json_obj([("c", json_array([2, json_array([3])]))])]))]))])).
test(oggetto_7) :- json_parse('{"a":"b", "c":[{"d":{"e":4}, "f":[5,6,[7,[8]]]}]}',
          json_obj([("a", "b"),  ("c", json_array([json_obj([("d", json_obj([("e", 4)])),  ("f", json_array([5, 6, json_array([7, json_array([8])])]))])]))])).

%------------------------------------------------------------------------------

%------------------------------------------------------------------------------
test(array_5) :- json_parse('[1,[2, {"a":"b"}]]', json_array([1, json_array([2, json_obj([("a", "b")])])])).
test(array_6) :- json_parse('["a", {"b":[1,{"c":[2,[3]]}]}]',
           json_array(["a", json_obj([("b", json_array([1, json_obj([("c", json_array([2, json_array([3])]))])]))])])).
test(array_7) :- json_parse('[1,[2, [3, [4, {"a":5}]]]]',
               json_array([1, json_array([2, json_array([3, json_array([4, json_obj([("a", 5)])])])])])).

%------------------------------------------------------------------------------

%------------------------------------------------------------------------------
test(oggetto_10) :- json_parse("{\" a \" : \"b\"}", json_obj([(" a ", "b")])).
test(oggetto_11) :- json_parse("{  'a ': 'b' , ' c ' : 'd'  }", json_obj([("a ", "b"), (" c ", "d")])).
test(oggetto_12) :- json_parse('  {\' a\' :\'b\', \'c\': \' d \', \' e \':\'f\', \'g\':\'h\'}  ',
				json_obj([(" a", "b"), ("c", " d "), (" e ", "f"), ("g", "h")])).
test(oggetto_19) :- json_parse("{'a':'b','c':'d',\"e\":\"f\"}", json_obj([("a", "b"), ("c", "d"), ("e", "f")])).
test(oggetto_20) :- json_parse('{\'a\':\'b\',\'c\':\'d\',"e":"f"}', json_obj([("a", "b"), ("c", "d"), ("e", "f")])).
test(oggetto_21) :- json_parse('{"a":"b","c":"d",\'e\':\'f\'}', json_obj([("a", "b"), ("c", "d"), ("e", "f")])).
%------------------------------------------------------------------------------

%------------------------------------------------------------------------------
test(oggetto_13, fail) :- json_parse("{a : 4}", _).
test(oggetto_14, fail) :- json_parse("{\"a\": b }", _).
test(oggetto_15, fail) :- json_parse("{'a':2, c:'d'}", _).
test(oggetto_22, fail) :- json_parse('{"nome" : "Arthur", "cognome" : "Dent"}', json_obj([json_array(_) | _])).
%------------------------------------------------------------------------------

%------------------------------------------------------------------------------
test(oggetto_16) :- json_parse('{"fo,32": "43"}', json_obj([("fo,32", "43")])).
test(oggetto_17) :- json_parse('{"fo{32}bar": "43"}', json_obj([("fo{32}bar", "43")])).
test(oggetto_18) :- json_parse('{"nome" : "Arthur", "cognome" : "Dent"}', json_obj([("nome", N) | _])).
%------------------------------------------------------------------------------
:- end_tests(json_parse).

:- begin_tests(json_get).

%------------------------------------------------------------------------------
test(get_1) :- json_parse("{\"a\":\"b\"}", K), json_get(K, ["a"], "b").
test(get_2) :- json_parse("{'a':'b', 'c':'d'}", K), json_get(K, ["c"], "d").
test(get_3) :- json_parse('{"a":{"b":[1,{"c":[2,[3]]}]}}', K), json_get(K, ["a", "b", 1, "c", 0], 2).
test(get_4) :- json_parse('{"a":"b", "c":[{"d":{"e":4}, "f":[5,6,[7,[8]]]}]}', K), json_get(K, ["c", 0, "d", "e"], 4).
test(get_5) :- json_parse('{"uno" : 1,

                  "due" : [ {"due-uno" : [[0], [1], [3]]},
                  
                            {"due-due" : [[4], [5], [6]]}]}',
                JSONOBJ),
                
     json_get(JSONOBJ, ["due", 1, "due-due", 2, 0], 6).

test(get_6) :- json_parse('{"nome" : "Zaphod",
                    "heads" : ["Head1", "Head2"]}', 
                Z),   json_get(Z, ["heads", 1], "Head2").

test(get_7) :- json_parse("{\"a\":\"b\"}", K), json_get(K, "a", "b").
test(get_8) :- json_parse('{"a":{"b":[1,{"c":[2,[3]]}]}}', K), json_get(K, ["a", "b", 1, "c", 0], 2).
test(get_9) :- json_parse("{\"a\":\"b\"}", K), json_get(K, [a], "b").
test(get_10) :- json_parse('{"a":{"b":[1,{"c":[2,[3]]}]}}', K), json_get(K, [a, b, 1, c, 0], 2).
test(get_11) :- json_parse('{"nome": "Arthur", "cognome": "Dent"}', O), json_get(O, "nome", R).
%------------------------------------------------------------------------------

%------------------------------------------------------------------------------
test(get_12) :- json_parse('[1,2,3]', K), json_get(K, [1], 2).
test(get_13) :- json_parse('[1, ["a", [2]]]', K), json_get(K, [1, 1, 0], 2).
test(get_14) :- json_parse('[1, [{"a":[2,[3]]}]]', K), json_get(K, [1, 0, "a", 1, 0], 3).
%------------------------------------------------------------------------------

:- end_tests(json_get).