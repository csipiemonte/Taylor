-- Popolamento della tabella "assets" per gli ambienti di DEV e di TEST
-- cfr. Triplette_REMEDY-asset_id_CRM_v02.xlsx

INSERT INTO "zammad"."assets"
(id, asset_type, name, created_at, updated_at)
VALUES
(31, 'sw', 'Il mio medico - Scelta e revoca rivolta al cittadino', NOW(), NOW()),
(27, 'sw', 'AUTOCERTIFICAZIONE ESENZIONE PER REDDITO CITTADINI', NOW(), NOW()),
(24, 'sw', 'GESTIONE VACCINAZIONI CITTADINO', NOW(), NOW()),
(25, 'sw', 'GESTIONE CONSENSI E PREFERENZE CITTADINI', NOW(), NOW()),
(20, 'sw', 'ROL per cittadino', NOW(), NOW()),
(32, 'sw', 'SERVIZI PER LA STAMPA DEL PROMEMORIA', NOW(), NOW()),
(22, 'sw', 'Deleghe Cittadini Adulti', NOW(), NOW()),
(6, 'sw', 'Dematerializzazione buoni pazienti celiaci', NOW(), NOW()),
(14, 'sw', 'Gestione appuntamenti screening tumori femminili (cittadini)', NOW(), NOW()),
(11, 'sw', 'FSE per cittadino', NOW(), NOW()),
(16, 'sw', 'La Mia Salute', NOW(), NOW()),
(29, 'sw', 'COVID SOL CITTADINO', NOW(), NOW()),
(17, 'sw', 'Pagamento ticket via web', NOW(), NOW()),
(33, 'sw', 'AUTOCERTIFICAZIONE ESENZIONE PER PATOLOGIA CITTADINI', NOW(), NOW()),
(34, 'sw', 'Trova un', NOW(), NOW()),
(35, 'sw', 'FSE - Taccuino per cittadino', NOW(), NOW()),
(36, 'sw', 'SOL ESTRATTO CONTO TICKET SANITARI', NOW(), NOW())
