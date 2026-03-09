--
-- PostgreSQL database dump
--

\restrict WEUl7BTpggbhVgURuhP9591tGUZxRpO7Pekhc4TuYHFqO7xeKW0mqkFAOT12va6

-- Dumped from database version 17.7 (Ubuntu 17.7-0ubuntu0.25.04.1)
-- Dumped by pg_dump version 17.7 (Ubuntu 17.7-0ubuntu0.25.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


--
-- Name: mode_annulation; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.mode_annulation AS ENUM (
    'jour',
    'periode',
    'hybride'
);


ALTER TYPE public.mode_annulation OWNER TO postgres;

--
-- Name: type_genre; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.type_genre AS ENUM (
    'M',
    'F',
    'Autre'
);


ALTER TYPE public.type_genre OWNER TO postgres;

--
-- Name: type_niveau; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.type_niveau AS ENUM (
    'Seconde',
    'Premiere',
    'Terminale',
    'BTS1',
    'BTS2',
    'CPGE',
    'Autre'
);


ALTER TYPE public.type_niveau OWNER TO postgres;

--
-- Name: type_repas; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.type_repas AS ENUM (
    'Chaud',
    'Froid',
    'None'
);


ALTER TYPE public.type_repas OWNER TO postgres;

--
-- Name: clean_expired_annulations(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.clean_expired_annulations() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE repas_annulations
    SET est_traite = TRUE
    WHERE est_traite = FALSE
    AND (
        -- Cas 1 : Mode 'jour' et la date_fin (qui est le jour cible) est strictement avant aujourd'hui
        (mode = 'jour' AND date_fin < CURRENT_DATE)
        OR 
        -- Cas 2 : Mode 'periode' ou 'hybride' et la date_fin est strictement avant aujourd'hui
        ((mode = 'periode' OR mode = 'hybride') AND date_fin < CURRENT_DATE)
    );
END;
$$;


ALTER FUNCTION public.clean_expired_annulations() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activites (
    id character varying(50) NOT NULL,
    nom character varying(100) NOT NULL,
    description text
);


ALTER TABLE public.activites OWNER TO postgres;

--
-- Name: chambres; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chambres (
    id integer NOT NULL,
    numero integer NOT NULL,
    capacite integer,
    etage integer,
    bat character(1),
    dispo integer
);


ALTER TABLE public.chambres OWNER TO postgres;

--
-- Name: chambres_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chambres_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chambres_id_seq OWNER TO postgres;

--
-- Name: chambres_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chambres_id_seq OWNED BY public.chambres.id;


--
-- Name: classes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.classes (
    id integer NOT NULL,
    nom character varying(50) NOT NULL,
    niveau public.type_niveau NOT NULL,
    prof_principal character varying(100),
    cpe_referent character varying(100)
);


ALTER TABLE public.classes OWNER TO postgres;

--
-- Name: classes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.classes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.classes_id_seq OWNER TO postgres;

--
-- Name: classes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.classes_id_seq OWNED BY public.classes.id;


--
-- Name: démissionnaires; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."démissionnaires" (
    id integer NOT NULL,
    nom character varying(100) NOT NULL,
    prenom character varying(100) NOT NULL,
    adresse text,
    genre public.type_genre,
    dimanche boolean DEFAULT false,
    dossier_complet boolean DEFAULT false,
    urgence_sociale boolean DEFAULT false,
    dossier_cartone_transmis boolean DEFAULT false,
    classe_id integer,
    chambre_id integer,
    referent_grenoble_id integer,
    retours_tardifs_backup jsonb,
    repas_prevus_backup jsonb
);


ALTER TABLE public."démissionnaires" OWNER TO postgres;

--
-- Name: eleves; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.eleves (
    id integer NOT NULL,
    nom character varying(100) NOT NULL,
    prenom character varying(100) NOT NULL,
    classe_id integer,
    adresse text,
    genre public.type_genre,
    temps_transport time without time zone,
    chambre_id integer,
    dimanche boolean DEFAULT false,
    referent_grenoble_id integer,
    dossier_cartone_transmis boolean DEFAULT false,
    dossier_complet boolean DEFAULT false,
    urgence_sociale boolean DEFAULT false,
    activite_id character varying(50)
);


ALTER TABLE public.eleves OWNER TO postgres;

--
-- Name: eleves_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.eleves_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.eleves_id_seq OWNER TO postgres;

--
-- Name: eleves_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.eleves_id_seq OWNED BY public.eleves.id;


--
-- Name: incidents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.incidents (
    id integer NOT NULL,
    chambre_id integer,
    date_signalement date DEFAULT CURRENT_DATE,
    intervenant character varying(100),
    date_resolution date
);


ALTER TABLE public.incidents OWNER TO postgres;

--
-- Name: incidents_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.incidents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.incidents_id_seq OWNER TO postgres;

--
-- Name: incidents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.incidents_id_seq OWNED BY public.incidents.id;


--
-- Name: repas_annulations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.repas_annulations (
    id integer NOT NULL,
    eleve_id integer,
    mode public.mode_annulation NOT NULL,
    jour_cible character varying(10),
    est_traite boolean DEFAULT false,
    date_debut date,
    date_fin date,
    repas_force public.type_repas DEFAULT 'None'::public.type_repas,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_mode_data CHECK ((((mode = 'jour'::public.mode_annulation) AND (jour_cible IS NOT NULL)) OR ((mode = 'periode'::public.mode_annulation) AND (date_debut IS NOT NULL) AND (date_fin IS NOT NULL)) OR ((mode = 'hybride'::public.mode_annulation) AND (jour_cible IS NOT NULL) AND (date_debut IS NOT NULL) AND (date_fin IS NOT NULL))))
);


ALTER TABLE public.repas_annulations OWNER TO postgres;

--
-- Name: repas_annulations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.repas_annulations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.repas_annulations_id_seq OWNER TO postgres;

--
-- Name: repas_annulations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.repas_annulations_id_seq OWNED BY public.repas_annulations.id;


--
-- Name: repas_prevus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.repas_prevus (
    id integer NOT NULL,
    eleve_id integer,
    jour_nom character varying(10) NOT NULL,
    type_repas_prevu public.type_repas DEFAULT 'Chaud'::public.type_repas NOT NULL,
    repas_exceptionnel public.type_repas
);


ALTER TABLE public.repas_prevus OWNER TO postgres;

--
-- Name: repas_prevus_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.repas_prevus_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.repas_prevus_id_seq OWNER TO postgres;

--
-- Name: repas_prevus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.repas_prevus_id_seq OWNED BY public.repas_prevus.id;


--
-- Name: responsables; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.responsables (
    id integer NOT NULL,
    nom character varying(100) NOT NULL,
    prenom character varying(100),
    telephone character varying(20),
    adresse text
);


ALTER TABLE public.responsables OWNER TO postgres;

--
-- Name: responsables_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.responsables_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.responsables_id_seq OWNER TO postgres;

--
-- Name: responsables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.responsables_id_seq OWNED BY public.responsables.id;


--
-- Name: retours_tardifs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.retours_tardifs (
    eleve_id integer NOT NULL,
    lundi_actif boolean DEFAULT false,
    mardi_actif boolean DEFAULT false,
    mercredi_actif boolean DEFAULT false,
    jeudi_actif boolean DEFAULT false,
    heure_lundi time without time zone,
    heure_mardi time without time zone,
    heure_mercredi time without time zone,
    heure_jeudi time without time zone
);


ALTER TABLE public.retours_tardifs OWNER TO postgres;

--
-- Name: v_annulations_actives; Type: VIEW; Schema: public; Owner: postgres
--

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


ALTER VIEW public.v_annulations_actives OWNER TO postgres;

--
-- Name: v_liste_annulations; Type: VIEW; Schema: public; Owner: postgres
--

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


ALTER VIEW public.v_liste_annulations OWNER TO postgres;

--
-- Name: v_liste_presences_jeudi; Type: VIEW; Schema: public; Owner: postgres
--

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


ALTER VIEW public.v_liste_presences_jeudi OWNER TO postgres;

--
-- Name: v_liste_presences_lundi; Type: VIEW; Schema: public; Owner: postgres
--

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


ALTER VIEW public.v_liste_presences_lundi OWNER TO postgres;

--
-- Name: v_liste_presences_mardi; Type: VIEW; Schema: public; Owner: postgres
--

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


ALTER VIEW public.v_liste_presences_mardi OWNER TO postgres;

--
-- Name: v_liste_presences_mercredi; Type: VIEW; Schema: public; Owner: postgres
--

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


ALTER VIEW public.v_liste_presences_mercredi OWNER TO postgres;

--
-- Name: v_repas_jeudi; Type: VIEW; Schema: public; Owner: postgres
--

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


ALTER VIEW public.v_repas_jeudi OWNER TO postgres;

--
-- Name: v_repas_lundi; Type: VIEW; Schema: public; Owner: postgres
--

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


ALTER VIEW public.v_repas_lundi OWNER TO postgres;

--
-- Name: v_repas_mardi; Type: VIEW; Schema: public; Owner: postgres
--

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


ALTER VIEW public.v_repas_mardi OWNER TO postgres;

--
-- Name: v_repas_mercredi; Type: VIEW; Schema: public; Owner: postgres
--

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


ALTER VIEW public.v_repas_mercredi OWNER TO postgres;

--
-- Name: v_retours_tardifs_complet; Type: VIEW; Schema: public; Owner: postgres
--

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


ALTER VIEW public.v_retours_tardifs_complet OWNER TO postgres;

--
-- Name: v_stats_classes; Type: VIEW; Schema: public; Owner: postgres
--

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


ALTER VIEW public.v_stats_classes OWNER TO postgres;

--
-- Name: chambres id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chambres ALTER COLUMN id SET DEFAULT nextval('public.chambres_id_seq'::regclass);


--
-- Name: classes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes ALTER COLUMN id SET DEFAULT nextval('public.classes_id_seq'::regclass);


--
-- Name: eleves id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eleves ALTER COLUMN id SET DEFAULT nextval('public.eleves_id_seq'::regclass);


--
-- Name: incidents id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incidents ALTER COLUMN id SET DEFAULT nextval('public.incidents_id_seq'::regclass);


--
-- Name: repas_annulations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.repas_annulations ALTER COLUMN id SET DEFAULT nextval('public.repas_annulations_id_seq'::regclass);


--
-- Name: repas_prevus id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.repas_prevus ALTER COLUMN id SET DEFAULT nextval('public.repas_prevus_id_seq'::regclass);


--
-- Name: responsables id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.responsables ALTER COLUMN id SET DEFAULT nextval('public.responsables_id_seq'::regclass);


--
-- Data for Name: activites; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activites (id, nom, description) FROM stdin;
FOOT	Football Club	Entraînement le mercredi après-midi
THEA	Théâtre	Répétition pour la pièce de fin d'année
MUSI	Conservatoire	Cours de solfège et instrument
FOOT_923	Football	\N
RUGB	Rugby	\N
DANS	Danse	\N
ECHE	Echecs	\N
BASK	Basket	\N
NATA	Natation	\N
MUSI_676	Musique	\N
GYM	Gym	\N
VOLL	Volley	\N
DESS	Dessin	\N
JUDO	Judo	\N
TENN	Tennis	\N
CHOR	Chorale	\N
ESCA	Escalade	\N
BADM	Badminton	\N
EQUI	Equitation	\N
VTT	VTT	\N
ATHL	Athlétisme	\N
HAND	Handball	\N
PIAN	Piano	\N
BOXE	Boxe	\N
VIOL	Violon	\N
\.


--
-- Data for Name: chambres; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chambres (id, numero, capacite, etage, bat, dispo) FROM stdin;
1	101	3	1	A	3
2	102	2	1	A	2
3	204	4	2	B	4
4	305	1	3	C	1
\.


--
-- Data for Name: classes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.classes (id, nom, niveau, prof_principal, cpe_referent) FROM stdin;
1	2NDE-1	Seconde	M. Petit	\N
2	1ERE-G	Premiere	Mme Durand	\N
3	TERM-S1	Terminale	M. Martin	\N
4	BTS-SIO1	BTS1	Mme Lefebvre	\N
5	2NDE1	Seconde	\N	\N
6	1ERE2	Premiere	\N	\N
7	TERM3	Terminale	\N	\N
8	2NDE2	Seconde	\N	\N
9	CPGE1	CPGE	\N	\N
10	1ERE1	Premiere	\N	\N
11	TERM1	Terminale	\N	\N
12	2NDE3	Seconde	\N	\N
13	1ERE3	Premiere	\N	\N
14	TERM2	Terminale	\N	\N
15	CPGE2	CPGE	\N	\N
\.


--
-- Data for Name: démissionnaires; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."démissionnaires" (id, nom, prenom, adresse, genre, dimanche, dossier_complet, urgence_sociale, dossier_cartone_transmis, classe_id, chambre_id, referent_grenoble_id, retours_tardifs_backup, repas_prevus_backup) FROM stdin;
\.


--
-- Data for Name: eleves; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.eleves (id, nom, prenom, classe_id, adresse, genre, temps_transport, chambre_id, dimanche, referent_grenoble_id, dossier_cartone_transmis, dossier_complet, urgence_sociale, activite_id) FROM stdin;
1	Martin	Lucas	1	\N	M	\N	1	f	1	f	f	f	FOOT
2	Bernard	Chloé	1	\N	F	\N	1	f	2	f	f	f	\N
3	Thomas	Enzo	4	\N	M	\N	3	f	3	f	f	f	MUSI
4	Petit	Léa	2	\N	F	\N	2	f	1	f	f	f	THEA
5	DUPONT	Jean	5	12 Rue des Lilas	M	01:30:00	1	t	4	f	t	f	FOOT_923
6	MARTIN	Sophie	6	\N	F	\N	3	f	\N	t	t	f	MUSI
7	BERNARD	Lucas	7	5 Avenue de la Gare	M	02:00:00	2	f	5	t	f	t	RUGB
8	PETIT	Emma	8	8 Place du Marché	F	00:45:00	\N	t	\N	f	f	f	DANS
9	ROBERT	Thomas	9	14 Bd Gambetta	M	03:00:00	\N	f	6	t	t	f	ECHE
10	RICHARD	Léa	10	\N	F	01:15:00	\N	t	7	t	t	f	\N
11	DURAND	Paul	11	22 Rue Victor Hugo	M	01:00:00	\N	f	\N	f	t	f	BASK
12	LEFEBVRE	Chloé	12	3 Impasse des Roses	F	00:30:00	\N	t	8	t	t	f	THEA
13	MOREAU	Antoine	13	\N	M	\N	\N	f	9	f	f	f	NATA
14	SIMON	Camille	14	7 Rue de la Paix	F	01:45:00	\N	t	\N	t	f	t	MUSI_676
15	LAURENT	Nicolas	15	\N	M	02:30:00	\N	f	10	t	t	f	\N
16	MICHEL	Julie	5	10 Avenue Jean Jaurès	F	01:20:00	\N	t	11	f	t	f	GYM
17	GARCIA	Louis	6	45 Rue de la République	M	00:50:00	\N	f	\N	t	t	f	VOLL
18	DAVID	Sarah	7	\N	F	\N	\N	t	12	f	f	f	DESS
19	BERTRAND	Alexandre	8	18 Rue Pasteur	M	01:10:00	\N	f	13	t	t	t	JUDO
20	ROUX	Manon	10	9 Bd Voltaire	F	01:55:00	\N	t	\N	t	f	f	\N
21	VINCENT	Maxime	11	\N	M	\N	\N	f	14	f	t	f	TENN
22	FOURNIER	Alice	12	33 Rue de Lyon	F	01:05:00	\N	t	15	t	t	f	CHOR
23	MOREL	Hugo	9	\N	M	\N	\N	f	\N	f	t	f	ESCA
24	GIRARD	Mathilde	13	50 Avenue Foch	F	02:15:00	\N	t	16	f	f	f	BADM
25	ANDRE	Enzo	14	\N	M	01:25:00	\N	f	17	t	t	f	\N
26	LEFEVRE	Océane	5	11 Rue des Fleurs	F	00:40:00	\N	t	\N	t	f	f	EQUI
27	MERCIER	Tom	6	\N	M	\N	\N	f	18	f	t	f	VTT
28	DUPUIS	Lola	7	2 Rue du Moulin	F	01:35:00	\N	t	19	f	t	t	ATHL
29	LAMBERT	Théo	8	\N	M	\N	\N	f	\N	t	f	f	HAND
30	BONNET	Inès	10	6 Place de l'Eglise	F	00:55:00	\N	t	20	t	t	f	PIAN
31	FRANCOIS	Raphaël	11	\N	M	\N	\N	f	21	f	t	f	\N
32	MARTINEZ	Clara	15	29 Boulevard Carnot	F	02:10:00	\N	t	\N	f	f	f	\N
33	LEGRAND	Arthur	12	\N	M	\N	\N	f	22	t	t	f	BOXE
34	GARNIER	Lisa	13	15 Rue St Michel	F	01:15:00	\N	t	23	t	f	t	VIOL
\.


--
-- Data for Name: incidents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.incidents (id, chambre_id, date_signalement, intervenant, date_resolution) FROM stdin;
1	1	2024-03-20	Plombier - Fuite radiateur	\N
2	3	2024-03-21	Électricien - Ampoule HS	\N
\.


--
-- Data for Name: repas_annulations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.repas_annulations (id, eleve_id, mode, jour_cible, est_traite, date_debut, date_fin, repas_force, created_at) FROM stdin;
\.


--
-- Data for Name: repas_prevus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.repas_prevus (id, eleve_id, jour_nom, type_repas_prevu, repas_exceptionnel) FROM stdin;
1	1	lundi	Chaud	\N
2	1	mardi	Chaud	\N
3	1	mercredi	Chaud	\N
4	1	jeudi	Chaud	\N
5	2	lundi	Chaud	\N
6	2	mardi	Chaud	\N
7	2	mercredi	Froid	\N
8	3	mercredi	Chaud	\N
9	3	jeudi	Chaud	\N
10	4	lundi	Chaud	\N
11	4	mercredi	Froid	\N
\.


--
-- Data for Name: responsables; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.responsables (id, nom, prenom, telephone, adresse) FROM stdin;
1	Dupont	Jean-Pierre	0476001122	12 rue de la Paix, 38000 Grenoble
2	Leroy	Catherine	0476334455	5 Avenue Alsace, 38100 Grenoble
3	Moreau	Robert	0476998877	21 Place Victor Hugo, 38000 Grenoble
4	M.	Dupont	\N	\N
5	Mme	Bernard	\N	\N
6	M.	Robert	\N	\N
7	Mme	Richard	\N	\N
8	M.	Lefebvre	\N	\N
9	Mme	Moreau	\N	\N
10	M.	Laurent	\N	\N
11	Mme	Michel	\N	\N
12	M.	David	\N	\N
13	Mme	Bertrand	\N	\N
14	M.	Vincent	\N	\N
15	Mme	Fournier	\N	\N
16	M.	Girard	\N	\N
17	Mme	Andre	\N	\N
18	M.	Mercier	\N	\N
19	Mme	Dupuis	\N	\N
20	M.	Bonnet	\N	\N
21	Mme	Francois	\N	\N
22	M.	Legrand	\N	\N
23	Mme	Garnier	\N	\N
\.


--
-- Data for Name: retours_tardifs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.retours_tardifs (eleve_id, lundi_actif, mardi_actif, mercredi_actif, jeudi_actif, heure_lundi, heure_mardi, heure_mercredi, heure_jeudi) FROM stdin;
1	t	t	t	t	19:00:00	19:00:00	19:00:00	19:00:00
2	t	t	t	f	17:00:00	17:00:00	17:00:00	\N
3	f	f	t	t	\N	\N	17:30:00	17:30:00
4	t	f	t	f	18:30:00	\N	18:30:00	\N
\.


--
-- Name: chambres_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chambres_id_seq', 4, true);


--
-- Name: classes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.classes_id_seq', 15, true);


--
-- Name: eleves_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.eleves_id_seq', 34, true);


--
-- Name: incidents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.incidents_id_seq', 2, true);


--
-- Name: repas_annulations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.repas_annulations_id_seq', 1, false);


--
-- Name: repas_prevus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.repas_prevus_id_seq', 11, true);


--
-- Name: responsables_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.responsables_id_seq', 23, true);


--
-- Name: activites activites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activites
    ADD CONSTRAINT activites_pkey PRIMARY KEY (id);


--
-- Name: chambres chambres_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chambres
    ADD CONSTRAINT chambres_pkey PRIMARY KEY (id);


--
-- Name: classes classes_nom_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_nom_key UNIQUE (nom);


--
-- Name: classes classes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_pkey PRIMARY KEY (id);


--
-- Name: démissionnaires démissionnaires_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."démissionnaires"
    ADD CONSTRAINT "démissionnaires_pkey" PRIMARY KEY (id);


--
-- Name: eleves eleves_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eleves
    ADD CONSTRAINT eleves_pkey PRIMARY KEY (id);


--
-- Name: incidents incidents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incidents
    ADD CONSTRAINT incidents_pkey PRIMARY KEY (id);


--
-- Name: repas_annulations repas_annulations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.repas_annulations
    ADD CONSTRAINT repas_annulations_pkey PRIMARY KEY (id);


--
-- Name: repas_prevus repas_prevus_eleve_id_jour_nom_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.repas_prevus
    ADD CONSTRAINT repas_prevus_eleve_id_jour_nom_key UNIQUE (eleve_id, jour_nom);


--
-- Name: repas_prevus repas_prevus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.repas_prevus
    ADD CONSTRAINT repas_prevus_pkey PRIMARY KEY (id);


--
-- Name: responsables responsables_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.responsables
    ADD CONSTRAINT responsables_pkey PRIMARY KEY (id);


--
-- Name: retours_tardifs retours_tardifs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.retours_tardifs
    ADD CONSTRAINT retours_tardifs_pkey PRIMARY KEY (eleve_id);


--
-- Name: eleves eleves_activite_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eleves
    ADD CONSTRAINT eleves_activite_id_fkey FOREIGN KEY (activite_id) REFERENCES public.activites(id);


--
-- Name: eleves eleves_chambre_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eleves
    ADD CONSTRAINT eleves_chambre_id_fkey FOREIGN KEY (chambre_id) REFERENCES public.chambres(id);


--
-- Name: eleves eleves_classe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eleves
    ADD CONSTRAINT eleves_classe_id_fkey FOREIGN KEY (classe_id) REFERENCES public.classes(id);


--
-- Name: eleves eleves_referent_grenoble_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.eleves
    ADD CONSTRAINT eleves_referent_grenoble_id_fkey FOREIGN KEY (referent_grenoble_id) REFERENCES public.responsables(id);


--
-- Name: incidents incidents_chambre_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incidents
    ADD CONSTRAINT incidents_chambre_id_fkey FOREIGN KEY (chambre_id) REFERENCES public.chambres(id);


--
-- Name: repas_annulations repas_annulations_eleve_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.repas_annulations
    ADD CONSTRAINT repas_annulations_eleve_id_fkey FOREIGN KEY (eleve_id) REFERENCES public.eleves(id) ON DELETE CASCADE;


--
-- Name: repas_prevus repas_prevus_eleve_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.repas_prevus
    ADD CONSTRAINT repas_prevus_eleve_id_fkey FOREIGN KEY (eleve_id) REFERENCES public.eleves(id) ON DELETE CASCADE;


--
-- Name: retours_tardifs retours_tardifs_eleve_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.retours_tardifs
    ADD CONSTRAINT retours_tardifs_eleve_id_fkey FOREIGN KEY (eleve_id) REFERENCES public.eleves(id) ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict WEUl7BTpggbhVgURuhP9591tGUZxRpO7Pekhc4TuYHFqO7xeKW0mqkFAOT12va6

