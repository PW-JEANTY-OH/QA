/* ----------------------------------------
Code exported from SAS Enterprise Guide
DATE: Thursday, February 7, 2019     TIME: 12:55:36 PM
PROJECT: CostPerUoS_IPNursing_v2
PROJECT PATH: G:\Corporate\share\Quality and Affordability Initiative\Data\Analytics Strategy\Sustainment Tools\CostPerUoS\CostPerUoS_IPNursing_v2.egp
---------------------------------------- */

/* ---------------------------------- */
/* MACRO: enterpriseguide             */
/* PURPOSE: define a macro variable   */
/*   that contains the file system    */
/*   path of the WORK library on the  */
/*   server.  Note that different     */
/*   logic is needed depending on the */
/*   server type.                     */
/* ---------------------------------- */
%macro enterpriseguide;
%global sasworklocation;
%local tempdsn unique_dsn path;

%if &sysscp=OS %then %do; /* MVS Server */
	%if %sysfunc(getoption(filesystem))=MVS %then %do;
        /* By default, physical file name will be considered a classic MVS data set. */
	    /* Construct dsn that will be unique for each concurrent session under a particular account: */
		filename egtemp '&egtemp' disp=(new,delete); /* create a temporary data set */
 		%let tempdsn=%sysfunc(pathname(egtemp)); /* get dsn */
		filename egtemp clear; /* get rid of data set - we only wanted its name */
		%let unique_dsn=".EGTEMP.%substr(&tempdsn, 1, 16).PDSE"; 
		filename egtmpdir &unique_dsn
			disp=(new,delete,delete) space=(cyl,(5,5,50))
			dsorg=po dsntype=library recfm=vb
			lrecl=8000 blksize=8004 ;
		options fileext=ignore ;
	%end; 
 	%else %do; 
        /* 
		By default, physical file name will be considered an HFS 
		(hierarchical file system) file. 
		*/
		%if "%sysfunc(getoption(filetempdir))"="" %then %do;
			filename egtmpdir '/tmp';
		%end;
		%else %do;
			filename egtmpdir "%sysfunc(getoption(filetempdir))";
		%end;
	%end; 
	%let path=%sysfunc(pathname(egtmpdir));
    %let sasworklocation=%sysfunc(quote(&path));  
%end; /* MVS Server */
%else %do;
	%let sasworklocation = "%sysfunc(getoption(work))/";
%end;
%if &sysscp=VMS_AXP %then %do; /* Alpha VMS server */
	%let sasworklocation = "%sysfunc(getoption(work))";                         
%end;
%if &sysscp=CMS %then %do; 
	%let path = %sysfunc(getoption(work));                         
	%let sasworklocation = "%substr(&path, %index(&path,%str( )))";
%end;
%mend enterpriseguide;

%enterpriseguide


/* Conditionally delete set of tables or views, if they exists          */
/* If the member does not exist, then no action is performed   */
%macro _eg_conditional_dropds /parmbuff;
	
   	%local num;
   	%local stepneeded;
   	%local stepstarted;
   	%local dsname;
	%local name;

   	%let num=1;
	/* flags to determine whether a PROC SQL step is needed */
	/* or even started yet                                  */
	%let stepneeded=0;
	%let stepstarted=0;
   	%let dsname= %qscan(&syspbuff,&num,',()');
	%do %while(&dsname ne);	
		%let name = %sysfunc(left(&dsname));
		%if %qsysfunc(exist(&name)) %then %do;
			%let stepneeded=1;
			%if (&stepstarted eq 0) %then %do;
				proc sql;
				%let stepstarted=1;

			%end;
				drop table &name;
		%end;

		%if %sysfunc(exist(&name,view)) %then %do;
			%let stepneeded=1;
			%if (&stepstarted eq 0) %then %do;
				proc sql;
				%let stepstarted=1;
			%end;
				drop view &name;
		%end;
		%let num=%eval(&num+1);
      	%let dsname=%qscan(&syspbuff,&num,',()');
	%end;
	%if &stepstarted %then %do;
		quit;
	%end;
%mend _eg_conditional_dropds;


/* save the current settings of XPIXELS and YPIXELS */
/* so that they can be restored later               */
%macro _sas_pushchartsize(new_xsize, new_ysize);
	%global _savedxpixels _savedypixels;
	options nonotes;
	proc sql noprint;
	select setting into :_savedxpixels
	from sashelp.vgopt
	where optname eq "XPIXELS";
	select setting into :_savedypixels
	from sashelp.vgopt
	where optname eq "YPIXELS";
	quit;
	options notes;
	GOPTIONS XPIXELS=&new_xsize YPIXELS=&new_ysize;
%mend _sas_pushchartsize;

/* restore the previous values for XPIXELS and YPIXELS */
%macro _sas_popchartsize;
	%if %symexist(_savedxpixels) %then %do;
		GOPTIONS XPIXELS=&_savedxpixels YPIXELS=&_savedypixels;
		%symdel _savedxpixels / nowarn;
		%symdel _savedypixels / nowarn;
	%end;
%mend _sas_popchartsize;


ODS PROCTITLE;
OPTIONS DEV=PNG;
GOPTIONS XPIXELS=0 YPIXELS=0;
FILENAME EGSRX TEMP;
ODS tagsets.sasreport13(ID=EGSRX) FILE=EGSRX
    STYLE=HTMLBlue
    STYLESHEET=(URL="file:///C:/Program%20Files/SASHome/SASEnterpriseGuide/7.1/Styles/HTMLBlue.css")
    NOGTITLE
    NOGFOOTNOTE
    GPATH=&sasworklocation
    ENCODING=UTF8
    options(rolap="on")
;

/*   START OF NODE: Preprocessing   */
%LET _CLIENTTASKLABEL='Preprocessing';
%LET _CLIENTPROCESSFLOWNAME='Process Flow';
%LET _CLIENTPROJECTPATH='G:\Corporate\share\Quality and Affordability Initiative\Data\Analytics Strategy\Sustainment Tools\CostPerUoS\CostPerUoS_IPNursing_v2.egp';
%LET _CLIENTPROJECTPATHHOST='LT163637';
%LET _CLIENTPROJECTNAME='CostPerUoS_IPNursing_v2.egp';
%LET _SASPROGRAMFILE='';
%LET _SASPROGRAMFILEHOST='';

GOPTIONS ACCESSIBLE;
OPTIONS VALIDVARNAME= V7;
LIBNAME output '/home/pxj479/Tasks/Output/RealizationTracker';
LIBNAME input '/home/pxj479/Tasks/Input';

PROC IMPORT OUT= WORK.PRC_COSTCENTERGROUPS DATAFILE= "/home/pxj479/Tasks/Input/PRC Cost Center Groups.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="Navigant"; 
     GETNAMES=YES;
RUN;

PROC IMPORT OUT= WORK.DublinMultiplier DATAFILE= "/home/pxj479/Tasks/Input/PRC Cost Center Groups.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="DublinMult"; 
     GETNAMES=YES;
RUN;

PROC IMPORT OUT= WORK.EVSAdjFactor DATAFILE= "/home/pxj479/Tasks/Input/PRC Cost Center Groups.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="EVSAdjFactor"; 
     GETNAMES=YES;
RUN;

PROC IMPORT OUT= WORK.EVSJobcodes DATAFILE= "/home/pxj479/Tasks/Input/PRC Cost Center Groups.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="EVSJobcodes"; 
     GETNAMES=YES;
RUN;

PROC IMPORT OUT= WORK.IPNursing_CoreFTE_Target DATAFILE= "/home/pxj479/Tasks/Input/IPNursing_CoreFTE_Target.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="Core"; 
     GETNAMES=YES;
RUN;

PROC IMPORT OUT= WORK.PatientDays_FinAccumChargeCodes DATAFILE= "/home/pxj479/Tasks/Input/PatientDays_FinanceAccumChargeCodes.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="ALL"; 
     GETNAMES=YES;
RUN;

/*** Importing Budget data ***/

PROC IMPORT OUT= WORK.FY19_Budget_Volume DATAFILE= "/home/pxj479/Tasks/Input/FY20_Budget_Volume.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="VolumeDrivers"; 
     GETNAMES=YES;
RUN;


%MACRO IMPR(IMP,OUT_DAT,EXL_SHT);
	PROC IMPORT OUT=&OUT_DAT DATAFILE="&IMP" DBMS=xlsx REPLACE; /*for oupput dataset for each SHEET */
	SHEET="&EXL_SHT";    /*for specifying sheets  */
	GETNAMES=YES;
	RUN;
%MEND IMPR;


%MACRO loop(sheet);
	%LET nwords=%SYSFUNC(countw(&sheet));
	%DO i=1 %TO &nwords;
		/** %PUT FY19_%SCAN(&sheet, &i); **/
		%IMPR(/home/pxj479/Tasks/Input/FY20_BudgetData.xlsx, FY19_BUDGET_%SCAN(&sheet, &i), %SCAN(&sheet, &i));
	%END;
%MEND loop;


%MACRO combine(sheet);
	%LET nwords=%SYSFUNC(countw(&sheet));
	DATA FY19_Budget;
	  SET
	  %DO i = 1 %TO &nwords;
	  	FY19_BUDGET_%SCAN(&sheet, &i)
	  %END;
	  ;
	RUN;
%MEND;

%LET sheetname=AMBUC OHPED OHWED HNHSP HRHOM HROBL MSHSP OBHSP HRINC DBHSP MNHSP GYHSP MMHSP RVHSP GTHSP DRHSP GCHSP ;

%loop(&sheetname);

%combine(&sheetname);


/*** End of Importing Budget data ***/

/*** Payperiod Roll up ***/

DATA PP_looksUp;
	FORMAT PPStartdate PPDate  MonthStartDate DATE9.;
	PPStartdate = '05JUL2014'd;
	FYStart = 2015;
	SteadyState = 0;
	DO FY = 2015 to 2025;
		DO PP = 1 to 26;
			IF FY = 2015 AND PP = 1 THEN DO; PPDate = PPStartdate; END;
			ELSE PPDate + 14;
			
			IF (PPDate >= '31DEC2016'd AND PPDate <= '25FEB2017'd) THEN SteadyState = 1;
			ELSE SteadyState = 0;
			
			IF FY IN (2016, 2018, 2020) THEN DO;
				IF PP IN (1 ,2 ) THEN DO; MONTH=7; FY_MONTH=1; END;
				ELSE IF PP IN (3, 4) THEN DO; MONTH=8; FY_MONTH=2; END;
				ELSE IF PP IN (5, 6, 7) THEN DO; MONTH=9; FY_MONTH=3; END;
				ELSE IF PP IN (8, 9) THEN DO; MONTH=10; FY_MONTH=4; END;
				ELSE IF PP IN (10, 11) THEN DO; MONTH=11; FY_MONTH=5; END;
				ELSE IF PP IN (12, 13) THEN DO; MONTH=12; FY_MONTH=6; END;
				ELSE IF PP IN (14, 15) THEN DO; MONTH=1; FY_MONTH=7; END; 
				ELSE IF PP IN (16, 17) THEN DO; MONTH=2; FY_MONTH=8; END; 
				ELSE IF PP IN (18, 19, 20) THEN DO; MONTH=3; FY_MONTH=9; END;
				ELSE IF PP IN (21, 22) THEN DO; MONTH=4; FY_MONTH=10; END;
				ELSE IF PP IN (23, 24) THEN DO; MONTH=5; FY_MONTH=11; END;
				ELSE IF PP IN (25, 26) THEN DO; MONTH=6; FY_MONTH=12; END;
				ELSE DO; MONTH = 0; END;
			END;
			ELSE DO;
				IF PP IN (1 ,2 ) THEN DO; MONTH=7; FY_MONTH=1; END;
				ELSE IF PP IN (3, 4, 5) THEN DO; MONTH=8; FY_MONTH=2; END;
				ELSE IF PP IN (6, 7) THEN DO; MONTH=9; FY_MONTH=3; END;
				ELSE IF PP IN (8, 9) THEN DO; MONTH=10; FY_MONTH=4; END;
				ELSE IF PP IN (10, 11) THEN DO; MONTH=11; FY_MONTH=5; END;
				ELSE IF PP IN (12, 13) THEN DO; MONTH=12; FY_MONTH=6; END;
				ELSE IF PP IN (14, 15) THEN DO; MONTH=1; FY_MONTH=7; END; 
				ELSE IF PP IN (16, 17) THEN DO; MONTH=2; FY_MONTH=8; END; 
				ELSE IF PP IN (18, 19, 20) THEN DO; MONTH=3; FY_MONTH=9; END;
				ELSE IF PP IN (21, 22) THEN DO; MONTH=4; FY_MONTH=10; END;
				ELSE IF PP IN (23, 24) THEN DO; MONTH=5; FY_MONTH=11; END;
				ELSE IF PP IN (25, 26) THEN DO; MONTH=6; FY_MONTH=12; END;
				ELSE DO; MONTH = 0; END;
			END;
			IF PP<=13 THEN Year = FY - 1;
			ELSE Year = FY;
			**Year = YEAR(PPDate);
			MonthStartDate = MDY(Month, 1, Year);
			OUTPUT;
		END;
	END;

RUN;

/*** End of Payperiod Roll up ***/

GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;
%LET _SASPROGRAMFILEHOST=;


/*   START OF NODE: Budget   */
%LET _CLIENTTASKLABEL='Budget';
%LET _CLIENTPROCESSFLOWNAME='Process Flow';
%LET _CLIENTPROJECTPATH='G:\Corporate\share\Quality and Affordability Initiative\Data\Analytics Strategy\Sustainment Tools\CostPerUoS\CostPerUoS_IPNursing_v2.egp';
%LET _CLIENTPROJECTPATHHOST='LT163637';
%LET _CLIENTPROJECTNAME='CostPerUoS_IPNursing_v2.egp';
%LET _SASPROGRAMFILE='';
%LET _SASPROGRAMFILEHOST='';

GOPTIONS ACCESSIBLE;
PROC TRANSPOSE DATA=WORK.FY19_Budget 
	OUT=WORK.FY19_Budget_Transp_v1 (KEEP=Year Facility Facility_Desc Cost_Center Cost_Center_Desc Line_Description Line_Description_Desc
									     FYMonth Column1 
 									RENAME=(Column1=Budget Cost_Center=CostCenter Cost_Center_Desc=CostCenter_Desc Line_Description=LineDescription
										    Line_Description_Desc=LineDescription_Desc))
	PREFIX=Column
	NAME=FYMonth;
	BY Year Facility Facility_Desc Cost_Center Cost_Center_Desc Line_Description Line_Description_Desc NOTSORTED;
	VAR July August September October November December January February March April May June;
RUN; QUIT;

