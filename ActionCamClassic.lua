

local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "ActionCamClassic" then
        print("ActionCamClassic fully initialized!")
    end
end)

local button = CreateFrame("Button", "ActionCamClassicButton", UIParent, "UIPanelButtonTemplate")

button:SetSize(140, 40)

button:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

button:SetText("Action Cam: Off")

button:SetScript("OnClick", function()
    actionCamEnabled = not actionCamEnabled

    if actionCamEnabled then
        print("Action Cam is Enabled!")
        button:SetText("Action Cam: On")
    else
        print("Action Cam is Disabled!")
        button:SetText("Action Cam: Off")
    end
end)
