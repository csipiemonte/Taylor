-- Popolamento della tabella "service_catalog_sub_items" per l'ambiente di PROD
-- ATTENZIONE: perché abbia effetto, l'esecuzione dello script SQL deve essere seguita
-- da un deploy che inneschi i db:seeds (cfr. db/seeds/object_manager_attributes_csi.rb)

INSERT INTO "zammad"."service_catalog_sub_items"
(id, parent_service, name, crm, itsm, created_at, updated_at)
VALUES
(2, 1, 'Come utilizzare l''applicativo', 1, 1, NOW(), NOW()),
(3, 1, 'Assistenza specialistica', 1, 1, NOW(), NOW()),
(4, 1, 'Assistenza normativa e di materia', 1, 1, NOW(), NOW()),
(5, 1, 'Informazione sul Servizio', 1, 1, NOW(), NOW()),
(6, 1, 'Installazione applicativo', 1, 1, NOW(), NOW()),
(7, 1, 'Supporto esecuzione procedure', 1, 1, NOW(), NOW()),
(8, 1, 'Verifica configurazione', 1, 1, NOW(), NOW()),
(9, 1, 'Chiarimento sulla logica applicativa', 1, 1, NOW(), NOW()),
(10, 2, 'Abilitazione utenze all''applicativo', 0, 1, NOW(), NOW()),
(11, 2, 'Attivazione nuove credenziali', 0, 1, NOW(), NOW()),
(12, 2, 'Disabilitazione utenze dall''applicativo', 0, 1, NOW(), NOW()),
(13, 2, 'Disattivazione credenziali', 0, 1, NOW(), NOW()),
(14, 2, 'Manutenzione credenziali', 0, 1, NOW(), NOW()),
(15, 2, 'Modifica abilitazione sull''applicativo', 0, 1, NOW(), NOW()),
(16, 2, 'Verifica abilitazione sull''applicativo', 0, 1, NOW(), NOW()),
(17, 3, 'Accesso', 0, 1, NOW(), NOW()),
(18, 3, 'Applicazione soluzione bypass', 0, 1, NOW(), NOW()),
(19, 3, 'Cause esterne a CSI', 0, 1, NOW(), NOW()),
(20, 3, 'Errore Noto', 0, 1, NOW(), NOW()),
(21, 3, 'Funzionalità', 0, 1, NOW(), NOW()),
(22, 3, 'Infrastruttura', 0, 1, NOW(), NOW()),
(23, 3, 'Prestazioni', 0, 1, NOW(), NOW()),
(24, 4, 'Causa esterna', 1, 0, NOW(), NOW()),
(25, 4, 'Middleware', 1, 0, NOW(), NOW()),
(26, 4, 'Rete', 1, 0, NOW(), NOW()),
(27, 4, 'Server', 1, 0, NOW(), NOW()),
(28, 4, 'Software applicativo', 1, 0, NOW(), NOW()),
(29, 5, 'Correzione Dati Massiva', 1, 1, NOW(), NOW()),
(30, 5, 'Correzione Dati Puntuale', 1, 1, NOW(), NOW()),
(31, 5, 'Elaborazioni Dati', 1, 1, NOW(), NOW()),
(45, 10, 'Generico', 1, 1, NOW(), NOW()),
(46, 11, 'Numero Verde Reg. Piemonte', 1, 1, NOW(), NOW()),
(47, 12, 'Gestione contatti', 1, 1, NOW(), NOW()),
(49, 14, 'Manutenzione credenziali', 1, 1, NOW(), NOW())
