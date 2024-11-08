
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
CREATE DATABASE if not exists dkim171; -- create database dkim171
show DATABASES; -- list all databases
use dkim171; -- to use my database

-- 9. HiveQL code to create an external table “hvac”.
--/-----------------------------------------------------------------------------------/--
--/-------------------------------------CODE SQL--------------------------------------/--
DROP TABLE IF EXISTS hvac;
-- create the hvac table on comma-separated sensor data
CREATE EXTERNAL TABLE IF NOT EXISTS hvac(`date`     STRING, 
                                        `time`      STRING, 
                                        targettemp  BIGINT, 
                                        actualtemp  BIGINT, 
                                        system      BIGINT,
                                        systemage   BIGINT,
                                        buildingid  BIGINT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE LOCATION '/user/dkim171/SensorFiles/hvac'
TBLPROPERTIES ('skip.header.line.count'='1');
--/---------------------------------End CODE SQL--------------------------------------/--
--/-----------------------------------------------------------------------------------/--
show tables; -- list all tables in my database
select * from hvac limit 10; --  query the content of the hvac table
describe formatted hvac; -- to see and check the description of the table

-- 10. HiveQL code to create another external table “building”.
--/-----------------------------------------------------------------------------------/--
--/-------------------------------------CODE SQL--------------------------------------/--
DROP TABLE IF EXISTS building;
--create the building table on comma-separated building data
CREATE EXTERNAL TABLE IF NOT EXISTS building(buildingid BIGINT, 
                                             buildingmgr STRING,
                                             buildingage BIGINT,
                                             hvacproduct STRING,
                                             country STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE LOCATION '/user/dkim171/SensorFiles/building'
TBLPROPERTIES ('skip.header.line.count'='1');
--/---------------------------------End CODE SQL--------------------------------------/--
--/-----------------------------------------------------------------------------------/--
show tables; -- to check if building table created successfully
select * from building limit 10; -- select 10 rows from the table building and check
describe formatted building; -- building table information

--/-----------------------------------------------------------------------------------/--
-- 11. The following Hive queries create select temperatures from your HVAC data, looking for
    -- temperature variations (see the query below). Specifically, the difference between the target
    -- temperature the thermostat was set to and the recorded temperature. If the difference is greater
    -- than 5, the temp_diff column will be set to 'HOT',or 'COLD' and extremetemp will be set to 1;
    -- otherwise, temp_diff will be set to ‘NORMAL’ and extremetemp will be set to 0.
    -- The queries will write the results into two new tables: hvac_temperatures and hvac_building (see
    -- the CREATE TABLE statements below). The hvac_building table will contain building information
    -- such as the manager, building age, and the HVAC system for buildings, and will also be used to look
    -- up temperature data for the building through the JOIN with the hvac_temperatures table.
--/-----------------------------------------------------------------------------------/--
--/-------------------------------------CODE SQL--------------------------------------/--
DROP TABLE IF EXISTS hvac_temperatures;
--create the hvac_temperatures table by selecting from the hvac table
CREATE TABLE hvac_temperatures
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE LOCATION '/user/dkim171/SensorFiles/hvac_temperatures/'
AS
SELECT *, targettemp - actualtemp AS temp_diff,
IF((targettemp - actualtemp) > 5, 'COLD',
IF((targettemp - actualtemp) < -5, 'HOT', 'NORMAL')) AS temprange,
IF((targettemp - actualtemp) > 5, '1', 
IF((targettemp - actualtemp) < -5, '1', 0)) AS extremetemp
FROM hvac;
--/---------------------------------End CODE SQL--------------------------------------/--
--/-----------------------------------------------------------------------------------/--
show tables; -- to check if building table created successfully
select * from building limit 10; -- select 10 rows from the table building and check
describe formatted building; -- building table information
select targettemp, actualtemp, system, systemage, temp_diff, temprange, extremetemp from hvac_temperatures LIMIT 10;

--/-----------------------------------------------------------------------------------/--
--/-------------------------------------CODE SQL--------------------------------------/--
DROP TABLE IF EXISTS hvac_building;
--create the hvac_building table by joining the building table and the hvac_temperatures table
CREATE TABLE hvac_building
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE LOCATION '/user/dkim171/SensorFiles/hvac_building/'
AS SELECT h.*, b.country, b.hvacproduct, b.buildingage, b.buildingmgr
FROM building b JOIN hvac_temperatures h ON b.buildingid = h.buildingid;
--/----------------------------------------- END -------------------------------------/--
--/-----------------------------------------------------------------------------------/--
show tables; -- to check if building table created successfully

select targettemp, actualtemp, system, systemage, temp_diff,temprange, extremetemp, country, hvacproduct, buildingmgr 
from hvac_building LIMIT 10;; -- select 10 rows from the table building and check

describe formatted hvac_building; -- building table information

-- 12. To get out of beeline 
!exit

-- 13. Open another terminal with git bash, minty, Windows 10 cmd CLI, or putty, which is to connect
    -- the BIG DATA CLOUD to download the output file 000000_0 at the HDFS path
    -- “/user/dkim171/SensorFiles/hvac_building ”:
ssh dkim171@129.146.230.230
hdfs dfs -ls SensorFiles/hvac_building

hdfs dfs -get SensorFiles/hvac_building/000000_0 -- Download the file, 000000_0, to the local file systems
hdfs dfs -get SensorFiles/hvac_building/000001_0 -- Download the file, 000000_0, to the local file systems
ls -al -- check if the file was downloaded successfully
cat 000000_0 000001_0 > final_0 -- create new merged file with all data from both files

-- 14. Open another terminal with git bash, minty, or putty in order to read/import the output file
    -- using your lab computer (or your PC/Laptop) - you have to DOWNLOAD the file to your lab computer (or your PC/Laptop). 
scp dkim171@129.146.230.230:/home/dkim171/final_1 downloaded_final_1.csv .

--/----------------------------The end of the Lab 2-----------------------------------/-- 

--/-----------------------------------------------------------------------------------/-- 
--/--------------------------------------Lab3-----------------------------------------/-- 
--/-----------------------------------------------------------------------------------/-- 
-- In this sample you will use an Hive query that analyzes website log files to get insight into how
    -- customers use the website. With this analysis, you can see the frequency of visits to the website in a day
    -- from external websites, and a summary of website errors that the users experience.
    -- In this tutorial, you'll learn how to use APACHE HADOOP to:
        -- • Download website log files
        -- • Create Hive tables to query those logs
        -- • Create Hive queries to analyze the data
        -- • Use Microsoft Excel to connect to APACHE Hadoop (using an ODBC connection) to retrieve the analyzed data

-- 1. The ssh command to connect to the Hadoop Spark cluster. 
ssh dkim171@129.146.230.230

-- 2. download the data file Website Log Data (909f2b.log) from a github:
wget -O 909f2b.log https://github.com/dalgual/aidatasci/raw/master/data/bigdata/909f2b.log

-- 3. to upload “909f2b.log” file to SampleLog directory of HDFS:
hdfs dfs -mkdir SampleLog
hdfs dfs -ls
hdfs dfs -put 909f2b.log SampleLog/
hdfs dfs -ls SampleLog/

-- 4. open beeline
beeline
CREATE DATABASE if not exists dkim171;
show DATABASES; -- list all databases
use dkim171; -- to use my database
-- or 
create database dkim171;
use dkim171; -- to use my database

-- 5. create table weblogs
--/-------------------------------------CODE SQL--------------------------------------/--
DROP TABLE IF EXISTS weblogs;
--create table weblogs on space-delimited website log data
CREATE EXTERNAL TABLE IF NOT EXISTS weblogs(
    s_date date, 
    s_time string, 
    s_sitename string, 
    cs_method string, 
    cs_uristem string,
    cs_uriquery string, 
    s_port int, 
    cs_username string, 
    c_ip string, 
    cs_useragent string, 
    cs_cookie string, 
    cs_referer string, 
    cs_host string, 
    sc_status int, 
    sc_substatus int, 
    sc_win32status int, 
    sc_bytes int, cs_bytes int, 
    s_timetaken int)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ' '
STORED AS TEXTFILE LOCATION '/user/dkim171/SampleLog/'
TBLPROPERTIES ('skip.header.line.count'='2');
--/---------------------------------End CODE SQL--------------------------------------/--
-- 6. check new created table
show tables;

-- 7. check table select 10 rows
select * from weblogs LIMIT 10;

-- 8. describe weblogs table
describe formatted weblogs;

-- 9. create new table clientErrors
--/-------------------------------------CODE SQL--------------------------------------/--
DROP TABLE IF EXISTS ClientErrors;
--create table ClientErrors for storing errors users experienced
CREATE EXTERNAL TABLE ClientErrors(
    sc_status int, 
    cs_referer string, 
    cs_page string, 
    cnt int)
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
GROUP BY sc_status, cs_referer, 
concat(cs_uristem,'?', regexp_replace(cs_uriquery,'X-ARR-LOG-ID=[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}',''))
ORDER BY cnt;
--/---------------------------------End CODE SQL--------------------------------------/--
show tables; -- check new table
select * from ClientErrors ORDER BY CNT DESC LIMIT 10; -- select 10 rows from clienterrors
-- 10. describe ClientErrors table
describe formatted ClientErrors;

-- 11. The query for refersperday extracts data from the weblogs table for all external websites referencing
    -- this website. The external website information is extracted from the cs_referer column of weblogs table.
    -- To make sure the referring links did not encounter an error, the table only shows data for pages that
    -- returned an HTTP status code between 200 and 300. The extracted data is then written to
    -- the refersperday table.
--/-------------------------------------CODE SQL--------------------------------------/--
DROP TABLE IF EXISTS RefersPerDay;
--create table RefersPerDay for storing references from external URL
CREATE EXTERNAL TABLE IF NOT EXISTS RefersPerDay(
    year int, 
    month int,
    day int, 
    cs_referer string, 
    cnt int)
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
--/---------------------------------End CODE SQL--------------------------------------/--
show tables; -- check new table
select * from RefersPerDay ORDER BY CNT DESC LIMIT 10; -- select 10 rows from RefersPerDay
select year, month, cs_referer from refersperday LIMIT 10; -- select 10 rows from RefersPerDay with year and month, cs_referer
-- 12. describe RefersPerDay table
describe formatted RefersPerDay;

-- 13. run the following hdfs command at the /user/jwoo5/SampleLog:
    -- local linux terminal to find out weblogs file
hdfs dfs -ls /user/dkim171/SampleLog/ -- It will show the file 909f2b.log as a result. At your local linux terminal, run the following hdfs command:
hdfs dfs -ls /user/dkim171/RefersPerDay/ -- It will list 000000_0 file.

-- 14. Download the hdfs file of the result to your local and copy it to your lab computer; use your account name not dkim171:
hdfs dfs -get /user/dkim171/RefersPerDay/000000_0 log_result.out
cat log_result.out
-- 15. download or copy the output file to computer:
scp dkim171@129.146.230.230:/home/dkim171/log_result.out .
--/----------------------------The end of the Lab 3-----------------------------------/-- 


-- The `hdfs dfs -cat` command is used to display the contents of a file in HDFS. 
    -- Since the file "1091.log" is in your default HDFS directory, this command will show its contents.
hdfs dfs -cat 1091.log

--/-----------------------------------------------------------------------------------/-- 
--/--------------------------------------Lab4-----------------------------------------/-- 
--/-----------------------------------------------------------------------------------/-- 
-- 1. The ssh command to connect to the Hadoop Spark cluster. 
ssh dkim171@129.146.230.230


wget -O time_zone_map.tsv https://github.com/dalgual/aidatasci/raw/master/data/bigdata/time_zone_map.tsv
wget -O dictionary.tsv https://github.com/dalgual/aidatasci/raw/master/data/bigdata/dictionary.tsv
wget -O minion_tweets.tar.gz https://github.com/dalgual/aidatasci/raw/master/data/bigdata/minion_tweets.tar.gz


ls -al -- check if the file was downloaded successfully

tar -zxvf minion_tweets.tar.gz -- unzip minion_tweets.tar.gz

ls Tweets/

ls

hdfs dfs -mkdir tmp
hdfs dfs -mkdir tmp/tweets_staging
hdfs dfs -ls tmp
hdfs dfs -put Tweets/* tmp/tweets_staging     (*/)-- remove it 
hdfs dfs -ls tmp/tweets_staging

hdfs dfs -mkdir tmp/data
hdfs dfs -mkdir tmp/data/tables

hdfs dfs -mkdir tmp/data/tables/time_zone_map
hdfs dfs -mkdir tmp/data/tables/dictionary
hdfs dfs -ls tmp/data/tables

hdfs dfs -put time_zone_map.tsv tmp/data/tables/time_zone_map/
hdfs dfs -put dictionary.tsv tmp/data/tables/dictionary/
hdfs dfs -ls tmp/data/tables/time_zone_map/
hdfs dfs -ls tmp/data/tables/dictionary


use dkim171;
CREATE EXTERNAL TABLE IF NOT EXISTS raw_tweets(json_response STRING)
STORED AS TEXTFILE
LOCATION "/user/dkim171/tmp/tweets_staging";

show tables;

CREATE TABLE IF NOT EXISTS tweets_text (
id BIGINT,
created_at STRING,
created_at_date STRING,
created_at_year STRING,
created_at_month STRING,
created_at_day STRING,
created_at_time STRING,
text STRING,
time_zone STRING);

FROM raw_tweets
INSERT OVERWRITE TABLE tweets_text
SELECT CAST(get_json_object(json_response, '$.id_str') as BIGINT),
get_json_object(json_response, '$.created_at'),
CONCAT(SUBSTR (get_json_object(json_response, '$.created_at'),1,10),
' ',
SUBSTR (get_json_object(json_response, '$.created_at'),27,4)),
SUBSTR (get_json_object(json_response, '$.created_at'),27,4),
CASE SUBSTR (get_json_object(json_response, '$.created_at'),5,3)
WHEN 'Jan' then '01' WHEN 'Feb' then '02'
WHEN 'Mar' then '03' WHEN 'Apr' then '04'
WHEN 'May' then '05' WHEN 'Jun' then '06'
WHEN 'Jul' then '07' WHEN 'Aug' then '08'
WHEN 'Sep' then '09' WHEN 'Oct' then '10'
WHEN 'Nov' then '11' WHEN 'Dec' then '12'
end,
SUBSTR (get_json_object(json_response, '$.created_at'),9,2),
SUBSTR (get_json_object(json_response, '$.created_at'),12,8),
get_json_object(json_response, '$.text'),
get_json_object(json_response, '$.user.time_zone');

select * from raw_tweets LIMIT 1;
select * from tweets_text LIMIT 10;

describe formatted tweets_text;

DROP TABLE IF EXISTS time_zone_map;
CREATE EXTERNAL TABLE if not exists time_zone_map (
time_zone string,
country string,
notes string )
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '/user/dkim171/tmp/data/tables/time_zone_map'
TBLPROPERTIES ('skip.header.line.count'='1');

select * from time_zone_map LIMIT 10;


CREATE EXTERNAL TABLE if not exists dictionary (
type string,
length int,
word string,
pos string,
stemmed string,
polarity string )
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '/user/dkim171/tmp/data/tables/dictionary';
select * from dictionary LIMIT 10;


Drop View IF EXISTS tweets_simple;
CREATE VIEW IF NOT EXISTS tweets_simple AS
SELECT
id tweet_id,
cast ( from_unixtime( unix_timestamp(
concat( created_at_year, ' ', created_at_month, ' ',
substring(created_at,9,11)), 'yyyy MM dd hh:mm:ss'))
as timestamp) ts,
text msg,
time_zone
FROM tweets_text;

select * from tweets_simple LIMIT 10;

CREATE VIEW IF NOT EXISTS tweets_clean AS
SELECT
t.tweet_id,
t.ts,
t.msg,
m.country
FROM tweets_simple t LEFT OUTER JOIN
time_zone_map m ON t.time_zone = m.time_zone;

select * from tweets_clean LIMIT 10;


-- Create view l1 to compute sentiment
create view IF NOT EXISTS l1 as
select id, words
from tweets_text
lateral view explode(sentences(lower(text))) dummy as words;
-- Create view l2 from l1 to compute sentiment
create view IF NOT EXISTS l2 as
select id, word
from l1
lateral view explode( words ) dummy as word;
-- Create view l3 from l2 to compute sentiment
create view IF NOT EXISTS l3 as select
id tweet_id,
l2.word,
case d.polarity
when 'negative' then -1
when 'positive' then 1
else 0 end as polarity
from l2 left outer join dictionary d on l2.word = d.word;


create table IF NOT EXISTS tweets_sentiment
stored as orc as select
tweet_id,
case
when sum( polarity ) > 0 then 'positive'
when sum( polarity ) < 0 then 'negative'
else 'neutral' end as sentiment
from l3 group by tweet_id;

select * from tweets_sentiment LIMIT 3;

CREATE TABLE IF NOT EXISTS tweetsbi
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ","
STORED AS TEXTFILE
LOCATION "/user/dkim171/tmp/tweets_bi"
AS SELECT
t.*,
case s.sentiment
when 'positive' then 2
when 'neutral' then 1
when 'negative' then 0
end as sentiment
FROM tweets_clean t LEFT OUTER JOIN tweets_sentiment s
on t.tweet_id = s.tweet_id;

select * from tweetsbi LIMIT 3;

--/-----------------------------------------------------------------------------------/-- 
--/--------------------------------------Lab5-----------------------------------------/-- 
--/-----------------------------------------------------------------------------------/-- 
-- 1. The ssh command to connect to the Hadoop Spark cluster. 
ssh dkim171@129.146.230.230

CREATE EXTERNAL TABLE IF NOT EXISTS ratings (
posted TIMESTAMP,
cust_id INT,
prod_id INT,
rating TINYINT,
message STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
LOCATION '/user/dkim171/ratings'; -- entire path: /user/jwoo5/ratings


DESCRIBE ratings;

wget https://github.com/dalgual/aidatasci/raw/master/data/bigdata/ratings_2012.txt

hdfs dfs -mkdir ratings

-bash-4.2$ hdfs dfs -put ratings_2012.txt ratings/

-bash-4.2$ hdfs dfs -ls ratings/

wget https://github.com/dalgual/aidatasci/raw/master/data/bigdata/ratings_2013.txt

hdfs dfs -mkdir dualcore
hdfs dfs -ls

hdfs dfs -put ratings_2013.txt dualcore/

hdfs dfs -ls dualcore

LOAD DATA INPATH '/user/dkim171/dualcore/ratings_2013.txt' INTO TABLE ratings;

SELECT COUNT(*) FROM ratings;


--/-----------------------------------------------------------------------------------/-- 
--/------------------------------------- Lab5 part2 ----------------------------------/-- 
--/-----------------------------------------------------------------------------------/-- 

wget https://github.com/dalgual/aidatasci/raw/master/data/bigdata/products.tsv

hdfs dfs -mkdir products
hdfs dfs -put products.tsv products/
hdfs dfs -ls


DROP TABLE IF EXISTS products;
CREATE EXTERNAL TABLE products (
prod_id INT,
brand STRING,
name STRING,
price INT,
cost INT,
shipping_wt INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
LOCATION 'products';

DESCRIBE products;



select * from products LIMIT 2;

SELECT prod_id, FORMAT_NUMBER(avg_rating, 2) AS
avg_rating
    FROM (SELECT prod_id, AVG(rating) AS avg_rating,
        COUNT(*) AS num
        FROM ratings
        GROUP BY prod_id) rated
    WHERE num >= 50
    ORDER BY avg_rating DESC
LIMIT 1;


SELECT prod_id, FORMAT_NUMBER(avg_rating, 2) AS
avg_rating
    FROM (SELECT prod_id, AVG(rating) AS avg_rating,
        COUNT(*) AS num
        FROM ratings
        GROUP BY prod_id) rated
    WHERE num >= 50
    ORDER BY avg_rating ASC
LIMIT 1;


SELECT EXPLODE(NGRAMS(SENTENCES(LOWER(message)), 2, 5))
AS bigrams
FROM ratings
WHERE prod_id = 1274673;


SELECT message
FROM ratings
WHERE prod_id = 1274673
AND message LIKE '%ten times more%'
LIMIT 3;


SELECT DISTINCT message
FROM ratings
WHERE prod_id = 1274673 AND message LIKE '%red%';


SELECT * FROM products WHERE prod_id = 1274673;

SELECT *
FROM products
WHERE name LIKE '%16 GB USB Flash Drive%'
AND brand='"Orion"';


-- test 1-gram in context_ngrams
SELECT context_ngrams(sentences(LOWER(message)),
array(null, null), 10) AS onegram FROM ratings;

-- Add EXPLODE() function to make the result pretty
SELECT EXPLODE(context_ngrams(sentences(LOWER(message)),
array(null, null), 10)) AS onegram FROM ratings;

-- test 2-gram in context_ngrams
SELECT EXPLODE(context_ngrams(sentences(LOWER(message)),
array(null, null), 10)) AS bigram FROM ratings;


-- test 4-gram in context_ngrams that starts “red one”
SELECT EXPLODE(context_ngrams(sentences(lower(message)),
array("red", "one", null, null), 10)) AS snippet FROM
ratings;