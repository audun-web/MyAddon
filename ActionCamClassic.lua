print("ActionCamClassic has loaded!") -- en print i chatten for å bekrefte at alt har lastet inn


--------------------------------------------------------------------------------------------------------------

local frame = CreateFrame("Frame", "MainWindow", UIParent, "BackdropTemplate") -- oppretter vinduet for addonen - Frame = type objekt

frame:SetSize(480, 280) -- mer kompakt vindu som passer innholdet bedre (litt bredere for bedre lesbarhet)

frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0) -- posisjon på vinduet

frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", -- bakgrunn filen som er i spill mappen
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", -- kant tekstur som ligger i spill mappen
    edgeSize = 16 -- størrelse på kanten
})

frame:Hide() -- gjør vinduet usynlig

tinsert(UISpecialFrames, frame:GetName()) -- innebygd funksjon i WoW filene for å lukke frame ved å trykke "esc"

--------------------------------------------------------------------------------------------------------------

SLASH_ACTIONCAM1 = "/acc"

SlashCmdList["ACTIONCAM"] = function(msg)
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end


--------------------------------------------------------------------------------------------------------------

local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton") -- lager en close knapp i vinduet - bruker en closebutton template som ligger standard i spillet

closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5) -- setter posisjonen på close-knappen til vinduet

local miniButton = CreateFrame("Button", "ActionCamClassicMiniButton", Minimap) -- lager en knapp på minimappet "Minimap" gjør at den er festet til minimappet
miniButton:SetSize(31, 31) -- klassisk størrelse for minimap-knapper (samme som mange pro addons bruker)
miniButton:SetPoint("CENTER", Minimap, "CENTER", 80, 0) -- startposisjon før vi bruker vinkel-funksjonen

-- sørg for at knappen ligger over minimappet
miniButton:SetFrameStrata("HIGH")
miniButton:SetFrameLevel(Minimap:GetFrameLevel() + 5)

-- ikon inni knappen (addon-logoen)
-- bruker SetNormalTexture slik at "minimap button collector" addons lettere kan finne knappen
miniButton:SetNormalTexture("Interface\\AddOns\\ActionCamClassic\\docs\\img\\ACC-logo.png")
local miniButtonIcon = miniButton:GetNormalTexture()
miniButtonIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9) -- kutter hjørnene litt for rundere følelse
-- klassisk plassering brukt av mange addons, tilpasset MiniMap-TrackingBorder
miniButtonIcon:ClearAllPoints()
miniButtonIcon:SetPoint("TOPLEFT", miniButton, "TOPLEFT", 7, -5)
miniButtonIcon:SetPoint("BOTTOMRIGHT", miniButton, "BOTTOMRIGHT", -5, 7)
miniButton.icon = miniButtonIcon

-- pushed texture (litt mørkere når man klikker)
miniButton:SetPushedTexture("Interface\\AddOns\\ActionCamClassic\\docs\\img\\ACC-logo.png")
local miniButtonPushed = miniButton:GetPushedTexture()
miniButtonPushed:SetTexCoord(0.1, 0.9, 0.1, 0.9)
miniButtonPushed:ClearAllPoints()
miniButtonPushed:SetPoint("TOPLEFT", miniButton, "TOPLEFT", 8, -6)
miniButtonPushed:SetPoint("BOTTOMRIGHT", miniButton, "BOTTOMRIGHT", -6, 8)
miniButtonPushed:SetVertexColor(0.8, 0.8, 0.8, 1)

-- gull-sirkel rundt, samme stil som mange profesjonelle addons bruker
local miniButtonBorder = miniButton:CreateTexture(nil, "OVERLAY")
miniButtonBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
miniButtonBorder:SetPoint("TOPLEFT", miniButton, "TOPLEFT", 0, 0) -- denne texturen er laget for å starte i TOPLEFT på en 31x31-knapp
miniButtonBorder:SetSize(53, 53)
miniButton.border = miniButtonBorder

-- highlight når man hovere knappen (WoW håndterer plasseringen når vi bare gir den texturen)
miniButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

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

miniButton:SetScript("OnEnter", function(self) -- OnEnter betyr når musen begynner å hovere objektet
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT") -- GameTooltip er innebygd tooltip funksjon i spillfilene
    GameTooltip:SetText("ActionCamClassic", 1, 1, 1) -- tittelen på tooltip framen
    GameTooltip:AddLine(" ", 1, 1, 1)
    GameTooltip:AddLine("Left Click: Open settings", 0.8, 0.8, 0.8) -- ny linje tekst på tooltip framen
    GameTooltip:AddLine("Drag: Move minimap button", 0.8, 0.8, 0.8)
    GameTooltip:AddLine("Command: /acc opens the panel", 0.8, 0.8, 0.8)
    GameTooltip:Show()
end)

miniButton:SetScript("OnLeave", function(self) -- når musen forlater hover av objekter
    GameTooltip:Hide()
end)



--------------------------------------------------------------------------------------------------------------

