# SQL is not really fast for large data sets, however this data set is so small
# it is probably OK to just use SQL. The SQL databases I used is not really
# optimized and most of the queries completed within 10 secs. I guess that with
# some minor database tuning, these queries can be performed on data that are
# 10x larger.


CREATE INDEX userid_tx_time_index ON transactions (userid, tx_time);
CREATE INDEX userid_tx_type_index ON transactions (userid, tx_type);
CREATE INDEX userid_index ON transactions (userid);

# Query 1) Identify users who had both sold and purchased.
SELECT DISTINCT userid FROM transactions WHERE userid IN (
 SELECT DISTINCT userid FROM transactions WHERE tx_type = 'Purchase'
) AND userid IN (
 SELECT DISTINCT userid FROM transactions WHERE tx_type = 'Sale'
);

# Query 2) Calculate LTP of each user based on total sale amount during time period.
SELECT userid, SUM(tx_amt) FROM transactions WHERE tx_type = 'Sale' GROUP BY userid;

# Query 3) Calculate LTR of each user based on total purchase amount during time period.
SELECT userid, SUM(tx_amt) FROM transactions WHERE tx_type = 'Purchase' GROUP BY userid;



# Query 4) Calculate Average LTP by averaging total sale value .
SELECT AVG(amt) FROM (SELECT SUM(tx_amt) as amt FROM transactions WHERE tx_type = 'Sale' GROUP BY userid) AS sale;
# Query 5) Calculate Average LTP of users that are both seller and shopper.
SELECT AVG(amt) FROM (SELECT SUM(tx_amt) as amt FROM transactions WHERE tx_type = 'Sale' AND userid IN (SELECT DISTINCT userid FROM transactions WHERE tx_type = 'Purchase') GROUP BY userid) AS sale;
# Query 6) Calculate Average LTR by averaging total revenue value.
SELECT AVG(amt) FROM (SELECT SUM(tx_amt) as amt FROM transactions WHERE tx_type = 'Purchase' GROUP BY userid) AS purchase;
# Query 7) Average LTR of users that are both seller and buyer.
SELECT AVG(amt) FROM (SELECT SUM(tx_amt) as amt FROM transactions WHERE tx_type = 'Purchase' AND userid IN (SELECT DISTINCT userid FROM transactions WHERE tx_type = 'Sale') GROUP BY userid) AS purchase;

# Query 8) Select userid of users in Cohort 1 (2013Q1).
SELECT userid FROM (SELECT userid, MIN(tx_time) as min_time FROM transactions GROUP BY userid) as users WHERE min_time >= '2013-1-1' AND min_time < '2013-4-1';
# Query 9) Select userid of users in Cohort 2 (2013Q2).
SELECT userid FROM (SELECT userid, MIN(tx_time) as min_time FROM transactions GROUP BY userid) as users WHERE min_time >= '2013-4-1' AND min_time < '2013-6-1';
# Query 10) Select userid of users in Cohort 3 (2013Q3)
SELECT userid FROM (SELECT userid, MIN(tx_time) as min_time FROM transactions GROUP BY userid) as users WHERE min_time >= '2013-6-1' AND min_time < '2013-9-1';

# Query 11) Average LTP for Cohort 1 (2013Q1).
SELECT AVG(amt) FROM (SELECT SUM(tx_amt) as amt FROM transactions WHERE tx_type = 'Sale' AND userid IN (
  SELECT userid FROM (SELECT userid, MIN(tx_time) as min_time FROM transactions GROUP BY userid) as users WHERE min_time >= '2013-1-1' AND min_time < '2013-4-1'
) GROUP BY userid) AS sale;

# Query 12) Average LTP for Cohort 2 (2013Q2).
SELECT AVG(amt) FROM (SELECT SUM(tx_amt) as amt FROM transactions WHERE tx_type = 'Sale' AND userid IN (
  SELECT userid FROM (SELECT userid, MIN(tx_time) as min_time FROM transactions GROUP BY userid) as users WHERE min_time >= '2013-4-1' AND min_time < '2013-6-1'
) GROUP BY userid) AS sale;

