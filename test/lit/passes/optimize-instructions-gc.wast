;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.
;; RUN: wasm-opt %s --optimize-instructions --enable-reference-types --enable-gc -S -o - \
;; RUN:   | filecheck %s

(module
  (import "env" "get-i32" (func $get-i32 (result i32)))

  (type $struct (struct
    (field $i8  (mut i8))
    (field $i16 (mut i16))
    (field $i32 (mut i32))
    (field $i64 (mut i64))
  ))

  (type $array (array (mut i8)))

  ;; These functions test if an `if` with subtyped arms is correctly folded
  ;; 1. if its `ifTrue` and `ifFalse` arms are identical (can fold)
  ;; CHECK:      (func $if-arms-subtype-fold (result anyref)
  ;; CHECK-NEXT:  (ref.null extern)
  ;; CHECK-NEXT: )
  (func $if-arms-subtype-fold (result anyref)
    (if (result anyref)
      (i32.const 0)
      (ref.null extern)
      (ref.null extern)
    )
  )
  ;; 2. if its `ifTrue` and `ifFalse` arms are not identical (cannot fold)
  ;; CHECK:      (func $if-arms-subtype-nofold (result anyref)
  ;; CHECK-NEXT:  (if (result anyref)
  ;; CHECK-NEXT:   (i32.const 0)
  ;; CHECK-NEXT:   (ref.null extern)
  ;; CHECK-NEXT:   (ref.null func)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $if-arms-subtype-nofold (result anyref)
    (if (result anyref)
      (i32.const 0)
      (ref.null extern)
      (ref.null func)
    )
  )

  ;; Stored values automatically truncate unneeded bytes.
  ;; CHECK:      (func $store-trunc (param $x (ref null $struct))
  ;; CHECK-NEXT:  (struct.set $struct $i8
  ;; CHECK-NEXT:   (local.get $x)
  ;; CHECK-NEXT:   (i32.const 35)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (struct.set $struct $i16
  ;; CHECK-NEXT:   (local.get $x)
  ;; CHECK-NEXT:   (i32.const 9029)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (struct.set $struct $i8
  ;; CHECK-NEXT:   (local.get $x)
  ;; CHECK-NEXT:   (call $get-i32)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $store-trunc (param $x (ref null $struct))
    (struct.set $struct $i8
      (local.get $x)
      (i32.const 0x123) ;; data over 0xff is unnecessary
    )
    (struct.set $struct $i16
      (local.get $x)
      (i32.const 0x12345) ;; data over 0xffff is unnecessary
    )
    (struct.set $struct $i8
      (local.get $x)
      (i32.and ;; truncating bits using an and is unnecessary
       (call $get-i32)
       (i32.const 0xff)
      )
    )
  )

  ;; Similar, but for arrays.
  ;; CHECK:      (func $store-trunc2 (param $x (ref null $array))
  ;; CHECK-NEXT:  (array.set $array
  ;; CHECK-NEXT:   (local.get $x)
  ;; CHECK-NEXT:   (i32.const 0)
  ;; CHECK-NEXT:   (i32.const 35)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $store-trunc2 (param $x (ref null $array))
    (array.set $array
      (local.get $x)
      (i32.const 0)
      (i32.const 0x123) ;; data over 0xff is unnecessary
    )
  )
)
