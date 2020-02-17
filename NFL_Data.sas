/* NFL DATA "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-02-04/attendance.csv" 

WE HAVE SOME INITIAL QUESTIONS:

1) 	For each team, what is their average attendance 
	considering years between 2000 and 2019?

2) 	Which team has the highest average attendance value?

3) 	What is the average attendance by year 
	between 2005 and 2019 for all teams that made the playoffs?
	Does that look different from the mean for those that did not make it
	to the playoffs? */
  
/* We complete these questions step-by-step to demonstrate each individual process
rather than completing the code as efficiently as possible*/

/* For 1) */

/* IMPORT ATTENDANCE DATA */

FILENAME Attend TEMP;

PROC HTTP 	URL = "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-02-04/attendance.csv"
			METHOD = "GET"
			OUT = Attend;
RUN;

PROC IMPORT DATAFILE = Attend
			DBMS = CSV
			OUT = original_attendance
			REPLACE
			;
	GUESSINGROWS=500; 	/* Use options GUESSINGROWS to avoid truncation. 										*/
						/* SAS reads 500 rows of the file to scan to determine the appropriate data type and 	*/
						/* length for the columns. 																*/
RUN;

proc print data=original_attendance(obs=100); /* Check the first 100 observations to see if IMPORT worked.		*/
run;

data attendance;				/* attendance IS THE NEW DATA SET THAT WE CREATE AND SEND DATA TO 		*/
	set original_attendance;	/* original_attendance IS THE NEW DATA SET WE READ DATA FROM	 		*/
	keep 	team  				/* VARIABLE IN THE ORIGINAL DATA SET THAT RETURNS THE CITY OF THE TEAM	*/
			team_name 			/* VARIABLE IN THE ORIGINAL DATA SET THAT RETURNS THE NAME OF THE TEAM	*/
			total 				/* VARIABLE IN THE ORIGINAL DATA SET THAT RETURNS THE TOTAL ATTENDANCE ACROSS 17 WEEKS */
			year 				/* VARIABLE IN THE ORIGINAL DATA SET THAT RETURNS THE SEASON YEAR 		*/
	;
run;

/* Take a look at the first 10 observations from the data set 'attendance', to see if everything is OK */
proc print data = attendance(obs=10);
run;

/* We se that the information 'Arizona Cardinals 2000 893926 ' repeats several times */
/* Let us take a look at the ORIGINAL data set with ALL columns to see if we can figure out why this happens */
proc print data = original_attendance(obs=20);
run;
/* Repetition happens because we have a attendance values by week for each team. 	*/
/* It's not an error in the data set, it's just how it was created.					*/
/* This tells us that we can remove the duplicates in the 'attendance' data set 	*/
/* without worrying about it.														*/	


/* REMOVE DUPLICATES IN THE 'attendance' DATA SET */

proc sort 	data = attendance 				/* Input data set to READ data FROM								*/
			nodupkey 						/* PROC SORT option that tells SAS to remove duplicated values 	*/
			out = attendance_nodup;			/* Output data set to SAVE unique (non-duplicated) data TO		*/
	by team team_name year;					/* Sort the data set by these columns 							*/
run;

data attendance_nodup_filter;				/* Input data set to SAVE data TO (NOTICE THAT IN A DATA STEP 		*/
	set attendance_nodup;					/* Output data set to SAVE filtered data TO							*/
	where 2000 <= year <= 2019;				/* within 2000 and 2019	*/
run;

ODS RTF FILE = "/home/u####/YOUR_FOLDER/HTML_average_attendance_output.html"; /* <- change u#### to your user, and YOUR_FOLDER to your folder */
	PROC MEANS 	DATA= attendance_nodup_filter 	/* Input data set to READ data FROM											 */
			MEAN							/* PROC MEANS option that tells SAS to return only the average(mean) 		 */
			;								/* END of PROC MEANS options										 		 */
	    VAR total;								/* CALL THE VARIABLE total FROM THE DATA SET THAT GIVES THE TOTAL ATTENDANCE */
	    CLASS team team_name;					/* RETURN RESULTS GROUPED BY team (TEAM CITY) AND team_name (TEAM NAME)		 */
  RUN;
ODS RTF CLOSE;

  
/* For 2) */

proc sort 	data = average_attendance_team_v02 				/* Input data set to READ data FROM				*/
			out = attendance_sorted;			/* Output data set to SAVE unique (non-duplicated) data TO		*/
	by descending total;					/* Sort the data set by these columns 							*/
