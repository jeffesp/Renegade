BEGIN;

CREATE TABLE people (
  id              INTEGER NOT NULL,
  first_name      TEXT NOT NULL,
  last_name       TEXT NOT NULL,
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

CREATE TABLE classes (
  id              INTEGER NOT NULL,
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
  PRIMARY KEY (student_id, roster_id),
  FOREIGN KEY (student_id) REFERENCES people (id),
  FOREIGN KEY (roster_id)  REFERENCES rosters (id)
);

CREATE TABLE locations (
  id              INTEGER NOT NULL,
  name            TEXT NOT NULL,
  description     TEXT NULL,
  create_date     DATETIME NOT NULL,
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
  person_id      INTEGER NOT NULL,
  FOREIGN KEY (meeting_id) REFERENCES meetings (id) ON DELETE CASCADE,
  FOREIGN KEY (person_id) REFERENCES people (id) ON DELETE CASCADE
);

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