PROC TRANSPOSE DATA=WORK.FY19_Budget_Volume
	OUT=WORK.FY19_Budget_Vol_Transp_v1 (KEEP=DataSet RelatedFacility RelatedFacility_Desc Facility CostCenter CostCenter_Desc SubAccount SubAccount_Desc
									         RelatedAccountType FYMonth Column1 RENAME=(Column1=BudgetVolume))
	PREFIX=Column
	NAME=FYMonth;
	BY DataSet RelatedFacility RelatedFacility_Desc Facility CostCenter CostCenter_Desc SubAccount SubAccount_Desc RelatedAccountType NOTSORTED;
	VAR July August September October November December January February March April May June;
RUN; QUIT;

PROC SQL;
	CREATE TABLE WORK.FY19_Budget_Transp_v2 AS
	SELECT DISTINCT * FROM WORK.FY19_Budget_Transp_v1
	ORDER BY Year, Facility, CostCenter, LineDescription, FYMonth;

	CREATE TABLE WORK.FY19_Budget_Vol_Transp_v2 AS
	SELECT DISTINCT * FROM WORK.FY19_Budget_Vol_Transp_v1
	ORDER BY DataSet, Facility, CostCenter, SubAccount_Desc, FYMonth;

	CREATE TABLE WORK.FY19_Budget_Transp_v3 AS
	SELECT SUBSTR(Year, 7) AS FY, SUBSTR(Facility_desc, 1, 5) AS Facility, CostCenter, FYMonth, SUM(Budget) as TotalLaborCost
	FROM WORK.FY19_Budget_Transp_v2
	WHERE UPCASE(LineDescription) IN ("SALARIES  WAGES", "SALARIES WAGES - STAFF", "EMPLOYEE BENEFITS")
	GROUP BY CALCULATED FY, CALCULATED Facility, CostCenter, FYMonth
	ORDER BY CALCULATED FY, CALCULATED Facility, CostCenter, FYMonth;

	/*** Coverting OBS and OPIB patient hours to days ***/
	CREATE TABLE WORK.FY19_Budget_Vol_Transp_v3 AS
	SELECT SUBSTR(Dataset, 7) AS FY, Facility, CostCenter, SubAccount_Desc, FYMonth, 
		   CASE 
		   	WHEN UPCASE(SubAccount_Desc) IN ("OBSERVATION HOURS", "OP IN A BED HOURS") THEN BudgetVolume/24
			ELSE BudgetVolume
		   END AS TotalVolume
	FROM WORK.FY19_Budget_Vol_Transp_v2
	ORDER BY CALCULATED FY, Facility, CostCenter, SubAccount_Desc, FYMonth;

	CREATE TABLE WORK.FY19_Budget_Vol_Transp_v4 AS
	SELECT FY, Facility, CostCenter, FYMonth, SUM(TotalVolume) AS TotalVolume
	FROM WORK.FY19_Budget_Vol_Transp_v3
	GROUP BY FY, Facility, CostCenter, FYMonth
	ORDER BY FY, Facility, CostCenter, FYMonth;

	CREATE TABLE WORK.FY19_Budget_ALl_v1 AS
	SELECT INPUT(t1.FY, 8.0) AS FY, t1.Facility, t1.CostCenter, t1.FYMonth, t1.TotalLaborCost, t2.TotalVolume, 
		   CASE 
		   	WHEN UPCASE(t1.FYMonth) = "JANUARY" THEN 1
			WHEN UPCASE(t1.FYMonth) = "FEBRUARY" THEN 2 
			WHEN UPCASE(t1.FYMonth) = "MARCH" THEN 3
			WHEN UPCASE(t1.FYMonth) = "APRIL" THEN 4
			WHEN UPCASE(t1.FYMonth) = "MAY" THEN 5
			WHEN UPCASE(t1.FYMonth) = "JUNE" THEN 6
			WHEN UPCASE(t1.FYMonth) = "JULY" THEN 7
			WHEN UPCASE(t1.FYMonth) = "AUGUST" THEN 8
			WHEN UPCASE(t1.FYMonth) = "SEPTEMBER" THEN 9
			WHEN UPCASE(t1.FYMonth) = "OCTOBER" THEN 10
			WHEN UPCASE(t1.FYMonth) = "NOVEMBER" THEN 11
			WHEN UPCASE(t1.FYMonth) = "DECEMBER" THEN 12
		  END AS Month
	FROM WORK.FY19_Budget_Transp_v3 t1
	LEFT JOIN WORK.FY19_Budget_Vol_Transp_v4 t2 ON (t1.FY=t2.FY AND t1.Facility=t2.Facility AND t1.CostCenter=t2.CostCenter AND t1.FYMonth=t2.FYMonth)
	ORDER BY t1.FY, t1.Facility, t1.CostCenter, t1.FYMonth;

	CREATE TABLE WORK.FY19_Budget_ALL_v2 AS
	SELECT t1.*, t2.FunctionalGroupings, t2.SurgeryAdminCostCenter AS AdminCostCenter
	FROM WORK.FY19_Budget_ALl_v1 t1
	INNER JOIN WORK.PRC_COSTCENTERGROUPS t2 ON (t1.Facility=t2.Facility AND t1.CostCenter = t2.CostCenter)
	ORDER BY t1.FY, t1.Facility, t1.CostCenter, t1.FYMonth;

	CREATE TABLE WORK.FY19_Budget_ALL_v3 AS
	SELECT t1.*, t2.TotalVolume AS AdminVolume,
		   CASE 
		   	WHEN t1.AdminCostCenter IS NOT NULL THEN t2.TotalVolume
			ELSE t1.TotalVolume
		   END AS Volume, 
		   t1.TotalLaborCost/CALCULATED Volume AS FY19_BudgetCostPerUoS FORMAT 8.2
	FROM WORK.FY19_Budget_ALl_v2 t1 
	LEFT JOIN WORK.FY19_Budget_Vol_Transp_v4 t2 ON (t1.FY=INPUT(t2.FY, 8.) AND t1.Facility=t2.Facility AND t1.AdminCostCenter=t2.CostCenter AND t1.FYMonth=t2.FYMonth)
	ORDER BY t1.FY, t1.Facility, t1.CostCenter, t1.FYMonth;

QUIT;



GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;
%LET _SASPROGRAMFILEHOST=;


/*   START OF NODE: LaborCost   */
%LET _CLIENTTASKLABEL='LaborCost';
%LET _CLIENTPROCESSFLOWNAME='Process Flow';
%LET _CLIENTPROJECTPATH='G:\Corporate\share\Quality and Affordability Initiative\Data\Analytics Strategy\Sustainment Tools\CostPerUoS\CostPerUoS_IPNursing_v2.egp';
%LET _CLIENTPROJECTPATHHOST='LT163637';
%LET _CLIENTPROJECTNAME='CostPerUoS_IPNursing_v2.egp';
%LET _SASPROGRAMFILE='';
%LET _SASPROGRAMFILEHOST='';

GOPTIONS ACCESSIBLE;
/*** Connect to Q&A SQL 
LIBNAME QASQL_1 odbc noprompt="dsn=QandA_SQL;" schema=dbo;
LIBNAME QASQL_2 odbc noprompt="dsn=QandA_SQL;" schema=oh; ***/

LIBNAME QASQL_1 ODBC DSN='EPSI02' schema = dbo; 
LIBNAME QASQL_2 ODBC DSN='EPSI02' schema = oh; 


PROC SQL;
/*** Agency Data ***/
   CREATE TABLE WORK.RMH_3178_AGENCY_V1 AS 
   SELECT DISTINCT t1.PPKey AS PP, 
          DATEPART(t1.PPEndDate) AS PPDate FORMAT DATE9., 
          t1.OpUnit AS Facility, 
          INPUT(t1.Dept, 8.)  AS CostCenter, 
          /** t1.MeasureType, **/
          t1.JobCode, 
          t1.Source, t1.EarningCode AS PayCode,
          t1.Tothours, t1.Totdollars
      FROM QASQL_1.QAI_Payroll t1
      WHERE UPCASE(t1.Source) = "CONTRACT" AND t1.BenefitsCodes EQ "" /* there is no benefit code field */
      ORDER BY  t1.PPEndDate, t1.OpUnit,
               t1.Dept
              ;
   CREATE TABLE WORK.RMH_3178_AGENCY_V2 AS 
   SELECT t1.Facility as BusinessUnit ,/* TO_CHAR_PYCHK_PAY_END_DT__MM_DD_ */
          (t1.PPDate) FORMAT=DATE9. LABEL="TO_CHAR_PYCHK_PAY_END_DT__MM_DD_" , 
		  t3.FY, t3.MonthStartDate,t3.Month,
		  t2.FunctionalGroupings, t2.CostCenterDescription,
          t1.CostCenter LABEL="DeptID" AS DeptID, 
          /* ERNCD */
            UPCASE(t1.Source) LABEL="ERNCD" AS ERNCD, 
          /* Sum_of_OTH_Hrs */
            (SUM(t1.Tothours)) LABEL="Sum_of_OTH_Hrs" AS WorkedHours, 
          /* SUM_of_OTH_Earns */
            (SUM(t1.Totdollars)) FORMAT=BEST12. AS Earnings
   FROM WORK.RMH_3178_AGENCY_V1 t1
   INNER JOIN WORK.PRC_COSTCENTERGROUPS t2 ON (t1.Facility = t2.Facility AND t1.CostCenter = t2.CostCenter)
   INNER JOIN WORK.PP_LOOKSUP t3 ON (t1.PPDate = t3.PPDate)
   GROUP BY t1.Facility, t1.PPDate, t3.FY, t3.MonthStartDate, t3.Month, t2.FunctionalGroupings, t2.CostCenterDescription,
               t1.CostCenter, t1.Source, t3.FY, t3.MonthStartDate,t3.Month
   ORDER BY t1.PPDate, t1.Facility, DeptID;

QUIT;
   /*** End Of Agency Data ***/

PROC SQL;
   /*** Payroll Data ***/
   CREATE TABLE WORK.RMH_3178_PR_v1 AS 
   SELECT DATEPART(t1.PPEndDate) LABEL="TO_CHAR_PYCHK_PAY_END_DT__MM_DD_" AS TO_CHAR_PYCHK_PAY_END_DT__MM_DD_ FORMAT DATE9., 
          t1.OPUnit AS BUSINESSUNIT, 
          INPUT(t1.Dept, 8.) as DeptID,
          INPUT(t1.JobCode, 8.) as JobCode,
          /* ERNCD */
          (compress(t1.EarningCode,"'")) as ERNCD, 
          t1.Tothours AS OTHHRS, 
          t1.Totdollars AS OTHEARNS, 
          t1.Source AS ERNCD_SPCL
   FROM QASQL_1.QAI_Payroll t1
   WHERE UPCASE(t1.Source) NE "CONTRACT" AND t1.BenefitsCodes EQ ""
   ORDER BY t1.PPEndDate,
               t1.OPUnit,
               INPUT(t1.Dept, 8.);

   CREATE TABLE WORK.RMH_3178_PR_v1_2 AS 
   SELECT   t1.BUSINESSUNIT, t1.TO_CHAR_PYCHK_PAY_END_DT__MM_DD_ FORMAT DATE9. AS PPDate, t1.DEPTID, t1.JobCode, UPCASE(t1.ERNCD) as ERNCD,
		    t2.FunctionalGroupings, t2.CostcenterDescription, 
			CASE 
				WHEN t3.FY = 2016 THEN t2.Benefits_2016
				WHEN t3.FY = 2017 THEN t2.Benefits_2017
				WHEN t3.FY = 2018 THEN t2.Benefits_2018
				WHEN t3.FY = 2019 THEN t2.Benefits_2019
				WHEN t3.FY = 2020 THEN t2.Benefits_2019
			END AS Benefits, 
			t3.FY, t3.MonthStartDate,t3.Month,
		    CASE 
		    /*** Imaging - For MMHSP 35030. This excludes job codes 6211 and 7336 ***/
			WHEN  t1.BUSINESSUNIT = 'MMHSP' AND t1.DeptID = 35030  AND t1.JobCode IN (6211, 7336) THEN (SUM(t1.OTHHRS)) * 0 
			ELSE (SUM(t1.OTHHRS)) 
			END AS SUM_of_OTH_HRS FORMAT=BEST8. , 

			CASE 
		    /*** Adjustement for Marion 82320: there is an employee there, Michael Beck, who split time with Morrow for the first 9 months of FY18. I manually transferred 60% of his time out of Marion 82320. ***/
			WHEN  t1.BUSINESSUNIT = 'MNHSP' AND t1.DeptID = 82320 AND t3.FY = 2018 AND t1.JobCode = 2762 THEN (SUM(t1.OTHEARNS)) * 0.4 
			/*** Imaging - For MMHSP 35030. This excludes job codes 6211 and 7336 ***/
			WHEN  t1.BUSINESSUNIT = 'MMHSP' AND t1.DeptID = 35030  AND t1.JobCode IN (6211, 7336) THEN (SUM(t1.OTHEARNS)) * 0 
			ELSE (SUM(t1.OTHEARNS))
			END AS SUM_of_OTH_EARNS_pre_BenAdj FORMAT=BEST9.,

			CASE 
			WHEN  t1.BUSINESSUNIT = 'MNHSP' AND t1.DeptID = 82320 AND t3.FY = 2018 AND t1.JobCode = 2762 THEN (SUM(t1.OTHEARNS))*(1+ CALCULATED Benefits)*0.4
			/*** Imaging - For MMHSP 35030. This excludes job codes 6211 and 7336 ***/
			WHEN  t1.BUSINESSUNIT = 'MMHSP' AND t1.DeptID = 35030  AND t1.JobCode IN (6211, 7336) THEN (SUM(t1.OTHEARNS))*(1+ CALCULATED Benefits)*0
			ELSE (SUM(t1.OTHEARNS))*(1+ CALCULATED Benefits)
			END AS SUM_of_OTH_EARNS FORMAT=BEST9. 
    FROM WORK.RMH_3178_PR_v1 t1
    INNER JOIN WORK.PRC_COSTCENTERGROUPS t2 ON (t1.BUSINESSUNIT = t2.Facility AND t1.DEPTID = t2.CostCenter)
	INNER JOIN WORK.PP_LOOKSUP t3 ON (t1.TO_CHAR_PYCHK_PAY_END_DT__MM_DD_ = t3.PPDate)
    GROUP BY  t1.BUSINESSUNIT, t1.TO_CHAR_PYCHK_PAY_END_DT__MM_DD_, t1.DEPTID, t1.JobCode, t1.ERNCD
			  , t2.FunctionalGroupings, t2.CostcenterDescription  , CALCULATED Benefits,  t3.FY, t3.MonthStartDate,t3.Month
    ORDER BY  t1.TO_CHAR_PYCHK_PAY_END_DT__MM_DD_, t1.BUSINESSUNIT, t2.FunctionalGroupings, t1.DEPTID, t1.JobCode, t1.ERNCD;

   CREATE TABLE WORK.RMH_3178_PR_v2 AS 
   SELECT t1.BUSINESSUNIT, t1.PPDate, t1.DEPTID, PUT(t1.JobCode, 20.) AS Jobcode, t1.ERNCD,
		  t1.FunctionalGroupings, t1.CostcenterDescription, t1.Benefits,
		  t1.FY, t1.MonthStartDate,t1.Month,
          /* SUM_of_OTH_HRS */
            (SUM(t1.SUM_of_OTH_HRS)) FORMAT=BEST8. AS SUM_of_OTH_HRS, 
          /* SUM_of_OTH_EARNS */
            (SUM(t1.SUM_of_OTH_EARNS_pre_BenAdj)) FORMAT=BEST9. AS SUM_of_OTH_EARNS_pre_BenAdj,
			(SUM(t1.SUM_of_OTH_EARNS)) FORMAT=BEST9. AS SUM_of_OTH_EARNS
    FROM WORK.RMH_3178_PR_v1_2 t1
   /** INNER JOIN WORK.PRC_COSTCENTERGROUPS t2 ON (t1.BUSINESSUNIT = t2.Facility AND t1.DEPTID = t2.CostCenter)
	INNER JOIN WORK.PP_LOOKSUP t3 ON (t1.TO_CHAR_PYCHK_PAY_END_DT__MM_DD_ = t3.PPDate)**/
    GROUP BY  t1.BUSINESSUNIT, t1.PPDate, t1.DEPTID, CALCULATED JobCode, t1.ERNCD,
			  t1.FunctionalGroupings, t1.CostcenterDescription, t1.Benefits, 
			  t1.FY, t1.MonthStartDate,t1.Month
    ORDER BY  t1.PPDate, t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DEPTID, CALCULATED JobCode, t1.ERNCD;

   CREATE TABLE WORK.RMH_3178_AGENCY_BenAdj AS 
   SELECT t1.Facility as BusinessUnit ,t1.PPDate FORMAT=DATE9. , t1.CostCenter LABEL="DeptID" AS DeptID,  
		  SUBSTR(t1.JobCode, INDEX(UPCASE(t1.JobCode), "T")+1) AS JobCode, UPCASE(t1.Source) LABEL="ERNCD" AS ERNCD,
   		  t2.FunctionalGroupings, t2.CostCenterDescription, 1 AS Benefits,
		  t3.FY, t3.MonthStartDate,t3.Month,
          /* Sum_of_OTH_Hrs */
            (SUM(t1.Tothours)) LABEL="Sum_of_OTH_Hrs" AS SUM_of_OTH_HRS, 
          /* SUM_of_OTH_Earns */
            (SUM(t1.Totdollars)) FORMAT=BEST12. AS SUM_of_OTH_EARNS_pre_BenAdj, 
			(SUM(t1.Totdollars)) FORMAT=BEST12. AS SUM_of_OTH_EARNS 
   FROM WORK.RMH_3178_AGENCY_V1 t1
   INNER JOIN WORK.PRC_COSTCENTERGROUPS t2 ON (t1.Facility = t2.Facility AND t1.CostCenter = t2.CostCenter)
   INNER JOIN WORK.PP_LOOKSUP t3 ON (t1.PPDate = t3.PPDate)
   GROUP BY t1.Facility, t1.PPDate, t1.CostCenter, CALCULATED JobCode, t1.Source, t2.FunctionalGroupings, t2.CostCenterDescription, Benefits,
			t3.FY, t3.MonthStartDate, t3.Month
   ORDER BY t1.PPDate, t1.Facility, t2.FunctionalGroupings, t1.CostCenter, CALCULATED JobCode, t1.Source;
