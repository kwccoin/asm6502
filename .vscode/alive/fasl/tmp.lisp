;(ql:quickload "sdl2")
;(ql:quickload "sdl2/examples")
; (sdl2-examples:basic-test); this work 

(push '*default-pathname-defaults* asdf:*central-registry*)

(asdf:load-system :asm6502)

; (nes:setup-and-emulate "")
()