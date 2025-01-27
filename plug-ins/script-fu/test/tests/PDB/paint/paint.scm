; Test painting operations on drawable

; The operand is a subset of the drawable
; For operations on the total image, see image-ops.scm
; For operations on a total layer, see layer-ops.scm

; Not currently testing pixels were changed,
; only that the operations says it succeeded.


; Define an aux testing function
; that tests the "-default" kind of paint operation.
; Takes an operation (first-class function)
; The operation must have the signature (layer, num_strokes, stroke array).
; All the <paint-op>-default PDB procedures have that signature.
(define (test-paint-op-default paint-op)
  ; the PDB procedure paint-op succeeds
  (assert `(,paint-op
              ,testLayer      ; target
              2               ; num-strokes
              #(4.0 4.0))))    ; float array))




;              setup
(define testImage (car (gimp-image-new 21 22 RGB)))

(define
  testLayer (car (gimp-layer-new
                    testImage
                    21
                    22
                    RGB-IMAGE
                    "LayerNew"
                    50.0
                    LAYER-MODE-NORMAL)))
; assert layer is not inserted in image


; paint ops fail until layer is added to image
(assert-error `(gimp-airbrush ,testLayer 50.0 ; pressure
                        2               ; num-strokes
                        #(4.0 4.0))    ; float array
              (string-append
                "Procedure execution of gimp-airbrush failed on invalid input arguments: "))
                ; "Item 'LayerNew#2' (10) cannot be used because it has not been added to an image"))


; adding layer to image succeeds
(assert `(gimp-image-insert-layer
            ,testImage
            ,testLayer
            0  ; parent
            0  ))  ; position within parent



; airbrush

(assert `(gimp-airbrush
            ,testLayer
            50.0 ; pressure
            2               ; num-strokes
            #(4.0 4.0)))    ; float array

; with two strokes
(assert `(gimp-airbrush
            ,testLayer
            50.0 ; pressure
            4    ; num-strokes
            #(4.0 4.0 8.0 8.0)))    ; float array

; with stroke out of bounds of image
(assert `(gimp-airbrush
            ,testLayer
            50.0  ; pressure
            4     ; num-strokes
            #(4.0 4.0 800.0 800.0)))    ; float array



; clone

; where source and target are same.
; stroke coords in the target.
; FIXME crashes
;(assert `(gimp-clone
 ;           ,testLayer      ; affected i.e. target
 ;           ,testLayer      ; source
 ;           CLONE-IMAGE     ; clone type
 ;           1.0 1.0         ; source coord x,y is not a vector
 ;           2               ; num-strokes
 ;           #(4.0 4.0)))    ; float array

; TODO CLONE-PATTERN




; eraser

(assert `(gimp-eraser
            ,testLayer  ; target
            4                      ; num-strokes
            #(4.0 4.0 800.0 800.0) ; float array
            BRUSH-HARD         ; hardness
            PAINT-CONSTANT))   ; PaintApplicationMode

(assert `(gimp-eraser-default
            ,testLayer  ; target
            4                      ; num-strokes
            #(0.0 0.0 800.0 800.0) ; float array
            ))



; FIXME crashes
; heal
;(assert `(gimp-heal
;            ,testLayer      ; affected i.e. target
;            ,testLayer      ; source
;            1.0 1.0         ; source coord x,y is not a vector
;            2               ; num-strokes
;            #(4.0 4.0)))    ; float array



; convolve
(assert `(gimp-convolve
            ,testLayer      ; affected i.e. target
            99.9999999999   ; pressure
            CONVOLVE-BLUR   ; type
            2               ; num-strokes
            #(4.0 4.0)))    ; float array



; dodgeburn
(assert `(gimp-dodgeburn
            ,testLayer      ; affected i.e. target
            66.0            ; exposure
            DODGE-BURN-TYPE-DODGE ; type, BURN or DODGE
            TRANSFER-MIDTONES ; transfer mode
            2               ; num-strokes
            #(4.0 4.0)))    ; float array


; pencil
; See below, only tested in default kind.



; smudge
(assert `(gimp-smudge
            ,testLayer      ; affected i.e. target
            0.0             ; pressure
            2               ; num-strokes
            #(4.0 4.0)))    ; float array




; Test the "-default" kinds of paint ops
; These are convenience methods, taking fewer args.
; The args default from the tool settings.

; In alphabetic order

(test-paint-op-default gimp-airbrush-default)
; FIXME crashes
;(test-paint-op-default gimp-clone-default)
(test-paint-op-default gimp-convolve-default)
(test-paint-op-default gimp-dodgeburn-default)
; FIXME crashes
;(test-paint-op-default gimp-heal-default)
(test-paint-op-default gimp-paintbrush-default)
; !!! gimp-pencil is not named gimp-pencil-default
; but has the same signature as other default paint ops.
(test-paint-op-default gimp-pencil)
(test-paint-op-default gimp-smudge-default)


; For any paint op,
; <2 control points is error
(assert-error `(gimp-airbrush
                  ,testLayer
                  50.0 ; pressure
                  1        ; num-strokes
                  #(4.0))  ; float array
                "Invalid value 1 for argument 2: expected value between 2 and 2147483647")

; The binding requires a Scheme vector for C float array,
; not a list, here a literal i.e. quoted.
(assert-error `(gimp-airbrush
                  ,testLayer
                  50.0 ; pressure
                  2            ; num-strokes
                  `(4.0 49.0))  ; strokes
                "in script, expected type: vector for argument 4 to gimp-airbrush")