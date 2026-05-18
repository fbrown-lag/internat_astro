CREATE VIEW public.v_annulations_actives AS
 SELECT e.nom,
    e.prenom,
    ra.mode,
    ra.jour_cible,
    ra.date_debut,
    ra.date_fin,
    ra.repas_force
   FROM (public.repas_annulations ra
     JOIN public.eleves e ON ((ra.eleve_id = e.id)))
  WHERE (((ra.mode = 'jour'::public.mode_annulation) AND (ra.est_traite = false)) OR ((ra.mode = 'periode'::public.mode_annulation) AND (CURRENT_DATE <= ra.date_fin)) OR ((ra.mode = 'hybride'::public.mode_annulation) AND (CURRENT_DATE <= ra.date_fin)));

CREATE VIEW public.v_liste_annulations AS
 SELECT ra.id AS annulation_id,
    e.nom,
    e.prenom,
    c.nom AS classe,
    ra.mode,
    ra.jour_cible,
    ra.date_debut,
    ra.date_fin,
    ra.repas_force,
    ra.created_at
   FROM ((public.repas_annulations ra
     JOIN public.eleves e ON ((ra.eleve_id = e.id)))
     LEFT JOIN public.classes c ON ((e.classe_id = c.id)))
  WHERE ((ra.est_traite = false) AND ((ra.date_fin >= CURRENT_DATE) OR (ra.date_fin IS NULL)))
  ORDER BY ra.date_debut;

CREATE VIEW public.v_liste_presences_jeudi AS
 SELECT e.id,
    e.nom,
    e.prenom,
    c.nom AS classe,
    ch.numero AS chambre,
    rt.heure_jeudi AS heure_prevue
   FROM (((public.eleves e
     JOIN public.retours_tardifs rt ON ((e.id = rt.eleve_id)))
     LEFT JOIN public.classes c ON ((e.classe_id = c.id)))
     LEFT JOIN public.chambres ch ON ((e.chambre_id = ch.id)))
  WHERE (rt.jeudi_actif = true)
  ORDER BY rt.heure_jeudi;

CREATE VIEW public.v_liste_presences_lundi AS
 SELECT e.id,
    e.nom,
    e.prenom,
    c.nom AS classe,
    ch.numero AS chambre,
    rt.heure_lundi AS heure_prevue
   FROM (((public.eleves e
     JOIN public.retours_tardifs rt ON ((e.id = rt.eleve_id)))
     LEFT JOIN public.classes c ON ((e.classe_id = c.id)))
     LEFT JOIN public.chambres ch ON ((e.chambre_id = ch.id)))
  WHERE (rt.lundi_actif = true)
  ORDER BY rt.heure_lundi;

CREATE VIEW public.v_liste_presences_mardi AS
 SELECT e.id,
    e.nom,
    e.prenom,
    c.nom AS classe,
    ch.numero AS chambre,
    rt.heure_mardi AS heure_prevue
   FROM (((public.eleves e
     JOIN public.retours_tardifs rt ON ((e.id = rt.eleve_id)))
     LEFT JOIN public.classes c ON ((e.classe_id = c.id)))
     LEFT JOIN public.chambres ch ON ((e.chambre_id = ch.id)))
  WHERE (rt.mardi_actif = true)
  ORDER BY rt.heure_mardi;

CREATE VIEW public.v_liste_presences_mercredi AS
 SELECT e.id,
    e.nom,
    e.prenom,
    c.nom AS classe,
    ch.numero AS chambre,
    rt.heure_mercredi AS heure_prevue
   FROM (((public.eleves e
     JOIN public.retours_tardifs rt ON ((e.id = rt.eleve_id)))
     LEFT JOIN public.classes c ON ((e.classe_id = c.id)))
     LEFT JOIN public.chambres ch ON ((e.chambre_id = ch.id)))
  WHERE (rt.mercredi_actif = true)
  ORDER BY rt.heure_mercredi;

