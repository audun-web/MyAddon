print("Addon has loaded!")


local settingsPanel = CreateFrame("Frame", "ActionCamSettingsPanel", UIParent, "BackdropTemplate")
settingsPanel:SetSize(700, 500)
settingsPanel:SetPoint("CENTER")

settingsPanel:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",  -- background texture
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",    -- border texture
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

settingsPanel:SetBackdropColor(0, 0, 0, 0.8)
 --settingsPanel:Hide()

