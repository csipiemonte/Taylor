-- Popolamento della tabella "service_catalog_sub_items" per l'ambiente di TEST (QA)
-- ATTENZIONE: perché abbia effetto, l'esecuzione dello script SQL deve essere seguita
-- da un deploy che inneschi i db:seeds (cfr. db/seeds/object_manager_attributes_csi.rb)

INSERT INTO "zammad"."service_catalog_sub_items"
(id, parent_service, name, created_at, updated_at)
VALUES
(1, 1, 'Assistenza normativa e di materia', NOW(), NOW()),
(2, 1, 'Assistenza specialistica', NOW(), NOW()),
(3, 1, 'Come utilizzare l''applicativo', NOW(), NOW()),
(4, 1, 'Informazione sul Servizio', NOW(), NOW()),
(5, 1, 'Installazione applicativo', NOW(), NOW()),
(6, 1, 'Supporto esecuzione procedure', NOW(), NOW()),
(7, 1, 'Verifica configurazione', NOW(), NOW()),
(8, 1, 'Chiarimento sulla logica applicativa', NOW(), NOW()),
(9, 2, 'Abilitazione utenze all''applicativo', NOW(), NOW()),
(10, 2, 'Attivazione nuove credenziali', NOW(), NOW()),
(11, 2, 'Disabilitazione utenze dall''applicativo', NOW(), NOW()),
(12, 2, 'Disattivazione credenziali', NOW(), NOW()),
(13, 2, 'Manutenzione credenziali', NOW(), NOW()),
(14, 2, 'Modifica abilitazione sull''applicativo', NOW(), NOW()),
(15, 2, 'Verifica abilitazione sull''applicativo', NOW(), NOW()),
(16, 3, 'Accesso', NOW(), NOW()),
(17, 3, 'Applicazione soluzione bypass', NOW(), NOW()),
(18, 3, 'Cause esterne a CSI', NOW(), NOW()),
(19, 3, 'Errore Noto', NOW(), NOW()),
(20, 3, 'Funzionalità', NOW(), NOW()),
(21, 3, 'Infrastruttura', NOW(), NOW()),
(22, 3, 'Prestazioni', NOW(), NOW()),
(23, 4, 'Causa esterna', NOW(), NOW()),
(24, 4, 'Middleware', NOW(), NOW()),
(25, 4, 'Rete', NOW(), NOW()),
(26, 4, 'Server', NOW(), NOW()),
(27, 4, 'Software applicativo', NOW(), NOW()),
(28, 5, 'Correzione Dati Massiva', NOW(), NOW()),
(29, 5, 'Correzione Dati Puntuale', NOW(), NOW()),
(30, 5, 'Elaborazioni Dati', NOW(), NOW()),
(31, 6, 'Assistenza normativa e di materia', NOW(), NOW()),
(32, 6, 'Assistenza specialistica', NOW(), NOW()),
(33, 6, 'Supporto esecuzione procedure', NOW(), NOW()),
(34, 7, 'Accesso', NOW(), NOW()),
(35, 7, 'Applicazione soluzione bypass', NOW(), NOW()),
(36, 7, 'Cause esterne a CSI', NOW(), NOW()),
(37, 7, 'Errore Noto', NOW(), NOW()),
(38, 7, 'Funzionalità', NOW(), NOW()),
(39, 7, 'Prestazioni', NOW(), NOW()),
(40, 8, 'Manutenzione correttiva', NOW(), NOW()),
(41, 9, 'Correzione Dati Massiva', NOW(), NOW()),
(42, 9, 'Correzione Dati Puntuale', NOW(), NOW()),
(43, 9, 'Elaborazioni Dati', NOW(), NOW()),
(44, 10, 'Generico', NOW(), NOW()),
(45, 11, 'Numero Verde Reg. Piemonte', NOW(), NOW()),
(46, 12, 'Gestione contatti', NOW(), NOW()),
(47, 13, 'Informazioni sul servizio', NOW(), NOW()),
(48, 14, 'Manutenzione credenziali', NOW(), NOW())
