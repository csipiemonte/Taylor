-- Popolamento della tabella "assets" per gli ambienti di DEV e di TEST
-- cfr. Triplette_REMEDY-asset_id_CRM_v02.xlsx

INSERT INTO "zammad"."assets"
(id, asset_type, name, created_at, updated_at)
VALUES
(1, 'sw', 'Il mio medico - Scelta e revoca rivolta al cittadino', NOW(), NOW()),
(2, 'sw', 'AUTOCERTIFICAZIONE ESENZIONE PER REDDITO CITTADINI', NOW(), NOW()),
(3, 'sw', 'GESTIONE VACCINAZIONI CITTADINO', NOW(), NOW()),
(4, 'sw', 'GESTIONE CONSENSI E PREFERENZE CITTADINI', NOW(), NOW()),
(5, 'sw', 'ROL per cittadino', NOW(), NOW()),
(6, 'sw', 'SERVIZI PER LA STAMPA DEL PROMEMORIA', NOW(), NOW()),
(7, 'sw', 'Deleghe Cittadini Adulti', NOW(), NOW()),
(8, 'sw', 'Dematerializzazione buoni pazienti celiaci', NOW(), NOW()),
(9, 'sw', 'Gestione appuntamenti screening tumori femminili (cittadini)', NOW(), NOW()),
(11, 'sw', 'FSE per cittadino', NOW(), NOW()),
(12, 'sw', 'La Mia Salute', NOW(), NOW()),
(13, 'sw', 'COVID SOL CITTADINO', NOW(), NOW()),
(14, 'sw', 'Pagamento ticket via web', NOW(), NOW()),
(15, 'sw', 'AUTOCERTIFICAZIONE ESENZIONE PER PATOLOGIA CITTADINI', NOW(), NOW()),
(16, 'sw', 'Trova un', NOW(), NOW()),
(17, 'sw', 'FSE - Taccuino per cittadino', NOW(), NOW()),
(18, 'sw', 'SOL ESTRATTO CONTO TICKET SANITARI', NOW(), NOW())
