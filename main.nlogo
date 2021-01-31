breed [Robots Robot]
breed [Kiosks Kiosk]
breed [AnalysisCenters AnalysisCenter]
breed [Persons Person]
breed [Analysors Analysor]

Robots-own
[
  RobotID
  OwnerKioskID
  CoronaDetects
  PeopleAround
  Status ; Active, Broken, Disabled, Dumpster
  Xposition
  Yposition
]

Kiosks-own
[
  KioskID
  ChildRobotID
  TeamID
  working
  Leader
  PersontoRobotDensity
  AnalysisCenterID
  Xposition
  Yposition
]

AnalysisCenters-own
[
  AnalysisCenterID
  CoronaIdentified
  Xposition
  Yposition
]

Analysors-own
[
  AnalysorID
  Infected
  Xposition
  Yposition
]

globals
[
  Region1
  Region2
  Region3
  Region4
  Region5
  TotalCoronaInfected
]



to setup
  __clear-all-and-reset-ticks
  set-default-shape Persons "person"
  set-default-shape AnalysisCenters "house colonial"
  set-default-shape Kiosks "campsite"
  set-default-shape Robots "circle"
  set-default-shape Analysors "hawk"

  Build-Robots
  Build-Kiosks
  Build-AnalysisCenters
  Build-Analysors
  TeamUp-Kiosks
  FindLeaders-Kiosks
  FindNearest-AnalysisCenters
  ask Robots [set status "Active"]

end


to go
  let region 0
  if (break?)
    [
      BreakRobots
    ]
  if (SelfConfig?)
  [
    CureForBrokenRobots
    SeeIfRobotsNeeded
    SeeIfKiosksNeeded
  ]
  FindNearest-AnalysisCenters
  Run-Robots
  Run-Kiosks
  Run-AnalysisCenters
  Run-Analysors

  ask Analysors with [AnalysorID = 1] [set Region Infected]
  set region1 region
  ask Analysors with [AnalysorID = 2] [set Region Infected]
  set region2 region
  ask Analysors with [AnalysorID = 3] [set Region Infected]
  set region3 region
  ask Analysors with [AnalysorID = 4] [set Region Infected]
  set region4 region
  set TotalCoronaInfected (region1 + region2 + region3 + region4 + region5)
  tick
end

to Run-Analysors
  let id 0
  let Infecteds 0
  ask Analysors[
    set id AnalysorID
    ask AnalysisCenters with [AnalysisCenterID = id]
    [
      set Infecteds CoronaIdentified
    ]
    set Infected Infecteds
  ]
end
to Run-AnalysisCenters
  let ID 0
  let theid 0
  let choice 1
  let CoronaIdentifieds 0
 ask AnalysisCenters
  [
    set ID AnalysisCenterID
    ask Kiosks with [AnalysisCenterID = ID]
    [
      set theid KioskID
      ask robots with [theid = OwnerKioskID and peopleAround > 0]
      [
        set PeopleAround (PeopleAround - 1)
        set CoronaIdentifieds (CoronaIdentifieds + 1)
      ]
    ]
    set CoronaIdentified CoronaIdentifieds
  ]
end
to Run-Kiosks
  let x 0
  let y 0
  let people 0
  let dens 0
  let id 0
  ask Kiosks with [TeamID = 1]
  [
    set x (random 20) set y (random 20)
    setxy x y set Xposition x set Yposition y
    set id KioskID
    ask robots with [OwnerKioskID = id]
    [set people (people + peopleAround)]
    set dens (people / (count kiosks with [childRobotID != "" and TeamID = 1]))
  ]
  ask kiosks with [Leader = "Yes" and TeamID = 1] [set PersontoRobotDensity dens]

  ask Kiosks with [TeamID = 2]
  [
    set x (random -20) set y (random 20)
    setxy x y set Xposition x set Yposition y
    ask robots with [OwnerKioskID = id] [
      set people (people + peopleAround)]
    set dens (people / (count kiosks with [childRobotID != "" and TeamID = 2]))
  ]
  ask kiosks with [Leader = "Yes" and TeamID = 2] [set PersontoRobotDensity dens]

  ask Kiosks with [TeamID = 3]
  [
    set x (random 20) set y (random -20)
    setxy x y set Xposition x set Yposition y
    ask robots with [OwnerKioskID = id] [
      set people (people + peopleAround)]
    set dens (people / (count kiosks with [childRobotID != "" and TeamID = 3]))
  ]
  ask kiosks with [Leader = "Yes" and TeamID = 3] [set PersontoRobotDensity dens]

  ask Kiosks with [TeamID = 4]
  [
    set x (random -20) set y (random -20)
    setxy x y set Xposition x set Yposition y
    ask robots with [OwnerKioskID = id] [
      set people (people + peopleAround)]
    set dens (people / (count kiosks with [childRobotID != "" and TeamID = 4]))
  ]
  ask kiosks with [Leader = "Yes" and TeamID = 4] [set PersontoRobotDensity dens]