QUIT;

/*** Premium Wage Data ***/
PROC SQL;
   CREATE TABLE WORK.RMH_3178_Prem_v1 AS 
   SELECT DATEPART(t1.PPEndDate) LABEL="TO_CHAR_PYCHK_PAY_END_DT__MM_DD_" AS PPDate FORMAT DATE9., 
          t1.OPUnit AS BUSINESSUNIT, 
          INPUT(t1.Dept, 8.) as DeptID,
          t1.JobCode,
          /* ERNCD */
          (compress(t1.EarningCode,"'")) as ERNCD, 
          t1.Tothours AS OTHHRS, 
          t1.Totdollars AS OTHEARNS, 
          t1.Source AS ERNCD_SPCL
   FROM QASQL_1.QAI_Payroll t1
   WHERE t1.BenefitsCodes EQ "" AND 
		 UPCASE(compress(t1.EarningCode,"'")) in ('OC', 'PR', 'CRN','OT','LP', 'OHP','CI', 'FP', 'RI','CIH', 
							                      'QU9','TP9','TD9','PC9','OTN', 'CX', 'BND','SHT')
   ORDER BY t1.PPEndDate,t1.OPUnit,INPUT(t1.Dept, 8.);
PROC SQL;
  CREATE TABLE WORK.RMH_3178_Prem_v2 AS 
  SELECT t1.PPDate, t1.BUSINESSUNIT, t1.DeptID, t1.JobCode, UPCASE(t1.ERNCD) as ERNCD, 
	     SUM(t1.OTHHRS) FORMAT=BEST8. AS WorkedHours, SUM(t1.OTHEARNS) FORMAT=BEST9. AS Earnings, 
		 t2.FunctionalGroupings, t2.CostcenterDescription,
		 t3.FY, t3.MonthStartDate, t3.Month
  FROM WORK.RMH_3178_Prem_v1 t1
  INNER JOIN WORK.PRC_COSTCENTERGROUPS t2 ON (t1.BUSINESSUNIT = t2.Facility AND t1.DEPTID = t2.CostCenter)
  INNER JOIN WORK.PP_LOOKSUP t3 ON (t1.PPDate = t3.PPDate)
  WHERE t3.FY >= 2016
  GROUP BY  t1.PPDate, t1.BUSINESSUNIT, t1.DEPTID, t1.JobCode, t1.ERNCD
			,t2.FunctionalGroupings, t2.CostcenterDescription  , t3.FY, t3.MonthStartDate, t3.Month
  ORDER BY  t1.PPDate, t1.BUSINESSUNIT, t2.FunctionalGroupings, t1.DEPTID, t1.JobCode, t1.ERNCD;

  	CREATE TABLE WORK.RMH_3178_Prem_v3   AS
	SELECT t1.BUSINESSUNIT, t1.FunctionalGroupings,
          t1.DEPTID, t1.ERNCD, t1.Jobcode, t1.CostcenterDescription, t1.FY, t1.MonthStartDate, t1.Month, 
            (SUM(t1.WorkedHours)) FORMAT=BEST8. AS WorkedHours, 
            (SUM(t1.Earnings)) FORMAT=BEST9. AS Earnings 
	FROM WORK.RMH_3178_Prem_v2 t1
	WHERE t1.FY >= 2016
	GROUP BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DEPTID, t1.ERNCD, t1.Jobcode, t1.CostcenterDescription, t1.FY, 
		     t1.MonthStartDate, t1.Month
	ORDER BY  t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DEPTID, t1.MonthStartDate, t1.ERNCD, t1.Jobcode ;

   CREATE TABLE WORK.RMH_3178_AGENCY_V2_Prem AS 
   SELECT t1.Facility as BusinessUnit ,/* TO_CHAR_PYCHK_PAY_END_DT__MM_DD_ */
          (t1.PPDate) FORMAT=DATE9. LABEL="TO_CHAR_PYCHK_PAY_END_DT__MM_DD_" , 
		  t3.FY, t3.MonthStartDate,t3.Month,
		  t2.FunctionalGroupings, t2.CostCenterDescription,
          t1.CostCenter LABEL="DeptID" AS DeptID, 
          /* ERNCD */
            UPCASE(t1.Source) LABEL="ERNCD" AS ERNCD, t1.JobCode,
          /* Sum_of_OTH_Hrs */
            (SUM(t1.Tothours)) LABEL="Sum_of_OTH_Hrs" AS WorkedHours, 
          /* SUM_of_OTH_Earns */
            (SUM(t1.Totdollars)) FORMAT=BEST12. AS Earnings
   FROM WORK.RMH_3178_AGENCY_V1 t1
   INNER JOIN WORK.PRC_COSTCENTERGROUPS t2 ON (t1.Facility = t2.Facility AND t1.CostCenter = t2.CostCenter)
   INNER JOIN WORK.PP_LOOKSUP t3 ON (t1.PPDate = t3.PPDate)
   GROUP BY t1.Facility, t1.PPDate, t3.FY, t3.MonthStartDate, t3.Month, t2.FunctionalGroupings, t2.CostCenterDescription,
               t1.CostCenter, t1.Source, t1.JobCode, t3.FY, t3.MonthStartDate, t3.Month
   ORDER BY t1.PPDate, t1.Facility, DeptID;

   CREATE TABLE WORK.RMH_3178_AGENCY_V3_Prem AS 
   SELECT t1.BusinessUnit, 
          t1.FY, t1.MonthStartDate FORMAT mmddyy10., t1.Month,
          t1.FunctionalGroupings, t1.CostCenterDescription,
          t1.DeptID, 
          t1.ERNCD, t1.JobCode,
          SUM(t1.WorkedHours) as WorkedHours, 
          SUM(t1.Earnings) as Earnings
      FROM WORK.RMH_3178_AGENCY_V2_Prem t1
	  WHERE t1.FY >= 2016
	  GROUP BY t1.BusinessUnit, 
          t1.FY, t1.MonthStartDate, t1.Month,
          t1.FunctionalGroupings, t1.CostCenterDescription,
          t1.DeptID, 
          t1.ERNCD, t1.JobCode
      ORDER BY t1.BusinessUnit,
               t1.DeptID,
               t1.MonthStartDate;

	CREATE TABLE WORK.OH_Premium_v1 AS 
	SELECT * FROM WORK.RMH_3178_AGENCY_V3_Prem
	 OUTER UNION CORR 
	SELECT * FROM WORK.RMH_3178_Prem_v3;

	CREATE TABLE WORK.OH_Premium_v1 AS 
	SELECT t1.BusinessUnit, 
          t1.FY, t1.MonthStartDate FORMAT mmddyy10., t1.Month,
          t1.FunctionalGroupings, t1.CostCenterDescription,
          t1.DeptID, t1.ERNCD, t1.JobCode,
          SUM(t1.WorkedHours) as WorkedHours, 
          SUM(t1.Earnings) as Earnings
	FROM WORK.OH_Premium_v1 t1
	GROUP BY t1.BusinessUnit, 
          t1.FY, t1.MonthStartDate, t1.Month,
          t1.FunctionalGroupings, t1.CostCenterDescription,
          t1.DeptID, t1.ERNCD, t1.JobCode
	ORDER BY t1.BusinessUnit, 
          t1.FY, t1.MonthStartDate, t1.Month,
          t1.FunctionalGroupings, t1.CostCenterDescription,
          t1.DeptID, t1.ERNCD, t1.JobCode;

QUIT;
 /*** End Of Premium Wage Data ***/

PROC SQL;

   /*** Merge Payroll and AGency Data ***/
	CREATE TABLE WORK.RMH_Cost_3178_V1 AS 
	SELECT * FROM WORK.RMH_3178_AGENCY_BenAdj
	OUTER UNION CORR
	SELECT * FROM WORK.RMH_3178_PR_v2;
 
   /*** 1.	GYHSP 35020 – This is the combination of 35020, 35030, 35070, 35090, and 35170
        2.	GTHSP 35020 – this is the combination of 35020 and 35010
   ***/
	CREATE TABLE WORK.RMH_COST_3178_V1_1 AS 
    SELECT t1.BusinessUnit, 
          t1.PPDate,
		  CASE 
		  WHEN t1.BusinessUnit = "GTHSP" AND t1.DeptID = 35010 THEN 35020
		  WHEN t1.BusinessUnit = "GYHSP" AND t1.DeptID IN (35030, 35070, 35090, 35170) THEN 35020
		  ELSE t1.DeptID
		  END AS DeptID, t1.Jobcode,
          t1.ERNCD, 
          t1.FunctionalGroupings, 
          t1.CostCenterDescription, 
          t1.Benefits, 
          t1.FY, 
          t1.MonthStartDate, 
          t1.MONTH, 
          t1.SUM_of_OTH_HRS, 
          t1.SUM_of_OTH_EARNS_pre_BenAdj, 
          t1.SUM_of_OTH_EARNS
    FROM WORK.RMH_COST_3178_V1 t1;

	/** End of GTHSP and GYHSP **/
QUIT;

/** For EVS include only few specific job codes are counted towards labor cost **/

DATA WORK.RMH_COST_3178_V1_2;
	SET WORK.RMH_COST_3178_V1_1;
	IF (UPCASE(FunctionalGroupings) EQ "EVS" AND DeptID EQ 75020 
	   AND STRIP(JOBCODE) NOT IN (  '201E',
									'2130',
									'4154',
									'5056',
									'6008',
									'0311',
									'6017',
									'6020',
									'6024',
									'6039',
									'6083',
									'6185',
									'6094',
									'6100',
									'6116',
									'6012',
									'6124',
									'6177',
									'6710',
									'7027',
									'7026',
									'7032',
									'7100',
									'7135',
									'8537',
									'U028',
									'M107',
									'U021'
  									)
    ) THEN DELETE ;
RUN;

/** End of EVS include only few specific job codes are counted towards labor cost **/

PROC SQL;
   CREATE TABLE WORK.RMH_Cost_3178_V2 AS 
   SELECT  t1.BUSINESSUNIT, t1.PPDate, 
		   t1.FunctionalGroupings, 
          /** t1.ForecastModelGroupings, **/
           t1.DEPTID , 
          /**  t1.ERNCD, **/ 
          /* SUM_of_SUM_of_OTH_EARNS */
            (SUM(t1.SUM_of_OTH_EARNS)) FORMAT=BEST12. AS SUM_of_SUM_of_OTH_EARNS, 
			(SUM(t1.SUM_of_OTH_HRS)) FORMAT=BEST12. AS SUM_of_SUM_of_OTH_HRS
   FROM WORK.RMH_COST_3178_V1_2 t1
   GROUP BY  t1.BUSINESSUNIT, t1.PPDate, t1.FunctionalGroupings,
               /** t1.ForecastModelGroupings, **/
               t1.DEPTID /**,
               t1.ERNCD **/
   ORDER BY  t1.BUSINESSUNIT, t1.PPDate, t1.FunctionalGroupings,
               t1.DEPTID /**,
               t1.ERNCD **/;

QUIT;
/* PWJ Added Earning Description 
PROC IMPORT OUT= WORK.OH_EarningCodes DATAFILE= "/home/pxj479/Tasks/Input/OH_EarningCodes.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="Paycodes"; 
     GETNAMES=YES;
RUN;

PROC SQL;
CREATE TABLE WORK.OH_Premium_v1  AS
	SELECT t1.*, t2.Desc AS ERNCD_Desc    
	FROM WORK.OH_Premium_v1 t1
    INNER JOIN WORK.OH_EarningCodes t2 ON (t1.ERNCD = t2.EarningCode);
QUIT; 	
 End of PWJ code */
 

