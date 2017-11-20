is_json_object(json_obj([Member | Members])) :-
    is_json_member(json_member(Member)),
    is_json_object(json_obj(Members)).

is_json_object(json_obj([])).

is_json_member(json_member(Pair)) :-
    Pair =.. [_, Attribute, Value],
    is_json_pair(json_pair(Attribute, Value)).

is_json_pair(json_pair(_Attribute, Value)) :-
    is_value(Value).

is_value(Value) :-
    string(Value), !.

is_value(Value) :-
    number(Value), !.

is_value(Value) :-
    json_obj(Value), !.
