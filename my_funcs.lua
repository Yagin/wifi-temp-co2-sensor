function split(str, sep)
    local result = {}
    local regex = ("([^%s]+)"):format(sep)
    for each in str:gmatch(regex) do
        table.insert(result, each)
    end
    return result
end

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
	tmr.alarm(	2,
				gFreqSensReading,
				tmr.ALARM_AUTO,
				function()
					GetData();
					if gCanSend then
						SendData(gURL,gPPM,gTemp,gHumi);
					end
					collectgarbage();
				end)
end -- function ProceedData()


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
