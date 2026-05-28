-- 1. Activités (Indépendante)
INSERT INTO public.activites (id, nom, description) VALUES
    ('FOOT', 'Football Club', 'Entraînement le mercredi après-midi'),
    ('THEA', 'Théâtre', 'Répétition pour la pièce de fin d''année'),
    ('MUSI', 'Conservatoire', 'Cours de solfège et instrument'),
    ('FOOT_923', 'Football', NULL),
    ('RUGB', 'Rugby', NULL),
    ('DANS', 'Danse', NULL),
    ('ECHE', 'Echecs', NULL),
    ('BASK', 'Basket', NULL),
    ('NATA', 'Natation', NULL),
    ('MUSI_676', 'Musique', NULL),
    ('GYM', 'Gym', NULL),
    ('VOLL', 'Volley', NULL),
    ('DESS', 'Dessin', NULL),
    ('JUDO', 'Judo', NULL),
    ('TENN', 'Tennis', NULL),
    ('CHOR', 'Chorale', NULL),
    ('ESCA', 'Escalade', NULL),
    ('BADM', 'Badminton', NULL),
    ('EQUI', 'Equitation', NULL),
    ('VTT', 'VTT', NULL),
    ('ATHL', 'Athlétisme', NULL),
    ('HAND', 'Handball', NULL),
    ('PIAN', 'Piano', NULL),
    ('BOXE', 'Boxe', NULL),
    ('VIOL', 'Violon', NULL);

-- 2. Chambres (Indépendante)
INSERT INTO public.chambres (id, numero, capacite, etage, bat, dispo) VALUES
    (1, 101, 3, 1, 'A', 3),
    (2, 102, 2, 1, 'A', 2),
    (3, 204, 4, 2, 'B', 4),
    (4, 305, 1, 3, 'C', 1);

-- 3. Classes (Indépendante)
INSERT INTO public.classes (id, nom, niveau, prof_principal, cpe_referent) VALUES
    (1, '2NDE-1', 'Seconde', 'M. Petit', NULL),
    (2, '1ERE-G', 'Premiere', 'Mme Durand', NULL),
    (3, 'TERM-S1', 'Terminale', 'M. Martin', NULL),
    (4, 'BTS-SIO1', 'BTS1', 'Mme Lefebvre', NULL),
    (5, '2NDE1', 'Seconde', NULL, NULL),
    (6, '1ERE2', 'Premiere', NULL, NULL),
    (7, 'TERM3', 'Terminale', NULL, NULL),
    (8, '2NDE2', 'Seconde', NULL, NULL),
    (9, 'CPGE1', 'CPGE', NULL, NULL),
    (10, '1ERE1', 'Premiere', NULL, NULL),
    (11, 'TERM1', 'Terminale', NULL, NULL),
    (12, '2NDE3', 'Seconde', NULL, NULL),
    (13, '1ERE3', 'Premiere', NULL, NULL),
    (14, 'TERM2', 'Terminale', NULL, NULL),
    (15, 'CPGE2', 'CPGE', NULL, NULL);

-- 4. Responsables (DÉPLACÉ ICI - Requis par la table élèves)
INSERT INTO public.responsables (id, nom, prenom, telephone, adresse) VALUES
    (1, 'Dupont', 'Jean-Pierre', '0476001122', '12 rue de la Paix, 38000 Grenoble'),
    (2, 'Leroy', 'Catherine', '0476334455', '5 Avenue Alsace, 38100 Grenoble'),
    (3, 'Moreau', 'Robert', '0476998877', '21 Place Victor Hugo, 38000 Grenoble'),
    (4, 'M.', 'Dupont', NULL, NULL),
    (5, 'Mme', 'Bernard', NULL, NULL),
    (6, 'M.', 'Robert', NULL, NULL),
    (7, 'M.', 'Richard', NULL, NULL),
    (8, 'M.', 'Lefebvre', NULL, NULL),
    (9, 'M.', 'Moreau', NULL, NULL),
    (10, 'M.', 'Laurent', NULL, NULL),
    (11, 'M.', 'Michel', NULL, NULL),
    (12, 'M.', 'David', NULL, NULL),
    (13, 'M.', 'Bertrand', NULL, NULL),
    (14, 'M.', 'Vincent', NULL, NULL),
    (15, 'M.', 'Fournier', NULL, NULL),
    (16, 'M.', 'Girard', NULL, NULL),
    (17, 'M.', 'Andre', NULL, NULL),
    (18, 'M.', 'Mercier', NULL, NULL),
    (19, 'M.', 'Dupuis', NULL, NULL),
    (20, 'M.', 'Bonnet', NULL, NULL),
    (21, 'M.', 'Francois', NULL, NULL),
    (22, 'M.', 'Legrand', NULL, NULL),
    (23, 'M.', 'Garnier', NULL, NULL);

