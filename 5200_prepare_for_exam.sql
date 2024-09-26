
--/-----------------------------------------------------------------------------------/-- 
--/--------------------------------------Lab1-----------------------------------------/-- 
--/-----------------------------------------------------------------------------------/-- 
-- Apache Hadoop Big Data cluster is created by the user which is composed of 3 nodes
-- (Linux servers). The IP addresses are, for example, as follows – or shown in the
--      a. master and utility nodes
--      b. 3 slave nodes
--/--------------------------Fundamental Hadoop commands------------------------------/-- 
-- The ssh command to connect to the Hadoop Spark cluster. 
ssh dkim171@129.146.230.230
 -- then enter the password dkim171

-- Run commands to check whether the cluster has Hive and Spark (PySpark, Spark using Python).
which hive
which pyspark

-- Command to check date ($???)
date
-- “ls” is to list the files and directory (folder) of the current folder.
ls
-- “pwd” is Present Working Directory to display your current location (path) of your filesystems
pwd
-- “echo” is to display a line of text:
echo "Big Data"

-- You can use “echo” and “>” if you want to add some words to a file named test.txt. And, you can use
-- “cat” to display the content of the file:
echo "Adding first line" > test.txt
cat test.txt

-- If you want to COPY a file named test.txt from your Big Data server, to your PC, you have to run
--  another git bash terminal without runnung ssh.
-- dot at the end of the command is REQUIRED!!!
scp dkim171@129.146.230.230:/home/dkim171/test.txt .
-- to find file local on your computer enter the command
ls -al test.txt
-- LOGOUT from the Big Data Server enter
exit
--/----------------------------The end of the Lab 1-----------------------------------/-- 

--/-----------------------------------------------------------------------------------/-- 
--/--------------------------------------Lab2-----------------------------------------/-- 
--/-----------------------------------------------------------------------------------/-- 
-- In this lab You will analyze and visualize sensor data. Thus,
-- • You should learn how to download sensor data to the local systems in Amazon AWS Cloud.
-- • Then, you will learn how to upload it to HDFS.
-- • You will figure out how to manipulate and analyze sensor data in HDFS using HiveQL.
-- • You will also practice how to visualize the result in Excel.

-- 1. connect to the Big Data Server 
ssh dkim171@129.146.230.230
-- Run the following HDFS commands to test if hdfs works well at your Oracle account:
hdfs dfs -ls -- list all files
hdfs dfs -mkdir test

-- 2. to remove the file use the following command
rm <name of the file> 
rm test.txt

-- 3. to DOWNLOAD the data from the Amazon S3 into Oracle Big Data Server:
wget -O SensorFile.zip https://github.com/dalgual/aidatasci/raw/master/data/bigdata/SensorFiles.zip

-- 4. to unzip archive use the command:
unzip SensorFile.zip
ls SensorFile -- to see unzipped files

-- 5. To upload HVAC.csv and building.csv files to HDFS of the Hadoop cluster: 
hdfs dfs -mkdir SensorFiles -- create directory
hdfs dfs -mkdir SensorFiles/hvac -- create directory inside directory
hdfs dfs -mkdir SensorFiles/building -- create directory inside directory
hdfs dfs -ls -- to see the files
cd SensorFiles -- enter to the directory
hdfs dfs -put HVAC.csv SensorFiles/hvac -- put file to the location
hdfs dfs -put building.csv SensorFiles/building -- put file to the location
hdfs dfs -ls SensorFiles/hvac -- list files 
hdfs dfs -ls SensorFiles/building -- list files

-- 6. Creating Hive table to Query Sensor data
-- The following Hive statement creates an external table that allows Hive to query data stored in
-- HDFS. External tables preserve the data in the original file format, while allowing Hive to perform
-- queries against the data within the file.
-- The Hive statements below create two new tables, named hvac and building, by describing the
-- fields within the files, the delimiter (comma) between fields, and the location of the file in Azure
-- Blob Storage. This will allow you to create Hive queries over your data.

-- 7. Run the following HDFS command to make beeline command works
hdfs dfs -chmod -R o+w . -- 
hdfs dfs -ls -- list files on HDFS
beeline -- Open hive CLI (Command Line Shell Interface)

-- 8. to create your database with your username to separate your tables with other users
CREATE DATABASE if not exists dkim171
show DATABASES; -- list all databases
use dkim171; -- to use my database

