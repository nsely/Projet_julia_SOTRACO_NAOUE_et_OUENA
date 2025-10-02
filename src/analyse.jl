# analyse.jl
# Module d'analyse des données pour le système SOTRACO

using DataFrames
using Statistics
using Dates

"""
    analyser_lignes(lignes::Vector{LigneBus}, frequentations::Vector{Frequentation})
Analyse les performances de chaque ligne de bus
"""
function analyser_lignes(lignes::Vector{LigneBus}, frequentations::Vector{Frequentation})
    println("\n📊 Analyse des lignes en cours...")
    
    analyses = Vector{AnalyseLigne}()
    
    for ligne in lignes
        # Filtrer les fréquentations pour cette ligne
        freq_ligne = filter(f -> f.ligne_id == ligne.id, frequentations)
        
        if isempty(freq_ligne)
            continue
        end
        
        # Calculs statistiques
        montees_total = sum(f.montees for f in freq_ligne)
        recettes = montees_total * ligne.tarif_fcfa
        
        # Taux d'occupation
        taux_occupations = [f.occupation_bus / f.capacite_bus for f in freq_ligne if f.capacite_bus > 0]
        taux_occupation_moy = isempty(taux_occupations) ? 0.0 : mean(taux_occupations)
        
        # Occupation min/max
        occupations = [f.occupation_bus for f in freq_ligne]
        occupation_max = isempty(occupations) ? 0 : maximum(occupations)
        occupation_min = isempty(occupations) ? 0 : minimum(occupations)
        
        # Taux de surcharge (occupation > capacité)
        surcharges = [f.occupation_bus > f.capacite_bus for f in freq_ligne]
        taux_surcharge = mean(surcharges) * 100
        
        # Temps d'attente théorique
        attente_theo_min = ligne.frequence_min / 2
        
        analyse = AnalyseLigne(
            ligne.id,
            ligne.nom_ligne,
            ligne.statut,
            recettes,
            taux_occupation_moy,
            occupation_max,
            occupation_min,
            montees_total,
            taux_surcharge,
            attente_theo_min,
            ligne.frequence_min
        )
        
        push!(analyses, analyse)
    end
    
    println("✅ Analyse de $(length(analyses)) lignes terminée")
    return analyses
end

"""
    analyser_arrets(arrets::Vector{Arret}, lignes::Vector{LigneBus}, frequentations::Vector{Frequentation})
Analyse les performances de chaque arrêt
"""
function analyser_arrets(arrets::Vector{Arret}, lignes::Vector{LigneBus}, frequentations::Vector{Frequentation})
    println("\n📊 Analyse des arrêts en cours...")
    
    analyses = Vector{AnalyseArret}()
    
    for arret in arrets
        # Filtrer les fréquentations pour cet arrêt
        freq_arret = filter(f -> f.arret_id == arret.id, frequentations)
        
        if isempty(freq_arret)
            continue
        end
        
        # Calcul des recettes (somme des montées × tarif moyen)
        montees_total = sum(f.montees for f in freq_arret)
        
        # Tarif moyen des lignes desservant cet arrêt
        tarif_moyen = if !isempty(arret.lignes_desservies)
            lignes_arret = filter(l -> l.id in arret.lignes_desservies, lignes)
            isempty(lignes_arret) ? 0.0 : mean([l.tarif_fcfa for l in lignes_arret])
        else
            0.0
        end
        
        recettes = montees_total * tarif_moyen
        
        # Taux d'occupation
        taux_occupations = [f.occupation_bus / f.capacite_bus for f in freq_arret if f.capacite_bus > 0]
        taux_occupation_moy = isempty(taux_occupations) ? 0.0 : mean(taux_occupations)
        
        # Occupation min/max
        occupations = [f.occupation_bus for f in freq_arret]
        occupation_max = isempty(occupations) ? 0 : maximum(occupations)
        occupation_min = isempty(occupations) ? 0 : minimum(occupations)
        
        # Taux de surcharge
        surcharges = [f.occupation_bus > f.capacite_bus for f in freq_arret]
        taux_surcharge = mean(surcharges) * 100
        
        # Temps d'attente et fréquence moyens
        freq_moyennes = if !isempty(arret.lignes_desservies)
            lignes_arret = filter(l -> l.id in arret.lignes_desservies, lignes)
            isempty(lignes_arret) ? 0.0 : mean([l.frequence_min for l in lignes_arret])
        else
            0.0
        end
        
        attente_theo_min = freq_moyennes / 2
        
        analyse = AnalyseArret(
            arret.nom_arret,
            arret.id,
            recettes,
            taux_occupation_moy,
            occupation_max,
            occupation_min,
            montees_total,
            taux_surcharge,
            attente_theo_min,
            freq_moyennes
        )
        
        push!(analyses, analyse)
    end
    
    println("✅ Analyse de $(length(analyses)) arrêts terminée")
    return analyses
