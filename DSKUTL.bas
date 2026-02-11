10 ' Pasopia Disk Utility
20 ' 
30 width 80
40 CLEAR ,&HCFFF
50 DEFINT A-Z
60 '
70 maxtrack=69

80 ' IF PEEK(&hea28)=&HC9 GOTO 130
90 FOR I=&he800 TO &hea6f
100  READ A$
110  POKE I,VAL("&H"+A$)
120 NEXT 

130 ' menu
140 wrt=0
150 red=1
160 fmt=2
170 poke &hea3b,&hff:poke &hea3c,&hff:out &he0,0
180 print "Pasopia Disk Utility"
190 print "----------------------------------"
200 input "Image Write:0, Copy:1, Format:2, End:3: ", menu$
210 if menu$="3" then end
220 if menu$<>"0" and menu$<>"1" and menu$<>"2" then goto 200
230 job=val(menu$)

240 '
250 print ""
260 if job=wrt then print"Image Write: Put formatted disk on drive2"
270 if job=red then print"Copy: Put source dsk: drive1, dest: drive2"
280 if job=fmt then print"Format: Put disk on drive2"

290 INPUT"If ready, press 'y' and return:",S$
300 if S$<>"y" and S$<>"Y" then 290
310 out &he6, &h40:a=time:while time < a+2: wend
320 for track=0 to maxtrack
330  if track=0 and job<>fmt then track=1
340  if track=0 and job=fmt then gosub 740
350  if track=1 and job=fmt then gosub 750
360  print "Track:" track
370  T=int(track / 2):SIDE=track mod 2:DRV=1
380  if job=wrt then bload #-1,"track":P=wrt:gosub 770
390  if job=red then P=red:DRV=0:gosub 770:P=wrt:DRV=1:gosub 770
400  if job=fmt then P=fmt:gosub 770
410 next
420 if job<>fmt then 190
430 INPUT"Do BASIC logical format?",S$
440 if S$<>"y" and S$<>"Y" then 190
450 '
460 for i=&hd000 to &hdbff
470  poke i,&hff
480 next
490 for i=&hdc00 to &hdcff
500  poke i,&h00
510 next
520 ' FAT
530 for i=&hdd00 to &hdd03
540  poke i,&hfe
550  poke i+256,&hfe
560  poke i+512,&hfe
570 next
580 for i=&hdd04 to &hdd8b
590  poke i,&hff
600  poke i+256,&hff
610  poke i+512,&hff
620 next
630 for i=&hdd8c to &hddff
640  poke i,&hfe
650  poke i+256,&hfe
660  poke i+512,&hfe
670 next
680 poke &hdd48, &hfe: poke &hdd4a, &hfe
690 poke &hde48, &hfe: poke &hde4a, &hfe
700 poke &hdf48, &hfe: poke &hdf4a, &hfe

710 T=18:SIDE=0:DRV=1:P=wrt:gosub 770
720 goto 190

730 '
740 poke &he9fc,&h0d:poke &he9f7,00:poke &hea01,00:poke &hea0b,&h19:return
750 poke &he9fc,&h4d:poke &he9f7,01:poke &hea01,01:poke &hea0b,&h32:return
760 ' Disk I/O
770 poke &he801, SIDE*128+DRV
780 poke &he804, T
790 poke &he80e, P 
800 add=&he800:call add
810 r=peek(&hea3f)
820 if r=0 then return
830 print "Disk I/O error"
840 end
850 '

