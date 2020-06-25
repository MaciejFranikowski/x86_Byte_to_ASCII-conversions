SYSEXIT  = 1
SYSREAD  = 3
SYSWRITE = 4
STDIN    = 0
STDOUT   = 1
EXIT     = 0

#segment danych
.data

bajtyIN:
#tworze 50 bajtowy bufor o etykiecie bajtyIn
#bede wczytywac do niego dane ze strumienia
.space 50

bajtyOUT:
#bufor 150 bajtowy, 3x wiekszy od wejsciowego
#bo dla kazdego bajtu, ktory odczytwamy, wypisujemy 3
.space 150

iloscZnakow:
#bufor 4 bajtowy, bedzie zawierac ilosc liczb wczytanych z strumienia
#wybieram 4 bajty, zeby dalo sie prowadzic na nim operacje jak na danych long
.space 4

spacja:
#tworze bit, za pomoca dyrektywy .byte, zawiera on kod spacji (0x20)
.byte ' ;

.text
.globl _start
_start:

#umieszczam dane w odpowiednich rejestrach, w celu wywoalania funkcji systemowej READ
movl $SYSREAD, %eax
movl $STDIN, %ebx
movl $bajtyIN, %ecx
movl $50, %edx
int $0x80

#funckja systemowa READ, zwraca do akumulatora ilosc wczytanych znakow
#przenosze zawartosc rejestru %eax pod adres iloscZnakow
movl %eax, iloscZnakow

#do rejestrow %edi i %ecx wrzucam wartosc 0, bede uzywal tych rejestro jako iteratorow
movl $0 , %edi
movl $0 , %ecx

edycja:
#rozpoczynam edycje pobranych ze strumienia danych

#zeruje rejestr %eax
movl $0 , %eax
#przenosze do rejesetru %ebx liczbe 16 (dziesietnie)
#bedzie to moj dzielnik w nadchodzacym dzieleniu
movl $0x10 , %ebx
#przenosze dane z adresu bajtyIn + ecx (ktore jest pozniej inkrementowane aby
#uzyskac dostep do kolejnych bajtow), do nizszego bajtu w rejestrze %eax
movb bajtyIN(%ecx), %al
incl %ecx
#instrukcja przygotowujace dane z rejestru eax do dzielenia
#tworzy z nich podwojne slowo %edx:%eax
cdq
#wykonywane jest dzielenie przez zawartosc %ebx
#calkowita czesc wyniku ilorazu zapisania jest w %eax
#reszta z dzielenia zapisana jest w %edx
divl %ebx

#sprawdzam czy calkowita czesc wyniku ilorazu jest >= 10 
#robie to, poniewaz w zalenzosci czy wynik jest > lub < nalezy dodac inna wartosc
#zeby otrzymac poprawny kod ascii
cmpb $0x0a , %al
jge wiekszeOd10
#przenosze bajt wyniku pod adres bajtyOUT + edi
movb %al, bajtyOUT(%edi)
#dodaje odpowiednia wartosc do tego wyniku
addb $0x30, bajtyOUT(%edi)
#skok do wykonywania blizniaczej operacji na reszcie z dzielenia
#nie chcemy wykonac kodu dla sytuacji gdzie wynik jest >=10
jmp reszta 
wiekszeOd10:
movb %al, bajtyOUT(%edi)
addb $0x37, bajtyOUT(%edi)

#blizniaczy kod do operacji na calkowitej czesci wyniku ilorazu
#odpowiednio zwiekszam iterator %edi aby odwolywac sie do kolejnych bajtow pod adresem bajtyOUT
reszta:
incl %edi
cmpb $0x0a, %dl
jge wiekszeOd10Reszta
movb %dl, bajtyOUT(%edi)
addb $0x30, bajtyOUT(%edi)
jmp koniec
wiekszeOd10Reszta:
movb %dl, bajtyOUT(%edi)
addb $0x37, bajtyOUT(%edi)

#tutaj bardzo podobnie, na adres bajtyOUT + edi podajemy nasz zapisny kod spacji
#musze go przeniesc wczesniej do %al, bo nie jest wspierana operacja movb MEMORY, MEMORY
koniec:
incl %edi
movb spacja, %al
movb %al, bajtyOUT(%edi)
incl %edi

#warunek dla petli, skok do etykiety edycja
cmpl %ecx, iloscZnakow
jg edycja

#przygotowanie do wywolania funkcji systemowej WRITE
#chce aby wypisane zostalo za kazdym razem 3x tyle ile wczytano
#wykonuje wiec mnozenie 3*iloscZnakow, wynik umieszczam w %edx (dlugosc wypisywanego ciagu)
movl $3, %edx
imull iloscZnakow, %edx 
movl $SYSWRITE, %eax
movl $STDOUT, %ebx
movl $bajtyOUT, %ecx
int $0x80

#petla, ktora sprawdza czy skonczyly sie dane wczytywane ze strumienia
cmpl $0, iloscZnakow
jne _start

#zakonczenie programu wywolaniem funkcji systemowej EXIT
movl $SYSEXIT, %eax
movl $EXIT, %ebx
int $0x80
