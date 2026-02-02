10 ' Pasopia Disk Utility
20 ' 
30 width 80
40 CLEAR ,&HDFFF
50 DEFINT A-Z
60 '
70 maxtrack=69

80 ' IF PEEK(&hF1FE)=&HC9 GOTO 130
90 FOR I=&hf000 TO &hf245
100  READ A$
110  POKE I,VAL("&H"+A$)
120 NEXT 

130 ' menu
140 wrt=0
150 red=1
160 fmt=2
170 poke &hf214, &hff  : 'reset current track
180 print "Pasopia Disk Utility"
190 print "----------------------------------"
200 input "Image Write:0, Copy:1, Format:2 : ", menu$
210 if menu$<>"0" and menu$<>"1" and menu$<>"2" then goto 200
220 job=val(menu$)

230 '
240 print ""
250 if job=wrt then print"Image Write: Put formatted disk on drive2"
260 if job=red then print"Copy: Put source dsk: drive1, dest: drive2"
270 if job=fmt then print"Format: Put disk on drive2"

280 INPUT"If ready, press 'y' and return:",S$
290 if S$<>"y" and S$<>"Y" then 280
300 for track=1 to maxtrack
310  print "Track:" track
320  T=int(track / 2):SIDE=track mod 2:DRV=1
330  if job=wrt then bload #-1,"track":P=wrt:gosub 680
340  if job=red then P=red:DRV=0:gosub 680:P=wrt:DRV=1:gosub 680
350  if job=fmt then P=fmt:gosub 680
360 next
370 if job<>fmt then 190
380 INPUT"Do BASIC logical format?",S$
390 if S$<>"y" and S$<>"Y" then 190
400 '
410 for i=&he000 to &hebff
420  poke i,&hff
430 next
440 for i=&hec00 to &hecff
450  poke i,&h00
460 next
470 ' FAT
480 for i=&hed00 to &hed03
490  poke i,&hfe
500  poke i+256,&hfe
510  poke i+512,&hfe
520 next
530 for i=&hed04 to &hed8b
540  poke i,&hff
550  poke i+256,&hff
560  poke i+512,&hff
570 next
580 for i=&hed8c to &hedff
590  poke i,&hfe
600  poke i+256,&hfe
610  poke i+512,&hfe
620 next
630 poke &hed48, &hfe: poke &hed4a, &hfe
640 poke &hee48, &hfe: poke &hee4a, &hfe
650 poke &hef48, &hfe: poke &hef4a, &hfe

660 T=18:SIDE=0:DRV=1:P=wrt:gosub 680
670 goto 190

680 ' Disk I/O
690 poke &hf001, SIDE*128+DRV
700 poke &hf004, T
710 poke &hf00e, P 
720 add=&hf000:call add
730 r=peek(&hf215)
740 if r=0 then return
750 print "Disk I/O error"
760 end
770 '


780 DATA 3e,00,11,01,01,06,10,cd,1c,f0,21,00,e0,3e,00,cd
790 DATA 4d,f0,3e,00,30,02,3e,ff,32,15,f2,c9,dd,21,ff,f1
800 DATA dd,72,02,dd,73,04,dd,36,05,01,e6,83,57,07,e6,01
810 DATA dd,77,03,07,07,b2,e6,07,dd,77,01,dd,70,09,78,83
820 DATA 3d,dd,77,06,dd,36,07,0e,dd,36,08,ff,c9,e5,32,09
830 DATA f2,f3,3e,40,d3,e6,cd,16,f1,21,11,f2,3a,00,f2,e6
840 DATA 03,16,00,5f,19,3a,01,f2,57,7e,5f,fe,ff,20,10,d5
850 DATA cd,43,f1,d1,38,68,cd,16,f1,38,60,e6,20,28,f7,7a
860 DATA bb,cd,e3,f0,38,58,cd,16,f1,38,50,e6,20,28,f7,cd
870 DATA f2,f0,3a,09,f2,b7,28,09,fe,02,ca,b4,f1,3e,46,18
880 DATA 02,3e,45,32,ff,f1,0e,09,f3,cd,52,f1,38,30,e1,3a
890 DATA 08,f2,57,1e,00,cd,78,f1,cd,9e,f1,fb,da,37,f1,3a
900 DATA 0a,f2,4f,e6,c0,28,1b,79,cb,5f,c2,3c,f1,3a,0b,f2
910 DATA cb,4f,20,02,18,61,3e,08,37,18,07,e1,18,04,fb,e1
920 DATA 18,55,c9,3e,0f,32,ff,f1,0e,03,cd,52,f1,d8,cd,71
930 DATA f1,c9,21,11,f2,3a,00,f2,e6,03,16,00,5f,19,3a,01
940 DATA f2,77,c9,3e,04,32,ff,f1,0e,02,cd,52,f1,d8,cd,9e
950 DATA f1,d8,3a,0a,f2,c9,3e,08,32,ff,f1,0e,01,cd,52,f1
960 DATA d8,cd,9e,f1,d8,3a,0a,f2,fe,80,4f,28,14,4f,e6,18
970 DATA 20,0a,79,e6,c0,28,0a,3e,ff,37,18,a6,3e,01,37,18
980 DATA a1,79,c9,3e,07,32,ff,f1,0e,02,cd,52,f1,d8,cd,71
990 DATA f1,c9,db,e4,fe,ff,20,02,37,c9,e6,10,20,f4,21,ff
1000 DATA f1,db,e4,e6,c0,fe,80,20,f8,7e,d3,e5,23,0d,20,f1
1010 DATA c9,db,e6,cb,7f,28,fa,c9,01,e5,00,db,e4,07,30,fb
1020 DATA 07,30,0f,07,30,07,ed,a2,1b,7b,b2,20,ee,d3,e2,d3
1030 DATA e0,c9,07,30,f8,ed,a3,1b,7b,b2,20,df,18,ef,21,0a
1040 DATA f2,db,e4,fe,ff,20,02,37,c9,07,30,f5,07,d0,db,e5
1050 DATA 77,23,18,ed,21,16,f2,dd,21,ff,f1,1e,01,06,10,dd
1060 DATA 4e,02,dd,56,03,71,23,72,23,73,23,1c,36,01,23,10
1070 DATA f4,3e,4d,32,ff,f1,3e,01,32,01,f2,3e,10,32,02,f2
1080 DATA 3e,32,32,03,f2,3e,e5,32,04,f2,0e,06,cd,52,f1,38
1090 DATA 0c,21,16,f2,11,40,00,cd,78,f1,cd,9e,f1,e1,c9,00
1100 DATA 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
1110 DATA 00,ff,ff,ff,ff,00,00,00,00,00,00,00,00,00,00,00
1120 DATA 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
1130 DATA 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
1140 DATA 00,00,00,00,00,00