-- 9. HiveQL code to create an external table “hvac”.
--/-----------------------------------------------------------------------------------/--
DROP TABLE IF EXISTS hvac;
-- create the hvac table on comma-separated sensor data
CREATE EXTERNAL TABLE IF NOT EXISTS hvac(`date` STRING, `time` STRING,
targettemp BIGINT,
actualtemp BIGINT,
system BIGINT,
systemage BIGINT,
buildingid BIGINT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE LOCATION '/user/dkim171/SensorFiles/hvac'
TBLPROPERTIES ('skip.header.line.count'='1');
--/-----------------------------------------------------------------------------------/--
show tables; -- list all tables in my database
select * from hvac limit 10; --  query the content of the hvac table
describe formatted hvac; -- to see and check the description of the table

-- 10. HiveQL code to create another external table “building”.
--/-----------------------------------------------------------------------------------/--
DROP TABLE IF EXISTS building;
--create the building table on comma-separated building data
CREATE EXTERNAL TABLE IF NOT EXISTS building(buildingid BIGINT, buildingmgr
STRING,
buildingage BIGINT,
hvacproduct STRING,
country STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE LOCATION '/user/dkim171/SensorFiles/building'
TBLPROPERTIES ('skip.header.line.count'='1');
--/-----------------------------------------------------------------------------------/--
show tables; -- to check if building table created successfully
select * from building limit 10; -- select 10 rows from the table building and check





JMv8bkUuB@JUq@9

 cat 000000_0 000001_0 > final_0


ssh dkim171@129.146.230.230
ls -al
hdfs dfs -ls

ls SensorFiles


CREATE DATABASE if not exists dkim171;
show DATABASES


 dfs –ls


DROP TABLE IF EXISTS building;
--create the building table on comma-separated building data
CREATE EXTERNAL TABLE IF NOT EXISTS building(buildingid BIGINT, buildingmgr
STRING,
    buildingage BIGINT,
    hvacproduct STRING,
    country STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE LOCATION '/user/dkim171/SensorFiles/building'
TBLPROPERTIES ('skip.header.line.count'='1');

https://bit.ly/30SD9NG



DROP TABLE IF EXISTS hvac;
--create the hvac table on comma-separated sensor data
CREATE EXTERNAL TABLE IF NOT EXISTS hvac(`date` STRING, `time` STRING,
targettemp BIGINT,
    actualtemp BIGINT,
    system BIGINT,
    systemage BIGINT,
    buildingid BIGINT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE LOCATION '/user/dkim171/SensorFiles/hvac'
TBLPROPERTIES ('skip.header.line.count'='1');
DROP TABLE IF EXISTS hvac_temperatures;
--create the hvac_temperatures table by selecting from the hvac table
CREATE TABLE hvac_temperatures
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE LOCATION '/user/dkim171/SensorFiles/hvac_temperatures/'
AS
SELECT *, targettemp - actualtemp AS temp_diff,
IF((targettemp - actualtemp) > 5, 'COLD',
IF((targettemp - actualtemp) < -5, 'HOT', 'NORMAL')) AS temprange,
IF((targettemp - actualtemp) > 5, '1', IF((targettemp - actualtemp) < -5,
'1', 0)) AS extremetemp
FROM hvac;


DROP TABLE IF EXISTS hvac_building;
--create the hvac_building table by joining the building table and the
hvac_temperatures table
CREATE TABLE hvac_building
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE LOCATION '/user/dkim171/SensorFiles/hvac_building/'
AS
SELECT h.*, b.country, b.hvacproduct, b.buildingage, b.buildingmgr
FROM building b JOIN hvac_temperatures h ON b.buildingid = h.buildingid;






DROP TABLE IF EXISTS hvac_temperatures;
--create the hvac_temperatures table by selecting from the hvac table
CREATE TABLE hvac_temperatures
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE LOCATION '/user/dkim171/SensorFiles/hvac_temperatures/'
AS
SELECT *, targettemp - actualtemp AS temp_diff,
IF((targettemp - actualtemp) > 5, 'COLD',
IF((targettemp - actualtemp) < -5, 'HOT', 'NORMAL')) AS temprange,
IF((targettemp - actualtemp) > 5, '1', IF((targettemp - actualtemp) < -5,
'1', 0)) AS extremetemp
FROM hvac;

DROP TABLE IF EXISTS hvac_building;
--create the hvac_building table by joining the building table and the
hvac_temperatures table
CREATE TABLE hvac_building
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE LOCATION '/user/dkim171/SensorFiles/hvac_building/'
AS
SELECT h.*, b.country, b.hvacproduct, b.buildingage, b.buildingmgr
FROM building b JOIN hvac_temperatures h ON b.buildingid = h.buildingid;


DROP TABLE IF EXISTS hvac_building;

CREATE TABLE hvac_building
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE LOCATION '/user/dkim171/SensorFiles/hvac_building/'
AS
SELECT h.*, b.country, b.hvacproduct, b.buildingage, b.buildingmgr
FROM building b JOIN hvac_temperatures h ON b.buildingid = h.buildingid;

scp dkim171@129.146.230.230:/home/dkim171/000000_0 000000_0.csv

-bash-4.1$ hdfs dfs -get SensorFiles/hvac_building/000000_0

scp dkim171@129.146.230.230:/Users/mityakim/Desktop/lab_2_5200/000000_0 000000_0.csv

/Users/mityakim/Desktop/lab_2_5200/


// lab 3
wget -O 909f2b.log https://github.com/dalgual/aidatasci/raw/master/data/bigdata/909f2b.log

hdfs dfs -mkdir SampleLog
hdfs dfs -ls
hdfs dfs -put 909f2b.log SampleLog/
hdfs dfs -ls SampleLog/

create database dkim171;
use dkim171;
show databases;

DROP TABLE IF EXISTS weblogs;
--create table weblogs on space-delimited website log data
CREATE EXTERNAL TABLE IF NOT EXISTS weblogs(s_date date, s_time
string, s_sitename string, cs_method string, cs_uristem string,
cs_uriquery string, s_port int, cs_username string, c_ip
string, cs_useragent string,
cs_cookie string, cs_referer string, cs_host string, sc_status
int, sc_substatus int,
sc_win32status int, sc_bytes int, cs_bytes int, s_timetaken
int )
ROW FORMAT DELIMITED FIELDS TERMINATED BY ' '
STORED AS TEXTFILE LOCATION '/user/dkim171/SampleLog/'
TBLPROPERTIES ('skip.header.line.count'='2');


describe formatted weblogs;

select * from weblogs LIMIT 10;




DROP TABLE IF EXISTS ClientErrors;
--create table ClientErrors for storing errors users experienced
CREATE EXTERNAL TABLE ClientErrors(sc_status int, cs_referer string,
cs_page string, cnt int)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE LOCATION '/user/dkim171/ClientErrors/' ;
--populate table ClientErrors with data from table weblogs
INSERT OVERWRITE TABLE ClientErrors
SELECT sc_status, cs_referer,
concat(cs_uristem,'?', regexp_replace(cs_uriquery,'X-ARR-LOG-ID=[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}',''))
cs_page,
count(distinct c_ip) as cnt
FROM weblogs
WHERE sc_status >=400 and sc_status < 500
GROUP BY sc_status, cs_referer, concat(cs_uristem,'?',
regexp_replace(cs_uriquery,'X-ARR-LOG-ID=[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}',''))
ORDER BY cnt;

describe formatted clienterrors;

select * from clienterrors ORDER BY CNT DESC LIMIT 10;




DROP TABLE IF EXISTS RefersPerDay;
--create table RefersPerDay for storing references from external URL
CREATE EXTERNAL TABLE IF NOT EXISTS RefersPerDay(year int, month int,
day int, cs_referer string, cnt int)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE LOCATION '/user/dkim171/RefersPerDay/';
--populate table RefersPerDay with data from the weblogs table
INSERT OVERWRITE TABLE RefersPerDay
SELECT year(s_date), month(s_date), day(s_date), cs_referer,
count(distinct c_ip) as cnt
FROM weblogs
WHERE sc_status >=200 and sc_status <300
GROUP BY s_date, cs_referer
ORDER BY cnt desc;

hdfs dfs -ls /user/dkim171/SampleLog/

hdfs dfs -ls /user/dkim171/RefersPerDay/

hdfs dfs -get /user/dkim171/RefersPerDay/000000_0 log_result.out

scp dkim171@129.146.230.230:/home/dkim171/log_result.out .
