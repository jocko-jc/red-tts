# red-tts
text-to-speech experimentation with red-language on Windows and macOs

tts on Windows 10 and on macOs, using the red language.

Trial of unified code for both platforms

NB: for older windows versions (i.e XP and 7), use simple-say.red, (based on vbs, instead of powershell not always available on these platforms) 

usage:

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