-- 5. Élèves (Dépend de toutes les tables ci-dessus)
INSERT INTO public.eleves (id, nom, prenom, classe_id, adresse, genre, temps_transport, chambre_id, dimanche, referent_grenoble_id, dossier_cartone_transmis, dossier_complet, urgence_sociale, activite_id) VALUES
    (1, 'Martin', 'Lucas', 1, NULL, 'M', NULL, 1, false, 1, false, false, false, 'FOOT'),
    (2, 'Bernard', 'Chloé', 1, NULL, 'F', NULL, 1, false, 2, false, false, false, NULL),
    (3, 'Thomas', 'Enzo', 4, NULL, 'M', NULL, 3, false, 3, false, false, false, 'MUSI'),
    (4, 'Petit', 'Léa', 2, NULL, 'F', NULL, 2, false, 1, false, false, false, 'THEA'),
    (5, 'DUPONT', 'Jean', 5, '12 Rue des Lilas', 'M', '01:30:00', 1, true, 4, false, true, false, 'FOOT_923'),
    (6, 'MARTIN', 'Sophie', 6, NULL, 'F', NULL, 3, false, NULL, true, true, false, 'MUSI'),
    (7, 'BERNARD', 'Lucas', 7, '5 Avenue de la Gare', 'M', '02:00:00', 2, false, 5, true, false, true, 'RUGB'),
    (8, 'PETIT', 'Emma', 8, '8 Place du Marché', 'F', '00:45:00', NULL, true, NULL, false, false, false, 'DANS'),
    (9, 'ROBERT', 'Thomas', 9, '14 Bd Gambetta', 'M', '03:00:00', NULL, false, 6, true, true, false, 'ECHE'),
    (10, 'RICHARD', 'Léa', 10, NULL, 'F', '01:15:00', NULL, true, 7, true, true, false, NULL),
    (11, 'DURAND', 'Paul', 11, '22 Rue Victor Hugo', 'M', '01:00:00', NULL, false, NULL, false, true, false, 'BASK'),
    (12, 'LEFEBVRE', 'Chloé', 12, '3 Impasse des Roses', 'F', '00:30:00', NULL, true, 8, true, true, false, 'THEA'),
    (13, 'MOREAU', 'Antoine', 13, NULL, 'M', NULL, NULL, false, 9, false, false, false, 'NATA'),
    (14, 'SIMON', 'Camille', 14, '7 Rue de la Paix', 'F', '01:45:00', NULL, true, NULL, true, false, true, 'MUSI_676'),
    (15, 'LAURENT', 'Nicolas', 15, NULL, 'M', '02:30:00', NULL, false, 10, true, true, false, NULL),
    (16, 'MICHEL', 'Julie', 5, '10 Avenue Jean Jaurès', 'F', '01:20:00', NULL, true, 11, false, true, false, 'GYM'),
    (17, 'GARCIA', 'Louis', 6, '45 Rue de la République', 'M', '00:50:00', NULL, false, NULL, true, true, false, 'VOLL'),
    (18, 'DAVID', 'Sarah', 7, NULL, 'F', NULL, NULL, true, 12, false, false, false, 'DESS'),
    (19, 'BERTRAND', 'Alexandre', 8, '18 Rue Pasteur', 'M', '01:10:00', NULL, false, 13, true, true, true, 'JUDO'),
    (20, 'ROUX', 'Manon', 10, '9 Bd Voltaire', 'F', '01:55:00', NULL, true, NULL, false, true, false, NULL),
    (21, 'VINCENT', 'Maxime', 11, NULL, 'M', NULL, NULL, false, 14, false, true, false, 'TENN'),
    (22, 'FOURNIER', 'Alice', 12, '33 Rue de Lyon', 'F', '01:05:00', NULL, true, 15, true, true, false, 'CHOR'),
    (23, 'MOREL', 'Hugo', 9, NULL, 'M', NULL, NULL, false, NULL, false, true, false, 'ESCA'),
    (24, 'GIRARD', 'Mathilde', 13, '50 Avenue Foch', 'F', '01:15:00', NULL, true, 16, false, false, true, 'BADM'),
    (25, 'ANDRE', 'Enzo', 14, NULL, 'M', '01:25:00', NULL, false, 17, true, true, false, NULL),
    (26, 'LEFEVRE', 'Océane', 5, '11 Rue des Fleurs', 'F', '00:40:00', NULL, true, NULL, true, true, false, 'EQUI'),
    (27, 'MERCIER', 'Tom', 6, NULL, 'M', NULL, NULL, false, 18, false, true, false, 'VTT'),
    (28, 'DUPUIS', 'Lola', 7, '2 Rue du Moulin', 'F', '01:35:00', NULL, true, 19, false, true, true, 'ATHL'),
    (29, 'LAMBERT', 'Théo', 8, NULL, 'M', NULL, NULL, false, NULL, true, false, false, 'HAND'),
    (30, 'BONNET', 'Inès', 10, '6 Place de l''Eglise', 'F', '00:55:00', NULL, true, 20, true, true, false, 'PIAN'),
    (31, 'FRANCOIS', 'Raphaël', 11, NULL, 'M', NULL, NULL, false, 21, false, true, false, NULL),
    (32, 'MARTINEZ', 'Clara', 15, '29 Boulevard Carnot', 'F', '02:10:00', NULL, true, NULL, false, false, false, NULL),
    (33, 'LEGRAND', 'Arthur', 12, NULL, 'M', NULL, NULL, false, 22, true, true, false, 'BOXE'),
    (34, 'GARNIER', 'Lisa', 13, '15 Rue St Michel', 'F', '01:15:00', NULL, true, 23, true, false, true, 'VIOL');

