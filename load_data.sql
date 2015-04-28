LOAD DATA INFILE '/Users/jslua/Twice/txs.txt'
INTO TABLE transactions
COLUMNS TERMINATED BY ' '
(userid, tx_type, @tx_time, tx_amt)
SET
tx_time = DATE_FORMAT(@tx_time, '%Y/%m/%d')