/**** Periop RN to Tech Ratio ***/
PROC SQL;
   CREATE TABLE WORK.OH_Periop_RNTech_V1 AS 
   SELECT DISTINCT t1.OpUnit AS BusinessUnit, t2.FunctionalGroupings, 
          INPUT(t1.Dept, 8.)  AS DeptID, t2.CostCenterDescription,
          t1.JobCode, 
		  CASE 
		  WHEN STRIP(t1.JobCode) IN ("3178", "U021", "3764") THEN "RN"
		  WHEN STRIP(t1.JobCode) IN ("4186", "U049", "U062", "4019", '4044') THEN "TECH" /*I added 4044 on 10/16/2020 */
		  END AS JobCodeDescription, t4.FY, t4.Month, t4.FY_Month,
		  SUM(t1.Tothours) AS FTEHours, SUM(t1.Totdollars) AS FTEDollars
  FROM QASQL_1.QAI_Payroll t1
  INNER JOIN WORK.PRC_COSTCENTERGROUPS t2 ON (t1.OpUnit = t2.Facility AND INPUT(t1.Dept, 8.) = t2.CostCenter) 
  INNER JOIN WORK.PP_LOOKSUP t4 ON (DATEPART(t1.PPEndDate) = t4.PPDate)	 
  WHERE  DATEPART(t1.PPEndDate) >= '01JUL2016'D AND STRIP(t1.JobCode) IN ("U021", "3764", "3178", "4186", "U049", "U062", "4019", '4044') 
  GROUP BY t1.OpUnit, t2.FunctionalGroupings, INPUT(t1.Dept, 8.), t2.CostCenterDescription, t1.JobCode, CALCULATED JobCodeDescription, t4.FY, t4.Month, t4.FY_Month
  ORDER BY t1.OpUnit, t2.FunctionalGroupings, INPUT(t1.Dept, 8.), t2.CostCenterDescription, t1.JobCode, CALCULATED JobCodeDescription, t4.FY, t4.Month, t4.FY_Month;
  CREATE TABLE WORK.OH_Periop_RNTech_V2 AS 
  SELECT t1.BusinessUnit, t1.FunctionalGroupings, t1.DeptID, t1.CostCenterDescription,
          t1.JobCodeDescription, t1.FY, t1.Month, t1.FY_Month,
		  SUM(t1.FTEHours) AS FTEHours, SUM(t1.FTEDollars) AS FTEDollars
  FROM WORK.OH_Periop_RNTech_V1 t1
  WHERE UPCASE(t1.FunctionalGroupings) = "PERIOP"
  GROUP BY t1.BusinessUnit, t1.FunctionalGroupings, t1.DeptID, t1.CostCenterDescription, t1.JobCodeDescription, t1.FY, t1.Month, t1.FY_Month
  ORDER BY t1.BusinessUnit, t1.FunctionalGroupings, t1.DeptID, t1.CostCenterDescription, t1.JobCodeDescription, t1.FY, t1.Month, t1.FY_Month;

QUIT;

PROC SORT
	DATA=WORK.OH_PERIOP_RNTECH_V2 (KEEP=FTEHours JobCodeDescription BusinessUnit FunctionalGroupings DeptID CostCenterDescription FY MONTH FY_MONTH)
	OUT=WORK.TMP0TempTableInput
	;
	BY BusinessUnit FunctionalGroupings DeptID CostCenterDescription FY MONTH FY_MONTH;
RUN;
PROC TRANSPOSE DATA=WORK.TMP0TempTableInput
	OUT=WORK.OH_PERIOP_RNTECH_V3 (LABEL="Split WORK.OH_PERIOP_RNTECH_V2")
;
	BY BusinessUnit FunctionalGroupings DeptID CostCenterDescription FY MONTH FY_MONTH;

	ID JobCodeDescription;
	VAR FTEHours;
RUN; QUIT;

DATA WORK.OH_PERIOP_RNTECH_V4;
	SET WORK.OH_PERIOP_RNTECH_V3;
	FORMAT Year 8. MonthStartDate DATE9. TotalHours 8.2  Target_RN_Ratio RN_TECH_RATIO PERCENT10.;

	TotalHours =  RN + TECH;
	RN_TECH_RATIO = RN/ TotalHours;
	IF CATX("", BusinessUnit, DeptID) IN ("DBHSP 25140", "DRHSP 25140", "GCHSP 25140", "GYHSP 25140", "GTHSP 25140",  /* PWJ added "GCHSP 25140" on 10/26/2020 */
										  "GTHSP 25060", "HNHSP 25140", "MMHSP 25140", "MNHSP 25140", "MNHSP 25142", 
										  "OBHSP 25140", "MSHSP 25140") THEN Target_RN_Ratio = 0.6;
	ELSE Target_RN_Ratio = 0.7;

	IF Month IN (7, 8, 9, 10, 11, 12) THEN Year = FY - 1;
	ELSE Year = FY;

	MonthStartDate = MDY(Month, 1, Year);
RUN;


PROC SORT DATA= WORK.OH_PERIOP_RNTECH_V4 OUT=WORK.OH_PERIOP_RNTECH_V4;
	BY BusinessUnit FunctionalGroupings DeptID FY FY_MONTH;
	WHERE (MonthStartDate < MDY( MONTH(TODAY()), 1, YEAR(TODAY()) ) & RN >0 & TECH>0);
QUIT;
/**** End of Periop RN to Tech Ratio ***/


GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;
%LET _SASPROGRAMFILEHOST=;


/*   START OF NODE: UoS   */
%LET _CLIENTTASKLABEL='UoS';
%LET _CLIENTPROCESSFLOWNAME='Process Flow';
%LET _CLIENTPROJECTPATH='G:\Corporate\share\Quality and Affordability Initiative\Data\Analytics Strategy\Sustainment Tools\CostPerUoS\CostPerUoS_IPNursing_v2.egp';
%LET _CLIENTPROJECTPATHHOST='LT163637';
%LET _CLIENTPROJECTNAME='CostPerUoS_IPNursing_v2.egp';
%LET _SASPROGRAMFILE='';
%LET _SASPROGRAMFILEHOST='';

GOPTIONS ACCESSIBLE;
PROC SQL;
   CREATE TABLE WORK.RVH_FY_17_STATS_v3 AS 
   SELECT t1.OPUnit, 
          INPUT(t1.FY, 8.) as FY, 
          INPUT(t1.Dept, 8.) as Dept,
          t1.PP, 
          /* STATS */
          SUM(t1.STATS) FORMAT=BESTX5. LABEL="STATS" AS STATS
      FROM QASQL_1.UoSStats t1
	  WHERE t1.Accum = "A" AND /** t1.OPUnit = 'RVHSP' AND ***/ INPUT(t1.Dept, 8.) NOT IN (16090)
      GROUP BY t1.OPUnit,
               t1.FY,
               t1.Dept,
               t1.PP
      ORDER BY t1.OPUnit,
               t1.FY,
               t1.Dept,
               t1.PP;

/*** OBHSP 25000 Stats manipulation and DBHSP 25080 and 25140 stats manipulation ***/
	CREATE TABLE WORK.OBHSP_25000_STATS_v1 AS 
    SELECT t1.OPUnit, 
          INPUT(t1.FY, 8.) as FY, 
          INPUT(t1.Dept, 8.) as Dept,
          t1.PP, 
          /* STATS */
          SUM(t1.STATS) FORMAT=BESTX5. LABEL="STATS" AS STATS
    FROM QASQL_1.UoSStats t1
    WHERE t1.OPUnit = 'OBHSP' AND INPUT(t1.Dept, 8.) IN (25000) AND t1.Accum = "A" AND ChargeCode NE "6208004"
    GROUP BY t1.OPUnit,
               t1.FY,
               t1.Dept,
               t1.PP
    ORDER BY t1.OPUnit,
               t1.FY,
               t1.Dept,
               t1.PP;

 	CREATE TABLE WORK.DBHSP_25080_140_STATS_v1 AS 
    SELECT t1.*, t2.Old_Mult, t2.New_Mult, (t1.Stats/t2.Old_Mult)*t2.New_Mult AS New_Stats 
    FROM QASQL_1.UoSStats t1
	LEFT JOIN WORK.DUBLINMULTIPLIER t2 ON (t1.OPUnit = t2.OPUnit AND INPUT(t1.Dept, 8.) = INPUT(t2.Dept, 8.) AND t1.Chargecode = t2.ChgCode AND t1.PatientType = t2.PT)
    WHERE t1.OPUnit = 'DBHSP' AND INPUT(t1.Dept, 8.) IN (25080, 25140) AND t1.Accum = "A" AND INPUT(t1.FY, 8.) <= 2018 
    ORDER BY t1.OPUnit,
               t1.FY,
               t1.Dept,
               t1.PP;

    CREATE TABLE WORK.DBHSP_25080_140_STATS_v2 AS 
    SELECT t1.OPUnit, 
          INPUT(t1.FY, 8.) as FY, 
          INPUT(t1.Dept, 8.) as Dept, t1.PP,
          /** t1.PP, SUM(t1.STATS) FORMAT=BESTX5. LABEL="STATS" AS Old_STATS, **/
          /* STATS */
          SUM(t1.New_Stats) FORMAT=BESTX5. LABEL="STATS" AS STATS
      FROM WORK.DBHSP_25080_140_STATS_v1 t1
      GROUP BY t1.OPUnit, t1.FY, t1.Dept, t1.PP
      ORDER BY t1.OPUnit, t1.FY, t1.Dept, t1.PP;
	
QUIT;


DATA WORK.RVH_FY_17_STATS_v3;
	SET WORK.RVH_FY_17_STATS_v3;
	IF OPUnit = 'OBHSP' AND Dept IN (25000) THEN DELETE;
	IF OPUnit = 'DBHSP' AND Dept IN (25080, 25140 ) AND FY <=  2018 THEN DELETE;
RUN;

/*** End of OBHSP 25000 Stats manipulation and DBHSP 25080 and 25140 stats manipulation***/

 PROC SQL;
 	CREATE TABLE WORK.RVH_FY_17_STATS_v3 AS 
	SELECT * FROM WORK.RVH_FY_17_STATS_v3
	 OUTER UNION CORR 
	SELECT * FROM WORK.OBHSP_25000_STATS_v1
	OUTER UNION CORR 
	SELECT * FROM WORK.DBHSP_25080_140_STATS_v2
	ORDER BY OPUnit, FY, Dept, PP;
 QUIT;



PROC SQL;
   CREATE TABLE WORK.RVH_LDNOOPIB_FY_16_17_STATS_v1 AS 
   SELECT t1.OPUnit, 
          INPUT(t1.FY, 8.) as FY, 
          INPUT(t1.Dept, 8.) as Dept,
          t1.PP, 
          /* STATS */
          SUM(t1.STATS) FORMAT=BESTX5. LABEL="STATS" AS STATS
      FROM QASQL_1.UoSStats t1
	  WHERE t1.Accum = "A" /** AND t1.OPUnit = 'RVHSP' ***/
			AND INPUT(t1.Dept, 8.) IN (16090) 
			AND t1.ChargeCode NOT IN ("99800009")
	  		AND INPUT(t1.FY, 8.) IN (2016, 2017)
      GROUP BY t1.OPUnit,
               t1.FY,
               t1.Dept,
               t1.PP
      ORDER BY t1.OPUnit,
               t1.FY,
               t1.Dept,
               t1.PP;

   CREATE TABLE WORK.RVH_LDOPIB_FY_16_17_STATS_v1 AS 
   SELECT t1.OPUnit, 
          INPUT(t1.FY, 8.) as FY, 
          INPUT(t1.Dept, 8.) as Dept,
          t1.PP, 
          /* STATS */
          SUM(t1.STATS) FORMAT=BESTX5. LABEL="STATS" AS OLD_STATS, 
		  SUM(t1.STATS)*0.09 FORMAT=BESTX5. LABEL="STATS" AS STATS 
      FROM QASQL_1.UoSStats t1
	  WHERE t1.Accum = "A" /*** AND t1.OPUnit = 'RVHSP' ***/
			AND INPUT(t1.Dept, 8.) IN (16090) 
			AND t1.ChargeCode IN ("99800009")
	  		AND INPUT(t1.FY, 8.) IN (2016, 2017)
      GROUP BY t1.OPUnit,
               t1.FY,
               t1.Dept,
               t1.PP
      ORDER BY t1.OPUnit,
               t1.FY,
               t1.Dept,
               t1.PP;

   CREATE TABLE WORK.RVH_LD_FY_18_STATS_v1 AS 
   SELECT t1.OPUnit, 
          INPUT(t1.FY, 8.) as FY, 
          INPUT(t1.Dept, 8.) as Dept,
          t1.PP, 
          /* STATS */
          SUM(t1.STATS) FORMAT=BESTX5. LABEL="STATS" AS STATS
      FROM QASQL_1.UoSStats t1
	  WHERE t1.Accum = "A" /*** AND t1.OPUnit = 'RVHSP' ***/
			AND INPUT(t1.Dept, 8.) IN (16090)
	  		AND INPUT(t1.FY, 8.) >= 2018
      GROUP BY t1.OPUnit,
               t1.FY,
               t1.Dept,
               t1.PP
      ORDER BY t1.OPUnit,
               t1.FY,
               t1.Dept,
               t1.PP;

	CREATE TABLE WORK.RVH_LD_STATS_v1 AS 
	SELECT * FROM WORK.RVH_LDNOOPIB_FY_16_17_STATS_v1
	 OUTER UNION CORR 
	SELECT OPUnit, FY, Dept, PP, STATS FROM WORK.RVH_LDOPIB_FY_16_17_STATS_v1
	 OUTER UNION CORR 
	SELECT * FROM WORK.RVH_LD_FY_18_STATS_v1
	ORDER BY OPUnit, FY, Dept, PP;

	CREATE TABLE WORK.RVH_LD_STATS_v2 AS
	SELECT t1.OPUnit, t1.FY, t1.Dept, t1.PP, 
          /* STATS */ 
		  SUM(t1.STATS) FORMAT=BESTX5. LABEL="STATS" AS STATS 
      FROM WORK.RVH_LD_STATS_v1 t1
      GROUP BY t1.OPUnit,
               t1.FY,
               t1.Dept,
               t1.PP
      ORDER BY t1.OPUnit,
               t1.FY,
               t1.Dept,
               t1.PP;

    CREATE TABLE WORK.RVH_FY_17_STATS_v4 AS 
	SELECT * FROM WORK.RVH_FY_17_STATS_v3
	 OUTER UNION CORR 
	SELECT * FROM WORK.RVH_LD_STATS_v2
	ORDER BY OPUnit, FY, Dept, PP;

   CREATE TABLE WORK.RVH_FY_17_STATS_v5 AS 
   SELECT t1.OPUnit, 
          /** t2.ForecastModelGroupings, **/
          t1.FY, 
          t1.Dept, 
          t1.PP, 
		  INPUT(SUBSTR(t1.PP,3), 2.) as PayPeriod,
          t1.STATS
      FROM WORK.RVH_FY_17_STATS_v4 t1
      INNER JOIN WORK.PRC_COSTCENTERGROUPS t2 ON (t1.OPUnit = t2.Facility) AND (t1.Dept = t2.CostCenter)
      ORDER BY t1.OPUnit, t1.FY,
               t1.Dept,
               t1.PP,  SCAN(t1.PP,3)
               ;

   CREATE TABLE WORK.RVH_STATS_SurgeryAdmin_v1 AS 
   SELECT  t1.OPUnit, 
          INPUT(t1.FY, 8.) as FY, 
          INPUT(t1.Dept, 8.) as Dept, t2.SurgeryAdminCostCenter, t2.Costcenter,
          t1.PP, 
          /* STATS */
          SUM(t1.STATS) FORMAT=BESTX5. LABEL="STATS" AS STATS
      FROM QASQL_1.UoSStats t1
	  INNER JOIN WORK.PRC_COSTCENTERGROUPS t2
	  ON (t1.OPUnit = t2.Facility AND INPUT(t1.Dept, 8.) = t2.SurgeryAdminCostCenter)
	  WHERE t1.Accum = "A" AND t2.SurgeryAdminCostCenter IS NOT NULL  
      GROUP BY t1.OPUnit,
               t1.FY,
               t1.Dept, t2.SurgeryAdminCostCenter, t2.Costcenter,
               t1.PP
      ORDER BY t1.OPUnit,
               t1.FY,
               t1.Dept, t2.SurgeryAdminCostCenter, t2.Costcenter,
               t1.PP;


