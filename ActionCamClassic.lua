print("ActionCamClassic has loaded!")

local frame = CreateFrame("Frame", "MyFirstWindow", UIParent, "BackdropTemplate")

frame:SetSize(500, 350)

frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    edgeSize = 16
})

frame:Show()

local button = CreateFrame("Button", "MyToggleButton", UIParent, "UIPanelButtonTemplate")

button:SetSize(120, 30)
button:SetPoint("CENTER", UIParent, "CENTER", 400, -150)
button:SetText("Toggle Window")

button:SetScript("OnClick", function()
    if frame:IsShown() then
        frame:Hide()
        print("Window Hidden")
    else
        frame:Show()
        print("Frame Shown")
    end
end)
