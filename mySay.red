Red[
    Title: "Text to Speech"
    Author: "jocko"
    Date: 2-Aug-2017
    Purpose: "Test TTS functions for Windows and Mac OSx"
    Rights: ""
    Licence: "BSD-2"
    Usage: {
        get-voices : list of available speakers on the computer 

        say "hello" : simple call to the tts function

        call with parameters:
        volume (from 0 to 100) :
        say "-vol 10  hello"
        rate (from -10 to 10) :
        say "-r 5 -vol 30 hello everybody"
        voice :
        say "-r -3 -v Thomas hello"
        for long voice names :
        say "-vol 30  -v <Microsoft Zira Desktop> hello everybody"
        text file :
        say "-r 2 -f corbeau.txt"
    }
]

;--- list the available voices
get-voices: func [/local voices][
        voices: ""
        switch system/platform [
            windows [
                cmd-str: copy {powershell.exe Add-Type -AssemblyName System.speech
                $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
                $speak.GetInstalledVoices().VoiceInfo.Name}
                call/output cmd-str voices ]
            macOS [ call/output {say -v ?} voices ]
        ]
        return voices
]


; --- tts function 
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

    regle: [
        any space
        any 
        [
        "-f " any space copy fichier some word some space
        |"-r " any space copy rate some number some space
        |"-vol " any space copy volume some number some space
        |"-v " any space thru "<" copy voice to ">" skip some space 
        |"-v " any space copy voice some word some space 
        ] 
        copy texte some expression ]

    parse str regle

    ;print rejoin [ "fichier " fichier ", rate : " rate ", volume : " volume  ", texte : " texte] 
    ;print voice

    ;--- replace the single quotes
    if (fichier <> "")   [ texte: read to-file fichier
                        replace/all texte "'" ""]

    if system/platform = 'windows [                   

        cmd-str: copy {powershell.exe Add-Type -AssemblyName System.speech
        $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer}
        
        if (rate <> "")  [
            append cmd-str newline
            append cmd-str rejoin ["$speak.Rate = "  rate ] ; between -10 and 10 / rate: nb of words per mn on macOS
        ]
        if (volume <> "")  [
            append cmd-str newline
            append cmd-str rejoin ["$speak.Volume = " volume ] ; between 0 and 100 
        ]
        if (voice <> "")  [
            append cmd-str newline
            append cmd-str rejoin ["$speak.SelectVoice('" voice "')" ]
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
            words-per-mn: (15 * to integer! (rate)) + 200  ; between -10 and 10 / rate: nb of words per mn on macOS
            ;print words-per-mn
            append cmd-str rejoin [" -r "  words-per-mn  " "] 
        ]   
        if (voice <> "")  [
            ;print voice
            append cmd-str rejoin [" -v "  voice  " "] 
        ]   
        append cmd-str rejoin ["'" texte "'"]

        either (volume <> "")  [
            ; level control macOS
            ; read the initial level
            vv: ""
            call/output "osascript -e 'output volume of (get volume settings)'" vv
            
            ; change the level
            call/wait rejoin ["osascript -e 'set volume output volume " volume  "'"]
            ;call/console "osascript -e 'get volume settings'" ; pour test
            
            ; pronounce
            call/wait cmd-str

            ; reset the initial level
            ; if vv = 0 [vv: 30] 
            call/wait rejoin ["osascript -e 'set volume output volume " vv "'"]
            ][
            ; without level control
            call/wait cmd-str 
            ]
        ]

]

; print what-dir
print get-voices

; --- tests
say "bonjour à tous"
say "-vol 10  bonjour à tous"
say "-r 3 -vol 30 bonjour à tous"

; --- voices depend upon the platform
if system/platform = 'macOS [
    say "-vol 30  -v Amelie bonjour à tous"
    say "-v Bruce hi everybody"]
if system/platform = 'windows [
    say "-vol 30  -v <Microsoft Zira Desktop> hi everybody"
    say "-v <Microsoft Hortense Desktop> bonjour à tous"
    ]
  
; test file ... in french
;say "-r 2 -f corbeau.txt"


