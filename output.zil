"OUTPUT for
		      		JOURNEY
	(c) Copyright 1988 Infocom, Inc.  All Rights Reserved."

;"Abortion"

<SETG ANONF-COUNT 0>

<DEFINE ACOND ("ARGS" LST "AUX" ATM)
	<SET ATM <PARSE <STRING "ANONF-"
				<UNPARSE <SETG ANONF-COUNT
					       <+ ,ANONF-COUNT 1>>>>>>
	<COND (<TYPE? <1 .LST> ATOM>
	       <SET ATM <1 .LST>>
	       <SET LST <REST .LST>>)>
	<MAPF <>
	      <FUNCTION (X "AUX" (XX <1 .X>))
		   <COND (<TYPE? .XX ATOM>
			  <PUT .X 1 <FORM ACTION? .XX>>)
			 (<TYPE? .XX ADECL>
			  <PUT .X 1 <FORM ACTION? <1 .XX>>>
			  <COND (<==? <2 .XX> CLEAR>
				 <PUTREST .X
					  ('<UPDATE-FSET ,ACTION-OBJECT
							 ,DONT-EXAMINE>
					   !<REST .X>)>)
				(<==? <2 .XX> REMOVE>
				 <COND (<==? <1 .XX> EXAMINE>
					<PUTREST .X
						 ('<UPDATE-MOVE
						      ,ACTION-OBJECT>
						  !<REST .X>)>)
				       (<==? <1 .XX> GET-ADVICE>
					<PUTREST .X
						 ('<UPDATE-FCLEAR ,HERE
								  ,ADVISE>
						  !<REST .X>)>)
				       (<==? <1 .XX> SCOUT>
					<PUTREST .X
						 ('<UPDATE-FSET ,HERE
								,DONT-SCOUT>
						  '<FSET ,HERE ,SCOUTED>
						  !<REST .X>)>)
				       (T
					<PUTREST .X
					  (<FORM REMOVE-TRAVEL-COMMAND
						 ',HERE
						 <FORM GVAL
						       <PARSE
							<STRING <SPNAME
								 <1 .XX>>
								"-COMMAND">>>>
					   !<REST .X>)>)>)
				(T
				 <ERROR BAD-ACOND!-ERRORS>)>)>>
	      <REST .LST>>
	<EVAL <FORM ROUTINE .ATM <1 .LST>
		    <FORM COND !<REST .LST>>>>
	.ATM>

