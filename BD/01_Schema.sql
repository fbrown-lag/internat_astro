-- Types
CREATE TYPE public.mode_annulation AS ENUM (
    'jour',
    'periode',
    'hybride'
);

CREATE TYPE public.type_genre AS ENUM (
    'M',
    'F',
    'Autre'
);

CREATE TYPE public.type_niveau AS ENUM (
    'Seconde',
    'Premiere',
    'Terminale',
    'BTS1',
    'BTS2',
    'CPGE',
    'Autre'
);

CREATE TYPE public.type_repas AS ENUM (
    'Chaud',
    'Froid',
    'None'
);

-- Tables
CREATE TABLE public.activites (
    id character varying(50) NOT NULL,
    nom character varying(100) NOT NULL,
    description text
);

CREATE TABLE public.chambres (
    id integer NOT NULL,
    numero integer NOT NULL,
    capacite integer,
    etage integer,
    bat character(1),
    dispo integer
);

CREATE SEQUENCE public.chambres_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.chambres_id_seq OWNED BY public.chambres.id;

CREATE TABLE public.classes (
    id integer NOT NULL,
    nom character varying(50) NOT NULL,
    niveau public.type_niveau NOT NULL,
    prof_principal character varying(100),
    cpe_referent character varying(100)
);

CREATE SEQUENCE public.classes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.classes_id_seq OWNED BY public.classes.id;

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

CREATE SEQUENCE public.eleves_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.eleves_id_seq OWNED BY public.eleves.id;

CREATE TABLE public.incidents (
    id integer NOT NULL,
    chambre_id integer,
    date_signalement date DEFAULT CURRENT_DATE,
    intervenant character varying(100),
    date_resolution date
);

CREATE SEQUENCE public.incidents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.incidents_id_seq OWNED BY public.incidents.id;

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
    CONSTRAINT check_mode_data CHECK (
        ((mode = 'jour'::public.mode_annulation) AND (jour_cible IS NOT NULL))
        OR ((mode = 'periode'::public.mode_annulation) AND (date_debut IS NOT NULL) AND (date_fin IS NOT NULL))
        OR ((mode = 'hybride'::public.mode_annulation) AND (jour_cible IS NOT NULL) AND (date_debut IS NOT NULL) AND (date_fin IS NOT NULL))
    )
);

CREATE SEQUENCE public.repas_annulations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.repas_annulations_id_seq OWNED BY public.repas_annulations.id;

CREATE TABLE public.repas_prevus (
    id integer NOT NULL,
    eleve_id integer,
    jour_nom character varying(10) NOT NULL,
    type_repas_prevu public.type_repas DEFAULT 'Chaud'::public.type_repas NOT NULL,
    repas_exceptionnel public.type_repas
);

CREATE SEQUENCE public.repas_prevus_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.repas_prevus_id_seq OWNED BY public.repas_prevus.id;

CREATE TABLE public.responsables (
    id integer NOT NULL,
    nom character varying(100) NOT NULL,
    prenom character varying(100),
    telephone character varying(20),
    adresse text
);

CREATE SEQUENCE public.responsables_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.responsables_id_seq OWNED BY public.responsables.id;

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

-- Sequence defaults
ALTER TABLE ONLY public.chambres ALTER COLUMN id SET DEFAULT nextval('public.chambres_id_seq'::regclass);
ALTER TABLE ONLY public.classes ALTER COLUMN id SET DEFAULT nextval('public.classes_id_seq'::regclass);
ALTER TABLE ONLY public.eleves ALTER COLUMN id SET DEFAULT nextval('public.eleves_id_seq'::regclass);
ALTER TABLE ONLY public.incidents ALTER COLUMN id SET DEFAULT nextval('public.incidents_id_seq'::regclass);
ALTER TABLE ONLY public.repas_annulations ALTER COLUMN id SET DEFAULT nextval('public.repas_annulations_id_seq'::regclass);
ALTER TABLE ONLY public.repas_prevus ALTER COLUMN id SET DEFAULT nextval('public.repas_prevus_id_seq'::regclass);
ALTER TABLE ONLY public.responsables ALTER COLUMN id SET DEFAULT nextval('public.responsables_id_seq'::regclass);

-- Primary keys, uniques, foreign keys
ALTER TABLE ONLY public.activites
    ADD CONSTRAINT activites_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.chambres
    ADD CONSTRAINT chambres_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_nom_key UNIQUE (nom);

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public."démissionnaires"
    ADD CONSTRAINT "démissionnaires_pkey" PRIMARY KEY (id);

ALTER TABLE ONLY public.eleves
    ADD CONSTRAINT eleves_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.incidents
    ADD CONSTRAINT incidents_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.repas_annulations
    ADD CONSTRAINT repas_annulations_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.repas_prevus
    ADD CONSTRAINT repas_prevus_eleve_id_jour_nom_key UNIQUE (eleve_id, jour_nom);

ALTER TABLE ONLY public.repas_prevus
    ADD CONSTRAINT repas_prevus_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.responsables
    ADD CONSTRAINT responsables_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.retours_tardifs
    ADD CONSTRAINT retours_tardifs_pkey PRIMARY KEY (eleve_id);

ALTER TABLE ONLY public.eleves
    ADD CONSTRAINT eleves_activite_id_fkey FOREIGN KEY (activite_id) REFERENCES public.activites(id);

ALTER TABLE ONLY public.eleves
    ADD CONSTRAINT eleves_chambre_id_fkey FOREIGN KEY (chambre_id) REFERENCES public.chambres(id);

ALTER TABLE ONLY public.eleves
    ADD CONSTRAINT eleves_classe_id_fkey FOREIGN KEY (classe_id) REFERENCES public.classes(id);

ALTER TABLE ONLY public.eleves
    ADD CONSTRAINT eleves_referent_grenoble_id_fkey FOREIGN KEY (referent_grenoble_id) REFERENCES public.responsables(id);

ALTER TABLE ONLY public.incidents
    ADD CONSTRAINT incidents_chambre_id_fkey FOREIGN KEY (chambre_id) REFERENCES public.chambres(id);

ALTER TABLE ONLY public.repas_annulations
    ADD CONSTRAINT repas_annulations_eleve_id_fkey FOREIGN KEY (eleve_id) REFERENCES public.eleves(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.repas_prevus
    ADD CONSTRAINT repas_prevus_eleve_id_fkey FOREIGN KEY (eleve_id) REFERENCES public.eleves(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.retours_tardifs
    ADD CONSTRAINT retours_tardifs_eleve_id_fkey FOREIGN KEY (eleve_id) REFERENCES public.eleves(id) ON DELETE CASCADE;
