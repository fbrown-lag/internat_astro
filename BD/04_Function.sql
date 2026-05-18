CREATE FUNCTION public.clean_expired_annulations() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE repas_annulations
    SET est_traite = TRUE
    WHERE est_traite = FALSE
      AND (
          (mode = 'jour' AND date_fin < CURRENT_DATE)
          OR ((mode = 'periode' OR mode = 'hybride') AND date_fin < CURRENT_DATE)
      );
END;
$$;