end
to Run-Robots
  let oldx 0
  let oldy 0
  let oldkiosk 0
  ask Robots with [status = "Active"]
  [
    set oldkiosk OwnerKioskID
    ask Kiosks with [KioskID = oldkiosk] [set oldx Xposition set oldy Yposition]
    set Xposition (oldx + random-normal 0 2) set Yposition (oldy + random-normal 0 2) setxy Xposition Yposition set peopleAround (random 4)
  ]
end
to FindLeaders-Kiosks

  ask one-of kiosks with [teamID = 1]
  [
    set Leader "Yes"
  ]

  ask one-of kiosks with [teamID = 2]
  [
    set Leader "Yes"
  ]

  ask one-of kiosks with [teamID = 3]
  [
    set Leader "Yes"
  ]

  ask one-of kiosks with [teamID = 4]
  [
    set Leader "Yes"
  ]

  ask kiosks with [Leader != "Yes"]
  [
    set Leader "no"
  ]

end
to SeeIfRobotsNeeded
  let again 1
  let team 0
  let oldkiosk 0
  let oldx 0
  let oldy 0
  let prdens 0
  let target 0

  while[again = 1]
  [
    set again 0
    set target one-of kiosks with [working != "Yes"]
    if target != nobody[
    ask one-of kiosks with [working != "Yes"]
    [
      set team TeamID set oldkiosk KioskID set oldx Xposition set oldy Yposition set again 1
    ]
    ask kiosks with [Leader = "Yes" and TeamID = team]
    [
      set prdens PersonToRobotDensity
    ]
    if (prdens > 2)
    [
      create-Robots 1 [setxy oldx oldy set Xposition oldx set Yposition oldy set OwnerKioskID oldkiosk set color gray set RobotID who set size 1]
    ]
  ]
  ]

end
to SeeIfKiosksNeeded
  let again 1
  let team 0
  let borrowteam 0
  let didborrow 0
  let shouldget 0
  let borrowrobotid 0
  let x 0
  let y 0
  let ID 0
  let ChildID 0
  let target 0
  while [again = 1]
  [ set again 0
    set target one-of Kiosks with [Leader = "Yes" and PersontoRobotDensity > 1.5]
    if target != nobody[
  ask one-of Kiosks with [Leader = "Yes" and PersontoRobotDensity > 1.5]
    [
      set team TeamID set shouldget 1
    ]
    if (shouldget = 1)
    [
      set again 1
        set target one-of Kiosks with[Leader = "Yes" and PersontoRobotDensity < 0.5]
        if target != nobody [
        ask one-of Kiosks with[Leader = "Yes" and PersontoRobotDensity < 0.5]
        [
          set borrowteam TeamID
          set didborrow 1
        ]
        ]
        if (didborrow = 1)
        [
        ask one-of kiosks with [TeamID = borrowteam and Leader != "Yes"]
         [
          set TeamID team set working "Yes"
         ]
        ]
      if (didborrow = 0)
        [
        create-Robots 1 [set x (random 20) set y (random 20)
        setxy x y set Xposition x set Yposition y set OwnerKioskID 9999 set color gray set RobotID who set ChildID who set size 1]

          create-Kiosks 1 [set kioskID who set ID who setxy x y set Xposition x set Yposition y set color yellow set size 1 set ChildRobotID childID]
      ]
    ]
  ]
  ]

