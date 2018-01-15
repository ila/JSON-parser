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

REALIZZAZIONE COMMON LISP
La realizzazione Common Lisp deve fornire due funzioni. 
Una funzione json-parse che accetta in ingresso una stringa e produce una struttura simile a quella illustrata 
per la realizzazione Prolog, una funzione json-get che accetta un oggetto JSON 
(rappresentato in Common Lisp, così come prodotto dalla funzione json_parse) e una serie di “campi”, 
recupera l’oggetto corrispondente. 
Un campo rappresentato da N (con N un numero maggiore o uguale a 0) rappresenta un indice di un array JSON. 

La sintassi degli oggetti JSON in Common Lisp è: 
•	Object = ’(’ json-obj members ’)’ 
•	Object = ’(’ json-array elements ’)’ e ricorsivamente: 
•	members = pair* 
•	pair = ’(’ attribute value ’)’ 
•	attribute = <atomo Common Lisp> | <stringa Common Lisp>
•	number = <numero Common Lisp>
•	value = string | number | Object 
•	elements = value*

L’idea di base per la realizzazione del parser è la divisione ricorsiva dell’oggetto JSON in più parti e 
il passaggio di attributi/oggetti/array alle rispettive funzioni per il controllo della validità della sintassi 
e la trasformazione delle coppie attribute-value in cons cells, e dell’array in una lista. 

Prima del parsing effettivo, divido la stringa in una lista di singoli caratteri, i quali verranno ricompattati 
in stringhe in base ai doppi apici, e i numeri vengono compattati e convertiti dai caratteri 
usando parse-integer o parse-float in base al fatto che contengano il carattere "." .

Sono state introdotte alcune funzioni ausiliarie per il controllo, il parsing dei valori, 
l’invertibilità dell’oggetto parsato. 

La funzione json-get ha un campo (opzionale) e una lista di campi 
utile per fare i controlli e scendere in profondità.
Si appoggia a search-array che effettua una ricerca in base all’indice dell’array.


Le principali funzioni utilizzate sono:
•	JSON-PARSE controlla se l’argomento è una stringa, trasforma la stringa in lista, 
	chiama CLEAN-CHARLIST che rimuove spazi, tab e invii e poi passa il risultato a JSON-PARSE-CHARLIST.

•	JSON-PARSE-CHARLIST controlla che le parentesi siano bilanciate e a seconda che siano graffe o quadre 
	chiama l’opportuna funzione sui valori all’interno delle parentesi.

•	PARSE-MEMBERS usando degli accumulatori e dei contatori per il bilanciamento degli apici, divide le coppie 
	attributo-valore che poi saranno controllate singolarmente da PARSE-VALUE.

•	PARSE-ARRAY controlla che i valori dell’array siano stringhe, numeri oppure oggetti JSON sempre 
	tramite PARSE-VALUE.

•	JSON-GET che restituisce il valore ottenuto seguendo una sequenza ordinata di stringhe, e l’equivalente 
	per array SEARCH-ARRAY.

•	REVERT-OBJ e REVERT-ARRAY per trasformare da sintassi Common Lisp a JSON, costruisce ricorsivamente 
	una stringa (tramite concatenate) usando un accumulatore e la restituisce nel caso base.

•	JSON-LOAD e JSON-WRITE per l’I/O da file.
