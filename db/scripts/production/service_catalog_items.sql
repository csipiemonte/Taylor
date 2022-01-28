-- Popolamento della tabella "service_catalog_items" per l'ambiente di PROD
-- ATTENZIONE: perché abbia effetto, l'esecuzione dello script SQL deve essere seguita
-- da un deploy che inneschi i db:seeds (cfr. db/seeds/object_manager_attributes_csi.rb)

INSERT INTO "zammad"."service_catalog_items"
(id, name, created_at, updated_at)
VALUES
(1,  '1L - Assistenza applicativa', NOW(), NOW()),
(2,  '1L - Gestione utenze applicative', NOW(), NOW()),
(3,  '1L - Malfunzionamento applicativo', NOW(), NOW()),
(4,  '1L - Problema Centralizzato Applicativo', NOW(), NOW()),
(5,  '1L - Trattamento dati', NOW(), NOW()),
(6,  '2L - Assistenza applicativa', NOW(), NOW()),
(7,  '2L - Malfunzionamento applicativo', NOW(), NOW()),
(8,  '2L - Manutenzione correttiva', NOW(), NOW()),
(9,  '2L - Trattamento dati', NOW(), NOW()),
(10, '1L - Dispatching applicativo', NOW(), NOW())
