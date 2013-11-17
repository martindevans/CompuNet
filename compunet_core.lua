local sides = { "front", "back", "left", "right", "top", "bottom" };

function Panic(message)
	SetTextColor(colors.red);
	print(message);
	print("Reinstall CompuNet From An Install Disk");
	os.sleep(30);
	os.shutdown();
end

--Sets the text color (if this monitor supports it)
local currentTerminalColor = 256;
function SetTextColor(color)
	if term.isColor() then
		term.setTextColor(color);
	end
	currentTerminalColor = color;
end

local drivers = {};
function RegisterDriver(name, driver)
    if drivers[name] then
        print("Driver conflict! 2 drivers registered for " .. name);
    end
    drivers[name] = driver;
end

local peripherals = {};
function SetupPeripherals(components)
	print("Locating Hardware Peripherals");

    local peripheralsByType = {};
	for _,name in ipairs(peripheral.getNames()) do
		local peripheralType = peripheral.getType(name);
        
        local p = peripheralsByType[peripheralType] or {};
        table.insert(p, name);
        peripheralsByType[peripheralType] = p;
	end
    
    for peripheralType,arr in pairs(peripheralsByType) do
        local driverHandle = drivers[peripheralType];
    
        if not driverHandle then
			SetTextColor(colors.red);
			print(" - No Device Driver Located For: " .. peripheralType);
			SetTextColor(colors.lightGray);
		else
            driverHandle.Drive(arr);
            print(" - Loaded Driver For: " .. peripheralType);
        end
    end
end

function LoadComponent(filename, pubkey, components)
	print(" - Loading " .. filename);

	if not fs.exists(filename) then
		Panic("OS is critically damaged! (Component " .. filename .. " is missing)");
	end

	if not cryptography.VerifyFileSignature(filename, pubkey) then
		Panic("OS is critically damaged! (Component " .. filename .. " Failed Signature Check)");
	end

	if not os.loadAPI(filename) then
		panic("OS is critically damaged! (Component " .. filename .. " Failed To Load");
	end

	table.insert(components, filename);
end

function LoadComponents(pubkey)
	local components = {};

	if not fs.exists("__compunet.bootmanifest") then
		Panic("OS is critically damaged! (Boot manifest file is missing)");
	end

	local manifestHandle = fs.open("__compunet.bootmanifest", "r");
	
    repeat
        local line = manifestHandle.readLine()
        if line then
            LoadComponent(line, pubkey, components);
        end
    until not line

	manifestHandle.close();

	return components;
end

function LoadPublicKey()
	if not fs.exists("compunet.publickey") then
		Panic("OS is critically damaged! (Security Verification Key Is Missing)");
	end
	local keyhandle = fs.open("compunet.publickey", "r");
	local publicKey = keyhandle.readAll();
	keyhandle.close();
	return publicKey;
end

local publicKey = "";
local components = {};
function Boot()
    print("Loading OS Verification Key");
    publicKey = LoadPublicKey();

    os.loadAPI("cryptography");
    
    print("Loading OS components from boot manifest");
    components = LoadComponents(publicKey);

    print("Connecting To Hardware peripherals");
    SetupPeripherals(components);
    
    goroutine.run(function()
        local status, err = pcall(sshell.Run);
        print("sshell exited: " .. tostring(status));
        print("sshell error: " .. tostring(err));
    end)
    
    print("Scheduler exited, shutting down");
    os.sleep(10);
    os.shutdown();
end