run;

proc print data = attendance_sorted(obs=1); /*check to see if its the right value*/
run;

ODS RTF FILE = "/home/u####2/New Work Folder/question1.rtf"; /* <- change u#### to your user, and YOUR_FOLDER to your folder */
	proc print data = attendance_sorted(obs=1);
	run;
ODS RTF CLOSE;   /*prints the data*/

/* For 3) */

/* IMPORT STANDINGS DATA

DATA SOURCE:

"https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-02-04/standings.csv"

FILENAME Stand TEMP;

PROC HTTP 	URL = "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-02-04/standings.csv"
			METHOD = "GET"
			OUT = Stand;
RUN;

PROC IMPORT DATAFILE = Stand
			DBMS = CSV
			OUT = original_standings
			REPLACE
			;
	GUESSINGROWS = 100; /* Use options GUESSINGROWS to avoid truncation. 										*/
						/* SAS reads 500 rows of the file to scan to determine the appropriate data type and 	*/
						/* length for the columns. 																*/
RUN;

data standings;				/* attendance IS THE NEW DATA SET THAT WE CREATE AND SEND DATA TO 		*/
	set original_standings;	/* original_attendance IS THE NEW DATA SET WE READ DATA FROM	 		*/
	keep 	team  				/* VARIABLE IN THE ORIGINAL DATA SET THAT RETURNS THE CITY OF THE TEAM	*/
			team_name 			/* VARIABLE IN THE ORIGINAL DATA SET THAT RETURNS THE NAME OF THE TEAM	*/
			playoffs				/* VARIABLE IN THE ORIGINAL DATA SET THAT RETURNS THE TOTAL ATTENDANCE ACROSS 17 WEEKS */
			year 				/* VARIABLE IN THE ORIGINAL DATA SET THAT RETURNS THE SEASON YEAR 		*/
	;
run;

proc sort 	data = standings 				/* Input data set to READ data FROM								*/
			nodupkey 						/* PROC SORT option that tells SAS to remove duplicated values 	*/
			out = standings_nodup;			/* Output data set to SAVE unique (non-duplicated) data TO		*/
	by team team_name year;					/* Sort the data set by these columns 							*/
Run;

data standings_nodup_filter;				/* Input data set to SAVE data TO (NOTICE THAT IN A DATA STEP 		*/
											/* THIS COMES FIRST - COMPARE IT TO THE PROC SORT ABOVE				*/

	set standings_nodup;					/* Output data set to SAVE filtered data TO							*/

	where 2005 <= year <= 2019;				/* THIS IS A ROW FILTER - Meaning that we drop rows that are NOT 	*/
											/* within 2000 and 2019												*/
run;

data attendance_nodup_filter2;				/* Input data set to SAVE data TO (NOTICE THAT IN A DATA STEP 		*/
											/* THIS COMES FIRST - COMPARE IT TO THE PROC SORT ABOVE				*/

	set attendance_nodup;					/* Output data set to SAVE filtered data TO							*/

	where 2005 <= year <= 2019;				/* THIS IS A ROW FILTER - Meaning that we drop rows that are NOT 	*/
											/* within 2000 and 2019												*/
run;

data merged_table;
 merge standings_nodup_filter attendance_nodup_filter2; /* OBSERVE THE USE OF THE IN= OPTION */
 by team team_name year;					   /* SUBSET ON inA USING IF */
Run;

data merged_table_avg;
	set merged_table;
	avg = total/16;  /*dividing the yearly avg by 16 games to get weekly avg*/ 
RUN;

ODS RTF FILE = "/home/u####/YOUR_FOLDER/HTML_average_attendance_output.html"; /* <- change u#### to your user, and YOUR_FOLDER to your folder */
	PROC MEANS 	DATA= merged_table_avg 	/* Input data set to READ data FROM											 */
			MEAN							/* PROC MEANS option that tells SAS to return only the average(mean) 		 */
			;								/* END of PROC MEANS options										 		 */

	    VAR avg;								/* CALL THE VARIABLE total FROM THE DATA SET THAT GIVES THE TOTAL ATTENDANCE */
	    CLASS year playoffs;					/* RETURN RESULTS GROUPED BY year AND playoffs	 */
  RUN;
ODS RTF CLOSE;










