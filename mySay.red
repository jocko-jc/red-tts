Red[
    Title: "Text to Speech"
    Author: "jocko"
    Date: 2-Aug-2017
    Purpose: "Test TTS functions for Windows and Mac OSx"
    Rights: ""
    Licence: "BSD-2"
    Usage: []
]

;--- lister les voix disponibles
get-voices: func [/local voices][
        voices: ""
        switch system/platform [
            windows [
               ; cmd-str: copy {powershell.exe Add-Type -AssemblyName System.speech
               ; $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
               ; $speak.GetInstalledVoices()}
                cmd-str: {powershell.exe "(New-Object -ComObject Sapi.SpVoice).GetVoices().item(0)"}
                ;call/console cmd-str
                call/output cmd-str voices ]
            macOS [ call/output {say -v ?} voices ]
        ]
        return voices
]


; --- synthèse 
say: func[str[string!] /local texte fichier rate volume cmd-str][ 

    digit:   charset "0123456789"
    letters: charset [#"a" - #"z" #"A" - #"Z" "àâéèêëôù"]
    special: charset "-."
    space: " "
    chars:   union union letters special digit
    word: [some chars]
    number: union digit special
    expression: [any [word | #" "  word]]

    fichier: copy "" 
    rate: copy ""
    volume: copy ""
    voice: copy ""
    texte: copy ""

    regle: [any 
        [
        "-f " copy fichier some word some space
        |"-r " copy rate some number some space
        |"-vol " copy volume some number some space
        |"-v " copy voice some word some space 
        ] 
        copy texte some expression ]

    parse str regle

    ;print rejoin [ "fichier " fichier ", rate : " rate ", volume : " volume  ", texte : " texte] 


    ;--- remplacer les apostrophes
    if (fichier <> "")   [ texte: read to-file fichier
                        replace/all texte "'" ""]

    if system/platform = 'windows [                   

        cmd-str: copy {powershell.exe Add-Type -AssemblyName System.speech
        $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer}
        append cmd-str newline
        ; ne fonctionne pas
        ;append cmd-str {$speak.SelectVoiceByHints('Male')}
        ; append cmd-str {$speak.SelectVoice('Microsoft Zira')}
        append cmd-str {$speak.SetVoice($speak.GetVoices().item(1))}

        if (rate <> "")  [
            append cmd-str newline
            append cmd-str rejoin ["$speak.Rate = "  rate ] ; de -10 à 10 / rate: nb de mots par mn sous osx
        ]
        if (volume <> "")  [
            append cmd-str newline
            append cmd-str rejoin ["$speak.Volume = " volume ] ; de 0 à 100 / seulement windows
        ]
        if (voice <> "")  [
        ;    append cmd-str newline
        ;    append cmd-str rejoin ["$speak.SelectVoice('"  voice "')"] 
        ]
        append cmd-str newline
        append cmd-str rejoin ["$speak.Speak('" texte "')"]
        ;append cmd-str newline
        ;append cmd-str {$speak.Dispose()}

        call/wait cmd-str
    ]

    if system/platform = 'macOS [
        
        cmd-str: copy {say }
        if (rate <> "")  [
            words-per-mn: (15 * to integer! (rate)) + 200
            ;print words-per-mn
            append cmd-str rejoin [" -r "  words-per-mn  " "] ; de -10 à 10 / rate: nb de mots par mn sous osx
        ]   
        if (voice <> "")  [
            print voice
            append cmd-str rejoin [" -v "  voice  " "] 
        ]   
        append cmd-str rejoin ["'" texte "'"]

        either (volume <> "")  [
            ; contrôle de volume pour mac
            ; lire le niveau actuel
            vv: ""
            call/output "osascript -e 'output volume of (get volume settings)'" vv
            
            ; changer le niveau
            call/wait rejoin ["osascript -e 'set volume output volume " volume  "'"]
            ;call/console "osascript -e 'get volume settings'" ; pour test
            
            ; prononcer
            call/wait cmd-str

            ; restaurer le niveau d'origine
            ; if vv = 0 [vv: 30] 
            call/wait rejoin ["osascript -e 'set volume output volume " vv "'"]
            ][
            ; sans contrôle de volume
            call/wait cmd-str 
            ]
        ]

]

; print what-dir
;print get-voices

; tests
say "bonjour à tous"
say "-r -3 -v Thomas bonjour les amis"
say "-vol 10  bonjour à tous"
; les voix dépendent de la plateforme
if system/platform = 'macOS [
    say "-vol 30  -v Amelie bonjour à tous"]
if system/platform = 'windows [
    say "-vol 30  -v Zira bonjour à tous"]

say "-r 5 -vol 30 bonjour à tous"
;say "-r 2 -f corbeau.txt"


