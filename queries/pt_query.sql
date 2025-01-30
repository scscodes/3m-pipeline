WITH unique_patients AS (
    SELECT DISTINCT subject_id
    FROM mimiciv_hosp.patients
    LIMIT 100  -- Adjust for larger populations
),
patient_data AS (
    SELECT
        p.subject_id,
        p.gender,
        p.anchor_age AS age,
        p.dod AS date_of_death,
        a.hadm_id,
        a.admittime AS admission_time,
        a.dischtime AS discharge_time,
        i.stay_id,
        i.intime AS icu_admission_time,
        i.outtime AS icu_discharge_time,
        i.los AS icu_length_of_stay
    FROM mimiciv_hosp.patients p
    INNER JOIN mimiciv_hosp.admissions a
        ON p.subject_id = a.subject_id
    INNER JOIN mimiciv_icu.icustays i
        ON a.hadm_id = i.hadm_id
    WHERE p.subject_id IN (SELECT subject_id FROM unique_patients)
),
severity_scores AS (
    SELECT
        aps.hadm_id,
        aps.stay_id,
        aps.apsiii AS apsiii_score,
        lod.lods AS lods_score,
        oasis.oasis AS oasis_score,
        sap.sapsii AS sapsii_score,
        sirs.sirs AS sirs_score,
        sep.sepsis3
    FROM mimiciv_derived.apsiii aps
    LEFT JOIN mimiciv_derived.lods lod
        ON aps.hadm_id = lod.hadm_id AND aps.stay_id = lod.stay_id
    LEFT JOIN mimiciv_derived.oasis oasis
        ON aps.hadm_id = oasis.hadm_id AND aps.stay_id = oasis.stay_id
    LEFT JOIN mimiciv_derived.sapsii sap
        ON aps.hadm_id = sap.hadm_id AND aps.stay_id = sap.stay_id
    LEFT JOIN mimiciv_derived.sirs sirs
        ON aps.hadm_id = sirs.hadm_id AND aps.stay_id = sirs.stay_id
    LEFT JOIN mimiciv_derived.sepsis3 sep
        ON aps.hadm_id = sap.hadm_id AND aps.stay_id = sap.stay_id
    WHERE aps.hadm_id IN (SELECT hadm_id FROM patient_data)
),
vitals AS (
    SELECT
        ce.subject_id,
        ce.hadm_id,
        ce.stay_id,
        ce.charttime,
        MAX(CASE WHEN ce.itemid = 220045 THEN ce.valuenum END) AS heart_rate,
        MAX(CASE WHEN ce.itemid = 220179 THEN ce.valuenum END) AS systolic_bp,
        MAX(CASE WHEN ce.itemid = 220180 THEN ce.valuenum END) AS diastolic_bp,
        MAX(CASE WHEN ce.itemid = 220210 THEN ce.valuenum END) AS respiratory_rate,
        MAX(CASE WHEN ce.itemid = 223761 THEN ce.valuenum END) AS temperature_fahrenheit,
        MAX(CASE WHEN ce.itemid = 223762 THEN ce.valuenum END) AS temperature_celsius,
        MAX(CASE WHEN ce.itemid = 220739 THEN ce.valuenum END) AS oxygen_saturation
    FROM mimiciv_icu.chartevents ce
    WHERE ce.subject_id IN (SELECT subject_id FROM unique_patients)
    GROUP BY ce.subject_id, ce.hadm_id, ce.stay_id, ce.charttime
),
labs AS (
    SELECT
        le.subject_id,
        le.hadm_id,
        le.charttime,
        MAX(CASE WHEN le.itemid = 50882 THEN le.valuenum END) AS bilirubin,
        MAX(CASE WHEN le.itemid = 50912 THEN le.valuenum END) AS creatinine,
        MAX(CASE WHEN le.itemid = 50971 THEN le.valuenum END) AS glucose
    FROM mimiciv_hosp.labevents le
    WHERE le.subject_id IN (SELECT subject_id FROM unique_patients)
    GROUP BY le.subject_id, le.hadm_id, le.charttime
)
SELECT
    pd.*, -- Basic details of patients
    ss.apsiii_score,
    ss.lods_score,
    ss.oasis_score,
    ss.sapsii_score,
    ss.sirs_score,
    ss.sepsis3,
    v.charttime,
    v.heart_rate,
    v.systolic_bp,
    v.diastolic_bp,
    v.respiratory_rate,
    v.temperature_fahrenheit,
    v.temperature_celsius,
    v.oxygen_saturation,
    l.bilirubin,
    l.creatinine,
    l.glucose
FROM patient_data pd
LEFT JOIN severity_scores ss
    ON pd.hadm_id = ss.hadm_id AND pd.stay_id = ss.stay_id
LEFT JOIN vitals v
    ON pd.subject_id = v.subject_id
    AND pd.hadm_id = v.hadm_id
    AND pd.stay_id = v.stay_id
LEFT JOIN labs l
    ON pd.subject_id = l.subject_id
    AND pd.hadm_id = l.hadm_id
    AND v.charttime = l.charttime
ORDER BY pd.subject_id, pd.hadm_id, pd.stay_id, v.charttime;