-- 6. Incidents (Dépend de chambres)
INSERT INTO public.incidents (id, chambre_id, date_signalement, intervenant, date_resolution) VALUES
    (1, 1, '2024-03-20', 'Plombier - Fuite radiateur', NULL),
    (2, 3, '2024-03-21', 'Électricien - Ampoule HS', NULL);

-- 7. Repas prévus (Dépend de eleves)
INSERT INTO public.repas_prevus (id, eleve_id, jour_nom, type_repas_prevu, repas_exceptionnel) VALUES
    (1, 1, 'lundi', 'Chaud', NULL),
    (2, 1, 'mardi', 'Chaud', NULL),
    (3, 1, 'mercredi', 'Chaud', NULL),
    (4, 1, 'jeudi', 'Chaud', NULL),
    (5, 2, 'lundi', 'Chaud', NULL),
    (6, 2, 'mardi', 'Chaud', NULL),
    (7, 2, 'mercredi', 'Froid', NULL),
    (8, 3, 'mercredi', 'Chaud', NULL),
    (9, 3, 'jeudi', 'Chaud', NULL),
    (10, 4, 'lundi', 'Chaud', NULL),
    (11, 4, 'mercredi', 'Froid', NULL);

-- 8. Retours tardifs (Dépend de eleves)
INSERT INTO public.retours_tardifs (eleve_id, lundi_actif, mardi_actif, mercredi_actif, jeudi_actif, heure_lundi, heure_mardi, heure_mercredi, heure_jeudi) VALUES
    (1, true, true, true, true, '19:00:00', '19:00:00', '19:00:00', '19:00:00'),
    (2, true, true, true, false, '17:00:00', '17:00:00', '17:00:00', NULL),
    (3, false, false, true, true, NULL, NULL, '17:30:00', '17:30:00'),
    (4, true, false, true, false, '18:30:00', NULL, '18:30:00', NULL);

-- 9. Sequences
SELECT pg_catalog.setval('public.chambres_id_seq', 4, true);
SELECT pg_catalog.setval('public.classes_id_seq', 15, true);
SELECT pg_catalog.setval('public.eleves_id_seq', 34, true);
SELECT pg_catalog.setval('public.incidents_id_seq', 2, true);
SELECT pg_catalog.setval('public.repas_annulations_id_seq', 1, false);
SELECT pg_catalog.setval('public.repas_prevus_id_seq', 11, true);
SELECT pg_catalog.setval('public.responsables_id_seq', 23, true);