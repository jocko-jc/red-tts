# red-tts
text-to-speech experimentation with red-language on Windows and macOs

tts on Windows 10 and on macOs, using the red language
trial of unified code for both platforms

usage:

get-voices : list of available speakers on the computer

say "hello" : simple call to the tts function

call with parameters:
volume (from 0 to 100) :
say "-vol 10  hello"

rate (from -10 to 10) :
say "-r 5 -vol 30 hello everybody"

voice :
say "-r -3 -v Thomas hello" (not implemented on windows)

text file :
say "-r 2 -f corbeau.txt"