-- startvinkel for minimap-knappen (0 grader = høyre side av minimappet)
local miniAngle = 180 -- 180 grader er høyre side av minimappet

local function UpdateMiniButtonPosition() -- ai generert funksjon for å kunne dra knappen rundt minimappet
    local radius = 80 -- større radius for å plassere knappen utenfor minimappet, men fortsatt festet
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

-- tekst i panelet for å vise tilbakemeldinger i stedet for å spamme chatten
local statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
statusText:SetText("")

-- hjelpefunksjon for å sette status-tekst som forsvinner etter 3 sekunder
local function SetStatusText(message)
    statusText:SetText(message or "")

    if message and message ~= "" then
        local currentMessage = message
        statusText.currentMessage = currentMessage

        C_Timer.After(3, function()
            if statusText.currentMessage == currentMessage then
                statusText:SetText("")
            end
        end)
    end
end

local mountCamButton = CreateFrame("Button", "MountCamButton", frame, "UIPanelButtonTemplate") -- legger til knapp
mountCamButton:SetSize(80, 32) -- knapp størrelse
mountCamButton:SetText("Off") -- startteksten på knappen hver gang du åpner spillet

local eventFrame = CreateFrame("Frame") -- legger til en tom frame
eventFrame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED") -- gir framen en funksjon som leter etter in-game events
eventFrame:SetScript("OnEvent", function(self, event) -- script når valgt event skjer
    if mountButtonStatus then -- kjør bare når knappen er aktivert
        if IsMounted() then -- IsMounted er en funksjon i spillet som sier at spilleren rir på hest
            ConsoleExec("ActionCam full") -- konsoll kommando i spillet
            ConsoleExec("ActionCam focusOff") 
            ConsoleExec("ActionCam noHeadMove")
        else
            ConsoleExec("ActionCam off")
        end
    end
end)

mountCamButton:SetScript("OnClick", function() -- funksjon når knappen trykkes
    mountButtonStatus = not mountButtonStatus -- setter boolean til den motsatte verdien av hva den allerede er
    if mountButtonStatus then
        mountCamButton:SetText("On")
        SetStatusText("ActionCam when Mounted: On")
    else
        mountCamButton:SetText("Off")
        -- slå av ActionCam direkte hvis man deaktiverer knappen mens man er mounted
        if IsMounted() then
            ConsoleExec("ActionCam off")
        end
        SetStatusText("ActionCam when Mounted: Off")
    end
end)

--------------------------------------------------------------------------------------------------------------

local mountCamTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge") -- legger til en tekst - overlay betyr at den ligger over frame

mountCamTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -75) -- litt mer margin for bedre spacing
mountCamTitle:SetText("ActionCam when Mounted") -- teksten

-- plasser status-tekst under hovedtittelen på panelet
statusText:ClearAllPoints()
statusText:SetPoint("TOP", titleText, "BOTTOM", 0, -28)

-- plasser knappen midt under teksten over
mountCamButton:ClearAllPoints() -- fjerner alle tidligere ankre hvor knappen er festet
mountCamButton:SetPoint("TOP", mountCamTitle, "BOTTOM", 0, -10) -- setter posisjonen til knappen

--------------------------------------------------------------------------------------------------------------

-- Lage en horisontal divider under tittelen
local titleDivider = frame:CreateTexture(nil, "ARTWORK") -- legger til en divider linje
titleDivider:SetColorTexture(0.6, 0.6, 0.6, 1) -- grå linje, RGBA
titleDivider:SetSize(440, 1) -- bredde og høyde (1 px tynn) tilpasset nytt, mindre vindu
titleDivider:SetPoint("TOP", titleText, "BOTTOM", 0, -10) -- 10 px under tittelen

--------------------------------------------------------------------------------------------------------------

local actionCamSettingsTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge") -- legger til et tekst element

-- Setter teksten på riktig sted i framen
actionCamSettingsTitle:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -75) -- mer luft fra kanten og bedre spacing mot venstre tittel
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
    SetStatusText("All ActionCam settings turned off")
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
        -- TurnAllOff() oppdaterer statusText
    else
        actionCamFullEnabled = true
        ConsoleExec("ActionCam full")
        fullButton:SetText("ActionCam Full: On")
        SetStatusText("ActionCam Full: On")
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
        -- TurnAllOff() oppdaterer statusText
    else
        actionCamNoHeadMoveEnabled = true
        ConsoleExec("ActionCam noHeadMove")
        noHeadMoveButton:SetText("No Head Move: On")
        SetStatusText("No Head Move: On")
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
        -- TurnAllOff() oppdaterer statusText
    else
        actionCamFocusOffEnabled = true
        ConsoleExec("ActionCam focusOff")
        focusOffButton:SetText("Focus Off: On")
        SetStatusText("Focus Off: On")
    end
end)



--------------------------------------------------------------------------------------------------------------

-- SavedVariables for å lagre innstillinger mellom innlogginger/reload
local savedVarsFrame = CreateFrame("Frame")