end
to CureForBrokenRobots
  let team 0
  let oldkiosk 0
  let borrowteam 0
  let borrowrobotid 0
  let didborrow 0
  let oldx 0
  let oldy 0
  let prdens 0
  let target 0
  while [(count Robots with [status = "Broken"] > 0)]
  [

    ask one-of Robots with [status = "Broken"]
    [
      set oldkiosk OwnerKioskID set status "Dumpster" set oldx Xposition set oldy Yposition set Xposition 20 set Yposition 20 set color red
    ]

    ask kiosks with [KioskID = oldkiosk]
    [
      set team TeamID
    ]

    ask Kiosks with [Leader = "Yes" and TeamID = team]
    [
      set prdens PersontoRobotDensity
    ]
      if(prdens > 1.5)
      [
      set target one-of Kiosks with[Leader = "Yes" and PersontoRobotDensity < 1]
      if target != nobody[
        ask one-of Kiosks with[Leader = "Yes" and PersontoRobotDensity < 1]
        [
          set borrowteam TeamID
          set didborrow 1
      ]]
        if (didborrow = 1)
        [
        ask one-of kiosks with [TeamID = borrowteam]
         [
          set borrowrobotid childRobotID set working "no" set childRobotID ""
         ]
          ask Robots with [RobotID = borrowrobotid]
          [
            set OwnerKioskID oldkiosk
          ]
        ]
      if (didborrow = 0)
        [
          create-Robots 1 [setxy oldx oldy set Xposition oldx set Yposition oldy set OwnerKioskID oldkiosk set color gray set RobotID who set size 1]
        ]
      ]
    ]
end
to BreakRobots
    ask one-of Robots
    [set status "Broken" setxy 20 20 set Xposition 20 set Yposition 20 set color red]
end
to Build-Robots
  let x 0
  let y 0
  create-Robots 5
  [set x (random 20) set y (random 20)
    setxy x y set Xposition x set Yposition y set OwnerKioskID 9999 set color gray set RobotID who set size 1]

  create-Robots 5
  [set x (random -20) set y (random 20)
    setxy x y set Xposition x set Yposition y set OwnerKioskID 9999 set color gray set RobotID who set size 1]

  create-Robots 5
  [set x (random 20) set y (random -20)
    setxy x y set Xposition x set Yposition y set OwnerKioskID 9999 set color gray set RobotID who set size 1]

  create-Robots 5
  [set x (random -20) set y (random -20)
    setxy x y set Xposition x set Yposition y set OwnerKioskID 9999 set color gray set RobotID who set size 1]

  ask Robots [set RobotID who]
end
to Build-Kiosks
  let x 0
  let y 0
  let ID 0
  let childID 0
  create-Kiosks 20
  [ask Kiosks [set KioskID who]
  set ID who
    ask one-of Robots with [OwnerKioskID = 9999] [
    set x Xposition set y Yposition set OwnerKioskID ID set childID RobotID]
  setxy x y set Xposition x set Yposition y set color yellow set size 1 set ChildRobotID childID]
end
to Build-AnalysisCenters
  let x 0
  let y 0
  create-AnalysisCenters 1 [set label "one" set AnalysisCenterID 1 set size 2 set color pink set x (18) set y (-18) setxy x y set Xposition x set Yposition y]
  create-AnalysisCenters 1 [set label "two" set AnalysisCenterID 2 set size 2 set color pink set x (-18) set y (18) setxy x y set Xposition x set Yposition y]
  create-AnalysisCenters 1 [set label "three" set AnalysisCenterID 3 set size 2 set color pink set x (18) set y (18) setxy x y set Xposition x set Yposition y]
  create-AnalysisCenters 1 [set label "four" set AnalysisCenterID 4 set size 2 set color pink set x (-18) set y (-18) setxy x y set Xposition x set Yposition y]
  create-AnalysisCenters 1 [set label "five" set AnalysisCenterID 5 set size 2 set color pink set x (0) set y (0) setxy x y set Xposition x set Yposition y]
end
to Build-Analysors
  let x 0
  let y 0
  create-Analysors 1
  [set x (random-normal 0 15) set y (random-normal 0 15)
     setxy x y set Xposition x set Yposition y set size 0.75 set AnalysorID 1 set color brown]
  create-Analysors 1
  [set x (random-normal 0 15) set y (random-normal 0 15)
     setxy x y set Xposition x set Yposition y set size 0.75 set AnalysorID 2 set color brown]
  create-Analysors 1
  [set x (random-normal 0 15) set y (random-normal 0 15)
     setxy x y set Xposition x set Yposition y set size 0.75 set AnalysorID 3 set color brown]
  create-Analysors 1
  [set x (random-normal 0 15) set y (random-normal 0 15)
     setxy x y set Xposition x set Yposition y set size 0.75 set AnalysorID 4 set color brown]
  create-Analysors 1
  [set x (random-normal 0 15) set y (random-normal 0 15)
     setxy x y set Xposition x set Yposition y set size 0.75 set AnalysorID 5 set color brown]
