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

function SetupPeripherals()
	print("Locating Hardware Peripherals");

	for _,name in ipairs(peripheral.getNames()) do
		print(name);
	end
end

function LoadComponent(filename, pubkey)
	print("Loading " .. filename);

	if not fs.exists(line) then
		Panic("OS is critically damaged! (Component " .. line .. " is missing)");
	end


	if not VerifyFileSignature(line, pubkey) then
		Panic("OS is critically damaged! (Component " .. line .. " Failed Signature Check)");
	end

	os.loadAPI(filename);
end

function LoadComponents(pubkey)
	if not fs.exists("__compunet.bootmanifest") then
		Panic("OS is critically damaged! (Boot manifest file is missing)");
	end

	local manifestHandle = fs.open("__compunet.bootmanifest", "r");
	local line = manifestHandle.readLine();
	while line do
		LoadComponent(line, pubkey);
		line = manifestHandle.readLine();
	end

	manifestHandle.close();
end

local publicKey = "";
function LoadPublicKey()
	if not fs.exists("compunet.publickey") then
		Panic("OS is critically damaged! (Security Verification Key Is Missing)");
	end
	local keyhandle = fs.open("compunet.publickey", "r");
	local publicKey = keyhandle.readAll();
	keyhandle.close();
	return publicKeyl
end

function Boot()
	print("Loading OS Verification Key");
	publicKey = LoadPublicKey();

	print("Loading OS components from boot manifest");
	LoadComponents(publicKey);

	print("Connecting To Hardware peripherals");
	SetupPeripherals();
end

local args = {...};
Boot();
