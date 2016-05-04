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

##### Instruktioner
En instruktion skrivs på formatet
```
OP [REG1] [REG2] [REG3] [DATA]

# Exempel
BRA F3B4
```
Alla register och data är specifika till formatet för respektive instruktion. Register och data kan antingen anges i hexadecimal eller som en referens till en label alternativt variabel. Tillgängliga insturktioner och dess namn finns i `vhdl/Instructions.txt`. Register borde inte mappas till variabler eller labels (TODO).

##### Variabler
En variabel skrivs på formatet
```
FOO=1
FOO_POINTER=FOO
```

Endast hexadecimala värden eller referenser till andra variabler är tillåtna värden. Alla variabler måste ha ett startvärde. Notera att hopp till variabler är tillåtet.

##### Labels
En label skrivs på formatet
```
FAIL:
```
En label genererar en NOP-instruktion, borde den göra det?

##### Kommentarer
En kommentar skrivs på formatet
```
# Kul!
```
Kommentarer måste skrivas på en egen rad.

#### Planerad funktionalitet
- IF-satser
- Loopar