end
to TeamUp-Kiosks
  ask Kiosks with [childRobotID < 5] [
    set TeamID 1
  ]
   ask Kiosks with [childRobotID >= 5 and childRobotID < 10] [
    set TeamID 2
  ]
  ask Kiosks with [childRobotID >= 10 and childRobotID < 15] [
    set TeamID 3
  ]
  ask Kiosks with [childRobotID >= 15 and childRobotID < 20] [
    set TeamID 4
  ]
end
to FindNearest-AnalysisCenters
 let x1 0
 let y1 0
 let x2 0
 let y2 0
 let tmp 10000
 let Dist 0
 let NearestCenterID 0
  ask Kiosks
  [
     set tmp 10000
     set NearestCenterID 0
     set x1 Xposition
     set y1 Yposition
    ask AnalysisCenters
    [
     set x2 Xposition
     set y2 Yposition
     set Dist  (abs (x2 - x1) + abs (y2 - y1))
     if Dist < tmp [set NearestCenterID AnalysisCenterID set tmp Dist]
    ]

    set AnalysisCenterID NearestCenterID
  ]

end
@#$#@#$#@
GRAPHICS-WINDOW
442
10
927
496
-1
-1
11.63415
1
10
1
1
1
0
1
1
1
-20
20
-20
20
0
0
1
ticks
30.0

BUTTON
128
24
191
57
NIL
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

SWITCH
57
64
199
97
break?
break?
1
1
-1000

SWITCH
57
103
200
136
SelfConfig?
SelfConfig?
1
1
-1000

BUTTON
56
24
119
57
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
69
199
131
244
NIL
Region1
17
1
11

MONITOR
136
199
199
244
NIL
Region2
17
1
11

MONITOR
71
252
128
297
NIL
region3
17
1
11

MONITOR
138
253
195
298
NIL
region4
17
1
11

MONITOR
70
307
127
352
NIL
region5
17
1
11

MONITOR
139
307
196
352
Total
TotalCoronaInfected
17
1
11

TEXTBOX
84
180
234
198
Live Infected Statistics
11
0.0
1

TEXTBOX
205
74
355
92
Kills Robots randomly
11
0.0
1

TEXTBOX
210
108
360
136
Makes Up for the Broken Robots / Adds Kiosks
11
0.0
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

campsite
false
0
Polygon -7500403 true true 150 11 30 221 270 221
Polygon -16777216 true false 151 90 92 221 212 221
Line -7500403 true 150 30 150 225

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

computer workstation
false
0
Rectangle -7500403 true true 60 45 240 180
Polygon -7500403 true true 90 180 105 195 135 195 135 210 165 210 165 195 195 195 210 180
Rectangle -16777216 true false 75 60 225 165
Rectangle -7500403 true true 45 210 255 255
Rectangle -10899396 true false 249 223 237 217
Line -16777216 false 60 225 120 225

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

hawk
true
0
Polygon -7500403 true true 151 170 136 170 123 229 143 244 156 244 179 229 166 170
Polygon -16777216 true false 152 154 137 154 125 213 140 229 159 229 179 214 167 154
Polygon -7500403 true true 151 140 136 140 126 202 139 214 159 214 176 200 166 140
Polygon -16777216 true false 151 125 134 124 128 188 140 198 161 197 174 188 166 125
Polygon -7500403 true true 152 86 227 72 286 97 272 101 294 117 276 118 287 131 270 131 278 141 264 138 267 145 228 150 153 147
Polygon -7500403 true true 160 74 159 61 149 54 130 53 139 62 133 81 127 113 129 149 134 177 150 206 168 179 172 147 169 111
Circle -16777216 true false 144 55 7
Polygon -16777216 true false 129 53 135 58 139 54
Polygon -7500403 true true 148 86 73 72 14 97 28 101 6 117 24 118 13 131 30 131 22 141 36 138 33 145 72 150 147 147

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

house colonial
false
0
Rectangle -7500403 true true 270 75 285 255
Rectangle -7500403 true true 45 135 270 255
Rectangle -16777216 true false 124 195 187 256
Rectangle -16777216 true false 60 195 105 240
Rectangle -16777216 true false 60 150 105 180
Rectangle -16777216 true false 210 150 255 180
Line -16777216 false 270 135 270 255
Polygon -7500403 true true 30 135 285 135 240 90 75 90
Line -16777216 false 30 135 285 135
Line -16777216 false 255 105 285 135
Line -7500403 true 154 195 154 255
Rectangle -16777216 true false 210 195 255 240
Rectangle -16777216 true false 135 150 180 180

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
NetLogo 6.2.0
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
