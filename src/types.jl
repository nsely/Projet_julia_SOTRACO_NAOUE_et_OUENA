# types.jl
# Définition des structures de données pour le système SOTRACO

using Dates

"""
    Arret
Structure représentant un arrêt de bus dans le réseau SOTRACO
"""
struct Arret
    id::Int
    nom_arret::String
    quartier::String
    zone::String
    latitude::Float64
    longitude::Float64
    abribus::Bool
    eclairage::Bool
    lignes_desservies::Vector{Int}
end

"""
    LigneBus
Structure représentant une ligne de bus
"""
struct LigneBus
    id::Int
    nom_ligne::String
    origine::String
    destination::String
    distance_km::Float64
    duree_trajet_min::Float64
    tarif_fcfa::Float64
    frequence_min::Float64
    statut::String
end

"""
    Frequentation
Structure représentant un enregistrement de fréquentation
"""
struct Frequentation
    id::Int
    date::Date
    heure::Time
    ligne_id::Int
    arret_id::Int
    montees::Int
    descentes::Int
    occupation_bus::Int
    capacite_bus::Int
end

"""
    AnalyseLigne
Structure pour stocker les résultats d'analyse par ligne
"""
mutable struct AnalyseLigne
    ligne_id::Int
    nom_ligne::String
    statut::String
    recettes_fcfa::Float64
    taux_occupation_moy::Float64
    occupation_max::Int
    occupation_min::Int
    montees_total::Int
    taux_surcharge::Float64
    attente_theo_min::Float64
    frequence_min::Float64
end

"""
    AnalyseArret
Structure pour stocker les résultats d'analyse par arrêt
"""
mutable struct AnalyseArret
    nom_arret::String
    arret_id::Int
    recettes_fcfa::Float64
    taux_occupation_moy::Float64
    occupation_max::Int
    occupation_min::Int
    montees_total::Int
    taux_surcharge::Float64
    attente_theo_min::Float64
    frequence_min::Float64
end

"""
    AnalyseQuartier
Structure pour stocker les résultats d'analyse par quartier
"""
mutable struct AnalyseQuartier
    nom_quartier::String
    recettes_fcfa::Float64
    taux_occupation_moy::Float64
    occupation_max::Int
    occupation_min::Int
    montees_total::Int
    taux_surcharge::Float64
    attente_theo_min::Float64
    frequence_min::Float64
end

"""
    AnalyseZone
Structure pour stocker les résultats d'analyse par zone
"""
mutable struct AnalyseZone
    nom_zone::String
    recettes_fcfa::Float64
    taux_occupation_moy::Float64
    occupation_max::Int
    occupation_min::Int
    montees_total::Int
    taux_surcharge::Float64
    attente_theo_min::Float64
    frequence_min::Float64
end

"""
    AnalyseJour
Structure pour stocker les résultats d'analyse par jour
"""
mutable struct AnalyseJour
    nom_jour::String
    recettes_fcfa::Float64
    taux_occupation_moy::Float64
    montees_total::Int
    occupation_max::Int
    occupation_min::Int
end

"""
    AnalysePlageHoraire
Structure pour stocker les résultats d'analyse par plage horaire
"""
mutable struct AnalysePlageHoraire
    plage_horaire::String
    recettes_fcfa::Float64
    taux_occupation_moy::Float64
    montees_total::Int
    occupation_max::Int
    occupation_min::Int
end

"""
    OptimisationLigne
Structure pour stocker les résultats d'optimisation
"""
mutable struct OptimisationLigne
    ligne_id::Int
    nom_ligne::String
    statut::String
    taux_occupation_moy_avant::Float64
    taux_occupation_moy_apres_optim::Float64
    freq_min_avant::Float64
    frequence_min_apres::Float64
end

"""
    SystemeSOTRACO
Structure principale contenant toutes les données du système
"""
mutable struct SystemeSOTRACO
    arrets::Vector{Arret}
    lignes::Vector{LigneBus}
    frequentations::Vector{Frequentation}
    analyses_lignes::Vector{AnalyseLigne}
    analyses_arrets::Vector{AnalyseArret}
    analyses_quartiers::Vector{AnalyseQuartier}
    analyses_zones::Vector{AnalyseZone}
    optimisations::Vector{OptimisationLigne}
end

# Constructeur vide pour le système
SystemeSOTRACO() = SystemeSOTRACO(
    Vector{Arret}(),
    Vector{LigneBus}(),
    Vector{Frequentation}(),
    Vector{AnalyseLigne}(),
    Vector{AnalyseArret}(),
    Vector{AnalyseQuartier}(),
    Vector{AnalyseZone}(),
    Vector{OptimisationLigne}()
)