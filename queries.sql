#LTV per purchasing user
SELECT userid, SUM(tx_amt) FROM transactions WHERE tx_type = 'Purchase' GROUP BY userid ORDER BY SUM(tx_amt) DESC;

#LTV per selling user
SELECT userid, SUM(tx_amt) FROM transactions WHERE tx_type = 'Sale' GROUP BY userid ORDER BY SUM(tx_amt) DESC;

#ppl who buy and sell sells less than those who sell only. Because those who sell only are professional sellers
#ppl who buy and sell buys more than those who buys only because they are more active users
#ppl who sell only are professional merchants, they rarely buy.
#not doing cohort analysis. assume that all these users are 1 cohort. I can also put them into different buckets, and do a similar analysis on separate buckets
SELECT AVG(sale.amt) FROM (SELECT SUM(tx_amt) as amt FROM transactions WHERE tx_type = 'Sale' GROUP BY userid) AS sale;
SELECT AVG(sale.amt) FROM (SELECT SUM(tx_amt) as amt FROM transactions WHERE tx_type = 'Sale' AND userid IN (SELECT DISTINCT userid FROM transactions WHERE tx_type = 'Purchase') GROUP BY userid) AS sale;
SELECT AVG(purchase.amt) FROM (SELECT SUM(tx_amt) as amt FROM transactions WHERE tx_type = 'Purchase' GROUP BY userid) AS purchase;
SELECT AVG(purchase.amt) FROM (SELECT SUM(tx_amt) as amt FROM transactions WHERE tx_type = 'Purchase' AND userid IN (SELECT DISTINCT userid FROM transactions WHERE tx_type = 'Sale') GROUP BY userid) AS purchase;

#there is a data anomaly. there is a purchase 0, $0 in the data. Need to filter it out and also plot exponential R graph.
#when i did a drill down for 