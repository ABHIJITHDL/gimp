; Test methods of Edit module of the PDB
; When the image has multi-layers
; Multi-layer editing is new to GIMP v3

; tested elsewhere
; paste when:
;  - clip is not empty
;  - clip has one layers
;  - no selection



; setup
; Load test image that already has drawable
(define testImage (testing:load-test-image "wilber.png"))

; Add a layer
(define testLayer2
         (car (gimp-layer-new
                    testImage
                    21
                    22
                    RGB-IMAGE
                    "LayerNew"
                    50.0
                    LAYER-MODE-NORMAL)))
; Insert new layer
(assert `(gimp-image-insert-layer
            ,testImage
            ,testLayer2
            0 0))  ; parent, position within parent

; get all the root layers
; testImage has two layers at root.
(define testLayers (cadr (gimp-image-get-layers testImage)))
;testLayers is-a vector

; capture a ref to the first layer
(define testLayer (vector-ref testLayers 0))

; check the image has two layers
(assert `(= (car (gimp-image-get-layers ,testImage))
            2))

; check our local list of layers is length 2
(assert `(= (vector-length ,testLayers)
            2))




; tests

; copy when no selection

; copy returns true when no selection and copies entire drawables

; FIXME this should fail? the passed length does not match the length of list
; copy first of two
(assert-PDB-true `(gimp-edit-copy 1 ,testLayers))
; copy both of two
(assert-PDB-true `(gimp-edit-copy 2 ,testLayers))


; paste when:
;  - clip is not empty
;  - clip has two layers
;  - no selection
; returns the pasted layers, a vector of length two
(assert `(= (car (gimp-edit-paste
                   ,testLayer
                  TRUE)) ; paste-into
            2))

; paste is NOT floating
; the passed layer is moot: new layers are created.

; the image now has four layers
(assert `(= (car (gimp-image-get-layers ,testImage))
            4))

; the new layers were pasted centered at (0,0)
; the new layers are partially off the canvas

; The image i.e. canvas is NOT larger now
(assert `(= (car (gimp-image-get-width ,testImage))
            256))
; !!! Note that some layers, when selected,
; might not be visible, since the scrollbars are on the current canvas
; not the size of the bounding box of all the layers.

; But resizing gives a larger size
;;(assert `(gimp-image-resize-to-layers ,testImage))
;;(assert `(= (car (gimp-image-get-width ,testImage))
;;            373))




; test pasting into a layer whose origin is off the canvas
; don't resize and then paste into the new layer that is off canvas.
; the clip still has two layers

; get reference to one of the new layers
; it is top of stack, the first element in the vector of layers
(define testOffCanvasLayer (vector-ref (cadr (gimp-image-get-layers testImage))
                                       0))

(assert `(= (car (gimp-edit-paste
                   ,testOffCanvasLayer
                  TRUE)) ; paste-into
            2))
; The image now has six layers, extending to the upper left.
(assert `(gimp-image-resize-to-layers ,testImage))
(assert `(= (car (gimp-image-get-width ,testImage))
            490))


; copy-visible when image has many layers
; only puts one layer on clip
(assert-PDB-true `(gimp-edit-copy-visible ,testImage))

; TODO this tested elsewhere
; paste when:
;  - clip is not empty
;  - clip has one layers
;  - no selection
; returns the pasted layers, a vector of length one
(assert `(= (car (gimp-edit-paste
                   ,testLayer
                  TRUE)) ; paste-into
            1))


; TODO test when the selection is not empty


; TODO test paste-into FALSE

; TODO test pasting into empty image.


; for debugging individual test file:
;(gimp-display-new testImage)
