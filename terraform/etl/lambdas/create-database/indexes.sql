USE `biomirror`;

CREATE INDEX `index_uniprot` ON idmapping (`uniprot`);
CREATE INDEX `index_db` ON idmapping (`db`);
CREATE INDEX `index_external` ON idmapping (`external`);

