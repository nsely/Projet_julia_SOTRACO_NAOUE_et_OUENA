# io_operations.jl
# Module de gestion des entrées/sorties pour le système SOTRACO

using CSV
using DataFrames
using Dates
using XLSX

"""
    charger_arrets(chemin::String)
Charge les données des arrêts depuis un fichier CSV
"""
function charger_arrets(chemin::String)
    println("📍 Chargement des arrêts...")
    df = CSV.read(chemin, DataFrame)
    
    arrets = Vector{Arret}()
    for row in eachrow(df)
        # Traitement des lignes desservies (conversion string -> vector d'entiers)
        lignes_str = string(row.lignes_desservies)
        lignes = if lignes_str != "missing" && lignes_str != ""
            [parse(Int, strip(x)) for x in split(lignes_str, ',')]
        else
            Int[]
        end
        
        arret = Arret(
            row.id,
            row.nom_arret,
            row.quartier,
            row.zone,
            row.latitude,
            row.longitude,
            lowercase(row.abribus) == "oui",
            lowercase(row.eclairage) == "oui",
            lignes
        )
        push!(arrets, arret)
    end
    
    println("✅ $(length(arrets)) arrêts chargés avec succès!")
    return arrets
end

"""
    charger_lignes(chemin::String)
Charge les données des lignes de bus depuis un fichier CSV
"""
function charger_lignes(chemin::String)
    println("🚌 Chargement des lignes de bus...")
    df = CSV.read(chemin, DataFrame)
    
    lignes = Vector{LigneBus}()
    for row in eachrow(df)
        ligne = LigneBus(
            row.id,
            row.nom_ligne,
            row.origine,
            row.destination,
            row.distance_km,
            row.duree_trajet_min,
            row.tarif_fcfa,
            row.frequence_min,
            row.statut
        )
        push!(lignes, ligne)
    end
    
    println("✅ $(length(lignes)) lignes chargées avec succès!")
    return lignes
end

"""
    charger_frequentation(chemin::String)
Charge les données de fréquentation depuis un fichier CSV
"""
function charger_frequentation(chemin::String)
    println("📊 Chargement des données de fréquentation...")
    df = CSV.read(chemin, DataFrame)
    
    frequentations = Vector{Frequentation}()
    for row in eachrow(df)
        try
            # Conversion sécurisée de l'ID
            id = if isa(row.id, Number)
                Int(row.id)
            elseif isa(row.id, String)
                parse(Int, row.id)
            else
                error("Type d'ID non supporté: $(typeof(row.id))")
            end
            
            # Conversion de la date
            date = if isa(row.date, Date)
                row.date
            elseif isa(row.date, String)
                Date(row.date, dateformat"yyyy-mm-dd")
            else
                error("Type de date non supporté: $(typeof(row.date))")
            end
            
            # Conversion de l'heure
            heure = if isa(row.heure, Time)
                row.heure
            elseif isa(row.heure, String)
                Time(row.heure, "HH:MM:SS")
            else
                error("Type d'heure non supporté: $(typeof(row.heure))")
            end
            
            # Conversion sécurisée des autres champs numériques
            ligne_id = Int(row.ligne_id)
            arret_id = Int(row.arret_id)
            montees = Int(row.montees)
            descentes = Int(row.descentes)
            occupation_bus = Int(row.occupation_bus)
            capacite_bus = Int(row.capacite_bus)
            
            freq = Frequentation(
                id,
                date,
                heure,
                ligne_id,
                arret_id,
                montees,
                descentes,
                occupation_bus,
                capacite_bus
            )
            push!(frequentations, freq)
            
        catch e
            println("⚠️ Erreur lors du traitement de la ligne $(row.id): $e")
            println("   Données: id=$(row.id), date=$(row.date), heure=$(row.heure)")
            # Continuer avec les autres lignes
            continue
        end
    end
    
    println("✅ $(length(frequentations)) enregistrements de fréquentation chargés avec succès!")
    return frequentations
end

"""
    charger_donnees_completes(dossier_data::String)
Charge toutes les données nécessaires au système
"""
function charger_donnees_completes(dossier_data::String)
    println("\n" * "="^60)
    println("🔄 CHARGEMENT DES DONNÉES DU SYSTÈME SOTRACO")
    println("="^60)
    
    # Vérification de l'existence du dossier
    if !isdir(dossier_data)
        error("❌ Le dossier $dossier_data n'existe pas!")
    end
    
    # Chemins des fichiers
    chemin_arrets = joinpath(dossier_data, "arrets.csv")
    chemin_lignes = joinpath(dossier_data, "lignes_bus.csv")
    chemin_freq = joinpath(dossier_data, "frequentation.csv")
    
    # Vérification de l'existence des fichiers
    for (fichier, chemin) in [("arrets.csv", chemin_arrets),
                               ("lignes_bus.csv", chemin_lignes),
                               ("frequentation.csv", chemin_freq)]
        if !isfile(chemin)
            error("❌ Le fichier $fichier n'existe pas dans $dossier_data!")
        end
    end
    
    # Chargement des données
    arrets = charger_arrets(chemin_arrets)
    lignes = charger_lignes(chemin_lignes)
    frequentations = charger_frequentation(chemin_freq)
    
    println("\n✅ Toutes les données ont été chargées avec succès!")
    println("="^60 * "\n")
    
    return arrets, lignes, frequentations
