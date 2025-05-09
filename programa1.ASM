; This is a basic template file for writing 48K Spectrum code.

AppFilename             equ "NewFile"                   ; What we're called (for file generation)

AppFirst                equ $8000                       ; First byte of code (uncontended memory)

                        zeusemulate "48K","ULA+"        ; Set the model and enable ULA+


; Start planting code here. (When generating a tape file we start saving from here)

                        org AppFirst                    ; Start of application

AppEntry                LD BC, (MesA)                   ; Cargamos en C el contenido de MesA
                        LD A, C                         ; Cargamos en el acumulador el contenido de B
                        LD BC, (MesB)                   ; Cargamos en C el contenido de MesB
                        ADD C                           ; Sumamos el contenido de C en el acumulador
                        SRL A                           ; Movemos 1 bit a la derecha para dividir
                        LD (RomanKey), A                ; Cargamos en RomanKey el contenido de A
                        LD B, RomanKey-TextoOriginal    ; Cargamos en B el tamaño del textoOriginal para crear un bucle
                        LD IX, TextoOriginal            ; Cargamos en IX la dirección de memoria de TextoOriginal
                        LD IY, TextoCifrado             ; Cargamos en IY la dirección de memoria de TextoCifrado
BucleCifrado            LD A, (IX)                      ; Cargamos en el acumulador el contenido de IX
                        LD DE, (RomanKey)               ; Cargamos en E el contenido de RomanKey
                        ADD E                           ; Sumamos el contenido de E en el acumulador para calcular el nuevo caracter ASCII
                        LD (IY), A                      ; Cargamos en IY el nuevo caracter ASCII
                        INC IX                          ; Incrementamos IX para pasar al siguiente caracter
                        INC IY                          ; Incrementamos IY para pasar al siguiente caracter
                        DJNZ BucleCifrado               ; Cerramos el bucle restando 1 a B hasta llegar a 0 y, va llamando a BucleCifrado
                        LD IX, TextoCifrado             ; Cargamos en IX la dirección de memoria de TextoCifrado
                        LD IY, TextoDescifrado          ; Cargamos en IY la dirección de memoria de TextoDescifrado
                        LD B, RomanKey-TextoOriginal    ; Cargamos en B el tamaño del textoOriginal para crear un bucle
BucleDescifrado         LD A, (IX)                      ; Cargamos en el acumulador el contenido de IX
                        LD DE, (RomanKey)               ; Cargamos en E el contenido de RomanKey
                        SUB E                           ; Sumamos el contenido de E en el acumulador para calcular el nuevo caracter ASCII
                        LD (IY), A                      ; Cargamos en IY el nuevo caracter ASCII
                        INC IX                          ; Incrementamos IX para pasar al siguiente caracter
                        INC IY                          ; Incrementamos IY para pasar al siguiente caracter
                        DJNZ BucleDescifrado            ; Cerramos el bucle restando 1 a B hasta llegar a 0 y, va llamando a BucleCifrado
FINAL                   halt                            ; Final del codigo
                        jp FINAL                        ; Final del codigo


; Stop planting code after this. (When generating a tape file we save bytes below here)
AppLast                 equ *-1                         ; The last used byte's address

MesA                    defb 1                          ; Mes de nacimiento de uno del grupo
MesB                    defb 1                          ; Mes de nacimiento de uno del grupo
TextoOriginal           defb "THAIS HABET NIGROS NIVEOS LAECANIA DENTES" ; Texto original
RomanKey                defs 1                          ; Se guardará el valor de la clave
TextoCifrado            defs RomanKey-TextoOriginal     ; Guarda el texto cifrado
TextoDescifrado         defs RomanKey-TextoOriginal     ; Guarda el texto descifrado
; Generate some useful debugging commands

                        profile AppFirst,AppLast-AppFirst+1     ; Enable profiling for all the code

; Setup the emulation registers, so Zeus can emulate this code correctly

Zeus_PC                 equ AppEntry                            ; Tell the emulator where to start
Zeus_SP                 equ $FF40                               ; Tell the emulator where to put the stack

; These generate some output files

                        ; Generate a SZX file
                        output_szx AppFilename+".szx",$0000,AppEntry    ; The szx file

                        ; If we want a fancy loader we need to load a loading screen
;                        import_bin AppFilename+".scr",$4000            ; Load a loading screen

                        ; Now, also generate a tzx file using the loader
                        output_tzx AppFilename+".tzx",AppFilename,"",AppFirst,AppLast-AppFirst,1,AppEntry ; A tzx file using the loader


