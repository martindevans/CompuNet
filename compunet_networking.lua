function CreateDriver()
    function Announce()
        
    end

    local modems = {};
    return {
        Drive = function(peripherals)
            for _,p in ipairs(peripherals) do
                table.insert(modems, peripheral.wrap(p));
            end
            
            --This is the blocking method to read packets:
            --local _, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message");
            --What's the non blocking way!?
        end,
        
        Devices = function()
            return modems;
        end
    };
end

local networkDriver = CreateDriver();
compunet_core.RegisterDriver("modem", networkDriver);

function IsOpen(channel)
    for _,m in ipairs(networkDriver.Devices()) do
        if m.isOpen(channel) then return true; end
    end
    return false;
end

function Open(channel)
    for _,m in ipairs(networkDriver.Devices()) do
        m.open(channel);
    end
end

function Close(channel)
    for _,m in ipairs(networkDriver.Devices()) do
        m.close(channel);
    end
end

function CloseAll()
    for _,m in ipairs(networkDriver.Devices()) do
        m.closeAll();
    end
end

function Transmit(channel, replyChannel, message, device)
    local m = networkDriver.Devices()[device or 1];
    m.transmit(channel, replyChannel, message);
end