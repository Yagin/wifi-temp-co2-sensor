-- Файл подключения к точке-доступа
local APREQ="ap_server.lua";
wifi.setmode(wifi.STATIONAP);
cfg={};
cfg.ssid = "node-" .. node.chipid();
cfg.pwd  = "node-" .. node.chipid();

wifi.ap.config(cfg);

print("AP network configuration");
print(wifi.ap.getip());

dofile(APREQ)

if file.open(gConfgiFile,"r") then
	lines = split(file:read(), "\n");
	if lines ~= nil then
		AP_SSID = lines[1];
		AP_pass = lines[2];
		file.close();
	end
	wifi.sta.config(AP_SSID, AP_pass);
	wifi.sta.connect();
	wifi.sta.autoconnect(1)
end -- if file.open(gConfgiFile,"r") then

collectgarbage();
