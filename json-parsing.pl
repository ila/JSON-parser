%%%% -*- Mode: Prolog -*-
%%%% json-parsing.pl

%%% aggiornato al 17/11/17

%%% json_parse(JSONString, Object).
%%% vero se una JSONString (una stringa SWI Prolog o un atomo Prolog)
%%% può venire scorporata come stringa, numero, json_obj o json_array

json_parse(JSONString, json_obj(Members)) :-
    string_concat("{", MemberString2, JSONString),
    string_concat(MemberString, "}", MemberString2),
    atomics_to_string(Members, ",", MemberString),
    json_obj(Members), !.

json_parse(JSONString, json_array(Elements)) :-
    split_string(JSONString, "", "'", Elements),
    json_array(Elements).


%%% json_get(JSON_obj, Fields, Result).
%%% che risulta vero quando Result è recuperabile seguendo la catena
%%% di campi presenti in Fields (una lista) a partire da JSON_obj

%%% caso in cui Fields è un numero

json_get(JSON_obj, Fields, Result) :-
    json_obj(JSON_obj).
    
    

%%% caso in cui Field è una stringa SWI Prolog

json_get(JSON_obj, Field, Result).



%%% json_obj(Members).

json_obj(Members) :-
    json_member(Members), !.

%%% json_array(Elements)

json_array([]) :- !.
json_array([Value | MoreElements]) :-
           is_value(Value),
           json_array(MoreElements).


%%% json_member(Members)

json_member([]) :- !.
json_member(['']) :- !.
json_member([PairString | MembersStrings]) :-
    atomics_to_string(Pair, " : ", PairString),
    json_pair(Pair),
    json_member(MembersStrings).


%%% json_pair(Pair)

json_pair([Attribute, Value]) :-
    atom_string(Attribute, AttributeString),
    atom_string(Value, ValueString),
    string(AttributeString),
    is_value(ValueString).


%%% json_value(Value)

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

json_write(JSON, FileName) :-
    json_parse(JSON, O),
    atom_string(O, String)
    open('FileName', write, File),
    write(File, String),
    nl(File),
    close(File).

%%%% end of file -- json-parsing.pl

