\ console based minesweeper in forth

9 value width
9 value height
10 value nmines
36 16 * constant maxsz
create grid maxsz allot
variable c
create seed
32 word time find dup [if] time drop
[then] 0= [if] utime [then] ,
0 value newgame
0 value dead
80 constant termw
24 constant termh
2variable curs
0 0 curs 2!
create sizes
9 c, 9 c, 10 c,
16 c, 16 c, 40 c,
30 c, 16 c, 99 c,

: rand
  dup >r                  
  seed @ xor              
  12341357 *              
  seed @ xor              
  123 +                   
  seed @ xor       
  dup 0< if negate then
  dup 1+ seed +!       
  r> mod ;

: xy width * + grid + ;

: inb? over 0>= -rot < and ;

: in-bounds? height inb? swap width inb? and ;

: xy? xy c@ 1 and ;

: visible? xy c@ 2 and ;

: mark? xy c@ 4 and ;

: mark xy dup c@
  dup 4 and if 4 invert and else 4 or then
  swap c! ;

: xy+ rot + -rot + swap ;

: for-adj
  2 -1 do 2 -1 do
    >r 2dup r> i j rot >r xy+
    2dup in-bounds? if r@ execute else 2drop then r>
  loop loop drop 2drop ;

: n+ xy? if 1 c +! then ;

: n 0 c ! ['] n+ for-adj c @ ;

: .xy
  2dup visible? if
    2dup xy? if 2drop [char] *
    else n dup if [char] 0 + else drop [char] . then then
  else
    mark? if [char] X else [char] # then
  then
  emit space ;

: clear grid width height * erase ;

: place width height * rand
  begin dup grid + c@ 0= if grid + 1 swap c! exit then
    1+ width height * mod
  again ;

: reveal dup c@ 2 or swap c! ;

: reveal-all
  1 to dead
  width height * 0 do grid i + reveal loop ;

defer revadj

: reveal-adj
  2dup visible? if 2drop exit then
  2dup xy? if 2drop exit then
  2dup xy reveal
  2dup n if 2drop exit then
  ['] revadj for-adj ;

' reveal-adj is revadj

: reveal-empty
  2dup n 0= if reveal-adj else 2drop then ;

: reset
  1 to newgame
  0 to dead
  clear
  nmines 0 do place loop ;

: ok-first? 2dup 2dup xy? 0= -rot n 0= and ;

: reveal
  newgame if ok-first? 0= if
    begin reset ok-first? until
  then then
  2dup xy? if 2drop reveal-all
  else 2dup xy reveal 2dup n 0= if ['] reveal-adj for-adj else 2drop then then
  0 to newgame ;

: .grid
  height 0 do
    width 0 do i j .xy loop cr
  loop ;

: offs+ swap 2* swap termw 2/ width - termh 2/ height 2/ - xy+ ;

: at-cursor curs 2@ offs+ at-xy ;

: draw-grid
  page
  height 0 do
    0 i offs+ at-xy
    width 0 do i j .xy loop cr
  loop ;

: draw-guide
  0 termh 1- at-xy
  dead 0= if ." h/j/k/l)move m)mark w)sweep " then
  ." r)reset q)quit 1/2/3)size" ;

: draw
  draw-grid draw-guide at-cursor ;

: curs+ curs 2@ xy+
  2dup in-bounds? if curs 2! at-cursor
  else 2drop then ;

: winner?
  dead if 0 exit then
  width height * 0 do
    grid i + c@ 3 and 0= if unloop 0 exit then
  loop -1 ;

: win
  reveal-all draw
  0 0 at-xy ." You win!"
  at-cursor ;

: set-size
  3 * sizes +
  dup c@ to width 1+
  dup c@ to height 1+
  dup c@ to nmines
  curs 2@ height 1- min swap width 1- min swap curs 2!
  reset draw ;

: play
  reset
  draw
  begin
    key dup case
    [char] q of page bye endof
    [char] r of reset draw endof
    [char] 1 of 0 set-size endof
    [char] 2 of 1 set-size endof
    [char] 3 of 2 set-size endof
    endcase
    dead 0= if case
    [char] h of -1  0 curs+ endof
    [char] j of  0  1 curs+ endof
    [char] k of  0 -1 curs+ endof
    [char] l of  1  0 curs+ endof
    [char] m of curs 2@ mark draw endof
    [char] w of curs 2@ reveal draw endof
    endcase
    else drop then
    winner? if win then
  again ;

play

