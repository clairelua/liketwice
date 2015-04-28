CREATE TABLE transactions 
(
	userid int NOT NULL,
	tx_type ENUM ('Purchase', 'Sale'),
	tx_time DATE,
	tx_amt int
);
CREATE INDEX userid_tx_type_index ON transactions (user_id, tx_type);