%%% json_parse(JSONString, Object).
%%% vero se una JSONString (una stringa SWI Prolog o un atomo Prolog)
%%% può venire scorporata come stringa, numero, json_obj o json_array

json_parse(JSONString, json_obj(Members)) :-
    split_string(JSONString, ",", "{}" ,Members),
    json_obj(Members), !.

json_parse(JSONString, json_array(Elements)) :-
    split_string(JSONString, "", "'", Elements),
    json_array(Elements).


%%% json_get(JSON_obj, Fields, Result).
%%% che risulta vero quando Result è recuperabile seguendo la catena di campi
%%% presenti in Fields (una lista) a partire da JSON_obj

%%% json_obj(Members).
%%%

json_obj(Members) :-
    json_member(Members), !.

%%% json_array(Elements)

json_array([]) :- !.
json_array([Value | MoreElements]) :-
           is_value(Value),
           json_array(MoreElements).


%%%  json_member(Members)

json_member([]) :- !.
json_member([PairString | MembersStrings]) :-
    split_string(PairString, ":", " \" ", [Attribute, Value]),
    json_pair(Attribute, Value),
    json_member(MembersStrings).


%%%  json_pair(Pair)

json_pair(Attribute, Value) :-
    string(Attribute),
    is_value(Value).


%%%  json_value(Value)

is_value(Value) :-
    string(Value), !.

is_value(Value) :-
    number(Value), !.

is_value(Value) :-
    json_obj(Value), !.
