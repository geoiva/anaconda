
-- SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";


--
-- table for emails (not currently used)
--

CREATE TABLE IF NOT EXISTS attachment (
  id serial PRIMARY KEY,
  filename varchar(255) DEFAULT NULL,
  filelink varchar(255) DEFAULT NULL,
  part integer DEFAULT NULL,
  emailid integer DEFAULT NULL);

--
-- Structure for table calibration
--

CREATE TYPE measure AS ENUM ('mm', 'cm', 'm');

CREATE TABLE IF NOT EXISTS calibration (
  id serial PRIMARY KEY,
  "timestamp" timestamp with time zone DEFAULT NULL,
  height real DEFAULT NULL,
  measure measure DEFAULT NULL,
  sensorid integer NOT NULL,
  yourname varchar(255) DEFAULT NULL,
  youremail varchar(255) DEFAULT NULL);
--  KEY fk_calibration_sensor1 (sensorid));

--
-- Structure for table catchment
--

CREATE TABLE IF NOT EXISTS catchments (
  id serial PRIMARY KEY,
  name varchar(255) NOT NULL,
  name_es varchar(255) DEFAULT NULL,
  name_ne varchar(255) DEFAULT NULL,
  description text NOT NULL,
  description_es text,
  description_ne text);

--
-- Structure for table email
--

CREATE TABLE IF NOT EXISTS email (
  id serial PRIMARY KEY,
  msgno integer DEFAULT NULL,
  sender varchar(255) DEFAULT NULL,
  senderemail varchar(255) DEFAULT NULL,
  sendermailbox varchar(255) DEFAULT NULL,
  senderhost varchar(255) DEFAULT NULL,
  subject varchar(255) DEFAULT NULL,
  body text,
  size integer DEFAULT NULL,
  extra text,
  creationdate timestamp DEFAULT NULL,
  online integer NOT NULL);

--
-- Table file
--

CREATE TABLE IF NOT EXISTS file (
  id serial PRIMARY KEY,
  filelink varchar(255) DEFAULT NULL,
  filename varchar(255) DEFAULT NULL,
  extension varchar(255) DEFAULT NULL,
  startdate date DEFAULT NULL,
  enddate date DEFAULT NULL,
  status varchar(255) DEFAULT NULL,
  sensorid integer NOT NULL);

--
-- Table migration
--

CREATE TABLE IF NOT EXISTS migration (
  version varchar(180) NOT NULL PRIMARY KEY,
  apply_time integer DEFAULT NULL);

--
--  Table profile
--

CREATE TABLE IF NOT EXISTS profile (
  id serial PRIMARY KEY,
  user_id integer NOT NULL,
  created_at timestamp NULL DEFAULT NULL,
  updated_at timestamp NULL DEFAULT NULL,
  full_name varchar(255) DEFAULT NULL);

--
-- Table role
--

CREATE TABLE IF NOT EXISTS role (
  id serial PRIMARY KEY,
  name varchar(255) NOT NULL,
  created_at timestamp NULL DEFAULT NULL,
  updated_at timestamp NULL DEFAULT NULL,
  can_admin integer NOT NULL DEFAULT '0');

CREATE TABLE locations (location_id serial,
                        location_name varchar(64),
                        CONSTRAINT pk_locations PRIMARY KEY (location_id));

--
-- Sensors table. Note: There are two tables that need to be merged eventually; "sensors" is inherited from the IMHEA system; "sensor" is from Webvillage
--

CREATE TABLE sensors (sensor_id serial,
                      sensor_name character varying(64),
                      lat real,
                      lon real,
                      location_id integer,   
                      catchment_id integer,       -- refers to a gauging location that closes the catchment
                      partner varchar(64),
		      timezone varchar(20),
                      CONSTRAINT pk_sensors PRIMARY KEY (sensor_id),
                      CONSTRAINT fk_catchment FOREIGN KEY (catchment_id) REFERENCES catchments,
                      CONSTRAINT fk_location FOREIGN KEY (location_id) REFERENCES locations);


CREATE TABLE IF NOT EXISTS sensor (
  id serial PRIMARY KEY,
  name varchar(255) DEFAULT NULL,
  catchmentid integer NOT NULL,
  latitude float DEFAULT NULL,
  longitude float DEFAULT NULL,
  sensortype varchar(255) DEFAULT NULL,
  units varchar(4) DEFAULT NULL,
  height float DEFAULT NULL,
  width float DEFAULT NULL,
  angle float DEFAULT NULL,
  property varchar(255) DEFAULT NULL,
  admin_email varchar(255) DEFAULT NULL
--  KEY fk_sensor_catchment1 (catchmentid)
);

--
-- Table user
--

