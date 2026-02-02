print("ActionCamClassic has loaded!") -- en print i chatten for å bekrefte at alt har lastet inn

--------------------------------------------------------------------------------------------------------------

local frame = CreateFrame("Frame", "MainWindow", UIParent, "BackdropTemplate") -- oppretter vinduet for addonen - Frame = type objekt

frame:SetSize(600, 450) -- størrelse på vinduet

frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0) -- posisjon på vinduet

frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", -- bakgrunn filen som er i spill mappen
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", -- kant tekstur som ligger i spill mappen
    edgeSize = 16 -- størrelse på kanten
})

frame:Show() -- gjør vinduet synlig

--------------------------------------------------------------------------------------------------------------

local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton") -- lager en close knapp i vinduet - bruker en closebutton template som ligger standard i spillet

closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5) -- setter posisjonen på close-knappen til vinduet

local miniButton = CreateFrame("Button", "ActionCamClassicMiniButton", Minimap) -- lager en knapp på minimappet "Minimap" gjør at den er festet til minimappet
miniButton:SetSize(32, 32) -- gir knappen en størrelse
miniButton:SetPoint("CENTER", Minimap, "CENTER", 80, 0) -- gir minimap knappen en posisjon

miniButton:SetNormalTexture("Interface\\Icons\\INV_Misc_Gear_01") -- gjør minimap knappen synlig vet et ikon som finnes i spillfilene

miniButton:SetScript("OnClick", function() -- gir knappen en funksjon, lukkes hvis den blir vist, vises hvis den er lukket
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end)

miniButton:SetMovable(true) -- gjør knappen flyttbar
miniButton:EnableMouse(true) -- lar knappen reagere på musen
miniButton:RegisterForDrag("LeftButton") -- lar venstreklikk dra

miniButton:SetScript("OnMouseDown", function(self, button) -- script for når du trykket med musen
    if button == "LeftButton" then
        self.isDragging = true -- sier at knappen nå dras
    end
end)

miniButton:SetScript("OnMouseUp", function(self, button) -- script for når du trykket med musen
    if button == "LeftButton" then
        self.isDragging = false -- sier at knappen ikke dras
    end
end)

--------------------------------------------------------------------------------------------------------------

local miniAngle = 0

local function UpdateMiniButtonPosition()
    local radius = 80
    local rad = miniAngle * math.pi / 180
    local x = radius * math.cos(rad)
    local y = radius * math.sin(rad)
    
    miniButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

UpdateMiniButtonPosition()

--------------------------------------------------------------------------------------------------------------

local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function(self, elapsed)
    if miniButton.isDragging then
        
        local mx, my = GetCursorPosition() -- hent museposisjon
        local scale = UIParent:GetEffectiveScale() -- henter scalen på hele UI
        mx = mx / scale -- finner riktig posisjon i forhold til minimappet
        my = my / scale

        
        local centerX, centerY = Minimap:GetCenter() -- midtpunktet til minimap
        
        
        miniAngle = math.deg(math.atan2(my - centerY, mx - centerX)) -- regn ut vinkelen fra midten av minimap til mus
        
        -- oppdater posisjon
        UpdateMiniButtonPosition()
    end
end)


--------------------------------------------------------------------------------------------------------------

local titleText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge") -- legger til tittel text, OVERLAY gjør at teksten er over vinduet

titleText:SetPoint("TOP", frame, "TOP", 0, -15) -- setter posisjon på teksten, fester den til overlay

titleText:SetText("ActionCamClassic") -- hva teksten sier

--------------------------------------------------------------------------------------------------------------


local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")

eventFrame:SetScript("OnEvent", function()
    if IsMounted() then
        print("Mounted")
        ConsoleExec("ActionCam on")
        ConsoleExec("ActionCam focusOff")
        ConsoleExec("ActionCam noHeadMove")
    else
        print("Dismounted")
        ConsoleExec("ActionCam off")
    end
end)
