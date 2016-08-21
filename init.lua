-- Данные с DHT11 считывает только при частоте CPU в 160 MHz
-- пока не разобрался почему
node.setcpufreq(node.CPU160MHZ);

wifi.setmode(wifi.STATIONAP);

-- "подключаем" переменные
dofile("my_vars.lua");
-- "подключаем" функции
dofile("my_funcs.lua");
-- Подключаемся к AP
dofile("ap_config.lua");

-- Основная процедура отправки данных на сервер
StartSendData();

-- Таймер на случай если нет доступа в интернет
tmr.alarm(	gIdntTmrConnAP,
			gAPConnectChkTime,
			tmr.ALARM_AUTO,
			function()
				-- Если доступ есть, останавливаем таймер
				if gAPConnectAvail then
					tmr.stop(gIdntTmrConnAP)
				end
				-- Пытаемся работать с данными
				StartSendData()
			end)

-- Засекам когда пойдут "честные" данные
tmr.alarm(	gIdntTmrTrustedData,
			gDelayBefSending,
			tmr.ALARM_AUTO,
			function()
				gCanSend = true;
				tmr.stop(gIdntTmrTrustedData);
			end)
