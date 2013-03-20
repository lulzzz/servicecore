﻿/* 
 * POSTGREQM - MARC-HI QUERY MANAGER
 * VERSION: 3.0
 * AUTHOR: JUSTIN FYFE
 * DATE: DECEMBER 30, 2010
 * FILES:
 *	QM.SQL		- SQL CODE TO CREATE TABLES, INDECIES, VIEWS AND SEQUENCES AND FUNCTIONS
 * DESCRIPTION:
 *	THIS FILE CLEANS AND THEN RE-CREATES THE POSTGRESQL QUERY MANAGER TABLES
 *	DATABASE SCHEMA INCLUDING TABLES, VIEWS, INDECIES, SEQUENCES AND FUNCTIONS. 
 * LICENSE:
 * 	Licensed under the Apache License, Version 2.0 (the "License");
 * 	you may not use this file except in compliance with the License.
 * 	You may obtain a copy of the License at
 *
 *     		http://www.apache.org/licenses/LICENSE-2.0
 *
 * 	Unless required by applicable law or agreed to in writing, software
 * 	distributed under the License is distributed on an "AS IS" BASIS,
 * 	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * 	See the License for the specific language governing permissions and
 * 	limitations under the License.
 *
 * REMARKS:
 *	THE SCHEMA THAT IS CREATED BY THIS FILE SHOULD NOT BE CONFUSED WITH THE
 *	SCHEMA FOR THE MESSAGE BOX SERVICE. THE MESSAGE BOX SERVICE SCHEMA IS
 *	INTENDED FOR NOT ONLY TRACKING REQUEST/RESPONSE PAIRS BUT FOR TRACKING
 *	THE RESPONSE TO QUEUED MODE OPERATIONS.
 */
--CREATE LANGUAGE PLPGSQL;

-- @TABLE
-- TABLE FOR THE STORAGE OF QUERIES
CREATE TABLE QRY_TBL
(
	QRY_ID		VARCHAR(128) NOT NULL, -- THE IDENTIFIER OF THE QUERY
	QRY_QTY		DECIMAL(4,0) NOT NULL, -- THE TOTAL QUANTITY OF RESULTS IN THE QUERY
	QRY_TAG		BYTEA NOT NULL, -- THE DOMAIN OF THE QUERY
	CRT_UTC		TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, -- THE TIME THAT THE QUERY WAS FIRST CREATED
	CONSTRAINT PK_QRY_TBL PRIMARY KEY (QRY_ID)
);	

-- @INDEX
-- THE MAJORITY OF QUERIES WILL BE REGISTERED WITH A DOMAIN AND QUERIED BY ID
-- CREATE UNIQUE INDEX QRY_TBL_IDX ON QRY_TBL(QRY_ID, QRY_TAG);

-- @SEQUENCE 
-- QUERY RESULTS SEQUENCE
CREATE SEQUENCE QRY_RSLT_SEQ START WITH 1 INCREMENT BY 1;

-- @TABLE
-- QUERY RESULTS TABLE
CREATE TABLE QRY_RSLT_TBL
(
	RSLT_ID		DECIMAL(20,0) NOT NULL DEFAULT nextval('QRY_RSLT_SEQ'), -- UNIQUE IDENTIFIER FOR THE RESULT
	ENT_ID		DECIMAL(20,0) NOT NULL, -- THE ENTERPRISE IDENTIFIER (THE QUERY READER SHOULD UNDERSTAND WHAT THIS IS)
	VRSN_ID		DECIMAL(20,0), -- THE VERSION ID
	RTR_UTC		TIMESTAMPTZ, -- THE TIME WHEN THE QUERY RESULT WAS RETRIEVED
	QRY_ID		VARCHAR(128) NOT NULL, -- THE ID OF THE QUERY TO WHICH THIS RESULT BELONGS
	CONSTRAINT PK_QRY_RSLT_TBL PRIMARY KEY (RSLT_ID),
	CONSTRAINT FK_QRY_RSLT_TBL FOREIGN KEY (QRY_ID) REFERENCES QRY_TBL(QRY_ID)
);

-- @INDEX
-- THE MAJORITY OF QUERY RESULTS WILL BE RETRIEVED USING THE QUERY ID
CREATE INDEX QRY_RSLT_QRY_ID_IDX ON QRY_RSLT_TBL(QRY_ID);

/*
 * FUNCTIONS
 */