# Query 13) Average LTP for Cohort 3.
SELECT AVG(amt) FROM (SELECT SUM(tx_amt) as amt FROM transactions WHERE tx_type = 'Sale' AND userid IN (
  SELECT userid FROM (SELECT userid, MIN(tx_time) as min_time FROM transactions GROUP BY userid) as users WHERE min_time >= '2013-6-1' AND min_time < '2013-9-1'
) GROUP BY userid) AS sale;

# For this cohort analysis, we should minus off n * 3 months from the cut off date to compare
# the same time frame, I got lazy so this was not done =/

# Query 14) Average LTR for Cohort 1 (2013Q1).
SELECT AVG(amt) FROM (SELECT SUM(tx_amt) as amt FROM transactions WHERE tx_type = 'Purchase' AND userid IN (
  SELECT userid FROM (SELECT userid, MIN(tx_time) as min_time FROM transactions GROUP BY userid) as users WHERE min_time >= '2013-1-1' AND min_time < '2013-4-1'
) GROUP BY userid) AS sale;

# Query 15) Average LTR for Cohort 2 (2013Q2).
SELECT AVG(amt) FROM (SELECT SUM(tx_amt) as amt FROM transactions WHERE tx_type = 'Purchase' AND userid IN (
  SELECT userid FROM (SELECT userid, MIN(tx_time) as min_time FROM transactions GROUP BY userid) as users WHERE min_time >= '2013-4-1' AND min_time < '2013-6-1'
) GROUP BY userid) AS sale;

# Query 16) Average LTR for Cohort 3 (2013Q3).
SELECT AVG(amt) FROM (SELECT SUM(tx_amt) as amt FROM transactions WHERE tx_type = 'Purchase' AND userid IN (
  SELECT userid FROM (SELECT userid, MIN(tx_time) as min_time FROM transactions GROUP BY userid) as users WHERE min_time >= '2013-6-1' AND min_time < '2013-9-1'
) GROUP BY userid) AS sale;

# Query 17) Purchase count of each shopper.
SELECT userid, COUNT(*) as purchase_count FROM transactions WHERE tx_type = 'Purchase' GROUP BY userid;

# Trendline data - Refer to LTR_predictions.xlsx
# userid, first purchase amount, purchase count, ltr
SELECT purchase_t.userid, purchase_t.tx_amt as first_amt, count_t.purchase_count, ltr_t.ltr FROM(
  SELECT userid, tx_time, tx_amt FROM transactions WHERE tx_type = 'Purchase'
) as purchase_t INNER JOIN(
  SELECT userid, min(tx_time) as min_time FROM transactions WHERE tx_type = 'Purchase' GROUP BY userid
) as first_t INNER JOIN (
    SELECT userid, COUNT(*) as purchase_count FROM transactions WHERE tx_type = 'Purchase' GROUP BY userid
) as count_t INNER JOIN (
  SELECT userid, SUM(tx_amt) as ltr FROM transactions WHERE tx_type = 'Purchase' GROUP BY userid
) as ltr_t ON
  first_t.userid = purchase_t.userid AND first_t.min_time = purchase_t.tx_time AND first_t.userid = count_t.userid AND purchase_t.userid = ltr_t.userid;

# Trendline data for cohort
SELECT purchase_t.userid, purchase_t.tx_amt as first_amt, count_t.purchase_count, ltr_t.ltr FROM(
  SELECT userid, tx_time, tx_amt FROM transactions WHERE tx_type = 'Purchase' AND userid IN (
    SELECT userid FROM (SELECT userid, MIN(tx_time) as min_time FROM transactions GROUP BY userid) as users WHERE min_time >= '2013-6-1' AND min_time < '2013-9-1'
  )
) as purchase_t INNER JOIN(
  SELECT userid, min(tx_time) as min_time FROM transactions WHERE tx_type = 'Purchase' GROUP BY userid
) as first_t INNER JOIN (
    SELECT userid, COUNT(*) as purchase_count FROM transactions WHERE tx_type = 'Purchase' GROUP BY userid
) as count_t INNER JOIN (
  SELECT userid, SUM(tx_amt) as ltr FROM transactions WHERE tx_type = 'Purchase' GROUP BY userid
) as ltr_t ON
  first_t.userid = purchase_t.userid AND first_t.min_time = purchase_t.tx_time AND first_t.userid = count_t.userid AND purchase_t.userid = ltr_t.userid;
