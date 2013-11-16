local sides = { "front", "back", "left", "right", "top", "bottom" };

function Panic(message)
	SetTextColor(colors.red);
	print(message);
	print("Reinstall Compunet From An Install Disk");
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

--Generates a digital signature
function GenerateSignature(payload, pubKey)
	return "1234";
end

function VerifyFileSignature(filename, pubkey)
	if not fs.exists(filename) or not fs.exists(filename .. ".signature") then
		return false;
	end

	local filehandle = fs.open(filename, "r");
	local data = filehandle.readAll();
	filehandle.close();

	local signaturehandle = fs.open(filename .. ".signature", "r");
	local signature = signaturehandle.readAll();
	signaturehandle.close();

	return GenerateSignature(filehandle, pubkey) == signature;
end

local peripherals = {};
function SetupPeripherals(components)
	print("Locating Hardware Peripherals");

	for _,name in ipairs(peripheral.getNames()) do
		local peripheralType = peripheral.getType(name);

		local driverFound = false;
		for _,c in ipairs(components) do
			local component = _G[c];
			if component.LoadDeviceDriver and type(component.LoadDeviceDriver) == "function" then
				local name, driver = component.LoadDeviceDriver(peripheralType, name);
				if driver then
					driverFound = true;

					local t = peripherals[name] or {};
					table.insert(t, driver);
					peripherals[name] = t;

					print(" - Loaded Driver For: " .. peripheralType .. " " .. name);

					break;
				end
			end
		end

		if not driverFound then
			SetTextColor(colors.red);
			print(" - No Device Driver Located For: " .. peripheralType .. " " .. name);
			SetTextColor(colors.lightGray);
		end
	end
end

function LoadComponent(filename, pubkey, components)
	print(" - Loading " .. filename);

	if not fs.exists(filename) then
		Panic("OS is critically damaged! (Component " .. filename .. " is missing)");
	end


	if not VerifyFileSignature(filename, pubkey) then
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
	local line = manifestHandle.readLine();
	while line do
		LoadComponent(line, pubkey, components);
		line = manifestHandle.readLine();
	end

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
	return publicKeyl
end

local publicKey = "";
local components = {};
function Boot()
	print("Loading OS Verification Key");
	publicKey = LoadPublicKey();

	print("Loading OS components from boot manifest");
	components = LoadComponents(publicKey);

	print("Connecting To Hardware peripherals");
	SetupPeripherals(components);
end