CREATE VIEW public.v_repas_jeudi AS
 SELECT e.id,
    e.nom,
    e.prenom,
    c.nom AS classe,
    ch.numero AS numero_chambre,
    rt.heure_jeudi AS heure_retour,
    ( SELECT ra.id
           FROM public.repas_annulations ra
          WHERE ((ra.eleve_id = e.id) AND (ra.est_traite = false) AND (((ra.mode = 'jour'::public.mode_annulation) AND ((ra.jour_cible)::text = 'jeudi'::text)) OR ((ra.mode = 'periode'::public.mode_annulation) AND ((((CURRENT_DATE + (((((4 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date >= ra.date_debut) AND (((CURRENT_DATE + (((((4 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date <= ra.date_fin))) OR ((ra.mode = 'hybride'::public.mode_annulation) AND ((ra.jour_cible)::text = 'jeudi'::text) AND ((((CURRENT_DATE + (((((4 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date >= ra.date_debut) AND (((CURRENT_DATE + (((((4 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date <= ra.date_fin)))))
         LIMIT 1) AS annulation_id,
        CASE
            WHEN (EXISTS ( SELECT 1
               FROM public.repas_annulations ra
              WHERE ((ra.eleve_id = e.id) AND (ra.est_traite = false) AND (((ra.mode = 'jour'::public.mode_annulation) AND ((ra.jour_cible)::text = 'jeudi'::text)) OR ((ra.mode = 'periode'::public.mode_annulation) AND ((((CURRENT_DATE + (((((4 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date >= ra.date_debut) AND (((CURRENT_DATE + (((((4 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date <= ra.date_fin))) OR ((ra.mode = 'hybride'::public.mode_annulation) AND ((ra.jour_cible)::text = 'jeudi'::text) AND ((((CURRENT_DATE + (((((4 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date >= ra.date_debut) AND (((CURRENT_DATE + (((((4 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date <= ra.date_fin))))))) THEN 'None'::public.type_repas
            ELSE COALESCE(rp.repas_exceptionnel, rp.type_repas_prevu, 'None'::public.type_repas)
        END AS repas_final,
    ((rp.repas_exceptionnel IS NOT NULL) OR (EXISTS ( SELECT 1
           FROM public.repas_annulations ra
          WHERE ((ra.eleve_id = e.id) AND (ra.est_traite = false) AND (((ra.mode = 'jour'::public.mode_annulation) AND ((ra.jour_cible)::text = 'jeudi'::text)) OR ((ra.mode = 'periode'::public.mode_annulation) AND ((((CURRENT_DATE + (((((4 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date >= ra.date_debut) AND (((CURRENT_DATE + (((((4 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date <= ra.date_fin))) OR ((ra.mode = 'hybride'::public.mode_annulation) AND ((ra.jour_cible)::text = 'jeudi'::text) AND ((((CURRENT_DATE + (((((4 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date >= ra.date_debut) AND (((CURRENT_DATE + (((((4 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date <= ra.date_fin)))))))) AS a_modification
   FROM ((((public.eleves e
     JOIN public.retours_tardifs rt ON ((e.id = rt.eleve_id)))
     LEFT JOIN public.classes c ON ((e.classe_id = c.id)))
     LEFT JOIN public.chambres ch ON ((e.chambre_id = ch.id)))
     LEFT JOIN public.repas_prevus rp ON (((e.id = rp.eleve_id) AND ((rp.jour_nom)::text = 'jeudi'::text))))
  WHERE (rt.jeudi_actif = true);

CREATE VIEW public.v_repas_lundi AS
 SELECT e.id,
    e.nom,
    e.prenom,
    c.nom AS classe,
    ch.numero AS numero_chambre,
    rt.heure_lundi AS heure_retour,
    ( SELECT ra.id
           FROM public.repas_annulations ra
          WHERE ((ra.eleve_id = e.id) AND (ra.est_traite = false) AND (((ra.mode = 'jour'::public.mode_annulation) AND ((ra.jour_cible)::text = 'lundi'::text)) OR ((ra.mode = 'periode'::public.mode_annulation) AND ((((CURRENT_DATE + (((((1 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date >= ra.date_debut) AND (((CURRENT_DATE + (((((1 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date <= ra.date_fin))) OR ((ra.mode = 'hybride'::public.mode_annulation) AND ((ra.jour_cible)::text = 'lundi'::text) AND ((((CURRENT_DATE + (((((1 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date >= ra.date_debut) AND (((CURRENT_DATE + (((((1 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date <= ra.date_fin)))))
         LIMIT 1) AS annulation_id,
        CASE
            WHEN (EXISTS ( SELECT 1
               FROM public.repas_annulations ra
              WHERE ((ra.eleve_id = e.id) AND (ra.est_traite = false) AND (((ra.mode = 'jour'::public.mode_annulation) AND ((ra.jour_cible)::text = 'lundi'::text)) OR ((ra.mode = 'periode'::public.mode_annulation) AND ((((CURRENT_DATE + (((((1 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date >= ra.date_debut) AND (((CURRENT_DATE + (((((1 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date <= ra.date_fin))) OR ((ra.mode = 'hybride'::public.mode_annulation) AND ((ra.jour_cible)::text = 'lundi'::text) AND ((((CURRENT_DATE + (((((1 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date >= ra.date_debut) AND (((CURRENT_DATE + (((((1 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date <= ra.date_fin))))))) THEN 'None'::public.type_repas
            ELSE COALESCE(rp.repas_exceptionnel, rp.type_repas_prevu, 'None'::public.type_repas)
        END AS repas_final,
    ((rp.repas_exceptionnel IS NOT NULL) OR (EXISTS ( SELECT 1
           FROM public.repas_annulations ra
          WHERE ((ra.eleve_id = e.id) AND (ra.est_traite = false) AND (((ra.mode = 'jour'::public.mode_annulation) AND ((ra.jour_cible)::text = 'lundi'::text)) OR ((ra.mode = 'periode'::public.mode_annulation) AND ((((CURRENT_DATE + (((((1 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date >= ra.date_debut) AND (((CURRENT_DATE + (((((1 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date <= ra.date_fin))) OR ((ra.mode = 'hybride'::public.mode_annulation) AND ((ra.jour_cible)::text = 'lundi'::text) AND ((((CURRENT_DATE + (((((1 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date >= ra.date_debut) AND (((CURRENT_DATE + (((((1 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date <= ra.date_fin)))))))) AS a_modification
   FROM ((((public.eleves e
     JOIN public.retours_tardifs rt ON ((e.id = rt.eleve_id)))
     LEFT JOIN public.classes c ON ((e.classe_id = c.id)))
     LEFT JOIN public.chambres ch ON ((e.chambre_id = ch.id)))
     LEFT JOIN public.repas_prevus rp ON (((e.id = rp.eleve_id) AND ((rp.jour_nom)::text = 'lundi'::text))))
  WHERE (rt.lundi_actif = true);

CREATE VIEW public.v_repas_mardi AS
 SELECT e.id,
    e.nom,
    e.prenom,
    c.nom AS classe,
    ch.numero AS numero_chambre,
    rt.heure_mardi AS heure_retour,
    ( SELECT ra.id
           FROM public.repas_annulations ra
          WHERE ((ra.eleve_id = e.id) AND (ra.est_traite = false) AND (((ra.mode = 'jour'::public.mode_annulation) AND ((ra.jour_cible)::text = 'mardi'::text)) OR ((ra.mode = 'periode'::public.mode_annulation) AND ((((CURRENT_DATE + (((((2 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date >= ra.date_debut) AND (((CURRENT_DATE + (((((2 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date <= ra.date_fin))) OR ((ra.mode = 'hybride'::public.mode_annulation) AND ((ra.jour_cible)::text = 'mardi'::text) AND ((((CURRENT_DATE + (((((2 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date >= ra.date_debut) AND (((CURRENT_DATE + (((((2 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date <= ra.date_fin)))))
         LIMIT 1) AS annulation_id,
        CASE
            WHEN (EXISTS ( SELECT 1
               FROM public.repas_annulations ra
              WHERE ((ra.eleve_id = e.id) AND (ra.est_traite = false) AND (((ra.mode = 'jour'::public.mode_annulation) AND ((ra.jour_cible)::text = 'mardi'::text)) OR ((ra.mode = 'periode'::public.mode_annulation) AND ((((CURRENT_DATE + (((((2 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date >= ra.date_debut) AND (((CURRENT_DATE + (((((2 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date <= ra.date_fin))) OR ((ra.mode = 'hybride'::public.mode_annulation) AND ((ra.jour_cible)::text = 'mardi'::text) AND ((((CURRENT_DATE + (((((2 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date >= ra.date_debut) AND (((CURRENT_DATE + (((((2 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date <= ra.date_fin))))))) THEN 'None'::public.type_repas
            ELSE COALESCE(rp.repas_exceptionnel, rp.type_repas_prevu, 'None'::public.type_repas)
        END AS repas_final,
    ((rp.repas_exceptionnel IS NOT NULL) OR (EXISTS ( SELECT 1
           FROM public.repas_annulations ra
          WHERE ((ra.eleve_id = e.id) AND (ra.est_traite = false) AND (((ra.mode = 'jour'::public.mode_annulation) AND ((ra.jour_cible)::text = 'mardi'::text)) OR ((ra.mode = 'periode'::public.mode_annulation) AND ((((CURRENT_DATE + (((((2 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date >= ra.date_debut) AND (((CURRENT_DATE + (((((2 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date <= ra.date_fin))) OR ((ra.mode = 'hybride'::public.mode_annulation) AND ((ra.jour_cible)::text = 'mardi'::text) AND ((((CURRENT_DATE + (((((2 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date >= ra.date_debut) AND (((CURRENT_DATE + (((((2 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date <= ra.date_fin)))))))) AS a_modification
   FROM ((((public.eleves e
     JOIN public.retours_tardifs rt ON ((e.id = rt.eleve_id)))
     LEFT JOIN public.classes c ON ((e.classe_id = c.id)))
     LEFT JOIN public.chambres ch ON ((e.chambre_id = ch.id)))
     LEFT JOIN public.repas_prevus rp ON (((e.id = rp.eleve_id) AND ((rp.jour_nom)::text = 'mardi'::text))))
  WHERE (rt.mardi_actif = true);

CREATE VIEW public.v_repas_mercredi AS
 SELECT e.id,
    e.nom,
    e.prenom,
    c.nom AS classe,
    ch.numero AS numero_chambre,
    rt.heure_mercredi AS heure_retour,
    ( SELECT ra.id
           FROM public.repas_annulations ra
          WHERE ((ra.eleve_id = e.id) AND (ra.est_traite = false) AND (((ra.mode = 'jour'::public.mode_annulation) AND ((ra.jour_cible)::text = 'mercredi'::text)) OR ((ra.mode = 'periode'::public.mode_annulation) AND ((((CURRENT_DATE + (((((3 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date >= ra.date_debut) AND (((CURRENT_DATE + (((((3 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date <= ra.date_fin))) OR ((ra.mode = 'hybride'::public.mode_annulation) AND ((ra.jour_cible)::text = 'mercredi'::text) AND ((((CURRENT_DATE + (((((3 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date >= ra.date_debut) AND (((CURRENT_DATE + (((((3 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date <= ra.date_fin)))))
         LIMIT 1) AS annulation_id,
        CASE
            WHEN (EXISTS ( SELECT 1
               FROM public.repas_annulations ra
              WHERE ((ra.eleve_id = e.id) AND (ra.est_traite = false) AND (((ra.mode = 'jour'::public.mode_annulation) AND ((ra.jour_cible)::text = 'mercredi'::text)) OR ((ra.mode = 'periode'::public.mode_annulation) AND ((((CURRENT_DATE + (((((3 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date >= ra.date_debut) AND (((CURRENT_DATE + (((((3 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date <= ra.date_fin))) OR ((ra.mode = 'hybride'::public.mode_annulation) AND ((ra.jour_cible)::text = 'mercredi'::text) AND ((((CURRENT_DATE + (((((3 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date >= ra.date_debut) AND (((CURRENT_DATE + (((((3 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date <= ra.date_fin))))))) THEN 'None'::public.type_repas
            ELSE COALESCE(rp.repas_exceptionnel, rp.type_repas_prevu, 'None'::public.type_repas)
        END AS repas_final,
    ((rp.repas_exceptionnel IS NOT NULL) OR (EXISTS ( SELECT 1
           FROM public.repas_annulations ra
          WHERE ((ra.eleve_id = e.id) AND (ra.est_traite = false) AND (((ra.mode = 'jour'::public.mode_annulation) AND ((ra.jour_cible)::text = 'mercredi'::text)) OR ((ra.mode = 'periode'::public.mode_annulation) AND ((((CURRENT_DATE + (((((3 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date >= ra.date_debut) AND (((CURRENT_DATE + (((((3 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date <= ra.date_fin))) OR ((ra.mode = 'hybride'::public.mode_annulation) AND ((ra.jour_cible)::text = 'mercredi'::text) AND ((((CURRENT_DATE + (((((3 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date >= ra.date_debut) AND (((CURRENT_DATE + (((((3 - (EXTRACT(dow FROM CURRENT_DATE))::integer) + 7) % 7))::double precision * '1 day'::interval)))::date <= ra.date_fin)))))))) AS a_modification
   FROM ((((public.eleves e
     JOIN public.retours_tardifs rt ON ((e.id = rt.eleve_id)))
     LEFT JOIN public.classes c ON ((e.classe_id = c.id)))
     LEFT JOIN public.chambres ch ON ((e.chambre_id = ch.id)))
     LEFT JOIN public.repas_prevus rp ON (((e.id = rp.eleve_id) AND ((rp.jour_nom)::text = 'mercredi'::text))))
  WHERE (rt.mercredi_actif = true);

CREATE VIEW public.v_retours_tardifs_complet AS
 SELECT e.nom,
    e.prenom,
    c.nom AS classe,
    rt.lundi_actif,
    rt.heure_lundi,
    rt.mardi_actif,
    rt.heure_mardi,
    rt.mercredi_actif,
    rt.heure_mercredi,
    rt.jeudi_actif,
    rt.heure_jeudi
   FROM ((public.eleves e
     JOIN public.retours_tardifs rt ON ((e.id = rt.eleve_id)))
     LEFT JOIN public.classes c ON ((e.classe_id = c.id)));

CREATE VIEW public.v_stats_classes AS
 SELECT c.id,
    c.nom,
    c.niveau,
    c.prof_principal,
    c.cpe_referent,
    count(e.id) AS nombre_eleves
   FROM (public.classes c
     LEFT JOIN public.eleves e ON ((c.id = e.classe_id)))
  GROUP BY c.id, c.nom, c.niveau, c.prof_principal, c.cpe_referent;
