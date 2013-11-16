function LoadDeviceDriver(deviceType, name)
	if deviceType ~= "modem" then
		return;
	end

	return deviceType, peripheral.wrap(name);
end
