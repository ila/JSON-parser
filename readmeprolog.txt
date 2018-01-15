INTRODUZIONE
Lo sviluppo di applicazioni web su Internet, ma non solo, richiede di scambiare dati fra applicazioni eterogenee, 
ad esempio tra un client web scritto in Javascript e un server, e viceversa. 
Uno standard per lo scambio di dati molto diffuso è lo standard JavaScript Object Notation, o JSON. 

Lo scopo di questo progetto è di realizzare due librerie, una in Prolog e l’altra in Common Lisp, 
che costruiscano delle strutture dati che rappresentino degli oggetti JSON a partire dalla loro rappresentazione 
come stringhe.

La sintassi delle stringhe JSON
•	JSON ::= Object | Array
•	Object ::= '{}' | '{' Members '}'
•	Members ::= Pair | Pair ',' Members
•	Pair ::= String ':' Value
•	Array ::= '[]' | '[' Elements ']'
•	Elements ::= Value | Value ',' Elements
•	Value ::= JSON | Number | String
•	Number ::= Digit+ | Digit+ '.' Digit+ Digit ::= 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
•	String ::= '"' AnyCharSansDQ* '"' | '’' AnyCharSansSQ* '’'
•	AnyCharSansDQ ::= <qualunque carattere (ASCII) diverso da '"'>
•	AnyCharSansSQ ::= <qualunque carattere (ASCII) diverso da '’'>

Dalla grammatica data, un oggetto JSON può essere scomposto ricorsivamente nelle seguenti parti:
1.	Object
2.	Pair
3.	Array
4.	Value
5.	String
6.	Number

Esempi
L'oggetto vuoto:
{}

L'array vuoto:
[]

Un oggetto con due "items":
{"nome": "Arthur", "cognome": 'Dent'}

Un oggetto complesso, contenente un sotto-oggetto, che a sua volta contiene un array di numeri 
(notare che, in generale, gli array non devono necessariamente avere tutti gli elementi dello stesso tipo)
{
	"modello": "SuperBook 1234",
	"anno di produzione": 2014,
	"processore":
		{
		"produttore": "EsseTi",
		"velocità di funzionamento (GHz)": [1, 2, 4, 8]
		}
}

Un altro esempio tratto da Wikipedia (una possibile voce di menu)
{
	"type": "menu",
	"value": "File",
	"items":
	[
		{"value": "New", "action": "CreateNewDoc"},
		{"value": "Open", "action": "OpenDoc"},
		{"value": "Close", "action": "CloseDoc"}
	]
}

REALIZZAZIONE PROLOG
La realizzazione in Prolog del parser richiede la definizione di due predicati: `json_parse/2` e `json_get/3`.
Il predicato `json_parse/2` è definibile come: `json_parse(JSONString, Object)`.
che risulta vero se JSONString (una stringa SWI Prolog o un atomo Prolog) può venire scorporata come stringa, numero, o nei termini composti:
•	`Object = json_obj(Members)`
•	`Object = json_array(Elements)`

e ricorsivamente:
•	`Members = []` or
•	`Members = [Pair | MoreMembers]`
•	`Pair = (Attribute, Value)`
•	`Attribute = <string SWI Prolog>`
•	`Number = <numero Prolog>`
•	`Value = <string SWI Prolog> | Number | Object`
•	`Elements = []` or
•	`Elements = [Value | More elements]`

Il predicato json_get/3 è definibile come: `json_get(JSON_obj, Fields, Result)`. che risulta vero quando `Result` 
è recuperabile seguendo la catena di campi presenti in `Fields` (una lista o una stringa) a partire da `JSON_obj`. 
Un campo rappresentato da `N` (con `N` un numero maggiore o uguale a 0) corrisponde a un indice di un array JSON.

Per il parser anche qui divido ricorsivamente l'oggetto JSON in sottoparti valide, controllarne la sintassi, 
fino ad arrivare ad analizzare gli elementi più innestati come i Value e generare dunque una nuova struttura, 
ovvero un termine json_obj contenente una lista di sottotermini contenenti le coppie, o un json_array 
contenente una lista di sottovalues da restituire come conversione del JSON passato in origine, se valido ovviamente.

Sono state aggiunte diverse funzioni ausiliarie per il controllo, il parsing dei valori, 
l’invertibilità dell’oggetto parsato. 

La funzione json_get ha un campo (una lista, un numero o una stringa) in base a ciò che intendo cercare nel json_obj
o json_array che sia.
Si appoggia a due predicati get_string che ricerca l'attributo passato come parametro all'interno di un oggetto
e get_index che ricerca l'elemento con index passato come parametro all'interno di un array.
I singoli caratteri vengono ricompattati in stringhe in base ai doppi apici, 
e i numeri vengono convertiti dalle stringhe usando parse-integer più qualche funzione aggiuntiva per 
convertire i numeri in floating point e negativi.

I principali predicati utilizzati sono:
•	json_parse/2, il quale cerca di trasformare la stringa (o atomo) JSON in un termine SWI Prolog così da 
	potergli applicare l'operatore =.. per rimuovere le parentesi graffe usando '{}' e chiamare json_obj/2
	in caso si tratti di un oggetto, oppure chiamare il json_array/2 in caso si tratti di array, 
	tornando in entrambi i casi il parsato.

•	json_obj/2, il quale cerca di applicare l'operatore =.. per dividere le coppie usando ',', prenderne una per volta
	e passarle al json_member/2, da cui ottiene i membri parsati con cui comporre una lista.

•	json_member/2, il quale cerca di applicare l'operatore =.. per dividere attributo e value usando ':' per poi
	validarli separatamente, chiamando json_pair/4, oltre che ricostruire la coppia coi valori parsati da esso.

•	json_pair/4, il quale controllerà che l'attributo sia una stringa passando il value al predicato is_value/2,
	compattando poi il value parsato con l'attributo
	
•	is_value/2, il quale controllerà che esso sia un valore numerico, una stringa o un complesso 
	json_obj/json_array e ritornerà il valore parsato.

•	json_get/3 che restituisce il valore ottenuto seguendo una sequenza ordinata di stringhe o index dato un 
	json_obj o un json_array.

•	json_load/2 e json_write/2 per l’I/O da file.

•	json_revert/2 per per trasformare da sintassi Prolog a JSON, costruisce ricorsivamente 
	una stringa facendo effettivamente il percorso inverso del json_parse/2.
