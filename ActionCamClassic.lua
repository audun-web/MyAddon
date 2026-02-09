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

frame:Hide() -- gjør vinduet usynlig

tinsert(UISpecialFrames, frame:GetName()) -- innebygd funksjon i WoW filene for å lukke frame ved å trykke "esc"


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
    if button == "LeftButton" then -- hvis knappen trykket ned er venstre museknapp
        self.isDragging = true -- sier at knappen nå dras
    end
end)

miniButton:SetScript("OnMouseUp", function(self, button) -- script for når du trykket med musen
    if button == "LeftButton" then
        self.isDragging = false -- sier at knappen ikke dras
    end
end)

--------------------------------------------------------------------------------------------------------------

-- startvinkel for minimap-knappen (0 grader = høyre side av minimappet)
local miniAngle = 180 -- 180 grader er høyre side av minimappet

local function UpdateMiniButtonPosition() -- ai generert funksjon for å kunne dra knappen rundt minimappet
    local radius = 80
    local rad = miniAngle * math.pi / 180
    local x = radius * math.cos(rad)
    local y = radius * math.sin(rad)
    
    miniButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

UpdateMiniButtonPosition()

--------------------------------------------------------------------------------------------------------------

local updateFrame = CreateFrame("Frame") -- legger til en tom frame, usynlig
updateFrame:SetScript("OnUpdate", function(self, elapsed) -- script som går hele tiden og venter på at noe skjer
    if miniButton.isDragging then -- hvis minimap knappen blir dratt
        
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
local mountButtonStatus = false -- true eller false her er av eller på i instillingspanelet i spillet

local mountCamButton = CreateFrame("Button", "MountCamButton", frame, "UIPanelButtonTemplate") -- legger til knapp
mountCamButton:SetSize(80, 32) -- knapp størrelse
mountCamButton:SetText("Off") -- startteksten på knappen hver gang du åpner spillet

local eventFrame = CreateFrame("Frame") -- legger til en tom frame
eventFrame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED") -- gir framen en funksjon som leter etter in-game events
eventFrame:SetScript("OnEvent", function(self, event) -- script når valgt event skjer
    if mountButtonStatus then -- kjør bare når knappen er aktivert
        if IsMounted() then -- IsMounted er en funksjon i spillet som sier at spilleren rir på hest
            print("Mounted") -- print funksjon i chat
            ConsoleExec("ActionCam full") -- konsoll kommando i spillet
            ConsoleExec("ActionCam focusOff") 
            ConsoleExec("ActionCam noHeadMove")
        else
            print("Dismounted")

            ConsoleExec("ActionCam off")
        end
    end
end)

mountCamButton:SetScript("OnClick", function() -- funksjon når knappen trykkes
    mountButtonStatus = not mountButtonStatus -- setter boolean til den motsatte verdien av hva den allerede er
    if mountButtonStatus then
        mountCamButton:SetText("On")
    else
        mountCamButton:SetText("Off")
        -- slå av ActionCam direkte hvis man deaktiverer knappen mens man er mounted
        if IsMounted() then
            ConsoleExec("ActionCam off")
        end
    end
end)

--------------------------------------------------------------------------------------------------------------

local mountCamTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge") -- legger til en tekst - overlay betyr at den ligger over frame

mountCamTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -75) -- setter posisjon til teksten
mountCamTitle:SetText("ActionCam when Mounted") -- teksten

-- plasser knappen midt under teksten over
mountCamButton:ClearAllPoints() -- fjerner alle tidligere ankre hvor knappen er festet
mountCamButton:SetPoint("TOP", mountCamTitle, "BOTTOM", 0, -10) -- setter posisjonen til knappen

--------------------------------------------------------------------------------------------------------------

-- Lage en horisontal divider under tittelen
local titleDivider = frame:CreateTexture(nil, "ARTWORK") -- legger til en divider linje
titleDivider:SetColorTexture(0.6, 0.6, 0.6, 1) -- grå linje, RGBA
titleDivider:SetSize(560, 1) -- bredde og høyde (1 px tynn)
titleDivider:SetPoint("TOP", titleText, "BOTTOM", 0, -10) -- 10 px under tittelen

