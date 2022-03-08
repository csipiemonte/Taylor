-- Popolamento della tabella "service_catalog_items" per l'ambiente di DEV
-- ATTENZIONE: perché abbia effetto, l'esecuzione dello script SQL deve essere seguita
-- da un deploy che inneschi i db:seeds (cfr. db/seeds/object_manager_attributes_csi.rb)

INSERT INTO "zammad"."service_catalog_items"
(id, name, crm, itsm, created_at, updated_at)
VALUES
(1,  '1L - Assistenza applicativa', 1, 1, NOW(), NOW()),
(2,  '1L - Gestione utenze applicative', 0, 1, NOW(), NOW()),
(3,  '1L - Malfunzionamento applicativo', 0, 1, NOW(), NOW()),
(4,  '1L - Problema Centralizzato Applicativo', 1, 0, NOW(), NOW()),
(5,  '1L - Trattamento dati', 1, 1, NOW(), NOW()),
(6,  '2L - Assistenza applicativa', 1, 1, NOW(), NOW()),
(7,  '2L - Malfunzionamento applicativo', 1, 1, NOW(), NOW()),
(8,  '2L - Manutenzione correttiva', 1, 1, NOW(), NOW()),
(9,  '2L - Trattamento dati', 1, 1, NOW(), NOW()),
(10, '1L - Dispatching applicativo', 1, 1, NOW(), NOW()),
(11, '1L - Gestione CUC', 1, 1, NOW(), NOW()),
(12, '1L - Informazioni Front Line', 1, 1, NOW(), NOW()),
(14, '1L - Gestione credenziali di accesso applicative', 1, 1, NOW(), NOW())
