Red[
    Title: "Text to Speech"
    Author: "jocko"
    Date: 25-Aug-2017
    Purpose: "Test TTS functions for Windows and Mac OSx"
    Rights: ""
    Licence: "BSD-2"
    Usage: {
        for old windows versions (uses vbs)
        for recent windows versions (win8.1, win10), and for Mac OSx, use mysay.red (using PowerShell)
        
        say "hello" : simple call to the tts function

        call with refinements:
        volume (from 0 to 100) :
        say/volume  "hello" 10
        rate (from -10 to 10) :
        say/rate/volume  " hello everybody" 5 30
        voice :
        say/voice "hello" 1
        alternative parameter changes using xml sapi specs :
        say "<voice required='Language=409'> A U.S. English voice should speak this. </voice>"
        say "<voice required='Language=40c'> Voici une voix francaise </voice>"
        say "<lang langid='40c'>Salut à tous</lang>"
    }
]



say: func [str[string!]  /rate rateval /volume volval /voice voiceId][
    ; version windows compatible winXP, win7
    cmd-file: %speak-test.vbs
    write cmd-file {Dim Speak
    Set Speak=CreateObject("sapi.spvoice")
    }

    if rate [write/append cmd-file   rejoin ["Speak.Rate = " rateval newline]] 
    if volume [write/append cmd-file   rejoin ["Speak.Volume = " volval newline]]
    if voice [write/append cmd-file  rejoin ["set Speak.Voice = Speak.GetVoices().Item(" voiceId ")" newline]] 
    
    write/append cmd-file rejoin [{Speak.Speak "}  str {"} newline]
    ;print read cmd-file
 
    call/wait rejoin ["start " cmd-file] 
    wait 1
    call rejoin ["del " cmd-file]
    wait 1
]

;-- tests
say "hello"
say/rate/volume "ceci est un test" 1 60 
say/rate/volume "et ceci un autre test" 5 30 
say/voice "voici une voix" 0
say/voice "et voici une autre voix" 1 
say "<voice required='Language=409'> A U.S. English voice should speak this. </voice>"
say "<voice required='Language=40c'> Voici une voix francaise </voice>"
say "<lang langid='40c'>Salut à tous..</lang>"