1000 DATA 3e,00,11,01,01,06,10,cd,1c,e8,21,00,d0,3e,00,cd
1010 DATA 4d,e8,3e,00,30,02,3e,ff,32,3f,ea,c9,dd,21,29,ea
1020 DATA dd,72,02,dd,73,04,dd,36,05,01,e6,83,57,07,e6,01
1030 DATA dd,77,03,07,07,b2,e6,07,dd,77,01,dd,70,09,78,83
1040 DATA 3d,dd,77,06,dd,36,07,0e,dd,36,08,ff,c9,e5,32,33
1050 DATA ea,f3,3e,40,d3,e6,01,60,ea,c5,cd,22,e9,c1,da,e7
1060 DATA e8,6f,0b,78,b1,ca,e7,e8,7d,e6,20,28,ec,cd,35,e9
1070 DATA 21,3b,ea,3a,2a,ea,e6,03,16,00,5f,19,3a,2b,ea,57
1080 DATA 7e,5f,fe,ff,20,0b,cd,6d,e9,da,eb,e8,cd,10,e9,38
1090 DATA 5a,cd,f0,e8,38,55,cd,10,e9,38,50,cd,ff,e8,3a,33
1100 DATA ea,b7,28,09,fe,02,ca,de,e9,3e,46,18,02,3e,45,32
1110 DATA 29,ea,0e,09,f3,cd,7c,e9,38,31,e1,3a,32,ea,57,1e
1120 DATA 00,cd,a2,e9,cd,c8,e9,fb,da,5e,e9,3a,34,ea,4f,e6
1130 DATA c0,28,1c,cb,59,c2,64,e9,3a,35,ea,cb,4f,20,03,c3
1140 DATA 5e,e9,3e,08,37,18,08,37,e1,18,04,fb,e1,18,6f,c9
1150 DATA 3e,0f,32,29,ea,0e,03,cd,7c,e9,d8,cd,9b,e9,c9,21
1160 DATA 3b,ea,3a,2a,ea,e6,03,16,00,5f,19,3a,2b,ea,77,c9
1170 DATA cd,35,e9,30,08,fe,01,28,f7,37,c3,e7,e8,e6,20,28
1180 DATA ef,c9,3e,04,32,29,ea,0e,02,cd,7c,e9,d8,cd,c8,e9
1190 DATA d8,3a,34,ea,c9,3e,08,32,29,ea,0e,01,cd,7c,e9,d8
1200 DATA cd,c8,e9,d8,3a,34,ea,4f,e6,c0,28,1e,fe,80,28,1a
1210 DATA cb,59,20,10,fe,40,28,06,cb,61,20,02,18,0c,3e,ff
1220 DATA 37,c3,ef,e8,3e,01,37,c3,ef,e8,b7,79,c9,3e,07,32
1230 DATA 29,ea,0e,02,cd,7c,e9,d8,cd,9b,e9,c9,db,e4,fe,ff
1240 DATA 20,02,37,c9,e6,10,20,f4,21,29,ea,db,e4,e6,c0,fe
1250 DATA 80,20,f8,7e,d3,e5,23,0d,20,f1,c9,db,e6,cb,7f,28
1260 DATA fa,c9,01,e5,00,db,e4,07,30,fb,07,30,0f,07,30,07
1270 DATA ed,a2,1b,7b,b2,20,ee,d3,e2,d3,e0,c9,07,30,f8,ed
1280 DATA a3,1b,7b,b2,20,df,18,ef,21,34,ea,db,e4,fe,ff,20
1290 DATA 02,37,c9,07,30,f5,07,d0,db,e5,77,23,18,ed,21,40
1300 DATA ea,dd,21,29,ea,1e,01,06,10,dd,4e,02,dd,56,03,71
1310 DATA 23,72,23,73,23,1c,36,01,23,10,f4,3e,4d,32,29,ea
1320 DATA 3e,01,32,2b,ea,3e,10,32,2c,ea,3e,32,32,2d,ea,3e
1330 DATA e5,32,2e,ea,0e,06,cd,7c,e9,38,0c,21,40,ea,11,40
1340 DATA 00,cd,a2,e9,cd,c8,e9,e1,c9,00,00,00,00,00,00,00
1350 DATA 00,00,00,00,00,00,00,00,00,00,00,ff,ff,ff,ff,00
1360 DATA 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
1370 DATA 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
1380 DATA 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
