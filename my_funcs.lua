function split(str, sep)
    local result = {}
    local regex = ("([^%s]+)"):format(sep)
    for each in str:gmatch(regex) do
        table.insert(result, each)
    end
    return result
end

-- Возвращает конфигурацию сети
function GetNetworkConf()
	print();
	print("=======================================");
	print("STATION network configuration");
	vIPv4addr, vNetmask, vGateway = wifi.sta.getip();
	print("    IPv4 address:",vIPv4addr);
	print("     Subnet Mask:",vNetmask);
	print(" Default Gateway:",vGateway);
	print("Physical Address:",wifi.sta.getmac());
	print();
	print("AP network configuration");
	vIPv4addr, vNetmask, vGateway = wifi.ap.getip();
	print("    IPv4 address:",vIPv4addr);
	print("     Subnet Mask:",vNetmask);
	print(" Default Gateway:",vGateway);
	print("Physical Address:",wifi.ap.getmac());
	print("=======================================");
end -- function GetNetworkConf()


-- Отправка данных на сервер GET запросом
function SendData(iURL, iPPM, iTemp, iHumi)
	-- Отправляем данные на сервер
	http.get(	gURL.."?ppm="..iPPM.."&temp="..iTemp.."&humi="..iHumi,
				nil,
				function(status, body)
				    if status == 200 then
				        print("Data transfer - OK")
				    else
				    	print("Data transfer - ERROR ",status)
				    	print(gURL.."?ppm="..iPPM.."&temp="..iTemp.."&humi="..iHumi);
				    end
				end );
	collectgarbage();
	return;
end -- function SendData(iURL, iPPM, iTemp, iHumi)


-- Получение данных с датчиков
function GetData()
	dofile('get-data-co2.lua');
	gTemp, gHumi = GetDataDHT11();
	print("PPM = "..gPPM.." Temp = "..gTemp.." Humi = "..gHumi);
end -- function GetData()


-- Функция формирования таблицы доступных точек-доступа
function GetAPList(iTbl) -- (SSID : Authmode, RSSI, BSSID, Channel)
    gAPList = gAPList..
    "<TABLE><TR><TD><CENTER>SSID</CENTER></TD><TD><CENTER>MAC</CENTER></TD><TR>"
    for ssid,v in pairs(iTbl) do
        local authmode, rssi, bssid, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]+)")
        gAPList = gAPList.."<TR><TD>"..
        		  string.format("%32s",ssid).."</TD><TD>"..bssid.."</TD></TR>"
    end
    gAPList = gAPList.."</TABLE>"
end -- function GetAPList(iTbl)


-- Функция чтения данных с датчиков, и отправка на сервер
function ProceedData()
	tmr.alarm(	gIdntTmrSensReading,
				gFreqSensReading,
				tmr.ALARM_AUTO,
				function()
					-- Получаем данные
					GetData();
					-- Проверяем статус сети
					if wifi.sta.status() ~= 5 then
						-- Если соединения нет, останавливаем текущий таймер
						tmr.stop(gIdntTmrSensReading);
						-- Сообщаем
						print("Connection lost...")
						-- Флаг того что соединения нет
						gAPConnectAvail = false;
						-- Запускаем таймер проверки наличия
						-- подключения через 5 минут
						tmr.start(gIdntTmrConnAP);
					elseif gCanSend and gAPConnectAvail then
						-- В случае если соединение есть и данные "честные" - ШЛЁМ
						SendData(gURL,gPPM,gTemp,gHumi);
					end
					collectgarbage();
				end)
end -- function ProceedData()


-- Получаем данные с датчика DHT11
function GetDataDHT11()
	-- Файл для получения данных с датчика DHT11, записываются в переменную gTemp (Температура) и gHumi (Влажность)
	Status, Temp, Humi, Temp_dec, Humi_dec = dht.read11(gDHTpin)
	if status == dht.ERROR_CHECKSUM then
		print( "DHT Checksum error." )
	elseif status == dht.ERROR_TIMEOUT then
		print( "DHT timed out." )
	end
	collectgarbage();
	return Temp, Humi;
end -- function GetDataDHT11()

-- Процедура проверки подключения и запуска опроса сенсоров
function StartSendData()

	local vConnCNT=0;

	tmr.alarm(	gIdntTmrStartSendData,
			2000,
			tmr.ALARM_AUTO,
			function()
				print("Attemp to connect to the AP #",vConnCNT+1);
				if wifi.sta.status() ~= 5 then
					vConnCNT = vConnCNT + 1;
					-- По истечении 20 секунд, в случае если
					-- подключение не установлено сообщаем об этом
					-- и больше не проверяем
					if vConnCNT > 9 then
						print("Failed to connect AP");
						-- Флаг того что соединения нет
						gAPConnectAvail = false;
						-- Останавливаем текущий таймер
						tmr.stop(gIdntTmrStartSendData);
						-- Опеределяем состояние таймера проверки наличия
						-- подключения через 5 минут
						running, mode = tmr.state(gIdntTmrConnAP);
						-- Запускаем если не работает
						if running == false then
							tmr.start(gIdntTmrConnAP);
						end
					end
				else
					-- Если соединение установлено, останавливаем текущий таймер
				    tmr.stop(gIdntTmrStartSendData);
				    -- так же останавливаем таймер проверки наличия
					-- подключения через 5 минут
				    tmr.stop(gIdntTmrConnAP);
				    -- Устанавливаем флаг того что подключение установлено
				    gAPConnectAvail = true;
				    -- Выводим конфигурацию сети
				    GetNetworkConf();
				    -- Работа с датчиками
				    ProceedData();
				end
			end)
end -- function StartSendData()