--------------------------------------------------------------------------------------------------------------

local actionCamSettingsTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge") -- legger til et tekst element

-- Setter teksten på riktig sted i framen
actionCamSettingsTitle:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -35, -75)
actionCamSettingsTitle:SetText("ActionCam Settings")


--------------------------------------------------------------------------------------------------------------
-- variabler for å bruke en skru av alle funksjon
local actionCamFullEnabled = false
local actionCamNoHeadMoveEnabled = false
local actionCamFocusOffEnabled = false

-- Slår av ALT
local function TurnAllOff()
    actionCamFullEnabled = false
    actionCamNoHeadMoveEnabled = false
    actionCamFocusOffEnabled = false

    ConsoleExec("ActionCam off") -- skrur av alle action cam settings 

    -- endrer teksten på de tre knappene for å matche settings statusen
    fullButton:SetText("ActionCam Full: Off")
    noHeadMoveButton:SetText("No Head Move: Off")
    focusOffButton:SetText("Focus Off: Off")

    print("All ActionCam settings turned off") -- print i chat for å bekrefte settings endringen
end


--------------------------------------------------------------------------------------------------------------
-- ActionCam Full
fullButton = CreateFrame("Button", "FullButton", frame, "UIPanelButtonTemplate")
fullButton:SetText("ActionCam Full: Off")
fullButton:SetSize(fullButton:GetFontString():GetStringWidth() + 20, 32) -- setter størrelsen, gjør størrelsen på knappen til å matche string størrelsen
fullButton:SetPoint("TOP", actionCamSettingsTitle, "BOTTOM", 0, -10) -- setter posisjonen til knappen i midten av actionCamSettingsTitle

fullButton:SetScript("OnClick", function() -- script for å skru av og på knappen/knappene
    if actionCamFullEnabled then
        TurnAllOff()
    else
        actionCamFullEnabled = true
        ConsoleExec("ActionCam full")
        fullButton:SetText("ActionCam Full: On")
    end
end)

--------------------------------------------------------------------------------------------------------------
-- No Head Move
noHeadMoveButton = CreateFrame("Button", "NoHeadMoveButton", frame, "UIPanelButtonTemplate")
noHeadMoveButton:SetText("No Head Move: Off")
noHeadMoveButton:SetSize(noHeadMoveButton:GetFontString():GetStringWidth() + 20, 32)
noHeadMoveButton:SetPoint("TOP", fullButton, "BOTTOM", 0, -8)

noHeadMoveButton:SetScript("OnClick", function()
    if actionCamNoHeadMoveEnabled then
        TurnAllOff()
    else
        actionCamNoHeadMoveEnabled = true
        ConsoleExec("ActionCam noHeadMove")
        noHeadMoveButton:SetText("No Head Move: On")
    end
end)

--------------------------------------------------------------------------------------------------------------
-- Focus Off
focusOffButton = CreateFrame("Button", "FocusOffButton", frame, "UIPanelButtonTemplate")
focusOffButton:SetText("Focus Off: Off")
focusOffButton:SetSize(focusOffButton:GetFontString():GetStringWidth() + 20, 32)
focusOffButton:SetPoint("TOP", noHeadMoveButton, "BOTTOM", 0, -8)

focusOffButton:SetScript("OnClick", function()
    if actionCamFocusOffEnabled then
        TurnAllOff()
    else
        actionCamFocusOffEnabled = true
        ConsoleExec("ActionCam focusOff")
        focusOffButton:SetText("Focus Off: On")
    end
end)



--------------------------------------------------------------------------------------------------------------

warningText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")

warningText:SetText([[TURNING OFF ONE,
TURNS OFF THEM ALL!]])

warningText:ClearAllPoints() -- fjerner alle tidligere ankre hvor knappen er festet
warningText:SetPoint("BOTTOM", focusOffButton, "BOTTOM", 0, -50) -- setter posisjonen til knappen