CREATE TABLE IF NOT EXISTS "user" (
  id serial PRIMARY KEY,
  role_id integer NOT NULL,
  status integer NOT NULL,
  email varchar(255) DEFAULT NULL,
  username varchar(255) DEFAULT NULL,
  password varchar(255) DEFAULT NULL,
  auth_key varchar(255) DEFAULT NULL,
  access_token varchar(255) DEFAULT NULL,
  logged_in_ip varchar(255) DEFAULT NULL,
  logged_in_at timestamp NULL DEFAULT NULL,
  created_ip varchar(255) DEFAULT NULL,
  created_at timestamp NULL DEFAULT NULL,
  updated_at timestamp NULL DEFAULT NULL,
  banned_at timestamp NULL DEFAULT NULL,
  banned_reason varchar(255) DEFAULT NULL
--  UNIQUE KEY user_email (email),
--  UNIQUE KEY user_username (username),
--  KEY user_role_id (role_id)
);

--
-- Table user_auth
--

CREATE TABLE IF NOT EXISTS user_auth (
  id serial PRIMARY KEY,
  user_id integer NOT NULL,
  provider varchar(255) NOT NULL,
  provider_id varchar(255) NOT NULL,
  provider_attributes text NOT NULL,
  created_at timestamp NULL DEFAULT NULL,
  updated_at timestamp NULL DEFAULT NULL
--  KEY user_auth_provider_id (provider_id),
--  KEY user_auth_user_id (user_id)
);

--
-- Tabelstructuur voor tabel user_token
--

CREATE TABLE IF NOT EXISTS user_token (
  id serial PRIMARY KEY,
  user_id integer DEFAULT NULL,
  type integer NOT NULL,
  token varchar(255) NOT NULL,
  data varchar(255) DEFAULT NULL,
  created_at timestamp NULL DEFAULT NULL,
  expired_at timestamp NULL DEFAULT NULL
--  UNIQUE KEY user_token_token (token),
--  KEY user_token_user_id (user_id)
);

-- Other tables inherited from IMHEA


CREATE TABLE variables (var_id serial,
                        name varchar(20),
                        description varchar(64),
                        CONSTRAINT pk_var PRIMARY KEY (var_id));

CREATE TABLE units (unit_id serial,
                    name varchar(20),
		    regex varchar(20),
                    CONSTRAINT pk_units PRIMARY KEY (unit_id));

CREATE TABLE files (file_id serial,
                    path varchar(512),
                    mtime timestamp with time zone NOT NULL,
		    uploadstatus integer,
                    CONSTRAINT pk_file PRIMARY KEY (file_id));

CREATE TABLE observations (obs_id serial,
                           value numeric NOT NULL,
                           "timestamp" timestamp with time zone NOT NULL,
                           var_id integer,  
                           sensor_id integer,
			   unit_id integer,
                           file_id integer,
                           CONSTRAINT pk_obs PRIMARY KEY (obs_id),
                           CONSTRAINT fk_file FOREIGN KEY (file_id) REFERENCES files,
                           CONSTRAINT fk_sensors FOREIGN KEY (sensor_id) REFERENCES sensors,
                           CONSTRAINT fk_units FOREIGN KEY (unit_id) REFERENCES units,
                           CONSTRAINT fk_var FOREIGN KEY (var_id) REFERENCES variables);

CREATE TABLE uptime (uptime_id serial,
                     sensor_id integer,
                     "timestamp" timestamp with time zone NOT NULL,
                     switch boolean,
                     CONSTRAINT pk_uptime PRIMARY KEY (uptime_id),
                     CONSTRAINT fk_sensors FOREIGN KEY (sensor_id) REFERENCES sensors);


-- Constraints

ALTER TABLE attachment
  ADD CONSTRAINT attachment_ibfk_1 FOREIGN KEY (emailid) REFERENCES email (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE calibration
  ADD CONSTRAINT fk_calibration_sensor1 FOREIGN KEY (sensorid) REFERENCES sensor (id) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE file
  ADD CONSTRAINT fk_file_sensor1 FOREIGN KEY (sensorid) REFERENCES sensor (id) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE profile
  ADD CONSTRAINT profile_user_id FOREIGN KEY (user_id) REFERENCES "user" (id);

ALTER TABLE sensor
  ADD CONSTRAINT fk_sensor_catchment1 FOREIGN KEY (catchmentid) REFERENCES catchment (id) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE "user"
  ADD CONSTRAINT user_role_id FOREIGN KEY (role_id) REFERENCES role (id);

ALTER TABLE user_auth
  ADD CONSTRAINT user_auth_user_id FOREIGN KEY (user_id) REFERENCES "user" (id);

ALTER TABLE user_token
  ADD CONSTRAINT user_token_user_id FOREIGN KEY (user_id) REFERENCES "user" (id);


--indices

CREATE INDEX timestamp_idx_1 ON observations (timestamp) WHERE sensor_id=1;