end

"""
    exporter_analyse_csv(donnees::Vector, nom_fichier::String, dossier_sortie::String="resultats")
Exporte les résultats d'analyse vers un fichier CSV
"""
function exporter_analyse_csv(donnees::Vector, nom_fichier::String, dossier_sortie::String="resultats")
    # Créer le dossier de sortie s'il n'existe pas
    if !isdir(dossier_sortie)
        mkpath(dossier_sortie)
    end
    
    # Convertir en DataFrame
    df = DataFrame()
    
    if length(donnees) > 0
        # Récupérer les noms de champs de la structure
        type_donnee = typeof(donnees[1])
        champs = fieldnames(type_donnee)
        
        # Créer les colonnes du DataFrame
        for champ in champs
            df[!, champ] = [getfield(d, champ) for d in donnees]
        end
    end
    
    # Chemin complet du fichier
    chemin_complet = joinpath(dossier_sortie, nom_fichier)
    
    # Exporter en CSV
    CSV.write(chemin_complet, df)
    println("💾 Données exportées vers: $chemin_complet")
    
    return chemin_complet
end

"""
    exporter_toutes_analyses(systeme::SystemeSOTRACO, dossier_sortie::String="resultats")
Exporte toutes les analyses du système vers des fichiers CSV
"""
function exporter_toutes_analyses(systeme::SystemeSOTRACO, dossier_sortie::String="resultats")
    println("\n" * "="^60)
    println("💾 EXPORTATION DES RÉSULTATS D'ANALYSE")
    println("="^60)
    
    # Créer le dossier de sortie s'il n'existe pas
    if !isdir(dossier_sortie)
        mkpath(dossier_sortie)
    end
    
    fichiers_exportes = String[]
    
    # Exporter les analyses par ligne
    if !isempty(systeme.analyses_lignes)
        push!(fichiers_exportes, 
              exporter_analyse_csv(systeme.analyses_lignes, "analyse_lignes.csv", dossier_sortie))
    end
    
    # Exporter les analyses par arrêt
    if !isempty(systeme.analyses_arrets)
        push!(fichiers_exportes,
              exporter_analyse_csv(systeme.analyses_arrets, "analyse_arrets.csv", dossier_sortie))
    end
    
    # Exporter les analyses par quartier
    if !isempty(systeme.analyses_quartiers)
        push!(fichiers_exportes,
              exporter_analyse_csv(systeme.analyses_quartiers, "analyse_quartiers.csv", dossier_sortie))
    end
    
    # Exporter les analyses par zone
    if !isempty(systeme.analyses_zones)
        push!(fichiers_exportes,
              exporter_analyse_csv(systeme.analyses_zones, "analyse_zones.csv", dossier_sortie))
    end
    
    # Exporter les optimisations
    if !isempty(systeme.optimisations)
        push!(fichiers_exportes,
              exporter_analyse_csv(systeme.optimisations, "optimisation_lignes.csv", dossier_sortie))
    end
    
    println("\n✅ $(length(fichiers_exportes)) fichiers exportés avec succès!")
    println("📁 Dossier de sortie: $dossier_sortie")
    println("="^60 * "\n")
    
    return fichiers_exportes
end

"""
    exporter_rapport_excel(systeme::SystemeSOTRACO, nom_fichier::String="rapport_sotraco.xlsx")
Exporte un rapport complet au format Excel
"""
function exporter_rapport_excel(systeme::SystemeSOTRACO, nom_fichier::String="rapport_sotraco.xlsx")
    println("📊 Génération du rapport Excel...")
    
    # Créer le dossier resultats s'il n'existe pas
    if !isdir("resultats")
        mkpath("resultats")
    end
    
    chemin_complet = joinpath("resultats", nom_fichier)
    
    XLSX.openxlsx(chemin_complet, mode="w") do xf
        # Feuille des analyses par ligne
        if !isempty(systeme.analyses_lignes)
            sheet = xf[1]
            XLSX.rename!(sheet, "Analyses Lignes")
            
            # En-têtes
            headers = ["Ligne ID", "Nom Ligne", "Statut", "Recettes (FCFA)", 
                      "Taux Occupation Moy", "Occupation Max", "Occupation Min",
                      "Montées Total", "Taux Surcharge", "Attente Théo (min)", "Fréquence (min)"]
            for (i, h) in enumerate(headers)
                sheet[1, i] = h
            end
            
            # Données
            for (row, analyse) in enumerate(systeme.analyses_lignes)
                sheet[row+1, 1] = analyse.ligne_id
                sheet[row+1, 2] = analyse.nom_ligne
                sheet[row+1, 3] = analyse.statut
                sheet[row+1, 4] = analyse.recettes_fcfa
                sheet[row+1, 5] = analyse.taux_occupation_moy
                sheet[row+1, 6] = analyse.occupation_max
                sheet[row+1, 7] = analyse.occupation_min
                sheet[row+1, 8] = analyse.montees_total
                sheet[row+1, 9] = analyse.taux_surcharge
                sheet[row+1, 10] = analyse.attente_theo_min
                sheet[row+1, 11] = analyse.frequence_min
            end
        end
        
        # Ajouter d'autres feuilles pour les autres analyses...
        # (code similaire pour analyses_arrets, analyses_quartiers, etc.)
    end
    
    println("✅ Rapport Excel exporté: $chemin_complet")
    return chemin_complet
end