-- @PROCEDURE
-- REGISTERS A QUERY WITH THE PERSISTANCE
CREATE OR REPLACE FUNCTION REG_QRY 
(
	QRY_ID_IN	IN VARCHAR(128),
	QRY_RSLT_CNT_IN	IN DECIMAL(4,0),
	QRY_TAG_IN	IN BYTEA
) RETURNS VOID AS
$$
BEGIN
	INSERT INTO QRY_TBL (QRY_ID, QRY_QTY, QRY_TAG) VALUES
		(QRY_ID_IN, QRY_RSLT_CNT_IN, QRY_TAG_IN);
	RETURN;
END
$$
LANGUAGE PLPGSQL;

-- @PROCEDURE
-- PUSH A QUERY RESULT INTO A RESULT SET
CREATE OR REPLACE FUNCTION PUSH_QRY_RSLT
(
	QRY_ID_IN	IN VARCHAR(128),
	RSLT_ENT_ID_IN	IN DECIMAL(20,0),
	RSLT_VRSN_ID_IN	IN DECIMAL(20,0)
) RETURNS VOID AS 
$$
BEGIN
	INSERT INTO QRY_RSLT_TBL (ENT_ID, QRY_ID, VRSN_ID)
		VALUES (RSLT_ENT_ID_IN, QRY_ID_IN, RSLT_VRSN_ID_IN);
	RETURN;
END
$$
LANGUAGE PLPGSQL;


-- @FUNCTION
-- POP THE SPECIFIED NUMBER OF RESULTS
-- RETURNS: SET OF DECIMALS
CREATE OR REPLACE FUNCTION GET_QRY_RSLTS
(
	QRY_ID_IN	IN VARCHAR(128),
	STR_IN		IN DECIMAL(4,0),
	QTY_IN		IN DECIMAL(4,0)
) RETURNS SETOF QRY_RSLT_TBL AS $$
DECLARE
	frst_rslt DECIMAL;
BEGIN

	IF(STR_IN > GET_QRY_CNT(QRY_ID_IN)) THEN
		RETURN QUERY SELECT * FROM QRY_RSLT_TBL WHERE TRUE = FALSE;
	END IF;
	
	-- GET THE FIRST RSLT_ID
	SELECT RSLT_ID INTO frst_rslt FROM
		(SELECT RSLT_ID FROM QRY_RSLT_TBL WHERE QRY_ID = QRY_ID_IN ORDER BY RSLT_ID ASC LIMIT STR_IN + 1) RSLTS
		ORDER BY RSLT_ID DESC
		LIMIT 1;
	
	-- QUERY FOR RESULTS
	RETURN QUERY SELECT * FROM QRY_RSLT_TBL 
			WHERE QRY_ID = QRY_ID_IN AND RSLT_ID >= frst_rslt 
			ORDER BY RSLT_ID ASC 
			LIMIT QTY_IN;
END
$$ 
LANGUAGE PLPGSQL;

-- @FUNCTION
-- GET THE NUMBER OF UN-POPPED RECORDS LEFT
CREATE OR REPLACE FUNCTION GET_QRY_CNT
(
	QRY_ID_IN	IN VARCHAR(128)
) RETURNS DECIMAL(4,0) AS
$$
BEGIN
	RETURN (SELECT QRY_QTY FROM QRY_TBL WHERE QRY_ID = QRY_ID_IN);
END
$$
LANGUAGE PLPGSQL;

-- @FUNCTION
-- DETERMINE IF THE QUERY HAS BEEN REGISTERED
CREATE OR REPLACE FUNCTION IS_QRY_REG
(
	QRY_ID_IN	IN VARCHAR(128)
) RETURNS BOOLEAN AS
$$
BEGIN
	RETURN (SELECT COUNT(*) FROM QRY_TBL WHERE QRY_ID = QRY_ID_IN);
END
$$
LANGUAGE PLPGSQL;

-- @FUNCTION
-- CLEAN STALE QUERIES
CREATE OR REPLACE FUNCTION QRY_CLN
(
	MAX_AGE_IN	IN VARCHAR(4)
) RETURNS VOID AS
$$
BEGIN
	DELETE FROM QRY_RSLT_TBL WHERE QRY_ID IN (SELECT QRY_ID FROM QRY_TBL WHERE CURRENT_TIMESTAMP - CRT_UTC > CAST(MAX_AGE_IN AS INTERVAL));
	DELETE FROM QRY_TBL WHERE CURRENT_TIMESTAMP - CRT_UTC > CAST(MAX_AGE_IN AS INTERVAL);
	RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION GET_QRY_TAG
(
	QRY_ID_IN	IN VARCHAR(128)
) RETURNS BYTEA AS
$$
BEGIN
	RETURN (SELECT QRY_TAG FROM QRY_TBL WHERE QRY_ID = QRY_ID_IN);
END;
$$ LANGUAGE plpgsql;