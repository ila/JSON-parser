%%%% -*- Mode: Prolog -*-
%%%% json-parsing.pl

%%% aggiornato al 23/11/17

%%% json_parse(JSONString, Object).
%%% vero se una JSONString (una stringa SWI Prolog o un atomo Prolog)
%%% può venire scorporata come stringa, numero, json_obj o json_array

%%% object
json_parse({}, json_obj([])) :- !.

json_parse(JSONAtom, json_obj(ParsedObject)) :-
    atom(JSONAtom),
    atom_string(JSONAtom, JSONString),
    term_string(JSON, JSONString),
    JSON =.. [{}, Object],
    json_obj(Object, ParsedObject),
    !.

json_parse(JSON, json_obj(ParsedObject)) :-
    JSON =.. [{}, Object],
    json_obj(Object, ParsedObject),
    !.

%%% array
json_parse(ArrayAtom, json_array(ParsedArray)) :-
    atom(ArrayAtom),
    atom_string(ArrayAtom, ArrayString),
    term_string(Array, ArrayString),
    json_array(Array, ParsedArray),
    !.

json_parse(Array, json_array(ParsedArray)) :-
    json_array(Array, ParsedArray),
    !.


%%% json_get(JSON_obj, Fields, Result).
%%% che risulta vero quando Result è recuperabile seguendo la catena
%%% di campi presenti in Fields (una lista) a partire da JSON_obj


%%% caso in cui Fields è una lista

%%% json_get(json_obj(ParsedObject), List, Result).
    



%%% caso in cui Fields è una stringa SWI Prolog

json_get(json_obj(ParsedObject), String, Result) :-
    string(String),
    get_string(ParsedObject, String, Result),
    !.

    
%%% caso in cui Fields è un numero

json_get(json_obj(ParsedArray), N, Result) :-
    number(N).
   

get_string([(Item1, Item2) | _], String, Result) :-
    String = Item1,
    Result = Item2,
    !.

get_string(String, [(_) | Items], Result) :-
    get_string(String, Items, Result),
    !.

get_string(_, [], _) :-
    fail,
    !.

%%% json_obj(Object).

json_obj([], []) :- !.

json_obj([Member], [ParsedMember]) :-
    json_member(Member, ParsedMember),
    !.

json_obj(Member, [ParsedMember]) :-
    json_member(Member, ParsedMember),
    !.

json_obj(Object, [ParsedMember | ParsedMembers]) :-
    Object =.. [',', Member | MoreMembers],
    json_member(Member, ParsedMember),
    json_obj(MoreMembers, ParsedMembers),
    !.

json_obj([Object], [ParsedMember | ParsedMembers]) :-
    Object =.. [',', Member | MoreMembers],
    json_member(Member, ParsedMember),
    json_obj(MoreMembers, ParsedMembers),
    !.


%%% json_array(Elements)

json_array([], []) :- !.

json_array([Value | MoreElements], [ParsedValue | ParsedElements]) :-
    is_value(Value, ParsedValue),
    json_array(MoreElements, ParsedElements),
    !.


%%% json_member(Members)

json_member(Member, (Attribute, ParsedValue) ) :-
    Member =.. [':', Attribute, Value],
    json_pair(Attribute, Value, ParsedValue),
    !.

json_member(Member, (Attribute, ParsedValue) ) :-
     atom(Attribute),
     atom_string(Attribute, StrAttribute),
     Member =.. [':', StrAttribute, Value],
     json_pair(StrAttribute, Value, ParsedValue),
     !.


%%% json_pair(Pair)

json_pair(Attribute, Value, ParsedValue) :-
    string(Attribute),
    is_value(Value, ParsedValue).

%%% json_value(Value)

is_value([], []) :- !.

is_value(Value, Value) :-
    string(Value), !.

is_value(Value, Value) :-
    number(Value), !.

is_value(Value, ParsedValue) :-
    json_parse(Value, ParsedValue), !.


%%% json_load(FileName, JSON)
%%% ha successo se riesce a costruire un oggetto JSON
%%% NB QUESTA ROBA LEGGE ANCHE I \n
%%% potrebbe essere utile read_file_to_codes?

json_load(FileName, JSON) :-
    open(FileName, read, File),
    read_string(File, _, O),
    json_parse(O, JSON),
    close(File).


%%% json_write(FineName, JSON)
%%% scrive l'oggetto JSON sul file FileName

json_write(JSON, FileName) :-
    json_parse(JSON, O),
    atom_string(O, String),
    open(FileName, write, File),
    write(File, String),
    nl(File),
    close(File).

%%%% end of file -- json-parsing.pl