QUIT;

DATA WORK.RVH_STATS_SurgeryAdmin_v2 ;
	SET WORK.RVH_STATS_SurgeryAdmin_v1 (DROP= Dept SurgeryAdminCostCenter RENAME=(CostCenter = Dept));

	PayPeriod = INPUT(SUBSTR(PP,3), 2.);
RUN;

/** Manual Stats extract ***/
PROC SQL;
   CREATE TABLE WORK.OH_Manual_STATS_v1 AS 
   SELECT t1.'Op Unit'n AS OPUnit, 
          t1.'Fiscal Year'n as FY, 
          INPUT(t1.Dept, 8.) as Dept,
          t1.'Pay Period'n AS PayPeriod, CATX('', "PP", PUT(t1.'Pay Period'n,z2.)) AS PP,
          SUM(t1.'Manual Volume'n) FORMAT=BESTX5. LABEL="STATS" AS STATS
      FROM QASQL_1.BW_ManualStats t1
	  WHERE INPUT(t1.Dept, 8.)  IN (34040)  
      GROUP BY t1.'Op Unit'n,
               t1.'Fiscal Year'n,
               INPUT(t1.Dept, 8.),
               t1.'Pay Period'n, CATX('', "PP", PUT(t1.'Pay Period'n,z2.))
      ORDER BY t1.'Op Unit'n,
               t1.'Pay Period'n,
               t1.'Fiscal Year'n,
               INPUT(t1.Dept, 8.);

	/*** Sterile Processing Dept ***/
   CREATE TABLE WORK.OH_Manual_STATS_v2 AS 
   SELECT t1.'Op Unit'n AS OPUnit, 
          t1.'Fiscal Year'n as FY, 
          INPUT(t1.Dept, 8.) as Dept,
          t1.'Pay Period'n AS PayPeriod, CATX('', "PP", PUT(t1.'Pay Period'n,z2.)) AS PP,
          SUM(t1.'Manual Volume'n) FORMAT=BESTX5. LABEL="STATS" AS STATS
      FROM QASQL_1.BW_ManualStats t1
	  WHERE t1.'Op Unit'n IN ("RVHSP", "DBHSP") AND INPUT(t1.Dept, 8.)  IN (25120)  
      GROUP BY t1.'Op Unit'n,
               t1.'Fiscal Year'n,
               INPUT(t1.Dept, 8.),
               t1.'Pay Period'n, CATX('', "PP", PUT(t1.'Pay Period'n,z2.))
      ORDER BY t1.'Op Unit'n,
               t1.'Fiscal Year'n, t1.'Pay Period'n,
               INPUT(t1.Dept, 8.);
	/*** End of Sterile Processing Dept ***/

QUIT;
/** End of Manual Stats extract ***/

/*** EVS Stats Computation ***/

PROC SQL;
   CREATE TABLE WORK.EVS_STATS_V1 AS 
   SELECT t1.OPUnit, 
          INPUT(t1.FY, 8.) as FY, 75020 AS Dept,
          t1.PP, INPUT(SUBSTR(t1.PP,3), 2.) as PayPeriod,
          /* STATS */
          SUM(t1.STATS) FORMAT=BESTX5. LABEL="STATS" AS STATS
      FROM QASQL_1.UoSStats t1
      INNER JOIN WORK.Patientdays_finaccumchargecodes t3 ON (t1.OPUnit = t3.Facility AND INPUT(t1.FY, 8.) = t3.FY AND INPUT(t1.ChargeCode, 8.) = t3.ChargeCode)
	  WHERE t1.Accum = "A" AND UPCASE(t3.GLAccountName) <> "PATIENT DAYS NURSERY"
      GROUP BY t1.OPUnit,
               t1.FY, CALCULATED Dept,
               t1.PP, CALCULATED PayPeriod
      ORDER BY t1.OPUnit,
               t1.FY,
               t1.PP;

	 CREATE TABLE WORK.EVS_STATS_V2 AS 
	 SELECT t1.OPUnit, t1.FY, t1.PP, t1.PayPeriod, t1.Dept, t1.STATS *t2.AdjustmentFactor AS STATS
	 FROM WORK.EVS_STATS_V1 t1
	 LEFT JOIN WORK.EVSADJFACTOR t2 ON (t1.OPUnit = t2.Facility) 
	 ORDER BY t1.OPUnit, t1.FY, t1.PP, t1.PayPeriod ;

QUIT;

/*** END Of EVS Stats Computation ***/

 /*** Imaging 1.GYHSP 35020 – This is the combination of 35020, 35030, 35070, 35090, and 35170
      		  2.GTHSP 35020 – this is the combination of 35020 and 35010
			  3.MMHSP 35140 – They no longer are accumulating the stats.  We have to assume the same charges codes are accumulating now that were accumulating in FY17.
 ***/
DATA RVH_FY_17_STATS_v5_1;
	SET RVH_FY_17_STATS_v5;
	IF UPCASE(OPUnit) = "GTHSP" AND Dept in (35010) THEN Dept = 35020;
	IF UPCASE(OPUnit) = "GYHSP" AND Dept IN (35030, 35070, 35090, 35170) THEN Dept = 35020;
RUN;

DATA WORK.MMHSP35140_FY_18_STATS;
	SET WORK.RVH_FY_17_STATS_v5;
	IF UPCASE(OPUnit) = "MMHSP" AND Dept in (35140) AND FY=2017;
	FY=2018;
RUN;

/** End of Imaging ***/

PROC SQL;
   CREATE TABLE WORK.RVH_FY_17_STATS_v5 AS 
   SELECT t1.OPUnit, 
          t1.FY, 
          t1.Dept, 
          t1.PP, 
		  t1.PayPeriod,
          SUM(t1.STATS) AS STATS
      FROM WORK.RVH_FY_17_STATS_v5_1 t1
	  GROUP BY t1.OPUnit, t1.FY,
               t1.Dept,
               t1.PP,  t1.PayPeriod
      ORDER BY t1.OPUnit, t1.FY,
               t1.Dept,
               t1.PP,  t1.PayPeriod
               ;

    CREATE TABLE WORK.RVH_FY_17_STATS_v5 AS 
	SELECT * FROM WORK.RVH_FY_17_STATS_v5
	OUTER UNION CORR 
	SELECT * FROM WORK.RVH_STATS_SurgeryAdmin_v2
	OUTER UNION CORR 
	SELECT * FROM WORK.OH_Manual_STATS_v1
	OUTER UNION CORR
    SELECT * FROM WORK.OH_Manual_STATS_v2
	OUTER UNION CORR 
	SELECT * FROM WORK.EVS_STATS_V2
	OUTER UNION CORR 
	SELECT * FROM WORK.MMHSP35140_FY_18_STATS
	ORDER BY OPUnit, FY, Dept, PP;

	/*** Dataset to create volume dashboard in Qliksesne ***/
	CREATE TABLE WORK.OH_STATS_v1 AS
	SELECT t1.OPUnit, t1.FY, t1.Dept, t3.FunctionalGroupings, t3.CostCenterDescription, t2.MonthStartDate, t2.FY_Month, t2.Month, SUM(t1.STATS) AS Volume
    FROM WORK.RVH_FY_17_STATS_v5 t1
	INNER JOIN WORK.PP_LOOKSUP t2 ON (t1.FY = t2.FY AND t1.PayPeriod = t2.PP)
	LEFT JOIN WORK.PRC_COSTCENTERGROUPS t3 on (t1.OPUnit = t3.Facility) AND (t1.Dept = t3.CostCenter)
	WHERE t1.STATS>0
	GROUP BY t1.OPUnit, t1.FY, t1.Dept, t3.FunctionalGroupings, t3.CostCenterDescription, t2.MonthStartDate, t2.FY_Month, t2.Month
	ORDER BY t1.OPUnit, t1.FY, t1.Dept, t3.FunctionalGroupings, t3.CostCenterDescription, t2.MonthStartDate, t2.FY_Month, t2.Month;
	/*** End of Dataset to create volume dashboard in Qliksesne ***/
RUN;





GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;
%LET _SASPROGRAMFILEHOST=;


/*   START OF NODE: FixedDept_Savings   */
%LET _CLIENTTASKLABEL='FixedDept_Savings';
%LET _CLIENTPROCESSFLOWNAME='Process Flow';
%LET _CLIENTPROJECTPATH='G:\Corporate\share\Quality and Affordability Initiative\Data\Analytics Strategy\Sustainment Tools\CostPerUoS\CostPerUoS_IPNursing_v2.egp';
%LET _CLIENTPROJECTPATHHOST='LT163637';
%LET _CLIENTPROJECTNAME='CostPerUoS_IPNursing_v2.egp';
%LET _SASPROGRAMFILE='';
%LET _SASPROGRAMFILEHOST='';

GOPTIONS ACCESSIBLE;
/*** Pull Manual Savings for few facility and cost center ***/

PROC IMPORT OUT= WORK.RVHSP32015 DATAFILE= "/home/pxj479/Tasks/Input/WFI_ManualSavingsUpdate.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="RVHSP32015"; 
     GETNAMES=YES;
RUN;

DATA WORK.RVHSP32015_v2;
	SET WORK.RVHSP32015;
	IF MONTH IN (7, 8, 9, 10, 11, 12) THEN 
		DO; FY = Year + 1 ; FY_Month = Month - 6; END;
	ELSE 
		DO; FY = Year; FY_Month = Month + 6; END; 
RUN;

/*** End of Pull Manual Savings for few facility and cost center ***/

/*** Imaging fixed dept savings ***/

PROC SQL;
   CREATE TABLE WORK.Imaging_FixedDept_FY16_v1 AS 
   SELECT t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t2.FY, t3.Benefits_2016 AS Benefits, 
          (SUM(t1.SUM_of_SUM_of_OTH_EARNS)) FORMAT=BEST12. AS SUM_of_OTH_EARNS, SUM(t1.SUM_of_SUM_of_OTH_EARNS)/26 FORMAT=BEST12. AS FY16_Target,
          (SUM(t1.SUM_of_SUM_of_OTH_HRS)) FORMAT=BEST12. AS SUM_of_OTH_HRS
   FROM WORK.RMH_COST_3178_V2 t1
   INNER JOIN WORK.PP_LOOKSUP t2 ON (t1.PPDATE = t2.PPDate)
   LEFT JOIN WORK.PRC_COSTCENTERGROUPS AS t3 ON (t1.BUSINESSUNIT = t3.Facility AND t1.FunctionalGroupings = t3.FunctionalGroupings AND t1.DeptID = t3.CostCenter)
   WHERE t2.FY = 2016  AND t1.BUSINESSUNIT IN ("DRHSP", "RVHSP") AND t1.DeptID IN (35130, 35090, 35115)
   GROUP BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t2.FY, t3.Benefits_2016 
   ORDER BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t2.FY;

   CREATE TABLE WORK.Imaging_FixedDept_Cost_v1 AS 
   SELECT t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t3.CostCenterDescription, t1.PPDATE, t2.Month, t2.FY, t2.FY_Month, t2.PP, t3.Baseline, 
		    CASE 
				WHEN t2.FY = 2016 THEN t3.Benefits_2016
				WHEN t2.FY = 2017 THEN t3.Benefits_2017
				WHEN t2.FY = 2018 THEN t3.Benefits_2018
				WHEN t2.FY = 2019 THEN t3.Benefits_2019
				WHEN t2.FY = 2020 THEN t3.Benefits_2019 /* To be changed when 2020 budget available */
			END AS Benefits,
            (SUM(t1.SUM_of_SUM_of_OTH_EARNS)) FORMAT=BEST12. AS SUM_of_OTH_EARNS,
            (SUM(t1.SUM_of_SUM_of_OTH_HRS)) FORMAT=BEST12. AS SUM_of_OTH_HRS,
			CASE  
		    WHEN FY <= Baseline OR FY >= 2019 THEN (SUM(t1.SUM_of_SUM_of_OTH_EARNS))
			ELSE (SUM(t1.SUM_of_SUM_of_OTH_EARNS))*(0.972**(FY-Baseline))
		    END AS SUM_of_OTH_EARNS_Adjusted
   FROM WORK.RMH_COST_3178_V2 t1
   INNER JOIN WORK.PP_LOOKSUP t2 ON (t1.PPDATE = t2.PPDate)
   LEFT JOIN WORK.PRC_COSTCENTERGROUPS AS t3 ON (t1.BUSINESSUNIT = t3.Facility AND t1.FunctionalGroupings = t3.FunctionalGroupings AND t1.DeptID = t3.CostCenter)
   WHERE t2.FY >= 2016 AND t1.BUSINESSUNIT IN ("DRHSP", "RVHSP") AND t1.DeptID IN (35130, 35090, 35115)
   GROUP BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t3.CostCenterDescription, t1.PPDATE, t2.Month ,t2.FY, t2.FY_Month, t2.PP, t3.Baseline,CALCULATED Benefits
   ORDER BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t3.CostCenterDescription, t1.DeptID, t1.PPDATE, t2.Month ,t2.FY, t2.FY_Month, t2.PP, t3.Baseline, CALCULATED Benefits;

   CREATE TABLE WORK.Imaging_FixedDept_Cost_v2 AS 
   SELECT t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.CostCenterDescription, COUNT(t1.PPDATE) AS PP_Count, t1.Month, t1.FY, t1.FY_Month, t1.Baseline, t1.Benefits, 
   		  t2.FY16_Target*COUNT(t1.PPDATE) AS  FY16_Target, t3.TotalLaborCost AS FY19_BudgetLaborCost,
          (SUM(t1.SUM_of_OTH_EARNS)) FORMAT=BEST12. AS SUM_of_OTH_EARNS,
          (SUM(t1.SUM_of_OTH_HRS)) FORMAT=BEST12. AS SUM_of_OTH_HRS,
		  (SUM(t1.SUM_of_OTH_EARNS_Adjusted)) FORMAT=BEST12. AS SUM_of_OTH_EARNS_Adjusted,
		  CASE 
		  WHEN t1.FY <= 2018 THEN (CALCULATED FY16_Target - SUM(t1.SUM_of_OTH_EARNS_Adjusted)) 
		  WHEN t1.FY >= 2019 THEN (FY19_BudgetLaborCost - SUM(t1.SUM_of_OTH_EARNS_Adjusted))
		  END AS MonthlySavings FORMAT 8. 
   FROM WORK.Imaging_FixedDept_Cost_v1 t1
   LEFT JOIN WORK.Imaging_FixedDept_FY16_v1 t2 ON (t1.BUSINESSUNIT = t2.BUSINESSUNIT AND t1.FunctionalGroupings = t2.FunctionalGroupings AND t1.DeptID = t2.DeptID)
   LEFT JOIN WORK.FY19_Budget_ALL_v3 AS t3 ON (t1.BUSINESSUNIT = t3.Facility AND t1.DeptID = t3.CostCenter AND t1.FY = t3.FY AND t1.Month = t3.Month)
   GROUP BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.CostCenterDescription, t1.FY,  t1.Month , t1.FY_Month, t1.Baseline, t1.Benefits, t2.FY16_Target, t3.TotalLaborCost
   ORDER BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.CostCenterDescription, t1.FY,  t1.Month , t1.FY_Month;

