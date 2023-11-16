
; not for m1 so far !!!!
; or at least very complicated as quicklisp does not have spec for M1/M2

; hence no sdl2; not sure why I add these into how-to-run this system though
; (ql:quickload "sdl2")
; (ql:quickload "sdl2/examples")
; (sdl2-examples:basic-test); this work under Intel Mac

; let us start without sdl2

; see https://ahefner.livejournal.com/20528.html
; and github to load the files under asm6502 (lisp)

; then load it 
; rlwrap sbcl --load "kwc-to-r<tab>

; temp solution to load the asd as defined

(push '*default-pathname-defaults* asdf:*central-registry*)

(asdf:load-system :asm6502)

; see https://lispcookbook.github.io/cl-cookbook/systems.html
; how you have the asm6502 system (but not nes though)

; (nes:setup-and-emulate "")
() ; you can do nothing but what you can do

(in-package :asm6502)

; when have issue as the package defined does not have exit/quit
; try to go back to cu or
;  (sb-ext:exit)

(defpackage :nes-test-1
  (:use :common-lisp :asm6502 :6502 :6502-modes ;
        :asm6502-nes 
        :asm6502-utility))

(in-package :nes-test-1)

(in-package :asm6502)


#|
(write-ines
 "/tmp/nes-test-1.nes"
 ())

 (write-ines
 "nes-test-1.nes"
 

 (let ((*context* (make-instance 'basic-context :address #x8000))
       (color (zp 0)))

   ;; Program Entry Point
   (set-label 'entry-point)
   (sei)                                ; Disable interrupts
   (cld)
   (ldx (imm #xFF))                     ; Init stack pointer
   (txs)
   (lda (imm 3))
   ;(sta color)
   (lda (imm #x00))
   ;(sta color)
   ; color whatever you do or not do always return #<ZP {70078CDAC3}>
   
;#|
   ;; Configure PPU
   (lda (imm #b10000000))               ; Enable VBlank NMI
   (sta (mem +ppu-cr1+))
   (lda (imm #b00000000))               ; Display off
   (sta (mem +ppu-cr2+))
   (jmp (mem *origin*))                 ; Spin.

   ;; VBlank Handler
   (set-label 'vblank-handler)
   (lda (mem +ppu-status+))             ; Clear NMI, reset high/low state
   (lda (imm #x3F))                     ; Program address #x3F00
   (sta (mem +vram-addr+))              ; ..write MSB
   (lda (imm #x00))
   (sta (mem +vram-addr+))              ; ..write LSB

   (inc color)                          ; Increment and load color
   (lda color)

   (lsr)                                ; Shift right two bits, so each
   (lsr)                                ; color appears for four frames.
   (sta (mem +vram-io+))                ; Write color to palete.

   (poke #x3F +vram-addr+)     ; Reset address due to palette latching.
   (poke #x00 +vram-addr+)
   (rti)

   ;; IRQ/Break Handler
   (set-label 'brk-handler)
   (rti)

   ;; Interrupt Vectors
   (advance-to +nmi-vector+)
   (dw (label 'vblank-handler)) ;; NMI
   (dw (label 'entry-point))    ;; RESET
   (dw (label 'brk-handler))    ;; BRK/IRQ
;|#
   (link *context*)
   (format t "hello, world asm6250~%")
   (format t "~A" color)
   ; )
   )
 )
;(exit)
|#
; the generated file can be loaded, well, anywhere even commodore 
; and definitely OpenEMU (like supertank and it)

; now try to run 

;  rlwrap sbcl --load "kwc<tab>

; see https://www.reddit.com/r/Common_Lisp/comments/14it7ag/asdfloadsystem/

; better to use load directory like 
;  ~/.config/common-lisp/source-registry.conf.d/


(asdf:load-asd "~/Documents/Github/asm6502/hacks/nes-hacks.asd")

; see https://lispcookbook.github.io/cl-cookbook/systems.html
; how you have the asm6502 system (but not nes though)

; (nes:setup-and-emulate "")
() ; you can do nothing but what you can do

; line 31 = value nil of ; (load "./hacks/music-demo.lisp")
(load "./hacks/nes-test-1.lisp")

; to see doc try
; but actually fuecu2 is better ??? and all goes somewhere on assembler ... nesmaker etc.

(list-all-packages)

(asdf:load-asd "~/Documents/Github/docbrowser/docbrowser.asd ")
(docbrowser:start-docserver)
; go to http://localhost:8080/

; there is a livedoc as well