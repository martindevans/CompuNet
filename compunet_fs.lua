local function CreateDriveDriver()
    local drives = {};
    return {
        Drive = function(peripherals)
            for _,p in ipairs(peripherals) do
                Mount(peripheral.wrap(p));
            end
        end,
        
        Devices = function()
            return modems;
        end
    };
end

local driveDriver = CreateDriveDriver();
compunet_core.RegisterDriver("drive", driveDriver);

function Mount(device)
    print("Mount this device! " .. tostring(device));
end