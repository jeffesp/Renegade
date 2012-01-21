BEGIN;

CREATE TABLE people (
  id              INTEGER NOT NULL,
  first_name      TEXT NOT NULL,
  last_name       TEXT NOT NULL,
  data            TEXT NULL,
  photo_id        INTEGER NULL,
  -- non input items
  person_type     INTEGER NOT NULL,
  create_date     DATETIME NOT NULL,
  delete_date     DATETIME NULL,
  PRIMARY KEY(id)
);

CREATE TABLE student_parents (
  student_id      INTEGER NOT NULL,
  parent_id       INTEGER NOT NULL,
  PRIMARY KEY (student_id, parent_id),
  FOREIGN KEY (student_id) REFERENCES people (id) ON DELETE CASCADE,
  FOREIGN KEY (parent_id)  REFERENCES people (id) ON DELETE CASCADE
);

CREATE TABLE photos (
  id              INTEGER NOT NULL,
  path            TEXT,
  PRIMARY KEY (id)
);

CREATE TABLE classes (
  id              INTEGER NOT NULL,
  short_name      TEXT NOT NULL,
  name            TEXT NOT NULL,
  PRIMARY KEY(id)
);

CREATE TABLE rosters (
  id              INTEGER NOT NULL,
  start_date      DATETIME NOT NULL,
  end_date        DATETIME NULL,
  class_id        INTEGER NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (class_id)  REFERENCES classes (id)
);

CREATE TABLE worker_roster (
  worker_id       INTEGER NOT NULL,
  roster_id       INTEGER NOT NULL,
  is_primary      BIT NOT NULL,
  PRIMARY KEY (worker_id, roster_id),
  FOREIGN KEY (worker_id) REFERENCES people (id),
  FOREIGN KEY (roster_id) REFERENCES rosters (id)
);

CREATE TABLE student_roster (
  student_id      INTEGER NOT NULL,
  roster_id       INTEGER NOT NULL,
  classification  INTEGER NOT NULL,
  PRIMARY KEY (student_id, roster_id),
  FOREIGN KEY (student_id) REFERENCES people (id),
  FOREIGN KEY (roster_id)  REFERENCES rosters (id)
  FOREIGN KEY (classification)  REFERENCES classifications (id)
);

CREATE TABLE classifications (
  id              INTEGER NOT NULL,
  abbreviation    TEXT NOT NULL,
  name            TEXT NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE locations (
  id              INTEGER NOT NULL,
  name            TEXT NOT NULL,
  description     TEXT NULL,
  create_date     DATETIME NOT NULL,
  delete_date     DATETIME NULL,
  PRIMARY KEY (id)
);

CREATE TABLE meetings (
  id              INTEGER NOT NULL,
  date            DATETIME NOT NULL,
  location_id     INTEGER NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (location_id) REFERENCES locations (id) ON DELETE CASCADE
);

CREATE TABLE meeting_attendance (
  meeting_id     INTEGER NOT NULL,
  class_id       INTEGER NOT NULL,
  person_id      INTEGER NOT NULL,
  FOREIGN KEY (class_id)   REFERENCES classes (id) ON DELETE CASCADE,
  FOREIGN KEY (meeting_id) REFERENCES meetings (id) ON DELETE CASCADE,
  FOREIGN KEY (person_id)  REFERENCES people (id) ON DELETE CASCADE
);

-- tables that support the application, not data used by the application
CREATE TABLE users (
  id              INTEGER NOT NULL,
  email_address   TEXT NOT NULL,
  password_hash   TEXT NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE roles (
  id              INTEGER NOT NULL,
  role_name       TEXT NOT NULL,
  is_active       BIT NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE users_roles (
  user_id         INTEGER NOT NULL,
  role_id         INTEGER NOT NULL,
  PRIMARY KEY (user_id, role_id)
  FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE CASCADE
);

COMMIT;

INSERT INTO classes (short_name, name) VALUES ('P-1', 'PreK-1st');
INSERT INTO classes (short_name, name) VALUES ('2-3', '2nd-3rd');
INSERT INTO classes (short_name, name) VALUES ('4-5', '4th-5th');
INSERT INTO classes (short_name, name) VALUES ('J-Hi', 'Jr. High');
INSERT INTO classifications (abbreviation, name) VALUES ('XT', 'Xenos Transfer');
INSERT INTO classifications (abbreviation, name) VALUES ('RN', 'Returning New');
INSERT INTO classifications (abbreviation, name) VALUES ('O', 'Original');
INSERT INTO classifications (abbreviation, name) VALUES ('FT', 'First Timer');
INSERT INTO classifications (abbreviation, name) VALUES ('VIS', 'Visitor');
INSERT INTO locations (name, description, create_date) VALUES ('JHi', 'Jr. High and below', date('now'));
INSERT INTO locations (name, description, create_date) VALUES ('Hi', 'High School', date('now'));
INSERT INTO locations (name, description, create_date) VALUES ('South', 'South Side', date('now'));

CREATE VIEW student AS SELECT id, first_name, last_name, create_date FROM people WHERE person_type = 1 AND delete_date IS NULL;
CREATE VIEW worker  AS SELECT id, first_name, last_name, create_date FROM people WHERE person_type = 2 AND delete_date IS NULL;
CREATE VIEW parent  AS SELECT id, first_name, last_name, create_date FROM people WHERE person_type = 3 AND delete_date IS NULL;
CREATE VIEW contact AS SELECT id, first_name, last_name, create_date FROM people WHERE person_type = 4 AND delete_date IS NULL;