QUIT;

DATA WORK.Imaging_FixedDept_Cost_v3 ;
	SET WORK.Imaging_FixedDept_Cost_v2 (DROP=PP_Count);
	SUM_of_STATS =.; CostPerUoS =.; Target=.; FY16_Target=.; FY17_Target=.; Rehab_Target=.; OBHSP_PERIOP_CostPerUoS=.;
RUN;

/*** End of Imaging fixed dept savings ***/

/*** Periop 82320 and 82321 fixed department savings ***/
PROC SQL;

   CREATE TABLE WORK.Periop_FixedDept_FY16_v1 AS 
   SELECT t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t2.FY, t3.Benefits_2016 AS Benefits, 
          (SUM(t1.SUM_of_SUM_of_OTH_EARNS)) FORMAT=BEST12. AS SUM_of_OTH_EARNS, SUM(t1.SUM_of_SUM_of_OTH_EARNS)/26 FORMAT=BEST12. AS FY16_Target,
          (SUM(t1.SUM_of_SUM_of_OTH_HRS)) FORMAT=BEST12. AS SUM_of_OTH_HRS
   FROM WORK.RMH_COST_3178_V2 t1
   INNER JOIN WORK.PP_LOOKSUP t2 ON (t1.PPDATE = t2.PPDate)
   LEFT JOIN WORK.PRC_COSTCENTERGROUPS AS t3 
   			 ON (t1.BUSINESSUNIT = t3.Facility AND t1.FunctionalGroupings = t3.FunctionalGroupings AND t1.DeptID = t3.CostCenter)
   WHERE t2.FY = 2016  AND t1.DeptID IN (82320, 82321) AND UPCASE(t1.FunctionalGroupings) = "PERIOP"
   GROUP BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t2.FY, t3.Benefits_2016 
   ORDER BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t2.FY;

   CREATE TABLE WORK.Periop_FixedDept_Cost_v1 AS 
   SELECT t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t3.CostCenterDescription, t1.PPDATE, t2.Month, t2.FY, t2.FY_Month, t2.PP, t3.Baseline, 
		    CASE 
				WHEN t2.FY = 2016 THEN t3.Benefits_2016
				WHEN t2.FY = 2017 THEN t3.Benefits_2017
				WHEN t2.FY = 2018 THEN t3.Benefits_2018
				WHEN t2.FY >= 2019 THEN t3.Benefits_2019 /* will need to be changed when 2020 benefits available*/
				
			END AS Benefits,
            (SUM(t1.SUM_of_SUM_of_OTH_EARNS)) FORMAT=BEST12. AS SUM_of_OTH_EARNS,
            (SUM(t1.SUM_of_SUM_of_OTH_HRS)) FORMAT=BEST12. AS SUM_of_OTH_HRS,
			CASE  
		    WHEN FY <= Baseline OR FY >= 2019 THEN (SUM(t1.SUM_of_SUM_of_OTH_EARNS))
			ELSE (SUM(t1.SUM_of_SUM_of_OTH_EARNS))*(0.972**(FY-Baseline))
		    END AS SUM_of_OTH_EARNS_Adjusted
   FROM WORK.RMH_COST_3178_V2 t1
   INNER JOIN WORK.PP_LOOKSUP t2 ON (t1.PPDATE = t2.PPDate)
   LEFT JOIN WORK.PRC_COSTCENTERGROUPS AS t3 ON (t1.BUSINESSUNIT = t3.Facility AND t1.FunctionalGroupings = t3.FunctionalGroupings AND t1.DeptID = t3.CostCenter)
   WHERE t2.FY >= 2016  AND t1.DeptID IN (82320, 82321) AND UPCASE(t1.FunctionalGroupings) = "PERIOP"
   GROUP BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t3.CostCenterDescription, t1.PPDATE, t2.Month ,t2.FY, t2.FY_Month, t2.PP, t3.Baseline,CALCULATED Benefits
   ORDER BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t3.CostCenterDescription, t1.DeptID, t1.PPDATE, t2.Month ,t2.FY, t2.FY_Month, t2.PP, t3.Baseline, CALCULATED Benefits;

   CREATE TABLE WORK.Periop_FixedDept_Cost_v2 AS 
   SELECT t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.CostCenterDescription, COUNT(t1.PPDATE) AS PP_Count, t1.Month, t1.FY, t1.FY_Month, t1.Baseline, t1.Benefits, 
   		  t2.FY16_Target*COUNT(t1.PPDATE) AS  FY16_Target, t3.TotalLaborCost AS FY19_BudgetLaborCost,
          (SUM(t1.SUM_of_OTH_EARNS)) FORMAT=BEST12. AS SUM_of_OTH_EARNS,
          (SUM(t1.SUM_of_OTH_HRS)) FORMAT=BEST12. AS SUM_of_OTH_HRS,
		  (SUM(t1.SUM_of_OTH_EARNS_Adjusted)) FORMAT=BEST12. AS SUM_of_OTH_EARNS_Adjusted,
		  CASE 
		  WHEN t1.FY <= 2018 THEN (CALCULATED FY16_Target - SUM(t1.SUM_of_OTH_EARNS_Adjusted)) 
		  WHEN t1.FY >= 2019 THEN (FY19_BudgetLaborCost - SUM(t1.SUM_of_OTH_EARNS_Adjusted))
		  END AS MonthlySavings FORMAT 8. 
   FROM WORK.Periop_FixedDept_Cost_v1 t1
   LEFT JOIN WORK.Periop_FixedDept_FY16_v1 t2 ON (t1.BUSINESSUNIT = t2.BUSINESSUNIT AND t1.FunctionalGroupings = t2.FunctionalGroupings AND t1.DeptID = t2.DeptID)
   LEFT JOIN WORK.FY19_Budget_ALL_v3 AS t3 ON (t1.BUSINESSUNIT = t3.Facility AND t1.DeptID = t3.CostCenter AND t1.FY = t3.FY AND t1.Month = t3.Month)
   GROUP BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.CostCenterDescription, t1.FY,  t1.Month , t1.FY_Month, t1.Baseline, t1.Benefits, t2.FY16_Target, t3.TotalLaborCost
   ORDER BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.CostCenterDescription, t1.FY,  t1.Month , t1.FY_Month;

QUIT;

DATA WORK.Periop_FixedDept_Cost_v3 ;
	SET WORK.Periop_FixedDept_Cost_v2 (DROP=PP_Count);
	SUM_of_STATS =.; CostPerUoS =.; Target=.; FY16_Target=.; FY17_Target=.; Rehab_Target=.; OBHSP_PERIOP_CostPerUoS=.;
RUN;

/*** End of Periop 82320 and 82321 fixed department savings ***/

GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;
%LET _SASPROGRAMFILEHOST=;


/*   START OF NODE: Postprocessing   */
%LET _CLIENTTASKLABEL='Postprocessing';
%LET _CLIENTPROCESSFLOWNAME='Process Flow';
%LET _CLIENTPROJECTPATH='G:\Corporate\share\Quality and Affordability Initiative\Data\Analytics Strategy\Sustainment Tools\CostPerUoS\CostPerUoS_IPNursing_v2.egp';
%LET _CLIENTPROJECTPATHHOST='LT163637';
%LET _CLIENTPROJECTNAME='CostPerUoS_IPNursing_v2.egp';
%LET _SASPROGRAMFILE='';
%LET _SASPROGRAMFILEHOST='';

GOPTIONS ACCESSIBLE;
PROC SQL;
/**** IP Nursing ****/
   CREATE TABLE WORK.RMH_IPNursing_COST_3178_v1 AS 
   SELECT t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.PPDATE, t2.Month, 
          t2.FY, t2.FY_Month,
          t2.PP,
		  
          /* SUM_of_OTH_EARNS */
            (SUM(t1.SUM_of_SUM_of_OTH_EARNS)) FORMAT=BEST12. AS SUM_of_OTH_EARNS, 
          /* SUM_of_OTH_HRS */
            (SUM(t1.SUM_of_SUM_of_OTH_HRS)) FORMAT=BEST12. AS SUM_of_OTH_HRS
      FROM WORK.RMH_COST_3178_V2 t1
      INNER JOIN WORK.PP_LOOKSUP t2 ON (t1.PPDATE = t2.PPDate)
      WHERE t2.FY >= 2016 AND  t1.DeptID NOT IN 
           (
           16030,
           16031, 16090
           )
      GROUP BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.PPDATE,  t2.Month ,
               t2.FY, t2.FY_Month,
               t2.PP
			   
      ORDER BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.PPDATE, t2.Month ,
               t2.FY, t2.FY_Month,
               t2.PP ;

   CREATE TABLE WORK.RMH_IPNursing_UoS_v1 AS 
   SELECT t1.OPUnit as BusinessUnit, t1.Dept as DeptID, t2.PPDate, t2.Month, 
          t1.FY, t2.FY_Month,
          t1.PayPeriod, 
          /* SUM_of_STATS */
            (SUM(t1.STATS)) FORMAT=BEST12. AS SUM_of_STATS
      FROM WORK.RVH_FY_17_STATS_v5 t1, WORK.PP_LOOKSUP t2
      WHERE (t1.FY = t2.FY AND t1.PayPeriod = t2.PP) AND (t2.FY >= 2016 AND t1.Dept NOT IN 
           (
           16030,
           16031, 16090
           )) 
      GROUP BY t1.OPUnit, t1.Dept, t2.PPDate, t2.Month, 
               t1.FY,t2.FY_Month,
               t1.PayPeriod
      ORDER BY t1.OPUnit, t1.Dept, t2.PPDate,  t2.Month, 
			   t1.FY, t2.FY_Month,
               t1.PayPeriod;

   CREATE TABLE WORK.RMH_IPNURSING_COSTPERUoS AS 
   SELECT t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.PPDATE, t1.Month, 
          t1.FY, t1.FY_Month,
          t1.PP,
          t1.SUM_of_OTH_EARNS, 
          t1.SUM_of_OTH_HRS, 
          t2.SUM_of_STATS
   FROM WORK.RMH_IPNURSING_COST_3178_V1 t1
   INNER JOIN WORK.RMH_IPNURSING_UOS_V1 t2 ON (t1.BUSINESSUNIT = t2.BUSINESSUNIT AND t1.DeptID = t2.DeptID AND t1.PPDATE = t2.PPDate);

   CREATE TABLE WORK.RMH_IPNURSING_COSTPERUoS_v2 AS 
   SELECT t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.PPDATE, MDY(t1.Month, 1, t1.FY) as FY_MonthStartDate FORMAT Date9., t1.FY, t1.FY_Month,
          t1.Month,
          /* SUM_of_OTH_EARNS */
            (SUM(t1.SUM_of_OTH_EARNS)) FORMAT=BEST12. AS SUM_of_OTH_EARNS, 
          /* SUM_of_OTH_HRS */
            (SUM(t1.SUM_of_OTH_HRS)) FORMAT=BEST12. AS SUM_of_OTH_HRS, 
          /* SUM_of_STATS */
            (SUM(t1.SUM_of_STATS)) FORMAT=BEST12. AS SUM_of_STATS
      FROM WORK.RMH_IPNURSING_COSTPERUOS t1
      GROUP BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.PPDATE, MDY(t1.Month, 1, t1.FY), 
			   t1.FY, t1.FY_Month, t1.Month
      ORDER BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.PPDATE, t1.FY, t1.FY_Month;
QUIT;

