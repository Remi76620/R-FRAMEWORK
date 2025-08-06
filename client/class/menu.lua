local menu = zUI.CreateMenu("Véhicule", "Gestion du véhicule", "Intéractions disponibles :", "default", nil, "F1", "Ouvrir le menu")
local vehicules = {"Adder", "Zentorno", "T20", "Osiris"}
local vehiculeIndex = 1
local volumeRadio = 50
local couleurVehicule = "#FF0000"
local couleurs = {"#FF0000", "#00FF00", "#0000FF", "#FFFF00"}
local couleurIndex = 1
local godModeEnabled = false
local plaque = ""
local recherche = ""
local godModItem

zUI.SetItems(menu, function()
    -- Spawn du véhicule sélectionné
    zUI.Button("Faire apparaître", "Spawn le véhicule sélectionné", {}, function(onSelected)
        if onSelected then
            local vehicleHash = GetHashKey(vehicules[vehiculeIndex])
            RequestModel(vehicleHash)
            -- Ici, ajoute la logique de spawn du véhicule
            print("Véhicule spawn :", vehicules[vehiculeIndex])
        end
    end)

    -- God Mode sur le véhicule
    godModItem = zUI.Checkbox("God Mode Véhicule", "Rendre le véhicule invincible", godModeEnabled, {
        IsDisabled = false
    }, function(onSelected)
        if onSelected then
            godModeEnabled = not godModeEnabled
            -- Ici, applique l'invincibilité au véhicule du joueur
            print("God Mode Véhicule :", godModeEnabled)
        end
    end)

    -- Choix du modèle de véhicule
    zUI.List("Modèle", "Choisir le modèle de véhicule", vehicules, vehiculeIndex, {
        IsDisabled = false
    }, function(onSelected, onChange, index)
        if onChange then
            vehiculeIndex = index
        end
        if onSelected then
            print("Modèle sélectionné :", vehicules[vehiculeIndex])
        end
    end)

    -- Volume de la radio du véhicule
    zUI.Slider("Volume Radio", "Régler le volume de la radio", volumeRadio, 5, {
        IsDisabled = false,
        ShowPercentage = true
    }, function(onSelected, onChange, percentage)
        if onChange then
            volumeRadio = percentage
            -- Ici, applique le volume à la radio du véhicule
            print("Volume radio :", volumeRadio)
        end
    end)

    -- Couleur personnalisée
    zUI.ColorPicker("Couleur personnalisée", "Choisir une couleur personnalisée", couleurVehicule, {
        IsDisabled = false
    }, function(onChange, value)
        if onChange then
            couleurVehicule = value
            -- Ici, applique la couleur personnalisée au véhicule
            print("Couleur personnalisée :", couleurVehicule)
        end
    end)

    -- Liste de couleurs prédéfinies
    zUI.ColorsList("Couleur rapide", "Sélectionner une couleur rapide", couleurs, couleurIndex, {
        IsDisabled = false
    }, function(onSelected, onChange, index)
        if onChange then
            couleurIndex = index
        end
        if onSelected then
            -- Ici, applique la couleur sélectionnée au véhicule
            print("Couleur rapide sélectionnée :", couleurs[couleurIndex])
        end
    end)

    -- Changer la plaque d'immatriculation
    zUI.TextArea("Plaque", "Définir la plaque d'immatriculation", plaque, "Ex: ZSQUAD", {
        IsDisabled = false
    }, function(onChange, value)
        if onChange then
            plaque = value
            -- Ici, applique la plaque au véhicule
            print("Plaque définie :", plaque)
        end
    end)

    -- Recherche d'un modèle de véhicule
    zUI.SearchBar("Recherche modèle", "Rechercher un modèle de véhicule", recherche, "Tapez ici...", {
        IsDisabled = false
    }, function(onChange, value)
        if onChange then
            recherche = value
            -- Ici, filtre la liste des véhicules selon la recherche
            print("Recherche :", recherche)
        end
    end)

    -- Lien vers un site d'infos véhicules
    zUI.LinkButton("Infos véhicules", "Ouvrir GTA Wiki", "https://gta.fandom.com/wiki/Vehicles_in_GTA_V", {
        IsDisabled = false
    })

    zUI.Line({"#FF0000", "#00FF00", "#0000FF"})

    zUI.Separator("GESTION DU VÉHICULE", "center")
end)

Citizen.CreateThread(function()
    while true do
        local delay = 2000
        if godModItem == zUI.GetHoveredItem() then
            delay = 200
            zUI.ShowInfoBox(
                "God Mode Véhicule",
                "Rend votre véhicule invincible aux dégâts.",
                "default",
                {
                    { type = "text",    title = "Description", value = "Active ou désactive l’invincibilité du véhicule actuellement utilisé." },
                    { type = "percent", title = "État",        value = godModeEnabled and 100 or 0 },
                    { type = "image",   title = "Aperçu",      value = "https://gta.fandom.com/wiki/File:Vapid_Dominator_GTA_V_FrontQtr.jpg" }
                }
            )
        end
        Citizen.Wait(delay)
    end
end)