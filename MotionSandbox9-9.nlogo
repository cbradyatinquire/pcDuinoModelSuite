breed [ people person ]
breed [ sensors sensor ]
breed [ walls wall ]

sensors-own [ domain active bin-x bin-y base-color  my-plot  my-plot-pen]
people-own [ p0 domain motion-script base-color animation-frame actual-location ]


globals [ 
  bin-width
  stage-boundary-patches
  bin-patches
  track-ycors
  
  clock
  clockstep
  
  mouse-down-at
  dragged
  
  plot-colors
  detectables
]

to init-wall
  set shape "square"
  set color yellow - 2
end

to setup-globals
  set stage-boundary-patches no-patches
  set bin-patches no-patches
  set bin-width 10
  set track-ycors (list (max-pycor / 2) (min-pycor / 2))
  set mouse-down-at []
  set dragged nobody
  set plot-colors [ red orange brown green blue magenta ]
  set detectables no-turtles
end

to setup-stage
  set stage-boundary-patches no-patches
  set stage-boundary-patches (patch-set stage-boundary-patches patches with [ pxcor = min-pxcor + bin-width ] )
  set stage-boundary-patches (patch-set stage-boundary-patches patches with [ pycor = max-pycor and pxcor > (min-pxcor + bin-width) ] )
  set stage-boundary-patches (patch-set stage-boundary-patches patches with [ pycor = min-pycor and pxcor > (min-pxcor + bin-width) ] )
  set stage-boundary-patches (patch-set stage-boundary-patches patches with [ pxcor = max-pxcor ] )
  set stage-boundary-patches (patch-set stage-boundary-patches patches with [ pycor = 0 and pxcor > (min-pxcor + bin-width) ] )
  
  ask stage-boundary-patches [ sprout-walls 1 [ init-wall ] ]
  ask patches with [ pxcor >= 0 and pxcor mod 6 = 0 ] [set pcolor .8] 
end

to setup-bin
  set bin-patches patches with [ pxcor < min-pxcor + bin-width ]
  ask bin-patches [ set pcolor blue - 3 ]
  ask patch (min-pxcor + bin-width / 5) (min-pycor / 2) [ sprout-sensors 1 [ set heading 90 set shape "motiondetector" set size max-pycor / 5 set color gray set base-color red set my-plot-pen "one" ] ]
  ask patch (min-pxcor + bin-width / 5) (max-pycor / 2) [ sprout-sensors 1 [ set heading 90 set shape "motiondetector" set size max-pycor / 5 set color gray set base-color red set my-plot-pen "one"] ]
  
  ask patch (min-pxcor + 2 * bin-width / 5) (min-pycor / 2) [ sprout-sensors 1 [ set heading 90 set shape "motiondetector" set size max-pycor / 5 set color gray set base-color orange set my-plot-pen "two" ] ]
  ask patch (min-pxcor + 2 * bin-width / 5) (max-pycor / 2) [ sprout-sensors 1 [ set heading 90 set shape "motiondetector" set size max-pycor / 5 set color gray set base-color orange set my-plot-pen "two" ] ]
  
  ask patch (min-pxcor + bin-width / 2) (min-pycor / 3) [ sprout-sensors 1 [ set heading 180 set shape "motiondetector" set size max-pycor / 5 set color gray set base-color brown set my-plot-pen "three" ] ]
  ask patch (min-pxcor + bin-width / 2) (2 * max-pycor / 3) [ sprout-sensors 1 [ set heading 180 set shape "motiondetector" set size max-pycor / 5 set color gray set base-color brown set my-plot-pen "three"  ] ]
  
  ask patch (min-pxcor + bin-width / 2) (2 * min-pycor / 3) [ sprout-sensors 1 [ set heading 0 set shape "motiondetector" set size max-pycor / 5 set color gray set base-color green set my-plot-pen "four" fd 1 ] ]
  ask patch (min-pxcor + bin-width / 2) ( max-pycor / 3) [ sprout-sensors 1 [ set heading 0 set shape "motiondetector" set size max-pycor / 5 set color gray set base-color green set my-plot-pen "four" fd 1 ] ]
  
  ask patch (min-pxcor + 3 * bin-width / 5) (min-pycor / 2) [ sprout-sensors 1 [ set heading 270 set shape "motiondetector" set size max-pycor / 5 set color gray set base-color blue set my-plot-pen "five" ] ]
  ask patch (min-pxcor + 3 * bin-width / 5) (max-pycor / 2) [ sprout-sensors 1 [ set heading 270 set shape "motiondetector" set size max-pycor / 5 set color gray set base-color blue set my-plot-pen "five" ] ]
  
  ask patch (min-pxcor + 4 * bin-width / 5) (min-pycor / 2) [ sprout-sensors 1 [ set heading 270 set shape "motiondetector" set size max-pycor / 5 set color gray set base-color magenta set my-plot-pen "six" ] ]
  ask patch (min-pxcor + 4 * bin-width / 5) (max-pycor / 2) [ sprout-sensors 1 [ set heading 270 set shape "motiondetector" set size max-pycor / 5 set color gray set base-color magenta set my-plot-pen "six"  ] ]
  
  ask sensors [ ifelse ycor > 0 [set domain "top" set my-plot "graphTop" ] [ set domain "bottom" set my-plot "graphBottom" ]  set active false set bin-x xcor set bin-y ycor ]