PROC SQL;
 /*** Womens Health cost centers ***/
   CREATE TABLE WORK.RMH_WNB_COST_3178_v1 AS 
   SELECT t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.PPDATE, 
          t2.FY, t2.FY_Month,
          t2.PP,
		  t2.Month,  
        
            (SUM(t1.SUM_of_SUM_of_OTH_EARNS)) FORMAT=BEST12. AS SUM_of_OTH_EARNS, 
         
            (SUM(t1.SUM_of_SUM_of_OTH_HRS)) FORMAT=BEST12. AS SUM_of_OTH_HRS
      FROM WORK.RMH_COST_3178_V2 t1
      INNER JOIN WORK.PP_LOOKSUP t2 ON (t1.PPDATE = t2.PPDate)
      WHERE t2.FY >= 2016 AND t1.DeptID IN 
           (
           16030,
           16031
           )
      GROUP BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.PPDATE,
               t2.FY, t2.FY_Month,
               t2.PP, t2.Month
      ORDER BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.PPDATE,
               t2.FY, t2.FY_Month,
               t2.PP, t2.Month;

   CREATE TABLE WORK.RMH_WNB_UoS_v1 AS 
   SELECT t1.OPUnit as BusinessUnit, t1.Dept as DeptID, t2.PPDate, 
          t1.FY, t2.FY_Month,
          t1.PayPeriod, t2.Month,  
         
            (SUM(t1.STATS)) FORMAT=BEST12. AS SUM_of_STATS
      FROM WORK.RVH_FY_17_STATS_v5 t1, WORK.PP_LOOKSUP t2
      WHERE (t1.FY = t2.FY AND t1.PayPeriod = t2.PP) AND (t2.FY >= 2016 AND t1.Dept IN 
           (
           16030,
           16031
           ))
      GROUP BY t1.OPUnit, t1.Dept, t2.PPDate,
               t1.FY, t2.FY_Month,
               t1.PayPeriod, t2.Month
      ORDER BY t1.OPUnit, t1.Dept, t2.PPDate, 
			   t1.FY, t2.FY_Month,
               t1.PayPeriod, t2.Month;

   CREATE TABLE WORK.RMH_WNB_COSTPERUoS AS 
   SELECT t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.PPDATE, 
          t1.FY, t1.FY_Month,
          t1.PP, t1.Month, 
          t1.SUM_of_OTH_EARNS, 
          t1.SUM_of_OTH_HRS, 
          t2.SUM_of_STATS
   FROM WORK.RMH_WNB_COST_3178_v1 t1
   INNER JOIN WORK.RMH_WNB_UoS_v1 t2 ON (t1.BUSINESSUNIT = t2.BUSINESSUNIT AND t1.DeptID = t2.DeptID AND t1.PPDATE = t2.PPDate);

   CREATE TABLE WORK.RMH_WNB_COSTPERUoS_v2 AS 
   SELECT t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.PPDATE, MDY(t1.Month, 1, t1.FY) as FY_MonthStartDate FORMAT Date9., t1.FY, t1.FY_Month,
          t1.Month,
         
            (SUM(t1.SUM_of_OTH_EARNS)) FORMAT=BEST12. AS SUM_of_OTH_EARNS, 
         
            (SUM(t1.SUM_of_OTH_HRS)) FORMAT=BEST12. AS SUM_of_OTH_HRS, 
			(SUM(t1.SUM_of_STATS)) FORMAT=BEST12. AS SUM_of_STATS
      FROM WORK.RMH_WNB_COSTPERUoS t1
      GROUP BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.PPDATE, MDY(t1.Month, 1, t1.FY), t1.FY, t1.FY_Month,
               t1.Month
      ORDER BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.PPDATE, t1.FY, t1.FY_Month;
QUIT;

PROC SQL;
  /*** Labor and Delivery cost centers ***/
   CREATE TABLE WORK.RMH_LD_COST_3178_v1 AS 
   SELECT t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.PPDATE, 
          t2.FY, t2.FY_Month,
          t2.PP, t2.Month, 
          
            (SUM(t1.SUM_of_SUM_of_OTH_EARNS)) FORMAT=BEST12. AS SUM_of_OTH_EARNS, 
         
            (SUM(t1.SUM_of_SUM_of_OTH_HRS)) FORMAT=BEST12. AS SUM_of_OTH_HRS
      FROM WORK.RMH_COST_3178_V2 t1
      INNER JOIN WORK.PP_LOOKSUP t2 ON (t1.PPDATE = t2.PPDate)
      WHERE t2.FY >= 2016 AND t1.DeptID IN 
           (
           16090
           )
      GROUP BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.PPDATE,
               t2.FY, t2.FY_Month,
               t2.PP, t2.Month
      ORDER BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.PPDATE,
               t2.FY, t2.FY_Month,
               t2.PP, t2.Month;

   CREATE TABLE WORK.RMH_LD_UoS_v1 AS 
   SELECT t1.OPUnit as BusinessUnit, t1.Dept as DeptID, t2.PPDate, 
          t1.FY, t2.FY_Month,
          t1.PayPeriod, t2.Month, 
         
            (SUM(t1.STATS)) FORMAT=BEST12. AS SUM_of_STATS
   FROM WORK.RVH_FY_17_STATS_v5 t1, WORK.PP_LOOKSUP t2
   WHERE (t1.FY = t2.FY AND t1.PayPeriod = t2.PP) AND (t2.FY >= 2016 AND t1.Dept IN 
           (
           16090
           ))
   GROUP BY t1.OPUnit, t1.Dept, t2.PPDate,
               t1.FY, t2.FY_Month,
               t1.PayPeriod, t2.Month
   ORDER BY t1.OPUnit, t1.Dept, t2.PPDate, 
			   t1.FY, t2.FY_Month,
               t1.PayPeriod, t2.Month;

   CREATE TABLE WORK.RMH_LD_COSTPERUoS AS 
   SELECT t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.PPDATE, 
          t1.FY, t1.FY_Month,
          t1.PP, t1.Month, 
          t1.SUM_of_OTH_EARNS, 
          t1.SUM_of_OTH_HRS, 
          t2.SUM_of_STATS
  FROM WORK.RMH_LD_COST_3178_v1 t1
  INNER JOIN WORK.RMH_LD_UoS_v1 t2 ON (t1.BUSINESSUNIT = t2.BUSINESSUNIT AND t1.DeptID = t2.DeptID AND t1.PPDATE = t2.PPDate);

   CREATE TABLE WORK.RMH_LD_COSTPERUoS_v2 AS 
   SELECT t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.PPDATE, MDY(t1.Month, 1, t1.FY) as FY_MonthStartDate FORMAT Date9., t1.FY, t1.FY_Month,
          t1.Month,
         
            (SUM(t1.SUM_of_OTH_EARNS)) FORMAT=BEST12. AS SUM_of_OTH_EARNS, 
         
            (SUM(t1.SUM_of_OTH_HRS)) FORMAT=BEST12. AS SUM_of_OTH_HRS, 
        
            (SUM(t1.SUM_of_STATS)) FORMAT=BEST12. AS SUM_of_STATS
      FROM WORK.RMH_LD_COSTPERUoS t1
      GROUP BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.PPDATE, MDY(t1.Month, 1, t1.FY), t1.FY, t1.FY_Month,
               t1.Month
      ORDER BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.PPDATE, t1.FY, t1.FY_Month;

QUIT;
/**

DATA RMH_IPNURSING_COSTPERUOS_V3;
	 SET RMH_IPNURSING_COSTPERUOS_V2;
	 FORMAT FY17MonthlySavings_v1 FY18MonthlySavings_v1 8.;
	 FY17MonthlySavings_v1=(LAG26(CostPerUoS)-CostPerUoS)*SUM_of_STATS;
	 FY18MonthlySavings_v1=(LAG52(CostPerUoS)-CostPerUoS)*SUM_of_STATS;

	 IF FY = 2016 THEN DO; FY17MonthlySavings_v1 = .; FY18MonthlySavings_v1 = .; END;
	 ELSE IF FY = 2017 THEN FY18MonthlySavings_v1 = .;
	 ELSE IF FY = 2018 THEN FY17MonthlySavings_v1 = .;
	 ELSE IF FY = 2019 THEN DO; FY17MonthlySavings_v1 = .; FY18MonthlySavings_v1 = .; END;

RUN;

DATA RMH_WNB_COSTPERUoS_v3;
	 SET RMH_WNB_COSTPERUoS_v2;
	 FORMAT FY17MonthlySavings_v1 FY18MonthlySavings_v1 8.;
	 FY17MonthlySavings_v1=(LAG26(CostPerUoS)-CostPerUoS)*SUM_of_STATS;
	 FY18MonthlySavings_v1=(LAG52(CostPerUoS)-CostPerUoS)*SUM_of_STATS;

	 IF FY = 2016 THEN DO; FY17MonthlySavings_v1 = .; FY18MonthlySavings_v1 = .; END;
	 ELSE IF FY = 2017 THEN FY18MonthlySavings_v1 = .;
	 ELSE IF FY = 2018 THEN FY17MonthlySavings_v1 = .;
	 ELSE IF FY = 2019 THEN DO; FY17MonthlySavings_v1 = .; FY18MonthlySavings_v1 = .; END;
RUN;

DATA RMH_LD_COSTPERUoS_v3;
	 SET RMH_LD_COSTPERUoS_v2;
     FORMAT FY17MonthlySavings_v1 FY18MonthlySavings_v1 8.;
	 FY17MonthlySavings_v1=(LAG26(CostPerUoS)-CostPerUoS)*SUM_of_STATS;
	 FY18MonthlySavings_v1=(LAG52(CostPerUoS)-CostPerUoS)*SUM_of_STATS;

	 IF FY = 2016 THEN DO; FY17MonthlySavings_v1 = .; FY18MonthlySavings_v1 = .; END;
	 ELSE IF FY = 2017 THEN FY18MonthlySavings_v1 = .;
	 ELSE IF FY = 2018 THEN FY17MonthlySavings_v1 = .;
	 ELSE IF FY = 2019 THEN DO; FY17MonthlySavings_v1 = .; FY18MonthlySavings_v1 = .; END;
RUN;
**/
PROC SQL;

	CREATE TABLE WORK.RMH_NURSING_COSTPERUOS_V1 AS 
	SELECT * FROM WORK.RMH_IPNURSING_COSTPERUOS_V2
	 OUTER UNION CORR 
	SELECT * FROM WORK.RMH_WNB_COSTPERUOS_V2
	 OUTER UNION CORR 
	SELECT * FROM WORK.RMH_LD_COSTPERUOS_V2
	ORDER BY BUSINESSUNIT, FunctionalGroupings, DeptID, PPDATE, FY, FY_Month;

	CREATE TABLE WORK.RMH_NURSING_COSTPERUOS_V2 AS 
    SELECT t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.FY, t1.FY_Month,
           t1.MONTH, t2.Baseline, 
		   CASE 
				WHEN t1.FY = 2016 THEN t2.Benefits_2016
				WHEN t1.FY = 2017 THEN t2.Benefits_2017
				WHEN t1.FY = 2018 THEN t2.Benefits_2018
				WHEN t1.FY = 2019 THEN t2.Benefits_2019
				WHEN t1.FY = 2020 THEN t2.Benefits_2019
			END AS Benefits,
           (SUM(t1.SUM_of_OTH_EARNS)) FORMAT=BEST12. AS SUM_of_OTH_EARNS, 
           (SUM(t1.SUM_of_OTH_HRS)) FORMAT=BEST12. AS SUM_of_OTH_HRS,
		   CASE 
				WHEN t1.FY <=2018 THEN 
		   			CASE  
		    			WHEN FY <= Baseline THEN (SUM(t1.SUM_of_OTH_EARNS))
						ELSE (SUM(t1.SUM_of_OTH_EARNS))*(0.972**(FY-Baseline))
					END
				/* ELSE (SUM(t1.SUM_of_OTH_EARNS))*(0.972) */
				WHEN T1.FY >= 2019 THEN (SUM(t1.SUM_of_OTH_EARNS))*(0.972)**(FY-2018) /* starting 2019 baseline=2018 */							

	       END AS SUM_of_OTH_EARNS_Adjusted, 
           (SUM(t1.SUM_of_STATS)) FORMAT=BEST12. AS SUM_of_STATS,
		   (CALCULATED SUM_of_OTH_EARNS)/(CALCULATED SUM_of_STATS) AS CostPerUoS_UnAdjusted,	 
		   (CALCULATED SUM_of_OTH_EARNS_Adjusted)/(CALCULATED SUM_of_STATS) AS CostPerUoS_Adjusted
    FROM WORK.RMH_NURSING_COSTPERUOS_V1 t1
	LEFT JOIN WORK.PRC_COSTCENTERGROUPS AS t2 ON (t1.BUSINESSUNIT = t2.Facility AND t1.FunctionalGroupings = t2.FunctionalGroupings AND t1.DeptID = t2.CostCenter)
    GROUP BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID,  t1.FY, t1.FY_Month,
          t1.MONTH, t2.Baseline, CALCULATED Benefits
	ORDER BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.FY, t1.FY_Month;

	CREATE TABLE WORK.RMH_NURSING_FY16_COSTPERUOS AS 
    SELECT t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.FY,
           (SUM(t1.SUM_of_OTH_EARNS)) FORMAT=BEST12. AS SUM_of_OTH_EARNS, 
           (SUM(t1.SUM_of_OTH_HRS)) FORMAT=BEST12. AS SUM_of_OTH_HRS, 
           (SUM(t1.SUM_of_STATS)) FORMAT=BEST12. AS SUM_of_STATS, 
		   (SUM(t1.SUM_of_OTH_EARNS))/(SUM(t1.SUM_of_STATS)) AS FY16_CostPerUoS
    FROM WORK.RMH_NURSING_COSTPERUOS_V1 t1
	WHERE t1.FY =2016 AND t1.SUM_of_OTH_EARNS > 0 AND t1.SUM_of_STATS > 0
    GROUP BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.FY
	ORDER BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.FY;

	CREATE TABLE WORK.RMH_NURSING_FY17_COSTPERUOS AS 
    SELECT t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.FY,
           (SUM(t1.SUM_of_OTH_EARNS)) FORMAT=BEST12. AS SUM_of_OTH_EARNS, 
           (SUM(t1.SUM_of_OTH_HRS)) FORMAT=BEST12. AS SUM_of_OTH_HRS,
           (SUM(t1.SUM_of_STATS)) FORMAT=BEST12. AS SUM_of_STATS, 
		   (SUM(t1.SUM_of_OTH_EARNS))/(SUM(t1.SUM_of_STATS)) AS FY17_CostPerUoS
    FROM WORK.RMH_NURSING_COSTPERUOS_V1 t1
	WHERE t1.FY =2017 AND t1.SUM_of_OTH_EARNS > 0 AND t1.SUM_of_STATS > 0
    GROUP BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.FY
	ORDER BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.FY;

	CREATE TABLE WORK.OBHSP_PERIOP_FY17_COSTPERUOS AS 
    SELECT t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.FY,
           (SUM(t1.SUM_of_OTH_EARNS)) FORMAT=BEST12. AS SUM_of_OTH_EARNS, 
           (SUM(t1.SUM_of_OTH_HRS)) FORMAT=BEST12. AS SUM_of_OTH_HRS,
           (SUM(t1.SUM_of_STATS)) FORMAT=BEST12. AS SUM_of_STATS, 
		   (SUM(t1.SUM_of_OTH_EARNS))/(SUM(t1.SUM_of_STATS)) AS OBHSP_PERIOP_CostPerUoS
    FROM WORK.RMH_NURSING_COSTPERUOS_V1 t1
	WHERE t1.FY =2017 AND t1.SUM_of_OTH_EARNS > 0 AND t1.SUM_of_STATS > 0 AND t1.PPdate 
		  BETWEEN '28JAN2017'd AND '17JUN2017'd AND UPCASE(t1.FunctionalGroupings) = "PERIOP" AND UPCASE(t1.BUSINESSUNIT) = "OBHSP" AND t1.DeptID = 25140 
    GROUP BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.FY
	ORDER BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.FY;

	CREATE TABLE WORK.REHAB_FY18_COSTPERUOS AS 
    SELECT t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.FY,
           (SUM(t1.SUM_of_OTH_EARNS)) FORMAT=BEST12. AS SUM_of_OTH_EARNS, 
           (SUM(t1.SUM_of_OTH_HRS)) FORMAT=BEST12. AS SUM_of_OTH_HRS,
           (SUM(t1.SUM_of_STATS)) FORMAT=BEST12. AS SUM_of_STATS, 
		   (SUM(t1.SUM_of_OTH_EARNS))/(SUM(t1.SUM_of_STATS)) AS Rehab_CostPerUoS
    FROM WORK.RMH_NURSING_COSTPERUOS_V1 t1
	WHERE t1.FY =2018 AND t1.PPdate in ('21OCT2017'd, '04NOV2017'd) AND UPCASE(t1.FunctionalGroupings) = "REHAB" AND t1.SUM_of_OTH_EARNS > 0 AND t1.SUM_of_STATS > 0
    GROUP BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.FY
	ORDER BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.FY;

	CREATE TABLE WORK.RMH_NURSING_FY18_COSTPERUOS AS 
    SELECT t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.FY,
           (SUM(t1.SUM_of_OTH_EARNS)) FORMAT=BEST12. AS SUM_of_OTH_EARNS, 
           (SUM(t1.SUM_of_OTH_HRS)) FORMAT=BEST12. AS SUM_of_OTH_HRS, 
           (SUM(t1.SUM_of_STATS)) FORMAT=BEST12. AS SUM_of_STATS, 
		   (SUM(t1.SUM_of_OTH_EARNS))/(SUM(t1.SUM_of_STATS)) AS FY18_CostPerUoS
    FROM WORK.RMH_NURSING_COSTPERUOS_V1 t1
	WHERE t1.FY =2018 AND t1.SUM_of_OTH_EARNS > 0 AND t1.SUM_of_STATS > 0
    GROUP BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.FY
	ORDER BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.FY;

	CREATE TABLE WORK.RMH_NURSING_COSTPERUOS_V3  AS
	SELECT t1.*, t2.Baseline, t2.CostCenterDescription, t1.Benefits, t8.TotalLaborCost AS FY19_LaborBudget, t8.Volume AS FY19_VolBudget,
	CASE 
		WHEN t1.FY <=2018 THEN 
			CASE 
				WHEN  t2.Baseline = 2016 THEN t3.FY16_CostPerUoS
				WHEN  t2.Baseline = 2017 AND UPCASE(t2.FunctionalGroupings) = "PERIOP" AND UPCASE(t1.BUSINESSUNIT) = "OBHSP" AND t1.DeptID = 25140  THEN t6.OBHSP_PERIOP_CostPerUoS
				WHEN  t2.Baseline = 2017 THEN t4.FY17_CostPerUoS
				WHEN  t2.Baseline = 2018 AND UPCASE(t2.FunctionalGroupings) = "REHAB" THEN t5.Rehab_CostPerUoS
			END
		WHEN t1.FY >= 2019 THEN /* to be changed when 2020 budget available */
			CASE 
				/** WHEN  t2.Baseline = 2018 AND UPCASE(t2.FunctionalGroupings) = "REHAB" THEN t5.Rehab_CostPerUoS **/
				WHEN t8.FY19_BudgetCostPerUoS IS NOT NULL THEN t8.FY19_BudgetCostPerUoS
				ELSE t7.FY18_CostPerUoS
			END
	END AS Target FORMAT 8.2,
	CASE 
		WHEN t1.FY <=2018 THEN CostPerUoS_Adjusted
		WHEN t1.FY = 2019 AND t8.FY19_BudgetCostPerUoS IS NULL THEN CostPerUoS_Adjusted
		WHEN t1.FY = 2019 AND t8.FY19_BudgetCostPerUoS IS NOT NULL THEN CostPerUoS_UnAdjusted
		WHEN t1.FY = 2020 THEN CostPerUoS_Adjusted /* To be changed when FY 2020  budget available */	
	END AS CostPerUoS FORMAT 8.2,
	t3.FY16_CostPerUoS AS FY16_Target FORMAT 8.2,
	t4.FY17_CostPerUoS AS FY17_Target FORMAT 8.2,
	t5.Rehab_CostPerUoS AS Rehab_Target FORMAT 8.2,
	t6.OBHSP_PERIOP_CostPerUoS AS OBHSP_PERIOP_CostPerUoS FORMAT 8.2,
	t7.FY18_CostPerUoS AS FY18_Target FORMAT 8.2, t8.FY19_BudgetCostPerUoS AS FY19_Target FORMAT 8.2,
	/**t1.CostPerUoS AS CostPerUoS_Adj FORMAT 8.2,
	((t3.FY16_CostPerUoS - t1.CostPerUoS)*t1.SUM_of_STATS) as MonthlySavings FORMAT 8., **/
    ((CALCULATED Target - CALCULATED CostPerUoS)*t1.SUM_of_STATS) AS MonthlySavings FORMAT 8.
	FROM WORK.RMH_NURSING_COSTPERUOS_V2 AS t1 
	LEFT JOIN WORK.PRC_COSTCENTERGROUPS AS t2 ON (t1.BUSINESSUNIT = t2.Facility AND t1.FunctionalGroupings = t2.FunctionalGroupings AND t1.DeptID = t2.CostCenter)
	LEFT JOIN WORK.RMH_NURSING_FY16_COSTPERUOS AS t3 ON (t1.BUSINESSUNIT = t3.BUSINESSUNIT AND t1.FunctionalGroupings = t3.FunctionalGroupings AND t1.DeptID = t3.DeptID)
	LEFT JOIN WORK.RMH_NURSING_FY17_COSTPERUOS AS t4 ON (t1.BUSINESSUNIT = t4.BUSINESSUNIT AND t1.FunctionalGroupings = t4.FunctionalGroupings AND t1.DeptID = t4.DeptID)
	LEFT JOIN WORK.REHAB_FY18_COSTPERUOS AS t5 ON (t1.BUSINESSUNIT = t5.BUSINESSUNIT AND t1.FunctionalGroupings = t5.FunctionalGroupings AND t1.DeptID = t5.DeptID)
	LEFT JOIN WORK.OBHSP_PERIOP_FY17_COSTPERUOS AS t6 ON (t1.BUSINESSUNIT = t6.BUSINESSUNIT AND t1.FunctionalGroupings = t6.FunctionalGroupings AND t1.DeptID = t6.DeptID)
	LEFT JOIN WORK.RMH_NURSING_FY18_COSTPERUOS AS t7 ON (t1.BUSINESSUNIT = t7.BUSINESSUNIT AND t1.FunctionalGroupings = t7.FunctionalGroupings AND t1.DeptID = t7.DeptID)
	LEFT JOIN WORK.FY19_Budget_ALL_v3 AS t8 ON (t1.BUSINESSUNIT = t8.Facility AND t1.DeptID = t8.CostCenter AND t1.FY = t8.FY AND t1.Month = t8.Month)
	ORDER BY t1.BUSINESSUNIT, t1.FunctionalGroupings, t1.DeptID, t1.FY, t1.FY_Month;