end

"""
    analyser_quartiers(arrets::Vector{Arret}, lignes::Vector{LigneBus}, frequentations::Vector{Frequentation})
Analyse les performances par quartier
"""
function analyser_quartiers(arrets::Vector{Arret}, lignes::Vector{LigneBus}, frequentations::Vector{Frequentation})
    println("\n📊 Analyse des quartiers en cours...")
    
    analyses = Vector{AnalyseQuartier}()
    
    # Regrouper les arrêts par quartier
    quartiers_uniques = unique([a.quartier for a in arrets])
    
    for quartier in quartiers_uniques
        # Filtrer les arrêts de ce quartier
        arrets_quartier = filter(a -> a.quartier == quartier, arrets)
        ids_arrets = [a.id for a in arrets_quartier]
        
        # Filtrer les fréquentations pour ce quartier
        freq_quartier = filter(f -> f.arret_id in ids_arrets, frequentations)
        
        if isempty(freq_quartier)
            continue
        end
        
        # Calcul des métriques agrégées
        montees_total = sum(f.montees for f in freq_quartier)
        
        # Tarif moyen des lignes du quartier
        lignes_ids = unique(vcat([a.lignes_desservies for a in arrets_quartier]...))
        lignes_quartier = filter(l -> l.id in lignes_ids, lignes)
        tarif_moyen = isempty(lignes_quartier) ? 0.0 : mean([l.tarif_fcfa for l in lignes_quartier])
        
        recettes = montees_total * tarif_moyen
        
        # Taux d'occupation
        taux_occupations = [f.occupation_bus / f.capacite_bus for f in freq_quartier if f.capacite_bus > 0]
        taux_occupation_moy = isempty(taux_occupations) ? 0.0 : mean(taux_occupations)
        
        # Occupation min/max
        occupations = [f.occupation_bus for f in freq_quartier]
        occupation_max = isempty(occupations) ? 0 : maximum(occupations)
        occupation_min = isempty(occupations) ? 0 : minimum(occupations)
        
        # Taux de surcharge
        surcharges = [f.occupation_bus > f.capacite_bus for f in freq_quartier]
        taux_surcharge = mean(surcharges) * 100
        
        # Temps d'attente et fréquence moyens
        freq_moyennes = isempty(lignes_quartier) ? 0.0 : mean([l.frequence_min for l in lignes_quartier])
        attente_theo_min = freq_moyennes / 2
        
        analyse = AnalyseQuartier(
            quartier,
            recettes,
            taux_occupation_moy,
            occupation_max,
            occupation_min,
            montees_total,
            taux_surcharge,
            attente_theo_min,
            freq_moyennes
        )
        
        push!(analyses, analyse)
    end
    
    println("✅ Analyse de $(length(analyses)) quartiers terminée")
    return analyses
end

"""
    analyser_zones(arrets::Vector{Arret}, lignes::Vector{LigneBus}, frequentations::Vector{Frequentation})
Analyse les performances par zone
"""
function analyser_zones(arrets::Vector{Arret}, lignes::Vector{LigneBus}, frequentations::Vector{Frequentation})
    println("\n📊 Analyse des zones en cours...")
    
    analyses = Vector{AnalyseZone}()
    
    # Regrouper les arrêts par zone
    zones_uniques = unique([a.zone for a in arrets])
    
    for zone in zones_uniques
        # Filtrer les arrêts de cette zone
        arrets_zone = filter(a -> a.zone == zone, arrets)
        ids_arrets = [a.id for a in arrets_zone]
        
        # Filtrer les fréquentations pour cette zone
        freq_zone = filter(f -> f.arret_id in ids_arrets, frequentations)
        
        if isempty(freq_zone)
            continue
        end
        
        # Calcul des métriques agrégées
        montees_total = sum(f.montees for f in freq_zone)
        
        # Tarif moyen des lignes de la zone
        lignes_ids = unique(vcat([a.lignes_desservies for a in arrets_zone]...))
        lignes_zone = filter(l -> l.id in lignes_ids, lignes)
        tarif_moyen = isempty(lignes_zone) ? 0.0 : mean([l.tarif_fcfa for l in lignes_zone])
        
        recettes = montees_total * tarif_moyen
        
        # Taux d'occupation
        taux_occupations = [f.occupation_bus / f.capacite_bus for f in freq_zone if f.capacite_bus > 0]
        taux_occupation_moy = isempty(taux_occupations) ? 0.0 : mean(taux_occupations)
        
        # Occupation min/max
        occupations = [f.occupation_bus for f in freq_zone]
        occupation_max = isempty(occupations) ? 0 : maximum(occupations)
        occupation_min = isempty(occupations) ? 0 : minimum(occupations)
        
        # Taux de surcharge
        surcharges = [f.occupation_bus > f.capacite_bus for f in freq_zone]
        taux_surcharge = mean(surcharges) * 100
        
        # Temps d'attente et fréquence moyens
        freq_moyennes = isempty(lignes_zone) ? 0.0 : mean([l.frequence_min for l in lignes_zone])
        attente_theo_min = freq_moyennes / 2
        
        analyse = AnalyseZone(
            zone,
            recettes,
            taux_occupation_moy,
            occupation_max,
            occupation_min,
            montees_total,
            taux_surcharge,
            attente_theo_min,
            freq_moyennes
        )
        
        push!(analyses, analyse)
    end
    
    println("✅ Analyse de $(length(analyses)) zones terminée")
    return analyses
