# Assembler för processor i TSEA83

#### Innehåll
Det här dokumentet behandlar hur man använder assemblern skriven i Python för att kompilera assembly-kod till den arkitekturen som specificeras i vhdl-delen av detta repo.

#### Syfte
Syftet med detta dokument är att ge läsaren insikt i hur assemblern används för att kompilera kod. Dokumentet har inte som syfte att utbilda läsaren i kompilatorns struktur eller hur den byggs ut.

#### Användning
Kod kompileras genom att köra följande kommando. Koden är testad med python 2.6 och 2.7. Det finns inga planer att stödja python 3 då detta inte finns hos ISY.
```
python assembler.py [FILNAMN]
```

Assemblern kommer kompilera koden och rapportera eventuella fel. Lyckas kompilering så skapas en fil med namnet `FILNAMN.out`. För att föra över koden till Nexys 3 används kommandot:
```
cat FILNAMN.out > /dev/ttyUSB0
```

#### Syntax
Assemblern stödjer relativt avancerad syntax med stöd för bland annat labels. Alla implementerade komponenter nämns nedan.

##### Labels
```
BAR:
[LABEL_NAME]:
```
Det är möjligt att deklarera labels som programmet kan hoppa till med hjälp av de olika instruktionerna för hopp. Eftersom kompilatorn inte tar hänsyn till vad för instruktioner som utför hopp så kompilerar kod som hoppar till variabler. Detta beteende är odefinierat då programminnet och arbetsminnet är skiljt.

##### Variabler
```
FOO = 1
[VARIABLE_NAME] = [VARIABLE_VALUE_HEX]
```
För att underlätta programmering stödjer kompilatorn deklaration av variabler. Dessa går att referera till i datafältet för instruktionerna LOAD och STORE och kan även användas i de mer avancerade uttrycken (IF, WHILE, osv). I variablerna kan endast hexadecimala tal lagras. Variabler kan deklareras flera gånger i programmet för att byta ut dess värde.

##### Register och alias
```
ALIAS 4 FOOBAR
ALIAS [REG_NR] [REG_ALIAS]
```
Att referera till register som ett hexadecimalt tal mellan 0 och F resulterar snabbt i svåröverskådlig kod, därför har kompilatorn stöd för att ge register alias som istället kan användas. Det går att byta ut registernummer i instruktioner och avancerade uttryck mot dess alias.

Alias kan skapas explicit genom att använda uttrycket `ALIAS [REG_NR] [REG_ALIAS]` eller implicit genom att ladda in en variabel i ett numrerat register `LOAD [REG_NR] [VARIABLE_NAME]`. All kod efter att ett alias deklarerats använder sig av följande alias tills det skrivs över av ett nytt. Notera att flera alias kan finnas för samma register, medan samma alias inte kan användas för flera register.

Exempel:
```
x = 5
y = 7

LOAD 0 x
LOAD 1 y
ALIAS 2 z

ADD z x y
# Register 2 (z) innehåller nu resultatet av 5 + 7
```

##### Instruktioner
```
[OP] (REG1) (REG2) (REG3) (DATA)

# Exempel
BRA F3B4
```
Antal register och data är specifika till formatet för respektive instruktion. Register kan anges i antingen i ett hexadecimalt tal mellan 0 och F eller via ett registeralias. Data kan antingen anges i hexadecimal eller som en referens till en label alternativt variabel. Notera att referenser till en label bara bör användas för instruktioner som hoppar. Tillgängliga instruktioner och dess namn finns i `vhdl/Instructions.txt`.

##### Kommentarer
```
# Kul!
#(COMMENT_CONTENT)
```
Kommentarer måste skrivas på en egen rad.

##### Loopar
```
WHILE [X] [CONDITION] [Y]
  (REPEATED_FUNCTIONALITY)
ENDWHILE
```
X och Y är variabler alternativt hårdkodad minnesadress till variabler eller registeralias. Register kan inte skrivas på talform. Noterbart är att denna sats genererar kod för att läsa in variablerna i register 0xD och 0xE vid varje upprepning och utökar också programmet med 5 st instruktioner. Tillåtna jämförelseoperationer är ==, !=, >=, och <=.

##### IF-satser
```
IF [X] [CONDITION] [Y]
  (CONDITIONAL_FUNCTIONALITY)
ENDIF
```
X och Y är variabler alternativt hårdkodad minnesadress till variabler eller registeralias. Register kan inte skrivas på talform. Noterbart är att denna sats genererar kod för att läsa in variablerna i register 0xD och 0xE och utökar därför programmet med 5 st instruktioner. Eftersom denna inläsning sker i början av loopar respektive IF-satser kan dessa samexistera utan några oönskade sidoeffekter. Tillåtna jämförelseoperationer är ==, !=, >=, och <=.

#### Planerad funktionalitet
- ELSE
- FOR-satser