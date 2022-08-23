USE `biomirror`;

CREATE INDEX `index_uniprot` ON biomirror (`uniprot`);
CREATE INDEX `index_db` ON biomirror (`db`);
CREATE INDEX `index_external` ON biomirror (`external`);