end

"""
    analyser_jours(lignes::Vector{LigneBus}, frequentations::Vector{Frequentation})
Analyse les performances par jour de la semaine
"""
function analyser_jours(lignes::Vector{LigneBus}, frequentations::Vector{Frequentation})
    println("\n📊 Analyse par jour de la semaine en cours...")
    
    analyses = Vector{AnalyseJour}()
    jours_semaine = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"]
    
    for (i, nom_jour) in enumerate(jours_semaine)
        # Filtrer les fréquentations pour ce jour (1=Lundi, 7=Dimanche)
        freq_jour = filter(f -> dayofweek(f.date) == i, frequentations)
        
        if isempty(freq_jour)
            continue
        end
        
        # Calcul des métriques
        montees_total = sum(f.montees for f in freq_jour)
        
        # Calcul des recettes (approximation avec tarif moyen)
        tarif_moyen = mean([l.tarif_fcfa for l in lignes])
        recettes = montees_total * tarif_moyen
        
        # Taux d'occupation
        taux_occupations = [f.occupation_bus / f.capacite_bus for f in freq_jour if f.capacite_bus > 0]
        taux_occupation_moy = isempty(taux_occupations) ? 0.0 : mean(taux_occupations)
        
        # Occupation min/max
        occupations = [f.occupation_bus for f in freq_jour]
        occupation_max = isempty(occupations) ? 0 : maximum(occupations)
        occupation_min = isempty(occupations) ? 0 : minimum(occupations)
        
        analyse = AnalyseJour(
            nom_jour,
            recettes,
            taux_occupation_moy,
            montees_total,
            occupation_max,
            occupation_min
        )
        
        push!(analyses, analyse)
    end
    
    println("✅ Analyse des jours de la semaine terminée")
    return analyses
end

"""
    analyser_plages_horaires(lignes::Vector{LigneBus}, frequentations::Vector{Frequentation})
Analyse les performances par plage horaire
"""
function analyser_plages_horaires(lignes::Vector{LigneBus}, frequentations::Vector{Frequentation})
    println("\n📊 Analyse par plage horaire en cours...")
    
    analyses = Vector{AnalysePlageHoraire}()
    
    # Définir les plages horaires de 6h à 22h
    for heure in 6:21
        plage = string(lpad(heure, 2, '0')) * "h-" * string(lpad(heure+1, 2, '0')) * "h"
        
        # Filtrer les fréquentations pour cette plage horaire
        freq_plage = filter(f -> hour(f.heure) == heure, frequentations)
        
        if isempty(freq_plage)
            continue
        end
        
        # Calcul des métriques
        montees_total = sum(f.montees for f in freq_plage)
        
        # Calcul des recettes
        tarif_moyen = mean([l.tarif_fcfa for l in lignes])
        recettes = montees_total * tarif_moyen
        
        # Taux d'occupation
        taux_occupations = [f.occupation_bus / f.capacite_bus for f in freq_plage if f.capacite_bus > 0]
        taux_occupation_moy = isempty(taux_occupations) ? 0.0 : mean(taux_occupations)
        
        # Occupation min/max
        occupations = [f.occupation_bus for f in freq_plage]
        occupation_max = isempty(occupations) ? 0 : maximum(occupations)
        occupation_min = isempty(occupations) ? 0 : minimum(occupations)
        
        analyse = AnalysePlageHoraire(
            plage,
            recettes,
            taux_occupation_moy,
            montees_total,
            occupation_max,
            occupation_min
        )
        
        push!(analyses, analyse)
    end
    
    println("✅ Analyse des plages horaires terminée")
    return analyses
end

