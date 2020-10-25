CREATE ROLE ergonode LOGIN PASSWORD '123' CREATEDB;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "ltree";

CREATE DATABASE ergonode OWNER ergonode;
CREATE DATABASE ergonode_test OWNER ergonode;