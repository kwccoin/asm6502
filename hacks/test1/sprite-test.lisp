
(defpackage :sprite-test-1
  (:use :common-lisp
        :6502
        :6502-modes
        :asm6502
        :asm6502-utility
        :asm6502-nes))

(in-package :sprite-test-1)

(defvar *path* #.*compile-file-pathname*)
(defun asset-path (filename) (merge-pathnames filename *path*))

;; I'm going to try this slightly differently this time..
(defparameter *global-context* (make-instance 'basic-context :address #x8000))
(setf *context* *global-context*)       ; yuck.

;;;; Globals

(defparameter vblank-flag (zp #xFF))

(defparameter *sprite-x* (zp #xF0))
(defparameter *sprite-y* (zp #xF1))
(defparameter *oamidx* (zp #xFF))

(defparameter *oam-shadow* #x0200)


;;;; Code

(defun oam-flag-value (flag)
  (let ((tmp (assoc flag '((:fliph . 64)
                           (:flipv . 128)
                           (:fg . 0)
                           (:bg . 32)))))
    (when (null tmp)
      (error "Unknown flag ~A" flag))
    (cdr tmp)))

(defmacro defsprite (name &body body)
  `(procedure ,name ;;',(list :sprite name)
     (ldy *oamidx*)
     (mapcar
      (lambda (spec)
        (destructuring-bind (x y tile palette &rest flags) spec
          ;; Write Y coordinate
          (lda *sprite-y*)
          (unless (zerop y)
            (clc)
            (adc (imm y)))
          (sta (aby *oam-shadow*))
          (iny)
          ;; Write tile index
          (lda (imm tile))
          (sta (aby *oam-shadow*))
          (iny)
          ;; Write flags
          (lda (imm (logior palette (reduce #'+ (mapcar #'oam-flag-value flags)))))
          (sta (aby *oam-shadow*))
          (iny)
          ;; Write X coordinate
          (lda *sprite-x*)
          (unless (zerop x)
            (clc)
            (adc (imm x)))
          (sta (aby *oam-shadow*))
          (iny)))
      ',body)
     (sty *oamidx*)
     (rts)))

(defsprite dude1
  (0 0 #x00 1)
  (8 0 #x01 1)
  (0 8 #x10 0)
  (8 8 #x11 0))

(procedure reset
  (sei)
  (cld)
  (poke #b00010000 +ppu-cr1+)         ; NMI off during init.
  (poke #b00000000 +ppu-cr2+)         ; Do turn the screen off too..
  (ldx (imm #xFF))                    ; Set stack pointer
  (txs)

  ;; Init sound hardware
  (poke 0 #x4015)                     ; Silence all channels
  (poke #x40 #x4017)                  ; Disable IRQ !!

  (as/until :negative (bita (mem +ppu-status+))) ; PPU warmup interval
  (as/until :negative (bita (mem +ppu-status+))) ; (two frames)

  (poke 0 vblank-flag)
  (poke #b10001000 +ppu-cr1+)         ; Enable NMI

  ;; Palette init
  (jsr 'wait-for-vblank)
  (jsr 'wait-for-vblank)
  (jsr 'wait-for-vblank)
  (ppuaddr #x3F00)
  (let ((bg #x1B))
    (dolist (color (list bg #x2D #x3D #x30  bg #x03 #x13 #x23
                         bg #x2D #x3D #x30  bg #x05 #x15 #x25
                         bg #x1d #x16 #x37  bg #x1d #x13 #x37))
     (poke color +vram-io+)))

  ;; Main loop - wait for vblank, reset PPU registers, do sprite DMA.
  (with-label :loop

    (jsr 'reset-sprites)
    (poke 40 *sprite-x*)
    (poke 80 *sprite-y*)
    (jsr 'dude1)

    (poke 90 *sprite-x*)
    (jsr 'dude1)

    (jsr 'wait-for-vblank)
    (poke 0 +spr-addr+)
    (poke (msb *oam-shadow*) +sprite-dma+)
    (poke #b10001000 +ppu-cr1+)
    (poke #b00010100 +ppu-cr2+)

    (jmp (mem :loop))))

(procedure reset-sprites
  (ldx (imm 0))
  (lda (imm 255))
  (as/until :zero
    (sta (abx *oam-shadow*))
    (dex)))

(procedure wait-for-vblank
  (lda (imm 0))
  (sta vblank-flag)
  (as/until :not-zero (lda vblank-flag))
  (lda (imm 0))
  (sta vblank-flag)
  (rts))

(procedure brk-handler (rti))

(procedure vblank-handler
  (inc vblank-flag)
  (rti))

;;;; Interrupt vectors

(advance-to +nmi-vector+)
(dw (label 'vblank-handler))
(dw (label 'reset))
(dw (label 'brk-handler))

;;;; Write ROM image

(write-ines "/tmp/sprite1.nes"
            (link *context*)
            :chr (concatenate 'vector
                              (ichr:encode-chr (ichr:read-gif (asset-path "spr0.gif")))
                              (ichr:encode-chr (ichr:read-gif (asset-path "spr0.gif")))))