"""
    analyser_abribus(arrets::Vector{Arret}, lignes::Vector{LigneBus}, frequentations::Vector{Frequentation})
Analyse des recettes selon la présence d'abribus
"""
function analyser_abribus(arrets::Vector{Arret}, lignes::Vector{LigneBus}, frequentations::Vector{Frequentation})
    println("\n📊 Analyse des abribus en cours...")
    
    resultats = DataFrame(abribus = String[], recettes_fcfa = Float64[])
    
    for avec_abri in [true, false]
        # Filtrer les arrêts
        arrets_filtre = filter(a -> a.abribus == avec_abri, arrets)
        ids_arrets = [a.id for a in arrets_filtre]
        
        # Filtrer les fréquentations
        freq_filtre = filter(f -> f.arret_id in ids_arrets, frequentations)
        
        if !isempty(freq_filtre)
            montees_total = sum(f.montees for f in freq_filtre)
            tarif_moyen = mean([l.tarif_fcfa for l in lignes])
            recettes = montees_total * tarif_moyen
            
            push!(resultats, (avec_abri ? "Oui" : "Non", recettes))
        end
    end
    
    println("✅ Analyse des abribus terminée")
    return resultats
end

"""
    analyser_eclairage(arrets::Vector{Arret}, lignes::Vector{LigneBus}, frequentations::Vector{Frequentation})
Analyse des recettes selon la présence d'éclairage
"""
function analyser_eclairage(arrets::Vector{Arret}, lignes::Vector{LigneBus}, frequentations::Vector{Frequentation})
    println("\n📊 Analyse de l'éclairage en cours...")
    
    resultats = DataFrame(eclairage = String[], recettes_fcfa = Float64[])
    
    for avec_eclairage in [true, false]
        # Filtrer les arrêts
        arrets_filtre = filter(a -> a.eclairage == avec_eclairage, arrets)
        ids_arrets = [a.id for a in arrets_filtre]
        
        # Filtrer les fréquentations
        freq_filtre = filter(f -> f.arret_id in ids_arrets, frequentations)
        
        if !isempty(freq_filtre)
            montees_total = sum(f.montees for f in freq_filtre)
            tarif_moyen = mean([l.tarif_fcfa for l in lignes])
            recettes = montees_total * tarif_moyen
            
            push!(resultats, (avec_eclairage ? "Oui" : "Non", recettes))
        end
    end
    
    println("✅ Analyse de l'éclairage terminée")
    return resultats
end

"""
    identifier_heures_pointe(frequentations::Vector{Frequentation})
Identifie les heures de pointe du réseau
"""
function identifier_heures_pointe(frequentations::Vector{Frequentation})
    # Grouper par heure
    heures_freq = Dict{Int, Int}()
    
    for f in frequentations
        h = hour(f.heure)
        heures_freq[h] = get(heures_freq, h, 0) + f.montees
    end
    
    # Calculer la moyenne
    moyenne = mean(values(heures_freq))
    
    # Heures de pointe = heures avec fréquentation > 1.5 * moyenne
    heures_pointe = [h for (h, freq) in heures_freq if freq > 1.5 * moyenne]
    
    return sort(heures_pointe)
end

"""
    calculer_statistiques_globales(systeme::SystemeSOTRACO)
Calcule les statistiques globales du réseau
"""
function calculer_statistiques_globales(systeme::SystemeSOTRACO)
    println("\n📊 Calcul des statistiques globales...")
    
    stats = Dict{String, Any}()
    
    # Nombre total d'arrêts, lignes, etc.
    stats["nombre_arrets"] = length(systeme.arrets)
    stats["nombre_lignes"] = length(systeme.lignes)
    stats["nombre_enregistrements"] = length(systeme.frequentations)
    
    # Statistiques sur les lignes
    lignes_actives = filter(l -> l.statut == "Actif", systeme.lignes)
    stats["lignes_actives"] = length(lignes_actives)
    stats["lignes_inactives"] = length(systeme.lignes) - length(lignes_actives)
    
    # Statistiques sur les arrêts
    arrets_avec_abri = filter(a -> a.abribus, systeme.arrets)
    arrets_eclaires = filter(a -> a.eclairage, systeme.arrets)
    stats["arrets_avec_abri"] = length(arrets_avec_abri)
    stats["arrets_eclaires"] = length(arrets_eclaires)
    
    # Statistiques de fréquentation
    if !isempty(systeme.frequentations)
        stats["montees_totales"] = sum(f.montees for f in systeme.frequentations)
        stats["descentes_totales"] = sum(f.descentes for f in systeme.frequentations)
        
        taux_occupations = [f.occupation_bus / f.capacite_bus for f in systeme.frequentations if f.capacite_bus > 0]
        stats["taux_occupation_moyen"] = mean(taux_occupations)
        
        # Heures de pointe
        stats["heures_pointe"] = identifier_heures_pointe(systeme.frequentations)
    end
    
    println("✅ Statistiques globales calculées")
    return stats
end