﻿/* 
 * POSTGRESHR - MARC-HI SHARED SCHEMA FOR MESSAGE TRACKING
 * VERSION: 3.0
 * AUTHOR: JUSTIN FYFE
 * DATE: AUGUST 5, 2010
 * FILES:
 *	MTDB.SQL		- SQL CODE TO CREATE TABLES, INDECIES, VIEWS AND SEQUENCES AND FUNCTIONS
 * DESCRIPTION:
 *	THIS FILE CLEANS AND THEN RE-CREATES THE POSTGRESQL MESSAGE TRACKING
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

--ALTER DATABASE shr SET bytea_output='ESCAPE';
CREATE LANGUAGE plpgsql;
DROP TABLE MSG_TBL CASCADE;

 -- @TABLE
 -- MAIN MESSAGE STORAGE TABLE
 --
 -- REMARKS: RESPONSIBLE FOR THE STORAGE AND RETRIEVAL OF REQUESTS AND RESPONSES TO MESSAGES
 CREATE TABLE MSG_TBL
 (
	MSG_ID		VARCHAR(48) NOT NULL, -- GUID OF THE MESSAGE BEING STORED
	MSG_RSP_ID	VARCHAR(48), -- GUID OF THE MESSAGE ID THAT THIS MESSAGE RESPONDS TO
	MSG_UTC		TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, -- THE TIME THAT THE MESSAGE WAS CREATED IN THE DATABASE
	MSG_BODY	BYTEA NOT NULL, -- CONTENT OF THE ACTUAL MESSAGE
	CONSTRAINT PK_MSG_TBL PRIMARY KEY (MSG_ID),
	CONSTRAINT FK_MSG_RSP_ID_MSG_TBL FOREIGN KEY (MSG_RSP_ID) REFERENCES MSG_TBL(MSG_ID)
);

-- @INDEX 
-- LOOKUP BY RESPONSE ID SHOULD BE INDEXED
CREATE UNIQUE INDEX MSG_TBL_MSG_RSP_ID_IDX ON MSG_TBL(MSG_RSP_ID);

CREATE UNIQUE INDEX MSG_TBL_MSG_ID_IDX ON MSG_TBL(MSG_ID);

-- @LANGUAGE
-- PLPGSQL
--CREATE LANGUAGE PLPGSQL;

-- @PROCEDURE
-- REGISTER A MESSAGE WITH THE MTDB
CREATE OR REPLACE FUNCTION REG_MSG
(
	MSG_ID_IN	IN VARCHAR(48), -- ID OF THE MESSAGE BEING REGISTERED
	MSG_BODY_IN	IN BYTEA, -- BODY OF THE MESSAGE
	MSG_RSP_IN	IN VARCHAR(48) -- NOT NULL
) RETURNS VOID AS 
$$
BEGIN
	INSERT INTO MSG_TBL (MSG_ID, MSG_BODY) VALUES
		(MSG_ID_IN, MSG_BODY_IN);
	UPDATE MSG_TBL SET MSG_RSP_ID = MSG_ID_IN WHERE MSG_ID = MSG_RSP_IN;
	RETURN;
END;
$$ LANGUAGE plpgsql;

-- @FUNCTION
-- GET THE MESSAGE FROM THE DATABASE
CREATE OR REPLACE FUNCTION GET_MSG
(
	MSG_ID_IN	IN VARCHAR(48) -- THE ID OF THE MESSAGE FOR WHICH TO FETCH
) RETURNS BYTEA AS
$$
BEGIN
	RETURN (SELECT MSG_BODY FROM MSG_TBL WHERE MSG_ID = MSG_ID_IN);
END;
$$ LANGUAGE plpgsql;

-- @FUNCTION
-- GET THE RESPONSE MESSAGE FROM THE DATABASE
CREATE OR REPLACE FUNCTION GET_RSP_MSG
(
	MSG_ID_IN	IN VARCHAR(48) -- THE ID OF THE MESSAGE FOR WHICH TO FETCH
) RETURNS BYTEA AS
$$
DECLARE 
	MSG_RSP_ID_VAL	VARCHAR(48);
BEGIN
	SELECT MSG_RSP_ID INTO MSG_RSP_ID_VAL FROM MSG_TBL WHERE MSG_ID = MSG_ID_IN;
	RETURN (SELECT MSG_BODY FROM MSG_TBL WHERE MSG_ID = MSG_RSP_ID_VAL);
END;
$$ LANGUAGE plpgsql;

-- @FUNCTION
-- QUERY THE STATUS OF A MESSAGE
CREATE OR REPLACE FUNCTION QRY_MSG_STATE
(
	MSG_ID_IN	IN VARCHAR(48)
) RETURNS CHAR AS
$$
BEGIN
	RETURN COALESCE(
		(SELECT CASE WHEN MSG_RSP_ID IS NULL THEN 'A' ELSE 'C' END AS STAT FROM MSG_TBL WHERE MSG_ID = MSG_ID_IN), 
		'N'
	);
END;
$$ LANGUAGE plpgsql;