<DEFINE EXECUTE ("ARGS" LST "AUX" ATM)
	<SET ATM <PARSE <STRING "ANONF-"
				<UNPARSE <SETG ANONF-COUNT
					       <+ ,ANONF-COUNT 1>>>>>>
	<COND (<TYPE? <1 .LST> FORM>
	       <SET LST ('() !.LST)>)>
	<EVAL <FORM ROUTINE .ATM !.LST>>
	.ATM>

;"Constants various"

<CONSTANT S-TEXT 0>
<CONSTANT S-WINDOW 1>

<CONSTANT S-BEEP 1>
<CONSTANT S-BOOP 2>

<CONSTANT H-NORMAL 0>
<CONSTANT H-INVERSE 1>

;"These may not be implemented on a target machine."
<GLOBAL H-BOLD 2>
;<GLOBAL H-ITALIC 4>

<CONSTANT D-TABLE-ON 3>
<CONSTANT D-TABLE-OFF -3>

<GLOBAL CHRH 0>
<GLOBAL CHRV 0>

<ROUTINE GPOS (C F)
	 <COND (<EQUAL? .F 1> .C)
	       (T
		<+ <* <- .C 1> .F> 1>)>>

<IF-YFLAG
<ROUTINE MAKE-WINDOW (N YL XL YS XS "OPTIONAL" (B 15))
	 <WINPOS .N
		 <GPOS .YL ,CHRV>
		 <GPOS .XL ,CHRH>>
	 <WINSIZE .N
		  <* .YS ,CHRV>
		  <* .XS ,CHRH>>
	 <WINATTR .N .B>
	 .N>>

<ROUTINE GCURSET (YL XL)
	 <COND (<ZERO? ,CURRENT-SCREEN>
		<SELECT-SCREEN 1>)>
	 <CURSET <GPOS .YL ,CHRV> <GPOS .XL ,CHRH>>>

;"tell macro and friends"

<IFFLAG (YFLAG
<TELL-TOKENS (CRLF CR)		<CRLF>
	     (NUM N) *		<PRINTN .X>
	     C *		<PRINTC .X>
	     S *:STRING		<PRINT .X>
	     CTE		<V-NUL>
	     D *		<WPRINTD .X>
	     TAG		<WPRINTTAG>
	     CHR *		<WPRINTCHR .X>
	     AO			<WPRINTD ,ACTION-OBJECT>
	     ACT		<WPRINTD ,ACTOR>
	     AOP		<WPRINTD-OBJECT-PERIOD>
	     MORE		<INPUT 1>
	     CLEAR		<CLEAR 2>
	     FORCE		<V-NUL>
	     RESET		<V-NUL>
	     WRAP		<V-NUL>
	     SCROLL		<V-NUL>>
	     
)
	(T
<TELL-TOKENS (CRLF CR)		<WCRLF>
	     (NUM N) *		<WPRINTN .X>
	     C *		<WPRINTC .X>
	     S *:STRING		<WPRINT .X>
	     CTE		<WCLEAR-TO-END>
	     D *		<WPRINTD .X>
	     TAG		<WPRINTTAG>
	     CHR *		<WPRINTCHR .X>
	     AO			<WPRINTD-OBJECT>
	     ACT		<WPRINTD-ACTOR>
	     AOP		<WPRINTD-OBJECT-PERIOD>
	     MORE		<WMORE>
	     CLEAR		<WCLEAR>
	     FORCE		<WFORCE>
	     RESET		<WRESET>
	     WRAP		<WWRAP>
	     SCROLL		<WSCROLL>>)>

<IFN-YFLAG
<ROUTINE WWRAP ()
	 <FCLEAR ,DEFAULT-WINDOW ,SCROLLBIT>>>

<IFN-YFLAG
<ROUTINE WSCROLL ()
	 <FSET ,DEFAULT-WINDOW ,SCROLLBIT>>>

<ROUTINE WPRINTCHR (CHR)
	 <COND (<IN-PARTY? .CHR> <WPRINTD .CHR>)
	       (T
		<TELL "[Error: ">
		<WPRINTD .CHR>
		<TELL "]">)>>

<IFN-YFLAG
<ROUTINE WPRINTD-ACTOR ()
	 <WPRINT <GET-DESC ,ACTOR>>>>

<IFN-YFLAG
<ROUTINE WPRINTD-OBJECT ()
	 <WPRINT <GET-DESC ,ACTION-OBJECT>>>>

;"macros"

<DEFMAC RFATAL ()
	'<PROG () <PUSH 8> <RSTACK>>>

<DEFMAC PROB ('BASE?)
	<FORM NOT <FORM L? .BASE? '<RANDOM 100>>>>

<ROUTINE PICK-ONE (TBL "AUX" LENGTH CNT RND MSG RFROB)
	 <SET LENGTH <GET .TBL 0>>
	 <SET CNT <GET .TBL 1>>
	 <SET LENGTH <- .LENGTH 1>>
	 <SET TBL <REST .TBL 2>>
	 <SET RFROB <REST .TBL <* .CNT 2>>>
	 <SET RND <RANDOM <- .LENGTH .CNT>>>
	 <SET MSG <GET .RFROB .RND>>
	 <PUT .RFROB .RND <GET .RFROB 1>>
	 <PUT .RFROB 1 .MSG>
	 <SET CNT <+ .CNT 1>>
	 <COND (<==? .CNT .LENGTH> 
		<SET CNT 0>)>
	 <PUT .TBL 0 .CNT>
	 .MSG>

;"MAIN-LOOP and associated routines"

;<ROUTINE ABS (N)
	 <COND (<NOT <L? .N 0>> .N)
	       (T <- 0 .N>)>>

<CONSTANT PERIOD-CR ".|">
<CONSTANT PERIOD ".">

<CONSTANT INF 32000>

<OBJECT WINDOWS-UNUSED
	(DESC "arc")
	(FLAGS BUSY SEEN LIT ENCHANTED SCOUTED SUBGROUP SINGLE-CAST
	       EXAMINED TRAPPED INCAPACITATED DEAD SOLVED DONT-TAKE TRIED
	       DONT-CAST DONT-SCOUT DONT-EXAMINE BLUE-MIX GRAY-MIX TRUTHFUL
	       INVENTORIED BLACK-MIX NEVER-DROP)
	(CAST-LIMIT INF)>

<OBJECT TEMP-WINDOW
	(LOC WINDOWS-UNUSED)
	(START-Y 0)
	(START-X 0)
	(END-Y 0)
	(END-X 0)
	(CUR-Y 0)
	(CUR-X 0)
	(WIDTH 0)
	(HEIGHT 0)>

<OBJECT WINDOWS
	(DESC "arc")>

;<ROUTINE WMAKE (SY EY SX EX "AUX" F)
	 <COND (<SET F <FIRST? ,WINDOWS-UNUSED>>
		<PUTP .F ,P?START-Y .SY>
		<PUTP .F ,P?START-X .SX>
		<PUTP .F ,P?CUR-Y .SY>
		<PUTP .F ,P?CUR-X .SX>
		<PUTP .F ,P?END-Y .EY>
		<PUTP .F ,P?END-X .EX>
		<PUTP .F ,P?WIDTH <- .EX .SX -1>>
		<PUTP .F ,P?HEIGHT <- .EY .SY -1>>
		.F)>>

;<ROUTINE WFLUSH (W) <MOVE .W ,WINDOWS-UNUSED>>

<GLOBAL DEFAULT-WINDOW <>>

<GLOBAL TEXT-WINDOW-LEFT ,INIT-TEXT-LEFT>

<IF-YFLAG
<GLOBAL PICINF-TBL <TABLE 0 0>>
>

<IF-YFLAG
<ROUTINE SETUP-WINDOWS ("AUX" PW PH)
	 <COND (<PICINF 2 ,PICINF-TBL>
		<SET PH <GET ,PICINF-TBL 0>>
		<SET PW <GET ,PICINF-TBL 1>>
		<SETG TEXT-WINDOW-LEFT
		      <+ 5 ;3 </ <+ .PW ,CHRH> ,CHRH>>>)
	       (T
		<SETG TEXT-WINDOW-LEFT ,INIT-TEXT-LEFT>)>
	 ;"Center top left of graphic window"
	 <MAKE-WINDOW 2
		      ,TOP-SCREEN-LINE
		      ,TEXT-WINDOW-LEFT
		      <- ,COMMAND-START-LINE ,TOP-SCREEN-LINE 1>
		      <- ,SCREEN-WIDTH ,TEXT-WINDOW-LEFT>>
	 ; "Changed as follows per TAA:
	    Window is top left of screen, and fills the area to the
	    borders drawn around other things.  Pictures will be centered
	    in this by GRAPHIC.  This allows us to ensure that pictures
	    will really, seriously, be cleared when needed."
	 <SETG GRAPHIC-WINDOW-Y <* <- ,COMMAND-START-LINE 2> ,CHRV>>
	 <SETG GRAPHIC-WINDOW-X <* <- ,TEXT-WINDOW-LEFT 2> ,CHRH>>
	 <MAKE-WINDOW 3
		      <IFFLAG (<==? MVER MAC> 1)
			      (T 2)>
		      ;</ <- ,COMMAND-START-LINE </ .PH ,CHRV>> 2>
		      ;"Was ,TOP-SCREEN-LINE"
		      <IFFLAG (<==? MVER MAC> 1)
			      (T 2)>
		      ;<+ </ </ <- <* <- ,TEXT-WINDOW-LEFT 1> ,CHRH>
				  .PW> 2> ,CHRH> 1>
		      ;"Was 2; centered position of picture, +1 for fencepost?"
		      <IFFLAG (<==? MVER MAC> <- ,COMMAND-START-LINE 2>)
			      (T <- ,COMMAND-START-LINE 3>)>
		      ;<+ </ .PH ,CHRV> 1>
		      ;"Was <- ,COMMAND-START-LINE ,TOP-SCREEN-LINE 1>
			the +1 is for the Mac, at least..."
		      <IFFLAG (<==? MVER MAC> <- ,TEXT-WINDOW-LEFT 2>)
			      (T
			       <- ,TEXT-WINDOW-LEFT 3>)> 
		      ;</ .PW ,CHRH>
		      ;"Was <- ,TEXT-WINDOW-LEFT 3>"
		      11>
	 ; "Set background color to black for this window"
	 <IF-BLACK-PICTURE-BORDER
	  <SCREEN 3>
	  <COLOR 9 2>
	  <CLEAR 3>>>>

;<IFFLAG (YFLAG
<ROUTINE TEXT-RESIZE (NUM "AUX" (LN 2) F)
	 <SETG TEXT-WINDOW-LEFT .NUM>
	 <MAKE-WINDOW 2
		      ,TOP-SCREEN-LINE
		      .NUM
		      <- ,COMMAND-START-LINE ,TOP-SCREEN-LINE 1>
		      <- ,SCREEN-WIDTH .NUM>>
	 <CLEAR 2>
	 <COND (<G? .NUM 3>
		<SCREEN 3>	; "TEMPORARY DUE TO YZIP/MAC PROBLEM."
		<CLEAR 3>
		<SELECT-SCREEN 1>
		<IFFLAG (<==? MVER MAC>
			 <SET LN <- .LN 1>>)> 
		<REPEAT ()
			<COND (<EQUAL? .LN <- ,COMMAND-START-LINE 1>>
			       <RETURN>)
			      (T
			       <GCURSET .LN <- ,TEXT-WINDOW-LEFT 1>>
			       <IFFLAG (<==? MVER MAC>
					<SET F <FONT 3>>
					<PRINTC 41>
					<SET F <FONT 1>>)
				       (T
					<PRINTI " ">)>
			       <SET LN <+ .LN 1>>)>>
		<SELECT-SCREEN 2>)>
	 <RTRUE>>)
	(T
<ROUTINE TEXT-RESIZE (NUM "AUX" (LN 2))
	 <SETG TEXT-WINDOW-LEFT .NUM>
	 <PUTP ,TEXT-WINDOW ,P?WIDTH <- ,SCREEN-WIDTH .NUM>>
	 <PUTP ,TEXT-WINDOW ,P?START-X .NUM>
	 <WCLEAR ,TEXT-WINDOW>
	 <PUTP ,GRAPHICS-WINDOW ,P?END-X <- .NUM 2>>
	 <PUTP ,GRAPHICS-WINDOW ,P?WIDTH <- .NUM 3>>
	 <COND (<G? .NUM 3> <WCLEAR ,GRAPHICS-WINDOW>)>
	 <HLIGHT ,H-INVERSE>
	 <REPEAT ()
		 <COND (<EQUAL? .LN <- ,COMMAND-START-LINE 1>>
			<RETURN>)
		       (T
			<GCURSET .LN <- ,TEXT-WINDOW-LEFT 1>>
			<PRINTI " ">
			<SET LN <+ .LN 1>>)>>
	 <HLIGHT ,H-NORMAL>>)>



;"Find the cursor"

<IFN-YFLAG
<GLOBAL WPRINT-BUF
	<TABLE
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 >>>

<IFN-YFLAG
<ROUTINE TBLPRINT (STR "OPTIONAL" (TBL ,WPRINT-BUF) (PC 0))
	 <PUT .TBL 0 0>
	 <DIROUT ,D-TABLE-ON .TBL>
	 <COND (<ZERO? .PC>
		<PRINT .STR>)
	       (<EQUAL? .PC ,WPRINT-NUM>
		<PRINTN .STR>)
	       (<EQUAL? .PC ,WPRINT-CHAR>
		<PRINTC .STR>)
	       (<EQUAL? .PC ,WPRINT-SPACE>
		<PRINTT ,WPRINT-EBUF .STR>)
	       (T
		<PRINTI "**ILL**">)>
	 <DIROUT ,D-TABLE-OFF>
	 <GET .TBL 0>>>

<CONSTANT WPRINT-NUM 1>
<CONSTANT WPRINT-CHAR 2>
<CONSTANT WPRINT-SPACE 3>

<IFN-YFLAG
<ROUTINE WPRINTC (CHR "OPTIONAL" (A ,DEFAULT-WINDOW))
	 <WPRINT .CHR .A ,WPRINT-CHAR>>>

<IFN-YFLAG
<ROUTINE WPRINTN (NUM "OPTIONAL" (A ,DEFAULT-WINDOW))
	 <WPRINT .NUM .A ,WPRINT-NUM>>>

<IFFLAG (YFLAG
<ROUTINE WPRINTTAG ()
	 <COND (<G? ,TAG-NAME-LENGTH 0>
		<PRINTT <REST ,NAME-TBL 2> ,TAG-NAME-LENGTH>)
	       (T
		<PRINT-DESC ,TAG>)>>)
	(T
<ROUTINE WPRINTTAG ()
	 <COND (<G? ,TAG-NAME-LENGTH 0>
		<WPRINT "<your name>">)
	       (T
		<WPRINT <GET-DESC ,TAG>>)>>)>

<IFFLAG (YFLAG
<ROUTINE WPRINTD (OBJ "OPTIONAL" A) <PRINT-DESC .OBJ>>)
	(T
<ROUTINE WPRINTD (OBJ "OPTIONAL" (A ,DEFAULT-WINDOW))
	 <WPRINT <GET-DESC .OBJ> .A>>)>

<GLOBAL WPRINT-FLAG <>>

<IFN-YFLAG
<ROUTINE WPRINT (STR "OPTIONAL" (A ,DEFAULT-WINDOW) (PC 0)
		       "AUX" (ENDX <GETP .A ,P?END-X>) LEN
		   	     (CURX <GETP .A ,P?CUR-X>) TMP
			     (BUF <REST ,WPRINT-BUF 2>) NBUF
			     (CL <GETP .A ,P?LINE>))
	 <COND (<AND ,SCRIPTING-FLAG <EQUAL? .A ,TEXT-WINDOW>>
		<SELECT-SCREEN 0>
		<DIROUT -1>
		<PRINT .STR>
		<DIROUT 1>
		<SELECT-SCREEN 1>)>
	 <SETG WPRINT-FLAG T>
	 <SET LEN <TBLPRINT .STR ,WPRINT-BUF .PC>>
	 <GCURSET <GETP .A ,P?CUR-Y> .CURX>
	 ;"Scan for line fit"
	 <REPEAT ()
		 <SET CURX <GETP .A ,P?CUR-X>>
		 <COND (<NOT <G? <SET TMP <+ .CURX .LEN>> .ENDX>>
			<COND (<NOT <FSET? .A ,SCROLLBIT>>
			       <PRINTT .BUF .LEN>)
			      (T
			       <COPYT .BUF .CL .LEN>
			       <PUTP .A ,P?LINE <SET CL <REST .CL .LEN>>>)>
			<PUTP .A ,P?CUR-X .TMP>
		        <RETURN>)
		       (T
			<SET TMP <- .ENDX .CURX>>
			;"Positions left"
			<SET NBUF <REST .BUF .TMP>>
			<REPEAT ()
				<COND (<OR <ZERO? .TMP>
					   <EQUAL? <GETB .NBUF 0> 32 13>>
				       <RETURN>)
				      (T
				       <SET NBUF <BACK!- .NBUF 1>>
				       <SET TMP <- .TMP 1>>)>>
			<COND (<NOT <ZERO? .TMP>>
			       <COND (<NOT <FSET? .A ,SCROLLBIT>>
				      <PRINTT .BUF .TMP>)
				     (T
				      <COPYT .BUF .CL .TMP>
				      <SET CL <REST .CL .TMP>>)>
			       <SET TMP <+ .TMP 1>>)>
			<WCRLF .A T>
			<SETG WPRINT-FLAG T>
			<SET CL <GETP .A ,P?LINE>>
			<SET LEN <- .LEN .TMP>>
			<SET BUF <REST .BUF .TMP>>
			;"Flush leading spaces"
			<REPEAT ()
				<COND (<EQUAL? <GETB .BUF 0> ,SPACE-BAR>
				       <SET BUF <REST .BUF>>
				       <SET LEN <- .LEN 1>>)
				      (T <RETURN>)>>)>>>>

<IFN-YFLAG
<ROUTINE WMORE ("OPTIONAL" (A ,DEFAULT-WINDOW) "AUX" CHR)
	 <COND (<FSET? .A ,SCROLLBIT>
		<WFORCE .A>)>
	 <GCURSET <- ,COMMAND-START-LINE 1>
		  <- ,SCREEN-WIDTH 8>>
	 <HLIGHT ,H-INVERSE>
	 <PRINTI "[MORE]">
	 <SET CHR <INPUT 1>>
	 <GCURSET <- ,COMMAND-START-LINE 1>
		  <- ,SCREEN-WIDTH 8>>
	 <PRINTI "       ">
	 <HLIGHT ,H-NORMAL>
	 .CHR>>

<IFN-YFLAG
<GLOBAL MORE-COUNT 0>>

<IFN-YFLAG
<ROUTINE WCRLF ("OPTIONAL" (A ,DEFAULT-WINDOW) (INT? <>) "AUX" CURX CURY LP L)
	 <COND (<AND <NOT .INT?> ,SCRIPTING-FLAG>
		<SELECT-SCREEN 0>
		<DIROUT -1>
		<CRLF>
		<DIROUT 1>
		<SELECT-SCREEN 1>)> 
	 <COND (<FSET? .A ,SCROLLBIT>
		<SET LP <GETP .A ,P?LINE-PTR>>
		<COND (<G? <SET LP <+ .LP 1>>
			   <GETP .A ,P?HEIGHT>>
		       <SET LP 0>)>
		<PUTP .A ,P?LINE-PTR .LP>
		<PUTP .A ,P?LINE <SET L <GET <GETP .A ,P?LINE-TBL> .LP>>>
		<COPYT .L 0 ,SCREEN-WIDTH>
		<PUTP .A ,P?CUR-X <GETP .A ,P?START-X>>
		<SETG MORE-COUNT <+ ,MORE-COUNT 1>>
		<COND (<EQUAL? ,MORE-COUNT <GETP .A ,P?HEIGHT>>
		       <WMORE .A>)>
		<RTRUE>)
	       (T
		<COND (<G? <SET CURY <+ <GETP .A ,P?CUR-Y> 1>>
			   <GETP .A ,P?END-Y>>
		       <WMORE .A>
		       <SET CURY <GETP .A ,P?START-Y>>)>
		<GCURSET .CURY
			 <SET CURX <GETP .A ,P?START-X>>>
		<PRINTT ,WPRINT-EBUF
			<- <GETP .A ,P?END-X> .CURX>>
		<GCURSET .CURY .CURX>
		<PUTP .A ,P?CUR-X .CURX>
		<PUTP .A ,P?CUR-Y .CURY>)>>>

<IFN-YFLAG
<ROUTINE WFORCE ("OPTIONAL" (A ,DEFAULT-WINDOW)
		 "AUX" END OFF
		       (SX <GETP .A ,P?START-X>)
		       (CY <GETP .A ,P?START-Y>)
		       (WIDTH <GETP .A ,P?WIDTH>)
		       (HEIGHT <GETP .A ,P?HEIGHT>)
		       (LT <GETP .A ,P?LINE-TBL>))
	 <SETG MORE-COUNT 0>
	 <COND (<NOT ,WPRINT-FLAG> <RTRUE>)
	       (T
		<SETG WPRINT-FLAG <>>)>
	 <COND (<G? <SET END <GETP .A ,P?LINE-PTR>>
		    .HEIGHT>
		<SET END 0>)>
	 <SET OFF .END>
	 <REPEAT ()
		 <COND (<G? <SET OFF <+ .OFF 1>> .HEIGHT> <SET OFF 0>)>
		 <COND (<EQUAL? .OFF .END>
			<RETURN>)>
		 <GCURSET .CY .SX>
		 <PRINTT ,WPRINT-EBUF .WIDTH>
		 <GCURSET .CY .SX>
		 <PRINTT <GET .LT .OFF> ,SCREEN-WIDTH>
		 <SET CY <+ .CY 1>>>>>

<GLOBAL WPRINT-EBUF <TABLE (BYTE)
32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32
32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32
32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32
32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32
>>

;<ROUTINE WCLEAR-TO-END ("OPTIONAL" (A ,DEFAULT-WINDOW))
	 <WCLEAR .A T>>

<IFN-YFLAG
<ROUTINE WCLEAR ("OPTIONAL" (A ,DEFAULT-WINDOW) (TO-END? <>)
		  "AUX" (LMAX <GETP .A ,P?END-Y>) LIN
		  	(STX <GETP .A ,P?START-X>)
			(WID <GETP .A ,P?WIDTH>))
	 <COND (.TO-END?
		<SET LIN <+ <GETP .A ,P?CUR-Y> 1>>)
	       (T
		<SET LIN <GETP .A ,P?START-Y>>)>
	 <REPEAT ()
		 <COND (<G? .LIN .LMAX>
			<RETURN>)
		       (T
			<GCURSET .LIN .STX>
			<PRINTT ,WPRINT-EBUF .WID>
			<SET LIN <+ .LIN 1>>)>>
	 <WRESET .A>>>

<IFN-YFLAG
<ROUTINE WRESET ("OPTIONAL" (A ,DEFAULT-WINDOW)
		 "AUX" (OFF 0) (HEIGHT <GETP .A ,P?HEIGHT>) LT)
	 <COND (<FSET? .A ,SCROLLBIT>
		<PUTP .A ,P?LINE-PTR 0>
		<PUTP .A ,P?LINE <GET <SET LT <GETP .A ,P?LINE-TBL>> 0>>
		<REPEAT ()
			<COPYT <GET .LT .OFF> 0 ,SCREEN-WIDTH>
			<COND (<G? <SET OFF <+ .OFF 1>> .HEIGHT>
			       <RETURN>)>>)>
	 <PUTP .A ,P?CUR-X <GETP .A ,P?START-X>>
	 <PUTP .A ,P?CUR-Y <GETP .A ,P?START-Y>>>>

<IFFLAG (YFLAG
<ROUTINE WSPACE (N)
	 <REPEAT ()
		 <COND (<L? <SET N <- .N 1>> 0> <RETURN>)
		       (T <PRINTC 32>)>>>)
	(T
<ROUTINE WSPACE (N "OPTIONAL" (A ,DEFAULT-WINDOW))
	 <WPRINT .N .A ,WPRINT-SPACE>>)>

<ROUTINE WCENTER (STR CNT)
	 <WSPACE </ <- <- ,SCREEN-WIDTH ,TEXT-WINDOW-LEFT> .CNT> 2>>
	 <TELL .STR>>

<GLOBAL CURRENT-GRAPHIC <>>

<IF-YFLAG
<ROUTINE GRAPHIC-STAMP (PIC WHERE "AUX" CURH CURW TOP LEFT
			NEWH NEWW)
  ;<COND (<NOT ,GRAPHICS-FLAG> <RTRUE>)>
  <SET CURH <GET ,PICINF-TBL 0>>
  <SET CURW <GET ,PICINF-TBL 1>>
  <SET TOP <+ </ <- ,GRAPHIC-WINDOW-Y .CURH> 2> 1>>
  <SET LEFT <+ </ <- ,GRAPHIC-WINDOW-X .CURW> 2> 1>>
  <COND (<G? .WHERE 0>
	 ; "WHERE is a funny picture, specifying the location
	    of the stamp relative to the corner of the background
	    graphic."
	 <PICINF .WHERE ,PICINF-TBL>
	 <SET LEFT <+ <GET ,PICINF-TBL 1> .LEFT>>
	 <SET TOP <+ <GET ,PICINF-TBL 0> .TOP>>)
	(T
	 <PICINF .PIC ,PICINF-TBL>
	 <SET NEWH <GET ,PICINF-TBL 0>>
	 <SET NEWW <GET ,PICINF-TBL 1>>
	 <COND (<NOT <0? <ANDB .WHERE ,STAMP-RIGHT>>>
		<SET LEFT <+ .LEFT <- .CURW .NEWW>>>)>
	 <COND (<NOT <0? <ANDB .WHERE ,STAMP-BOTTOM>>>
		<SET TOP <+ .TOP <- .CURH .NEWH>>>)>)>
  ;<SCREEN 3>
  <DISPLAY .PIC .TOP .LEFT>
  ;<SCREEN 2>>>

<IF-YFLAG
<GLOBAL CURRENT-STAMP <>>
<GLOBAL CURRENT-STAMP-LOC <>>
>

<IFFLAG (YFLAG
<ROUTINE GRAPHIC ("OPTIONAL" (STR <>) (STAMP <>) WHERE)
	 <COND (<OR <NOT ,GRAPHICS-FLAG>
		    <EQUAL? .STR ,CURRENT-GRAPHIC>>
		<RTRUE>)>
	 <COND (<AND <NOT .STR> <NOT .STAMP>>
		<SET STR ,CURRENT-GRAPHIC>
		<SET STAMP ,CURRENT-STAMP>
		<SET WHERE ,CURRENT-STAMP-LOC>)
	       (.STR
		<SETG CURRENT-GRAPHIC .STR>)>
	 <SCREEN 3>
	 <COND (.STR <CLEAR 3>)>
	 <COND (<ZERO? .STR> T)
	       (<AND <G? .STR 0> <L? .STR 255>>
		<COND (<PICINF .STR ,PICINF-TBL>
		       <DISPLAY .STR
			 <+ </ <- ,GRAPHIC-WINDOW-Y <GET ,PICINF-TBL 0>> 2> 1>
			 <+ </ <- ,GRAPHIC-WINDOW-X <GET ,PICINF-TBL 1>> 2> 1>>)>)
	       (T <PRINT .STR>)>
	 <COND (.STAMP
		<SETG CURRENT-STAMP .STAMP>
		<SETG CURRENT-STAMP-LOC .WHERE>
		<GRAPHIC-STAMP .STAMP .WHERE>)
	       (T
		<SETG CURRENT-STAMP <>>)>
	 <SCREEN 2>>)
	(T
<ROUTINE GRAPHIC ("OPTIONAL" (STR <>) (STAMP <>) WHERE)
	 <COND (<OR <NOT ,GRAPHICS-FLAG>
		    <EQUAL? .STR ,CURRENT-GRAPHIC>>
		<RTRUE>)>
	 <COND (.STAMP
		<SET STR .STAMP>
		<SETG CURRENT-GRAPHIC .STR>)
	       (<NOT .STR>
		<SET STR ,CURRENT-GRAPHIC>)
	       (T
		<SETG CURRENT-GRAPHIC .STR>)>
	 <WCLEAR ,GRAPHICS-WINDOW>
	 <WPRINT .STR ,GRAPHICS-WINDOW>>)>
		    
<GLOBAL CURRENT-SCREEN 0>

<ROUTINE SELECT-SCREEN (N)
	 <SCREEN .N>
	 <SETG CURRENT-SCREEN .N>>

<ROUTINE I/WE ("OPTIONAL" (N 1) (CAPS? <>))
	 <COND (<G? ,PARTY-MAX .N>
		<COND (.CAPS? "We") (T "we")>)
	       (T "I")>>

<ROUTINE I-WAS/WE-WERE ("OPTIONAL" (N 1))
	 <COND (<G? ,PARTY-MAX .N> "we were")
	       (T "I was")>>

<ROUTINE I/EACH ("OPTIONAL" (N 1))
	 <COND (<G? ,PARTY-MAX .N> "each of us")
	       (T "I")>>

<ROUTINE MY/OUR ("OPTIONAL" (N 1))
	 <COND (<G? ,PARTY-MAX .N> "our")
	       (T "my")>>

<ROUTINE ME/US ("OPTIONAL" (N 1))
	 <COND (<G? ,PARTY-MAX .N> "us")
	       (T "me")>>

<ROUTINE PRINT-DESC (OBJ)
	 <PRINT <GET-DESC .OBJ>>>

<ROUTINE GET-DESC (OBJ)
	 <COND (<AND <L? ,SCREEN-WIDTH ,12-WIDTH>
		     <SET STR <GETP .OBJ ,P?12DESC>>>
		.STR)
	       (T
		<GETP .OBJ ,P?SDESC>)>>

<ROUTINE PRINT-COMMAND (CMD)
	 <PRINT <GET-COMMAND .CMD>>>

<ROUTINE GET-COMMAND (CMD)
	 <GET .CMD ,COMMAND-FULL>>

;"Pix that come up for one move only; can't have a stamp"
<ROUTINE SINGLE-MOVE-GRAPHIC (G)
	 <SETG SAVED-GRAPHIC ,CURRENT-GRAPHIC>
	 <GRAPHIC .G>
	 <QUEUE I-CLEAR-SINGLE-MOVE-GRAPHIC 1>>

<GLOBAL SAVED-GRAPHIC 0>

<OBJECT I-CLEAR-SINGLE-MOVE-GRAPHIC
	(TIME 0)
	(ACTION
	 <EXECUTE ()
		  <GRAPHIC ,SAVED-GRAPHIC>>)>