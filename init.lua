-- Данные с DHT11 считывает только при частоте CPU в 160 MHz
-- пока не разобрался почему
node.setcpufreq(node.CPU160MHZ);

-- "подключаем" переменные
dofile("my_vars.lua");
-- "подключаем" функции
dofile("my_funcs.lua");
-- Подключаемся к AP
dofile("ap_config.lua");

local vConnCNT=0;
tmr.alarm(	0,
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
						print("Failed to connect AP")
						tmr.stop(0)
					end
				else
				    tmr.stop(0)
				    print("STATION network configuration");
				    print(wifi.sta.getip());
				    ProceedData();
				end
			end)

-- Засекам когда пойдут "честные" данные
tmr.alarm(	1,
			gDelayBefSending,
			tmr.ALARM_AUTO,
			function()
				gCanSend = true;
				tmr.stop(1);
			end)
