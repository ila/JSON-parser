%%%% -*- Mode: Prolog -*-
%%%% json-parsing.pl

%%% aggiornato al 21/11/17

%%% json_parse(JSONString, Object).
%%% vero se una JSONString (una stringa SWI Prolog o un atomo Prolog)
%%% può venire scorporata come stringa, numero, json_obj o json_array


json_parse(JSONAtom, json_obj(ParsedObject)) :-
    atom_string(JSONAtom, JSONString),
    term_string(JSON, JSONString),
    JSON =.. [{} , Object],
    json_obj(Object, ParsedObject),
    !.


%%% array
%%% ParsedObjects può anche essere vuoto, rip
%%% va malissimo in errore con più di un oggetto
json_parse(JSONAtom, json_obj(ParsedObjects, Name, json_array(List))) :-
    atom_string(JSONAtom, JSONString),
    term_string(JSON, JSONString),
    JSON =.. [{}, Object],
    ParsedArray =.. [':', Name, List],
    is_value(Name),
    json_array(List),
    !.
  

%%% json_get(JSON_obj, Fields, Result).
%%% che risulta vero quando Result è recuperabile seguendo la catena
%%% di campi presenti in Fields (una lista) a partire da JSON_obj
%%% D - ricorda di togliere gli underscore che ho messo perchè se no
%%% rompeva coi singleton

%%% caso in cui Fields è un numero

json_get(JSON_obj, _Fields, _Result) :-
    json_obj(JSON_obj).



%%% caso in cui Field è una stringa SWI Prolog
%%% D - ricorda di togliere gli underscore che ho messo perchè se no
%%% rompeva coi singleton

json_get(_JSON_obj, _Field, _Result).



%%% json_obj(Object).

json_obj([], []) :- !.

json_obj([Member], [ParsedMember]) :-
    json_member(Member, ParsedMember),
    !.

%%% per l'array
json_obj(Object, [ParsedMember | ParsedMembers]) :-
    Object =.. [',', Member | MoreMembers],
    json_member(Member, ParsedMember),
    json_obj(MoreMembers, ParsedMembers),
    !.


%%% json_array(Elements)
%%% I - ci ho provato, la logica era di fare overloading
%%% del metodo obj in modo da separare nome dell'array
%%% e lista e poi fare il controllo sulla lista
%%% forse manca un caso baso

json_array([]) :- !.

json_array([Value | MoreElements]) :-
    is_value(Value),
    json_array(MoreElements),
    !.


%%% json_member(Members)

json_member(Member, (Attribute, Value) ) :-
    Member =.. [':', Attribute, Value],
    json_pair(Attribute, Value),
    !.

json_member(Member, (Attribute, Value) ) :-
     atom(Attribute),
     atom_string(Attribute, StrAttribute),
     Member =.. [':', StrAttribute, Value],
     json_pair(StrAttribute, Value),
     !.
    
%% json_member([PairString | MembersStrings]) :-
%%     atomics_to_string(Pair, ":", PairString),
%%     json_pair(Pair),
%%     json_member(MembersStrings).


%%% json_pair(Pair)
%%% questo e' un atomo

json_pair(Attribute, Value) :-
    string(Attribute),
    is_value(Value).


%%% json_value(Value)

is_value([]) :- !.

is_value(Value) :-
    string(Value), !.

is_value(Value) :-
    number(Value), !.

is_value(Value) :-
    json_obj(Value), !.


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
%%% D - rimossi gli apici da open(Filename, ...) perchè altrimenti dava
%%% singleton su FileName

json_write(JSON, FileName) :-
    json_parse(JSON, O),
    atom_string(O, String),
    open(FileName, write, File),
    write(File, String),
    nl(File),
    close(File).

%%%% end of file -- json-parsing.pl

%%% inizio test
is_json_object(json_obj([Member | Members])) :-
    is_json_member(json_member(Member)),
    is_json_object(json_obj(Members)).
 
is_json_object(json_obj([])).
 
is_json_member(json_member(Pair)) :-
    Pair =.. [_, Attribute, Value],
    is_json_pair(json_pair(Attribute, Value)).
 
is_json_pair(json_pair(_Attribute, Value)) :-
    is_value(Value).