savedVarsFrame:RegisterEvent("ADDON_LOADED")
savedVarsFrame:RegisterEvent("PLAYER_LOGOUT")

savedVarsFrame:SetScript("OnEvent", function(self, event, arg1) -- script som kjøres når spiller logger av og addon
    if event == "ADDON_LOADED" and arg1 == "ActionCamClassic" then
        
        ActionCamClassicDB = ActionCamClassicDB or {} -- sørg for at tabellen finnes

        -- sett standardverdier hvis de ikke finnes fra før
        if ActionCamClassicDB.miniAngle == nil then
            ActionCamClassicDB.miniAngle = 180
        end
        if ActionCamClassicDB.mountButtonStatus == nil then
            ActionCamClassicDB.mountButtonStatus = false
        end
        if ActionCamClassicDB.actionCamFullEnabled == nil then
            ActionCamClassicDB.actionCamFullEnabled = false
        end
        if ActionCamClassicDB.actionCamNoHeadMoveEnabled == nil then
            ActionCamClassicDB.actionCamNoHeadMoveEnabled = false
        end
        if ActionCamClassicDB.actionCamFocusOffEnabled == nil then
            ActionCamClassicDB.actionCamFocusOffEnabled = false
        end

        -- last inn verdier til lokale variabler
        miniAngle = ActionCamClassicDB.miniAngle
        mountButtonStatus = ActionCamClassicDB.mountButtonStatus
        actionCamFullEnabled = ActionCamClassicDB.actionCamFullEnabled
        actionCamNoHeadMoveEnabled = ActionCamClassicDB.actionCamNoHeadMoveEnabled
        actionCamFocusOffEnabled = ActionCamClassicDB.actionCamFocusOffEnabled

        -- oppdater UI til lagrede verdier
        UpdateMiniButtonPosition()

        if mountButtonStatus then
            mountCamButton:SetText("On")
        else
            mountCamButton:SetText("Off")
        end

        if actionCamFullEnabled then
            fullButton:SetText("ActionCam Full: On")
            ConsoleExec("ActionCam full")
        else
            fullButton:SetText("ActionCam Full: Off")
        end

        if actionCamNoHeadMoveEnabled then
            noHeadMoveButton:SetText("No Head Move: On")
            ConsoleExec("ActionCam noHeadMove")
        else
            noHeadMoveButton:SetText("No Head Move: Off")
        end

        if actionCamFocusOffEnabled then
            focusOffButton:SetText("Focus Off: On")
            ConsoleExec("ActionCam focusOff")
        else
            focusOffButton:SetText("Focus Off: Off")
        end

    elseif event == "PLAYER_LOGOUT" then
        -- lagre nåværende verdier når spilleren logger ut eller gjør /reload
        ActionCamClassicDB = ActionCamClassicDB or {}

        ActionCamClassicDB.miniAngle = miniAngle
        ActionCamClassicDB.mountButtonStatus = mountButtonStatus
        ActionCamClassicDB.actionCamFullEnabled = actionCamFullEnabled
        ActionCamClassicDB.actionCamNoHeadMoveEnabled = actionCamNoHeadMoveEnabled
        ActionCamClassicDB.actionCamFocusOffEnabled = actionCamFocusOffEnabled
    end
end)

--------------------------------------------------------------------------------------------------------------

warningText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")

warningText:SetText([[TURNING OFF ONE,
TURNS OFF THEM ALL!]])

warningText:ClearAllPoints() -- fjerner alle tidligere ankre hvor knappen er festet
warningText:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 15, 20) -- setter posisjonen til teksten så den passer i det nye, mindre vinduet

--------------------------------------------------------------------------------------------------------------

-- Reset til standardverdier knapp
local resetButton = CreateFrame("Button", "ResetButton", frame, "UIPanelButtonTemplate")
resetButton:SetText("Reset to Default")
resetButton:SetSize(resetButton:GetFontString():GetStringWidth() + 20, 26)
resetButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -15, 15) -- nederst høyre hjørne

resetButton:SetScript("OnClick", function()
    -- ActionCam settings
    TurnAllOff()

    -- mount setting
    mountButtonStatus = false
    mountCamButton:SetText("Off")

    -- minimap button position
    miniAngle = 180
    UpdateMiniButtonPosition()

    -- oppdater SavedVariables med en gang (slik at /reload også husker reset)
    ActionCamClassicDB = ActionCamClassicDB or {}
    ActionCamClassicDB.miniAngle = miniAngle
    ActionCamClassicDB.mountButtonStatus = mountButtonStatus
    ActionCamClassicDB.actionCamFullEnabled = actionCamFullEnabled
    ActionCamClassicDB.actionCamNoHeadMoveEnabled = actionCamNoHeadMoveEnabled
    ActionCamClassicDB.actionCamFocusOffEnabled = actionCamFocusOffEnabled

    SetStatusText("All ActionCamClassic settings reset to default")
end)

