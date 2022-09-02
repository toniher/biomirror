USE `biomirror`;

CREATE INDEX IF NOT EXISTS `index_uniprot` ON idmapping (`uniprot`);
CREATE INDEX IF NOT EXISTS `index_db` ON idmapping (`db`);
CREATE INDEX IF NOT EXISTS `index_external` ON idmapping (`external`);

