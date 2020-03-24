24/03/2020
libname classdat "C:\EPI5143 Course Material\datasets"; 
libname ex "C:\EPI5143 Course Material\EPI5143 exercise"; 

/******** Question 1 ***********/
*Dates between 2003-2004;
data abstract; 
set classdat.nhrabstracts; 
if 2003 <= year(datepart(hraAdmDtm))<= 2004 then output;
run;

proc sort data=abstract nodupkey;
by hraencwid; 
run;

/******** Question 2+3 ***********/
proc sort data=classdat.nhrdiagnosis out=diagnosis;
by hdghraencwid;
run; 

data diabetes_;
set diagnosis;
	by hdghraencwid;
	if first.hdghraencwid=1 then do;
	dm=0;count=0; 
	end;
	if hdgcd in:('250' 'E10' 'E11') then do; 
	dm=1;count=count+1;
	end;
	if last.hdghraencwid=1 then output;
	retain dm count; 
run;

proc freq data=diabetes_;
tables dm count;
run;

%macro skip; 
	data diabetes;
	set classdat.nhrdiagnosis;
	dm=0;
	if hdgcd in:('250' 'E10' 'E11') 
	then dm=1; 
	run;

	proc means data=diabetes_ noprint;
	class hdghraencwid;
	types hdghraencwid; 
	var dm;
	output out=diabetes_ max(dm)=dm n(dm)=count sum(dm)=dm_count;
	run;
%mend skip; 


proc sort data=abstract nodupkey;
by hraencwid;
run;

proc sort data=diabetes_;
by hdghraencwid;
run;

/******** Question 4 ***********/
*In=a for IDs from spine; 
*Setting missing diabetes codes to 0; 
data final;
	merge abstract(in=a) diabetes_(in=b rename=(hdghraencwid=hraencwid));
	by hraencwid;
	if a;
	if dm=. then dm=0;
	if count=. then count=0;
	if dm_count=. then dm_count=0;
run;

/******** Question 5 ***********/
/******** # observations matches spine dataset ***********/ 
proc freq data=final;
tables dm count;
run;

/* Between January 1st, 2003 to December 31st 2004, the proportion of diabetes diagnoses accounted for during
admissions was 83/2230 (3.72%) */

/*Total number of admissions btwn. Jan, 1st 2003 and Dec, 31st, 2004 = 2230 */ 