end

to setup-actors
 create-people 1 [ set size 5 setxy 0 item 0 track-ycors set color red set heading 90 set shape "person" set base-color cyan set domain "top" set p0 0 set animation-frame 1 set motion-script [] ]
 create-people 1 [ set size 5 setxy 0 item 1 track-ycors set color blue set heading 90 set shape "person" set base-color yellow + 1 set domain "bottom" set p0 0 set animation-frame 1 set motion-script [] ]
end

to setup 
  ca
  setup-globals
  setup-stage
  setup-bin
  setup-actors
  reset-ticks
  reset-motion
end

to reset-motion
  setup-for-motion
  set clock 0.0
  set clockstep 0.1
  ask patch 0 0 [ set plabel get-label-for-time clock ]
end

to prepare-motions
  ask people [ set shape "person" set color base-color ]
  ask people [ parse-motion-script (runresult (word domain "-motion-script")) ]
  ask people [ set xcor p0 * 6  set actual-location xcor ]
end

to setup-for-motion
  prepare-motions
  set detectables (turtle-set people walls)
  clear-all-plots
end

to run-scripts
  reset-motion
  while [ clock <= 9.9 ]
  [
    every clockstep [
      ask people [ execute-moment 10 * clock ]
      ask sensors with [ active = true ] [ plot-value ]
      set clock clock + clockstep
      ask patch 0 0 [ set plabel get-label-for-time clock ]
    ]
  ]

end

to-report get-label-for-time [ atime ]
  let lbl (word (precision clock 2) )
  if (not member? "." lbl) [ set lbl (word lbl ".0") ]
  report (word lbl "   ")
end