QUIT;
/**
DATA RMH_NURSING_COSTPERUOS_V4;
	SET RMH_NURSING_COSTPERUOS_V3;
	FORMAT FY17MonthlySavings FY18MonthlySavings FY19MonthlySavings 8. FY20MonthlySavings 8.; 

    FY17MonthlySavings = (LAG12(CostPerUoS)-CostPerUoS)*SUM_of_STATS; 
    FY18MonthlySavings = (LAG24(CostPerUoS)-CostPerUoS)*SUM_of_STATS; 
	FY19MonthlySavings = (LAG36(CostPerUoS)-CostPerUoS)*SUM_of_STATS; 
    FY20MonthlySavings = (LAG48(CostPerUoS)-CostPerUoS)*SUM_of_STATS; 
RUN;
**/

/*** Combine Fixed Depatment for few facility with RMH_NURSING_COSTPERUOS_V3 file ***/
PROC SQL;
	CREATE TABLE WORK.RMH_NURSING_COSTPERUOS_V3 AS 
	SELECT * FROM WORK.Imaging_FixedDept_Cost_v3
	 OUTER UNION CORR
	SELECT * FROM WORK.Periop_FixedDept_Cost_v3
	 OUTER UNION CORR 
	SELECT * FROM WORK.RMH_NURSING_COSTPERUOS_V3;
QUIT;
/*** End of Combine Fixed Depatment for few facility with RMH_NURSING_COSTPERUOS_V3 file ***/

DATA RMH_NURSING_COSTPERUOS_V4;
	SET RMH_NURSING_COSTPERUOS_V3;
	FORMAT MonthStartDate DATE9.;
	/**
	IF FY = 2016 THEN DO; MonthlySavings = .; END;
	ELSE IF FY = 2017 THEN DO; MonthlySavings = FY17MonthlySavings; END;
	ELSE IF FY = 2018 THEN DO; MonthlySavings = FY18MonthlySavings; END;
	ELSE IF FY = 2019 THEN DO; MonthlySavings = FY19MonthlySavings; END;
	ELSE IF FY = 2020 THEN DO; MonthlySavings = FY20MonthlySavings; END;
	**/
	IF MONTH IN (7, 8, 9, 10, 11, 12) THEN Year = FY - 1;
	ELSE Year = FY;

	MonthStartDate = MDY(Month, 1, Year);

	IF FY <= Baseline AND UPCASE(FunctionalGroupings) NE "REHAB" THEN MonthlySavings = 0;
	IF UPCASE(FunctionalGroupings) = "REHAB" AND MonthStartDate < '01NOV2017'd THEN MonthlySavings = 0;

	IF UPCASE(BusinessUnit) = "GTHSP" THEN DO;
		IF DeptID IN (25030, 25050, 25060) THEN BusinessUnit = "GTHSP B&J";
	END; 

	IF UPCASE(BusinessUnit) = "MNHSP" THEN DO;
		IF DeptID IN (25000, 25081, 25142, 82321) THEN BusinessUnit = "MNHSP AMB";
	END; 

RUN;

/*** Combine Manual Savings for few facility and cost center with RMH_NURSING_COSTPERUOS_V4 file ***/

PROC SQL;
	CREATE TABLE WORK.RMH_NURSING_COSTPERUOS_V4 AS 
	SELECT * FROM WORK.RMH_NURSING_COSTPERUOS_V4 (DROP=CostPerUoS_UnAdjusted CostPerUoS_Adjusted FY18_Target FY19_Target FY19_LaborBudget FY19_VolBudget)
	 OUTER UNION CORR 
	SELECT * FROM WORK.RVHSP32015_v2;
QUIT;

/*** End of Combine Manual Savings for few facility and cost center ***/

PROC SORT DATA=RMH_NURSING_COSTPERUOS_V4 OUT=RMH_NURSING_COSTPERUOS_V4;
	BY BusinessUnit FunctionalGroupings DeptID FY FY_MONTH;
	WHERE MonthStartDate < MDY( MONTH(TODAY()), 1, YEAR(TODAY()) ) AND FunctionalGroupings <> "EVS" ;
RUN;


PROC EXPORT DATA= WORK.RMH_NURSING_COSTPERUOS_V4
	OUTFILE= '/home/pxj479/Tasks/Output/RealizationTracker/RMH_NURSING_COSTPERUOS_V4.csv'
	DBMS=CSV REPLACE;
RUN;

PROC EXPORT DATA= WORK.RMH_NURSING_COSTPERUOS_V4
	OUTFILE= '/sharemnt/qliktest/RMH_NURSING_COSTPERUOS_V4.csv'
	DBMS=CSV REPLACE;
RUN;

PROC EXPORT DATA= WORK.RMH_NURSING_COSTPERUOS_V4
	/*OUTFILE= '/sharemnt/wrpqlik01-QA/RMH_NURSING_COSTPERUOS_V4.csv'*/
	OUTFILE= '/sharemnt/qlikprod02/QA/RMH_NURSING_COSTPERUOS_V4.csv'
	DBMS=CSV REPLACE;
RUN;

PROC EXPORT DATA= WORK.OH_Premium_v1
	OUTFILE= '/home/pxj479/Tasks/Output/RealizationTracker/OH_Premium_v1.csv'
	DBMS=CSV REPLACE;
RUN;

PROC EXPORT DATA= WORK.OH_Premium_v1
	OUTFILE= '/sharemnt/qliktest/OH_Premium_v1.csv'
	DBMS=CSV REPLACE;
RUN;

PROC EXPORT DATA= WORK.OH_Premium_v1
	/*OUTFILE= '/sharemnt/wrpqlik01-QA/OH_Premium_v1.csv'*/
	OUTFILE= '/sharemnt/qlikprod02/QA/OH_Premium_v1.csv'
	DBMS=CSV REPLACE;
RUN;


PROC EXPORT DATA= WORK.OH_STATS_v1
	OUTFILE= '/home/pxj479/Tasks/Output/RealizationTracker/OH_STATS_v1.csv'
	DBMS=CSV REPLACE;
RUN;

PROC EXPORT DATA= WORK.OH_STATS_v1
	OUTFILE= '/sharemnt/qliktest/OH_STATS_v1.csv'
	DBMS=CSV REPLACE;
RUN;

PROC EXPORT DATA= WORK.OH_STATS_v1
	/*OUTFILE= '/sharemnt/wrpqlik01-QA/OH_STATS_v1.csv'*/
	OUTFILE= '/sharemnt/qlikprod02/QA/OH_STATS_v1.csv'
	DBMS=CSV REPLACE;
RUN;

PROC EXPORT DATA= WORK.OH_PERIOP_RNTECH_V4
	OUTFILE= '/home/pxj479/Tasks/Output/RealizationTracker/OH_PERIOP_RNTECH_V4.csv'
	DBMS=CSV REPLACE;
RUN;

PROC EXPORT DATA= WORK.OH_PERIOP_RNTECH_V4
	OUTFILE= '/sharemnt/qliktest/OH_PERIOP_RNTECH_V4.csv'
	DBMS=CSV REPLACE;
RUN;

PROC EXPORT DATA= WORK.OH_PERIOP_RNTECH_V4
	/*OUTFILE= '/sharemnt/wrpqlik01-QA/OH_PERIOP_RNTECH_V4.csv'*/
	OUTFILE= '/sharemnt/qlikprod02/QA/OH_PERIOP_RNTECH_V4.csv'
	DBMS=CSV REPLACE;
RUN;


/**
PROC EXPORT DATA= SASHELP.BASEBALL
	OUTFILE= '/sharemnt/qliktest/BASEBALL.csv'
	DBMS=CSV REPLACE;
RUN;
**/


GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;
%LET _SASPROGRAMFILEHOST=;

;*';*";*/;quit;run;
ODS _ALL_ CLOSE;