;;person procedure
to execute-moment [ index ]
  ifelse length motion-script < index [ set shape "person" set color gray ]
  [
    let prefix ""
    let v item index motion-script
    ifelse (v = 0) [ set shape "person" ]
    [
      if v > 0 [set prefix "-forward-"]
      if v < 0 [set prefix "-backward-" ]
      let frame (floor ((index * v) mod 9)) + 1
      set shape (word "person" prefix frame)
    ]
    set actual-location actual-location + (3 / 5) * v   ;;each unit is 2 inches (1/6 of a foot. 
    ifelse (actual-location > (max-pxcor - 1) or actual-location < min-pxcor + bin-width ) [ set xcor (max-pxcor - 1.1) ht ]  ;;hide (go offscreen) rather than break the world 
    [ st set xcor actual-location ]  ;;each unit is 2 inches (1/6 of a foot. .
  ]
end


;;wall (partition) management
to remove-partition
  ask walls with [ ycor = 0 and xcor < max-pxcor and xcor > min-pxcor + bin-width ] [ die ]
end

to put-partition-back
  if not any? walls with [ ycor = 0 and xcor < max-pxcor and xcor > min-pxcor + bin-width ] 
  [
    ask patches with [ pycor = 0 and pxcor < max-pxcor and pxcor > min-pxcor + bin-width ]  [ sprout-walls 1 [ init-wall ] ]
  ]
end




;;sensor procedure
to plot-value 
  let value get-sensor-reading
  set-current-plot my-plot
  set-current-plot-pen my-plot-pen
  plotxy clock value
end

to-report get-sensor-reading
  ifelse any? detectables in-cone 78 20
  [
    let seen-turtle min-one-of detectables in-cone 78 16 [distance myself]
    report (distance seen-turtle / 6)
  ]
  [
   ;happens when the actor goes off screen.
   report 0 
  ]
end

;;sensor placement
to arrange-sensors
  every .1
  [
     ifelse mouse-down? 
     [
       ifelse ( length mouse-down-at = 0 )
       [
         set dragged get-draggable-from mouse-xcor mouse-ycor
         if (dragged != nobody)
         [
            set mouse-down-at (list mouse-xcor mouse-ycor)
            ask dragged [ ask my-links [die] ] ;;unglue this sensor from any actor
         ]
       ]
       [
         ask dragged [ 
           if (mouse-xcor < max-pxcor - 1) [ set xcor mouse-xcor ]
           if (domain = "top" and mouse-ycor > 1 and mouse-ycor <= max-pycor - 1) [set ycor mouse-ycor]
           if (domain = "bottom" and mouse-ycor < -1 and mouse-ycor >= min-pycor + 1) [set ycor mouse-ycor]
           ifelse xcor > min-pxcor + bin-width [ set active true ] [ set active false ]
           ifelse active [ set color base-color ] [ set color gray ]
         ]
         display
       ]
     ]
     [
       if (length mouse-down-at > 0 )
       [ 
         set mouse-down-at [] 
         if (dragged != nobody) [ 
           ask dragged [ 
             ifelse active = false [ set color gray setxy bin-x bin-y ] 
             [ ;;now, deal with possible glueing to an actor.
               if (glue-to-actors?) [
                 if any? people with [ domain = [domain] of myself and distance myself < 4 ]
                 [
                   let my-guy one-of people with [ domain = [domain] of myself and distance myself < 4 ]
                   move-to my-guy
                   fd 1.5
                   create-link-with my-guy [ hide-link tie ]
                   set color color + 1
                 ] 
               ]
             ]
           ] 
         ] 
         set dragged nobody
         display
       ] 
     ]
  ]
end

to-report get-draggable-from [ xv yv ]
  ifelse any? sensors with [ distancexy xv yv  < 4 ]
  [ report min-one-of sensors [ distancexy xv yv]  ]
  [ report nobody ]
end



;;;PARSING OF THE MOTION MARKUP LANGUAGE
;;person procedure
to parse-motion-script [ script ]
  let commands script
  let command-list []


    set commands strip-startoff-info commands
    while [ member? "\n" commands ]
    [
      let j position "\n" commands
      let cmd substring commands 0 j
      set command-list (sentence command-list (parse-command cmd) )
      set commands substring commands (j + 1) (length commands)
    ]
  ;;get the last one
  set command-list (sentence command-list (parse-command commands) )
  set motion-script command-list 
end

;;e.g., go right slowly for 3 seconds
to-report parse-command [ cmd-string ]
  let direct "unknown"
  let spd -1
  let dura -1
  ifelse (position "go" cmd-string = 0)
  [
    if position "go right" cmd-string = 0 [ set direct "right" ]
    if position "go left" cmd-string = 0 [ set direct "left" ]
    if member? "very-slowly" cmd-string [ set spd 1 ]
    if member? " slowly" cmd-string [ set spd 2 ]
    if member? " quickly" cmd-string [ set spd 3 ]
    if member? "very-quickly" cmd-string [ set spd 4 ]
    let durpos position "for " cmd-string
    if (durpos > 0 and durpos + 4 < length cmd-string) [
      let durseg substring cmd-string (durpos + 4) (length cmd-string)
      let secpos position " second" durseg
      set dura read-from-string (substring durseg 0 secpos)
    ]
    if (direct != "unknown" and spd > -1 and dura > -1) [
      let sign 0
      if direct = "right" [ set sign 1 ]
      if direct = "left" [ set sign -1]
      let vals n-values (10 * dura) [ sign * spd]
      report vals
    ]
  ] 
  [
   if (position "pause for " cmd-string = 0) 
   [
     let punit position "second" cmd-string
     let paustring substring cmd-string 9 punit
     let pauselen read-from-string paustring
     let vals n-values (10 * pauselen) [0]
     report vals
   ]
  ]
  report []
end

to-report strip-startoff-info [ cmdstr ]
  let remaining-commands cmdstr
  let pzero 0
  if (position "start off at the " remaining-commands = 0) [
       let punit position "foot" remaining-commands
       let p0str substring remaining-commands 17 punit
       set pzero (runresult p0str)
       let linend position "\n" remaining-commands 
       if (is-number? linend ) [
         set remaining-commands substring remaining-commands (linend + 1) (length remaining-commands) ]
  ]
  set p0 pzero
  report remaining-commands
end



;;;command creation & manipulation

to remove-last-action [which ]
  let varstring (word which "-motion-script") 
  run (word "set " varstring " reverse " varstring)
  run (word "set " varstring " remove-first-line " varstring )
  run (word "set " varstring " reverse " varstring)
end

to-report remove-first-line [string]
  let j position "\n" string
  ifelse (j != false) [ report substring string (j + 1) length string ]
  [ report "" ]
end

to set-startoff [which location-phrase ]
  let varstring (word which "-motion-script") 
  let need-to-remove runresult (word "position \"start off\" " varstring " = " 0)
  if (need-to-remove) [ run (word "set " varstring " remove-first-line " varstring ) ]
  run (word "set " varstring " add-first-line " varstring " \"" location-phrase "\"" )
end

to add-go-action [ which adirection aspeed aduration ] 
  let varstring (word which "-motion-script") 
  run (word "set " varstring " add-last-line " varstring " \"" (word adirection " " aspeed " " aduration) "\"" )
end

to add-pause-action [which apause-duration ]
  let varstring (word which "-motion-script") 
  run (word "set " varstring " add-last-line " varstring " \"" (word "pause " apause-duration) "\"" )
end


to-report add-first-line [ string line ]
  report (word "start off " line "\n" string  )
end
  
to-report add-last-line [ string line ]
  report (word string "\n" line  )
end
  
  
  
@#$#@#$#@
GRAPHICS-WINDOW
331
10
1052
392
-1
19
9.0
1
31
1
1
1
0
0
0
1
-12
66
-19
19
0
0
1
ticks
30.0

BUTTON
332
395
432
465
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
7
12
329
302
graphTop
time
distance
0.0
10.0
0.0
12.0
false
false
"" ""
PENS
"one" 1.0 0 -2674135 true "" ""
"two" 1.0 0 -955883 true "" ""
"three" 1.0 0 -6459832 true "" ""
"four" 1.0 0 -10899396 true "" ""
"five" 1.0 0 -13345367 true "" ""
"six" 1.0 0 -5825686 true "" ""

PLOT
1054
155
1377
464
graphBottom
time
distance
0.0
10.0
0.0
12.0
true
false
"" ""
PENS
"one" 1.0 0 -2674135 true "" ""
"two" 1.0 0 -955883 true "" ""
"three" 1.0 0 -6459832 true "" ""
"four" 1.0 0 -10899396 true "" ""
"five" 1.0 0 -13345367 true "" ""
"six" 1.0 0 -5825686 true "" ""

INPUTBOX
41
304
276
527
top-motion-script
start off at the 2 foot mark\ngo right very-quickly for 1 seconds\ngo right quickly for 4 seconds\npause for 1 second\ngo left very-quickly for 4 seconds
1
1
String

CHOOSER
514
538
610
583
direction
direction
"go right" "go left"
0

CHOOSER
613
538
717
583
speed
speed
"very-slowly" "slowly" "quickly" "very-quickly"
3

CHOOSER
719
538
858
583
duration
duration
"for .5 seconds" "for 1 second" "for 1.5 seconds" "for 2 seconds" "for 2.5 seconds" "for 3 seconds" "for 3.5 seconds" "for 4 seconds" "for 4.5 seconds" "for 5 seconds"
1

BUTTON
281
533
483
578
add GO action to top script
add-go-action \"top\" direction speed duration
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
886
538
1101
583
add GO action to bottom script
add-go-action \"bottom\" direction speed duration
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
570
591
860
636
pause-duration
pause-duration
"for .5 seconds" "for 1 second" "for 1.5 seconds" "for 2 seconds" "for 2.5 seconds" "for 3 seconds" "for 3.5 seconds" "for 4 seconds" "for 4.5 seconds" "for 5 seconds"
0

TEXTBOX
511
609
578
632
pause
17
14.0
1

BUTTON
280
587
482
634
add PAUSE action to top script
add-pause-action \"top\" pause-duration
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
886
591
1101
637
add PAUSE action to bottom script
add-pause-action \"bottom\" pause-duration
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
587
481
859
526
startoff-location
startoff-location
"at the 0.5 foot mark" "at the 1 foot mark" "at the 1.5 foot mark" "at the 2 foot mark" "at the 2.5 foot mark" "at the 3 foot mark" "at the 3.5 foot mark" "at the 4 foot mark" "at the 4.5 foot mark" "at the 5 foot mark" "at the 5.5 foot mark" "at the 6 foot mark" "at the 6.5 foot mark" "at the 7 foot mark" "at the 7.5 foot mark" "at the 8 foot mark" "at the 8.5 foot mark" "at the 9 foot mark" "at the 9.5 foot mark" "at the 10 foot mark" "at the 10.5 foot mark" "at the 11 foot mark"
1

TEXTBOX
513
500
586
521
start off
17
52.0
1

BUTTON
281
644
483
681
remove last action from top script
remove-last-action \"top\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
281
479
483
525
set STARTOFF info for top script
set-startoff \"top\" startoff-location
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
885
477
1102
526
set STARTOFF info for bottom script
set-startoff \"bottom\" startoff-location
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
1142
466
1377
685
bottom-motion-script
start off at the 1 foot mark\ngo right slowly for 3 seconds\ngo right very-slowly for 2 seconds\npause for 2 seconds\ngo left quickly for 1 second
1
1
String

BUTTON
886
650
1102
686
remove last action from bottom script
remove-last-action \"bottom\"
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
762
395
894
465
Run Scripts Once
run-scripts
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
896
394
1052
465
Run Scripts Continuously
run-scripts\nwait .75\nreset-motion\nwait .5
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
660
394
760
465
Reset Motion
reset-motion
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
475
394
608
432
NIL
arrange-sensors
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
475
432
608
465
glue-to-actors?
glue-to-actors?
0
1
-1000

BUTTON
46
553
186
586
NIL
remove-partition
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
45
592
186
625
NIL
put-partition-back
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

motiondetector
true
0
Rectangle -7500403 true true 30 165 270 240
Circle -7500403 true true 83 98 134

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person-backward-1
false
0
Polygon -7500403 true true 180 195 180 105 165 90 105 90 105 105 105 120 120 180
Circle -7500403 true true 95 5 80
Rectangle -7500403 true true 117 73 153 90
Polygon -7500403 true true 135 195 180 180 204 228 240 255 225 300 167 242
Polygon -7500403 true true 120 180 180 180 144 232 141 299 101 299 105 223
Polygon -7500403 true true 165 90 205 125 240 180 210 195 173 137 150 120
Polygon -7500403 true true 120 136 120 151 94 202 66 190 90 136 105 91

person-backward-2
false
0
Polygon -7500403 true true 120 136 135 166 108 203 80 191 98 147 109 98
Circle -7500403 true true 95 5 80
Rectangle -7500403 true true 117 73 153 90
Polygon -7500403 true true 132 176 183 160 195 225 225 255 210 300 165 255
Polygon -7500403 true true 126 164 180 180 150 225 150 300 105 300 105 225
Polygon -7500403 true true 195 180 180 105 165 90 113 89 105 105 105 120 120 180
Polygon -7500403 true true 169 91 204 135 225 180 180 195 165 150 150 120

person-backward-3
false
0
Polygon -7500403 true true 129 123 119 162 135 200 104 201 102 150 106 104
Polygon -7500403 true true 135 180 180 180 180 225 210 285 165 300 135 225
Polygon -7500403 true true 120 180 179 180 142 239 165 300 120 300 120 225
Circle -7500403 true true 95 5 80
Rectangle -7500403 true true 117 73 153 90
Polygon -7500403 true true 184 192 180 105 165 90 120 90 105 105 105 120 120 195
Polygon -7500403 true true 165 90 180 105 207 193 172 199 165 150 150 120

person-backward-4
false
0
Polygon -7500403 true true 120 135 120 165 125 205 114 203 110 135 117 89
Circle -7500403 true true 95 5 80
Rectangle -7500403 true true 117 73 153 90
Polygon -7500403 true true 135 180 180 180 180 225 180 300 135 300 135 225
Polygon -7500403 true true 119 182 149 182 164 227 164 302 119 302 119 212
Polygon -7500403 true true 180 190 180 105 170 90 120 90 105 105 105 120 120 195
Polygon -7500403 true true 155 90 170 102 180 135 180 165 180 210 150 210

person-backward-5
false
0
Circle -7500403 true true 95 5 80
Rectangle -7500403 true true 117 73 153 90
Polygon -7500403 true true 120 180 165 180 165 225 180 300 120 300 120 225
Polygon -7500403 true true 105 180 180 180 165 225 150 300 105 300 99 222
Polygon -7500403 true true 180 195 180 105 165 90 120 90 105 105 105 120 120 195
Polygon -7500403 true true 120 135 120 165 120 195 105 195 105 120 117 89
Polygon -7500403 true true 164 128 164 158 164 203 134 203 135 120 158 95

person-backward-6
false
0
Polygon -7500403 true true 135 180 180 180 178 222 195 300 150 300 135 225
Polygon -7500403 true true 118 174 180 178 135 240 127 298 86 294 90 225
Circle -7500403 true true 95 5 80
Rectangle -7500403 true true 117 73 153 90
Polygon -7500403 true true 184 192 180 105 165 90 120 90 105 105 105 120 120 195
Polygon -7500403 true true 165 90 195 120 207 193 180 195 180 135 150 120
Polygon -7500403 true true 150 124 150 154 139 201 105 199 107 133 117 93

person-backward-7
false
0
Circle -7500403 true true 95 5 80
Rectangle -7500403 true true 117 73 153 90
Polygon -7500403 true true 135 180 180 180 195 240 210 300 165 300 150 240
Polygon -7500403 true true 135 166 180 181 123 229 120 297 79 289 87 210
Polygon -7500403 true true 180 195 180 105 165 90 120 90 105 105 105 120 111 193
Polygon -7500403 true true 178 103 200 133 221 195 189 202 176 165 146 120
Polygon -7500403 true true 120 133 135 163 120 210 90 195 102 146 105 105

person-backward-8
false
0
Polygon -7500403 true true 117 168 162 183 122 239 97 300 60 280 87 226
Circle -7500403 true true 95 5 80
Rectangle -7500403 true true 117 73 153 90
Polygon -7500403 true true 180 180 180 105 165 90 120 90 105 105 105 120 105 180
Polygon -7500403 true true 165 90 201 127 234 183 208 197 182 158 150 120
Polygon -7500403 true true 120 133 135 163 90 195 68 179 97 141 117 87
Polygon -7500403 true true 135 180 180 180 195 240 225 300 180 300 150 240

person-backward-9
false
0
Circle -7500403 true true 95 5 80
Rectangle -7500403 true true 117 73 153 90
Polygon -7500403 true true 135 180 180 180 195 225 232 289 195 300 150 225
Polygon -7500403 true true 112 185 165 180 137 240 129 300 83 301 100 229
Polygon -7500403 true true 179 180 179 105 164 90 119 90 105 97 104 120 113 185
Polygon -7500403 true true 165 90 210 135 240 180 210 195 180 150 150 120
Polygon -7500403 true true 115 137 115 154 78 199 54 179 85 139 115 92

person-forward-1
false
0
Polygon -7500403 true true 120 195 120 105 135 90 195 90 195 105 195 120 180 180
Circle -7500403 true true 125 5 80
Rectangle -7500403 true true 147 73 183 90
Polygon -7500403 true true 165 195 120 180 96 228 60 255 75 300 133 242
Polygon -7500403 true true 180 180 120 180 156 232 159 299 199 299 195 223
Polygon -7500403 true true 135 90 95 125 60 180 90 195 127 137 150 120
Polygon -7500403 true true 180 136 180 151 206 202 234 190 210 136 195 91

person-forward-2
false
0
Polygon -7500403 true true 180 136 165 166 192 203 220 191 202 147 191 98
Circle -7500403 true true 125 5 80
Rectangle -7500403 true true 147 73 183 90
Polygon -7500403 true true 168 176 117 160 105 225 75 255 90 300 135 255
Polygon -7500403 true true 174 164 120 180 150 225 150 300 195 300 195 225
Polygon -7500403 true true 105 180 120 105 135 90 187 89 195 105 195 120 180 180
Polygon -7500403 true true 131 91 96 135 75 180 120 195 135 150 150 120

person-forward-3
false
0
Polygon -7500403 true true 171 123 181 162 165 200 196 201 198 150 194 104
Polygon -7500403 true true 165 180 120 180 120 225 90 285 135 300 165 225
Polygon -7500403 true true 180 180 121 180 158 239 135 300 180 300 180 225
Circle -7500403 true true 125 5 80
Rectangle -7500403 true true 147 73 183 90
Polygon -7500403 true true 116 192 120 105 135 90 180 90 195 105 195 120 180 195
Polygon -7500403 true true 135 90 120 105 93 193 128 199 135 150 150 120

person-forward-4
false
0
Polygon -7500403 true true 180 135 180 165 175 205 186 203 190 135 183 89
Circle -7500403 true true 125 5 80
Rectangle -7500403 true true 147 73 183 90
Polygon -7500403 true true 165 180 120 180 120 225 120 300 165 300 165 225
Polygon -7500403 true true 181 182 151 182 136 227 136 302 181 302 181 212
Polygon -7500403 true true 120 190 120 105 130 90 180 90 195 105 195 120 180 195
Polygon -7500403 true true 145 90 130 102 120 135 120 165 120 210 150 210

person-forward-5
false
0
Circle -7500403 true true 125 5 80
Rectangle -7500403 true true 147 73 183 90
Polygon -7500403 true true 180 180 135 180 135 225 120 300 180 300 180 225
Polygon -7500403 true true 195 180 120 180 135 225 150 300 195 300 201 222
Polygon -7500403 true true 120 195 120 105 135 90 180 90 195 105 195 120 180 195
Polygon -7500403 true true 180 135 180 165 180 195 195 195 195 120 183 89
Polygon -7500403 true true 136 128 136 158 136 203 166 203 165 120 142 95

person-forward-6
false
0
Polygon -7500403 true true 165 180 120 180 122 222 105 300 150 300 165 225
Polygon -7500403 true true 182 174 120 178 165 240 173 298 214 294 210 225
Circle -7500403 true true 125 5 80
Rectangle -7500403 true true 147 73 183 90
Polygon -7500403 true true 116 192 120 105 135 90 180 90 195 105 195 120 180 195
Polygon -7500403 true true 135 90 105 120 93 193 120 195 120 135 150 120
Polygon -7500403 true true 150 124 150 154 161 201 195 199 193 133 183 93

person-forward-7
false
0
Circle -7500403 true true 125 5 80
Rectangle -7500403 true true 147 73 183 90
Polygon -7500403 true true 165 180 120 180 105 240 90 300 135 300 150 240
Polygon -7500403 true true 165 166 120 181 177 229 180 297 221 289 213 210
Polygon -7500403 true true 120 195 120 105 135 90 180 90 195 105 195 120 189 193
Polygon -7500403 true true 122 103 100 133 79 195 111 202 124 165 154 120
Polygon -7500403 true true 180 133 165 163 180 210 210 195 198 146 195 105

person-forward-8
false
0
Polygon -7500403 true true 183 168 138 183 178 239 203 300 240 280 213 226
Circle -7500403 true true 125 5 80
Rectangle -7500403 true true 147 73 183 90
Polygon -7500403 true true 120 180 120 105 135 90 180 90 195 105 195 120 195 180
Polygon -7500403 true true 135 90 99 127 66 183 92 197 118 158 150 120
Polygon -7500403 true true 180 133 165 163 210 195 232 179 203 141 183 87
Polygon -7500403 true true 165 180 120 180 105 240 75 300 120 300 150 240

person-forward-9
false
0
Circle -7500403 true true 125 5 80
Rectangle -7500403 true true 147 73 183 90
Polygon -7500403 true true 165 180 120 180 105 225 68 289 105 300 150 225
Polygon -7500403 true true 188 185 135 180 163 240 171 300 217 301 200 229
Polygon -7500403 true true 121 180 121 105 136 90 181 90 195 97 196 120 187 185
Polygon -7500403 true true 135 90 90 135 60 180 90 195 120 150 150 120
Polygon -7500403 true true 185 137 185 154 222 199 246 179 215 139 185 92

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.5
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
